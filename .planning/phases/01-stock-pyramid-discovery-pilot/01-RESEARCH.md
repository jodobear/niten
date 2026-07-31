# Phase 1: Stock Pyramid Discovery Pilot - Research

**Researched:** 2026-07-31
**Domain:** Source-unmodified Pyramid deployment, Nostr access-control discovery, and evidence-gated operations
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Relay Visibility and Identity
- **D-01:** Expose a public HTTPS/WSS origin at `niten.sovereignengineering.io`.
- **D-02:** Anonymous users may read explicitly public content. Publishing is restricted to allowlisted alumni, and restricted groups require authorization.
- **D-03:** Pyramid and operator administration remain privately restricted even though the relay origin is public.
- **D-04:** Quietly list the relay in common relay directories without broader promotion.
- **D-05:** Public relay metadata identifies it as “Niten by Sovereign Engineering,” clearly labels it experimental, and includes concise operator contact, publishing rules, and operator-readable/non-E2EE privacy language.

### Alumni Roster and Joining
- **D-06:** Use the user-supplied Nostr alumni roster event as the source for a one-time pilot-start allowlist snapshot. The event identifier and extracted pubkeys are private operational inputs and must not be committed to Git or GitHub.
- **D-07:** Send one shared Niten link to the full snapshotted roster. Participation is voluntary; measure actual uptake rather than imposing a participant target or staged waves.
- **D-08:** Later roster changes require an operator-reviewed manual refresh. Do not periodically or continuously synchronize the source event during Phase 1.
- **D-09:** An allowlisted alumnus authenticates with the existing key and onboards immediately. No individual invitation or operator approval queue is intended.

### Client, Signer, and Identity Coverage
- **D-10:** Nostrord and Flotilla are required for NIP-29 group coverage. Jumble is required only for public-feed and publishing flows it actually supports. Other clients provide opportunistic evidence.
- **D-11:** Phase 1 requires one proven path for each signer family: nos2x Chromium, nos2x Firefox, Amber/NIP-55, one iOS NIP-46 signer, and one member-chosen bunker flow. The full target-client × signer cross-product belongs to Phase 3.
- **D-12:** Alumni use real existing identities for normal workflows. Operators use disposable identities for denial, removal, ban, role-change, and destructive tests.
- **D-13:** Discovery continues despite client, signer, privacy, or authorization failures. Record the failure and isolate the affected client/group/action where possible; stop the entire pilot only when the host itself is unsafe.

### Stock Link and Quickstart
- **D-14:** The shared URL opens the stock Niten/Pyramid instance. Phase 1 does not build a custom portal or client chooser.
- **D-15:** The accompanying invitation is a concise quickstart covering experimental status, URL, allowlist eligibility, job-based client/signer guidance, privacy warning, and reporting paths.
- **D-16:** Recommend Flotilla for general community use, Nostrord for focused NIP-29/group testing, and Jumble only for supported public-feed flows.
- **D-17:** Alumni may self-troubleshoot and switch to a documented alternate path. Reports should identify client/version, signer, attempted flow, and error. Never ask anyone to paste, transmit, or expose an `nsec`.

### Content, Privacy, and Transition
- **D-18:** Pilot content is real but provisional. Encourage normal public conversation and preserve it when feasible, while warning that Pyramid-local groups, metadata, and test content may be reset during redeployment.
- **D-19:** Ordinary confidential conversation is allowed in access-controlled groups only after a clear warning that NIP-29 access control is operator-readable, not end-to-end encrypted, and under active compatibility testing.
- **D-20:** If Pyramid is revised, replaced, or redeployed, provide advance notice and make a best-effort migration/export of standard signed events and membership/group configuration before retiring old state.
- **D-21:** Phase 1 has no calendar-duration or participant-count minimum. The decision gate opens when every required stock flow and signer-family path has an observed pass/fail result.

### Failure Disclosure
- **D-22:** After rapid confirmation of a privacy or authorization failure, notify directly affected alumni. Post a cohort bulletin when impact may be systemic; do not wait for full root-cause analysis or a fix.
- **D-23:** Isolate only the affected client, group, or action where possible while unrelated discovery continues.
- **D-24:** Every failure notice is concise and redacted: time, affected scope, possible impact, containment, user action, and next update. Never include private event bodies or signer material.

### Feedback, Operations, and Repository
- **D-25:** Collect feedback through a dedicated Niten pilot group, a private operator channel for sensitive reports, and GitHub issues for non-sensitive actionable defects.
- **D-26:** Use a concise report template: client/version, signer, action, expected result, actual result, and timestamp. Mirror these fields in GitHub issue templates.
- **D-27:** Feedback is shared by default. Privacy and security reports remain private until safely redacted. GitHub never receives private events, alumni roster data, signer material, bunker details, credentials, or live secrets.
- **D-28:** Post concise restart, failure, and configuration-change notices to both a Niten announcement group and the existing out-of-band alumni channel.
- **D-29:** Continuous pilot changes are allowed, with concise notice before and after disruptive work.
- **D-30:** Use `https://github.com/jodobear/niten` as the single canonical repository for deployment code, configuration templates, runbooks, redacted evidence, issues, and pull requests. — **Reversibility:** costly — changing the repository later requires remote migration and updating issue, PR, automation, and documentation links.

### the agent's Discretion
- Select the exact current upstream Pyramid pin after re-auditing it against the researched baseline.
- Choose the minimum source-unmodified build/package method, systemd hardening, Caddy routing, private operator-access mechanism, backup implementation, rollback layout, and redacted evidence format that satisfy PILOT-01 through PILOT-08.
- Define the detailed order of stock-flow tests and compatible pairing used to prove each required signer family.
- Choose concise wording and formatting for quickstart, relay metadata, issue templates, incident notices, and operational notices while preserving the decisions above.

