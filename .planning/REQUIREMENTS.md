# Requirements: Sovereign Engineering Nostr Community Infrastructure

**Working title:** Dialogos (not final)  
**Defined:** 2026-07-30  
**Core Value:** Give Sovereign Engineering alumni a reliable, high-signal online town square they choose to use every week without surrendering identity, keys, portability, or exit.

## v1 Requirements

### Stock Pyramid Discovery Pilot

- [ ] **PILOT-01**: Operators can reproduce and deploy an exact pinned upstream Pyramid release/commit without modifying its source, recording the upstream repository, tag, commit, checksum, build/runtime versions, and effective configuration.
- [ ] **PILOT-02**: The discovery host runs only the minimum live-testing envelope: Caddy/TLS, a loopback-bound Pyramid process under systemd, least-privilege state paths, bounded journald logs, a recoverable backup, and a documented rollback to the previous known-good artifact/state.
- [ ] **PILOT-03**: Stock Pyramid browser administration is not exposed as a general public surface; operator access is restricted to an approved private path while existing clients exercise ordinary group/member workflows.
- [ ] **PILOT-04**: A small named cohort of testing alumni can connect to the pilot through existing Nostr clients and member-controlled NIP-07, NIP-46, or NIP-55 signers without giving keys to project infrastructure.
- [ ] **PILOT-05**: The cohort exercises stock Pyramid membership, invitations, public/restricted/private group behavior, roles, NIP-42 authentication, NIP-50 search, notes/replies/reactions, deletion, reconnect, and rejection/error paths that supported clients expose.
- [ ] **PILOT-06**: Operators retain exact client/signer/Pyramid pass-fail evidence, destination captures for access-controlled content, operational observations, participant workflow feedback, and a categorized list of native capability, configuration need, defect, client gap, and genuinely missing product requirement.
- [ ] **PILOT-07**: Standalone Blossom, hosted community clients, public-event aggregation, custom curation, companion APIs, Pyramid source patches, and other product services are not discovery-pilot dependencies; each requires evidence and a new planning decision after the pilot.
- [ ] **PILOT-08**: The discovery review selects the next milestone from retained evidence and can discard/redeploy the pilot without making member identity, keys, or external Nostr content dependent on the experimental host.

### Governance and Product Identity

- [ ] **GOV-01**: Operators can identify the legal operator, VPS provider, hosting region, applicable jurisdiction, provider AUP, abuse contact, and offsite-backup region before production data is accepted.
- [ ] **GOV-02**: Project records a final community name, brand relationship to Sovereign Engineering, primary domain, service subdomains, NIP-05 namespace, GitHub owner, and repository name before permanent public URLs or remote repository are created.
- [ ] **GOV-03**: Members can read plain-language policies describing public content, access-controlled operator-readable rooms, moderation scope, deletion limits, retention, backups, federation, and private-attachment restrictions before joining.
- [ ] **GOV-04**: Operators can apply a published capability matrix that distinguishes root operator, administrator, alumni, invited friend, public reader, and service identities for every privileged action.
- [ ] **GOV-05**: Pyramid remains the sole authority for membership, invitations, community roles, group policy, moderation, accepted community events, and canonical relay search.
- [ ] **GOV-06**: Public launch is blocked until every documented stability gate has current retained evidence, regardless of elapsed calendar time.

### Pyramid Supply Chain and Security

- [ ] **SEC-01**: Operators can reproduce the selected Pyramid build from a pinned release and commit with recorded checksum, dependency inventory or SBOM, build instructions, and source provenance.
- [ ] **SEC-02**: Pyramid secret-bearing settings are written with mode `0600`, their parent/data directories use least-privilege permissions, and a recurring automated test detects permission regression.
- [ ] **SEC-03**: Browser administration uses validated one-time NIP-98 authentication, short-lived server-side `Secure`/`HttpOnly`/`SameSite` sessions, CSRF protection, step-up checks for destructive actions, and no replayable long-lived browser bearer.
- [ ] **SEC-04**: Every privileged Pyramid endpoint has a repository-grounded authorization audit and executable allow/deny tests derived from the capability matrix.
- [ ] **SEC-05**: Caddy is the only public listener; Pyramid, Blossom, admin, metrics, and other backends bind to loopback or a private operator network.
- [ ] **SEC-06**: Member keys, operator signing keys, raw `nsec`s, bunker URIs, and signer connection secrets are absent from VPS files, logs, metrics, backups, and support bundles.
- [ ] **SEC-07**: Unneeded Pyramid modules with broad network or resource risk—including link preview, image proxy, SFTP, arbitrary relay fetch, LiveKit, paywall, and auto-update—remain disabled until separately approved and tested.

