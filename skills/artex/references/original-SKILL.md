---
name: artex
description: ARTEX — Autonomous AI-driven penetration testing platform (LLM multi-agent). Use this skill to install, configure, and operate ARTEX for authorized security assessments. Covers Docker deployment, task creation, evidence capture, dual-graph architecture, and defense/detection rules from the global edition.
---
# ARTEX Skill — Autonomous Penetration Testing Platform

## Overview
ARTEX is a **self-hosted, LLM-driven autonomous penetration testing system**. It decomposes goals into intents, dispatches workers that run real tools (Bash, HTTP, browser), and accumulates findings into a dual-graph architecture (asset graph + exploration graph) with full evidence capture (MITM proxy, browser extension).

**Key repos:**
- **BaaRai/ARTEX** (14.6k ⭐) — Primary English fork, actively maintained
- **jiwoochris/artex-global** (4.3k ⭐) — Global edition: EN/KR/ZH/ES/JA UI, Sigma/Suricata detection rules, MITRE ATT&CK layer, host triage script

**License:** AGPL-3.0 — derivative works must be open-sourced.

---

## Quick Start (Docker Compose)

```bash
# 1. Clone (choose one)
git clone https://github.com/BaaRai/ARTEX.git          # Main English fork
# OR
git clone https://github.com/jiwoochris/artex-global.git  # Global edition (multi-lang + defense rules)
cd ARTEX  # or artex-global

# 2. Configure
cp .env.example .env
# Edit .env: set POSTGRES_PASSWORD (required), optionally LLM_API_KEY, LLM_BASE_URL

# 3. Launch
docker compose up -d --build

# 4. Get setup token
docker compose logs artex | grep "Setup token"
# Open http://localhost:8787 → enter token → create admin user

# 5. Configure LLM (System → LLM)
# Add Anthropic/OpenAI/Ollama profile, then set as active in System → Settings
```

---

## Core Concepts

### Dual-Graph Architecture
| Graph | Scope | Purpose |
|-------|-------|---------|
| **Asset Graph** | Global (shared across tasks) | Source of truth: `root_domain`, `subdomain`, `ip`, `service`, `app`, `endpoint`, `company` |
| **Exploration Graph** | Per-task | Reasoning trail: `goal` → `intent` → `fact` → `finding` → `hint` (edges: spawns/yields/derived_from/proves) |
| **Anchors** | Link both | `exploration_anchors(node_id, asset_id)` ties intents/facts/findings to concrete assets |

### Engine Loop
```
Planner (reads exploration graph) → dispatches intents → Worker claims intent →
Worker executes real tools (traced via MITM proxy) → writes back facts/assets/findings →
graph change wakes planner again (closed loop until goal proven)
```

### Evidence Capture
- **Recording MITM proxy** (:8788) with generated CA — all Bash/HTTP tool calls traced
- **Browser extension** (`extension/`) — log in once (CAPTCHA, 2FA), capture authenticated session
- **Findings bind to traffic** — POE level, verification status, verbatim evidence quotes

### Autonomy with Brakes
- **Interception gate** — human approval per tool call (string/regex/argv-prefix rules)
- **Scope gate** — assets outside declared scope not explored
- **Target gate** (opt-in) — refuse unapproved destinations
- **Budgets** — token/turn limits per task
- **Prompt-injection framing** — tool output treated as untrusted data

---

## Operating ARTEX

### Create a Task (UI or API)
1. **Dashboard → New Task**
2. Fill: Description, Goal, Target scope (domains/IPs/CIDRs)
3. Select LLM profile(s), enable **multi-LLM rotation** for resilience
4. Set worker concurrency (System → Settings → Worker count ≥ 2)
5. Start — planner begins decomposing goal

### Monitor Progress
- **Tasks view** — active/completed, token spend, findings count
- **Exploration graph** — visual lineage of intents → facts → findings
- **Asset coverage graph** — what % of in-scope assets tested
- **Traffic viewer** — request/response for any finding
- **Human-in-the-loop chat** — inject hints mid-run

### Key APIs (for automation)
```bash
# Create task
curl -X POST http://localhost:8787/api/tasks \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"description":"Test example.com","goal":"Full web app assessment","scope":["example.com"]}'

# List tasks
curl -H "Authorization: Bearer $TOKEN" http://localhost:8787/api/tasks

# Get task graph
curl -H "Authorization: Bearer $TOKEN" http://localhost:8787/api/tasks/{id}/graph

# List findings
curl -H "Authorization: Bearer $TOKEN" http://localhost:8787/api/tasks/{id}/findings

# Add hint mid-run
curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"text":"Focus on /api/v1/ endpoints for IDOR"}' \
  http://localhost:8787/api/tasks/{id}/hints
```