### Deferred Ideas (OUT OF SCOPE)
- Full target-client × signer cross-product — Phase 3; captured as a major todo.
- Standalone Blossom, hosted community UI, public-event aggregation, curation, companion APIs, and Pyramid source patches — blocked until the Phase 1 decision gate.
- Napplet/Kehto and hosted headless community applets — outside this project; require a separate future project if pursued.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PILOT-01 | Operators can reproduce and deploy an exact pinned upstream Pyramid release/commit without modifying its source, recording the upstream repository, tag, commit, checksum, build/runtime versions, and effective configuration. | Exact v1.3.2 tag, commit, release checksum, source-build inputs, immutable artifact layout, and journal fields are specified below. |
| PILOT-02 | The discovery host runs only the minimum live-testing envelope: Caddy/TLS, a loopback-bound Pyramid process under systemd, least-privilege state paths, bounded journald logs, a recoverable backup, and a documented rollback to the previous known-good artifact/state. | The systemd, Caddy, state, backup, restore, and rollback contracts below define the host envelope. |
| PILOT-03 | Stock Pyramid browser administration is not exposed as a general public surface; operator access is restricted to an approved private path while existing clients exercise ordinary group/member workflows. | Public/private Caddy routing, private bootstrap order, route-denial tests, and browser-session risks are documented. |
| PILOT-04 | A small named cohort of testing alumni can connect to the pilot through existing Nostr clients and member-controlled NIP-07, NIP-46, or NIP-55 signers without giving keys to project infrastructure. | Roster ingestion is out-of-band and signer coverage uses NIP-07/46/55 without VPS key custody. |
| PILOT-05 | The cohort exercises stock Pyramid membership, invitations, public/restricted/private group behavior, roles, NIP-42 authentication, NIP-50 search, notes/replies/reactions, deletion, reconnect, and rejection/error paths that supported clients expose. | A sequenced stock-flow matrix defines every required behavior and negative control. |
| PILOT-06 | Operators retain exact client/signer/Pyramid pass-fail evidence, destination captures for access-controlled content, operational observations, participant workflow feedback, and a categorized list of native capability, configuration need, defect, client gap, and genuinely missing product requirement. | Evidence schema, redaction split, destination traps, and classification vocabulary are specified. |
| PILOT-07 | Standalone Blossom, hosted community clients, public-event aggregation, custom curation, companion APIs, Pyramid source patches, and other product services are not discovery-pilot dependencies; each requires evidence and a new planning decision after the pilot. | Minimum module configuration and explicit non-goals keep these absent. |
| PILOT-08 | The discovery review selects the next milestone from retained evidence and can discard/redeploy the pilot without making member identity, keys, or external Nostr content dependent on the experimental host. | The hard decision gate, key-custody boundary, exports, restore proof, and disposal contract preserve exit. |
| DOC-01 | Operators maintain a private build journal from day one containing decisions, failures, fixes, diagrams, costs, compatibility evidence, restore evidence, and upstream improvement notes. | A private journal/evidence layout and minimum journal record are defined. |
</phase_requirements>

## Summary

Pin and deploy the official Pyramid **v1.3.2** release from `fiatjaf/pyramid`, tag commit `e12e81641bfe6cacc6dd246e9433d602c1240e66`. The live official amd64 asset was downloaded and verified as 193,079,560 bytes with SHA-256 `93180050e101fa870ca022279eac3c18ea0bf263aee9d8dc67f24292b9c41920`. Upstream `master` was one commit ahead during research; the delta permits deletion of relay-signed events and is not part of v1.3.2. Deploy the checked release asset, independently reproduce the tagged source build for provenance, and do not silently substitute `master`. [VERIFIED: GitHub release API, downloaded asset, and official Pyramid repository at v1.3.2]

The source-unmodified safety envelope must compensate for material stock behavior. Pyramid writes a relay secret into `settings.json` using mode `0644`, writes `management.jsonl` with mode `0644`, defaults several auxiliary relays on, defaults anonymous ephemeral writes on, and exposes a long-lived JavaScript-readable browser login cookie. Stock pages also load scripts and fonts from third-party CDNs. Therefore Pyramid must bind loopback, start with `UMask=0077`, live under a private state directory, disable unnecessary modules and automatic updates, and expose privileged browser routes only on a mesh-only admin origin. Operators must use a dedicated browser profile and dedicated pilot operator identity; the public stock page is view-only guidance, not a place to authorize a privileged signer. [VERIFIED: official Pyramid v1.3.2 source `global/settings.go`, `pyramid/members.go`, `global/utils.go`, and `layout/layout.templ`]

