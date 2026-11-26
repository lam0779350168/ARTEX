# HackTricks Quick Reference Card

## 🔍 Most Frequently Used Sections

### Web App Testing
| Topic | Path |
|-------|------|
| **Web Methodology** | `pentesting-web/web-vulnerabilities-methodology.md` |
| **Recon** | `pentesting-web/web-reconnaissance.md` |
| **WAF/403 Bypass** | `pentesting-web/403-and-401-bypasses.md` |
| **SQL Injection** | `pentesting-web/sql-injection/README.md` |
| **XSS** | `pentesting-web/xss-cross-site-scripting/README.md` |
| **SSRF** | `pentesting-web/ssrf.md` |
| **XXE** | `pentesting-web/xxe-xee-xml-external-entity.md` |
| **Deserialization** | `pentesting-web/deserialization/` |
| **SSTI** | `pentesting-web/server-side-template-injection.md` |
| **Prototype Pollution** | `pentesting-web/prototype-pollution.md` |
| **GraphQL** | `pentesting-web/graphql.md` |
| **OAuth/OIDC/SAML** | `pentesting-web/oauth.md` |
| **JWT** | `pentesting-web/json-web-tokens-jwt.md` |
| **File Upload** | `pentesting-web/file-upload.md` |
| **LFI/RFI** | `pentesting-web/file-inclusion.md` |
| **IDOR** | `pentesting-web/idors.md` |
| **Race Conditions** | `pentesting-web/race-conditions.md` |
| **Cache Poisoning** | `pentesting-web/web-cache-poisoning.md` |
| **HTTP Smuggling** | `pentesting-web/http-request-smuggling.md` |
| **XS-Leaks** | `pentesting-web/xs-search/README.md` |
| **CSP Bypass** | `pentesting-web/content-security-policy-csp-bypass.md` |

### Network Services
| Service | Path |
|---------|------|
| **SMB** | `network-services-pentesting/pentesting-smb.md` |
| **LDAP** | `network-services-pentesting/pentesting-ldap.md` |
| **Kerberos** | `network-services-pentesting/pentesting-kerberos-88.md` |
| **DNS** | `network-services-pentesting/pentesting-dns.md` |
| **RDP** | `network-services-pentesting/pentesting-rdp.md` |
| **SSH** | `network-services-pentesting/pentesting-ssh.md` |
| **FTP** | `network-services-pentesting/pentesting-ftp.md` |
| **SMTP** | `network-services-pentesting/pentesting-smtp.md` |
| **SNMP** | `network-services-pentesting/pentesting-snmp.md` |
| **MySQL** | `network-services-pentesting/pentesting-mysql.md` |
| **PostgreSQL** | `network-services-pentesting/pentesting-postgresql.md` |
| **MSSQL** | `network-services-pentesting/pentesting-mssql.md` |
| **Oracle** | `network-services-pentesting/pentesting-oracle.md` |
| **Redis** | `network-services-pentesting/pentesting-redis.md` |
| **MongoDB** | `network-services-pentesting/pentesting-mongodb.md` |
| **Elasticsearch** | `network-services-pentesting/pentesting-elasticsearch.md` |
| **Docker** | `network-services-pentesting/pentesting-docker.md` |
| **Kubernetes** | `network-services-pentesting/pentesting-kubernetes.md` |
| **Jenkins** | `network-services-pentesting/pentesting-jenkins.md` |
| **GitLab** | `network-services-pentesting/pentesting-gitlab.md` |
| **VNC** | `network-services-pentesting/pentesting-vnc.md` |

