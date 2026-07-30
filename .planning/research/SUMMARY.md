# Project Research Summary

**Project:** Sovereign Engineering Nostr Community Infrastructure
**Domain:** Modular, Pyramid-centered sovereign Nostr community infrastructure
**Researched:** 2026-07-30
**Confidence:** MEDIUM

## Executive Summary

This is not a conventional community application and should not be planned as one. It is a small sovereign network composed from a relay/community authority, existing Nostr clients and external signers, a separate media service, and thin discovery/administration surfaces. The canonical relay is [`fiatjaf/pyramid`](https://github.com/fiatjaf/pyramid), not the older `github-tijlxyz/khatru-pyramid`. Research inspected Pyramid **v1.3.2**, commit `e12e81641bfe6cacc6dd246e9433d602c1240e66`, released 2026-07-29. It natively provides the membership hierarchy, public/member relay paths, NIP-29 groups, NIP-42 authentication, NIP-86 administration subset, NIP-05, NIP-50 search, moderation, and memory-mapped `mmm` event storage needed for the core. It is also young, fast-moving, and not production-safe unchanged: its secret-bearing `settings.json` is saved with mode `0644`, and its browser admin session design has long-lived replay and web-session weaknesses. Both are pre-pilot blockers, not later hardening tasks.

Recommended v1 is deliberately modular: native Pyramid binary under `systemd` on Debian 13.6, loopback-only behind Caddy 2.11.4; standalone Blossom on an isolated origin after its roster/quota bridge is proven; restic to an independent S3-compatible backup target; journald plus Prometheus/exporters/Alertmanager; static onboarding/status/public-discovery surfaces; existing clients and member-controlled signers. Nostrord should be the pinned NIP-29 reference/compatibility client, Flotilla the preferred alumni workspace only after it passes the complete privacy and signer matrix, and Jumble the public chronological feed/long-form front door. This resolves a source conflict: feature research favored Flotilla as default UX, while stack research favored Nostrord as the launch pilot. They serve different jobs. A coherent hosted UI is feasible without adding a daemon, database, or Nostr authority: Caddy can serve pinned static clients on isolated origins. The recommended sequence is a branded portal first, a pinned Jumble feed trial after the core pilot, then a narrow web-only Flotilla hardening fork if measured workspace needs justify its maintenance. Do not self-host every client or build a custom client before pilot evidence.

The main risks are false security promises, immature admin behavior, policy/role mismatch, deletion resurrection, private-event routing leaks, unbounded public media, and backups that cannot restore coherent state. NIP-29 `private` means relay-enforced access control—not E2EE—and ordinary multi-relay clients can still misroute plaintext. Private-room attachments must therefore remain disabled for sensitive content until an audited encrypted-group and encrypted-media design exists. A single 4-vCPU/8-GB/160-GB VPS plus offsite backup is feasible below US$100/month: base estimates are roughly $30–70, while a conservative all-in estimate with contingency is $61–91. The margin is narrow enough that actual media, egress, backup, and restore measurements are release gates.

### Implementation Sequencing Decision — 2026-07-31

Before implementing the researched v1 topology, run a bounded **stock-Pyramid discovery pilot**. Re-audit and pin the current upstream candidate, deploy it without source changes behind Caddy/systemd and minimum host safeguards, restrict the stock administration surface to operators, and onboard a small named alumni cohort through existing clients and member-controlled signers. The pilot tests native Pyramid membership, groups, roles, authentication, search, publishing, deletion, reconnect, error behavior, and client/signer compatibility in real use.

Standalone Blossom, hosted community clients, aggregation, curation, companion services, and Pyramid patches are not prerequisites for this discovery deployment. Record native capability, configuration needs, Pyramid defects, client gaps, missing workflows, operational behavior, and participant feedback; then plan the next milestone from that evidence. The larger seven-process v1 topology below remains a researched target, not the discovery-pilot starting topology.

Napplet-style hosted headless community applets are a distinct possible future product direction and are fully outside this project's roadmap. Preserve only the general boundary that clients remain replaceable and non-authoritative.

## Decision Posture

### Confirmed Facts

- **Canonical implementation:** use [`fiatjaf/pyramid`](https://github.com/fiatjaf/pyramid) v1.3.2 / `e12e816…`; [`github-tijlxyz/khatru-pyramid`](https://github.com/github-tijlxyz/khatru-pyramid) is a legacy project and must not appear in deployment automation.
- **Maturity:** v1.3.2 was one day old when researched. Activity is confirmed; operational stability and compatibility are not.
- **Persistence:** Pyramid uses `mmm` memory-mapped event layers, `management.jsonl`, `settings.json`, and embedded Bleve indexes. PostgreSQL is neither required nor the supported data model.
- **Native core:** membership/invites, roots and display roles, public/member relay paths, NIP-29 groups, NIP-42, a NIP-86 subset, NIP-05, NIP-50, moderation, and deletion paths exist.
- **Native extras:** Blossom, GRASP, nsite, streaming, link preview, image proxy, paywall, SFTP, LiveKit, and curation routes exist in the same binary; existence does not make them recommended v1 ownership.
- **Role limitation:** Pyramid role labels do not define a complete capability system. Non-root invites default above zero, and members can create groups. Admin-only friend admission requires configuration, tests, and potentially a narrow policy patch.
- **Privacy limitation:** [NIP-29](https://github.com/nostr-protocol/nips/blob/master/29.md) private groups are operator-readable access-controlled plaintext. They are not E2EE.
- **Deletion limitation:** [NIP-09](https://github.com/nostr-protocol/nips/blob/master/09.md) is a request, not global erasure. Pyramid has a two-hour generic group-message deletion constraint and root-visible deleted-group archives that conflict with an unconditional deletion promise.
- **Federation limitation:** Pyramid favorites/popular/uppermost/inbox and manual NIP-77 utilities do not constitute complete member-feed federation, provenance, moderation inheritance, or deletion propagation.
- **Media limitation:** no verified minimal server currently provides dynamic Pyramid membership, per-user aggregate quota, authenticated private delivery, and clean service separation together.
- **Compatibility limitation:** repository/docs claims are not an interop result. NIP-29 is draft/optional; Pyramid already special-cases Flotilla/aiohttp behavior around NIP-77.

### High-Confidence Recommendations

- Keep Pyramid responsible only for authoritative relay/community state. Run optional services separately unless a temporary, explicitly bounded native fallback is accepted.
- Patch/fork narrowly for `settings.json` mode and safe browser administration. Maintain a patch ledger and rebase/acceptance suite.
- Use flat service subdomains, one protocol owner per origin, and Caddy as the only public listener.
- Keep two separate root/operator pubkeys; never store member keys, operator signer keys, bunker URIs, or signer connection secrets on the VPS.
- Start public federation as direct multi-relay reads. Materialize a sidecar aggregate only if pilot evidence shows query-time fan-out is inadequate.
- Treat private attachments as a cryptographic feature, not a Blossom configuration feature.
- Prefer an endorsed Sovereign Engineering sub-brand, but do not select a name or create the GitHub remote until member, domain, trademark, NIP-05, repository-owner, and scope checks complete.

### Open Decision Gates

1. Legal operator, jurisdiction, provider, region, OS image, provider AUP, abuse process, and backup region.
2. Final name/domain/NIP-05 namespace and GitHub owner/repository name.
3. Pyramid fork/patch strategy and exact release checksum/digest.
4. Root/admin/capability matrix, group-creation policy, and friend-admission enforcement.
5. Native Pyramid NIP-05 versus a generated static projection. Recommendation: keep Pyramid/roster canonical; use native NIP-05 unless namespace controls require a generated read-only projection.
6. Standalone Blossom implementation/backend and roster/quota bridge. Recommendation: `hzrd149/blossom-server` v6.2.0 target; Pyramid native Blossom only as a tightly capped public-asset fallback.
7. Best-of implementation: hardened admin-only Pyramid favorites versus a tiny signed curator/projection.
8. Federation source allowlist/backfill, direct-query bounds, and threshold for deploying a materialized aggregator.
9. Backup retention/deletion window and verified quiesced snapshot procedure.
10. Private attachment/E2EE design; no implementation is approved by current research.

## Key Findings

Detailed evidence lives in [STACK.md](./STACK.md), [FEATURES.md](./FEATURES.md), [ARCHITECTURE.md](./ARCHITECTURE.md), [PITFALLS.md](./PITFALLS.md), [NAPPLETS.md](./NAPPLETS.md), [SERVICE-BOUNDARIES.md](./SERVICE-BOUNDARIES.md), [UI-CANDIDATES.md](./UI-CANDIDATES.md), [CLIENT-HOSTING.md](./CLIENT-HOSTING.md), and [UI-ADOPTION.md](./UI-ADOPTION.md).

### Recommended Stack

**Core technologies:**

- **Debian 13.6 amd64:** conservative host with native systemd/nftables.
- **Pyramid v1.3.2 / `e12e816…`:** pinned core relay/community authority; native binary, no automatic updates.
- **Caddy v2.11.4:** sole TLS/WebSocket ingress; preserve canonical host/scheme and well-known paths.
- **Pyramid `mmm` + Bleve 2.4.4:** native event persistence and NIP-50 search; no PostgreSQL or external search cluster.
- **`hzrd149/blossom-server` v6.2.0 / `bff3acb…`:** preferred separate public-media service after policy bridge and abuse controls; rootless Podman/Quadlet acceptable.
- **restic v0.19.1 + independent S3-compatible storage:** encrypted offsite backups, checks, pruning, and blank-host restore drills.
- **journald + Prometheus 3.13.1 LTS + node_exporter 1.12.1 + blackbox_exporter 0.28.0 + Alertmanager 0.33.1:** bounded operational telemetry without a launch Grafana/Loki dependency.
- **Static site/thin signed UI:** onboarding, privacy language, client/signer guidance, roster projection, Best-of, and status links; no key custody or shadow authorization database.
- **Small Go sidecars only when justified:** curator and eventual aggregate worker; communicate through signed/public interfaces, never Pyramid store files.

**Explicitly omit at launch:** Kubernetes, Docker Compose as production control plane, PostgreSQL, Redis, Kafka, Elasticsearch/OpenSearch, Grafana/Loki without a measured need, Pyramid auto-update/easy installer, built-in SFTP, link preview/image proxy, LiveKit, GRASP, nsite, paywall, and broad streaming.

**Deployment topology:** one dedicated VPS; Caddy public on 80/443; SSH restricted; Pyramid and all metrics/admin/backends bound to loopback/private network; flat `relay.`, `blobs.`/`media.`, `status.`, and optionally `admin.` origins. External uptime and encrypted backup must sit outside the VPS failure domain. This is single-host recovery architecture, not high availability.

#### Exact V1 Service Budget

Recommended internal pilot has **7 project-managed always-on processes, 11 project-managed systemd units, 3 local public origins plus 1 external status origin, 3 runtime-writable stores, 2 Nostr-aware server processes, 1 WSS relay server, and 1 server-held event signer**. Public launch remains at 7 processes, 11 units, 3 stores, 2 Nostr-aware servers, and 1 relay; it adds only the static `best.<domain>` origin, bringing local origins to 4. The server-held signer is Pyramid's internal relay key; no recommended server holds a member or operator content-author key.

| Always-on v1 process | Role | Store / Nostr boundary |
|---|---|---|
| `caddy.service` | TLS, WSS tunneling, static community/NIP-05/Best-of content | Operational TLS state; no Nostr parsing |
| `pyramid.service` | Sole community relay and policy authority | Pyramid mmap/management/settings/index store; full WSS relay |
| `blossom.service` | Public media ownership, quotas, deletion, bytes | Blob metadata/object store; Nostr-signed HTTP auth, not WSS |
| `node-exporter.service` | Host metrics | No product store or Nostr authority |
| `blackbox-exporter.service` | Outside-facing protocol probes | No product store or Nostr authority |
| `prometheus.service` | Metrics/alert evaluation | Bounded TSDB; no Nostr authority |
| `alertmanager.service` | Alert routing | Operational notification state only |

Four additional managed units are two timer/oneshot pairs: backup and restore-check. Internal local origins are `relay.<domain>`, `blobs.<domain>`, and `community.<domain>`; externally hosted status is separate. The three counted stores are Pyramid, Blossom, and Prometheus. Restic is an off-host repository, while certificates, logs, and Alertmanager state remain in the recovery inventory without becoming product stores.

The gated materialized aggregator adds exactly **+1 process, +1 unit, +1 store, +1 Nostr-aware component, and no origin or WSS server**. Selected later aggregation + Git + GRASP + stateless private-media gateway yields **11 processes, 15 units, 7 local origins plus 1 external status origin, 6 stores, 5 Nostr-aware server processes, 2 WSS relay servers, and still 1 server-held event signer**. Prior Napplet research found that a browser runtime could be static, but that direction is not part of this project's service budget or roadmap.

**One-authority duplication budget:** one canonical membership/policy authority, one canonical community-event store, one canonical public-blob owner, and zero server-side member signers. Repeated parsing, event-ID/signature verification, endpoint-specific authorization checks, scoped filtering/deduplication, and disposable projections are required at trust boundaries. Duplicate membership/role tables, public relay/search truth, re-signed member content, Napplet ACL as relay authorization, or a second blob catalog are prohibited.

### Native vs Separate Capability Boundary

| Capability | Recommended owner | Reason / constraint |
|---|---|---|
| Membership, invites, roots, group state | Pyramid | One authoritative community-state writer |
| Public/member relay, NIP-29, NIP-42, search, moderation | Pyramid | Native core; must be acceptance-tested at pin |
| NIP-05 | Pyramid initially, or generated read-only projection | Avoid duplicated truth; namespace policy remains a gate |
| Website/onboarding/status links | Static/thin web | Separate release and security surface; no keys |
| General public files/media | Standalone Blossom | Independent quota, abuse, storage, backup, and replacement lifecycle |
| Temporary public profile/group assets | Pyramid native Blossom only if needed | Membership-aware quotas exist; public-only, capped, SFTP disabled |
| Private attachments | No v1 owner | Disable sensitive use until audited client encryption + key distribution + authenticated fetch |
| Public federation | Direct client queries first; sidecar later | Avoid copied-content lifecycle until measured need |
| Best-of | Signed curator/projection or hardened favorites | Manual, admin-only, preserves original event/signature |
| Git/NIP-34 | Separate Git host + GRASP later | Git objects and Nostr collaboration have separate lifecycles |
| Client composition/runtime | Existing clients and replaceable conventional browser adapters; Napplet/headless-applet work excluded | Client ACL/signing/routing is not relay membership, persistence, moderation, or operations |
| Observability/backup | Separate operator services | Must remain useful when Pyramid is unhealthy |

### Expected Features

**Must have for internal pilot and public-launch eligibility:**

- Authoritative roster and explicit alumni/friend/admin/operator capability matrix.
- Admin-only friend admission, two distinct root operators, and tested recovery.
- Bring-your-own-key signer flows: nos2x, nos2x Firefox, Amber NIP-55/NIP-46, selected iOS remote signer, and member-chosen bunkers.
- Public chronological member feed, notes/replies/reactions, long-form publishing/reading, and a public NIP-29 town square.
- Access-controlled alumni rooms labeled “operator-readable, not E2EE,” with trap-relay leak tests.
- NIP-05, search with audience enforcement, minimal member directory, notifications/unread behavior, mute/block tools, onboarding/status/exit guidance.
- General-purpose public Blossom with auth, per-user and global quotas, MIME/size policy, quarantine/report/delete flow, forecasting, and restore proof.
- Private-room attachment guardrail: sensitive plaintext uploads disabled.
- Strong local deletion contract, tombstones, derived-store removal, and backup aging; no global-erasure claim.
- Minimal human moderation and auditable severe-abuse actions; no engagement ranking or behavioral profiling.
- Manual chronological “All” plus editorial “Best of.”

**Should have after core pilot evidence:**

- Rich opt-in directory/community map and alumni/friend NIP-58 recognition badges.
- Bounded external public-event discovery with provenance; materialized aggregate only if direct reads fail measured requirements.
- NIP-52 events/RSVPs, optional zaps/V4V, advisory governance, and selected NIP-34/GRASP experiments.
- Later LiveKit rooms only with measured demand and a separate operations review.

**Defer to v2+ or a dedicated research milestone:**

- Marmot/MLS E2EE rooms and encrypted group attachments.
- NIP-29-aware live replica/failover.
- Full custom client; requires documented core-job failures across composed clients plus maintenance/security ownership.
- Napplet/Kehto production use or hosted headless-applet architecture; pursue only as a separate future project.
- Public educational/cloneable release until production stability and publication decisions pass.

### Client and Signer Compatibility

| Surface | Recommended role | Gate |
|---|---|---|
| Nostrord | NIP-29 reference, group administration, chat-first fallback | Primary protocol baseline; pin version and test NIP-07/NIP-46, group roles/deletion/private reads |
| Flotilla | Preferred alumni workspace | Promote only after trap-relay, auth, NIP-77 workaround, signer, notification, upload, and privacy matrix passes; remove upstream analytics in self-hosted build |
| Jumble | Public chronological feed, community preset, long-form/discovery | Do not treat as NIP-29 administration client; test signer and relay-set behavior |
| nos2x / nos2x-fox | Desktop browser signing | Default desktop paths; verify release provenance and browser parity |
| Amber | Android NIP-55/NIP-46 | Recommended Android pilot; test each chosen client and relay triple |
| Nostrum or another iOS NIP-46 signer | Experimental iOS path | Alpha/reference maturity; select and test before recommending |

“Supports NIP-X” is insufficient. Support requires pinned client/signer/relay triples passing login, reconnect, public publication, group invite/roles/private reads, exact outbound destination capture, search, upload/delete, and rejection/error behavior. Never recommend raw `nsec` paste when NIP-07/46/55 is available.

### Hosted UI Adoption

No inspected open-source client closes the entire product requirement unchanged. The viable path is composition first and consolidation only after live evidence:

| Stage | Surface | Candidate | Host delta | Ownership / risk |
|---|---|---|---|---|
| Internal pilot | `community.<domain>` | Thin branded portal plus deep links | No additional origin beyond the planned portal; +0 process/store/Nostr server | Low; 1–2 engineer-weeks planning estimate |
| Post-pilot feed trial | `feed.<domain>` | Pinned Jumble community-mode static build | +1 origin; +0 process/unit/store/Nostr server | Low/medium; 3–6 engineer-weeks including hardening and acceptance |
| Coherent workspace | `app.<domain>` or `rooms.<domain>` | Narrow web-only Flotilla fork | +1 origin; +0 process/unit/store/Nostr server | High; 2–4 engineer-months plus continuous upstream review |
| Evidence-gated v2 | Same primary app origin | Full custom client | +1 origin; +0 server daemon for static web, but four release lanes if web/native/desktop | Very high; 18–36 engineer-months cross-platform |

The effort estimates assume one experienced frontend/Nostr engineer and include the security, signer, relay-routing, PWA, compatibility, and rollback work that makes a hosted build production-worthy. They are planning ranges, not vendor facts.

**Flotilla is the closest unified foundation.** Its platform mode, branding, NIP-29 administration, NIP-42, NIP-50, Blossom, and NIP-07/46/55 coverage align with Pyramid. It is not safe to deploy unchanged: the researched release loads upstream Plausible analytics, calls hard-coded Coracle services, exposes unrelated hosting/login surfaces, inherits broad external defaults, and lacks verified `All`, `Best of`, NIP-23, NIP-58, and general-file flows. A production deployment is therefore a small, maintained hardening fork unless upstream makes those dependencies removable by configuration.

**Jumble is the easiest first self-hosted experiment.** It provides a strong public chronological feed, article reading, search, Blossom, NIP-05, and NIP-07/46 as a static web app. It is not a NIP-29 workspace and must never become membership or moderation authority. **Nostrord remains the independent NIP-29 correctness and fallback client**, not the primary branded shell. Coracle, noStrudel, and Snort are useful implementation references; Obelisk is currently blocked by licensing and documented privacy/safety defects; The Wired is excluded because its bundled backend would duplicate Pyramid, Blossom, search, and policy authority.

Each client must use its own origin. Do not iframe clients or mount independent apps under paths on one origin: signer permissions, service workers, storage, CSP, and rollback become coupled. Shared design tokens, terminology, top-level navigation, canonical `nprofile`/`nevent`/`naddr`/group deep links, and consistent privacy language provide coherence without shared secrets or shadow state.

The architecture score for the recommended sequence—portal now, one static hosted client, bounded fork only on evidence—is **8.5/10**. It reaches 10/10 only after: (1) an analytics-free configuration-only upstream mode, (2) reproducible pinned builds with checksums/SBOM/provenance and a security rebuild drill, (3) the full 180-cell client/signer/flow matrix plus hosting checks, (4) leak-free standard deep links and endpoint adapters, and (5) an eight-week trial proving the hosted client completes at least 90% of measured weekly jobs while remaining removable.

### Napplet and Kehto Research Boundary

Napplet/Kehto is a promising **client capability-isolation model**, not a replacement for Pyramid, Blossom, or the launch companion UI. It is out of scope for this project's implementation and roadmap; the retained research only prevents future boundary confusion. Canonical repositories and inspected pins are:

| Repository | Inspected pin | Actual role |
|---|---|---|
| [`napplet/naps`](https://github.com/napplet/naps/tree/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24) | `5ac0490461ca6fec2f0d2e45b4835cf9bc08de24` | NAP contract/archetype registry; no runtime code |
| [`napplet/web`](https://github.com/napplet/web/tree/03ad65b66413e5798536ef48695ffc4c2508f2c3) | `03ad65b66413e5798536ef48695ffc4c2508f2c3` | Alpha napplet-side SDK/types/shims/build/conformance tools; not a host or relay |
| [`kehto/web`](https://github.com/kehto/web/tree/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f) | `3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f` | Early-alpha browser host/runtime/reference services; integrator must supply production adapters |

Use the singular lower-case `napplet` namespace; historical `napplet/napplet` and `sandwichfarm/napplet` links are stale. [NIP-5D at inspected PR head `eb45dfd…`](https://github.com/nostr-protocol/nips/blob/eb45dfd7335b7f88cb53781984c553581d2b4c34/5D.md) and most needed NAPs remain draft. Current implementation drift includes an untransmitted NAP-RELAY group option, ignored publish options, no NIP-50 `search` field in `NostrFilter`, and stub-level notifications.

Boundary is strict: Kehto may mediate a browser's napplet identity, capability grants, signer consent, relay selection, upload/fetch, local preferences, and intent routing. Pyramid still owns membership, invites, roles, NIP-29/42/86, NIP-05/50, moderation, deletion, persistence, search, backup, and upgrades. Blossom still owns blob persistence, ownership, quotas, deletion, abuse handling, and backup. NAP-STORAGE is disposable client KV, NAP-IDENTITY is not the alumni roster, NAP-UPLOAD is not a media server, and a Napplet ACL cannot authorize anything at the relay. Pyramid/Blossom must independently revalidate every request.

Keep any later conventional UI replaceable and non-authoritative. No UI may own community authority; all writes require authoritative server confirmation, while optimistic UI remains explicitly pending and disposable. Any Napplet/headless-applet experiment requires a separate project charter rather than promotion through this roadmap.

### Federation and Portability

Members may publish unchanged signed public events to their chosen relays. Private/group/control/protected content must never enter the public aggregation path. Start with Jumble or equivalent direct reads from bounded member NIP-65 write relays and an operator allowlist. If pilot latency/load proves this inadequate, introduce a sidecar that:

- validates signature, ID, author roster, kind/tag/time/size, and public classification;
- rejects all `h`-tagged, NIP-17/59, NIP-70 protected, private/control/auth, and unknown-policy events;
- preserves original event bytes/signature and stores provenance separately;
- deduplicates by event ID and handles replaceable/addressable semantics;
- imports authorized deletions, maintains tombstones, removes derived data, and prevents resurrection;
- publishes only through normal local WSS ingress—never raw `mmm` writes;
- bounds relays, backfill, concurrency, retry/dead-letter state, and observable lag.

### Cost and Capacity

Start with 4 vCPU, 8 GB RAM, and 160 GB local NVMe. Planning assumptions: 100 alumni plus about 20 friends, 40 weekly active, 100 peak WebSockets, test 500, 2,000 writes/day, test 20 writes/s for 15 minutes, up to 5 million events, about 60 GB aggregate media cap, and 10–15 GB bounded logs/metrics. Conservative all-in monthly planning is **$61–91** including contingency; lower base estimates are **$30–70**. Under-US$100 is feasible but not guaranteed until 30-day disk, egress, object-storage, backup, restore-VM, and external-monitor measurements pass. Media disk/egress is the likely first bottleneck; move Blossom storage/host first rather than splitting Pyramid storage.

### Branding and Repository Naming

Research favors an **endorsed sub-brand**: a living maritime/shipyard place “by Sovereign Engineering.” A direct institutional extension is clear but generic; an independent name such as the working title “Dialogos” loses immediate recognition and risks feeling academic/static. Ancient-agora and hacker motifs should remain secondary texture, not the lead identity or an exclusion signal.

No candidate is cleared. Naming requires a member workshop plus domain, NIP-05 namespace, social-handle, trademark, and client URL tests. Do not create a GitHub remote before the final product name, repository owner, and repository scope are decided. Because this repository will contain deployment, companion services, tests, runbooks, and evidence—not merely a relay—the remote name should describe the whole infrastructure (for example, `<final-name>-infra`) rather than cementing `nip-29-relay` or the unapproved `dialogos`. Create remote only after explicit owner approval.

### Architecture Approach

Use a single-host modular architecture with strict trust and state boundaries. Caddy is the only public listener. Pyramid alone writes member/group/relay state. Blossom alone writes blob metadata/files. Any aggregator owns only provenance/checkpoints and sends unchanged events through WSS. A reviewed curation manifest owns editorial inclusion; a static projector verifies original events and never re-signs member content. Static web and browser runtimes own no authority. Backup and monitoring use their own identities and retention. Separate Unix users, writable paths, credentials, quotas, logs, and restore procedures make services replaceable without pretending a single VPS is highly available.

**Major components:**

1. **Ingress (Caddy)** — TLS, WSS routing, coarse limits, canonical headers, access logging; no Nostr authorization.
2. **Pyramid core** — membership hierarchy, relay policy, NIP-29, authentication, administration, moderation, event/search state.
3. **Thin onboarding/admin web** — client/signer discovery, roster/role UX, privacy language, NIP-05/Best-of/status navigation; signed calls, no key custody.
4. **Standalone Blossom** — public blobs, signed upload/delete, quotas, reports, quarantine, retention, backup.
5. **Federation/static curation** — optional bounded public-event importer only after its gate; immutable Best-of artifact served by Caddy; no always-on curator, private payloads, or signature rewriting.
6. **Operations plane** — systemd, journald, Prometheus/exporters/Alertmanager, restic, redacted evidence and runbooks.
7. **Existing clients/signers** — portable user experience and signing boundary; private keys stay client-side.

### Vision Assumptions Research Disproved

- Pyramid is **not** an operationally mature turnkey platform simply because it bundles many features.
- “Private NIP-29 room” is **not** an encryption guarantee.
- `alumni`, `friend`, and `admin` labels are **not** ACLs.
- Pyramid built-in admin authentication is **not** safe enough unchanged for production.
- Built-in Blossom is **not** a turnkey general-purpose private-media service.
- Favorites/popular/NIP-77 are **not** complete federation.
- A NIP support claim is **not** client/signer compatibility evidence.
- A successful backup command is **not** recovery evidence.
- HTTPS homepage health is **not** protocol readiness.
- Infrastructure availability alone will **not** create weekly participation; pilot facilitation and conversation quality are product work.
- Napplet/Kehto is **not** a relay, production client, server policy layer, NIP-50 implementation, Blossom service, or operations replacement.

### Critical Pitfalls

1. **False privacy claim** — say “access-controlled, operator-readable”; trap-relay test every supported client; disable sensitive private attachments.
2. **Unsafe Pyramid admin session** — replace long-lived JS-readable bearer with fully validated one-time NIP-98 login, short server-side `Secure`/`HttpOnly`/`SameSite` session, CSRF protection, step-up actions, CSP, and self-hosted pinned dependencies.
3. **Secret-bearing state readable too broadly** — patch `settings.json` to `0600`, parent/data to `0700`, recurring permission test, encrypted restricted backup.
4. **Role/policy mismatch** — write capability matrix first; set non-root invite quota to zero; enforce at relay/API, not UI/badge labels; test every allow/deny cell.
5. **Deletion resurrection** — define local deletion SLA, keep tombstones, purge search/cache/aggregate/media, reconcile Pyramid two-hour/archive behavior, and prove through reindex/refetch/restore.
6. **Unbounded or unsafe Blossom** — isolated origin, quarantine, MIME detection, malware policy, strict auth scope, per-file/user/day/global/concurrency/bandwidth limits, disk high-water behavior, and counsel-approved abuse flow.
7. **SSRF/egress abuse** — disable link preview/image proxy and arbitrary relay fetches initially; apply public-IP/port allowlists, redirect revalidation, time/byte limits, and egress firewall.
8. **Mutable supply chain and bad rollback** — exact tags/commits/digests/checksums/SBOM, no `latest`/easy installer/auto-update, restored-data staging, atomic switch, compatible rollback or snapshot restore.
9. **Incoherent backup** — quiesce/snapshot mmap and SQLite consistently; restore blank VPS; compare signatures, roles, groups, blobs, tombstones, indexes, and full client flows.
10. **Log/secrets leakage** — allowlist fields, redact event bodies/NIP-46/NIP-98/invite/file material, bound retention, canary-scan logs/metrics/backups/support bundles.

## Implications for Requirements

- Rewrite “private rooms” acceptance language as access-controlled, operator-readable rooms; E2EE and private group attachments become later gated requirements.
- Make the two Pyramid security fixes and privileged-endpoint audit explicit launch requirements.
- Separate descriptive roles/badges from enforceable capabilities; require an executable authorization matrix.
- Define deletion as a scoped local contract with backup aging and remote-copy caveats, not universal erasure.
- Define public-event aggregation as an experience requirement, not necessarily copied storage; direct reads satisfy v1 if performance and provenance pass.
- Require standalone media policy features before calling storage general-purpose: membership sync, aggregate quota, MIME/quarantine, abuse handling, deletion, backup, and capacity controls.
- Require exact pinned client/signer compatibility evidence and private-destination packet/event capture.
- Require the v1 portal to provide coherent onboarding, device/signer selection, privacy/status guidance, authoritative directory/badge/Best-of projections, and canonical deep links without retaining signer or authorization state.
- Permit one pinned static hosted-client trial after the core pilot. Require a separate origin, immutable artifact, endpoint allowlist, CSP, SBOM, signer/routing tests, PWA rollback, and zero new server authority.
- Permit a narrow web-only client fork only after measured repeated workflow failure, no timely upstream/configuration fix, and two maintainers accepting a 12-month maintenance budget. Keep custom client scope behind the existing v2 evidence gate.
- Define success gates for adoption and conversation quality alongside availability; no custom-client scope without failed-job evidence.
- Record final name, domain layout, GitHub owner/repository name, provider, jurisdiction, and publication strategy as explicit decision records before dependent work.
- Make the exact v1 count a requirements budget: 7 always-on processes, 11 units, 3 pilot/4 launch local origins, 3 stores, 2 Nostr-aware servers, 1 WSS relay, and no hosted member signer; any addition must declare its count and authority delta.
- Enforce the one-authority budget: Pyramid owns community policy/events; Blossom owns public blobs; client/runtime state is disposable and cannot become roster, search, moderation, or deletion truth.
- Require every client-facing feature to consume replaceable adapters and authoritative server APIs. UI writes succeed only after server confirmation.
- Exclude Napplet/Kehto and hosted headless-applet architecture from this project entirely; transfer retained research only if a separately chartered future project is approved.

## Implications for Roadmap

### Phase -1: Stock Pyramid Discovery Pilot
**Rationale:** Real stock-Pyramid use should define the implementation problem before the project owns companion services or patches.
**Delivers:** current upstream pin audit; source-unmodified build; minimal Caddy/systemd/permissions/backup/rollback envelope; privately restricted operator administration; small named alumni cohort using existing clients/signers; native capability and compatibility evidence; participant feedback; categorized next-step decision.
**Addresses:** fastest safe path to live Pyramid groups and evidence-driven requirements.
**Avoids:** speculative hosted UI, premature Blossom/federation work, local patches before an upstream baseline, and architecture chosen from documentation alone.
**Research:** implementation-focused current-pin audit and live acceptance only.

### Phase 0: Governance, Brand, and Operating Decisions
**Rationale:** Provider, legal, identity, retention, and naming choices constrain every later interface and policy.  
**Delivers:** legal-operator/provider/AUP decision; data classification; privacy/deletion/retention/abuse policies; capability matrix; two-operator model; name/domain/NIP-05/GitHub decision; threat-boundary draft.  
**Addresses:** authoritative roster, roles, admin-only admission, brand, portability.  
**Avoids:** labels-as-ACL, false privacy/deletion promises, provider suspension, premature remote identity.  
**Research:** **Required**—jurisdiction-specific counsel/provider review and naming clearance.

### Phase 1: Reproducible Hardened Foundation
**Rationale:** No application behavior is trustworthy until release provenance, secrets, ingress, and rollback boundaries exist.  
**Delivers:** dedicated VPS baseline; Debian/systemd/nftables/Caddy; pinned Pyramid build and checksum; narrow fork/patch ledger; `0600` settings fix; loopback origins; secret handling; baseline limits/monitoring; disposable staging deploy; declared 7-process/11-unit/3-store inventory and per-component authority contract.
**Addresses:** stable core relay prerequisite, under-$100 cost baseline, two-operator access.  
**Avoids:** mutable updates, public origin ports, secret leakage, SSRF/egress proxy, false HTTPS readiness.  
**Research:** **Required**—Pyramid packaging, fork/upstream strategy, safe systemd sandbox, provider benchmark.

### Phase 2: Safe Administration, Membership, and Recovery
**Rationale:** Authority must be correct before real members, clients, or groups touch the service.  
**Delivers:** rebuilt admin auth/session boundary; privileged endpoint audit; root-admin invite enforcement; alumni/friend/admin mapping; group-creation policy; audit/redaction; recovery/handover tests; authoritative roster and NIP-05 path.  
**Addresses:** admission, role distinction, NIP-05, two operators.  
**Avoids:** replayable browser admin bearer, UI-only policy, shared skeleton keys, stale invite/access races.  
**Research:** **Required**—source-level authorization audit and executable matrix.

### Phase 3: Core Conversation Vertical Slice
**Rationale:** Prove smallest end-to-end community loop before adding files or federation.  
**Delivers:** public member-write relay, anonymous read, public town square, access-controlled rooms, notes/replies/reactions/long-form, NIP-50 search, coherent branded onboarding/status portal, canonical client deep links, Nostrord baseline, Flotilla/Jumble bake-off builds, signer matrix, exact destination leak tests, active-state deletion, and replaceable client adapters whose state is non-authoritative.
**Addresses:** weekly conversation table stakes and BYOK compatibility.  
**Avoids:** NIP-checkbox support, NIP-29-as-E2EE, multi-relay leakage, search shadow copies.  
**Research:** **Required**—client/signer behavior is low-confidence and NIP-29 is draft.

### Phase 4: Resilience and Operational Contract
**Rationale:** Cohort expansion must not precede recoverability or incident ownership.  
**Delivers:** consistent Pyramid snapshots; encrypted off-provider restic; blank-host restore; measured RPO/RTO; deletion aging; reindex/upgrade/rollback/reboot drills; protocol canaries; alerts; moderation/incident/handover runbooks exercised by both operators.  
**Addresses:** reliability, deletion, observability, backup/restore, operator continuity.  
**Avoids:** green-but-incoherent backups, single-VPS “HA,” resurrection after restore, untested upgrade.  
**Research:** **Required**—Pyramid mmap snapshot semantics and any later replica design.

### Phase 5: Public Media and Abuse-Safe Files
**Rationale:** General-purpose uploads greatly expand resource, privacy, and legal risk; add only after core authority and recovery work.  
**Delivers:** isolated Blossom origin; roster bridge; per-user/global quotas; MIME/size/quarantine/report/delete policy; malware/content handling; capacity forecasting; media backup/restore; client upload matrix. Private-room sensitive attachments remain disabled.  
**Addresses:** general-purpose public media/files and safe-attachment guardrail.  
**Avoids:** public plaintext private files, disk/heap/egress exhaustion, auth replay, illegal-content improvisation.  
**Research:** **Required**—server/backend audit, quota bridge, content-safety tooling, counsel-approved operations.

### Phase 6: Public Discovery, Curation, and Federation
**Rationale:** Local conversation and deletion semantics must work before outside content can amplify or pollute the system.  
**Delivers:** chronological All feed, signed manual Best-of, member directory, direct-query external discovery with provenance; optional bounded aggregate sidecar only after measured need; deletion/tombstone/moderation propagation and lag monitoring.  
**Addresses:** public influence, editorial showcase, portability, external member posts.  
**Avoids:** engagement ranking, silent copying, private/protected imports, duplicate/resurrected events, SSRF relay hints.  
**Research:** **Required** if materialized aggregation or Pyramid favorites patch is chosen; direct-query feed patterns otherwise standard.

### Phase 7: Thirty-Day Alumni Pilot and Public Launch Gate
**Rationale:** Production-shaped evidence—not elapsed time—determines readiness.  
**Delivers:** staged cohort expansion; facilitation rituals; adoption/quality feedback; 500-WebSocket and 20-writes/s load evidence; media pressure test; 180-cell client/signer/flow compatibility matrix; hosted-client selection evidence; security review/threat model; full restore and two-operator handover; actual cost forecast; zero unresolved critical/high findings.  
**Addresses:** 80 onboarded/40 weekly-active direction, conversation quality, public-launch confidence.  
**Avoids:** empty technically-correct network, custom-client reflex, calendar-driven launch.  
**Research:** standard pilot practice; thresholds must be fixed before observation.

### Phase 8: Post-Launch Expansion and Education
**Rationale:** Extensions should follow demonstrated conversation habit and stable operations.  
**Delivers:** pinned static Jumble public-feed trial; evidence-gated web-only Flotilla hardening fork and workspace trial; badges/community map, events/V4V/governance, selected NIP-34/GRASP, optional LiveKit, sanitized educational site/NIP-23 series/quickstart, and publication decision. Separate future research tracks cover replica, Marmot/MLS E2EE, encrypted group media, and custom client.
**Addresses:** differentiators and reusable-reference objective.  
**Avoids:** empty feature surfaces, Pyramid monolith, premature code publication, unaudited crypto, and alpha runtime productization on the launch critical path.
**Research:** **Required** for E2EE/private media/replica/custom client; ordinary educational publishing can use established patterns. Napplet/headless-applet work requires a separate project.

### Phase Ordering Rationale

- Governance fixes the meaning of member, administrator, private, deletion, abuse, and retention before code encodes them.
- Hardened ingress and supply chain precede exposure; safe authority precedes users; core text conversation precedes media and federation.
- Recovery must be proven before a broad cohort can create irreplaceable state.
- Media adds the largest legal/resource surface; federation adds the largest provenance/deletion surface.
- Pilot tests the complete production-shaped system and community habit; public opening is quality-gated.
- E2EE, Git, live media, replica, education, and custom client remain independently replaceable later work.

### Public Stability Gate

Public opening requires retained evidence of all of the following:

1. Thirty-day alumni pilot meeting predeclared availability, adoption, conversation-quality, moderation-load, and operator-burden criteria.
2. Blank-host full restore with measured RPO/RTO, deletion-aging proof, and successful two-operator execution.
3. Load above expected use, including 500 WSS, 20 writes/s for 15 minutes, and bounded concurrent media pressure, adjusted upward if pilot data requires.
4. Repository-grounded threat model and security review after topology freeze.
5. No unresolved critical or high-severity defects.
6. Version-pinned client/signer matrix including exact event destinations and private allow/deny tests.
7. Protocol-level monitoring and external outage detection, not merely HTTP homepage health.
8. Incident, moderation, deletion, abuse, upgrade/rollback, backup/restore, and handover runbooks exercised by both operators.
9. Secret-permission and admin-session blockers fixed and regression-tested.
10. Thirty-day disk/egress/backup/restore forecast with contingency below US$100/month.

### Research Flags

**Deeper phase research required:** Phase -1 needs only current-pin and executable acceptance research; Phases 0–6 need the explicit gates above; Phase 8 needs research for E2EE, private media, replica, NIP-34, LiveKit, or custom-client work.

**Standard patterns; skip dedicated research unless scope changes:** static public website, conventional Caddy routing after URLs are fixed, ordinary journald/Prometheus wiring, manual editorial workflow, pilot facilitation mechanics, and post-launch NIP-23 educational publishing. Even these still require project-specific acceptance tests.

## Confidence Assessment

| Area | Confidence | Notes |
|---|---|---|
| Stack | MEDIUM | Exact current repositories/releases and source were checked; Pyramid and several companions are fast-moving, and deployment pins may already be stale when implementation begins. |
| Features | MEDIUM | Official NIPs/current client sources support the decomposition; negative claims mean “not found,” and actual workflow demand needs pilot data. |
| Architecture | MEDIUM | Boundaries use established system patterns and direct Pyramid source evidence; snapshot consistency, final provider, media bridge, and federation remain unproven. |
| Pitfalls | MEDIUM | Pyramid/admin/privacy/deletion findings are source-backed; deployment impact needs executable verification. Legal applicability is LOW pending facts and counsel. |
| Client/signer compatibility | LOW | Claims and source inspection exist, but no pairwise production-shaped matrix has run. |
| Cost/capacity | MEDIUM | Current anchors fit budget; media/egress/mmap behavior and provider choice require measurement. |

**Overall confidence:** MEDIUM

### Stale or Unverified Components

- Pyramid v1.3.2: exact inspected pin, but released 2026-07-29 and lacks LTS/stability assurance; re-audit latest candidate rather than silently upgrading.
- Flotilla: active, but Pyramid contains a client-specific NIP-77 workaround; pinned-build tests required.
- Nostrord: explicit Pyramid claims, but iOS remains in development and live matrix is absent.
- Nostrum/iOS NIP-46: alpha/reference maturity; not a production recommendation yet.
- `hzrd149/blossom-server` v6.2.0: strong modular target, but dynamic Pyramid roster and aggregate quota bridge do not exist as verified turnkey functionality.
- Route96 v0.7.0: richer policies but pre-1.0 and MariaDB-heavy; not default.
- NIP-29, NIP-34, Marmot/MLS paths: draft/optional or evolving; re-check exact specifications and clients per phase.
- NIP-5D and most needed NAPs: draft; exact proposal heads may move and must be repinned together.
- `napplet/web` at `03ad65b…`: alpha SDK with known relay/search contract drift; not a host runtime.
- `kehto/web` at `3a4d71a…`: early-alpha reference runtime with no-op/in-memory starting adapters and incomplete notification/security/production integration.
- Pyramid NIP-86 coverage, live mmap snapshot consistency, complete deletion semantics, and readiness/metrics endpoints: incomplete or unverified.

### Gaps to Address

- Exact privileged endpoint inventory and secure admin-session implementation.
- Exact Pyramid settings/migration/storage compatibility across upgrades and rollback.
- Provider/jurisdiction/legal operator, abuse duties, and backup location.
- Root/admin/alumni/friend/group capability matrix and whether a policy patch is required.
- General Blossom roster/quota/quarantine implementation and arbitrary MIME behavior.
- Private group encryption/key distribution/media protocol and audited compatible clients.
- Query-time federation UX/performance and evidence threshold for copied aggregation.
- NIP-05 ownership/rename/departure behavior and final domain layout.
- Client/signer triples, auto-update behavior, exact group destinations, notifications, and deletion flows.
- Roster/data reconciliation for badges/directory and Best-of authorization mechanism.
- Final name, GitHub owner/repository identity, and post-launch publication model.
- Versioned replaceable conventional client-adapter contracts and removal/security/utility acceptance evidence.

## Sources

### Primary Protocol and Implementation Sources

- [Pyramid repository](https://github.com/fiatjaf/pyramid), [v1.3.2](https://github.com/fiatjaf/pyramid/releases/tag/v1.3.2), [settings/permission source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/global/settings.go#L465-L475), [private group query filter](https://github.com/fiatjaf/pyramid/blob/v1.3.2/groups/queries.go#L63-L97), [raw sync target](https://github.com/fiatjaf/pyramid/blob/v1.3.2/sync.go#L55-L80), and [optional feature registration](https://github.com/fiatjaf/pyramid/blob/v1.3.2/main.go#L487-L548).
- Official Nostr specifications: [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md), [NIP-09](https://github.com/nostr-protocol/nips/blob/master/09.md), [NIP-17](https://github.com/nostr-protocol/nips/blob/master/17.md), [NIP-29](https://github.com/nostr-protocol/nips/blob/master/29.md), [NIP-34](https://github.com/nostr-protocol/nips/blob/master/34.md), [NIP-42](https://github.com/nostr-protocol/nips/blob/master/42.md), [NIP-46](https://github.com/nostr-protocol/nips/blob/master/46.md), [NIP-50](https://github.com/nostr-protocol/nips/blob/master/50.md), [NIP-55](https://github.com/nostr-protocol/nips/blob/master/55.md), [NIP-62](https://github.com/nostr-protocol/nips/blob/master/62.md), [NIP-65](https://github.com/nostr-protocol/nips/blob/master/65.md), [NIP-70](https://github.com/nostr-protocol/nips/blob/master/70.md), [NIP-77](https://github.com/nostr-protocol/nips/blob/master/77.md), [NIP-86](https://github.com/nostr-protocol/nips/blob/master/86.md), and [NIP-98](https://github.com/nostr-protocol/nips/blob/master/98.md).
- [Blossom protocol](https://github.com/hzrd149/blossom), [Blossom Server](https://github.com/hzrd149/blossom-server), and [Marmot protocol](https://github.com/parres-hq/marmot).
- Napplet/Kehto: [`napplet/naps` at `5ac0490…`](https://github.com/napplet/naps/tree/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24), [`napplet/web` at `03ad65b…`](https://github.com/napplet/web/tree/03ad65b66413e5798536ef48695ffc4c2508f2c3), [`kehto/web` at `3a4d71a…`](https://github.com/kehto/web/tree/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f), and [NIP-5D inspected head `eb45dfd…`](https://github.com/nostr-protocol/nips/blob/eb45dfd7335b7f88cb53781984c553581d2b4c34/5D.md).
- Current client/signer sources: [Flotilla](https://gitea.coracle.social/coracle/flotilla), [Nostrord](https://github.com/nostrord/nostrord), [Jumble](https://github.com/CodyTseng/jumble), [nos2x](https://github.com/fiatjaf/nos2x), [nos2x-fox](https://github.com/diegogurpegui/nos2x-fox), [Amber](https://github.com/greenart7c3/Amber), and [Nostrum](https://github.com/nostr-connect/nostrum).

### Operations and Cost Sources

- [Caddy reverse proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy), [systemd credentials](https://systemd.io/CREDENTIALS/), and [restic documentation](https://restic.readthedocs.io/en/stable/).
- [Prometheus](https://prometheus.io/), [node_exporter](https://prometheus.io/docs/guides/node-exporter/), [blackbox_exporter](https://github.com/prometheus/blackbox_exporter), and [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/).
- Current pricing anchors: [Akamai Cloud](https://www.akamai.com/cloud/pricing) and [Backblaze B2](https://www.backblaze.com/cloud-storage/pricing).

### Legal/Policy Sources—Applicability Unresolved

- [18 U.S.C. §2258A](https://uscode.house.gov/view.xhtml?edition=2023&num=0&req=granuleid%3AUSC-2023-title18-section2258A), [US Copyright Office DMCA resources](https://www.copyright.gov/dmca/), and [EU Digital Services Act](https://eur-lex.europa.eu/eli/reg/2022/2065/oj). These identify questions only; they do not establish which duties apply.

---
*Research completed: 2026-07-30*
*Ready for roadmap: yes, subject to Phase 0 decision gates*