### Membership, Identity, and Recognition

- [ ] **MEM-01**: An administrator can add an approved alumnus `npub` to the authoritative roster without requiring email identity.
- [ ] **MEM-02**: Only administrators can issue or approve invited-friend membership; alumni and friends cannot recursively invite friends.
- [ ] **MEM-03**: Public readers can distinguish alumni, invited friends, administrators, and service identities without treating display labels or badges as authorization.
- [ ] **MEM-04**: Two independent root operators can administer membership and complete a tested recovery and handover flow without sharing a member or operator private key.
- [ ] **MEM-05**: A member can claim a community NIP-05 identifier under a documented reservation, rename, revocation, departure, and collision policy.
- [ ] **MEM-06**: A member can receive an NIP-58 alumni or invited-friend badge derived from the authoritative roster, with an operator-tested correction and revocation process.
- [ ] **MEM-07**: A member can find other opted-in members through a minimal searchable directory while controlling optional cohort, skills, project, and profile metadata.

### Conversation and Community Experience

- [ ] **CONV-01**: A public visitor can read the chronological public feed without membership or authentication.
- [ ] **CONV-02**: Only approved alumni, invited friends, administrators, and explicitly authorized service identities can publish to the community relay.
- [ ] **CONV-03**: A public visitor can browse an unranked reverse-chronological feed scoped to approved member authors.
- [ ] **CONV-04**: An authorized editor can curate a manual “Best of” surface that preserves each selected event's original author, ID, signature, and source.
- [ ] **CONV-05**: A member can join and participate in a public NIP-29 town-square group using a supported client.
- [ ] **CONV-06**: An authorized alumnus can read and participate in access-controlled alumni rooms while unauthorized and anonymous readers are denied.
- [ ] **CONV-07**: Every access-controlled room is labeled as operator-readable and not end-to-end encrypted before a member posts.
- [ ] **CONV-08**: A member can publish and read public notes, replies, and reactions through the supported client set.
- [ ] **CONV-09**: A member can publish and read NIP-23 long-form posts with Markdown and public Blossom references.
- [ ] **CONV-10**: A member can search public and authorized private content through NIP-50 without receiving results outside their read permissions.
- [ ] **CONV-11**: A member can receive supported-client notifications or unread indicators and can use mute/block controls without server-side behavioral profiling.

### Keys, Signers, and Client Compatibility

- [ ] **CLNT-01**: A member can use their existing Nostr key through nos2x, nos2x Firefox, Amber, a selected iOS NIP-46 signer, or a member-chosen NIP-46 bunker without giving a raw private key to community infrastructure.
- [ ] **CLNT-02**: Operators maintain a pinned compatibility matrix for Pyramid with Flotilla, Nostrord, and Jumble across the approved signer paths.
- [ ] **CLNT-03**: Each approved client/signer/relay triple passes login, reconnect, public publishing, invitation, role, private-read allow/deny, search, upload, delete, rejection, and error-behavior tests relevant to that client.
- [ ] **CLNT-04**: Exact outbound destination capture proves public events reach only member-selected public relays and access-controlled events never reach trap/public relays.
- [ ] **CLNT-05**: The onboarding site recommends signer-based login and never presents raw `nsec` paste as the normal path.

### Hosted UI and Experience Coherence

