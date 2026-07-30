# Service Boundaries and Nostr-Logic Count

**Project:** Sovereign Engineering Nostr Community Infrastructure  
**Researched:** 2026-07-30  
**Question:** How many services does the recommended system actually contain?  
**Confidence:** MEDIUM — boundaries are strong; Pyramid, Blossom, and Kehto remain fast-moving and require pin-level acceptance tests.

## Short Answer

Recommended v1 has **7 project-managed always-on processes**, **11 project-managed systemd units**, **3 locally served public origins plus one external status origin**, **3 runtime-writable persistent stores**, and **2 Nostr-aware server processes**. Only **Pyramid** is a WebSocket relay and community authority. Standalone **Blossom** understands signed Nostr authorization but is not a relay.

Public launch does not require another daemon. Add the manually curated Best-of as a static artifact, served by the existing Caddy process on its own origin. Start cross-relay aggregation as direct client reads; deploy a materialized aggregator only after measured fan-out or UX failure. This keeps public launch at **7 always-on processes** and moves the aggregator to an exact **+1 process / +1 unit / +1 store / +1 Nostr-aware component** when its gate is crossed.

The selected later expansion—materialized aggregation, Git, GRASP, and a stateless private-media authorization gateway—has **11 always-on processes**, **15 systemd units**, **7 locally served public origins plus one external status origin**, **6 runtime-writable stores**, and **5 Nostr-aware server processes**. A Napplet/Kehto runtime adds **zero** operator processes, units, stores, or origins: it is static browser code on the existing community origin.

## Counting Rules

Counts below are exact for the recommended topology, not every optional component mentioned elsewhere.

- A **process/service** is a project-managed, always-on daemon. Base-OS daemons such as PID 1, `systemd-journald`, SSH, and time sync are infrastructure prerequisites, not Dialogos product services and are excluded.
- A **systemd unit** includes always-on `.service` units plus scheduled `.timer` and corresponding oneshot `.service` units. A timer is a unit but not an always-on process.
- A **public origin** is a distinct browser/protocol origin. The externally hosted status page is counted separately from origins routed by this VPS.
- A **store** is runtime-writable persistent state that must be backed up or rebuilt deliberately. Caddy certificate state and Alertmanager silences are operational state, but are not counted as product/telemetry stores; they remain in the backup inventory.
- A **Nostr-aware server process** parses Nostr events, filters, signatures, relay frames, or Nostr authorization. Static files, Caddy, metrics, Git smart HTTP/SSH, and backup tools are not Nostr-aware.
- A browser client or operator batch tool may contain Nostr logic without becoming a server service. Those are listed, but excluded from operator daemon counts.

## Exact Inventory by Stage

| Stage | Always-on processes | Project systemd units | Local public origins | External public origins | Runtime stores | Nostr-aware server processes | WSS relay servers | Server-held event signers |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Internal pilot | 7 | 11 | 3 | 1 | 3 | 2 | 1 | 1 |
| Public launch | 7 | 11 | 4 | 1 | 3 | 2 | 1 | 1 |
| Later selected expansion | 11 | 15 | 7 | 1 | 6 | 5 | 2 | 1 |

“Server-held event signer” means a service-owned key used to sign Nostr events. Members and operators still sign with their own browser, mobile, hardware, or NIP-46 signer. Pyramid necessarily has an internal relay key and can emit server-generated events; no other recommended v1 server should hold a content-author key. A chosen GRASP implementation must not be allowed to create a second community signer unless a later protocol requirement is explicitly approved.

### Internal pilot: 7 processes, 11 units

| Process / unit | Type | Public origin | Persistent state | Nostr-aware? |
|---|---|---|---|---|
| `caddy.service` | Infrastructure ingress/static server | `relay`, `blobs`, `community` | TLS/operational state only | No |
| `pyramid.service` | Product authority | `wss://relay…` | Pyramid mmap layers, management log, settings, indexes | Yes: full relay |
| `blossom.service` | Product media service | `https://blobs…` | Blob metadata and blob objects | Yes: signed HTTP auth only |
| `node-exporter.service` | Infrastructure telemetry | None | None | No |
| `blackbox-exporter.service` | Infrastructure probe | None | None | No |
| `prometheus.service` | Infrastructure telemetry | None; private loopback/VPN UI only | Bounded metrics TSDB | No |
| `alertmanager.service` | Infrastructure alert routing | None | Silences/notification state only | No |
| `dialogos-backup.timer` + `dialogos-backup.service` | Scheduled infrastructure job | None | Writes offsite restic repository | No |
| `dialogos-restore-check.timer` + `dialogos-restore-check.service` | Scheduled infrastructure job | None | Disposable restore evidence | No |

