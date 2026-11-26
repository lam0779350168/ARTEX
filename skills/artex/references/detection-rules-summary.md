# ARTEX Detection Rules Summary (from artex-global)

## Sigma Rules (`detections/sigma/`)

| Rule File | Technique | Description |
|-----------|-----------|-------------|
| `artex-enrich-prober.yml` | T1590.005 | Detects ARTEX's async HTTP/DNS enrichment prober User-Agent |
| `artex-norma-sdk-webfetch.yml` | T1590.005 | Detects norma SDK WebFetch tool User-Agent pattern |
| `artex-recording-proxy.yml` | T1040 | Network traffic capture via ARTEX MITM proxy |
| `artex-browser-extension.yml` | T1539 | Browser extension capture activity |
| `artex-autonomous-recon.yml` | T1590 | Autonomous reconnaissance chain patterns |
| `artex-credential-access.yml` | T1555 | Credential access via autonomous tools |

**Convert for your SIEM:**
```bash
# Splunk
sigma convert -t splunk detections/sigma/*.yml

# Elasticsearch/OpenSearch
sigma convert -t elastalert detections/sigma/*.yml

# Generic JSON
sigma convert -t json detections/sigma/*.yml
```

## Suricata Rules (`detections/suricata/`)

| Rule File | Target |
|-----------|--------|
| `artex-enrich.rules` | Enrichment prober HTTP requests |
| `artex-webfetch.rules` | WebFetch tool traffic |
| `artex-proxy.rules` | Recording proxy CA/mitm traffic |

**Deploy:**
```bash
cp detections/suricata/*.rules /etc/suricata/rules/
suricata -T -c /etc/suricata/suricata.yaml  # test
systemctl reload suricata
```

## MITRE ATT&CK Navigator Layer
- `detections/attack/artex-attack-layer.json` — Import into https://mitre-attack.github.io/attack-navigator/
- Shows which techniques each Sigma/Suricata rule covers

## IoC Indicators (`detections/indicators/`)
- `artex_indicators.csv` — Machine-readable: `indicator,type,source_rule,source_file,description`
- `artex_indicators.misp.json` — Ready for MISP / OpenCTI / threat intel platforms

## Host Triage Script
```bash
# Zero-dependency, stdlib only
python3 detections/triage/artex_host_triage.py

# Checks:
# 1. Process listening on :8787 (ARTEX API)
# 2. Process listening on :8788 (MITM proxy)
# 3. PostgreSQL schema: exploration_nodes, exploration_anchors, assets, companies
# 4. ./keys/ (jwt.key, secret.key)
# 5. ./data/ (traffic index, task files)
# 6. Browser extension artifacts
```

## Defense Guide
- `docs/defense-en.md` — Full defender playbook (also `defense-ko.md`)
- Covers: AI attack vs scanner differences, observable fingerprints (target view + forensic view), hardening checklist, WAF/SIEM pseudo-rules, IR summary, Korean reporting channels (KISA, FSI, PIPC)

## Usage in This Platform
```bash
# As a custom tool, you could create a Sigma converter or Suricata deployer
# Or use the host triage script via shell command
```