- [ ] **UI-01**: A branded community portal gives public readers and members one coherent entry point for onboarding, signer/client selection, privacy guidance, status, directory, badges, Best-of, and help without retaining signer or authorization state.
- [ ] **UI-02**: Approved clients share documented visual tokens, terminology, privacy language, and canonical `nprofile`, `nevent`, `naddr`, and NIP-29 group deep-link behavior while remaining independently replaceable.
- [ ] **UI-03**: Each self-hosted client uses a separate origin with its own CSP, service worker, browser storage, signer permission, and rollback boundary; independent clients are neither iframed nor mounted under paths on a shared origin.
- [ ] **UI-04**: A self-hosted web client is served as a pinned immutable static artifact by Caddy and adds no long-lived server process, server-side store, signer custody, membership database, or Nostr authority.
- [ ] **UI-05**: Every hosted-client release has reproducible frozen-lockfile builds, checksums, SBOM and provenance, an explicit outbound endpoint allowlist, no unapproved analytics or third-party services, compatibility evidence, and tested service-worker/cache rollback.
- [ ] **UI-06**: After the core pilot, operators can trial one pinned public-feed client on its own origin and can remove it without changing Pyramid, Blossom, identities, memberships, or events.
- [ ] **UI-07**: A downstream client fork remains web/PWA-only and narrowly limited to branding, approved endpoint defaults, privacy hardening, deep links, and proven interoperability gaps; it begins only after repeated measured workflow failure, no timely configuration/upstream fix, and two maintainers accept a 12-month maintenance budget.

### Public Media and General Files

- [ ] **MEDIA-01**: A standalone Blossom service operates on an isolated origin and remains independently replaceable from Pyramid.
- [ ] **MEDIA-02**: An approved member can upload and retrieve allowed general-purpose files—including images, audio, video, PDFs, documents, archives, and technical artifacts—through signed Blossom authorization.
- [ ] **MEDIA-03**: Blossom enforces per-file, per-member, daily, concurrent, bandwidth, and global storage limits with high-water behavior that protects relay availability.
- [ ] **MEDIA-04**: Upload handling verifies content hashes, detects actual MIME type, applies explicit size/type policy, and supports quarantine, reporting, operator review, and deletion.
- [ ] **MEDIA-05**: Operators can revoke a member's upload access from the Pyramid-authoritative roster without maintaining an independent long-lived role database in Blossom.
- [ ] **MEDIA-06**: Operators can back up and restore Blossom metadata and objects and can prove member ownership, deletion, and integrity after a blank-host restore.
- [ ] **MEDIA-07**: Clients and onboarding prevent sensitive plaintext attachments in access-controlled rooms; private-room media stays unavailable until an audited encrypted design is approved.

### Federation, Portability, and Deletion

- [ ] **FED-01**: A member can publish the same signed public event to any public relays configured in their client without server-forced replication.
- [ ] **FED-02**: The community experience can discover approved members' public events from bounded, allowlisted external relays through direct queries that preserve event identity and source provenance.
- [ ] **FED-03**: Inward discovery rejects NIP-29 group/control events, NIP-17/59 private messaging, NIP-70 protected events, private/protected relay paths, unknown-policy events, invalid signatures, and non-member authors.
- [ ] **FED-04**: Direct-query aggregation deduplicates by event ID, bounds relays/authors/time/results/concurrency, reports incomplete sources, and cannot write Pyramid storage directly.
- [ ] **FED-05**: Valid local deletion requests remove active events and derived search/curation/directory state, preserve tombstones against resurrection, document remote-copy limits, and age deleted data out of backups on schedule.

### Deployment, Reliability, and Operations