The largest privacy planning fact is that keeping the roster input private does **not** make resulting membership private. Stock Pyramid renders the member tree on its home page and publishes relay/group membership state containing member pubkeys. NIP-29 private groups are relay-enforced access control, not E2EE. D-06 is implementable as “input event and extracted snapshot never enter Git/GitHub”; it cannot be interpreted as “membership pubkeys are undiscoverable by relay users” without a source change, which Phase 1 forbids. The quickstart and consent text must say this before onboarding. [VERIFIED: official Pyramid v1.3.2 invite-tree and membership source; CITED: https://github.com/nostr-protocol/nips/blob/master/29.md]

**Primary recommendation:** deploy the exact v1.3.2 asset behind the two-origin Caddy/systemd envelope, complete the redacted pass/fail matrix and a blank-host restore, then issue exactly one `PROCEED`, `REVISE`, `REPLACE`, or `STOP` verdict. [VERIFIED: phase requirements and live upstream audit]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Public HTTPS/WSS and TLS | CDN / Static ingress (Caddy) | API / Backend | Caddy is the only public listener; Pyramid remains loopback-only. [CITED: https://caddyserver.com/docs/caddyfile/directives/reverse_proxy] |
| Relay protocol, membership, groups, search | API / Backend (Pyramid) | Database / Storage (`mmm`, Bleve) | Stock Pyramid is the single authority and store for the pilot. [VERIFIED: official Pyramid v1.3.2 source] |
| Browser/operator administration | Private ingress plus Pyramid | Operator workstation | The same backend serves admin pages, so reachability is separated at Caddy/firewall rather than inside patched source. [VERIFIED: official Pyramid v1.3.2 route table] |
| Signing and member identity | Browser/mobile/remote signer | Existing client | No member or operator content key belongs on the VPS. [CITED: https://github.com/nostr-protocol/nips/blob/master/46.md] |
| Roster snapshot | Operator workstation/private state | Pyramid NIP-86 membership log | Raw input stays out-of-band; only explicit allow operations enter Pyramid. [VERIFIED: official Pyramid v1.3.2 NIP-86 handlers] |
| Backup and rollback | Operator/host operations | Off-host encrypted repository | Pyramid state and matching artifact/config must restore as one known-good generation. [CITED: https://restic.readthedocs.io/en/stable/040_backup.html] |
| Evidence and decision | Private build journal | Redacted canonical repository | Raw identities/events stay private; only redacted case results enter GitHub. [VERIFIED: CONTEXT D-24 through D-30] |

## Standard Stack

### Core

| Component | Exact pin | Purpose | Why Standard for This Phase |
|-----------|-----------|---------|-----------------------------|
| Pyramid | v1.3.2 / `e12e81641bfe6cacc6dd246e9433d602c1240e66` | Stock relay/community authority | Current official release at research time; exact amd64 asset checksum verified. [VERIFIED: official GitHub release API and asset] |
| Caddy | v2.11.4 | TLS and public/private reverse-proxy boundary | Current official release; native WebSocket tunneling and automatic HTTPS. [VERIFIED: official Caddy GitHub release API; CITED: https://caddyserver.com/docs/caddyfile/directives/reverse_proxy] |
| systemd | Debian 13 packaged version, record exact host version | Service lifecycle, hardening, log namespace/timers | Native host supervisor; pinning is the OS image/package snapshot rather than a project vendored binary. [CITED: https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html] |
| restic | v0.19.1 | Encrypted off-host snapshot, check, and restore | Current official release and documented restore workflow. [VERIFIED: official restic GitHub release API; CITED: https://restic.readthedocs.io/en/stable/050_restore.html] |

### Supporting

| Component | Exact pin | Purpose | When to Use |
|-----------|-----------|---------|-------------|
| `nak` | v0.20.2 | NIP-86 membership reconciliation and protocol probes | Operator workstation only; never put a bunker URI or secret on a command line or in captured output. [VERIFIED: official `fiatjaf/nak` GitHub release API] |
| Nostrord | v2.4.0, record served build | NIP-29 reference path | Group baseline with nos2x Chromium and Firefox. The day-after-release head fixed same-group-ID/cross-relay state confusion, so the pilot must avoid reused group IDs and record the exact served build. [VERIFIED: official `n-ostr/n-ostr` repository release and commit history] |
| Flotilla | v1.9.0, record served build | General community and Android/NIP-55 group path | Required group coverage; verify Pyramid's advertised-NIP workaround and destination routing. [VERIFIED: official Flotilla Gitea tags and Pyramid v1.3.2 NIP-11 source] |
| Jumble | v26.7.2, record served build | Supported public feed/publish/search | Do not use it as a NIP-29 administration client. [VERIFIED: official `CodyTseng/jumble` release] |
| nos2x / nos2x-fox | Store build recorded at test time / v1.20.1 | Chromium and Firefox NIP-07 paths | Use distinct browser profiles and capture extension/store version. [VERIFIED: official repositories; official nos2x-fox release] |
| Amber | v6.3.0 | Android NIP-55 signer path | Exercise accept and reject paths for normal, group, and NIP-42 events. [VERIFIED: official `greenart7c3/Amber` release] |
| Clave | v1.0.0 | iOS NIP-46 signer path | Discovery-only iOS path; its own README labels it beta and notes no independent audit. Use disposable identity first and record consent. [VERIFIED: official `DocNR/clave` release and README] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| v1.3.2 release asset | Current `master` source build | Rejected: it is a different behavior set and has no release checksum; using it would invalidate the pinned-release premise. [VERIFIED: official Pyramid repository comparison] |
| Private mesh admin origin | Public admin with application login | Rejected: stock browser authentication is not an adequate public security boundary. [VERIFIED: official Pyramid v1.3.2 login source] |
| Quiesced whole-state backup | File-by-file live copy | Rejected until upstream documents consistency semantics for mmap/search/member state. [VERIFIED: official Pyramid v1.3.2 multi-store layout; CITED: https://restic.readthedocs.io/en/stable/040_backup.html] |

**Artifact installation (amd64):**

```bash
install -D -o root -g root -m 0755 pyramid-amd64 \
  /opt/niten/pyramid/releases/v1.3.2-e12e8164/pyramid
printf '%s  %s\n' \
  '93180050e101fa870ca022279eac3c18ea0bf263aee9d8dc67f24292b9c41920' \
  '/opt/niten/pyramid/releases/v1.3.2-e12e8164/pyramid' \
  | sha256sum --check --strict
ln -sfn /opt/niten/pyramid/releases/v1.3.2-e12e8164 \
  /opt/niten/pyramid/current
```

[VERIFIED: official Pyramid v1.3.2 amd64 release asset]

### Source Reproduction Contract

Clone `https://github.com/fiatjaf/pyramid`, fetch tag `v1.3.2`, detach at the exact commit, verify a clean tree, and preserve the source archive checksum. The tag declares Go `1.26.2`; upstream builds use `templ`, Tailwind, musl, Node 25, and `just build`. Upstream `package.json` uses range dependencies and has no lockfile, so a later `npm install` can select different frontend inputs. Record `go version`, `node --version`, `npm --version`, `musl-gcc --version`, `git status`, `go env`, `go version -m` on the result, `npm ls --all`, and the resulting checksum. Treat a differing locally built checksum as a provenance result, not permission to replace the verified release asset. [VERIFIED: official Pyramid v1.3.2 `go.mod`, `Dockerfile`, `justfile`, `package.json`, and release workflow]

Do not use upstream `easy.sh`: it selects mutable latest state, changes firewall/service configuration, and does not enforce the verified release digest. [VERIFIED: official Pyramid v1.3.2 `easy.sh`]

## Package Legitimacy Audit

No npm, PyPI, or crates package is introduced by this phase. Pyramid's npm modules are upstream source-build inputs, not new project dependency choices; preserve their resolved tree in the private build journal. The package-legitimacy gate is therefore not applicable. Release artifacts are instead gated by canonical repository, exact tag/commit, registry/release metadata, size, and SHA-256. [VERIFIED: phase stack and upstream source]

## Architecture Patterns

### System Architecture Diagram

```text
Anonymous reader / alumni clients / member-controlled signers
                         |
              HTTPS/WSS niten.sovereignengineering.io
                         v
               Caddy public route policy
              /          |             \
   NIP-11 + WSS     stock public home   privileged HTTP paths
          \              |                      |
           +-------------+                fixed 404 denial
                         |
                  127.0.0.1:3334
                         v
                stock Pyramid v1.3.2
                | membership/groups/search
                v
          /var/lib/pyramid generation

Operator browser -- private mesh + trusted local CA --> admin.niten private listener
                                                        |
                                                  full Pyramid UI/API

Private roster input --> offline validate/dedupe --> NIP-86 allow calls --> management state
                                                (raw values never in Git/logs)

systemd stop --> consistent state snapshot + artifact/config manifest --> restic off-host
                                                               |
                                                         blank-host restore
```

[VERIFIED: official Pyramid v1.3.2 listener/routes/state; CITED: https://caddyserver.com/docs/caddyfile/directives/reverse_proxy]

### Recommended Project Structure

```text
deploy/
├── caddy/Caddyfile                 # templated public/private routing; no live addresses
├── systemd/pyramid.service         # hardened unit
├── systemd/niten-backup.{service,timer}
├── systemd/niten-restore-check.{service,timer}
└── settings/settings.example.json  # secret-free effective settings template
scripts/
├── verify-artifact.sh              # pin, size, checksum, ELF metadata
├── roster-import.sh                # reads private file/FD; emits only counts/status
├── backup.sh                       # quiesce, snapshot, restart, check
├── restore-drill.sh                # blank path/host, never live overwrite
└── evidence-redact.sh              # allowlist schema and leak scan
docs/
├── operations.md                   # bootstrap, update, rollback, discard
├── quickstart.md                   # concise cohort instructions/privacy
├── incident-template.md
└── decision-gate.md
evidence/
├── README.md                       # schema and redaction policy
└── cases/                          # redacted per-case results only
```

[RECOMMENDATION: derived from PILOT-01 through PILOT-08 and DOC-01]

### Pattern 1: Immutable Artifact, Mutable Generation

Keep release directories immutable. Keep `/opt/niten/pyramid/current` as the selected artifact symlink. Before any disruptive change, stop Pyramid, snapshot `/var/lib/pyramid` plus effective non-secret config hash and artifact manifest, then start the new generation. Rollback means stop, preserve the failed generation, restore the matching prior snapshot into a new state directory, atomically select artifact/state symlinks, start, and run NIP-11/WSS/auth/read/write smoke probes. Never point an older binary at newer live state in place. [VERIFIED: Pyramid state is multi-file/mmap plus membership/search state; RECOMMENDATION: safe rollback pattern]

### Pattern 2: Two-Origin Administration Boundary

Public Caddy forwards WebSocket upgrades, NIP-11 requests, the stock root page, and ordinary client paths, but returns 404 for privileged browser routes such as `/setup/*`, `/settings*`, `/clients*`, `/database*`, `/event/*`, `/log*`, `/search/reindex*`, `/update*`, `/restart*`, `/action*`, `/u/sync*`, `/icon/*`, and disabled-module paths. A private mesh-only origin bound to the mesh interface forwards the full backend; that exact host must be included in Pyramid `alternate_domains`. Bootstrap domain/root only through the private origin before the public listener is enabled. Validate the route list against every route at the pinned source, not against this prose alone. [VERIFIED: official Pyramid v1.3.2 `main.go` and `settings.go`; RECOMMENDATION: ingress containment]

```caddyfile
niten.sovereignengineering.io {
    @privileged {
        path /setup/* /settings* /clients* /database* /event/* /log* /search/reindex* /update* /restart* /action* /u/sync* /icon/* /forum/* /groups/enable /groups/disable /groups/livekit/* /groups/wipe/* /groups/deleted /.well-known/nip29/livekit* /blossom* /grasp* /stream* /imgproxy* /linkpreview* /link/preview* /paywall* /nsite* /po/* /scheduled*
    }
    respond @privileged 404

    @nip86_public {
        method POST
        path /
    }
    respond @nip86_public 404

    reverse_proxy 127.0.0.1:3334 {
        stream_close_delay 5m
    }
}

https://admin.niten.sovereignengineering.io {
    bind {$NITEN_MESH_IP}
    tls internal
    reverse_proxy 127.0.0.1:3334
}
```

[VERIFIED: the shown syntax passed local `caddy validate` with v2.10.2; CITED: https://caddyserver.com/docs/caddyfile/directives/reverse_proxy; RECOMMENDATION: repeat validation with target v2.11.4 and run route probes]

### Pattern 3: Hardened Stock Process

```ini
[Unit]
Description=Niten stock Pyramid relay
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=60
StartLimitBurst=5

[Service]
Type=simple
User=pyramid
Group=pyramid
EnvironmentFile=/etc/niten/pyramid.env
WorkingDirectory=/var/lib/pyramid
ExecStart=/opt/niten/pyramid/current/pyramid
Restart=on-failure
RestartSec=5s
UMask=0077
NoNewPrivileges=yes
PrivateTmp=yes
PrivateDevices=yes
ProtectSystem=strict
ProtectHome=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
ProtectClock=yes
ProtectHostname=yes
RestrictNamespaces=yes
RestrictRealtime=yes
LockPersonality=yes
CapabilityBoundingSet=
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
ReadWritePaths=/var/lib/pyramid
StandardOutput=journal
StandardError=journal
LogNamespace=niten
LogRateLimitIntervalSec=30s
LogRateLimitBurst=1000

[Install]
WantedBy=multi-user.target
```

[CITED: https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html; RECOMMENDATION: run `systemd-analyze verify` and `systemd-analyze security pyramid.service` on the target OS before enablement]

Use `HOST=127.0.0.1`, `PORT=3334`, `DATA_PATH=/var/lib/pyramid/current`, `NO_AUTO_UPDATES=true`; do not expose SFTP. Precreate state directories mode `0700`, and verify `settings.json` and `management.jsonl` are `0600` after first private bootstrap. A dedicated journald namespace should set a finite `SystemMaxUse` and `MaxRetentionSec`; retain Pyramid's own rotating file log in the backup inventory. [VERIFIED: official Pyramid v1.3.2 env and file-mode/logging source; CITED: https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html]

### Pattern 4: Minimal Effective Settings

Enable `groups.enabled` and `search.enable`. Set `max_invites_per_person` to `0`, `allow_access_request=false`, `allow_ephemeral_from_anyone=false`, `accept_scheduled_events=false`, and explicitly disable internal, personal, favorites, inbox, bookmarks, popular, uppermost, moderated, Blossom, GRASP, nsite, stream, imgproxy, link preview, paywall, operator, embedded LiveKit, and other non-pilot modules. Set domain, alternate private admin domain, relay name, contact, description/privacy wording, limits, and icon explicitly. After bootstrap, export a redacted effective-settings report plus its checksum; never export `relay_internal_secret_key`. [VERIFIED: official Pyramid v1.3.2 defaults and settings schema; RECOMMENDATION: minimum Phase 1 surface]

Pyramid performs startup egress attempts to `api.ipify.org` and `httpbin.org`, and automatic update checks unless disabled. Record those stock attempts in the network inventory; deny unexpected destinations at the host only after proving startup and required group/client behavior remain functional. [VERIFIED: official Pyramid v1.3.2 `global/global.go` and update source]

### Pattern 5: Private Roster Snapshot

1. Receive the source event out-of-band into operator-controlled encrypted storage; never place its identifier, JSON, pubkeys, or derived membership file in the repository. [VERIFIED: CONTEXT D-06 and D-27]
2. Verify event ID/signature, expected kind/author/shape, and parse only valid `p` tags. Normalize lowercase 64-hex pubkeys, deduplicate, sort, and calculate a private manifest hash/count. [CITED: https://github.com/nostr-protocol/nips/blob/master/01.md]
3. From an operator workstation, invoke stock NIP-86 `allowpubkey` once per snapshot member. Keep signer/bunker material in the signer process, not CLI arguments, shell history, VPS, Git, or logs. [VERIFIED: official Pyramid v1.3.2 NIP-86 handlers; CITED: https://github.com/nostr-protocol/nips/blob/master/86.md]
4. Reconcile the exact private set against `listallowedpubkeys` privately. Commit only run ID, time, input count, accepted count, duplicate/invalid counts, and pass/fail. [VERIFIED: official Pyramid v1.3.2 NIP-86 handlers; RECOMMENDATION: data minimization]
5. Later changes are a new manual, reviewed snapshot/diff run; no daemon or periodic sync. [VERIFIED: CONTEXT D-08]

With `max_invites_per_person=0`, non-root members cannot expand membership through stock invitation accounting, while roots remain able to administer the roster. Test that negative control with a disposable member before cohort invitation. [VERIFIED: official Pyramid v1.3.2 membership source]

### Anti-Patterns to Avoid

- **Treating a private group as encryption:** Pyramid and operators can read content; say “access-controlled, operator-readable, not E2EE.” [CITED: https://github.com/nostr-protocol/nips/blob/master/29.md]
- **Using the stock browser login as a public admin boundary:** its cookie is long-lived and JavaScript-readable, and the page executes CDN scripts. Use private reachability plus an isolated operator profile and pilot-only operator identity. [VERIFIED: official Pyramid v1.3.2 UI/auth source]
- **Logging protocol fixtures blindly:** raw events reveal pubkeys, content, group IDs, relay sets, and sometimes signer connection data. Generate redacted case metadata separately. [VERIFIED: CONTEXT D-24 and D-27]
- **Live-copying mmap/search state:** quiesce the service for the authoritative backup until a verified upstream consistency mechanism exists. [VERIFIED: official Pyramid v1.3.2 store layout]
- **Calling all client failures relay defects:** preserve client, signer, Pyramid, relay destinations, and negative controls so ownership can be classified. [VERIFIED: PILOT-06]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Nostr signing | Key parser, Schnorr signing, or VPS key vault | Member-controlled NIP-07/46/55 signer | Custody and cryptographic edge cases remain outside project infrastructure. [CITED: official NIP-46 and NIP-55] |
| TLS/WebSocket proxy | Custom TLS daemon or WebSocket bridge | Caddy v2.11.4 | Caddy natively handles certificate automation and WebSocket upgrade/tunneling. [CITED: https://caddyserver.com/docs/automatic-https] |
| Relay membership/groups/search | Shadow database or companion API | Stock Pyramid | Duplicate authority would defeat the discovery question. [VERIFIED: PILOT-07 and official Pyramid source] |
| Backup encryption/dedup/check | Tarball script | restic v0.19.1 plus restore drill | Repository checks and restores are standard operations, while an ad hoc archive proves neither. [CITED: official restic backup/restore docs] |
| Client/signer cross-product | New hosted client | Required existing clients/signers only | Hosted UI and full matrix are explicitly deferred. [VERIFIED: D-10, D-11, PILOT-07] |
| Secret redaction | Generic regex-only cleanup | Positive evidence schema plus repository leak scan | Known-safe fields are more reliable than guessing every secret representation. [RECOMMENDATION: data minimization]

**Key insight:** Phase 1 measures stock Pyramid. Every custom authority, patched route, hosted client, or companion service destroys the experimental boundary and moves the question instead of answering it. [VERIFIED: phase boundary and PILOT-07]

## Common Pitfalls

### Pitfall 1: Roster Input Privacy Is Mistaken for Membership Privacy
**What goes wrong:** Operators keep the source event out of Git but promise that membership pubkeys remain private. [VERIFIED: official Pyramid v1.3.2 source]
**Why it happens:** Stock Pyramid renders/publishes membership state; NIP-29 privacy protects group reads, not all community metadata. [VERIFIED: official Pyramid invite-tree/membership source; CITED: NIP-29]
**How to avoid:** Obtain informed consent with exact wording; never publish the source event or private manifest; treat hidden membership as a missing product requirement if required. [RECOMMENDATION]
**Warning signs:** Anonymous/member queries or the stock home reveal roster relationships not described in the quickstart. [VERIFIED: official Pyramid source]

### Pitfall 2: Private Admin Is Only a URL Guess
**What goes wrong:** Privileged paths, setup, NIP-86 POST, or browser login remain reachable at the public origin. [VERIFIED: official Pyramid route table]
**Why it happens:** Admin and relay share one process/listener. [VERIFIED: official Pyramid v1.3.2 `main.go`]
**How to avoid:** Generate the public deny list from the exact pin, bind the private origin to mesh, bootstrap privately, and probe every route from public and private networks. [RECOMMENDATION]
**Warning signs:** Public `/settings`, `/database`, `/setup/root`, or a management POST returns anything except the configured denial. [RECOMMENDATION]

### Pitfall 3: CDN Script Risk Reaches a Privileged Signer
**What goes wrong:** A privileged browser page loads mutable third-party JavaScript while holding a replayable login event. [VERIFIED: official Pyramid v1.3.2 layout]
**Why it happens:** Alpine, nostr web components, window.nostr, htmx, and fonts are loaded from external CDNs without source-local pinning. [VERIFIED: official Pyramid v1.3.2 layout]
**How to avoid:** Isolated operator browser/profile and pilot-only key; no privileged signer on the public page; record outbound page dependencies; classify production remediation as upstream patch/revise work. [RECOMMENDATION]
**Warning signs:** Admin page works only with broad third-party script access or the same browser profile holds valuable identities. [RECOMMENDATION]

### Pitfall 4: “Private” Content Reaches Another Relay
**What goes wrong:** A client or signer publishes access-controlled content to a default/write relay in addition to Niten. [CITED: NIP-29 relay model]
**Why it happens:** Clients may merge relay sets or mishandle group destinations. [ASSUMED]
**How to avoid:** Use harmless unique trap content and controlled trap relays; capture destinations at the client/proxy layer without storing the event body in Git; immediately contain and notify on leakage. [RECOMMENDATION]
**Warning signs:** The test event ID appears outside the expected Niten connection. [RECOMMENDATION]

### Pitfall 5: Delete Is Treated as Erasure
**What goes wrong:** UI disappearance is reported as global or backup deletion. [CITED: https://github.com/nostr-protocol/nips/blob/master/09.md]
**Why it happens:** Signed events are copyable and Pyramid has age/state-specific deletion behavior. Pyramid group messages older than two hours are not author-deletable in the inspected stock handler. [VERIFIED: official Pyramid v1.3.2 group deletion source]
**How to avoid:** Test local query results, search/index state, reconnect, restart, and backup aging separately; state “best-effort local deletion,” never global erasure. [RECOMMENDATION]
**Warning signs:** Deleted content returns after reconnect/restart or remains searchable. [RECOMMENDATION]

### Pitfall 6: A Backup Exists but No Generation Can Restore
**What goes wrong:** A restic snapshot exists, but artifact/config/secret/member/search state mismatch or restore corrupts the only live copy. [RECOMMENDATION]
**Why it happens:** File presence is confused with recovery. [CITED: official restic restore docs]
**How to avoid:** Quiesced snapshot, `restic check`, blank-path/blank-host restore, exact manifest, and protocol acceptance before declaring recoverable. [CITED: official restic docs]
**Warning signs:** No recorded RPO/RTO, no restore transcript, or restore requires inventing undocumented steps. [RECOMMENDATION]

## Evidence and Test Architecture

### Required Pairings (Not a Full Cross-Product)

| Path | Client | Signer | Required Scope |
|------|--------|--------|----------------|
| S1 | Nostrord v2.4.0/recorded build | nos2x Chromium/recorded store build | Membership, NIP-42, public/restricted/private groups, roles, delete/reconnect/error. [VERIFIED: D-10/D-11] |
| S2 | Nostrord v2.4.0/recorded build | nos2x-fox v1.20.1 | Repeat a bounded group/auth/reconnect baseline. [VERIFIED: D-11] |
| S3 | Flotilla v1.9.0/recorded build | Amber v6.3.0 via NIP-55 | Group workflow plus signer accept/reject and reconnect. [VERIFIED: D-10/D-11] |
| S4 | Jumble v26.7.2/recorded build | Clave v1.0.0 via NIP-46 | Public publish/read/search/reconnect only; do not claim NIP-29 coverage. [VERIFIED: D-10/D-11 and official Clave docs] |
| S5 | Flotilla or Nostrord, exact build recorded | one member-chosen bunker | One compatible group/auth/publish flow plus disconnect/reconnect. Record signer product/version, never bunker URI. [VERIFIED: D-11] |

Mutable web clients require URL, client-reported version, platform/user agent, observation time, and where feasible service-worker/bundle hashes. A version label alone does not reproduce a served web build. [RECOMMENDATION: evidence integrity]

### Stock-Flow Sequence

1. **Host/provenance:** checksum, clean tag, effective redacted config, listening sockets, public/private Caddy route probes, TLS/NIP-11, service hardening, file permissions, reboot, log bounds. [VERIFIED: PILOT-01/02/03]
2. **Roster/membership:** private snapshot validation/reconciliation; allowlisted immediate write; nonmember read of public content; nonmember write rejection; access-request/invite denial; root manual add/remove with disposable identities. [VERIFIED: PILOT-04/05]
3. **Group state:** create unique public-open, public-restricted, hidden, and private+closed groups; test broad/explicit reads, member/nonmember writes, joins/invites, owner/admin/moderator/member transitions, removal/ban, metadata visibility, and restart persistence. Pyramid requires private groups to be closed; `hidden` and `private` are distinct. [VERIFIED: official Pyramid v1.3.2 group source; CITED: NIP-29]
4. **Protocol/content:** NIP-42 challenge/reconnect, NIP-50 positive/negative/audience-scoped search, note/reply/reaction, duplicate/invalid/oversize/stale/unauthorized rejects, delete before and after Pyramid's two-hour group threshold, reconnect/restart query. [VERIFIED: official Pyramid v1.3.2 source; CITED: NIP-42/NIP-50/NIP-09]
5. **Routing/privacy:** unique harmless trap events for every access-controlled path; prove exact outbound relay destinations and absence on controlled non-target relays. Never use confidential text for the trap. [RECOMMENDATION]
6. **Signer paths:** run S1-S5, including signer denial/cancel, connection loss, reconnection, and no raw-key fallback. [VERIFIED: PILOT-04/05]
7. **Operations:** disruptive notice, stop/start/restart, backup/check, blank restore, rollback to prior generation, and disposal/export rehearsal. [VERIFIED: PILOT-02/08/DOC-01]
8. **Feedback/decision:** collect structured participant/operator reports, categorize, close evidence gaps, issue one hard verdict. [VERIFIED: PILOT-06/08]

### Evidence Record

```yaml
case_id: P1-GROUP-PRIVATE-READ-UNAUTH
requirement: PILOT-05
observed_at_utc: <timestamp>
pyramid: {tag: v1.3.2, commit: e12e8164, artifact_sha256: <verified>}
client: {name: <name>, version: <version>, build_ref: <url-or-hash>, platform: <platform>}
signer: {family: NIP-07|NIP-46|NIP-55, product: <name>, version: <version>}
identity_class: allowlisted-real|disposable-operator|unauthorized-disposable
action: <controlled vocabulary>
expected: pass|reject
observed: pass|reject|error|timeout
destinations: [niten, trap-none]  # aliases only in committed evidence
evidence_refs: [private-journal-id, redacted-log-id]
classification: native-capability|configuration-need|pyramid-defect|client-gap|missing-product-requirement
containment: <none-or-redacted-action>
```

[RECOMMENDATION: implements PILOT-06 without retaining sensitive payloads]

Committed evidence must contain no event JSON/body, event IDs from private tests, roster event identifier, pubkeys/npubs/nprofiles, group invite codes, private group identifiers, bunker/nostrconnect URI, connection secret, authorization header/cookie, `nsec`, credentials, live IPs, or raw logs. The private journal may map opaque case IDs to sensitive fixtures under operator access; it must still never contain signer private keys or connection secrets. Run a leak scan before every evidence commit. [VERIFIED: D-24/D-27; RECOMMENDATION: data minimization]

### Hard Decision Gate

The gate opens only when every required stock flow and S1-S5 signer path has an observed pass/fail, public/private route tests pass, the private roster is reconciled, every access-controlled destination capture is classified, backup/blank restore/rollback pass, feedback is categorized, and incident/exit notices are ready. A failure may be accepted as evidence; a missing observation may not. [VERIFIED: D-13, D-21, PILOT-06/08]

Issue exactly one signed review verdict with owner, date, evidence index, unresolved risks, containment, next milestone, and exit actions:

- **PROCEED:** stock native behavior plus configuration is sufficient; no unresolved host-safety or systemic privacy/authorization blocker exists. [RECOMMENDATION]
- **REVISE:** Pyramid remains the candidate, but a bounded deployment/client/runbook or later upstream source change is required before broader use. Phase 1 stays source-unmodified. [RECOMMENDATION]
- **REPLACE:** core authority/privacy/compatibility behavior requires pervasive changes or another relay fits the evidence materially better. [RECOMMENDATION]
- **STOP:** host safety, key custody, privacy containment, operator capacity, or cohort consent cannot be made acceptable. [RECOMMENDATION]

Immediately stop public ingress—not merely the affected flow—if Pyramid binds publicly outside Caddy, privileged routes are reachable publicly, key/signer material reaches the VPS/logs/repository, state permissions expose the relay secret, restore/rollback threatens the only state copy, or a systemic authorization leak cannot be contained. Other client/action failures follow D-13/D-23 scoped isolation. [VERIFIED: D-13/D-23; RECOMMENDATION: host safety definition]

## Backup, Restore, Rollback, and Discard Contract

- Back up a stopped Pyramid state generation, redacted effective config plus secret config from its protected source, exact artifact/checksum manifest, unit/Caddy versions, and membership/search state. Keep Caddy certificates in the host-recovery inventory, not the public repository. [VERIFIED: official Pyramid state layout; RECOMMENDATION]
- Use an independent off-host restic repository and credentials not stored in Git or the state snapshot. Run backup, `restic check`, retention/prune under a documented policy, and restore into a blank non-live target. [CITED: official restic backup/working-with-repositories/restore docs]
- A restore passes only after file ownership/mode checks, exact artifact selection, service startup, NIP-11, WebSocket, anonymous public read, member auth/write, private group read denial, search, and restart persistence. [RECOMMENDATION]
- Rollback always preserves the failed generation first. Never overwrite it or downgrade against mutable newer state. [RECOMMENDATION]
- Discard/redeploy exports standard signed events and membership/group configuration best-effort, not signer keys. Notify members, revoke public ingress, preserve the retention-approved evidence/backup, and document what cannot migrate. External Nostr events and member identities remain independently usable. [VERIFIED: D-18/D-20/PILOT-08]

## Code Examples

### Redacted Effective Environment

```dotenv
HOST=127.0.0.1
PORT=3334
DATA_PATH=/var/lib/pyramid/current
NO_AUTO_UPDATES=true
```

[VERIFIED: official Pyramid v1.3.2 `global/global.go`]

### Public Protocol Probes

```bash
curl --fail --silent --show-error \
  -H 'Accept: application/nostr+json' \
  https://niten.sovereignengineering.io/ \
  | jq -e '.name == "Niten by Sovereign Engineering"'

curl --fail --silent --show-error \
  https://niten.sovereignengineering.io/settings \
  --output /dev/null --write-out '%{http_code}\n'
```

The second probe must assert the configured public denial status; do not capture a response body. WebSocket/NIP-42/NIP-50 probes should use generated disposable keys and sanitized output. [CITED: NIP-11; RECOMMENDATION]

### Private Build Journal Minimum Record

```text
run-id, UTC time, operator, decision/change, reason
upstream URL/tag/full commit/source archive checksum
release asset URL/size/SHA-256 and local verification transcript
build host image; Go/Node/npm/musl/just/templ versions; dependency tree
binary metadata/checksum; git clean-tree proof
redacted effective config hash; secret-config private reference
service/Caddy/restic versions; costs and resource observations
case/evidence IDs; failures/fixes; restore/rollback transcript
upstream issue/improvement candidates; final gate impact
```

[RECOMMENDATION: implements DOC-01]

## State of the Art

| Old/Unpinned Approach | Current Phase Approach | When Verified | Impact |
|-----------------------|------------------------|---------------|--------|
| `github-tijlxyz/khatru-pyramid` or mutable latest | `fiatjaf/pyramid` v1.3.2 / exact commit and checksum | 2026-07-31 | Canonical, reproducible discovery subject. [VERIFIED: official repositories] |
| Pyramid v1.3.2 release | `master` one commit ahead (`fd33969…`) allowing deletion of relay-signed events | 2026-07-31 | Do not mix unreleased behavior into Phase 1 evidence. [VERIFIED: official Pyramid compare] |
| Caddy 2.10.2 locally installed | Current official Caddy v2.11.4 | 2026-07-31 | Target provisioning must install/record the current pin, not assume the workstation version. [VERIFIED: local probe and official release API] |
| restic 0.19.0 locally installed | Current official restic v0.19.1 | 2026-07-31 | Provision exact target version and exercise its documented restore. [VERIFIED: local probe and official release API] |
| `nak` 0.16.2 locally installed | Current official `nak` v0.20.2 | 2026-07-31 | Use pinned operator tooling; do not infer target availability from local state. [VERIFIED: local probe and official release API] |

**Deprecated/outdated:** upstream `easy.sh`, legacy Khatru Pyramid repository, mutable `master` deployment, raw `nsec` paste, and Nostrum as an unverified current iOS recommendation are excluded. [VERIFIED: upstream audits and D-17]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Some clients may merge relay sets and misroute access-controlled plaintext. | Pitfall 4 | Destination-trap tests might be overcautious, but removing them could miss a severe privacy leak. |

All other implementation facts in this document were verified against live official repositories/source or cited official documentation. Recommendations still require execution evidence on the chosen VPS and exact client builds. [VERIFIED: research record]

## Open Questions

1. **VPS/provider/region and private mesh are not selected.**
   - What we know: public DNS/TLS and private operator reachability are required. [VERIFIED: D-01/D-03]
   - What's unclear: provider, jurisdiction/AUP, Debian image, backup region, mesh product/address, and operator CA distribution. [VERIFIED: current planning state]
   - Recommendation: Wave 0 must lock these before any public DNS cutover. [RECOMMENDATION]
2. **Does D-06 permit stock-visible membership pubkeys?**
   - What we know: input event and extracted files stay private, but stock Pyramid exposes resulting membership relationships. [VERIFIED: official Pyramid source]
   - What's unclear: whether alumni have consented to that distinction. [VERIFIED: CONTEXT contains no explicit consent result]
   - Recommendation: make this a pre-onboarding human gate; if hidden membership is required, Phase 1 cannot satisfy it source-unmodified. [RECOMMENDATION]
3. **Exact production client builds may move.**
   - What we know: current tags were verified, but hosted/mobile/store releases are mutable operational inputs. [VERIFIED: official client repositories]
   - What's unclear: what build each participant will actually run. [VERIFIED: no cohort run exists yet]
   - Recommendation: freeze the matrix at test time and retain build/URL/platform evidence. [RECOMMENDATION]
4. **Browser admin exposure remains discovery-grade.**
   - What we know: private routing reduces reachability but does not remove long-lived cookie/CDN script risk. [VERIFIED: official Pyramid v1.3.2 source]
   - What's unclear: whether the operator accepts a dedicated pilot identity/profile and whether all privileged HTTP paths can be fully denied publicly without impairing required flows. [VERIFIED: execution not yet performed]
   - Recommendation: require route probes and operator acceptance before public onboarding; likely classify production remediation as `REVISE`. [RECOMMENDATION]

## Environment Availability

This audit describes the current planning workstation, not the fresh VPS; the target must repeat every probe and record output. [VERIFIED: local environment probe]

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Go | Source reproduction | Available, wrong patch | 1.26.0; tag requires 1.26.2 | Pinned build container/toolchain. [VERIFIED: local probe and upstream go.mod] |
| Node/npm | Frontend source reproduction | Available, wrong major | Node 22.22.0/npm 10.9.4; upstream uses Node 25 | Pinned build container. [VERIFIED: local probe and upstream Dockerfile] |
| Caddy | Host ingress testing | Available, old | 2.10.2 vs current 2.11.4 | Install pinned target release. [VERIFIED: local probe and official release API] |
| restic | Backup testing | Available, old | 0.19.0 vs current 0.19.1 | Install pinned target release. [VERIFIED: local probe and official release API] |
| `nak` | NIP probes/roster | Available, old | 0.16.2 vs current 0.20.2 | Install pinned operator release. [VERIFIED: local probe and official release API] |
| systemd | Units/timers | Available | 258 locally | Verify target Debian version/features. [VERIFIED: local probe] |
| `websocat` | Optional raw WSS debugging | Missing | — | Use `nak`/client probes; not blocking. [VERIFIED: local probe] |

**Missing dependencies with no fallback:** VPS/provider/private-mesh provisioning and the private roster/cohort input block execution, not planning. [VERIFIED: planning state]

**Missing dependencies with fallback:** exact Go/Node/Caddy/restic/nak pins are absent locally but can be provided by pinned build/host installation. `websocat` is optional. [VERIFIED: local probe]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | yes | NIP-42 connection auth for relay; private reachability plus dedicated pilot operator identity for stock browser admin. Never treat the stock cookie alone as sufficient. [VERIFIED: Pyramid source; CITED: NIP-42] |
| V3 Session Management | yes | Isolated admin profile, private origin, no public admin; record the stock cookie weakness as a gate. [VERIFIED: Pyramid v1.3.2 source] |
| V4 Access Control | yes | Pyramid membership/group checks plus public/private ingress tests and disposable negative identities. [VERIFIED: Pyramid source; CITED: NIP-29] |
| V5 Input Validation | yes | Stock event signature/ID/schema/limit checks; separately validate roster event/type/pubkeys and negative fixtures. [VERIFIED: Pyramid source; CITED: NIP-01] |
| V6 Cryptography | yes | Nostr secp256k1/Schnorr in existing clients/signers; Caddy TLS; restic encryption. Never hand-roll or store member keys. [CITED: official NIPs, Caddy, and restic docs] |
| V7 Error/Logging | yes | Bounded namespaced journald, app-log rotation, redacted evidence, no raw private events/signers. [VERIFIED: Pyramid logging source and D-24/D-27] |
| V8 Data Protection | yes | `UMask=0077`, private state, off-host encrypted backup, private roster/journal, consent for membership visibility. [VERIFIED: Pyramid file modes and D-06/D-27] |
| V9 Communications | yes | Caddy HTTPS/WSS, loopback backend, mesh-only private admin, exact destination traps. [CITED: Caddy reverse-proxy docs] |
| V12 Files/Resources | yes | Disabled Blossom/SFTP/GRASP/nsite and restrictive writable paths. [VERIFIED: Pyramid settings/modules] |
| V14 Configuration | yes | Immutable artifact, auto-update disabled, redacted effective config, exact route inventory, restore/rollback proof. [VERIFIED: Pyramid source and PILOT-01/02] |

### Known Threat Patterns for Pyramid Pilot

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Replayed/forged browser admin session | Spoofing / Elevation | Mesh-only ingress, isolated operator profile/key, route denial, no public browser admin; later upstream fix if proceeding. [VERIFIED: Pyramid auth source] |
| Group authorization bypass or client misroute | Information Disclosure | Member/nonmember matrix, broad/explicit query tests, trap relays, rapid redacted notice and scoped containment. [CITED: NIP-29; VERIFIED: D-22/D-23] |
| Unauthorized cohort expansion | Elevation | `max_invites_per_person=0`, access requests off, private reconciliation, disposable invitation negative test. [VERIFIED: Pyramid membership source] |
| Relay secret/state disclosure | Information Disclosure | Service `UMask=0077`, mode/ownership assertions, private backup, no raw settings in Git. [VERIFIED: Pyramid file-mode source] |
| Supply-chain substitution | Tampering | Canonical repo, tag+commit+size+SHA-256, immutable release layout, clean-source reproduction journal. [VERIFIED: live release audit] |
| Destructive rollback/restore | Tampering / Denial | Preserve failed generation, restore into blank path, match artifact/state/config, protocol acceptance before switch. [RECOMMENDATION]
| CDN script compromise on stock page | Spoofing / Information Disclosure | No privileged public signer, isolated admin profile, private path, explicit production decision gate. [VERIFIED: Pyramid layout source] |
| Sensitive data in Git/evidence | Information Disclosure | Positive redacted schema, leak scan, private opaque mapping, no raw logs/events/roster/signers. [VERIFIED: D-24/D-27] |

## Sources

### Primary (MEDIUM-to-HIGH confidence)

- `https://github.com/fiatjaf/pyramid/releases/tag/v1.3.2` and official release API — tag, timestamp, assets, size, digest; amd64 asset independently downloaded and hashed. [VERIFIED: official source]
- `https://github.com/fiatjaf/pyramid/tree/e12e81641bfe6cacc6dd246e9433d602c1240e66` — complete pinned source audit covering build, settings, routes, authentication, membership, groups, storage, logging, updates, and defaults. [VERIFIED: official source]
- `https://github.com/nostr-protocol/nips/blob/master/29.md` — group access semantics. [CITED: official specification]
- `https://github.com/nostr-protocol/nips/blob/master/42.md` — relay authentication. [CITED: official specification]
- `https://github.com/nostr-protocol/nips/blob/master/46.md` — remote signing. [CITED: official specification]
- `https://github.com/nostr-protocol/nips/blob/master/50.md` — search. [CITED: official specification]
- `https://github.com/nostr-protocol/nips/blob/master/55.md` — Android signing. [CITED: official specification]
- `https://caddyserver.com/docs/caddyfile/directives/reverse_proxy` and `https://caddyserver.com/docs/automatic-https` — WebSocket proxy and TLS behavior. [CITED: official documentation]
- `https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html` and `journald.conf.html` — service sandbox and log bounds. [CITED: official documentation]
- `https://restic.readthedocs.io/en/stable/040_backup.html`, `045_working_with_repos.html`, and `050_restore.html` — backup/check/restore. [CITED: official documentation]

### Secondary (MEDIUM confidence)

- Official release/tag histories for Nostrord, Flotilla, Jumble, nos2x, nos2x-fox, Amber, Clave, Caddy, restic, and `nak`, queried 2026-07-31. [VERIFIED: canonical repositories]
- `.planning/research/SUMMARY.md` — project-level baseline reused only where rechecked or clearly identified as project constraints. [VERIFIED: repository planning artifact]

### Tertiary (LOW confidence)

- Client relay-set misrouting is retained as an explicit assumption to be tested, not as a confirmed client defect. [ASSUMED]

## Metadata

**Confidence breakdown:**
- Standard stack: **HIGH** for Pyramid pin/artifact/source behavior; **MEDIUM** for target-host package pins until installed. [VERIFIED: live source/release and local environment audits]
- Architecture: **MEDIUM** — official component behavior is verified; the two-origin envelope and hardening require target-host acceptance tests. [VERIFIED: source/docs; RECOMMENDATION pending execution]
- Pitfalls: **HIGH** for Pyramid auth/file-mode/membership/CDN behaviors; **MEDIUM** for cross-client routing until matrix execution. [VERIFIED: source audit; ASSUMED client-routing risk]
- Client/signers: **MEDIUM** — canonical releases are current, but exact served/store builds and combinations remain execution evidence. [VERIFIED: official repositories]

**Research date:** 2026-07-31
**Valid until:** 2026-08-07 (Pyramid and client pins are fast-moving; re-run release/source diff before implementation.)
