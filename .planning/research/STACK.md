# Technology Stack

**Project:** Sovereign NIP-29 Alumni Relay
**Researched:** 2026-07-30
**Mode:** Ecosystem research
**Overall confidence:** MEDIUM — primary repositories, current tags, official protocol specifications, and source inspection agree; Pyramid is young and changing quickly, and several client combinations still require live interoperability tests.

## Executive Recommendation

Deploy the current **`fiatjaf/pyramid` v1.3.2** release as a native, checksum-verified binary under `systemd` on **Debian 13.6**, bound to loopback behind **Caddy v2.11.4**. Let Pyramid own relay membership, NIP-29 groups, its browser administration surface, NIP-05, embedded search, and its native path-scoped subrelays. Do not add PostgreSQL: Pyramid's supported persistence model is its `mmm` memory-mapped event store plus an append-only management journal and embedded Bleve indexes.

Use **rootless Podman only for independently replaceable companion services**, not for Pyramid itself. Add a separate Blossom server only after its missing membership/quota policy is implemented and acceptance-tested. Build public member-content aggregation as a small custom worker in a later phase; Pyramid's favorites/popular/Negentropy features are not a complete federation or deletion-propagation system.

The stack is deliberately small. A 4-vCPU, 8-GB RAM, 160-GB NVMe VPS is ample for the first 100 members while leaving headroom for memory-mapped indexes and search. Prometheus plus exporters is enough for two operators; Grafana, Loki, Kubernetes, Redis, Kafka, Elasticsearch, and a database server add cost and failure modes without solving a launch requirement.

## Resolve the Pyramid Naming Ambiguity First