- [ ] **OPS-01**: Operators can deploy the stack reproducibly to a fresh dedicated Debian VPS using native systemd services, least-privilege Unix users, explicit writable paths, and nftables-host firewalling.
- [ ] **OPS-02**: Initial production topology runs Caddy, Pyramid, standalone Blossom, node_exporter, blackbox_exporter, Prometheus, and Alertmanager as seven always-on processes without introducing a second community relay authority.
- [ ] **OPS-03**: Service URLs use separately testable flat origins for community web, relay, media/files, and external status; final names are chosen only after compatibility and brand checks.
- [ ] **OPS-04**: Operators can observe protocol-level relay health, WebSocket acceptance, authenticated and anonymous read paths, disk, memory, CPU, file descriptors, event writes, search, media capacity, backup freshness, and certificate expiry.
- [ ] **OPS-05**: Logs, metrics, alerts, and exported evidence use allowlisted fields, bounded retention, and automated canary scans for event bodies, invite material, signer secrets, NIP-46/NIP-98 data, and private content.
- [ ] **OPS-06**: Encrypted backups are written to a provider or failure domain independent from the VPS and are checked and pruned under a documented retention policy.
- [ ] **OPS-07**: Both operators can restore a blank host and verify Pyramid roles, groups, public/private access, event signatures, search, Blossom ownership, tombstones, indexes, and full client flows within measured RPO/RTO.
- [ ] **OPS-08**: Operators can stage, upgrade, migrate, roll back, and reboot every service using pinned artifacts without automatic updates or incompatible silent state changes.
- [ ] **OPS-09**: Incident, moderation, abuse, deletion, backup, restore, upgrade, rollback, capacity, credential rotation, and operator-handover runbooks are exercised by both operators.
- [ ] **OPS-10**: Load tests sustain at least 500 WebSocket connections and 20 event writes per second for 15 minutes, plus bounded concurrent media pressure, without privacy or authorization failure.
- [ ] **OPS-11**: A 30-day internal alumni pilot runs concurrently with hardening, compatibility, recovery, load, security, and operational work; deployment and live testing do not wait for those workstreams to finish.
- [ ] **OPS-12**: Public opening occurs only after the 30-day pilot, restore drill, load evidence, repository-grounded threat model/security review, full compatibility matrix, exercised runbooks, fixed Pyramid secret/admin blockers, no unresolved critical/high defects, and a measured monthly forecast below US$100.

### Post-Core Community Expansion

- [ ] **EXT-01**: Members can opt into a richer community map showing cohorts, skills, projects, interests, and recent public work without creating a second identity authority.
- [ ] **EXT-02**: Authorized members can publish and respond to NIP-52 events and RSVPs after core conversation usage is established.
- [ ] **EXT-03**: Members can optionally send and receive value-for-value zaps without payment becoming a condition of membership, publishing, or room access.
- [ ] **EXT-04**: Members can discover community Git projects and use a separately operated Git service plus a kind-restricted NIP-34/GRASP collaboration relay without allowing ordinary social/group events into that relay.
- [ ] **EXT-05**: Any materialized public-event aggregator is added only after direct-query evidence proves a need and remains a non-public WSS client with provenance/checkpoint state rather than a second relay/search authority.

### Documentation, Repository, and Delivery Workflow

- [ ] **DOC-01**: Operators maintain a private build journal from day one containing decisions, failures, fixes, diagrams, costs, compatibility evidence, restore evidence, and upstream improvement notes.
- [ ] **DOC-02**: After stable launch, a public Sovereign Engineering website experience explains why Nostr fits sovereign communities and how the deployed architecture protects keys, portability, inspectability, and exit.
- [ ] **DOC-03**: After stable launch, another community can follow a sanitized quickstart to reproduce a basic deployment and understand production trade-offs for identity, access, moderation, media, backups, and federation.
- [ ] **DOC-04**: After stable launch, the project publishes a Nostr long-form series derived from verified build evidence rather than pre-launch claims.
- [ ] **DOC-05**: After stable launch, operators decide whether and how to publish a cloneable repository while excluding secrets, member data, live operational credentials, and unsafe defaults.
- [ ] **DOC-06**: Once naming and ownership are approved, implementation work uses contextual GitHub issues, `agent/*` branches, narrow commits, draft pull requests, relevant checks, external Codex review polling, actionable-finding fixes, and retained verification before merge.

### Success Measurement

