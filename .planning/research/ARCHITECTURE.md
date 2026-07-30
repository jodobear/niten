# Architecture Research

**Domain:** Modular sovereign Nostr community infrastructure centered on Pyramid
**Researched:** 2026-07-30
**Confidence:** MEDIUM

## Executive Recommendation

Run one small production stack on a dedicated VPS, but preserve boundaries so each service can move independently. Caddy is sole public listener. Pyramid owns only authoritative community relay, membership/access, roles, moderation, and NIP-29 groups. Disable Pyramid's optional Blossom, GRASP, nsite, streaming, paywall, link-preview, image-proxy, SFTP, and embedded LiveKit for release one. Media, public-event aggregation, web/NIP-05, curation, observability, and backup remain separate processes, Unix users, stores, and lifecycles.

Recommended public surface (labels remain placeholders until naming lands):

| Address | Owner | Behavior |
|---|---|---|
| `wss://relay.<domain>` | Pyramid | Root WebSocket; NIP-11 HTTPS; public reads/member writes; authoritative NIP-29 URL |
| `https://blobs.<domain>` | Standalone Blossom | Public blobs; signed member upload/delete; quotas; never public plaintext private media |
| `https://<domain>` | Static site/onboarding | Discovery, compatible clients/signers, setup, aggregate status, public feed links |
| `https://<domain>/.well-known/nostr.json` | Static NIP-05 output | Reviewed public name map, CORS, no redirects |
| `https://best.<domain>` | Curated projection | Read-only admin-curated showcase |
| `https://status.<domain>` | External monitor/page | Useful even when VPS is down |
| `https://admin.<domain>` | Thin signed UI | Prefer private-network-only; no private keys |
| `git.<domain>` + `grasp.<domain>` | Later services | Separate Git host and NIP-34 collaboration service |

This is single-host deployment, not monolith. External uptime monitor and encrypted offsite backup sit outside VPS failure domain.

## Evidence Snapshot: Pyramid Boundary

