# syntax=docker/dockerfile:1
#
# Multi-stage build for the published release binary.
#
#   release binary (dist/artex, extracted from artex-0.7.0-linux-amd64.zip)
#     -> runtime image (tools + embedded UI binary)
#
# To build from source instead, restore the upstream `web` and `build` stages and
# put back `COPY --from=build /out/artex /app/artex` in the runtime stage.

# ------------------------------------------------------- release binary ---
FROM scratch AS build
COPY dist/artex /out/artex

# ------------------------------------------------------- third-party tools ---
# Web-recon toolbox (drost-community take 1, #100): pinned release binaries, staged
# on the build platform and copied into /usr/local/bin of the runtime image so hunt
# workers can run them directly through their Bash tool. Versions pinned per tool;
# upgrade deliberately.
#
# Every archive is verified against a SHA-256 written down here, per asset and per
# architecture, not against the *_checksums.txt of its own GitHub release. Checking
# against that file catches a corrupted or swapped download and a moved tag, but the
# digest and the artifact it describes come from the same publisher and the same
# release: a replacement asset and a replacement checksums file agree with each
# other and the build passes. Pinning the digest here moves that decision out of the
# build, so a swapped asset fails unless the diff that swaps it also changes the
# digest a reviewer reads.
#
# Cost: a version bump is now three edits (the version ARG and the two digests), and
# a publisher re-uploading an asset under the same tag breaks the build until the
# digest is bumped on purpose. That is the trade: the build stops trusting the
# channel it downloads from.
#
# sqlmap has no release binaries: it is a shallow clone of a pinned tag, checked
# against the expected commit, which is the same idea.
FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS tools
ARG TARGETARCH
ARG NUCLEI_VERSION=v3.11.1
ARG NUCLEI_SHA256_AMD64=ea63d4ae232808cd7c6bc00d0142428e231fab59dae01042246097d195835ab6
ARG NUCLEI_SHA256_ARM64=8044e3d9768ba0a744b2872c1a87e813006f013da97ca9f50f7661a4203bec07
ARG HTTPX_VERSION=v1.12.0
ARG HTTPX_SHA256_AMD64=9d8439e8b6c9aa7d1e2314817a392e00d5178da3af5652f7475f88868f418f76
ARG HTTPX_SHA256_ARM64=fd7b123c1dfbc3d69f19f524e4eebcd6ec06b9a6cbd56813c76f11645197331e
ARG SUBFINDER_VERSION=v2.17.0
ARG SUBFINDER_SHA256_AMD64=a39c3e5c7a26ef3c430915c4d6cbf7716a00f26769a75e9405aba796142eba37
ARG SUBFINDER_SHA256_ARM64=24913d49dddc1d3a5e99a4a7580da5be980959b9415b96f52c4f7f4124392190
ARG KATANA_VERSION=v1.8.0
ARG KATANA_SHA256_AMD64=cb027ae99d0757061b70c07a15c7a80f62c5a535ab52c4a329f80c4b0a7309d2
ARG KATANA_SHA256_ARM64=80e269210727a855511ffac8dfb01297b2344742acec71a35e8ba4a67a90f0f2
ARG FFUF_VERSION=v2.3.0
ARG FFUF_SHA256_AMD64=b2a3c725fcb9da175159682f54d6e9149f2905b00d84d155e7efc5d599975ceb
ARG FFUF_SHA256_ARM64=e2d712615d53da797ee929006e41f2df5a7960a5353133db9c150ddaa22ae4e8
ARG DALFOX_VERSION=v3.2.4
ARG DALFOX_SHA256_AMD64=c11cfd2f8261973f0a2a2a1eba5a147ce77712a29acfa6343f9847fb8bb7eca2
ARG DALFOX_SHA256_ARM64=fd56b0b7da2d06868cd73b504f41d21314629feffcd5bdc97718db1c9dd2fa70
ARG SQLMAP_VERSION=1.9.9
ARG SQLMAP_COMMIT=cceda39208b5aad478de2c3f731df4239d9881f6
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip \
    && rm -rf /var/lib/apt/lists/*
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) PD_ARCH=amd64; FFUF_ARCH=amd64; DALFOX_ARCH=x86_64; \
             NUCLEI_SUM="$NUCLEI_SHA256_AMD64"; HTTPX_SUM="$HTTPX_SHA256_AMD64"; \
             SUBFINDER_SUM="$SUBFINDER_SHA256_AMD64"; KATANA_SUM="$KATANA_SHA256_AMD64"; \
             FFUF_SUM="$FFUF_SHA256_AMD64"; DALFOX_SUM="$DALFOX_SHA256_AMD64" ;; \
      arm64) PD_ARCH=arm64; FFUF_ARCH=arm64; DALFOX_ARCH=aarch64; \
             NUCLEI_SUM="$NUCLEI_SHA256_ARM64"; HTTPX_SUM="$HTTPX_SHA256_ARM64"; \
             SUBFINDER_SUM="$SUBFINDER_SHA256_ARM64"; KATANA_SUM="$KATANA_SHA256_ARM64"; \
             FFUF_SUM="$FFUF_SHA256_ARM64"; DALFOX_SUM="$DALFOX_SHA256_ARM64" ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    mkdir -p /out; \
    fetch() { base="$1"; asset="$2"; want="$3"; name="$4"; \
      rm -rf /tmp/t; mkdir -p /tmp/t/x; \
      curl -fsSL "$base/$asset" -o "/tmp/t/$asset"; \
      if [ -z "$want" ]; then echo "no pinned digest for $asset" >&2; exit 1; fi; \
      got="$(sha256sum "/tmp/t/$asset" | cut -d' ' -f1)"; \
      if [ "$want" != "$got" ]; then echo "checksum mismatch for $asset: want $want got $got" >&2; exit 1; fi; \
      case "$asset" in *.zip) unzip -q "/tmp/t/$asset" -d /tmp/t/x ;; *) tar -xzf "/tmp/t/$asset" -C /tmp/t/x ;; esac; \
      find /tmp/t/x -type f -name "$name" -exec install -m 0755 {} /out/ \; ; \
      [ -x "/out/$name" ] || { echo "$name not found in $asset" >&2; exit 1; }; \
      rm -rf /tmp/t; }; \
    gh="https://github.com"; \
    fetch "$gh/projectdiscovery/nuclei/releases/download/$NUCLEI_VERSION" \
      "nuclei_${NUCLEI_VERSION#v}_linux_${PD_ARCH}.zip" "$NUCLEI_SUM" nuclei; \
    fetch "$gh/projectdiscovery/httpx/releases/download/$HTTPX_VERSION" \
      "httpx_${HTTPX_VERSION#v}_linux_${PD_ARCH}.zip" "$HTTPX_SUM" httpx; \
    fetch "$gh/projectdiscovery/subfinder/releases/download/$SUBFINDER_VERSION" \
      "subfinder_${SUBFINDER_VERSION#v}_linux_${PD_ARCH}.zip" "$SUBFINDER_SUM" subfinder; \
    fetch "$gh/projectdiscovery/katana/releases/download/$KATANA_VERSION" \
      "katana_${KATANA_VERSION#v}_linux_${PD_ARCH}.zip" "$KATANA_SUM" katana; \
    fetch "$gh/ffuf/ffuf/releases/download/$FFUF_VERSION" \
      "ffuf_${FFUF_VERSION#v}_linux_${FFUF_ARCH}.tar.gz" "$FFUF_SUM" ffuf; \
    fetch "$gh/hahwul/dalfox/releases/download/$DALFOX_VERSION" \
      "dalfox-${DALFOX_VERSION}-linux-${DALFOX_ARCH}-musl.tar.gz" "$DALFOX_SUM" dalfox; \
    git clone --quiet --depth 1 --branch "$SQLMAP_VERSION" https://github.com/sqlmapproject/sqlmap /opt/sqlmap; \
    commit="$(git -C /opt/sqlmap rev-parse HEAD)"; \
    if [ "$commit" != "$SQLMAP_COMMIT" ]; then echo "sqlmap commit mismatch: want $SQLMAP_COMMIT got $commit" >&2; exit 1; fi; \
    rm -rf /opt/sqlmap/.git

# ------------------------------------------------------- Go exploit toolbox ---
# Built in a throwaway stage so the runtime image carries no Go toolchain.
FROM --platform=$BUILDPLATFORM golang:1.26-bookworm AS gobins
ENV CGO_ENABLED=0 GOBIN=/out GOFLAGS=-trimpath
RUN set -eux; \
    mkdir -p /out; \
    go install github.com/owasp-amass/amass/v4/cmd/amass@latest; \
    go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest; \
    go install github.com/lc/gau/v2/cmd/gau@latest; \
    go install github.com/tomnomnom/waybackurls@latest; \
    go install github.com/PentestPad/subzy@latest; \
    go install github.com/jpillora/chisel@latest; \
    go install github.com/nicocha30/ligolo-ng/cmd/proxy@latest; \
    go install github.com/nicocha30/ligolo-ng/cmd/agent@latest; \
    go install github.com/ropnop/kerbrute@latest; \
    mv /out/proxy /out/ligolo-proxy; \
    mv /out/agent /out/ligolo-agent; \
    ln -s ligolo-proxy /out/ligolo-ng; \
    ls -l /out

# ---------------------------------------------------- exploit/payload toolbox ---
# amd64-only: the release binaries below are published for x86-64 only.
# The git checkouts track their default branch; pin them when the build must be
# reproducible.
FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS exploit
ARG TARGETARCH
RUN set -eux; \
    [ "${TARGETARCH:-amd64}" = "amd64" ] || { echo "exploit toolbox is amd64-only" >&2; exit 1; }; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl git build-essential \
      libssl-dev swig libkrb5-dev libldap2-dev libsasl2-dev libffi-dev; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /out /opt; \
    curl -fsSL https://github.com/epi052/feroxbuster/releases/download/v2.14.0/x86_64-linux-feroxbuster.tar.gz -o /tmp/ferox.tar.gz; \
    printf '%s  %s\n' 3ab2cefdb03af090bcf11c4b82bd85a7e8a2b4439237ac06993568eade28ee96 /tmp/ferox.tar.gz | sha256sum -c -; \
    tar -xzf /tmp/ferox.tar.gz -C /out feroxbuster; \
    curl -fsSL https://github.com/Sh1Yo/x8/releases/download/v4.3.0/x86_64-linux-x8.gz -o /tmp/x8.gz; \
    printf '%s  %s\n' b3e54da4c0cc62163a3485addea6671368ee69342ea5740e56d6d6112196bd0e /tmp/x8.gz | sha256sum -c -; \
    gunzip -c /tmp/x8.gz > /out/x8; \
    curl -fsSL https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64 -o /out/pspy64; \
    printf '%s  %s\n' c93f29a5cc1347bdb90e14a12424e6469c8cfea9a20b800bc249755f0043a3bb /out/pspy64 | sha256sum -c -; \
    curl -fsSL https://github.com/peass-ng/PEASS-ng/releases/download/20261122-25957cb1/linpeas.sh -o /out/linpeas.sh; \
    printf '%s  %s\n' c74e1bc0922b082efd58d06d1f8731ceecb84bf56cc575270d4c52e39b2feb02 /out/linpeas.sh | sha256sum -c -; \
    curl -fsSL https://github.com/peass-ng/PEASS-ng/releases/download/20261122-25957cb1/winPEASx64.exe -o /out/winPEASx64.exe; \
    printf '%s  %s\n' 6fd215c352d974fcfe939b03eb3b49f910237891f2eaaa48080a9674b2f48598 /out/winPEASx64.exe | sha256sum -c -; \
    chmod +x /out/*; \
    git clone --depth 1 https://github.com/blechschmidt/massdns /tmp/massdns; \
    make -C /tmp/massdns -j"$(nproc)"; \
    cp /tmp/massdns/bin/massdns /out/massdns; \
    rm -rf /tmp/massdns; \
    git clone --depth 1 https://github.com/swisskyrepo/PayloadsAllTheThings /opt/payloadsallthethings; \
    git clone --depth 1 https://github.com/danielmiessler/SecLists /opt/seclists; \
    git clone --depth 1 https://gitlab.com/exploit-database/exploitdb /opt/exploitdb; \
    git clone --depth 1 https://github.com/sullo/nikto /opt/nikto; \
    git clone --depth 1 https://github.com/commixproject/commix /opt/commix; \
    git clone --depth 1 https://github.com/s0md3v/XSStrike /opt/xsstrike; \
    git clone --depth 1 https://github.com/ticarpi/jwt_tool /opt/jwt_tool; \
    git clone --depth 1 https://github.com/defparam/smuggler /opt/smuggler; \
    git clone --depth 1 https://github.com/codingo/NoSQLMap /opt/nosqlmap; \
    git clone --depth 1 https://github.com/lgandx/Responder /opt/responder; \
    git clone --depth 1 https://github.com/CiscoCXSecurity/enum4linux /opt/enum4linux; \
    git clone --depth 1 https://github.com/cddmp/enum4linux-ng /opt/enum4linux-ng; \
    git clone --depth 1 https://github.com/ropnop/windapsearch /opt/windapsearch; \
    git clone --depth 1 https://github.com/s0md3v/Corsy /opt/corsy; \
    git clone --depth 1 https://github.com/dolevf/graphql-cop /opt/graphql-cop; \
    find /opt -name .git -prune -exec rm -rf {} +; \
    du -sh /opt/*

# --------------------------------------------------------- toolserver binary ---
# One generic JSON-RPC wrapper; each catalogued repo runs it with --tool <name>.
FROM --platform=$BUILDPLATFORM golang:1.26-bookworm AS toolserver
WORKDIR /src
COPY go.mod go.sum ./
COPY tools/ ./tools/
COPY cmd/toolserver/ ./cmd/toolserver/
RUN CGO_ENABLED=0 GOFLAGS=-trimpath go build -o /out/toolserver ./cmd/toolserver

# ------------------------------- extra scan/audit binaries (pinned releases) ---
FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS scanbins
ARG TARGETARCH
ARG TRUFFLEHOG_VERSION=3.100.1
ARG GITLEAKS_VERSION=8.30.1
ARG OSV_VERSION=2.7.1
ARG TRIVY_VERSION=0.76.2
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl tar gzip; \
    rm -rf /var/lib/apt/lists/*; \
    case "${TARGETARCH:-amd64}" in \
      amd64) PD_ARCH=amd64; GL_ARCH=x64 ;; \
      arm64) PD_ARCH=arm64; GL_ARCH=arm64 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    mkdir -p /out; \
    curl -fsSL "https://github.com/trufflesecurity/trufflehog/releases/download/v${TRUFFLEHOG_VERSION}/trufflehog_${TRUFFLEHOG_VERSION}_linux_${PD_ARCH}.tar.gz" | tar -xz -C /out trufflehog; \
    curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${GL_ARCH}.tar.gz" | tar -xz -C /out gitleaks; \
    curl -fsSL "https://github.com/google/osv-scanner/releases/download/v${OSV_VERSION}/osv-scanner_linux_${PD_ARCH}" -o /out/osv-scanner; \
    curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" | tar -xz -C /out trivy; \
    chmod +x /out/*; \
    ls -l /out

# ------------------------------------------ Python C2 / OSINT entrypoints ---
# Each catalog entry needs an executable on PATH that runs the upstream tool.
# Source checkouts live in the image and their console scripts in one venv.
FROM --platform=$BUILDPLATFORM python:3.12-slim-bookworm AS pyextras
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates git build-essential; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /opt /out
RUN set -eux; \
    gh=https://github.com; \
    git clone --quiet --depth 1 "$gh/lam0779350168/Claude-BugHunter.git" /opt/claude-bughunter; \
    git clone --quiet --depth 1 "$gh/EntySec/Ghost.git" /opt/ghost; \
    git clone --quiet --depth 1 "$gh/t3l3machus/Villain.git" /opt/villain; \
    git clone --quiet --depth 1 "$gh/AlessandroZ/LaZagne.git" /opt/lazagne; \
    git clone --quiet --depth 1 "$gh/0x4m4/hexstrike-ai.git" /opt/hexstrike; \
    git clone --quiet --depth 1 "$gh/malwaredllc/byob.git" /opt/byob; \
    git clone --quiet --depth 1 "$gh/jthuraisamy/SysWhispers2.git" /opt/syswhispers; \
    git clone --quiet --depth 1 "$gh/Manisso/fsociety.git" /opt/fsociety; \
    python -m lib2to3 -w -n /opt/fsociety/fsociety.py >/dev/null; \
    git clone --quiet --depth 1 "$gh/BC-SECURITY/Empire.git" /opt/empire; \
    python -m venv /opt/c2py; \
    python -m venv /opt/empirevenv; \
    /opt/c2py/bin/pip install --no-cache-dir --timeout 120 --retries 5 --ignore-requires-python \
      /opt/claude-bughunter /opt/ghost \
      -r /opt/villain/requirements.txt -r /opt/lazagne/requirements.txt \
      -r /opt/hexstrike/requirements.txt colorama; \
    /opt/empirevenv/bin/pip install --no-cache-dir --timeout 120 --retries 5 --ignore-requires-python /opt/empire; \
    printf '#!/bin/sh\nexec /opt/c2py/bin/cbh "$@"\n' > /out/claude-bughunter; \
    printf '#!/bin/sh\nexec /opt/empirevenv/bin/empire-server "$@"\n' > /out/empire; \
    printf '#!/bin/sh\ncd /opt/hexstrike && exec /opt/c2py/bin/python hexstrike_server.py "$@"\n' > /out/hexstrike; \
    printf '#!/bin/sh\ncd /opt/villain && exec /opt/c2py/bin/python Villain.py "$@"\n' > /out/villain; \
    printf '#!/bin/sh\ncd /opt/lazagne/Linux && exec /opt/c2py/bin/python laZagne.py "$@"\n' > /out/lazagne; \
    printf '#!/bin/sh\ncd /opt/byob/byob && exec /opt/c2py/bin/python client.py "$@"\n' > /out/byob; \
    printf '#!/bin/sh\ncd /opt/syswhispers && exec /opt/c2py/bin/python syswhispers.py "$@"\n' > /out/syswhispers; \
    printf '#!/bin/sh\ncd /opt/fsociety && exec /opt/c2py/bin/python fsociety.py "$@"\n' > /out/fsociety; \
    chmod +x /out/*; \
    ls -l /out
# Heavy scanners conflict in a single pip resolution; one venv per group keeps
# each dependency graph small and the build deterministic.
RUN set -eux; \
    gh=https://github.com; \
    git clone --quiet --depth 1 --branch 4.9.2 "$gh/laramies/theHarvester.git" /opt/theharvester; \
    git clone --quiet --depth 1 --branch v1.4.1 "$gh/usestrix/strix.git" /opt/strix; \
    python -m venv /opt/scanvenv; \
    python -m venv /opt/harvestvenv; \
    python -m venv /opt/strixvenv; \
    python -m venv /opt/prowlervenv; \
    python -m venv /opt/osintvenv; \
    /opt/scanvenv/bin/pip install --no-cache-dir --timeout 120 --retries 5 garak agentic_security pyrit; \
    /opt/harvestvenv/bin/pip install --no-cache-dir --timeout 120 --retries 5 /opt/theharvester; \
    /opt/strixvenv/bin/pip install --no-cache-dir --timeout 120 --retries 5 /opt/strix; \
    /opt/prowlervenv/bin/pip install --no-cache-dir --timeout 120 --retries 5 prowler; \
    /opt/osintvenv/bin/pip install --no-cache-dir --timeout 120 --retries 5 sherlock-project maigret holehe; \
    for t in garak agentic_security pyrit_scan pyrit_shell pyrit_backend; do \
      if [ -x "/opt/scanvenv/bin/$t" ]; then ln -sf "/opt/scanvenv/bin/$t" "/out/$t"; fi; \
    done; \
    for t in theHarvester; do ln -sf "/opt/harvestvenv/bin/$t" "/out/$t"; done; \
    for t in strix; do ln -sf "/opt/strixvenv/bin/$t" "/out/$t"; done; \
    for t in prowler; do ln -sf "/opt/prowlervenv/bin/$t" "/out/$t"; done; \
    for t in sherlock maigret holehe; do ln -sf "/opt/osintvenv/bin/$t" "/out/$t"; done; \
    printf '#!/bin/sh\nexec /opt/scanvenv/bin/pyrit_scan "$@"\n' > /out/pyrit; \
    chmod +x /out/*; \
    ls -l /out

# ------------------------- C2 frameworks and payload tooling (amd64 only) ---
# Go CLIs, .NET server, release binaries and Windows EXEs. Windows targets run
# through the wine64 loader installed in the runtime stage.
FROM --platform=$BUILDPLATFORM golang:1.26-bookworm AS c2extras
ARG TARGETARCH
ENV GOTOOLCHAIN=auto
RUN set -eux; \
    [ "${TARGETARCH:-amd64}" = "amd64" ] || { echo "C2 toolbox is amd64-only" >&2; exit 1; }; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip build-essential clang mingw-w64 \
      gcc-mingw-w64-x86-64 gnupg; \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg; \
    echo 'deb [arch=amd64] https://packages.microsoft.com/debian/12/prod bookworm main' > /etc/apt/sources.list.d/microsoft.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends dotnet-sdk-8.0; \
    rm -rf /var/lib/apt/lists/*
RUN set -eux; \
    mkdir -p /out /opt/winbin; \
    gh=https://github.com; \
    git clone --quiet --depth 1 "$gh/HavocFramework/Havoc.git" /opt/havoc; \
    (cd /opt/havoc/teamserver && GO111MODULE=on go build -o /out/havoc main.go); \
    git clone --quiet --depth 1 "$gh/Ne0nd0g/merlin.git" /opt/merlin; \
    (cd /opt/merlin && go build -o /out/merlin .); \
    git clone --quiet --depth 1 "$gh/adaptix-framework/AdaptixC2.git" /opt/adaptix; \
    (cd /opt/adaptix/AdaptixServer && go build -o /out/adaptix .); \
    git clone --quiet --depth 1 "$gh/its-a-feature/Mythic.git" /opt/mythic; \
    (cd /opt/mythic/Mythic_CLI/src && go build -o /out/mythic .); \
    git clone --quiet --depth 1 "$gh/cobbr/Covenant.git" /opt/covenant; \
    (cd /opt/covenant && DOTNET_CLI_TELEMETRY_OPTOUT=1 dotnet publish Covenant/Covenant.csproj -c Release -o /opt/covenant/publish)
RUN set -eux; \
    gh=https://github.com; \
    curl -fsSL "$gh/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip" -o /tmp/mimi.zip; \
    unzip -q -o /tmp/mimi.zip 'x64/mimikatz.exe' -d /opt/winbin; \
    cp /opt/winbin/x64/mimikatz.exe /opt/winbin/mimikatz.exe; \
    curl -fsSL --retry 3 --retry-delay 2 "https://raw.githubusercontent.com/r3motecontrol/GhostPack-CompiledBinaries/master/Rubeus.exe" -o /opt/winbin/rubeus.exe; \
    git clone --quiet --depth 1 "$gh/fortra/nanodump.git" /opt/nanodump; \
    (cd /opt/nanodump && (make -f Makefile.clang nanodump CC="clang -L/usr/lib/gcc/x86_64-w64-mingw32/12-win32" || true) && cp dist/nanodump.x64.exe /opt/winbin/nanodump.exe); \
    curl -fsSL "$gh/frohoff/ysoserial/releases/download/v0.0.6/ysoserial-all.jar" -o /opt/ysoserial.jar; \
    git clone --quiet --depth 1 "$gh/ambionics/phpggc.git" /opt/phpggc; \
    curl -fsSL "$gh/TheWover/donut/releases/download/v1.1/donut_v1.1.tar.gz" -o /tmp/donut.tgz; \
    tar -xzf /tmp/donut.tgz -C /tmp ./donut; \
    install -m 0755 /tmp/donut /out/donut; \
    curl -fsSL "$gh/optiv/scarecrow/releases/download/v5.1/ScareCrow_5.1_linux_amd64" -o /out/scarecrow; \
    curl -fsSL "$gh/fatedier/frp/releases/download/v0.72.0/frp_0.72.0_linux_amd64.tar.gz" -o /tmp/frp.tgz; \
    tar -xzf /tmp/frp.tgz -C /opt; \
    curl -fsSL "$gh/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip" -o /tmp/gophish.zip; \
    unzip -q /tmp/gophish.zip gophish -d /opt/gophish; \
    chmod +x /opt/gophish/gophish; \
    printf 'v0.12.1\n' > /opt/gophish/VERSION; \
    curl -fsSL "$gh/kgretzky/evilginx2/releases/download/v3.3.0/evilginx-v3.3.0-linux-64bit.zip" -o /tmp/evilginx.zip; \
    unzip -q /tmp/evilginx.zip evilginx -d /opt/evilginx2; \
    chmod +x /opt/evilginx2/evilginx; \
    git clone --quiet --depth 1 "$gh/danielbohannon/Invoke-Obfuscation.git" /opt/invoke-obfuscation; \
    git clone --quiet --depth 1 "$gh/fin3ss3g0d/evilgophish.git" /opt/evilgophish; \
    curl -fsSL "$gh/github/codeql-cli-binaries/releases/download/v2.27.6/codeql-linux64.zip" -o /tmp/codeql.zip; \
    unzip -q /tmp/codeql.zip -d /opt/codeql; \
    printf '#!/bin/sh\nexec env WINEDEBUG=-all /usr/lib/wine/wine64 /opt/winbin/mimikatz.exe "$@"\n' > /out/mimikatz; \
    printf '#!/bin/sh\nexec env WINEDEBUG=-all /usr/lib/wine/wine64 /opt/winbin/rubeus.exe "$@"\n' > /out/rubeus; \
    printf '#!/bin/sh\nexec env WINEDEBUG=-all /usr/lib/wine/wine64 /opt/winbin/nanodump.exe "$@"\n' > /out/nanodump; \
    printf '#!/bin/sh\nexec java -jar /opt/ysoserial.jar "$@"\n' > /out/ysoserial; \
    printf '#!/bin/sh\nexec php /opt/phpggc/phpggc "$@"\n' > /out/phpggc; \
    printf '#!/bin/sh\nexec /opt/codeql/codeql/codeql "$@"\n' > /out/codeql; \
    printf '#!/bin/sh\nexec env DOTNET_ROLL_FORWARD=Major dotnet /opt/covenant/publish/Covenant.dll "$@"\n' > /out/covenant; \
    printf '#!/bin/sh\nexec pwsh -NoProfile -File /opt/invoke-obfuscation/Invoke-Obfuscation.ps1 "$@"\n' > /out/invoke-obfuscation; \
    printf '#!/bin/sh\ncd /opt/gophish && exec ./gophish "$@"\n' > /out/gophish; \
    printf '#!/bin/sh\nexec /opt/evilginx2/evilginx "$@"\n' > /out/evilginx2; \
    printf '#!/bin/sh\nexec bash /opt/evilgophish/setup.sh "$@"\n' > /out/evilgophish; \
    printf '#!/bin/sh\nexec /opt/frp_0.72.0_linux_amd64/frpc "$@"\n' > /out/frp; \
    chmod +x /out/*; \
    ls -l /out

# ---------------------------------------------------------------- runtime ---
FROM python:3.12-slim-bookworm
ARG TARGETARCH
# Common tools: ripgrep / curl / vim, plus a set of recon staples (add/remove as needed).
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates ripgrep curl wget vim git jq unzip xz-utils gnupg \
      wine64 default-jre-headless php-cli \
      dnsutils iputils-ping netcat-openbsd inetutils-telnet whois nmap \
    && rm -rf /var/lib/apt/lists/*
# Windows EXEs run through wine64; PowerShell and .NET back the C2 CLIs.
RUN set -eux; \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg; \
    echo 'deb [arch=amd64] https://packages.microsoft.com/debian/12/prod bookworm main' > /etc/apt/sources.list.d/microsoft.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends powershell dotnet-sdk-8.0; \
    rm -rf /var/lib/apt/lists/*
# Node 22 from the official nodejs.org tarball: bookworm's apt nodejs is 18,
# Playwright requires >=20, and 20 is end-of-life. 22 matches the CI and release
# workflows. Verified against a digest pinned here rather than against the fetched
# SHASUMS256.txt, for the reason given at the tools stage.
ARG NODE_VERSION=22.23.4
ARG NODE_SHA256_AMD64=1805bcd35e6815559bd2eb97db438d3fdb0eb3a5e6a977b7c1badca76337e9ce
ARG NODE_SHA256_ARM64=6287aa46b6c375d816e63ae66d024fbbfd70404825aabdfdf898a970871d2f4b
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) NODE_ARCH=x64; want="$NODE_SHA256_AMD64" ;; \
      arm64) NODE_ARCH=arm64; want="$NODE_SHA256_ARM64" ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base="https://nodejs.org/dist/v${NODE_VERSION}"; \
    asset="node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"; \
    curl -fsSL "$base/$asset" -o "/tmp/$asset"; \
    [ -n "$want" ] || { echo "no pinned digest for $asset" >&2; exit 1; }; \
    got="$(sha256sum "/tmp/$asset" | cut -d' ' -f1)"; \
    if [ "$want" != "$got" ]; then echo "checksum mismatch for $asset: want $want got $got" >&2; exit 1; fi; \
    tar -xJf "/tmp/$asset" -C /usr/local --strip-components=1 --no-same-owner; \
    rm -f "/tmp/$asset"; \
    node --version; npm --version
# Pinned, checksum-verified recon binaries and the sqlmap checkout from the tools stage.
COPY --from=tools /out/ /usr/local/bin/
COPY --from=tools /opt/sqlmap /opt/sqlmap
RUN set -eux; \
    ln -s /opt/sqlmap/sqlmap.py /usr/local/bin/sqlmap; \
    nuclei -version >/dev/null; httpx -version; subfinder -version; katana -version; \
    ffuf -V >/dev/null; dalfox --version >/dev/null; sqlmap --version >/dev/null

# bbot recursive recon orchestrator (#117): blacklanternsecurity/bbot, AGPL-3.0
# (same license as ARTEX; standalone CLI dependency, not linked code). Pinned
# version, own venv to isolate from the image python. Module dependencies are
# preinstalled (--install-all-deps) so scans never need pip at runtime, which
# would fail under a program's egress allowlist.
ARG BBOT_VERSION=3.0.2
# arm64: bbot's Chrome and retirejs's Node are x86-64; use native builds.
RUN set -eux; \
    python -m venv /opt/bbot; \
    /opt/bbot/bin/pip install --no-cache-dir --timeout 120 --retries 5 "bbot==${BBOT_VERSION}"; \
    ln -s /opt/bbot/bin/bbot /usr/local/bin/bbot; \
    if [ "${TARGETARCH:-amd64}" = "arm64" ]; then \
      apt-get update; \
      apt-get install -y --no-install-recommends chromium; \
      rm -rf /var/lib/apt/lists/*; \
      bbot_dir="$(/opt/bbot/bin/python -c 'import bbot, os; print(os.path.dirname(bbot.__file__))')"; \
      sed -i 's/linux-x64/linux-arm64/g' "$bbot_dir/modules/retirejs.py"; \
    fi; \
    bbot -y --install-all-deps; \
    if [ "${TARGETARCH:-amd64}" = "arm64" ]; then \
      printf '\nmodules:\n  gowitness:\n    chrome_path: /usr/bin/chromium\n' >> /root/.config/bbot/bbot.yml; \
    fi; \
    bbot --version >/dev/null; \
    bbot --dry-run -t example.com -m wafw00f,paramminer_getparams,lightfuzz,sslcert,gowitness,retirejs >/dev/null 2>&1 || true; \
    bbot --dry-run -t example.com -m wafw00f,paramminer_getparams,lightfuzz,sslcert,gowitness,retirejs --no-color >/tmp/bbot-dry.log 2>&1 || true; \
    ! grep -qE "Installing|ERRR|CRITICAL" /tmp/bbot-dry.log || { cat /tmp/bbot-dry.log; exit 1; }


# Preinstall Playwright MCP and CLI (globally) so no network download is needed at runtime.
# @playwright/mcp: the seeded browser MCP runs the playwright-mcp binary directly.
# `npx @playwright/mcp` is not used: it queries the npm registry on every start even
# with the package installed globally.
# @playwright/cli: provides playwright-cli, verified with --help right after install.
# Then install playwright (browser management) and preinstall chromium plus its system
# dependencies via --with-deps. @playwright/mcp and @playwright/cli bundle their own
# playwright-core, which expects a different Chromium build than
# playwright@PLAYWRIGHT_VERSION installs, so that build is installed as well (second
# install line); without it neither can launch a browser. All three packages are
# pinned; upgrade deliberately.
ARG PLAYWRIGHT_MCP_VERSION=0.0.83
ARG PLAYWRIGHT_CLI_VERSION=0.1.22
ARG PLAYWRIGHT_VERSION=1.64.1
# playwright-core's exports map hides cli.js from require.resolve, so run the
# binary npm links for @playwright/mcp instead: it is the copy MCP actually
# loads, and it installs the Chromium revision that copy expects.
RUN npm install -g "@playwright/mcp@${PLAYWRIGHT_MCP_VERSION}" "@playwright/cli@${PLAYWRIGHT_CLI_VERSION}" "playwright@${PLAYWRIGHT_VERSION}" \
    && playwright-cli --help \
    && playwright install --with-deps chromium \
    && "$(npm root -g)/@playwright/mcp/node_modules/.bin/playwright-core" install chromium \
    && rm -rf /var/lib/apt/lists/*
# Agent processes run as the executor with HOME and XDG_CACHE_HOME in the data
# directory (server/execpriv_unix.go); the browsers installed above stay in root's
# cache, which /root's 0711 lets the executor reach.
ENV PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright

# Exploit/payload toolbox: Metasploit, ExploitDB, SecLists, wordlists and the
# Python/Perl exploit tools. The Go binaries come from the gobins stage and the
# release binaries/clones from the exploit stage.
RUN apt-get update && apt-get install -y --no-install-recommends \
      gnupg perl libnet-ssleay-perl libxml-writer-perl samba-common-bin \
      whatweb hydra john hashcat smbclient ldap-utils proxychains4 sshuttle gobuster \
      ruby ruby-dev build-essential libcurl4-openssl-dev libxml2-dev libxslt1-dev zlib1g-dev \
      gcc g++ make libssl-dev libffi-dev libkrb5-dev libldap2-dev libsasl2-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=gobins /out/ /usr/local/bin/
COPY --from=scanbins /out/ /usr/local/bin/
COPY --from=toolserver /out/toolserver /usr/local/bin/toolserver
COPY --from=exploit /out/ /usr/local/bin/
COPY --from=exploit /opt/payloadsallthethings /opt/payloadsallthethings
COPY --from=exploit /opt/seclists /opt/seclists
COPY --from=exploit /opt/exploitdb /opt/exploitdb
COPY --from=exploit /opt/nikto /opt/nikto
COPY --from=exploit /opt/commix /opt/commix
COPY --from=exploit /opt/xsstrike /opt/xsstrike
COPY --from=exploit /opt/jwt_tool /opt/jwt_tool
COPY --from=exploit /opt/smuggler /opt/smuggler
COPY --from=exploit /opt/nosqlmap /opt/nosqlmap
COPY --from=exploit /opt/responder /opt/responder
COPY --from=exploit /opt/enum4linux /opt/enum4linux
COPY --from=exploit /opt/enum4linux-ng /opt/enum4linux-ng
COPY --from=exploit /opt/windapsearch /opt/windapsearch
COPY --from=exploit /opt/corsy /opt/corsy
COPY --from=exploit /opt/graphql-cop /opt/graphql-cop
RUN set -eux; \
    python -m venv /opt/exploit; \
    /opt/exploit/bin/pip install --no-cache-dir --timeout 120 --retries 5 --upgrade pip; \
    /opt/exploit/bin/pip install --no-cache-dir --timeout 120 --retries 5 \
      impacket certipy-ad bloodhound donpapi ldeep ldapdomaindump mitm6 adidnsdump \
      arjun dirsearch dnstwist ssh-audit simplejson termcolor PySocks \
      pymongo couchdb httplib2 ipcalc pbkdf2 requests semgrep; \
    /opt/exploit/bin/pip install --no-cache-dir --timeout 120 --retries 5 "git+https://github.com/Pennyw0rth/NetExec"; \
    /opt/exploit/bin/pip install --no-cache-dir --timeout 120 --retries 5 -r /opt/responder/requirements.txt; \
    /opt/exploit/bin/pip install --no-cache-dir --timeout 120 --retries 5 -r /opt/xsstrike/requirements.txt; \
    /opt/exploit/bin/pip install --no-cache-dir --timeout 120 --retries 5 -r /opt/jwt_tool/requirements.txt; \
    /opt/exploit/bin/pip install --no-cache-dir --timeout 120 --retries 5 -r /opt/windapsearch/requirements.txt; \
    /opt/exploit/bin/pip install --no-cache-dir --timeout 120 --retries 5 -r /opt/enum4linux-ng/requirements.txt; \
    for t in atexec.py GetNPUsers.py GetUserSPNs.py getST.py psexec.py secretsdump.py ticketer.py wmiexec.py \
             adidnsdump arjun bloodhound-python certipy dirsearch dnstwist donpapi ldapdomaindump ldeep mitm6 nxc ssh-audit; do \
      ln -sf "/opt/exploit/bin/$t" "/usr/local/bin/$t"; \
    done; \
    ln -sf /opt/exploit/bin/GetUserSPNs.py /usr/local/bin/GetSPN.py; \
    ln -sf /opt/exploit/bin/getST.py /usr/local/bin/GetST.py; \
    ln -sf /opt/bbot/bin/wafw00f /usr/local/bin/wafw00f; \
    ln -sf /usr/local/bin/nxc /usr/local/bin/crackmapexec; \
    python -m venv /opt/donpapivenv; \
    /opt/donpapivenv/bin/pip install --no-cache-dir --timeout 120 --retries 5 donpapi==2.0.1; \
    rm -f /usr/local/bin/donpapi; \
    printf '#!/bin/sh\nexec /opt/donpapivenv/bin/donpapi "$@"\n' > /usr/local/bin/donpapi; \
    chmod +x /usr/local/bin/donpapi; \
    for spec in \
      "commix:/opt/commix/commix.py" \
      "xsstrike:/opt/xsstrike/xsstrike.py" \
      "jwt_tool.py:/opt/jwt_tool/jwt_tool.py" \
      "smuggler.py:/opt/smuggler/smuggler.py" \
      "nosqlmap:/opt/nosqlmap/nosqlmap.py" \
      "responder:/opt/responder/Responder.py" \
      "windapsearch.py:/opt/windapsearch/windapsearch.py" \
      "corsy:/opt/corsy/corsy.py" \
      "graphql-cop:/opt/graphql-cop/graphql-cop.py" \
      "enum4linux-ng.py:/opt/enum4linux-ng/enum4linux-ng.py"; do \
      name="${spec%%:*}"; path="${spec#*:}"; dir="$(dirname "$path")"; file="$(basename "$path")"; \
      printf '#!/bin/sh\ncd %s && exec /opt/exploit/bin/python %s "$@"\n' "$dir" "$file" > "/usr/local/bin/$name"; \
      chmod +x "/usr/local/bin/$name"; \
    done; \
    ln -sf /opt/enum4linux/enum4linux.pl /usr/local/bin/enum4linux; \
    printf '#!/bin/sh\ncd /opt/nikto/program && exec ./nikto.pl "$@"\n' > /usr/local/bin/nikto; \
    printf '#!/bin/sh\ncd /opt/exploitdb && exec ./searchsploit "$@"\n' > /usr/local/bin/searchsploit; \
    chmod +x /usr/local/bin/nikto /usr/local/bin/searchsploit
# Additional CLI entry points from the pip extras above (only when the package
# actually ships them) plus npm-based OSINT/LLM tools and the Lynis auditor.
RUN set -eux; \
    for t in semgrep; do \
      if [ -x "/opt/exploit/bin/$t" ]; then ln -sf "/opt/exploit/bin/$t" "/usr/local/bin/$t"; fi; \
    done; \
    2to3 -w -n /opt/nosqlmap/*.py; \
    npm install -g firecrawl-cli promptfoo @keygraph/shannon; \
    mv /usr/local/bin/shannon /usr/local/bin/shannon-real; \
    printf '#!/bin/sh\nexport HOME=/tmp\nexec setpriv --reuid=10001 --regid=10001 --clear-groups /usr/local/bin/shannon-real "$@"\n' > /usr/local/bin/shannon; \
    chmod +x /usr/local/bin/shannon; \
    git clone --quiet --depth 1 https://github.com/CISOfy/lynis /opt/lynis; \
    printf '#!/bin/sh\ncd /opt/lynis && exec ./lynis "$@"\n' > /usr/local/bin/lynis; \
    chmod +x /usr/local/bin/lynis
RUN gem install wpscan --no-document && wpscan --version
RUN set -eux; \
    curl -fsSL https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -o /tmp/msfinstall; \
    sh /tmp/msfinstall; \
    rm -f /tmp/msfinstall; \
    msfconsole --version; \
    msfvenom --version || true
ARG SLIVER_VERSION=v1.7.9
ARG SLIVER_CLIENT_SHA256=9f66bd5d55ec190905688184b029032a0e8c454ff83b76c91884f65384207672
RUN set -eux; \
    curl -fsSL "https://github.com/BishopFox/sliver/releases/download/${SLIVER_VERSION}/sliver-client_linux-amd64" -o /usr/local/bin/sliver-client; \
    printf '%s  %s\n' "$SLIVER_CLIENT_SHA256" /usr/local/bin/sliver-client | sha256sum -c -; \
    chmod +x /usr/local/bin/sliver-client; \
    sliver-client version
COPY scripts/artex-run scripts/payload-search scripts/sliver-cmd scripts/msf-run /usr/local/bin/
RUN chmod +x /usr/local/bin/artex-run /usr/local/bin/payload-search /usr/local/bin/sliver-cmd /usr/local/bin/msf-run
# Remaining catalog entries: Python entrypoints, Go/.NET CLIs and release binaries.
COPY --from=pyextras /opt/ /opt/
COPY --from=pyextras /out/ /usr/local/bin/
COPY --from=c2extras /opt/ /opt/
COPY --from=c2extras /out/ /usr/local/bin/
RUN ln -sf /opt/c2py/bin/ghost /usr/local/bin/ghost

WORKDIR /app
COPY tools/catalog.json /app/tools/catalog.json
# Binary compiled from source in the build stage above.
COPY --from=build /out/artex /app/artex
# Daemon startup script: relaunches the process after a crash and forwards SIGTERM
# to artex — docker stop only signals PID 1; without forwarding, artex never receives it,
# cannot shut down gracefully, and is hard-killed by SIGKILL after 10 seconds.
COPY start.sh /app/start.sh
RUN chmod +x /app/artex /app/start.sh && mkdir -p -m 0700 /app/keys \
    && chmod 0711 /root \
    # Sliver's client calls os/user.Current(); uid 10001 needs a passwd entry.
    && echo 'artex:x:10001:10001::/tmp:/bin/sh' >> /etc/passwd
# No setuid or setgid programs (su, passwd, mount, bbot's chrome_sandbox, ...): an
# agent process runs as the executor and must not regain root through one, even
# when the container runs without docker-compose.yml's no-new-privileges.
RUN find / -xdev -perm /6000 -type f -exec chmod a-s {} +
COPY skills/ /app/skills/
# persistence points: data/ (traffic index, task files, transcripts) and keys/ (jwt.key, secret.key, via ARTEX_JWT_KEY_DIR)
VOLUME ["/app/data", "/app/keys"]
EXPOSE 8787 8788
ENTRYPOINT ["/app/start.sh"]
CMD ["-addr", ":8787", "-proxy", ":8788"]
