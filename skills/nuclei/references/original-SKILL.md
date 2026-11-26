---
name: nuclei
description: Nuclei — Fast, template-based vulnerability scanner (ProjectDiscovery). 15k+ ⭐. Supports 10000+ templates for CVEs, misconfigurations, exposures, tech detection, and more. Use this skill to install, update templates, and run targeted scans during authorized assessments.
---
# Nuclei Skill — Template-Based Vulnerability Scanner

## Overview
**Nuclei** by ProjectDiscovery is the leading fast, template-based vulnerability scanner. Used by bug bounty hunters, pentesters, and security teams worldwide.

**Repo:** https://github.com/projectdiscovery/nuclei
**Templates:** https://github.com/projectdiscovery/nuclei-templates (10,000+)
**Stars:** 15k+ ⭐
**Language:** Go

---

## Installation

### Binary (Recommended)
```bash
# Linux x64
curl -L https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_linux_amd64.zip -o nuclei.zip
unzip nuclei.zip
chmod +x nuclei
sudo mv nuclei /usr/local/bin/

# macOS
curl -L https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_macOS_amd64.zip -o nuclei.zip
unzip nuclei.zip
chmod +x nuclei
sudo mv nuclei /usr/local/bin/

# Windows
curl -L https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_windows_amd64.zip -o nuclei.zip
unzip nuclei.zip
# Add to PATH
```

### Go Install
```bash
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

### Docker
```bash
docker pull projectdiscovery/nuclei:latest
# Run: docker run --rm projectdiscovery/nuclei -u https://target.com -t cves/
```

---

## Template Management

### Update Templates (Daily)
```bash
# Update all templates
nuclei -update-templates

# Update specific template dir
nuclei -update-templates -template-dir ~/nuclei-templates
```

### List Template Categories
```bash
nuclei -tl
```

**Main Categories:**
| Category | Path | Description |
|----------|------|-------------|
| **CVEs** | `cves/` | Known vulnerability templates (10,000+) |
| **Misconfigurations** | `misconfiguration/` | Cloud, k8s, Docker, web server configs |
| **Exposures** | `exposures/` | Sensitive files, debug endpoints, backups |
| **Technologies** | `technologies/` | Fingerprinting (CMS, frameworks, servers) |
| **Takeovers** | `takeovers/` | Subdomain takeover detection |
| **Fuzzing** | `fuzzing/` | Parameter fuzzing templates |
| **Generic** | `generic/` | Generic detections |
| **Token Spray** | `token-spray/` | API token validation |
| **Workflows** | `workflows/` | Multi-step attack chains |
| **Headless** | `headless/` | Browser-based templates |

---

## Basic Usage

### Scan Single Target
```bash
# All templates
nuclei -u https://target.com

# Specific template directory
nuclei -u https://target.com -t cves/

# Multiple targets
nuclei -l targets.txt -t cves/

# With rate limiting
nuclei -u https://target.com -rate-limit 100 -bulk-size 25
```

### Scan with Severity Filter
```bash
# Critical + High only
nuclei -u https://target.com -severity critical,high

# Exclude info/low
nuclei -u https://target.com -severity critical,high,medium
```

### Output Formats
```bash
# JSON (for parsing)
nuclei -u https://target.com -json -o results.json

# Markdown report
nuclei -u https://target.com -markdown-export reports/

# Sarif (for GitHub/SAST)
nuclei -u https://target.com -sarif -o results.sarif

# Template execution summary
nuclei -u https://target.com -stats
```

---

## Advanced Usage

### Custom Templates
```bash
# Local template file
nuclei -u https://target.com -t ./my-template.yaml

# Directory of custom templates
nuclei -u https://target.com -t ./custom-templates/

# Remote template (GitHub raw)
nuclei -u https://target.com -t https://raw.githubusercontent.com/user/repo/main/template.yaml
```

### Workflows (Multi-Step)
```bash
# Run workflow
nuclei -u https://target.com -w workflows/http/cve-2024-xxxx.yaml

# List workflows
nuclei -w workflows/ -tl
```

### Headless (Browser) Templates
```bash
# Requires Chrome/Chromium
nuclei -u https://target.com -headless -t headless/
```

### Authentication
```bash
# Basic auth
nuclei -u https://target.com -basic-auth user:pass

# Header auth
nuclei -u https://target.com -H "Authorization: Bearer TOKEN"

# Cookie
nuclei -u https://target.com -H "Cookie: session=abc123"

# Custom auth script
nuclei -u https://target.com -auth-script auth.js
```

### Proxy & Network
```bash
# HTTP/SOCKS5 proxy
nuclei -u https://target.com -proxy http://127.0.0.1:8080

# Follow redirects
nuclei -u https://target.com -follow-redirects

# Max host error retries
nuclei -u https://target.com -max-host-error 3
```

### Exclude Templates/Tags
```bash
# Exclude by tag
nuclei -u https://target.com -exclude-tags dos,fuzzing

# Exclude by template ID
nuclei -u https://target.com -exclude-id CVE-2021-44228

# Exclude by severity
nuclei -u https://target.com -exclude-severity info,low
```

---

## Template Structure (YAML)

```yaml
id: CVE-2024-XXXX
info:
  name: Target Vulnerability Name
  author: author_name
  severity: critical
  description: |
    Description of the vulnerability
  reference:
    - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-XXXX
  classification:
    cvss-metrics: CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
    cvss-score: 9.8
    cve-id: CVE-2024-XXXX
    cwe-id: CWE-XX
  metadata:
    max-request: 3
    shodan-query: http.title:"Target"
    fofa-query: title="Target"