Canonical repository is [`fiatjaf/pyramid`](https://github.com/fiatjaf/pyramid). Current inspected release: [`v1.3.2`](https://github.com/fiatjaf/pyramid/releases/tag/v1.3.2), published 2026-07-29, commit `e12e81641bfe6cacc6dd246e9433d602c1240e66`. Pin tested version and digest; never follow `latest`.

Pyramid v1.3.2 supplies membership hierarchy, access/invites, roots and root-managed roles, NIP-86 management, public member-write/internal relays, NIP-29 groups, NIP-42 auth, NIP-11, deletion/moderation, and memory-mapped event layers. It also registers Blossom, GRASP, nsite, streaming, image proxy, link preview, paywall, operator and many projection routes in one binary ([source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/main.go#L487-L548)). Treat these as optional upstream features, not required production ownership.

Two pre-pilot blockers:

1. Relay internal secret is serialized in `settings.json` ([source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/global/settings.go#L57-L63)); save uses mode `0644` ([source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/global/settings.go#L465-L475)). Patch to `0600`, parent `0700`, verify after every save. Entire Pyramid data/backups are secret-bearing.
2. Built-in negentropy download targets raw main store through `StorePublisher` ([source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/sync.go#L55-L80)). Never use blind sync as inward aggregator; validate/classify through a sidecar and normal relay ingress.

Pyramid's private-group query filter hides contents from non-members, though non-hidden private metadata remains visible ([source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/groups/queries.go#L63-L97)). This is access control, not encryption, and needs executable tests at deployed pin.

## System Overview

```text
 Existing clients/signers                        Selected external public relays
 NIP-07/46/55; keys stay client                              │ outbound WSS
             │ HTTPS/WSS                                      ▼
┌────────────▼────────────── TRUST BOUNDARY: VPS ───────────────────────────────┐
│ provider firewall: public 80/443; SSH only VPN/allowlist                     │
│ ┌──────────────────────── Caddy :80/:443 ──────────────────────────────────┐ │
│ │ TLS, hostname routing, coarse limits, logs, metrics                     │ │
│ └─────┬──────────────┬───────────────┬────────────────┬───────────────────┘ │
│       ▼              ▼               ▼                ▼                     │
│  Pyramid         Blossom        static site       signed admin UI           │
│  relay/access    public blobs   + NIP-05          no key custody             │
│  + NIP-29            │                                                   │   │
│       ▲              │                                                   │   │
│       │ local WSS    │                                                   │   │
│  public aggregator   │       curator → read-only Best-of projection      │   │
│  validate/dedupe/    │                                                   │   │
│  provenance          │                                                   │   │
│ ───────────────────── STATE BOUNDARY ───────────────────────────────────── │   │
│ Pyramid mmap | aggregator SQLite | Blossom DB/blobs | logs/metrics         │   │
│ distinct owners; no cross-service direct file access                      │   │
│ node_exporter + blackbox + Prometheus + Alertmanager + journald/Alloy      │   │
└────────────────────────────────┬───────────────────────────────────────────┘
                                 ▼ outbound HTTPS/S3
                    encrypted offsite restic repository

LATER: Git client ↔ git.<domain> ↔ grasp.<domain> ↔ Nostr clients
```

## Trust Boundaries

| Boundary | Testable controls |
|---|---|
| Internet → Caddy | TLS, size/connection/time limits, rate limits, correct proxy headers, no direct backend ports |
| Caddy → Pyramid | Signature/ID verification, membership, NIP-42, query-cost and per-IP/pubkey limits |
| Public relay → private NIP-29 | Default-deny auth queries; non-member negative tests; mmap unreachable; no public replica |
| External relays → aggregator | Signature/ID, member author, public allowlist/tag denylist, size/time bounds, dedupe |
| Aggregator → Pyramid | Normal local WSS publish only; never raw-store write; narrow OS user; append-only provenance |
| Client → Blossom | Signed BUD auth, hash, quotas, streaming size/type policy, processing/mirror disabled initially |
| Private attachment → blob store | Client ciphertext before upload; auth defense-in-depth; no keys/nonces in logs |
| Operator → admin | Two separate accounts/pubkeys, signed actions, hardware-backed SSH, audit log, re-auth destructive ops |
| VPS → backup | Client-side encryption, scoped bucket key, offline recovery secret, restore checks |
| Public status | External probes; distinguish HTTP health, protocol correctness, backup freshness, restore readiness |

## Component Boundaries

| Component | Owns | Must not own | Interface |
|---|---|---|---|
| Caddy | 80/443, TLS, routing, coarse limits | Nostr authorization/member state | HTTPS/WSS to loopback; metrics |
| Pyramid | Member graph, alumni/friend/admin labels, invites, roles, public relay, NIP-29, NIP-42/86, moderation | Files, Git, web, crawling, telemetry, backup | Nostr WS, NIP-11/29/42/86 |
| Onboarding/admin UI | Signer discovery, invite/role UX | Keys, passwords, canonical authorization | NIP-07/46/55 + signed relay calls |
| Blossom | Blob ownership, physical blobs, signed upload/delete, quotas/reports | Membership truth, group keys | Blossom HTTP; reviewed roster export |
| Aggregator | Source selection, validation, dedupe, provenance, deletions, checkpoints | DMs/groups, signature changes, generic mirroring | External WSS → local WSS; SQLite ledger |
| Curator | Admin-signed include/remove ledger; public projection | Re-signing content; engagement scoring | Signed control action; read-only feed |
| Web/NIP-05 | Static discovery/onboarding/name map | Relay state/keys/admin authority | HTTPS static assets/JSON |
| Observability | Aggregate health/capacity/errors | Content analytics/social profiles | Loopback metrics, journal/Alloy, alerts |
| Backup | Consistent snapshots, encryption, retention, restore evidence | Live serving/indefinite deleted content | systemd timers + restic |
| Git + GRASP later | Git objects separately from NIP-34 events | Pyramid DB coupling | Git SSH/HTTPS + WSS |

Canonical-state rule: Pyramid alone writes community/member/group state; Blossom alone writes blob metadata/files; aggregator ledger only records observation provenance while Pyramid stores unchanged events; curator alone writes inclusion decisions; Git host owns Git objects. No service touches another service's files.

## Hostname/Routing Decision

| Model | Compatibility and operations | Verdict |
|---|---|---|
| Flat subdomains | Root relay/Blossom origins; explicit CORS, certs, logs, limits, migration | **Recommend** |
| Nested subdomains | Usually works; longer IDs; wildcard `*.example` does not cover `*.community.example` | Only if brand requires; test cert/client matrix |
| Paths | Pyramid supports them, but external clients/discovery vary; auth/cache/log policies couple | Avoid for configured protocols; okay for same-service admin APIs |
| Protocol-aware single host | Header/upgrade/path ambiguity; widest blast radius | Do not multiplex unrelated services. Dedicated relay host serving WSS plus NIP-11 HTTP is normal |

Caddy supports WebSocket tunneling ([docs](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy)) and metrics ([docs](https://caddyserver.com/docs/metrics)). It alone terminates TLS. Pyramid and all backends bind loopback/private rootless network; disable Pyramid autocert listeners.

## Data Flows

### Onboarding, Invite, Role

```text
admin browser + chosen signer
 → static admin UI → signed NIP-42/NIP-86 action
 → Caddy → Pyramid → validate root authority
 → append membership/role action → publish/result → UI audit view
```

Set Pyramid non-root invite allowance to zero. Use two root/admin pubkeys for primary and backup operators. Assign `alumni` or `friend` to all admitted members; `administrator` only to operators/admins. Pyramid labels do not automatically enforce every capability: acceptance tests must prove only roots/admins can invite friends and manage roles. UI holds no keys; delegate to nos2x, Amber/NIP-55, compatible iOS signing, or member-selected NIP-46 bunker. No hosted bunker.

### Public Local Publication

```text
member signs locally → WSS/Caddy/Pyramid
 → verify signature/id/size/kind/timestamp/member policy
 → main event layer → matching subscriptions → anonymous/public readers
```

Members may send same signed public event to other write relays. Event ID stays identical. Valid NIP-09 deletion requests remove/stop serving matching-author targets while deletion request remains available. Global deletion cannot be guaranteed across independent relays/clients ([NIP-09](https://github.com/nostr-protocol/nips/blob/master/09.md)).

### Public-Event Inward Aggregation

```text
Pyramid roster ──────────────────────┐
member NIP-65 write relays +         ├→ bounded subscriptions
operator-approved source relays ─────┘  → parse/signature/event-id bounds
                                         → current member/friend author
                                         → explicit PUBLIC classifier
                                         → event-ID dedupe + provenance ledger
                                         → unchanged event to local WSS
                                         → normal Pyramid validation/storage
```

Admit only public kinds required for profiles, public notes/replies/reactions, long-form, relay lists, and valid deletions. Reject:

- Any `h` group tag.
- NIP-17/59 DMs, seals, gift wraps, file messages, and private relay lists.
- Any NIP-70 protected `['-']` tag. NIP-70 requires author-authenticated publication and default relay rejection ([spec](https://github.com/nostr-protocol/nips/blob/master/70.md)).
- NIP-29 membership/moderation/metadata outside Pyramid group path.
- Oversized, invalid, future/implausibly old, unknown-policy, or non-member events.

Store `{event_id, source_relay, first_seen, last_seen}` separately; never mutate signed event for provenance. Forward accepted replaceable/addressable versions and let tested relay replacement semantics select served state. Import valid member-authored NIP-09 requests, verify target authorship when known, and keep polling long enough to see deletions. Start with 2–4 NIP-65 write relays/member plus operator allowlist; bound backfill and connection count. NIP-65 supports author write-relay discovery and recommends small lists ([spec](https://github.com/nostr-protocol/nips/blob/master/65.md)).

### Access-Controlled NIP-29 Room

```text
NIP-29 client → authoritative group relay hint → NIP-42 auth
 → event with h=<group-id> → Pyramid membership/role/kind checks
 → plaintext store → query checks reader membership
 → broadcast only to authenticated allowed readers
```

NIP-29 defines relay-enforced closed writers and optional private reads, not encryption ([spec](https://github.com/nostr-protocol/nips/blob/master/29.md)). Operators and anyone with data/backup access can technically read plaintext. State this clearly.

Server ACL cannot stop a client from sending same plaintext to public relays. Leak prevention must be tested:

1. Endorsed clients use group relay hint as sole destination for private `h` events.
2. Public relay configuration stays separate from group links; private room never becomes generic publish target.
3. Aggregator and any later exporter reject every `h` event and fail closed on unknown tags/kinds.
4. For each supported client, configure a trap public relay, publish private group content, assert trap receives zero events. Remove failing clients from recommendations.
5. NIP-29 `previous` references mitigate out-of-context forks, not confidentiality.

Only ciphertext makes accidental publication non-catastrophic. E2EE is later separate work.

### Blossom and Private Attachments

```text
member hashes blob + signs Blossom auth
 → blobs host → hash/size/quota/type/ownership checks
 → blob + descriptor → public GET by SHA-256
 → signed owner deletion; physical removal after last owner
```

Blossom defines blobs on publicly accessible servers ([official spec](https://github.com/hzrd149/blossom)). Use standalone, pinned [`hzrd149/blossom-server`](https://github.com/hzrd149/blossom-server) or validated equivalent. Require signed upload/delete; no anonymous upload; disable listing others, server-side mirror, and transcoding initially; stream/hash uploads; strict member/friend quota. Local filesystem primary during pilot; preserve S3-compatible backend option.

| Private-media design | Public-reader confidentiality | Server/operator confidentiality | Client burden | Verdict |
|---|---:|---:|---|---|
| Public plaintext Blossom | No | No | Existing | Forbidden |
| Authenticated plaintext | Yes if every route enforces | No | Custom | Only explicitly operator-readable low-sensitivity use; not E2EE |
| Client-encrypted public blob | Yes | Yes | Crypto/key distribution | Minimum cryptographic design |
| Client-encrypted + authenticated fetch | Yes | Yes | Highest/audited | **Target**; auth is defense-in-depth |

NIP-44 explicitly does not define attachments ([spec](https://github.com/nostr-protocol/nips/blob/master/44.md)). NIP-17 encrypted kind-15 files exist, but NIP-17 says group chats above ten participants need another scheme ([spec](https://github.com/nostr-protocol/nips/blob/master/17.md)); it is not ready for 100-person NIP-29 rooms.

Launch rule: disable private-room attachment UI until phase-specific design and client audit pass. Preferred later flow: random per-object AEAD key; encrypt file and thumbnail locally; upload ciphertext only; place key/nonce/hash/metadata inside audited room encryption envelope; require short-lived Nostr-signed retrieval. Never log key material.

### Best-of Curation

```text
admin selects public event ID → signs add/remove decision
 → curator validates current admin roster → stores decision/reason/time
 → fetches/verifies original event → unchanged read-only projection
```

Never re-sign member content. Keep original ID/signature and separate signed curation audit. Initial option: Pyramid favorites only after focused patch/test makes writes admin-only. Otherwise use tiny curator + read-only relay/static feed. Automatic engagement ranking is later and non-blocking.

### NIP-05, Website, Status

Generate reviewed NIP-05 mapping; serve static at `/.well-known/nostr.json`. NIP-05 requires HTTPS, lowercase hex, browser CORS, and no redirects; pubkey stays primary identity ([spec](https://github.com/nostr-protocol/nips/blob/master/05.md)). Site stays static where possible. Dynamic onboarding/admin uses narrow signed APIs, never password accounts.

Public status uses an external monitor/page. Internal Grafana remains private. Show separate health for WSS/public read, authenticated private-read canary, Blossom upload/delete canary, backup freshness, and last restore drill. Green HTTP alone is not readiness.

### NIP-34/Git Later

NIP-34 separates Git-enabled servers from repository announcements/patches/issues/status ([spec](https://github.com/nostr-protocol/nips/blob/master/34.md)). `git.<domain>` owns Git objects/SSH/HTTPS; `grasp.<domain>` owns NIP-34 WSS events. Do not use Pyramid's embedded GRASP merely because available. Draft/optional NIP-34 comes after social pilot.

## Deployment, Isolation, Secrets

### Recommended Hybrid

- Host systemd: Caddy, pinned Pyramid, aggregator/curator, exporters, backup timers.
- Rootless Podman Quadlet when canonical upstream delivery is containerized: Blossom and optional Prometheus/Grafana/Loki/Alloy. Pin image digests; own volume only; loopback publication only.
- Static site/NIP-05 served read-only by Caddy.

| Option | Result | Verdict |
|---|---|---|
| Native system services | Low overhead, strong systemd sandbox/rollback; dependency packaging cost | Best for core binaries |
| Rootless containers | Immutable upstream artifacts; UID/volume/network complexity | Best selectively |
| Hybrid | Matches delivery; one supervisor and explicit stores | **Recommend** |
| Rootful Docker Compose | Easy demo; root daemon, accidental ports, mutable tags | Dev only |
| Kubernetes | Excess cost/failure modes | Reject |

Dedicated Unix user/service, `UMask=0077`, read-only config/executable, writable own state only. Test `NoNewPrivileges`, `PrivateTmp`, `ProtectSystem=strict`, `ProtectHome`, `PrivateDevices`, capability/address-family restrictions, `MemoryMax`, `TasksMax`, and `ReadWritePaths` against actual flows.

Network:

- Provider+host firewall: inbound 80/443 only. Bootstrap SSH restricted; then private network/VPN. Two named operator accounts, separate hardware-backed keys, no passwords/shared root.
- Caddy public; Pyramid `127.0.0.1:3334`; everything else loopback/private rootless network. No public metrics/admin/exporter ports.
- Aggregator outbound WSS only to reviewed sources with timeouts/caps. Backup outbound HTTPS/S3 only to scoped endpoint.
- Disable SFTP/FTP, LiveKit/TURN, built-in autocert, and Pyramid auto-update (`NO_AUTO_UPDATES=true`).

Member/admin private keys never reach infrastructure. Server secrets: Pyramid relay key, restic password, object-store credential, alert token, optional synthetic test key. Use systemd credentials or root `0600` files outside Git; systemd credentials avoid environment propagation and restrict access ([docs](https://systemd.io/CREDENTIALS/)). Keep offline recovery copies so host/TPM loss cannot block restore. Pyramid's secret-bearing settings/data require patched mode, `0700` parent, encrypted backup.

## Storage, Backup, Restore, Deletion

```text
/var/lib/dialogos/
├── pyramid/       # 0700; mmap, secret settings, membership/action logs
├── blossom/       # metadata DB + public blobs; separate owner
├── aggregator/    # provenance/checkpoint SQLite; no private payloads
├── curator/       # decisions/projection
├── prometheus/    # bounded retention
└── loki/          # optional bounded logs
/etc/dialogos/     # root-owned non-secret config
/run/credentials/  # runtime secrets
/srv/dialogos-site/# read-only static release
```

No shared catch-all volume. Separate stores allow different backup, quota, retention, restore, and migration.

Restic supplies encrypted/authenticated repositories plus backup/restore/check/forget/prune ([docs](https://restic.readthedocs.io/en/stable/), [design](https://github.com/restic/restic/blob/master/doc/design.rst)). Use offsite S3-compatible bucket in different provider/failure domain and bucket-scoped key.

1. **Consistency:** never assume a live mmap/SQLite copy is valid. Prefer filesystem/LVM snapshot after tested quiesce; otherwise briefly stop Pyramid, reflink/copy snapshot, restart, then restic. SQLite uses online backup API or stop/snapshot. Immutable blobs may copy live only if metadata snapshot is consistent.
2. **Frequency:** nightly state; optional six-hour Pyramid after measurement. Save non-secret release manifests each deploy. Do not claim RPO until drills measure it.
3. **Retention/deletion:** content-bearing snapshots daily for 35 days, then weekly prune. Separate long-term infra/config set excludes user content. Once source deletion and all pre-deletion snapshots expire, `forget`+`prune` removes unreferenced chunks. Publish maximum 35 days plus bounded prune delay. External recipients/relays may retain copies.
4. **Integrity:** backup freshness alert; weekly metadata check; monthly sampled data check; quarterly full check if cost allows.
5. **Restore:** monthly disposable-directory restore; full service drill before opening. Verify Pyramid secret/settings/membership, public/private queries, Blossom ownership/hash, aggregator checkpoints, DNS/TLS procedure, and pins. Offline password recovery held under agreed two-operator custody; bucket key alone cannot decrypt.

NIP-29 recommends live history replica. Do not replicate private plaintext to public relay. A later replica must encrypt at rest, preserve private ACL, and pass migration/fork tests. First release uses offsite encrypted backup; replica never replaces restore drill.

## Observability and Operations

- `node_exporter` for host metrics ([official guide](https://prometheus.io/docs/guides/node-exporter/)).
- Caddy request/upstream metrics.
- Blackbox exporter for HTTPS/cert/DNS/TCP plus protocol-aware WSS canary ([official repo](https://github.com/prometheus/blackbox_exporter)).
- Prometheus, 15-day bounded local retention; Alertmanager routing/grouping/silences ([docs](https://prometheus.io/docs/alerting/latest/alertmanager/)); two operator destinations.
- Structured journald first. Add single-binary Loki + Alloy only when needed. Promtail was removed in Loki 3.7.3 ([release](https://grafana.com/docs/loki/latest/release-notes/v3-7/)). Grafana private only.

| Alert | Initial gate |
|---|---|
| Relay unavailable | 2 external failures; page after 5 min |
| Public-read canary | Alert after confirmation |
| Private allow/deny canary | Immediate; unauthorized allow = security incident |
| Disk | warn <30%, critical <20%, uploads stop before 15% |
| Memory/restarts | sustained >85%, OOM, restart loop |
| TLS | warn <21 days, critical <7 |
| Blossom | missing/orphan descriptor or failed delete canary |
| Aggregator | checkpoint lag and per-source failures |
| Backup/restore | no backup in 30h; no sampled restore in 35d |
| Abuse/auth | aggregate rate-limit/auth spike; never log event content |

Allowed product measures: onboarded count, coarse weekly-active unique pubkeys, public post count, aggregate storage. Short retention, published definitions. No per-user engagement scores, cross-relay behavioral dossiers, social-graph telemetry, tracking pixels, or ad tech.

## Capacity and Cost

| Dimension | Pilot assumption | Gate |
|---|---:|---|
| Identities | 100 alumni + 20 friends | trivial roster |
| Weekly active | 40 | product metric |
| WebSockets | 25 ordinary, 100 peak, test 500 | measure FD/RAM/latency |
| Writes | 2,000/day; test 20/s for 15 min | clean overload/no corruption |
| Events | plan up to 5M | reserve 20–40 GB incl. index; measure mmap amplification |
| Blossom | 512 MB/alumni, 256 MB/friend; ~60 GB aggregate cap | raise only from forecast |
| Logs/metrics | 10–15 GB bounded | 15–30 days |
| Recovery target | initial RPO 24h/RTO 4h | claim only after full drill |

Start 4 shared vCPU, 8 GB RAM, 160 GB SSD. Akamai currently lists that shared size at US$48/month ([official pricing](https://www.akamai.com/cloud/pricing)); provider/region/jurisdiction remain gates. Benchmark chosen VPS.

| Monthly item | Estimate |
|---|---:|
| VPS | $48 |
| Offsite backup 250–500 GB | $2–5; B2 starts $6.95/TB-month ([pricing](https://www.backblaze.com/cloud-storage/pricing)) |
| Domain/DNS | $1–3 |
| External status | $0–10 |
| Notifications/misc | $0–5 |
| Restore VM/contingency | $10–20 |
| **Expected** | **$61–91** |

160 GB allocation: 25 GB OS/releases, 30 GB Pyramid/indexes, 60 GB Blossom, 15 GB logs/metrics/snapshot staging, ≥30 GB free. If exceeded, move Blossom to object storage/own storage first; never starve Pyramid or remove free-space gates. Likely first bottleneck is media disk, then external aggregation connections, not CPU.

## Upgrade, Rollback, Scaling

1. Pin binary/image version and SHA-256; record chosen Pyramid release asset digest.
2. Disable update button/auto-update, `latest`, and install pipes.
3. Upgrade restored production copy first; run migration, public/private, deletion, Blossom, aggregator, and client checks.
4. Take consistent verified pre-upgrade snapshot.
5. Install beside old, atomic switch, smoke/metrics gates.
6. Roll back binary/config on failure. If format migrated, restore snapshot; never use old binary on unknown new state.
7. Keep two proven releases/manifests local+offsite. Patch OS on tested cadence; reboot drill verifies services, mounts, firewall, timers.

Scaling path: keep one VPS through pilot; move Blossom storage/host first; move aggregator if outbound work contends; add warm restore host then NIP-29-aware replica only when availability warrants; add Git/GRASP independently; add audited E2EE/custom client without collapsing protocols.

## Repository Structure

```text
deploy/       # caddy, hardened systemd, quadlet, firewall, inventory
services/     # aggregator, curator, thin admin-web
site/         # static public site and reviewed NIP-05 generator/output
config/       # non-secret Pyramid/Blossom/Prometheus/Alloy policy
ops/          # backup, restore, upgrade, incident, handover
tests/        # protocol, privacy, compatibility, load, recovery
decisions/    # ADRs, pins, exceptions, unresolved gates
evidence/     # redacted acceptance output; never secrets/content
```

Config defines policy; service enforces; test proves; evidence records. Secrets and generated live state never enter Git.

## Build Order and Minimum Vertical Slice

Minimum slice:

1. Two operator/admin pubkeys; non-root invites disabled.
2. Admin signs invite for one test alumni.
3. Alumni signs with supported external signer/client and publishes public note.
4. Anonymous external client reads it.
5. Alumni publishes one private NIP-29 message; member reads; anonymous/non-member/trap relay receive nothing.
6. Author deletion behaves per policy.
7. Controlled outage fires alerts.
8. Encrypted consistent backup restores entire slice on disposable host.

Private attachments, aggregation, curation, Git are not needed to prove slice.

Dependency order:

1. **Decisions/threat boundary:** name/domain, provider/region/jurisdiction, OS, Pyramid pin, data classes, backup retention.
2. **Hardened host:** two operators, SSH/VPN, firewall, time, filesystem, Caddy, service manager, secrets, base monitoring.
3. **Pyramid core:** fix permissions, disable extras/update, admin-only invites, roles, public+NIP-29, limits; privacy/protocol tests.
4. **Onboarding/NIP-05/site:** stable URL and signed admin contract first.
5. **Backup/restore/runbooks:** before cohort expansion, not pilot end.
6. **Standalone public Blossom:** roster auth, quotas, delete/report, capacity/backup; public attachments only.
7. **Private-room client hardening:** trap-relay matrix, ACL matrix, plaintext disclosure; private attachments disabled.
8. **Public aggregator:** sources, classifier, provenance, deletion, monitoring.
9. **Best-of:** admin-signed manual curation/projection.
10. **30-day pilot:** architecture freeze except fixes; full stability gates.
11. **Later:** Git/NIP-34, badges, V4V, events, E2EE, replica, custom client.

## 30-Day Pilot and Stability Gates

Pilot cadence:

- Days 1–7: 5–10 technical users; public/private text; daily review; no private attachments; tight media quota.
- Days 8–14: 20–30 users; public Blossom; deletion/quota exhaustion; sampled restore.
- Days 15–21: 40–60 users; bounded aggregation + manual curation; measure duplicate/lag/source/moderation load.
- Days 22–30: target cohort; architecture freeze except fixes; load, reboot, handover, full restore, security and compatibility work.

Public opening requires retained evidence for every item:

- 30 pilot days within defined availability/error budget; zero unresolved critical/high defects.
- Public WSS/read and private authenticated allow/deny canaries pass.
- Trap-relay leak test passes for every recommended client; failing/unknown clients excluded.
- Full restore on disposable host, measured RPO/RTO, deletion-retention proof.
- Load above expected peak: initially 500 WSS + 20 writes/s for 15 min + bounded concurrent blob pressure, revised upward if pilot demands.
- Repository-grounded threat model and security review after final topology.
- Pyramid secret-permission issue fixed and verified; no direct backend ports.
- Compatibility matrix for nos2x variants, Amber/NIP-55, iOS remote-signing path, NIP-46, Nostrord, Flotilla, and Jumble where applicable.
- Monitoring, incident, moderation, upgrade/rollback, backup/restore, deletion, and handover runbooks exercised by both operators.
- Actual 30-day disk/egress/connection/backup/restore forecast stays below $100 with contingency.

## Anti-Patterns

| Anti-pattern | Failure | Use instead |
|---|---|---|
| Enable every Pyramid feature | One process/release/data dir owns relay, files, Git, web, media | Pyramid core only; protocol-separated services |
| Call NIP-29 “encrypted/private” | Operator, backup, client misrouting exposes plaintext | Say access-controlled; trap-relay tests; audited ciphertext later |
| Blind negentropy import | DMs/groups/protected/invalid history bypass classifier | Sidecar verifier → normal relay publish |
| One hostname for everything | Header/path ambiguity and large blast radius | Flat one-protocol-owner hosts |
| Live mmap/SQLite file copy | Successful backup, corrupt restore | Quiesced/app-aware snapshot + actual restore |
| Mutable production | Update button/`latest`/manual drift ruins rollback | Pins, staged restored-state test, atomic switch |
| Public Grafana/admin/exporters | Operational/control data exposed | Operator private network; coarse external status only |
| Public plaintext private attachment | URL or server exposure leaks content | Disable; later client encryption + auth defense-in-depth |

## Unresolved Decision Gates

| Gate | Before | Required evidence |
|---|---|---|
| Final name/domain hierarchy | DNS/TLS | Brand/ownership/NIP-05/client URL test |
| VPS provider/region/jurisdiction/OS | Provisioning | Current price, abuse/legal policy, latency, snapshot/API, disk benchmark |
| Pyramid pin/fork | Core deploy | Checksum, source/release audit, migration, NIP matrix, `0600` fix |
| Admin mapping | Onboarding | Roots vs administrators, alumni/friend labels, only-admin invite proof |
| Curated implementation | Curation | Admin-only Pyramid favorites patch vs sidecar compatibility |
| Aggregator sources/backfill | Aggregation | Relay allowlist, kinds/tags, stale handling, deletions, NIP-65 behavior |
| Blossom server/backend | Media | Current audit, roster hook, quota/delete/report, local/S3 performance |
| Private attachment threat model | Any private file | Group envelope/key design, AEAD format, revocation, client support, audit |
| External status/alert channels | Pilot | Independent outage + both-operator receipt test |
| Backup retention | Real users | Published deletion window, legal/provider needs, prune proof |
| Live replica/failover | Availability expansion | Private ACL, NIP-29 migration/fork drill, cost |
| Git+GRASP | NIP-34 phase | Current NIP/client matrix, Git auth/backup/resource model |

## Confidence Assessment

| Area | Confidence | Notes |
|---|---|---|
| Boundaries/Nostr semantics | MEDIUM | Current official NIPs; many are draft/optional |
| Pyramid detail | MEDIUM | Exact v1.3.2 source/release checked; rapidly changing; executable tests pending |
| Deployment/security | MEDIUM | Official systemd/Caddy/restic patterns; exact host/provider open |
| Private attachments | MEDIUM | Spec limits clear; final group crypto/client design unresolved |
| Capacity/cost | MEDIUM | Current primary price anchors; pilot measurement required |
| Client compatibility | LOW | Not tested here; explicit matrix phase required |

Overall MEDIUM. Research seam classifies web findings MEDIUM only after official-source cross-checking. Treat client routing, private attachment design, and snapshot consistency as unvalidated until pilot gates pass.

## Primary Sources

- [Pyramid repo](https://github.com/fiatjaf/pyramid), [v1.3.2](https://github.com/fiatjaf/pyramid/releases/tag/v1.3.2), [secret setting](https://github.com/fiatjaf/pyramid/blob/v1.3.2/global/settings.go#L57-L63), [mmap layers](https://github.com/fiatjaf/pyramid/blob/v1.3.2/global/global.go#L24-L90), [private query filter](https://github.com/fiatjaf/pyramid/blob/v1.3.2/groups/queries.go#L63-L97), [raw sync target](https://github.com/fiatjaf/pyramid/blob/v1.3.2/sync.go#L55-L80)
- Nostr: [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md), [05](https://github.com/nostr-protocol/nips/blob/master/05.md), [09](https://github.com/nostr-protocol/nips/blob/master/09.md), [17](https://github.com/nostr-protocol/nips/blob/master/17.md), [29](https://github.com/nostr-protocol/nips/blob/master/29.md), [34](https://github.com/nostr-protocol/nips/blob/master/34.md), [42](https://github.com/nostr-protocol/nips/blob/master/42.md), [44](https://github.com/nostr-protocol/nips/blob/master/44.md), [59](https://github.com/nostr-protocol/nips/blob/master/59.md), [65](https://github.com/nostr-protocol/nips/blob/master/65.md), [70](https://github.com/nostr-protocol/nips/blob/master/70.md), [86](https://github.com/nostr-protocol/nips/blob/master/86.md)
- [Blossom protocol](https://github.com/hzrd149/blossom), [standalone server](https://github.com/hzrd149/blossom-server)
- [Caddy reverse proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy), [metrics](https://caddyserver.com/docs/metrics), [systemd credentials](https://systemd.io/CREDENTIALS/)
- [restic docs](https://restic.readthedocs.io/en/stable/), [design](https://github.com/restic/restic/blob/master/doc/design.rst)
- [node_exporter](https://prometheus.io/docs/guides/node-exporter/), [blackbox](https://github.com/prometheus/blackbox_exporter), [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/), [Loki](https://grafana.com/docs/loki/latest/)
- Current cost anchors: [Akamai](https://www.akamai.com/cloud/pricing), [Backblaze B2](https://www.backblaze.com/cloud-storage/pricing)

---
*Architecture research for modular Sovereign Engineering Nostr community infrastructure*
*Researched: 2026-07-30*