### Linux Privilege Escalation
| Topic | Path |
|-------|------|
| **Checklist** | `linux-hardening/main-system-information/linux-privilege-escalation-checklist.md` |
| **SUID/SGID** | `linux-hardening/interesting-files-permissions/suid-sgid-and-acl-triage.md` |
| **Capabilities** | `linux-hardening/interesting-files-permissions/linux-capabilities.md` |
| **Sudo** | `linux-hardening/main-system-information/sudo-command-abuse.md` |
| **Kernel CVEs** | `linux-hardening/main-system-information/kernel-lpe-cves/README.md` |
| **Escaping Jails** | `linux-hardening/main-system-information/escaping-from-limited-bash.md` |
| **Cron/Timer** | `linux-hardening/main-system-information/linux-privilege-escalation-checklist.md#cron-jobs` |
| **NFS** | `linux-hardening/interesting-files-permissions/nfs-no_root_squash-misconfiguration-pe.md` |
| **Containers** | `linux-hardening/main-system-information/escaping-from-limited-bash.md#docker` |

### Windows / Active Directory
| Topic | Path |
|-------|------|
| **AD Methodology** | `windows-hardening/active-directory-methodology/README.md` |
| **Kerberoasting** | `windows-hardening/active-directory-methodology/kerberoasting.md` |
| **AS-REP Roasting** | `windows-hardening/active-directory-methodology/as-rep-roasting.md` |
| **DCSync** | `windows-hardening/active-directory-methodology/dcsync.md` |
| **Golden/Silver Ticket** | `windows-hardening/active-directory-methodology/golden-ticket.md` |
| **Pass-the-Hash/Ticket** | `windows-hardening/active-directory-methodology/pass-the-hash.md` |
| **Delegation** | `windows-hardening/active-directory-methodology/delegation.md` |
| **GPO Abuse** | `windows-hardening/active-directory-methodology/gpo-abuse.md` |
| **ACL/ACE** | `windows-hardening/active-directory-methodology/acl-ace-abuse.md` |
| **LAPS** | `windows-hardening/active-directory-methodology/laps.md` |
| **Certificates/AD CS** | `windows-hardening/active-directory-methodology/ad-cs.md` |
| **Lateral Movement** | `windows-hardening/lateral-movement/README.md` |
| **Privilege Escalation** | `windows-hardening/privilege-escalation/README.md` |
| **AMSI Bypass** | `windows-hardening/antivirus-bypass/amsi-bypass.md` |
| **AppLocker Bypass** | `windows-hardening/applocker-bypass.md` |
| **Event Log Tampering** | `windows-hardening/event-log-tampering.md` |

### Cloud
| Topic | Path |
|-------|------|
| **Kubernetes** | `https://cloud.hacktricks.wiki/en/pentesting-cloud/kubernetes-security/` |
| **AWS** | `https://cloud.hacktricks.wiki/en/pentesting-cloud/pentesting-cloud-methodology.html#aws` |
| **GCP** | `https://cloud.hacktricks.wiki/en/pentesting-cloud/pentesting-cloud-methodology.html#gcp` |
| **Azure** | `https://cloud.hacktricks.wiki/en/pentesting-cloud/pentesting-cloud-methodology.html#azure` |
| **CI/CD** | `https://cloud.hacktricks.wiki/en/pentesting-ci-cd/pentesting-ci-cd-methodology.html` |

### Mobile
| Topic | Path |
|-------|------|
| **Android** | `mobile-pentesting/android-app-pentesting/README.md` |
| **iOS** | `mobile-pentesting/ios-app-pentesting/README.md` |
| **Frida** | `mobile-pentesting/android-app-pentesting/frida.md` |
| **Objection** | `mobile-pentesting/android-app-pentesting/objection.md` |
| **Certificate Pinning** | `mobile-pentesting/android-app-pentesting/certificate-pinning.md` |

### Binary Exploitation
| Topic | Path |
|-------|------|
| **Stack Overflow** | `binary-exploitation/stack-overflow/README.md` |
| **ROP/JOP** | `binary-exploitation/rop-return-oriented-programing/README.md` |
| **Heap** | `binary-exploitation/libc-heap/README.md` |
| **Format Strings** | `binary-exploitation/format-strings/README.md` |
| **Kernel (Linux)** | `binary-exploitation/linux-kernel-exploitation/README.md` |
| **Kernel (Windows)** | `binary-exploitation/windows-kernel-exploitation/README.md` |
| **VM Escape** | `binary-exploitation/vm-escape-and-hypervisor-exploitation/README.md` |

