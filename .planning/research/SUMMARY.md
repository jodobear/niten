# Project Research Summary

**Project:** Sovereign Engineering Nostr Community Infrastructure
**Domain:** Modular, Pyramid-centered sovereign Nostr community infrastructure
**Researched:** 2026-07-30
**Confidence:** MEDIUM

## Executive Summary

This is not a conventional community application and should not be planned as one. It is a small sovereign network composed from a relay/community authority, existing Nostr clients and external signers, a separate media service, and thin discovery/administration surfaces. The canonical relay is [`fiatjaf/pyramid`](https://github.com/fiatjaf/pyramid), not the older `github-tijlxyz/khatru-pyramid`. Research inspected Pyramid **v1.3.2**, commit `e12e81641bfe6cacc6dd246e9433d602c1240e66`, released 2026-07-29. It natively provides the membership hierarchy, public/member relay paths, NIP-29 groups, NIP-42 authentication, NIP-86 administration subset, NIP-05, NIP-50 search, moderation, and memory-mapped `mmm` event storage needed for the core. It is also young, fast-moving, and not production-safe unchanged: its secret-bearing `settings.json` is saved with mode `0644`, and its browser admin session design has long-lived replay and web-session weaknesses. Both are pre-pilot blockers, not later hardening tasks.

Recommended v1 is deliberately modular: native Pyramid binary under `systemd` on Debian 13.6, loopback-only behind Caddy 2.11.4; standalone Blossom on an isolated origin after its roster/quota bridge is proven; restic to an independent S3-compatible backup target; journald plus Prometheus/exporters/Alertmanager; static onboarding/status/public-discovery surfaces; existing clients and member-controlled signers. Nostrord should be the pinned NIP-29 reference/compatibility client, Flotilla the preferred alumni workspace only after it passes the complete privacy and signer matrix, and Jumble the public chronological feed/long-form front door. This resolves a source conflict: feature research favored Flotilla as default UX, while stack research favored Nostrord as the launch pilot. They serve different jobs. Do not self-host every client or build a custom client before pilot evidence.

The main risks are false security promises, immature admin behavior, policy/role mismatch, deletion resurrection, private-event routing leaks, unbounded public media, and backups that cannot restore coherent state. NIP-29 `private` means relay-enforced access control—not E2EE—and ordinary multi-relay clients can still misroute plaintext. Private-room attachments must therefore remain disabled for sensitive content until an audited encrypted-group and encrypted-media design exists. A single 4-vCPU/8-GB/160-GB VPS plus offsite backup is feasible below US$100/month: base estimates are roughly $30–70, while a conservative all-in estimate with contingency is $61–91. The margin is narrow enough that actual media, egress, backup, and restore measurements are release gates.

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

Detailed evidence lives in [STACK.md](./STACK.md), [FEATURES.md](./FEATURES.md), [ARCHITECTURE.md](./ARCHITECTURE.md), and [PITFALLS.md](./PITFALLS.md).

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

Use a single-host modular architecture with strict trust and state boundaries. Caddy is the only public listener. Pyramid alone writes member/group/relay state. Blossom alone writes blob metadata/files. Any aggregator owns only provenance/checkpoints and sends unchanged events through WSS. Curator owns signed selection decisions. Static web owns no authority. Backup and monitoring use their own identities and retention. Separate Unix users, writable paths, credentials, quotas, logs, and restore procedures make services replaceable without pretending a single VPS is highly available.

**Major components:**

1. **Ingress (Caddy)** — TLS, WSS routing, coarse limits, canonical headers, access logging; no Nostr authorization.
2. **Pyramid core** — membership hierarchy, relay policy, NIP-29, authentication, administration, moderation, event/search state.
3. **Thin onboarding/admin web** — client/signer discovery, roster/role UX, privacy language, NIP-05/Best-of/status navigation; signed calls, no key custody.
4. **Standalone Blossom** — public blobs, signed upload/delete, quotas, reports, quarantine, retention, backup.
5. **Federation/curation sidecars** — optional bounded public-event import and admin-signed manual projection; no private payloads or signature rewriting.
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
- Define success gates for adoption and conversation quality alongside availability; no custom-client scope without failed-job evidence.
- Record final name, domain layout, GitHub owner/repository name, provider, jurisdiction, and publication strategy as explicit decision records before dependent work.

## Implications for Roadmap

### Phase 0: Governance, Brand, and Operating Decisions
**Rationale:** Provider, legal, identity, retention, and naming choices constrain every later interface and policy.  
**Delivers:** legal-operator/provider/AUP decision; data classification; privacy/deletion/retention/abuse policies; capability matrix; two-operator model; name/domain/NIP-05/GitHub decision; threat-boundary draft.  
**Addresses:** authoritative roster, roles, admin-only admission, brand, portability.  
**Avoids:** labels-as-ACL, false privacy/deletion promises, provider suspension, premature remote identity.  
**Research:** **Required**—jurisdiction-specific counsel/provider review and naming clearance.

### Phase 1: Reproducible Hardened Foundation
**Rationale:** No application behavior is trustworthy until release provenance, secrets, ingress, and rollback boundaries exist.  
**Delivers:** dedicated VPS baseline; Debian/systemd/nftables/Caddy; pinned Pyramid build and checksum; narrow fork/patch ledger; `0600` settings fix; loopback origins; secret handling; baseline limits/monitoring; disposable staging deploy.  
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
**Delivers:** public member-write relay, anonymous read, public town square, access-controlled rooms, notes/replies/reactions/long-form, NIP-50 search, onboarding/status site, Nostrord baseline, Flotilla/Jumble pilots, signer matrix, exact destination leak tests, active-state deletion.  
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
**Delivers:** staged cohort expansion; facilitation rituals; adoption/quality feedback; 500-WebSocket and 20-writes/s load evidence; media pressure test; compatibility matrix; security review/threat model; full restore and two-operator handover; actual cost forecast; zero unresolved critical/high findings.  
**Addresses:** 80 onboarded/40 weekly-active direction, conversation quality, public-launch confidence.  
**Avoids:** empty technically-correct network, custom-client reflex, calendar-driven launch.  
**Research:** standard pilot practice; thresholds must be fixed before observation.

### Phase 8: Post-Launch Expansion and Education
**Rationale:** Extensions should follow demonstrated conversation habit and stable operations.  
**Delivers:** badges/community map, events/V4V/governance, selected NIP-34/GRASP, optional LiveKit, sanitized educational site/NIP-23 series/quickstart, publication decision. Separate future research tracks cover replica, Marmot/MLS E2EE, encrypted group media, and custom client.  
**Addresses:** differentiators and reusable-reference objective.  
**Avoids:** empty feature surfaces, Pyramid monolith, premature code publication, unaudited crypto.  
**Research:** **Required** for E2EE/private media/replica/custom client; ordinary educational publishing can use established patterns.

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

**Deeper phase research required:** Phases 0–6 for the explicit gates above; Phase 8 for E2EE, private media, replica, NIP-34, LiveKit, or custom-client work.

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

## Sources

### Primary Protocol and Implementation Sources

- [Pyramid repository](https://github.com/fiatjaf/pyramid), [v1.3.2](https://github.com/fiatjaf/pyramid/releases/tag/v1.3.2), [settings/permission source](https://github.com/fiatjaf/pyramid/blob/v1.3.2/global/settings.go#L465-L475), [private group query filter](https://github.com/fiatjaf/pyramid/blob/v1.3.2/groups/queries.go#L63-L97), [raw sync target](https://github.com/fiatjaf/pyramid/blob/v1.3.2/sync.go#L55-L80), and [optional feature registration](https://github.com/fiatjaf/pyramid/blob/v1.3.2/main.go#L487-L548).
- Official Nostr specifications: [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md), [NIP-09](https://github.com/nostr-protocol/nips/blob/master/09.md), [NIP-17](https://github.com/nostr-protocol/nips/blob/master/17.md), [NIP-29](https://github.com/nostr-protocol/nips/blob/master/29.md), [NIP-34](https://github.com/nostr-protocol/nips/blob/master/34.md), [NIP-42](https://github.com/nostr-protocol/nips/blob/master/42.md), [NIP-46](https://github.com/nostr-protocol/nips/blob/master/46.md), [NIP-50](https://github.com/nostr-protocol/nips/blob/master/50.md), [NIP-55](https://github.com/nostr-protocol/nips/blob/master/55.md), [NIP-62](https://github.com/nostr-protocol/nips/blob/master/62.md), [NIP-65](https://github.com/nostr-protocol/nips/blob/master/65.md), [NIP-70](https://github.com/nostr-protocol/nips/blob/master/70.md), [NIP-77](https://github.com/nostr-protocol/nips/blob/master/77.md), [NIP-86](https://github.com/nostr-protocol/nips/blob/master/86.md), and [NIP-98](https://github.com/nostr-protocol/nips/blob/master/98.md).
- [Blossom protocol](https://github.com/hzrd149/blossom), [Blossom Server](https://github.com/hzrd149/blossom-server), and [Marmot protocol](https://github.com/parres-hq/marmot).
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