The three local origins are `relay.<domain>`, `blobs.<domain>`, and the main `community.<domain>`. The status page/monitor is external, yielding one additional public origin. Admin operation is a local signed tool or a protected route on an existing origin, not another daemon or public admin origin. Static NIP-05, onboarding, documentation, and policy pages are files served by Caddy.

The three stores are Pyramid state, Blossom state, and Prometheus TSDB. Restic is an off-host backup repository rather than another local runtime store. Caddy certificates, Alertmanager silences, and logs still belong in operational recovery procedures.

### Public launch: still 7 processes, 11 units

Public launch adds `best.<domain>` as a fourth local origin, but Caddy serves it from a reviewed, immutable curation artifact. The authoritative editorial decision is the reviewed curation manifest in the deployment/content workflow; production does not need an always-on curator or mutable curation database. The projector must verify the referenced original event, preserve its ID and signature, and publish static output. It must never re-sign a member's content.

Initial cross-relay aggregation is direct read composition in compatible clients. The member roster remains Pyramid-authoritative; client relay lists remain user/client configuration. This satisfies discovery without establishing a second event store. If the public chronological experience cannot meet latency, provenance, deletion, or bounded-query gates this way, enable the materialized aggregator described below. Its delta is exact:

| Gated addition | Processes | Units | Origins | Stores | Nostr-aware servers | WSS servers |
|---|---:|---:|---:|---:|---:|---:|
| Materialized aggregator | +1 | +1 | +0 | +1 | +1 | +0 |

The aggregator is a WSS **client**, not a WSS server. It observes an allowlisted external relay set, validates and classifies public member-authored events, records only checkpoints/provenance, and submits unchanged events through Pyramid's normal WSS ingress. It cannot write Pyramid files, answer public REQs, manage membership, or become a search authority.

### Later selected expansion: 11 processes, 15 units

The later count assumes all four approved additions below are active. Existing backup and restore-check unit pairs remain, hence 11 always-on `.service` units plus four scheduled units = 15 total project units.

| Addition | Process | New origin | New store | Nostr role |
|---|---:|---:|---:|---|
| Materialized public aggregator | +1 | 0 | +1 provenance/checkpoint SQLite | WSS client; validates public events; never serves relay traffic |
| Git server | +1 | +1 `git…` | +1 Git object/repository store | None |
| GRASP / NIP-34 relay | +1 | +1 `grasp…` | +1 NIP-34 event store | Separate WSS relay restricted to collaboration kinds |
| Private-media authorization gateway | +1 | +1 `private-media…` | 0; stateless against approved claims and ciphertext objects | Verifies Nostr auth/membership proof; never sees plaintext |
| Napplet/Kehto runtime | +0 | 0; static on `community…` | 0 operator store | Browser-only relay/signing mediation; no server authority |

This produces seven local origins: relay, public blobs, community, Best-of, Git, GRASP, and private media. The external status page is the eighth public origin overall. Loki, Alloy, Grafana, a live replica, a hosted signer, and a dedicated curator are not in this selected topology. Each would require a separate decision and an explicit count delta.

## Per-Component Authority and Nostr Logic