### AI / LLM Security
| Topic | Path |
|-------|------|
| **AI Agent Security** | `AI/AI-Agent-Security-Methodology.md` |
| **MCP Security** | `AI/AI-MCP-Servers.md` |
| **A2A Protocol** | `AI/AI-A2A-Protocol.md` |
| **Prompt Injection** | `AI/AI-Prompts.md` |
| **LLM Gateway** | `AI/AI-LLM-Gateway-Security.md` |
| **AI-Assisted Fuzzing** | `AI/AI-Assisted-Fuzzing-and-Vulnerability-Discovery.md` |

### Recon & OSINT
| Topic | Path |
|-------|------|
| **External Recon** | `generic-methodologies-and-resources/external-recon-methodology/README.md` |
| **Threat Intel APIs** | `generic-methodologies-and-resources/external-recon-methodology/reconnaissance-and-threat-intelligence-apis.md` |
| **GitHub Dorks** | `generic-methodologies-and-resources/external-recon-methodology/github-leaked-secrets.md` |
| **Database Leaks** | `generic-methodologies-and-resources/external-recon-methodology/database-leaks.md` |
| **Wide Source Code Search** | `generic-methodologies-and-resources/external-recon-methodology/wide-source-code-search.md` |

### Forensics
| Topic | Path |
|-------|------|
| **Linux Forensics** | `generic-methodologies-and-resources/basic-forensic-methodology/linux-forensics.md` |
| **Windows Forensics** | `generic-methodologies-and-resources/basic-forensic-methodology/windows-forensics/README.md` |
| **Memory (Volatility)** | `generic-methodologies-and-resources/basic-forensic-methodology/memory-dump-analysis/volatility-cheatsheet.md` |
| **PCAP/Wireshark** | `generic-methodologies-and-resources/basic-forensic-methodology/pcap-inspection/wireshark-tricks.md` |
| **Docker Forensics** | `generic-methodologies-and-resources/basic-forensic-methodology/docker-forensics.md` |
| **Browser Artifacts** | `generic-methodologies-and-resources/basic-forensic-methodology/specific-software-file-type-tricks/browser-artifacts.md` |

---

## 🚀 One-Liners

### Start Local Instance
```bash
# English (default)
docker run -d --rm -p 3337:3000 -v $(pwd)/hacktricks:/app ghcr.io/hacktricks-wiki/hacktricks-cloud/translator-image bash -c "cd /app && git checkout master && git pull && mdbook serve --hostname 0.0.0.0"

# Spanish
export HT_LANG="es" && docker compose up -d
```

### Search Local Repo
```bash
grep -r "kerberoasting" hacktricks/src --include="*.md" -l
grep -r "sql injection" hacktricks/src/pentesting-web --include="*.md" -l
```

### Build PDF (requires mdbook-pdf)
```bash
cd hacktricks && mdbook build && mdbook-pdf build
```

---

## 🔗 External Companion Repos
| Repo | Description |
|------|-------------|
| **PEASS-ng** | https://github.com/carlospolop/PEASS-ng — Privilege escalation scripts (LinPEAS/WinPEAS) |
| **HackTricks CLI** | `pip install hacktricks-cli` — Community CLI tool |
| **Cloud HackTricks** | https://cloud.hacktricks.wiki — Dedicated cloud security wiki |
| **PEASS-ng Releases** | https://github.com/carlospolop/PEASS-ng/releases — Precompiled binaries |

---

## 📝 Contributing
- Edit `.md` files in `src/`
- PR to `master` branch
- Follow style guide in `CONTRIBUTING.md`
- Translations: create branch `<lang>` (e.g., `es`, `fr`)

---

## ⚖️ License
**CC BY-NC-SA 4.0** — Attribution, Non-Commercial, ShareAlike.
See `src/LICENSE.md` and `welcome/hacktricks-values-and-faq.md`.