---

## Defense & Detection (from artex-global)

The **global edition** includes defender-oriented material:

### Detection Rules (`detections/`)
| Layer | Format | Purpose |
|-------|--------|---------|
| **Host/Log/SIEM** | Sigma (YAML) | Atomic + correlation rules → convert for Splunk/Elastic/OpenSearch |
| **Network** | Suricata | Target ARTEX enrich prober & norma SDK User-Agents |
| **ATT&CK Coverage** | JSON (Navigator layer) | Maps rules to MITRE techniques |
| **IoC Indicators** | CSV + MISP JSON | Verified fingerprints for SIEM lookup / threat-intel platforms |

### Host Triage Script
```bash
# Run on a suspected host (stdlib only, no deps)
python3 detections/triage/artex_host_triage.py
# Checks: listen port 8787, proxy 8788, Postgres exploration schema, keys/, data/
```

### Defense Guide
- `docs/defense-en.md` (also `defense-ko.md`) — How autonomous AI attacks differ from scanners, observable fingerprints, hardening checklist, WAF/SIEM pseudo-rules, Korean reporting channels (KISA, FSI, PIPC)

---

## Configuration Reference

### Environment Variables (`.env`)
```bash
# Required
POSTGRES_PASSWORD=strong_random_password

# LLM (at least one)
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Optional
ARTEX_SECRET_KEY=base64_32_bytes  # for encrypted secrets at rest (generate: openssl rand -base64 32)
ARTEX_JWT_KEY=base64_32_bytes     # JWT signing (auto-generated if absent)
ARTEX_BIND=0.0.0.0:8787           # web UI bind
ARTEX_PROXY_BIND=0.0.0.0:8788     # MITM proxy bind
ARTEX_UPDATE_CHECK=1              # show update banner (checks GitHub releases daily)
ARTEX_TRUSTED_PROXIES=10.0.0.0/8  # for correct client IP behind reverse proxy
```

### Multi-LLM Rotation
In **System → LLM** create multiple profiles. In **task creation** or `PUT /api/tasks/{id}/llm`:
```json
{
  "llm_profile_ids": [1, 2],
  "llm_rotate": true
}
```
Workers cycle A→B→A→B across intents; planner stays on task profile.

---

## Updating
```bash
cd ARTEX
./update.sh
# Or manually:
git pull
docker compose build artex
docker compose up -d artex
```
Data preserved: `pgdata` volume, `./data`, `./keys`, `./skills`.

---

## Development Mode
```bash
./dev.sh
# Backend:  :8787 (go run ./cmd/artex)
# Proxy:    :8788
# Frontend: :5173 (Next.js hot reload)
# Open http://localhost:5173
```

---

## Skill Usage Patterns

### Pattern 1: Deploy ARTEX for an Assessment
```bash
# Use this skill to spin up ARTEX, configure LLM, create task for target
# Then monitor via UI or API until findings generated
```

### Pattern 2: Export Findings for Reporting
```bash
# GET /api/tasks/{id}/findings → CSV/JSON
# Each finding includes: title, severity, POE, verification status, evidence quotes, bound traffic
```

### Pattern 3: Run Detection Rules Against Logs
```bash
# Convert Sigma rules: sigma convert -t splunk detections/*.yml
# Deploy Suricata rules: copy detections/suricata/*.rules to /etc/suricata/rules/
# Import MISP IoCs: detections/indicators/artex_indicators.misp.json
```

### Pattern 4: Host Triage
```bash
# Copy detections/triage/artex_host_triage.py to target, run with python3
```

---

## Safety & Legal
⚠️ **Authorized use only.** ARTEX can carry an attack from recon → intrusion → exfiltration autonomously.
- Only test systems you own or have explicit written authorization for
- Respect bug bounty scope / rules of engagement
- Comply with local laws (Korea: 정보통신망법, 개인정보보호법; your jurisdiction's equivalents)
- This skill is for **defensive learning, authorized testing, and detection engineering**

---

## References
- BaaRai/ARTEX: https://github.com/BaaRai/ARTEX
- jiwoochris/artex-global: https://github.com/jiwoochris/artex-global
- Agent SDK (norma): https://github.com/Autumn-27/norma
- ScopeSentry (scope mgmt): https://github.com/Autumn-27/ScopeSentry
- Architecture docs: `docs/ARCHITECTURE.md`, `docs/OPS.md`