---
name: peass
description: PEASS-ng — Privilege Escalation Awesome Scripts Suite (LinPEAS, WinPEAS, MacPEAS). The de facto standard for post-exploitation privilege escalation enumeration. Companion to HackTricks by same author (carlospolop). Use this skill to download, verify, and run PEAS scripts during authorized assessments.
---
# PEASS-ng Skill — Privilege Escalation Enumeration Suite

## Overview
**PEASS-ng** (Privilege Escalation Awesome Scripts Suite — Next Generation) is the industry-standard post-exploitation enumeration toolkit by **carlospolop** (author of HackTricks).

**Repo:** https://github.com/carlospolop/PEASS-ng
**Stars:** 15k+ ⭐
**Components:**
- **LinPEAS** — Linux/Unix privilege escalation auditor (bash + compiled binaries)
- **WinPEAS** — Windows privilege escalation auditor (.exe, .bat, .ps1)
- **MacPEAS** — macOS privilege escalation auditor (bash)

**Online:** https://github.com/carlospolop/PEASS-ng/tree/master/linPEAS (etc.)

---

## Quick Download (Latest Release)

```bash
# LinPEAS (Linux)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -o linpeas.sh
chmod +x linpeas.sh

# LinPEAS (compiled, faster, no dependencies)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64 -o linpeas
chmod +x linpeas

# WinPEAS (Windows x64)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe -o winPEASx64.exe

# WinPEAS (PowerShell - runs in memory)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.ps1 -o winPEAS.ps1

# WinPEAS (Batch)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat -o winPEAS.bat

# MacPEAS
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/macpeas.sh -o macpeas.sh
chmod +x macpeas.sh
```

---

## Verification (Critical!)

**Always verify checksums** before running on target:

```bash
# Check latest release page for SHA256:
# https://github.com/carlospolop/PEASS-ng/releases/latest

# Example verification:
sha256sum linpeas.sh
# Compare with release page value

# Or verify via cosign (if available):
cosign verify-blob --signature linpeas.sh.sig --certificate linpeas.sh.crt linpeas.sh
```

---

## Running LinPEAS

### Basic
```bash
./linpeas.sh
```

### Common Options
```bash
# Quiet (less output)
./linpeas.sh -q

# Only show vulnerabilities (skip info)
./linpeas.sh -v

# Output to file
./linpeas.sh -a > linpeas-output.txt

# Specific checks
./linpeas.sh --no-color --no-banner -q

# Host enumeration only (no network)
./linpeas.sh --host

# Container mode
./linpeas.sh --container
```

### Full Help
```bash
./linpeas.sh -h
```

---

## Running WinPEAS

### Executable (x64)
```cmd
winPEASx64.exe
winPEASx64.exe quiet
winPEASx64.exe cmd
```

### PowerShell (In-Memory, Fileless)
```powershell
# Download and execute in memory
IEX (New-Object Net.WebClient).DownloadString('https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.ps1')

# Or with args
. ./winPEAS.ps1; Invoke-WinPEAS -Quiet
```

### Batch
```cmd
winPEAS.bat
winPEAS.bat quiet
```

---

## Running MacPEAS
```bash
./macpeas.sh
./macpeas.sh -q
```

---

## Key Checks Performed

### LinPEAS
| Category | Checks |
|----------|--------|
| **System Info** | Kernel, distro, hostname, uptime, CPU/RAM |
| **Users** | Current user, sudoers, sudo -l, groups, password policies |
| **SUID/SGID** | All SUID/SGID binaries, GTFOBins matching |
| **Capabilities** | getcap -r /, capability exploitation |
| **Cron/Timer** | /etc/cron*, /etc/systemd/timers, user crontabs |
| **Services** | systemd, init.d, Docker, suspicious services |
| **Files** | Writable /etc/passwd, /etc/shadow, SSH keys, .bash_history |
| **Network** | Listening ports, routing, ARP, Docker/network namespaces |
| **Containers** | Docker socket, k8s tokens, container escape checks |
| **Kernel** | Version, CVEs (via kernel version), modules |
| **Software** | Installed packages, versions, vulnerable software |
| **Cloud** | AWS/GCP/Azure metadata, IMDSv2 |
| **GTFOBins** | Auto-matches SUID/caps/binaries to GTFOBins exploits |