tags: cve,cve2024,target,rce

http:
  - method: GET
    path:
      - "{{BaseURL}}/vulnerable-endpoint"
    headers:
      User-Agent: nuclei-scanner
    matchers:
      - type: word
        words:
          - "vulnerable_indicator"
        part: body
      - type: status
        status:
          - 200
    extractors:
      - type: regex
        name: version
        regex:
          - "version=([0-9.]+)"
        part: body
```

---

## Common Scan Recipes

### Bug Bounty Recon
```bash
# Wide scan with tech detection + exposures
nuclei -l targets.txt -t technologies/,exposures/ -o recon.json -json

# CVE scan on discovered tech
nuclei -l targets.txt -t cves/ -severity critical,high -o cves.json -json
```

### Internal Network
```bash
# Internal web services
nuclei -l internal-hosts.txt -t misconfiguration/,exposures/,cves/ -rate-limit 50
```

### Kubernetes/Cloud
```bash
# K8s misconfigs
nuclei -u https://k8s-api:6443 -t misconfiguration/kubernetes/ -header "Authorization: Bearer $TOKEN"

# Cloud metadata exposure
nuclei -u http://169.254.169.254 -t exposures/cloud/
```

### API Testing
```bash
# OpenAPI/Swagger
nuclei -u https://api.target.com -t exposures/api/ -t fuzzing/

# GraphQL
nuclei -u https://api.target.com/graphql -t cves/ -tags graphql
```

### CI/CD Pipeline
```bash
# GitHub Actions/GitLab CI
nuclei -u https://github.com/org/repo -t misconfiguration/ci-cd/
```

---

## Integration with Platform

### As Custom Tool
```python
# nuclei_scan.py
import subprocess, json, sys

def run_nuclei(target, templates="cves/", severity="critical,high"):
    cmd = [
        "nuclei", "-u", target,
        "-t", templates,
        "-severity", severity,
        "-json", "-silent"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    findings = []
    for line in result.stdout.strip().split('\n'):
        if line:
            findings.append(json.loads(line))
    return findings

if __name__ == "__main__":
    target = sys.argv[1]
    print(json.dumps(run_nuclei(target), indent=2))
```

### With ARTEX
ARTEX agents can invoke Nuclei via Bash tool for automated scanning.

---

## Template Development

### Create Custom Template
```bash
# Scaffold
nuclei -generate-template

# Validate
nuclei -validate -t my-template.yaml
```

### Template Helpers
| Helper | Description |
|--------|-------------|
| `{{BaseURL}}` | Target base URL |
| `{{Hostname}}` | Target hostname |
| `{{Port}}` | Target port |
| `{{Scheme}}` | http/https |
| `{{Path}}` | Request path |
| `{{RandInt}}` | Random integer |
| `{{RandStr}}` | Random string |
| `{{Timestamp}}` | Unix timestamp |
| `{{HexDecode('...')}}` | Hex decode |
| `{{Base64Decode('...')}}` | Base64 decode |

### Matchers
| Type | Use Case |
|------|----------|
| `word` | String match in body/header |
| `regex` | Regex match |
| `status` | HTTP status code |
| `size` | Response size |
| `binary` | Binary content match |
| `dsl` | DSL expression (complex logic) |
| `xpath` | XML/HTML xpath |

### Extractors
| Type | Use Case |
|------|----------|
| `regex` | Extract via regex |
| `json` | Extract from JSON |
| `xpath` | Extract from XML/HTML |
| `dsl` | Extract via DSL |

---

## Performance Tuning

```bash
# High concurrency
nuclei -u https://target.com -c 100 -rate-limit 500

# Low bandwidth
nuclei -u https://target.com -c 10 -rate-limit 50 -bulk-size 10

# Timeout
nuclei -u https://target.com -timeout 10 -retries 1

# Disable keep-alive
nuclei -u https://target.com -disable-keepalive
```

---

## Safety & Legal
⚠️ **Authorized testing only.** Nuclei sends real HTTP requests that can trigger IDS/IPS, WAF, rate limits, or cause DoS if misconfigured.
- Only scan systems you own or have explicit written authorization for
- Respect `robots.txt` and rate limits
- Use `-rate-limit` and `-c` to control aggressiveness
- Some templates are intrusive (DoS, RCE verification) — review before use
- Comply with bug bounty scope / rules of engagement
- ProjectDiscovery maintains a [template policy](https://github.com/projectdiscovery/nuclei-templates/blob/main/CONTRIBUTING.md)

---

## Related Skills
| Skill | Purpose |
|-------|---------|
| `hacktricks` | Methodology reference for Nuclei findings |
| `artex` | Autonomous platform that can orchestrate Nuclei |
| `api-recon` | API reconnaissance before Nuclei scanning |
| `scopesentry` | Scope management for scan targets |

---

## Quick Links
- **Binary Releases:** https://github.com/projectdiscovery/nuclei/releases
- **Templates:** https://github.com/projectdiscovery/nuclei-templates
- **Documentation:** https://docs.nuclei.sh/
- **Template Guide:** https://docs.nuclei.sh/templates/
- **Discord:** https://discord.gg/projectdiscovery