- [ ] **MET-01**: Operators can measure aggregate onboarded members, weekly active `npub`s, event volume, room activity, storage, latency, uptime, moderation load, and operator burden without behavioral profiling.
- [ ] **MET-02**: Operators collect periodic qualitative alumni feedback about belonging, conversation quality, client friction, missing workflows, and reasons for returning or disengaging.
- [ ] **MET-03**: Six months after public launch, the project can evaluate progress against 80 alumni onboarded, 40 weekly active alumni, and approximately 20 invited friends, with adoption prioritized over conversation quality, public influence, and reference reuse in that order.

## v2 Requirements

### Encrypted Community Spaces

- **E2EE-01**: Members can use audited interoperable end-to-end encrypted group rooms after protocol, client, key-rotation, multi-device, removal, recovery, metadata, and security review gates pass.
- **E2EE-02**: Members can attach encrypted files to E2EE group rooms without exposing plaintext, decryption metadata, membership, or blob authority to unauthorized parties.

### Advanced Resilience and Clients

- **RES-01**: Operators can deploy a NIP-29-aware live replica or failover design after coherent-state, group-policy, deletion, and split-brain semantics are proven.
- **CLIENT-01**: Members can use a full custom community client only after measured workflow failures show existing clients plus the thin companion surface cannot achieve the product goal and maintenance ownership is approved.

### Deferred Community Capabilities

- **GOVR-01**: Members can participate in advisory proposals and polls under a documented human decision process.
- **LIVE-01**: Members can host live audio/video rooms after demand, consent, moderation, TURN/network, capacity, and operational reviews pass.
- **NOTF-01**: Members can opt into a privacy-minimized digest only if pilot evidence shows client-native notifications are insufficient.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Napplet/Kehto integration, hosted headless community applets, or Napplet architecture prototyping | This is a distinct possible future product direction and is wholly outside this project's roadmap; this project uses stock Pyramid and existing clients first. |
| Mandatory payments or paid membership tiers | Community follows value for value; belonging and participation are never paywalled. |
| Dialogos-hosted keys or bunker service | Members bring their own keys and choose their own signer/bunker. |
| Pyramid as a monolith for every optional service | Separate operational and data lifecycles remain replaceable under Unix philosophy. |
| Engagement-ranked default feed | Project uses chronology plus explicit manual curation, not attention-economy incentives. |
| Automated AI moderation or reputation scoring | Minimal human moderation and member filtering preserve inspectability and open disagreement. |
| Plaintext sensitive attachments in access-controlled rooms | NIP-29 access control is not encryption; public content-addressed blobs can leak. |
| Global deletion guarantee | Local deletion and backup aging can be enforced; remote relays and recipients may retain signed events. |
| Critical-path dependence on upstream acceptance | Upstream contributions are preferred, but delivery uses bounded patches or companion work when necessary. |
| Public release before stability evidence | Quality and security gates override schedule pressure. |
| Kubernetes or a distributed data platform for v1 | A single-host modular system meets expected scale and budget with lower operational burden. |

## Definition of Done

A v1 requirement is complete only when:

1. Its implementation is committed through the approved issue/branch/PR workflow.
2. Automated and manual acceptance checks pass against pinned production candidates.
3. Applicable privacy, authorization, deletion, recovery, and failure-path tests pass.
4. Operational evidence and runbook changes are retained.
5. External Codex review findings are polled and all actionable critical/high defects are resolved.
6. The requirement is verified against observable user or operator behavior, not only code presence.

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PILOT-01 | Phase 1 | Pending |
| PILOT-02 | Phase 1 | Pending |
| PILOT-03 | Phase 1 | Pending |
| PILOT-04 | Phase 1 | Pending |
| PILOT-05 | Phase 1 | Pending |
| PILOT-06 | Phase 1 | Pending |
| PILOT-07 | Phase 1 | Pending |
| PILOT-08 | Phase 1 | Pending |
| GOV-01 | Phase 2 | Pending |
| GOV-02 | Phase 2 | Pending |
| GOV-03 | Phase 2 | Pending |
| GOV-04 | Phase 2 | Pending |
| GOV-05 | Phase 2 | Pending |
| GOV-06 | Phase 2 | Pending |
| SEC-01 | Phase 2 | Pending |
| SEC-02 | Phase 2 | Pending |
| SEC-03 | Phase 2 | Pending |
| SEC-04 | Phase 2 | Pending |
| SEC-05 | Phase 2 | Pending |
| SEC-06 | Phase 2 | Pending |
| SEC-07 | Phase 2 | Pending |
| MEM-01 | Phase 2 | Pending |
| MEM-02 | Phase 2 | Pending |
| MEM-03 | Phase 2 | Pending |
| MEM-04 | Phase 2 | Pending |
| MEM-05 | Phase 2 | Pending |
| MEM-06 | Phase 2 | Pending |
| MEM-07 | Phase 2 | Pending |
| CONV-01 | Phase 3 | Pending |
| CONV-02 | Phase 3 | Pending |
| CONV-03 | Phase 3 | Pending |
| CONV-04 | Phase 3 | Pending |
| CONV-05 | Phase 3 | Pending |
| CONV-06 | Phase 3 | Pending |
| CONV-07 | Phase 3 | Pending |
| CONV-08 | Phase 3 | Pending |
| CONV-09 | Phase 3 | Pending |
| CONV-10 | Phase 3 | Pending |
| CONV-11 | Phase 3 | Pending |
| CLNT-01 | Phase 3 | Pending |
| CLNT-02 | Phase 3 | Pending |
| CLNT-03 | Phase 3 | Pending |
| CLNT-04 | Phase 3 | Pending |
| CLNT-05 | Phase 3 | Pending |
| UI-01 | Phase 3 | Pending |
| UI-02 | Phase 3 | Pending |
| UI-03 | Phase 3 | Pending |
| UI-04 | Phase 3 | Pending |
| UI-05 | Phase 3 | Pending |
| UI-06 | Phase 3 | Pending |
| UI-07 | Phase 3 | Pending |
| MEDIA-01 | Phase 4 | Pending |
| MEDIA-02 | Phase 4 | Pending |
| MEDIA-03 | Phase 4 | Pending |
| MEDIA-04 | Phase 4 | Pending |
| MEDIA-05 | Phase 4 | Pending |
| MEDIA-06 | Phase 4 | Pending |
| MEDIA-07 | Phase 4 | Pending |
| FED-01 | Phase 3 | Pending |
| FED-02 | Phase 4 | Pending |
| FED-03 | Phase 4 | Pending |
| FED-04 | Phase 4 | Pending |
| FED-05 | Phase 4 | Pending |
| OPS-01 | Phase 2 | Pending |
| OPS-02 | Phase 4 | Pending |
| OPS-03 | Phase 4 | Pending |
| OPS-04 | Phase 4 | Pending |
| OPS-05 | Phase 4 | Pending |
| OPS-06 | Phase 4 | Pending |
| OPS-07 | Phase 4 | Pending |
| OPS-08 | Phase 4 | Pending |
| OPS-09 | Phase 4 | Pending |
| OPS-10 | Phase 4 | Pending |
| OPS-11 | Phase 4 | Pending |
| OPS-12 | Phase 4 | Pending |
| EXT-01 | Phase 5 | Pending |
| EXT-02 | Phase 5 | Pending |
| EXT-03 | Phase 5 | Pending |
| EXT-04 | Phase 5 | Pending |
| EXT-05 | Phase 5 | Pending |
| DOC-01 | Phase 1 | Pending |
| DOC-02 | Phase 5 | Pending |
| DOC-03 | Phase 5 | Pending |
| DOC-04 | Phase 5 | Pending |
| DOC-05 | Phase 5 | Pending |
| DOC-06 | Phase 2 | Pending |
| MET-01 | Phase 5 | Pending |
| MET-02 | Phase 5 | Pending |
| MET-03 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 89 total
- Mapped to phases: 89
- Unmapped: 0
- Duplicate mappings: 0

---
*Requirements defined: 2026-07-30*
*Last updated: 2026-07-31 after roadmap creation*