### WinPEAS
| Category | Checks |
|----------|--------|
| **System** | OS version, architecture, hotfixes, language |
| **Users** | Current user, groups, logged users, UAC level |
| **Registry** | AutoLogon, AlwaysInstallElevated, Unquoted Service Paths |
| **Services** | Vulnerable permissions, DLL hijacking, unquoted paths |
| **Scheduled Tasks** | Task Scheduler, startup folder, run keys |
| **Files** | Writable dirs in PATH, unattend.xml, web.config, SSH keys |
| **Tokens** | Token privileges, impersonation, SeImpersonate/SeAssignPrimaryToken |
| **Registry** | AppLocker, SRP, WDAC, PowerShell logging |
| **Network** | Firewall rules, shares, sessions, RDP/WinRM |
| **Drivers** | Vulnerable drivers (DBUtil, etc.) |
| **Kubernetes** | Service account tokens, kubeconfig |
| **Cloud** | Azure IMDS, AWS IMDS, GCP metadata |

---

## Output Interpretation

### Color Codes (LinPEAS)
| Color | Meaning |
|-------|---------|
| **RED** | Critical — likely exploitable |
| **YELLOW** | Interesting — potential vector |
| **GREEN** | Good — security control present |
| **BLUE** | Informational |
| **LIGHT_CYAN** | Commands you can run |

### Common RED Findings
- `SUID binary matches GTFOBins` → Immediate priv esc
- `Writable /etc/passwd` → Add root user
- `Docker socket access` → `docker run -v /:/host -it alpine chroot /host`
- `Kernel exploit available` → Check `linux-hardening/main-system-information/kernel-lpe-cves/`
- `Unquoted service path` → WinPEAS: plant binary in path
- `SeImpersonatePrivilege` → Potato/JuicyPotato/RogueWinRM

---

## Integration with HackTricks

| PEAS Finding | HackTricks Reference |
|--------------|---------------------|
| SUID binary | `linux-hardening/interesting-files-permissions/suid-sgid-and-acl-triage.md` |
| Capabilities | `linux-hardening/interesting-files-permissions/linux-capabilities.md` |
| Sudo abuse | `linux-hardening/main-system-information/sudo-command-abuse.md` |
| Kernel CVE | `linux-hardening/main-system-information/kernel-lpe-cves/` |
| Cron job | `linux-hardening/main-system-information/linux-privilege-escalation-checklist.md` |
| Unquoted path | `windows-hardening/privilege-escalation/unquoted-service-paths.md` |
| Token privs | `windows-hardening/privilege-escalation/token-manipulation.md` |
| AlwaysInstallElevated | `windows-hardening/privilege-escalation/alwaysinstallelevated.md` |

---

## Automation in This Platform

### Custom Tool: Auto-download & Verify
```bash
# Create as custom tool for agents
create_custom_tool(
  key="peass_download",
  kind="script",
  description="Download and verify latest PEAS release",
  exec={code="""
import hashlib, requests, sys
urls = {
  'linpeas.sh': 'https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh',
  'linpeas': 'https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64',
  'winpeas.exe': 'https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe',
  'winpeas.ps1': 'https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.ps1',
  'macpeas.sh': 'https://github.com/carlospolop/PEASS-ng/releases/latest/download/macpeas.sh',
}
for name, url in urls.items():
  r = requests.get(url, timeout=30)
  r.raise_for_status()
  with open(name, 'wb') as f: f.write(r.content)
  sha = hashlib.sha256(r.content).hexdigest()
  print(f'{name}: {sha}')
"""}
)
```

### Run via Shell Session
```bash
# In agent shell session:
shell_open("bash")
shell_send(session_id, text="./linpeas.sh -q", submit=true, wait=true)
```

---

## Safety & Legal
⚠️ **Authorized use only.** PEAS are enumeration tools — they don't exploit, but output reveals attack paths.
- Only run on systems you own or have explicit written authorization for
- Output may contain sensitive data (passwords, keys, tokens) — handle per data policy
- Comply with local laws and engagement rules
- Delete output files after assessment

---

## Related Skills
| Skill | Purpose |
|-------|---------|
| `hacktricks` | Methodology reference for PEAS findings |
| `artex` | Autonomous pentest platform that can run PEAS |
| `scopesentry` | Scope management for engagement boundaries |