| Component | Authoritative state | WSS behavior | Signs events? | Relay sets | Nostr logic and overlap |
|---|---|---|---|---|---|
| **Pyramid** | Sole membership, roots/roles, invitations, groups, moderation, accepted community events, canonical search/index projections | Public WSS server behind Caddy | Yes, only service-owned relay/internal events; never member content | Its own canonical relay paths; no broad external crawl set | Full validation, filters, routing, storage, search, policy, admin. This is the one community authority. Pyramid v1.3.2 exposes many optional modules in one binary; keep non-core modules disabled ([main mux](https://github.com/fiatjaf/pyramid/blob/v1.3.2/main.go#L487-L548)). |
| **Standalone Blossom** | Blob ownership metadata, quotas, deletions, object bytes | None; HTTPS only | No Nostr content events | None | Verifies signed Blossom authorization events and hashes. Signature/event parsing overlap is harmless. A separate roster or role database would be dangerous duplication; accept a narrow, versioned roster projection from Pyramid. Blossom's official protocol uses Nostr-signed HTTP authorization ([spec](https://github.com/hzrd149/blossom)). |
| **Materialized aggregator** | Observation checkpoint, source, first/last seen, deletion/tombstone provenance only | Outbound WSS client to allowlisted external relays and local Pyramid ingress | No | Explicit external source allowlist plus the one local destination | Duplicates event decoding, ID/signature checks, filters, dedupe, and routing intentionally. It must not duplicate membership policy, general storage, search, moderation/admin, or public REQ handling. Pyramid's raw NIP-77 store target is why direct store synchronization is forbidden ([source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/sync.go#L55-L80)). |
| **Static Best-of projector** | Reviewed curation manifest outside production runtime; generated pages are replaceable artifacts | None | Operator may sign a separate curation record using an external signer; projector does not sign | Fetch-only source list during build | Verifies event IDs/signatures and renders. No relay, storage, search, membership, or moderation authority. Never re-signs quoted content. |
| **Thin admin/onboarding UI** | None; all accepted state remains Pyramid state | Browser client to Pyramid | Requests operator signing from an external signer; holds no key | Only configured community relay | Constructs requests and displays results. UI validation is convenience, never authority; Pyramid revalidates authorization and input. |
| **Caddy** | Routing/TLS configuration only | Tunnels WebSocket bytes; does not parse Nostr frames | No | None | No Nostr logic. Host/path routing, TLS, limits, and proxy headers only ([Caddy WebSocket reverse proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy)). |
| **Prometheus/exporters/Alertmanager** | Metrics and alert state only | Blackbox may probe a WSS handshake; it is not a relay | No | None | Protocol probes may send test frames but have no event authority. Infrastructure daemons, not Nostr product services. |
| **Backup/restore jobs** | Encrypted snapshots and evidence | None | No | None | Byte-level state handling only. Must preserve boundaries rather than merge stores. |
| **Git server, later** | Git repositories and access config | None; Git SSH/HTTPS | No Nostr events | None | No Nostr logic. NIP-34 announcements belong to GRASP, not Git storage ([NIP-34](https://github.com/nostr-protocol/nips/blob/master/34.md)). |
| **GRASP, later** | Collaboration events only | Separate WSS server | Normally accepts user-signed events; no general community signer | Its own collaboration origin only | Reuses relay validation/filter/storage/search primitives, but authority is safe only while restricted to an explicit NIP-34 kind/policy set. Social/group/member events remain Pyramid-only. |
| **Private-media gateway, later** | No canonical state; optional append-only audit is derived | HTTPS only | No | None | Verifies authorization and obtains bounded membership claims. It must not maintain roles, decrypt client ciphertext, or become a second Blossom catalog. |
| **Kehto/Napplet runtime, later** | Per-browser session, capability, local storage, and user preference state only | Browser WSS client through a host relay adapter | Shell-owned signer signs once; napplet never receives signer capability | User/shell-configured client relay pool | Client dispatch, ACL, filters, local cache, relay routing, and signing mediation. These are user-agent concerns, not server acceptance or membership authority. |

Pyramid private-group query filtering is an access-control enforcement point, not encryption ([source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/groups/queries.go#L63-L97)). No Blossom, gateway, Napplet runtime, or aggregator may reinterpret that as permission to expose plaintext elsewhere.

## Duplication Budget

Not every repeated Nostr parser is architectural duplication. The decisive question is whether two components can independently decide canonical membership, accepted events, policy, or durable current truth.

### Harmless and required overlap

| Repeated capability | Where | Why acceptable |
|---|---|---|
| Event decoding, ID recomputation, Schnorr verification | Pyramid, aggregator, Best-of build, Blossom auth, GRASP, clients | Every trust boundary must validate untrusted input independently. Share audited libraries where practical, but never trust another process's “already validated” flag. |
| Filter matching and dedupe | Pyramid, direct-reading clients, aggregator, GRASP | Each is scoped to its own data plane. Client filtering is presentation; aggregator filtering is ingress classification; Pyramid filtering is canonical query/acceptance. |
| Relay routing | Pyramid server, aggregator client, browser runtime client, GRASP server | Server acceptance, ingestion routing, client relay selection, and collaboration serving are different roles. Names and metrics must make that distinction visible. |
| Signed authorization verification | Pyramid NIP-42/admin, Blossom upload/delete, private-media gateway | Authorization is endpoint-specific. Each service verifies its own request, then consumes the smallest approved membership claim. |
| Derived search/index/cache | Pyramid indexes, browser cache, static Best-of output | Safe only when external derivatives are disposable and cannot accept writes or override canonical results. |

### Dangerous duplication: prohibit it

| Duplicate | Failure mode | Boundary |
|---|---|---|
| Membership/role tables in Blossom, aggregator, GRASP, or gateway | Revoked users retain access; role semantics drift | Pyramid is sole authority. Export narrow signed/versioned claims; short TTL; fail closed on stale privileged claims. |
| Aggregator as a second public relay/store/search service | Conflicting deletion, moderation, search, and event truth | No public listener; provenance/checkpoints only; unchanged events enter Pyramid's ordinary validated WSS path. |
| Curator re-signing member content | Changes authorship and creates a competing event | Preserve original event ID/signature; sign only a distinct inclusion/audit record. |
| Napplet ACL treated as relay authorization | A browser capability grant bypasses server policy | Runtime ACL only decides which napplet may request a host action. Pyramid independently validates every signed event and request. |
| GRASP accepting ordinary social/group events | Second general-purpose relay with divergent moderation/deletion | Explicit kind allowlist and separate origin/store; NIP-34 collaboration only. |
| Private-media gateway storing plaintext or its own blob catalog | New confidentiality and deletion authority | Ciphertext end to end; Blossom owns object lifecycle; gateway is stateless authorization. |
| Dedicated search sidecar becoming writable/current truth | Stale or contradictory results survive deletion | Search is a rebuildable projection; canonical deletion and visibility come from Pyramid. |

The target duplication budget is therefore **one canonical membership/policy authority, one canonical community-event store, one canonical public-blob owner, and zero server-side member signers**. Multiple protocol parsers are expected. Multiple authorities are not.

## Pyramid-Native Blossom Versus Standalone Blossom

Pyramid v1.3.2 includes Blossom routes in the same binary ([registered routes](https://github.com/fiatjaf/pyramid/blob/v1.3.2/main.go#L487-L548)). Keeping standalone Blossom changes the count by exactly one daemon and one independently owned store:

| Choice | Internal/public processes | Systemd units | Local origins | Runtime stores | Nostr-aware servers | Operational consequence |
|---|---:|---:|---:|---:|---:|---|
| **Standalone Blossom — recommended** | 7 | 11 | unchanged at 3/4 | 3 | 2 | Independent quota, abuse, deletion, capacity, backup, and migration lifecycle; one narrow roster bridge must be secured. |
| Pyramid-native Blossom | 6 | 10 | unchanged; Caddy can keep `blobs…` | 2 physical owners | 1 combined process | Fewer moving parts, but relay and media share release, resources, failure domain, secret-bearing backup, and upgrade rollback. |

Native Blossom removes a process, not a responsibility. The blob data, quotas, deletion, abuse response, capacity forecasting, and recovery tests still exist. It also makes “Pyramid owns only community relay functions” false and gives public media load the same failure domain as private groups. Use native Blossom only as a tightly capped emergency/pilot fallback if no standalone server passes roster, quota, deletion, and restore gates. Do not start native and casually migrate later; URLs, ownership metadata, deletion proofs, and backups make that a real migration.

## Napplet/Kehto Boundary

Kehto is currently an alpha implementation of a NIP-5D Napplet runtime—explicitly “one runtime, not the runtime” and “far from complete” ([README](https://github.com/kehto/web/blob/82b4238bd365a981b0c7c68b879697252e502e2a/README.md#L8-L16)). Its architecture separates capability state, browser-agnostic runtime dispatch, browser shell, and service adapters ([architecture](https://github.com/kehto/web/blob/82b4238bd365a981b0c7c68b879697252e502e2a/docs/concepts/architecture.md)). The runtime owns message dispatch, ACL gates, service routing, and session state; the shell owns iframes, `postMessage`, browser lifecycle, and gateway loading ([boundary](https://github.com/kehto/web/blob/82b4238bd365a981b0c7c68b879697252e502e2a/docs/concepts/runtime-shell-boundaries.md)).

That paradigm belongs entirely on the client side for Dialogos:

```text
untrusted napplet
  -> Kehto runtime capability check
  -> shell-owned signer / relay adapter
  -> signed standard Nostr event or authenticated HTTP request
  -> Caddy
  -> Pyramid or Blossom revalidates and authorizes independently
```

Kehto's publish path has the napplet submit an `EventTemplate`; the runtime obtains the shell-owned signer, signs once, and gives the signed event to the relay backend. Napplets do not receive signer RPC access ([runtime README](https://github.com/kehto/web/blob/82b4238bd365a981b0c7c68b879697252e502e2a/packages/runtime/README.md#L38-L49)). This preserves the existing requirement that member keys never reach Dialogos servers.

The hard boundary is: **a Napplet runtime may compose client capabilities, but it may not become a hosted policy proxy or relay authority**. It receives no direct database access, privileged roster file, server signing key, or “trusted validation” shortcut. Its ACL controls access to browser services; it cannot grant community membership. Its relay list is a user/shell preference; it cannot redefine the community canonical relay. Its cache is per-user and disposable; it cannot become canonical search/storage. Every publication crosses the same public protocol boundary and is revalidated by Pyramid.

The NAP shell also derives session identity from its own trusted creation state rather than a napplet assertion, while NAP-INTENT leaves handler selection to shell policy and forbids napplets from addressing one another directly ([NAP-SHELL](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/naps/NAP-SHELL.md#L134-L157), [NAP-INTENT](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/naps/NAP-INTENT.md#L15-L22)). These are useful client isolation rules, not substitutes for server authorization.

## V1 Recommendation

Ship the **7-process topology**:

1. Caddy.
2. Pyramid core only.
3. Standalone public Blossom.
4. node_exporter.
5. blackbox_exporter.
6. Prometheus.
7. Alertmanager.

Keep backup and restore checks as two timer/oneshot pairs, for 11 managed units total. Serve onboarding, NIP-05, policy, and later Best-of as static Caddy content. Use a local/external signed admin tool, not an always-on admin service. Use direct client relay composition first. Add the materialized aggregator only on an evidence gate. Defer GRASP, Git, private-media gateway, and Kehto/Napplet composition until core protocol, privacy, deletion, and recovery gates pass.

This is not “seven Nostr microservices.” It is **two Nostr-aware product servers, five ordinary infrastructure daemons, one canonical relay authority, and no hosted member signer**. That is the smallest topology that preserves the project's required media separation and production observability without turning Pyramid into the monolith the project explicitly rejects.

## Primary Sources

- [Pyramid v1.3.2 release](https://github.com/fiatjaf/pyramid/releases/tag/v1.3.2), [main route registration](https://github.com/fiatjaf/pyramid/blob/v1.3.2/main.go#L487-L548), [settings secret](https://github.com/fiatjaf/pyramid/blob/v1.3.2/global/settings.go#L57-L63), [settings save mode](https://github.com/fiatjaf/pyramid/blob/v1.3.2/global/settings.go#L465-L475), [raw sync target](https://github.com/fiatjaf/pyramid/blob/v1.3.2/sync.go#L55-L80)
- [Blossom protocol](https://github.com/hzrd149/blossom), [Blossom server](https://github.com/hzrd149/blossom-server)
- [NIP-29 relay-based groups](https://github.com/nostr-protocol/nips/blob/master/29.md), [NIP-34 Git collaboration](https://github.com/nostr-protocol/nips/blob/master/34.md), [NIP-42 relay authentication](https://github.com/nostr-protocol/nips/blob/master/42.md)
- [Kehto README](https://github.com/kehto/web/blob/82b4238bd365a981b0c7c68b879697252e502e2a/README.md), [architecture](https://github.com/kehto/web/blob/82b4238bd365a981b0c7c68b879697252e502e2a/docs/concepts/architecture.md), [runtime/shell boundary](https://github.com/kehto/web/blob/82b4238bd365a981b0c7c68b879697252e502e2a/docs/concepts/runtime-shell-boundaries.md), [runtime relay/signing contract](https://github.com/kehto/web/blob/82b4238bd365a981b0c7c68b879697252e502e2a/packages/runtime/README.md#L38-L49)
- [NAP-SHELL at `5ac0490`](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/naps/NAP-SHELL.md), [NAP-INTENT at `5ac0490`](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/naps/NAP-INTENT.md)
- [Caddy reverse proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy), [Prometheus node exporter guide](https://prometheus.io/docs/guides/node-exporter/), [blackbox exporter](https://github.com/prometheus/blackbox_exporter), [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)