| Candidate | Status on 2026-07-30 | Decision |
|---|---|---|
| [`fiatjaf/pyramid`](https://github.com/fiatjaf/pyramid) | Current canonical project; live tag `v1.3.2` at commit `e12e81641bfe6cacc6dd246e9433d602c1240e66`, dated 2026-07-29; active source and modern group implementation | **Use this** |
| [`github-tijlxyz/khatru-pyramid`](https://github.com/github-tijlxyz/khatru-pyramid) | Older invitation-tree proof/project; latest tag `v0.3.0` from 2025-03-24 | **Do not deploy**; treat as legacy/superseded |

The deployment repository, package pins, runbooks, and source links must always say **`fiatjaf/pyramid`**, not merely "Pyramid." This prevents automation from silently selecting the obsolete repository. [Confidence: HIGH for repository identity; MEDIUM overall because the project has no formal long-term-support declaration.]

## Recommended Stack

### Core Relay and Host

| Technology | Version / pin | Purpose | Why |
|---|---:|---|---|
| Debian | **13.6 `trixie`**, amd64 | Host OS | Current stable Debian point release; conservative security maintenance, native `systemd`, nftables, and unattended security updates |
| Pyramid | **v1.3.2**, commit `e12e81641bfe6cacc6dd246e9433d602c1240e66` | Main Nostr relay, membership, NIP-29 groups, admin UI, NIP-05, search, subrelays | Only current canonical Pyramid; directly implements the community topology and avoids stitching together several relay products |
| Caddy | **v2.11.4** | TLS, HTTP/2/3, WebSocket reverse proxy, request/access logging | Automatic certificate management and reliable WebSocket proxying; gives one ingress and keeps Pyramid's application socket private |
| systemd | Debian 13 supplied | Service lifecycle, credentials, resource limits, timers | Native dependency ordering, restart policy, journal integration, sandboxing, and no container daemon |
| nftables | Debian 13 supplied | Host firewall | Expose only SSH, 80, and 443; all application/metrics ports remain loopback or private-admin-network only |

### Persistence, Search, and Backup

| Technology | Version / pin | Purpose | Why |
|---|---:|---|---|
| Pyramid `mmm` eventstore | Bundled with Pyramid v1.3.2 | Event persistence and isolated relay indexes | This is Pyramid's native data model. Multiple logical layers share deduplicated event data in memory-mapped storage |
| Bleve | **v2.4.4**, bundled | NIP-50 main and per-group full-text indexes | Embedded; avoids a separate search service and its operational burden |
| Restic | **v0.19.1** | Encrypted offsite backups and retention | Mature, signed release; works with S3-compatible object storage and supports integrity checks and restore drills |
| Independent S3-compatible bucket | Provider-managed | Offsite backup target | Separates host loss from backup loss. Use a different provider/account boundary from the VPS where practical |

### Media and Optional Companion Services

| Technology | Version / pin | Purpose | When to use |
|---|---:|---|---|
| [`hzrd149/blossom-server`](https://github.com/hzrd149/blossom-server) | **v6.2.0**, commit `bff3acbcdbcf9c9da3fea3538cd4dadd2ce646b3` | Separate Blossom/BUD media service, reports, retention rules, local or S3 storage | Recommended target after a thin Pyramid-membership and per-user-quota policy integration exists |
| Pyramid native Blossom | Bundled v1.3.2 | Membership-aware uploads and aggregate member quotas | Acceptable **temporary launch option for public assets only** if hard quotas are required before the separate policy layer is ready |
| [`v0l/route96`](https://github.com/v0l/route96) | **v0.7.0**, commit `ee1636b1e5d9036614278b176e54b09e2b5dd9c0` | Richer Blossom/NIP-96 moderation, whitelist, retention, processing, quotas | Consider only if true per-user quota/admin workflows justify MariaDB and a pre-1.0 service; not the default |
| Rootless Podman | **5.4.2** from Debian 13 | Isolation for companion services | Use Quadlet/systemd units for Blossom or monitoring; do not introduce Docker Compose as the production control plane |

### Observability

| Technology | Version / pin | Purpose | Why |
|---|---:|---|---|
| journald | Debian 13 supplied | Primary service logs | Pyramid already writes stdout and a rotating local log; journald gives bounded persistence and operator access without a log stack |
| Prometheus | **v3.13.1 LTS** | Local metrics and alert evaluation | Current LTS bugfix release; low operational cost at single-host scale |
| node_exporter | **v1.12.1** | Host CPU, memory, disk, filesystem, network metrics | Essential for detecting mmap/storage pressure and capacity trends |
| blackbox_exporter | **v0.28.0** | HTTPS and WebSocket-adjacent endpoint probes | Pyramid has no verified native readiness or Prometheus endpoint; probe the real public surface |
| Alertmanager | **v0.33.1** | Email/webhook alert delivery | Separates alert evaluation from routing and deduplication |
| External uptime probe | Provider-managed, independent | Outside-in reachability | Detects DNS, certificate, routing, VPS, and Caddy failures that same-host monitoring cannot see |

Do not deploy Grafana or Loki at launch. Prometheus' own UI plus alert rules is sufficient for two technical operators; add Grafana only after a dashboard use case appears. Keep Caddy JSON access logs short-lived and minimize or hash client IPs where operationally feasible.

## What Pyramid v1.3.2 Actually Is

Pyramid is one Go process built on the current `fiatjaf.com/nostr` relay stack (Khatru functionality is now part of that module). Its v1.3.2 module declares Go 1.26.2. A downloaded release binary does not need Go or Node on the VPS; those toolchains belong only in a reproducible build environment.

```text
Internet clients
      |
      | HTTPS / WSS :443
      v
    Caddy
      |
      +--> 127.0.0.1:3334  Pyramid
      |                       |
      |                       +-- mmm event layers
      |                       +-- management.jsonl
      |                       +-- settings.json
      |                       +-- Bleve search indexes
      |                       +-- optional blossom-files/
      |
      +--> 127.0.0.1:3001  Blossom companion (later)
      |
      +--> static client assets (optional Flotilla/Jumble build)

Local/private operations plane
      +-- systemd + journald
      +-- Prometheus/exporters/Alertmanager
      +-- restic timer --> independent object storage
```

### Native Data Model

Pyramid creates multiple logical eventstore layers within its data directory, including system, main, internal, invites, pending access, personal, favorites, popular, uppermost, inbox, secret, moderation queue, moderated, scheduled, Blossom metadata, operator events, and deleted-group archives. The layers isolate queries and policy while `mmm` deduplicates the underlying event data.

Other state is equally important:

- `settings.json`: operator settings plus Pyramid's internal relay signing key.
- `management.jsonl`: append-only replay journal for membership, invite, role, drop/leave, and disable actions.
- `search/`: Bleve indexes for main relay and groups; rebuildable but operationally useful.
- `blossom-files/`: native media blobs if enabled.
- `log` and rotations: Pyramid's own file logs in addition to stdout.
- optional SFTP host key and downloaded LiveKit binary if those risky/optional features are enabled.

There is no supported PostgreSQL schema to migrate. Backing up only "the database file" is insufficient; the settings, management journal, event layers, and media state form the recoverable service.

### Feature Ownership Matrix

| Requirement | Pyramid native | Configuration needed | Separate/custom work | Decision |
|---|---|---|---|---|
| Nostr signature verification | Yes, underlying relay stack | None beyond normal limits | Acceptance-test invalid signatures and malformed frames | Native |
| Relay authentication | NIP-42 challenge/auth and NIP-98-style web login | Require auth on private paths; test proxy headers/origin | Client-signer compatibility tests | Native + config |
| Community membership | NIP-43 hierarchical join/invite/leave actions; root ancestors; descendant drop/disable rules | Seed two root administrators; set invite limits | A flat, admins-only invitation policy is **not** the natural hierarchy model and may require policy code | Native with policy gap |
| Roles (`alumni`, `friend`, `admin`) | Arbitrary display roles can be created/assigned by roots | Define labels and operator process | Pyramid roles do not create arbitrary permissions. `friend` visibility or admins-only invites needs separate authorization logic | Config + possible custom work |
| NIP-29 groups | Create/edit/delete groups, invitations, membership, admin/moderator actions, pins, supported kinds, hidden/private/closed/restricted state | Define default group policy and group-admin roster | Live backup/replica and migration exercises | Native |
| Private groups | Read filters enforced for authenticated members | Private groups must also be closed; use hidden where discovery must be limited | E2EE is outside Pyramid; clients must encrypt sensitive content | Native access control, not confidentiality from operator |
| Public/member-only feeds | Root main path is public-readable/member-writable; `/internal` is member-read/write | Set stable paths and NIP-11 metadata | None for basic feeds | Native |
| Bookmarks/personal data | `/bookmarks`, `/personal`, and visibility controls | Choose public/member/disabled modes | Privacy acceptance tests; operator remains capable of storage access | Native |
| Moderation | Root admin UI/API, pubkey/event/IP bans, queue/moderated path, group admin/moderator actions | Written escalation/audit process and two-person operator discipline | Exportable moderation audit/reporting if required | Native + operations |
| NIP-86 administration | Subset exposed by the relay stack and browser UI | Bind admin surface through standard relay endpoint; never expose extra local ports | Test each required standard admin method; do not assume full NIP-86 coverage | Native, verify exact subset |
| NIP-05 | `/.well-known/nostr.json` and member username claims | Enable domain mapping and preserve CORS through Caddy | None | Native |
| NIP-50 search | Embedded Bleve for a defined set of text/profile kinds plus per-group search | Pick languages; provision rebuild time | Does not index every supported event kind | Native with scope limit |
| Negentropy | Manual per-user NIP-77 synchronization of that user's authored events | Operator/user-driven | Not scheduled full-member federation | Native utility only |
| Public member aggregation | Favorites/popular/uppermost/inbox provide curation/discovery | These can supplement UX | Full allowlisted aggregation, source provenance, retries, moderation and deletion propagation need a custom worker | Custom phase |
| Deletions | Main relay uses standard deletion handling; group delete-event and group archive/wipe flows exist | Publish deletion/retention policy | Validate NIP-09 semantics, old group-message rules, tombstones, external-source deletion propagation, backups and search removal | Native core + custom/ops gaps |
| Blossom media | Native membership upload/quota implementation available | Public-only asset policy, file caps, MIME policy | Preferred separate service needs membership/quota bridge; private media needs client-side encryption or a new delivery design | Separate phase |
| Backups/upgrades | No complete built-in production workflow | Disable auto-update; systemd timers/runbooks | Restic, quiesced snapshots, restore tests, staged release validation | Separate operations stack |
| Metrics/readiness | Operator UI/stats and structured logs | Log levels/retention | Prometheus exporters and blackbox health checks | Separate operations stack |

## Protocol and Event Support

### Core Protocol Position

Pyramid v1.3.2 explicitly enables or conditionally advertises NIP-43 membership, NIP-29 groups, NIP-50 search, NIP-16 scheduling, and NIP-63 paywall behavior. It relies on the underlying relay stack for basic WebSocket flow, signature checking, authentication, count/subscriptions, deletion, and relay management. Do **not** publish a hand-written `supported_nips` list from this research: fetch the deployed NIP-11 document and compare it with an executable acceptance matrix, because underlying defaults move with Pyramid's pinned dependency.

The main relay allowlist in v1.3.2 includes the expected social set—profiles, short notes, deletions, reposts, reactions, chats, comments, long-form content, relay/user lists, bookmarks, follows, zaps, calendars/live events, app data, and multiple newer content kinds. NIP-29 group events are handled by the group layer instead of merely passing through the main allowlist. The two NIP-43 membership request kinds required for join/leave are admitted independently of the normal kind list.

### NIP-29 Semantics That Affect Product Design

- NIP-29 is still marked **draft** and **optional**. The relay is authoritative for membership rules and signs group metadata/admin/member state with its relay key.
- Group content uses an `h` tag. Pyramid supports group creation, metadata changes, invite codes, put/remove user, delete-event, delete-group, pins, fixed `admin`/`moderator` behavior, and per-group supported kinds.
- `private` limits reads to members; `restricted` limits writes; `hidden` limits discovery; `closed` prevents ordinary join. These flags are independent in the protocol. Pyramid requires private groups to be closed, which is a sensible default.
- Private means **relay-enforced access**, not end-to-end encryption. The relay operator and anyone who obtains plaintext storage/backups can read it. Clients can also leak group events to another relay. State this plainly in onboarding.
- NIP-29 itself recommends a live second-relay replica for history resilience. Pyramid does not turn that recommendation into an operator-ready replication service.
- Current Pyramid group deletion is nuanced: a deleted group is soft-archived to a root-only layer until a root explicitly wipes it. Generic author deletion of a group message is time-bounded in Pyramid's group handler. This must be reconciled with the project's promise to honor signed deletions.

### Search Scope

Pyramid's main Bleve index covers a configured subset of text-bearing kinds, including profiles, text/reposts, group/chat/comment-like content, media and long-form kinds. It is not a universal index over every allowed kind. Reindexing is a privileged streaming rebuild that deletes and recreates the index. Capacity planning must therefore reserve enough disk and maintenance time for a full rebuild without deleting authoritative event storage.

### Replication and Aggregation Boundary

Native mechanisms have narrower purposes:

- `/favorites`: members explicitly republish chosen external events.
- `/popular` and `/uppermost`: ingest external events that cross member-interaction thresholds.
- `/inbox`: discovery/safe-inbox behavior driven by relationship and moderation policy.
- NIP-77 UI: manual reconciliation for events authored by the logged-in member.

None is a deterministic, scheduled import of every member's public events from declared external relays. The later aggregation worker should:

1. read an allowlisted member/public-key roster and allowed source relays;
2. fetch only public event kinds within bounded windows;
3. preserve source relay and ingestion timestamps outside signed event content;
4. deduplicate by event ID and enforce signature/time/size/kind policy;
5. exclude NIP-29 group events, private/control events, auth events, and secrets;
6. ingest deletion requests/tombstones before or with content and remove derived search/media references;
7. apply moderation before publication to the public aggregate;
8. maintain retry/dead-letter state and observable lag.

Use the same Go Nostr module pinned by Pyramid, or a tightly pinned `nak`/SDK integration, to reduce semantic drift. Do not scrape clients or copy events while rewriting signatures.

## Membership and Authorization Recommendation

Seed exactly two root administrator pubkeys and store neither private key on the VPS. Root access is operational authority, not a shared server credential. Require both admins to have tested recovery paths and use separate signer devices.

Pyramid's membership hierarchy is valuable for alumni referrals, but it does not exactly equal a flat allowlist with three arbitrary authorization roles:

- roots/admins can invite and govern descendants;
- non-root members may receive invite capacity based on global/depth settings;
- ancestors can drop descendants; single-root ancestry affects disable behavior;
- display roles are assigned separately and do not automatically change those capabilities.

Therefore launch with **root-admin invitations only** by configuring all non-root invite allowances to zero if the UI permits that exact policy. If v1.3.2 cannot express it cleanly, do not encode permissions in role labels; add a small reviewed policy patch or operator-mediated join workflow. Treat `alumni` and `friend` as descriptive roles until an explicit authorization matrix exists.

## Blossom Decision

No currently verified, minimal off-the-shelf service satisfies all four requirements simultaneously: dynamic Pyramid membership, per-user total-byte quotas, authenticated private downloads, and a clean separate storage boundary.

### Preferred End State: Separate `blossom-server` v6.2.0

Use `hzrd149/blossom-server` because it is narrowly scoped, MIT-licensed, supports the core Blossom BUD set, local or S3 storage, reports, retention rules, and an admin dashboard. Put it on `media.<domain>` behind Caddy and run it as a rootless Podman Quadlet.

Before production, add a thin policy integration that exports Pyramid's active membership to the Blossom upload allowlist and enforces per-pubkey aggregate bytes. The upstream server's static pubkey rules and per-request size limits are not the same as total quotas, and config changes require a controlled reload/restart. That gap is a roadmap item, not a configuration detail.

### Temporary Launch Option: Pyramid Native Blossom

Native Blossom already knows Pyramid membership and provides per-member aggregate quotas, including hierarchy-depth overrides. It stores blobs under Pyramid's data directory and serves them publicly. Use it only for public profile/group assets with strict MIME and size limits; do not present it as private attachment storage. Keep the optional Blossom SFTP feature disabled and its port closed—it expands the attack surface and bypasses normal application workflows.

### Why Not Route96 by Default

Route96 offers stronger media moderation and quota features, but it brings MariaDB, local media processing, more state, and pre-1.0 upgrade risk. For 100 users and two operators, that operational cost is unjustified unless hard quota/report requirements cannot be met by the thin companion policy.

## Signer Compatibility

The relay never needs member private keys. It validates signed events and NIP-42 authentication events regardless of which compliant signer created them. Compatibility is chiefly a client concern.

| Signer | Platform / protocol | Recommendation | Caveat |
|---|---|---|---|
| [`fiatjaf/nos2x`](https://github.com/fiatjaf/nos2x) | Chromium browser extension; NIP-07 `window.nostr`, NIP-04/44 methods | Default desktop-browser pilot | Extension storage and permission prompts remain endpoint risks; verify release provenance |
| [`diegogurpegui/nos2x-fox`](https://github.com/diegogurpegui/nos2x-fox) | Firefox NIP-07 extension | Firefox pilot | Test every target web client; do not assume Chromium/Firefox parity |
| [`greenart7c3/Amber`](https://github.com/greenart7c3/Amber) | Android NIP-55 application signer and NIP-46 remote signer | Recommended Android signer pilot; verify signed release manifest/APK | NIP-55 requires client integration; NIP-46 needs compatible communication-relay setup |
| [`nostr-connect/nostrum`](https://github.com/nostr-connect/nostrum) | iOS/Android NIP-46 reference app | Experimental iOS pilot only | Alpha/TestFlight-oriented, 42-commit reference project, no evidence for production support maturity |

Nostrord explicitly supports NIP-07 and NIP-46. Flotilla exposes signer-relay configuration and current mobile work, but each build must be tested. Jumble's web and Electron variants have different key-storage boundaries. Never recommend pasting an `nsec` into a web client when a NIP-07/NIP-46 flow is available.

## Client Compatibility

| Client | Best role | Current evidence | Recommendation |
|---|---|---|---|
| [`nostrord/nostrord`](https://github.com/nostrord/nostrord) / [nostrord.com](https://nostrord.com/) | Focused NIP-29 group chat and administration | Explicitly lists Pyramid compatibility, NIP-29 group create/invite/join/admin flows, media, NIP-07 and NIP-46; web, Android and desktop, with iOS still in development | **Primary launch pilot** for group workflows |
| [Flotilla](https://gitea.coracle.social/coracle/flotilla) | Discord-like relay/community UI | Active canonical Gitea repository as of 2026-07-21; platform mode, Blossom and signer-relay configuration; current Pyramid code suppresses NIP-77 advertisement for Flotilla/aiohttp because of a group compatibility issue | **Secondary pilot**, pinned build only; remove upstream analytics script in self-hosted build |
| [`CodyTseng/jumble`](https://github.com/CodyTseng/jumble) | Public relay feed exploration and a community-preset feed | Active, MIT, web/Electron, configurable community relay sets; not evidenced as the strongest NIP-29 admin surface | Offer for public/member feed use, not primary group administration |

Before onboarding 100 members, run a release-pinned matrix across Nostrord, Flotilla, and Jumble for:

- NIP-42 challenge and reconnect;
- main public read/member write and `/internal` member-only behavior;
- group discovery, open/closed invite, hidden/private read filtering, admin/moderator actions, pins, deletion, and long-form kinds;
- NIP-50 search and result shapes;
- Blossom upload/render/delete behavior;
- nos2x, nos2x-fox, Amber NIP-55/NIP-46, and experimental iOS NIP-46;
- offline/reconnect, relay error messages, duplicate events, and rejected writes.

Do not self-host all three clients at launch. A static, pinned Flotilla or Jumble build adds little server load, but every hosted client becomes another release/security surface. Prefer upstream clients unless custom relay defaults materially improve onboarding.

## Deployment and Security Baseline

### Host and Service Layout

- VPS: 4 shared/dedicated vCPU, 8 GB RAM, 160 GB NVMe, IPv4/IPv6. Provider snapshots may supplement, but never substitute for, application-consistent offsite backups.
- Dedicated `pyramid` system user, no shell, data directory `0700`.
- Pyramid release binary in versioned `/opt/pyramid/v1.3.2/`; stable symlink switched only after preflight.
- `DATA_PATH` on local NVMe; do not put `mmm` on NFS/FUSE/object mounts.
- Pyramid bound to `127.0.0.1:3334`; Caddy owns 80/443. Set `NO_AUTO_UPDATES=true`.
- `settings.json` contains an internal relay secret key. Pyramid currently creates/saves settings with permissive source-level mode behavior, so explicitly enforce directory `0700` and file `0600` after creation and in a recurring permission check.
- No member `nsec`, bunker URI, signer token, Restic password, API token, or private key in Git, environment dump, logs, or support output. Use root-readable systemd credentials/files.
- SSH keys only; disable password/root login; allow admin ingress by private mesh or limited source addresses where available.
- nftables default-deny inbound; expose 22 (restricted), 80, and 443 only. Never publish Pyramid's optional SFTP port, Prometheus, exporters, or Caddy admin API.
- Apply systemd hardening after confirming mmap/write needs: `NoNewPrivileges`, private temp, protected home/system, explicit writable data path, bounded file descriptors/processes, and sensible memory/CPU limits.

### Caddy Responsibilities

Caddy terminates TLS and proxies ordinary HTTP plus WebSockets without path rewriting. It must preserve the host and scheme Pyramid uses for NIP-11/NIP-98 validation. Configure request-body ceilings and timeouts that permit WebSocket sessions but reject oversized HTTP uploads before application parsing. Route `/.well-known/nostr.json` and `/.well-known/nip29/*` unchanged. Do not enable Pyramid's built-in autocert/TLS behind Caddy.

Use separate hostnames for the relay and media service, such as `relay.example.org` and `media.example.org`. This makes media replacement, caching, quotas, and incident isolation possible without changing the relay identity.

### Release Installation Pattern

Do not run upstream `easy.sh` in production. It downloads "latest," edits the firewall, selects ports, and creates service state with operator-context assumptions. Instead:

1. declare exact release URL, tag, commit and SHA-256 in the deployment repository;
2. verify checksum/signature provenance in CI or an isolated staging host;
3. install to a versioned immutable directory;
4. run a disposable-data startup and NIP/client smoke test;
5. quiesce and snapshot live data;
6. switch the symlink and restart under systemd;
7. run public acceptance probes; roll back binary/config if storage remains compatible;
8. restore from backup in staging when a release changes storage or management replay semantics.

Pin container companions by immutable image digest, not `latest`. If upstream has no trustworthy multi-arch image provenance, build from a signed tag in CI and record the resulting digest/SBOM.

## Backup, Restore, Deletion, and Upgrade Policy

### Backup Set

Back up Pyramid's complete data directory, versioned deployment configuration, Caddy configuration, systemd units, Blossom database/blob state, and encrypted secret material required to restore service identity. Bleve indexes may be excluded only if a tested reindex procedure and time budget exist.

Online consistency of the memory-mapped store is not documented strongly enough to trust a naïve file copy. Until an upstream-supported snapshot method is verified, use a short maintenance window: stop/quiesce Pyramid, take a same-filesystem copy or snapshot, restart, then have Restic upload the snapshot. Measure the pause in staging.

For content-bearing Pyramid/media snapshots, use 14 daily plus 4 weekly generations and enforce a maximum age of 30 days; run `restic check` monthly and a full isolated restore quarterly. Keep longer, separately scoped backups only for deployment configuration and non-content audit metadata. If the community promises another deletion maximum, backup retention and object-lock settings must match it exactly. Do not advertise 30-day erasure while retaining six-month plaintext snapshots.

### Deletion Contract

NIP-09 is a deletion **request**, and relays have discretion, but this project's product promise is stronger. Define "honor" as:

- validate that deletion is authorized by the same pubkey/address semantics;
- stop returning the event from every public/member/group query;
- remove it from Bleve and derived aggregate views;
- delete unreferenced owned Blossom blobs when requested;
- store a minimal tombstone so federation does not re-import the event;
- propagate or observe upstream deletion requests in the aggregation worker;
- expire plaintext from backup generations within the published retention window.

Pyramid's group archive and two-hour generic group-message deletion rule must be tested against that contract. If it fails, patch policy before promising universal deletion behavior.

### Upgrades

Pyramid v1.3.2 shipped one day before this research date. That is strong evidence of activity and weak evidence of stability. Disable its automatic self-update. Use a staging data copy, pinned clients, schema/replay tests, backup/restore gate, and one-week canary/observation window for every minor Pyramid release. Security fixes can shorten the window, not remove the tests.

## Operations and Observability

Pyramid uses zerolog-style output and also rotates a local file around 10 MB with a small backup count and time window. Treat journald as canonical operations output and avoid double-retaining verbose payload logs. Redact authorization headers, invite codes, signer-connect URIs, and event content where possible.

Pyramid does not expose a verified `/metrics` or explicit readiness endpoint. Monitor at four levels:

1. **Host:** free disk/inodes, memory and swap, mmap/file descriptors, CPU steal, network, clock sync, filesystem errors.
2. **Process:** systemd active/restarts, resident memory, open files, log error rate, data-directory growth.
3. **Protocol:** HTTPS NIP-11 fetch, WebSocket handshake, read subscription/EOSE, test-member authenticated write/read/delete on a synthetic kind/group.
4. **Outside-in:** DNS, TLS expiry/chain, HTTP/WSS reachability, latency from an independent provider.

Alert on disk above 70/85%, inode pressure, sustained memory above 75%, repeated restart, certificate expiry, failed backup/check, stale successful backup, search rebuild failure, aggregation lag, public protocol smoke failure, and membership/admin journal errors. Do not expose Prometheus publicly; bind it to loopback/private admin access.

## Cost Envelope

| Item | Expected monthly range | Notes |
|---|---:|---|
| 4-vCPU / 8-GB / 160-GB VPS | $25–50 | Provider/region dependent; prioritize NVMe and backup network reliability |
| Independent S3-compatible backups | $2–10 | Depends on media and retention; set lifecycle rules |
| External uptime/alert delivery | $0–10 | Free tier is often adequate; independence matters more than feature count |
| Domain/DNS amortized | $1–3 | Use DNSSEC where supported; registrar lock and two-admin recovery |
| Growth reserve | $20–40 | Leaves room under the $100 ceiling for larger disk, media egress, or replica experiments |

The launch stack should fit around **$30–70/month**. If media growth or egress approaches the ceiling, move Blossom objects to S3-compatible storage before resizing the relay host. Do not prematurely split Pyramid's memory-mapped store across nodes.

## Alternatives Considered

| Category | Recommended | Alternative | Why not now |
|---|---|---|---|
| Relay | fiatjaf/Pyramid v1.3.2 | Generic Khatru/strfry/nostr-rs-relay | Would require rebuilding Pyramid's membership, path subrelays, admin and NIP-29 behavior |
| Service packaging | Native Pyramid + systemd | Docker/Podman container for Pyramid | Native release is simpler and avoids volume/UID/mmap ambiguity; companions may use rootless Podman |
| Reverse proxy | Caddy v2.11.4 | Pyramid built-in autocert | Central ingress is easier to harden, observe, and extend to media/static clients |
| Database | Native mmm | PostgreSQL | Not Pyramid's supported data model; adds migrations and operational work without benefit |
| Search | Embedded Bleve | Elasticsearch/OpenSearch/Meilisearch | Far too heavy for 100 users; creates synchronization and privacy surfaces |
| Media | blossom-server + policy bridge | Native Blossom | Separate lifecycle and storage are better long term; native remains a public-only temporary option |
| Media rich stack | blossom-server + bridge | Route96 | Route96 is capable but MariaDB/pre-1.0 complexity exceeds launch needs |
| Monitoring | Prometheus/exporters/Alertmanager | Grafana + Loki stack | Dashboards/log aggregation are not necessary for two operators at launch |
| Orchestration | systemd/Quadlet | Kubernetes | No high-availability database or multi-node workload justifies it |
| Federation | Small explicit worker | Relay mirroring everything | Safe aggregation needs policy, provenance, tombstones and exclusion rules, not indiscriminate copying |

## Explicitly Avoid

- `github-tijlxyz/khatru-pyramid` and any documentation pointing to it.
- mutable `latest` images/releases or Pyramid's automatic update path.
- running upstream `easy.sh` on the production host.
- putting member private keys, root admin keys, bunker URIs, signer tokens, or invite codes on the server/in Git.
- describing NIP-29 `private` as end-to-end encrypted.
- exposing native Blossom SFTP, Prometheus, exporters, Caddy admin, or Pyramid loopback ports to the Internet.
- treating display roles as enforceable authorization roles.
- claiming favorites/popular/manual Negentropy is full federation.
- online file-copy backups of live mmap storage without a verified consistency procedure.
- permanent retention that makes the deletion promise false.
- self-hosting every client, adding Grafana/Loki, or introducing Kubernetes before measured need.

## Required Phase-Specific Research and Acceptance Gates

| Phase | Gate before proceeding |
|---|---|
| Pyramid foundation | Build a pinned v1.3.2 staging instance; capture NIP-11; validate all paths, supported kinds, NIP-42, limits, restart/replay, file permissions, and a clean restore |
| Membership/governance | Prove admins-only invitations, root recovery, multi-parent/descendant rules, role limitations, and complete management journal replay |
| NIP-29 groups | Run public/restricted/private/hidden/closed cases across three clients; validate moderation, pins, group archive/wipe, author deletion and operator visibility |
| Media | Decide native temporary vs separate Blossom; prove membership sync, per-user quota, report/delete flow, MIME caps, unreferenced cleanup and encrypted-private-media story |
| Aggregation | Write provenance/tombstone threat model; test duplicate events, forged timestamps/signatures, relay outage, source deletion, moderation and exclusion of group/private kinds |
| Operations | Measure quiesced backup pause, restore time, reindex time, disk growth, upgrade rollback, external WSS probe and two-admin incident handoff |

## Confidence Assessment

| Area | Confidence | Basis / remaining uncertainty |
|---|---|---|
| Canonical Pyramid and current pin | HIGH | Live Git tags plus current repository/source inspection; no ambiguity after resolving legacy repo |
| Pyramid architecture and native features | MEDIUM | Direct v1.3.2 source inspection; fast-moving code and sparse formal release/operations documentation |
| NIP-29 semantics | HIGH for protocol, MEDIUM for Pyramid edge behavior | Official NIP plus implementation source; client and deletion edge cases need executable tests |
| Host/proxy/backup/monitoring stack | HIGH | Current signed upstream releases and standard single-host production patterns |
| Blossom choice | MEDIUM | Repositories and source verify capabilities; no candidate meets dynamic membership + aggregate quota + private delivery without integration |
| Signer compatibility | MEDIUM | Official signer/client claims; full pairwise live tests not run |
| Client compatibility | MEDIUM | Current official sites/repos; Nostrord explicitly claims Pyramid support, while Flotilla workaround and Jumble group scope require validation |
| Cost/capacity | MEDIUM | Conservative estimate, but real event/media volume and mmap behavior are not measured |

## Sources

Primary sources checked on 2026-07-30:

- [Current Pyramid repository](https://github.com/fiatjaf/pyramid) and [v1.3.2 source tree](https://github.com/fiatjaf/pyramid/tree/v1.3.2) — tag, source, license, storage, paths, configuration, Docker/easy-install behavior. [Confidence: MEDIUM after cross-check]
- [Legacy khatru-pyramid repository](https://github.com/github-tijlxyz/khatru-pyramid) — disambiguation only. [Confidence: MEDIUM]
- [Official NIP-29 specification](https://github.com/nostr-protocol/nips/blob/master/29.md) — group authority, events, privacy flags, moderation, migration/replica model. [Confidence: MEDIUM after cross-check]
- [Official NIP-43 specification](https://github.com/nostr-protocol/nips/blob/master/43.md) — relay access and membership request metadata. [Confidence: MEDIUM]
- [Official NIP-42 specification](https://github.com/nostr-protocol/nips/blob/master/42.md) — relay authentication. [Confidence: MEDIUM]
- [Official NIP-09 specification](https://github.com/nostr-protocol/nips/blob/master/09.md) — deletion-request semantics. [Confidence: MEDIUM]
- [Official NIP-50 specification](https://github.com/nostr-protocol/nips/blob/master/50.md) and [NIP-77](https://github.com/nostr-protocol/nips/blob/master/77.md) — search and Negentropy. [Confidence: MEDIUM]
- [Debian releases](https://www.debian.org/releases/) — current stable OS line. [Confidence: MEDIUM after cross-check]
- [Caddy v2.11.4](https://github.com/caddyserver/caddy/releases/tag/v2.11.4) — current reverse-proxy release. [Confidence: MEDIUM]
- [Restic v0.19.1](https://github.com/restic/restic/releases/tag/v0.19.1) — current signed backup release. [Confidence: MEDIUM]
- [Prometheus v3.13.1](https://github.com/prometheus/prometheus/releases/tag/v3.13.1), [node_exporter v1.12.1](https://github.com/prometheus/node_exporter/releases/tag/v1.12.1), [blackbox_exporter v0.28.0](https://github.com/prometheus/blackbox_exporter/releases/tag/v0.28.0), and [Alertmanager v0.33.1](https://github.com/prometheus/alertmanager/releases/tag/v0.33.1). [Confidence: MEDIUM]
- [`hzrd149/blossom-server`](https://github.com/hzrd149/blossom-server) and [`v0l/route96`](https://github.com/v0l/route96) — media alternatives and operational tradeoffs. [Confidence: MEDIUM after source cross-check]
- [Nostrord product/compatibility documentation](https://nostrord.com/) and [source repository](https://github.com/nostrord/nostrord). [Confidence: MEDIUM]
- [Flotilla canonical repository](https://gitea.coracle.social/coracle/flotilla) and [Jumble repository](https://github.com/CodyTseng/jumble). [Confidence: MEDIUM]
- [nos2x](https://github.com/fiatjaf/nos2x), [nos2x-fox](https://github.com/diegogurpegui/nos2x-fox), [Amber](https://github.com/greenart7c3/Amber), and [Nostrum](https://github.com/nostr-connect/nostrum). [Confidence: MEDIUM]

All `websearch` findings were classified by the GSD confidence seam as **MEDIUM**, including cross-checked findings. No low-confidence claim is used as an authoritative production recommendation.
