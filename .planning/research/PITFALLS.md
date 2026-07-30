# Domain Pitfalls

**Domain:** Sovereign Nostr community infrastructure using Pyramid, NIP-29 groups, inward aggregation, and Blossom
**Project:** Alumni community relay
**Researched:** 2026-07-30
**Overall confidence:** MEDIUM

## How to Read This Document

Findings use three epistemic labels:

- **Confirmed:** directly supported by the current Pyramid source, a published protocol specification, or official platform documentation.
- **Inference:** a project-specific risk derived from confirmed behavior. It must be validated in the proposed deployment.
- **Unresolved legal question:** facts that depend on the operator, legal entity, users, server and backup locations, provider, or counsel. These are decision gates, not legal conclusions.

Recommended roadmap phases used below:

| Phase | Recommended scope |
|-------|-------------------|
| 0 | Governance, threat model, jurisdiction, provider, and data policy |
| 1 | Reproducible hardened VPS, domains, TLS, proxy, secrets, and supply chain |
| 2 | Pyramid authorization and admin-session safety |
| 3 | Public relay, aggregation, deletion, and moderation correctness |
| 4 | Private groups, client compatibility, and signer safety |
| 5 | Blossom isolation, quotas, content safety, and abuse/legal operations |
| 6 | Backup, restore, observability, capacity, upgrade, and incident runbooks |
| 7 | Thirty-day pilot and quality-gated public launch |

Phase names are research recommendations; roadmap authors may renumber them, but should preserve the ordering constraints.

## Critical Pitfalls

### Pitfall 1: Treating a NIP-29 Private Group as End-to-End Encryption

**What goes wrong:** Members post sensitive plaintext believing the `private` group flag encrypts it. The relay, operators, backups, logs, and any accidentally configured destination can read or retain the content.

**Evidence/status:** **Confirmed.** NIP-29 describes access control by the hosting relay. Group events remain ordinary signed Nostr events with an `h` tag. `private` restricts reads to members; `hidden` restricts discovery of metadata. Pyramid enforces membership at query time, but its relay root remains authorized. NIP-44 explicitly does not encrypt attachments and still leaks IP, timing, and size metadata. NIP-59 gift wrapping obscures more metadata but retains routing information.

**Why it happens:** “Private” is read as a cryptographic property instead of a relay policy. Multi-relay clients also make destination mistakes easy.

**Warning signs:**

- UI copy says encrypted, confidential, secret, or only participants can read.
- A private-group event appears in a raw database export, relay log, backup, public relay, or a non-member subscription.
- Members paste plaintext secrets or upload plaintext sensitive documents.
- No operator-access disclosure exists.

**Prevention:**

- Label the first release “access-controlled, not end-to-end encrypted” in onboarding and composer UI.
- Prohibit high-sensitivity material during the pilot.
- Keep an explicit future E2EE phase; do not imply that NIP-44 alone solves group messaging or attachments.
- Separate public and private relay destinations. Default group composers to the group host only.
- Minimize operator access, logs, backup readers, and support exports.
- For sensitive attachments, require client-side encryption before Blossom or defer the workflow.

**Validation/release gate:** Create a private group and a canary event. Prove a non-member cannot query it through every hostname, path, supported client, aggregation worker, and replica. Inspect relay storage and backup to demonstrate the documented operator visibility. Attempt client-side cross-posting to every configured relay. Public launch remains blocked if copy implies E2EE.

**Phase to address:** Phase 0 policy and Phase 4 implementation/compatibility.

### Pitfall 2: Shipping Pyramid's Current Browser Admin Authentication Unchanged

**What goes wrong:** A captured browser bearer can be replayed for administrative access long after signing. Third-party JavaScript or XSS can read the token. Cross-site mutations may be possible if session and CSRF boundaries are not rebuilt.

**Evidence/status:** **Confirmed in Pyramid v1.3.2 (`e12e816`).** The admin layout loads unpinned JavaScript at runtime from jsDelivr and unpkg. It writes a JavaScript-readable `nip98` cookie with a roughly 400-day lifetime and without `Secure`, `HttpOnly`, or `SameSite`. The signed event contains a domain tag, while `GetLoggedUser` verifies signature and domain but does not enforce the NIP-98 kind, a short `created_at` window, exact URL, HTTP method, or payload. NIP-98 requires those request bindings and recommends a short time window.

**Why it happens:** A signed event is mistaken for a safe long-lived web session. Signature validity proves authorship, not request freshness or intent.

**Warning signs:**

- A login event captured yesterday still authorizes a mutation.
- `document.cookie` reveals the admin bearer.
- Admin HTML depends on mutable CDN scripts.
- Mutation endpoints accept a GET, an old event, a mismatched URL/method, or a cross-site request.

**Prevention:**

- Replace persistent signed bearers with one-time, fully validated NIP-98 login followed by a short server-side session.
- Validate kind, signature, timestamp, exact canonical URL, method, and payload hash where relevant.
- Set `Secure`, `HttpOnly`, restrictive `SameSite`, bounded expiry, rotation, and explicit logout revocation.
- Add CSRF protection and step-up authorization for root, role, secret, update, wipe, and backup actions.
- Self-host reviewed browser dependencies; pin versions and use a restrictive Content Security Policy.

**Validation/release gate:** Automated negative tests must reject expired, future-dated, wrong-kind, wrong-host, wrong-path, wrong-method, replayed, and modified-payload events. Browser tests must show JavaScript cannot read the session and cross-site requests cannot mutate state. This is a **public-launch blocker**.

**Phase to address:** Phase 2, after the Phase 1 web boundary is stable.

### Pitfall 3: Assuming Pyramid's Default Roles Match the Alumni Governance Model

**What goes wrong:** Ordinary members invite users, moderators perform admin-like actions, or any member creates an unmanaged group. The intended alumni/friend/admin boundary exists only in prose.

**Evidence/status:** **Confirmed in current source.** Pyramid defaults `MaxInvitesPerPerson` to 4; roots are unlimited; a value of 0 disables non-root invitations. Any Pyramid member can create a group and becomes its admin. Several group actions authorize any role, not only a role named admin. Global custom roles are not a complete authorization layer for every action. NIP-29 deliberately leaves role names and capabilities to relay policy.

**Why it happens:** Display labels are confused with enforced capabilities, and protocol flexibility is mistaken for a ready-made permission model.

**Warning signs:**

- Changing a role name changes UI but not allowed actions.
- A friend or moderator can create an invite, role, group, or deletion unexpectedly.
- There is no executable permission matrix.
- Operators share one root identity.

**Prevention:**

- Define actions down the rows and alumni/friend/admin/operator roles across columns before implementation.
- Set non-root invitation quota to zero if only admins may invite, then add a separate auditable admin invitation flow.
- Decide who may create groups, appoint roles, remove members, delete content, wipe groups, and change infrastructure settings.
- Give two operators separate keys and sessions. Do not share a root secret.
- Log privileged decisions without logging sensitive event bodies.

**Validation/release gate:** For every matrix cell, run positive and negative API tests with distinct identities. Include closed/open groups, expired/replayed invites, removed members, demoted admins, last-admin protection, and concurrent role changes. Manual UI visibility does not count as authorization proof.

**Phase to address:** Phase 0 governance; Phase 2 enforcement; Phase 4 client-level verification.

### Pitfall 4: Promising Deletion That the Protocol and Current Service Do Not Deliver

**What goes wrong:** Users believe deletion erases all copies, while remote relays, clients, local aggregation, logs, soft-deleted group storage, or old backups retain or resurrect the event.

**Evidence/status:** **Confirmed.** NIP-09 calls deletion a request and says deletion across all relays and clients cannot be guaranteed. Supporting relays should retain deletion requests to prevent reinsertion. NIP-62 defines a targeted relay-vanish request only for relays that implement it. Current Pyramid rejects NIP-09 deletion of group messages older than two hours. Group deletion moves events to a root-visible deleted-group store until a separate wipe. The inward curation path has no demonstrated source-deletion propagation and tombstone contract.

**Why it happens:** UI disappearance is treated as erasure; active indexes, source relays, replicas, backups, and re-import paths are tested separately or not at all.

**Warning signs:**

- A deleted event returns after reindex, restore, source refetch, or alternate-client query.
- Documentation says delete permanently without scope and retention caveats.
- Backup aging is based only on calendar age, not tested restoration.
- Aggregation stores provenance but no deletion tombstone.

**Prevention:**

- Publish a precise deletion contract: which active services act immediately, what remote copies cannot be controlled, and when encrypted backups age out.
- Persist signed deletion/tombstone events and block re-import.
- Propagate deletion through public indexes, search, previews, caches, local aggregation, and Blossom metadata where authorized.
- Reconcile Pyramid's two-hour group-message rule with the product promise before launch.
- Define root-visible retention and exceptional legal holds with access controls and audit.

**Validation/release gate:** Delete public, group, aggregated, and attachment references at multiple ages; query every interface; re-submit the original event; re-fetch the source; rebuild indexes; restore each backup generation. Record maximum erasure time and residual copies. Do not claim deletion until this drill passes.

**Phase to address:** Phase 3 active-state semantics; Phase 6 backup aging and restore proof.

### Pitfall 5: Running a General-Purpose Blossom Server as an Unbounded Public File Host

**What goes wrong:** Anonymous or compromised users fill disk, serve malware or illegal content, upload polyglots/image bombs, hotlink bandwidth, or use the VPS as durable public hosting. Private-group attachments leak because standard Blossom URLs are publicly retrievable.

**Evidence/status:** **Confirmed.** BUD-02 defines blob URLs as directly retrievable and supplies media metadata; it does not provide private-group authorization. BUD-11 supports scoped authorization but warns that insufficiently scoped delete tokens are replayable. Pyramid stores blobs mode `0644`; its member upload default of zero means unlimited, while group-only users default to 1 MB. The upload callback receives the body as a byte slice, creating a **deployment inference** that memory pressure must be measured under concurrency. No complete quarantine, malware-scanning, content-sniffing, or legal-response workflow was found in the current repository.

**Why it happens:** Content-addressing prevents some tampering but does not make bytes safe, lawful, private, bounded, or cheap.

**Warning signs:**

- No per-file, per-user, daily, global-storage, or bandwidth quota.
- `GET /<hash>` returns a private group's plaintext file without group authentication.
- Browser renders uploader-supplied HTML/SVG inline on the main origin.
- Disk, heap, egress, or scan queue grows without alerts.
- Operators have no safe intake process for reported illegal content.

**Prevention:**

- Put blobs on an isolated origin with no ambient admin cookies, `X-Content-Type-Options: nosniff`, conservative `Content-Disposition`, and a narrow content security policy.
- Quarantine uploads before public GET; verify size, hash, detected type, decompression/resolution/frame limits, and malware policy.
- Enforce per-file, per-identity, daily, global disk, concurrency, and bandwidth limits. Root must not silently bypass operational ceilings.
- Require exact server/hash/verb/expiry scoping for Blossom authorization.
- Treat public Blossom as public. Use client-side encrypted blobs or a separately authenticated delivery design for sensitive group attachments.
- Implement report, quarantine, appeal, permanent-block, evidence-minimization, and operator-safety procedures before enabling broad uploads.

**Validation/release gate:** Test MIME mismatches, HTML/SVG/polyglots, compressed bombs, oversized files, slow uploads, concurrent uploads, quota races, replayed auth, delete scope, hotlinking, hash mismatch, scan timeout, quarantine bypass, disk-high-water behavior, and plaintext private attachment retrieval. Measure heap and temporary-disk peaks.

**Phase to address:** Phase 5. Keep uploads invite-only and tightly capped until Phase 7 evidence supports broader use.

### Pitfall 6: Exposing Server-Side Fetchers and Relay Hints as SSRF/Egress Proxies

**What goes wrong:** An attacker makes the VPS query loopback, RFC1918, link-local, cloud metadata, internal admin endpoints, or arbitrary external services through link previews, image transformation, aggregation, or WebSocket relay hints.

**Evidence/status:** **Confirmed for Pyramid's link preview path.** It accepts arbitrary HTTP(S) URLs and uses a standard HTTP client that follows redirects, without a demonstrated private/link-local address block or response-size cap. Its token endpoint derives a per-pubkey token for any valid signed Nostr identity without demonstrated community-membership enforcement, and permissive CORS is not an authorization boundary. **Inference:** remote event/relay hints and media transformation add similar egress surfaces and require explicit tests. Official imgproxy controls include source allowlists, private-address restrictions, and file/resolution/frame caps.

**Why it happens:** URL parsing and an HMAC token are treated as sufficient. Redirects, DNS rebinding, IPv6 forms, alternate encodings, and outbound WebSockets escape the initial check.

**Warning signs:**

- Fetch logs contain localhost, `.local`, private IP, link-local, metadata, or unusual ports.
- Preview endpoint is reachable by any key.
- DNS is checked only before redirects, or the HTTP library automatically follows them.
- Relay hints open outbound `ws://` or connections to private ranges.

**Prevention:**

- Disable link preview in production until membership authorization and SSRF controls exist.
- Resolve and validate every hop; allow only public IPs, HTTPS/WSS where possible, and approved ports. Re-check after redirect and connection.
- Block loopback, private, link-local, multicast, documentation, and metadata ranges for IPv4 and IPv6. Add an egress firewall as defense in depth.
- Cap DNS, connect, TLS, header, body, redirect, and total time/bytes.
- Configure imgproxy allowed sources and resolution/file/frame limits explicitly.
- Apply the same URL policy to aggregation relay hints and background synchronizers.

**Validation/release gate:** Use an SSRF corpus covering numeric/encoded IPs, IPv6, DNS rebinding, redirect-to-private, credentialed URLs, alternate schemes, large/infinite bodies, and private WebSocket targets. Confirm network policy blocks attempts even if application validation is bypassed.

**Phase to address:** Phase 1 network boundary; Phase 3 aggregation; Phase 5 preview/media services.

### Pitfall 7: Unverified Self-Update and Mutable Container Inputs

**What goes wrong:** A registry compromise, mutable tag, CDN compromise, or compromised update source becomes code execution as root on the community host. An upgrade partially changes binary/schema/data and cannot roll back.

**Evidence/status:** **Confirmed in current source/build files.** The Dockerfile uses mutable base tags including `ubuntu:latest`, has no final non-root `USER`, and does not pin image digests. The easy installer downloads artifacts without a demonstrated checksum/signature gate. The built-in update path downloads and executes a replacement, including from a configurable source, without a demonstrated cryptographic release verification step. No complete migration/rollback contract or changelog was found. Official Docker guidance recommends digest pinning and a non-root user where possible.

**Why it happens:** Convenience installation and auto-update are promoted directly into production operations.

**Warning signs:**

- Deployment uses `latest` or unreviewed Git HEAD.
- The container runs as root and mounts all persistent data writable.
- Production can self-update from the admin UI.
- No SBOM, release checksum/provenance, staging restore, or rollback snapshot exists.

**Prevention:**

- Build from one reviewed Pyramid commit/tag and pin every image by digest.
- Produce/store an SBOM and scan OS and language dependencies. Treat “no advisory listed” as no assurance.
- Run as a dedicated non-root UID, use a read-only root filesystem, drop capabilities, and mount only required paths.
- Disable in-place auto-update. Promote releases through staging against a restored production backup.
- Define schema/data compatibility, preflight, maintenance window, rollback limits, and post-upgrade checks.

**Validation/release gate:** Rebuild reproducibly from recorded inputs; verify digests/provenance; scan; run container escape/permission checks; upgrade a restored dataset; run compatibility tests; simulate failure halfway; roll back; verify hashes/counts/roles/blobs/deletions. No public upgrade without a tested rollback or an explicit irreversible migration procedure.

**Phase to address:** Phase 1 supply-chain baseline; Phase 6 lifecycle rehearsal.

### Pitfall 8: Backing Up Files Without Proving a Consistent, Restorable Community State

**What goes wrong:** Backups exist but combine different instants of event indexes, management state, blobs, settings, and tombstones. Restore boots yet silently loses roles, deletes, or attachments. Secrets are either missing or exposed.

**Evidence/status:** **Confirmed architectural condition plus inference.** Pyramid places multiple services and data classes under a shared data path and process. Settings include relay/signing and integration secrets and are currently written mode `0644`. NIP-29 recommends a replica because group durability depends on the hosting relay. The project has one fresh VPS, so restore—not nominal backup success—is the resilience boundary.

**Why it happens:** File copy success and container restart are used as acceptance tests. Mmap/database consistency, off-host independence, and application invariants are omitted.

**Warning signs:**

- Last restore drill is “never” or uses the live host.
- Backup is in the same provider/account/region and mutable by the production credential.
- Blob files and indexes have different counts; member roles or tombstones disappear after restore.
- Secrets appear in broad-readable archives or logs.

**Prevention:**

- Inventory data classes: active events, indexes, management events, roles/invites, tombstones, group state, blobs, settings, certificates, logs, and secrets.
- Use an application-aware quiesce/snapshot contract; verify mmap/database flush behavior.
- Store encrypted, versioned, immutable off-host copies with separate credentials and tested retention.
- Separate recoverable configuration from secrets; use mode `0600` or a proper secret store; document which secrets must rotate after restore.
- Define and measure RPO/RTO. Consider a NIP-29 replica, but do not call it HA until failover and convergence are tested.

**Validation/release gate:** Restore onto a blank VPS using only the runbook and backup. Compare event IDs/counts, signatures, roles, group visibility, indexes, blobs/hashes, deletion tombstones, and supported client flows. Repeat with an intentionally interrupted backup and an old generation. Two operators must independently complete the drill.

**Phase to address:** Phase 1 secret/file layout; Phase 6 full restore and replica drill.

### Pitfall 9: Aggregating Public Content Without Preserving Moderation and Deletion Boundaries

**What goes wrong:** A reaction or relay hint imports spam, illegal content, protected events, private/group content, or impersonated context. Deleted content reappears. Duplicate and replaceable events produce inconsistent timelines.

**Evidence/status:** **Confirmed/inference.** Pyramid's curation logic can fetch an externally referenced event from relay hints and store selected popular/uppermost content. It recognizes NIP-70 protected events, but no complete source-deletion propagation/tombstone contract was demonstrated. NIP-65's normal read/write relay model means clients and authors may distribute events across several relays; source availability and canonical context are not guaranteed.

**Why it happens:** Valid Schnorr signature is treated as sufficient admission. It proves the event's key signed those bytes, not relevance, safety, desired audience, provenance quality, or continued availability.

**Warning signs:**

- Local feed cannot show source relay, importer, or moderation decision.
- The same event appears multiple times or deleted source content remains indefinitely.
- Arbitrary member reactions cause server-side fetch/storage.
- Private/group/protected event kinds enter a public index.

**Prevention:**

- Define an explicit author/source allowlist and whether friend accounts are eligible.
- Verify signatures and IDs; deduplicate by event ID; correctly process replaceable/addressable events.
- Retain provenance, fetch time, source relays, and local moderation state.
- Reject private/group/protected content and unsafe kinds before storage/display.
- Apply SSRF-safe relay hint policy, bounded fetches, and moderation before public promotion.
- Persist deletion tombstones; periodically reconcile source deletion and prevent re-import.

**Validation/release gate:** Test invalid signatures, duplicate relay copies, conflicting replaceables, malicious relay URLs, source outages, protected/group/private content, local takedown, source deletion, and repeated re-import. Verify moderation and deletion survive index rebuild and backup restore.

**Phase to address:** Phase 3 before any public aggregate feed.

### Pitfall 10: Relying on Application Limits While WebSocket, HTTP, Disk, and CPU Remain Unbounded

**What goes wrong:** Huge tags/filters, slow connections, subscription floods, uploads, image bombs, or log amplification exhaust memory, CPU, file descriptors, disk, or bandwidth. A full disk corrupts service state and backup jobs.

**Evidence/status:** **Confirmed/inference.** Pyramid exposes content, subscription, query, and filter-cost settings. Its content-size check is not a demonstrated full serialized WebSocket frame limit, while the advertised NIP-11 limit may be read as such. The HTTP server does not demonstrate a complete production timeout policy. Unlimited member uploads and multi-service colocation make disk and heap coupling material.

**Why it happens:** Per-event policy is mistaken for infrastructure capacity management. Average-load tests miss adversarial shapes and shared-resource failure.

**Warning signs:**

- No edge body/frame/connection/request rate limits or explicit server timeouts.
- No 70/80/90% disk thresholds, inode alerts, or read-only degradation mode.
- One upload or query raises RSS far beyond its payload size.
- Logs grow rapidly during invalid-event floods.

**Prevention:**

- Bound full HTTP bodies, WebSocket frames, tag counts/sizes, filters, subscriptions, connections per IP/account, query work, upload concurrency, and background fetches.
- Configure header/read/write/idle deadlines consistently at app and proxy.
- Reserve disk; set per-service quotas and retention; alert before exhaustion; define safe read-only behavior.
- Rate-limit expensive failures and sample/redact logs.
- Run relay, blob/media, search, and preview workloads with explicit resource limits or separate services where isolation is needed.

**Validation/release gate:** Load and abuse tests must cover slowloris, connection churn, huge tags, pathological filters, repeated AUTH, subscription fan-out, upload concurrency, image bombs, scan backlog, log flood, disk-full, inode-full, and restart recovery. Record p95/p99 latency, RSS, CPU, descriptors, disk, and dropped/rejected work against budgets.

**Phase to address:** Phase 1 edge defaults; Phase 5 blob-specific limits; Phase 6 capacity/load gate.

### Pitfall 11: Assuming TLS and a Reverse Proxy Are Correct Because the Homepage Loads

**What goes wrong:** One relay path fails WebSocket upgrade, NIP-11 advertises the wrong URL/limits, forged proxy headers defeat IP controls, or a subdomain exposes a backend/admin port directly. Certificate renewal fails unnoticed.

**Evidence/status:** **Confirmed deployment risk.** Pyramid supports path-based relays and special domains. Caddy supports WebSocket proxying, but intentionally ignores incoming `X-Forwarded-For` by default unless trusted proxies are configured; its strict trusted-proxy mode is topology-sensitive. Client behavior around path relays varies and must be measured.

**Why it happens:** HTTPS GET is tested while SNI, WebSocket, NIP-11, AUTH, CORS, canonical URL, and forwarded identity are independent contracts.

**Warning signs:**

- Backend port is public or binds all interfaces.
- Any internet client can supply a trusted `X-Forwarded-For` value.
- A supported client works on root domain but not `/group` or a relay subdomain.
- No expiry/renewal alert exists.

**Prevention:**

- Bind Pyramid privately; expose only Caddy. Firewall management and origin ports.
- Trust proxy addresses narrowly and enable strict parsing only for the actual hop order.
- Maintain explicit canonical external URLs and NIP-11 per relay endpoint.
- Separate admin and blob origins/cookies; restrict CORS by endpoint and threat model.
- Monitor certificate expiry, renewal errors, DNS, and WebSocket handshakes.

**Validation/release gate:** From outside the VPS, test every hostname/path for DNS, SNI/cert chain, HTTPS redirect, WebSocket upgrade, NIP-11, AUTH, public/private query, Blossom, CORS, origin reachability, forged forwarding headers, and certificate renewal in staging. Run the version-pinned client matrix against the exact public URLs.

**Phase to address:** Phase 1; retest in Phases 4 and 7.

### Pitfall 12: Logging Private Content, Bearers, Signer Material, and Member Metadata

**What goes wrong:** Operators minimize database access but expose the same information through error logs, admin log viewers, metrics labels, backups, or support bundles. A NIP-46 connection secret or NIP-98 bearer becomes account access.

**Evidence/status:** **Confirmed/inference.** Pyramid's logging configuration retains rotated logs and records request metadata such as IP/origin/user-agent. Multiple error paths attach whole events, which can include private/group content. Settings contain signing and integration secrets. NIP-44 documents unavoidable IP/time/size metadata leakage; encryption does not make operational metadata disappear.

**Why it happens:** Structured logging serializes rich objects by convenience, and “encrypted event” is treated as harmless log data.

**Warning signs:**

- Logs contain full event JSON, content, authorization headers/cookies, connection URIs/secrets, upload URLs, or private-group identifiers.
- Pubkeys/IPs are permanent metric labels.
- Support asks users to upload an unredacted data directory.
- Any admin role can browse logs indefinitely.

**Prevention:**

- Use a field allowlist: event ID/kind, bounded reason code, coarse route, and pseudonymous or truncated network identifiers where operationally justified.
- Explicitly redact NIP-46 URI/secret, NIP-98 event/cookie, auth headers, session IDs, private event bodies, upload names/URLs, settings, and keys.
- Keep retention no longer than the incident purpose; restrict and audit operator access; encrypt off-host logs/backups.
- Publish a metadata/privacy notice matching actual collection and retention.
- Build a redacted support export.

**Validation/release gate:** Seed unique canaries into private content, tokens, signer connection strings, filenames, URLs, settings, and headers; exercise success/error paths; scan logs, metrics, traces, backups, and support bundles. Any secret canary is a release blocker.

**Phase to address:** Phase 0 data policy; Phase 2 auth redaction; Phase 6 observability verification.

### Pitfall 13: Mishandling NIP-46 and Personal Keys

**What goes wrong:** The service hosts or logs signer secrets despite the BYOK promise; a client grants broad signer permissions; a stale client key remains authorized; or users assume logout revokes a compromised remote signer relationship.

**Evidence/status:** **Confirmed protocol constraints.** NIP-46 distinguishes the client key, remote-signer key, and user's signing key. Connection secrets must be validated. Clients should request least privilege, can switch relays, and should delete client keys on logout. Logout alone is not a reliable security boundary. The project explicitly chooses BYOK and no hosted bunker.

**Why it happens:** NIP-46 is marketed as remote signing without modeling the connection URI, per-client key, permission scope, revocation, recovery, and relay metadata as security-sensitive assets.

**Warning signs:**

- Server logs or support tickets contain bunker URIs, secrets, private keys, or QR payloads.
- All clients reuse one client key or request unrestricted signing.
- Removing a user from the community is assumed to revoke their signer.
- There is no tested lost-device/revocation flow.

**Prevention:**

- Keep all user signing keys and bunker custody outside this VPS. Never request or persist them.
- Redact connection material everywhere and prevent it from entering analytics, crash reports, screenshots, or backups.
- Require per-client keys, validated connection secrets, bounded permissions, and clear consent prompts.
- Document removal-from-community separately from signer/device revocation.
- Support direct browser/extension/mobile signer choices without coercing users into one custody model.

**Validation/release gate:** Test nos2x, Amber, iOS signer, and NIP-46 flows for connect, permission refusal, least privilege, relay switch/reconnect, stale connection, device loss, client-key deletion, logout, and community removal. Scan all observability outputs for seeded connection secrets.

**Phase to address:** Phase 4, with logging controls from Phases 2 and 6.

### Pitfall 14: Skipping Jurisdiction, Provider, and Illegal-Content Operations Until the First Report

**What goes wrong:** Operators receive a copyright, malware, harassment, or suspected child-sexual-abuse-material report without a lawful/safe procedure. The VPS provider suspends the host, evidence is mishandled, or operators unnecessarily view/download harmful material.

**Evidence/status:** **Unresolved legal question.** Applicability depends on the legal operator, service role, user and server/backup locations, and provider. In the US, 18 U.S.C. §2258A imposes reporting duties on qualifying providers after actual knowledge; this research does not determine whether the project qualifies. US DMCA safe-harbor conditions can include policy and designated-agent requirements; applicability is unresolved. EU Digital Services Act duties and exemptions vary, while Article 16 establishes notice/action mechanisms for hosting services and Article 8 rejects a general monitoring obligation. Provider acceptable-use and abuse processes are not known until a vendor is selected.

**Why it happens:** A trusted invite-only community is treated as eliminating legal/abuse exposure, even though accounts can be compromised and general-purpose uploads are public infrastructure.

**Warning signs:**

- No named legal entity/operator, governing law, provider region, backup region, terms, privacy notice, or abuse contact.
- Abuse handling means “an admin will inspect the file.”
- No escalation clock, appeal, evidence-minimization, or law-enforcement procedure.
- Provider selection compares only price/RAM.

**Prevention:**

- Before public uploads, obtain jurisdiction-specific counsel covering operator classification, notice/action, copyright, privacy, retention, law-enforcement requests, and mandatory reporting.
- Define an abuse mailbox/form, authentication and prioritization of reports, quarantine-first workflow, limited trained operators, appeals, decision records, and emergency escalation.
- Do not require operators to manually download suspected CSAM; establish counsel-approved handling and reporting steps.
- Select provider on AUP/user-content fit, abuse SLA, suspension notice, region, export, bandwidth, backups, and law-enforcement process—not price alone.
- Keep a provider-exit image/backup and rehearse migration.

**Validation/release gate:** Counsel-approved written policy and tabletop exercises for malware, copyright, harassment, account compromise, suspected CSAM, provider suspension, and lawful request. Verify intake works without exposing the reporter or content broadly. This is a gate for broad public Blossom and public launch, not a conclusion that any named regime applies.

**Phase to address:** Phase 0 decision gate; Phase 5 operational implementation; Phase 7 tabletop acceptance.

### Pitfall 15: Declaring Client Support from NIP Checkboxes Instead of End-to-End Behavior

**What goes wrong:** Nostrord, Flotilla, or Jumble can connect but fail role changes, private AUTH reads, group deletion, path relays, Blossom auth, or signer reconnection. Multi-relay defaults leak group events or fragment public conversations.

**Evidence/status:** **Confirmed need.** NIP-29 remains a draft optional protocol. Current Pyramid special-cases a client user agent by removing NIP-77 from NIP-11 because that sync behavior is incompatible with groups. NIP-65 intentionally distributes reads/writes across multiple relays for ordinary social use, which conflicts with group-host-only routing unless the client handles the context correctly.

**Why it happens:** “Supports NIP-29/NIP-46” covers syntax, not the exact version, workflow, relay URL shape, signer, and privacy destination.

**Warning signs:**

- No pinned app/extension/mobile versions in the support matrix.
- Testing stops after login or viewing one public note.
- A composer gives no clear destination preview.
- Client upgrades are automatic and untested.

**Prevention:**

- Maintain a small, version-pinned compatibility matrix: Nostrord, Flotilla, Jumble; nos2x, Amber, iOS signer, and NIP-46.
- Test public notes/replies/reactions/long-form, group creation/join/invite/role/remove/delete, private AUTH read, destination isolation, Blossom upload/delete, reconnect, and logout.
- Publish supported versions and known limitations; stage upgrades before recommending them.
- Make multi-relay destination visible and require private-group traffic to the intended host only.

**Validation/release gate:** Repeat the matrix against production-shaped domains and paths with packet/event capture. Verify exact relay recipients, not only UI outcome. A client is supported only if required flows pass; record regressions per version.

**Phase to address:** Phase 4; smoke subset in every release; full matrix in Phase 7.

### Pitfall 16: Building Infrastructure or a Custom Client Without Solving the Cold Start

**What goes wrong:** The relay is technically sound but empty, experts do not return, public aggregation overwhelms member conversation, and operators respond by building a custom client that becomes a permanent maintenance burden.

**Evidence/status:** **Inference from the project model.** A network of roughly 100 expert alumni needs recurring social value, not merely availability. No protocol feature guarantees activation, quality, or community norms.

**Why it happens:** Infrastructure milestones are measurable, while facilitation and repeat participation are treated as post-launch marketing. Client friction is blamed before workflow evidence exists.

**Warning signs:**

- Pilot success is uptime/account count only.
- Few members create or reply after onboarding; conversations depend on operators.
- Public aggregated posts dominate local member posts.
- A custom client is proposed without a failed-job inventory, owner, budget, and exit plan.

**Prevention:**

- Seed a small cohort of conveners, topic rituals, scheduled prompts, introductions, and a moderated “Best Of.”
- Import only consented directory/profile information and make first contribution easy.
- Measure aggregate activation, weekly return, contributors, unanswered posts, reply depth, moderation load, and operator hours without invasive profiling.
- Tune aggregation to support—not replace—member discussion.
- Build a custom client only after the pilot identifies repeated, material job failures that upstream configuration/contribution cannot solve.

**Validation/release gate:** Thirty-day pilot with predeclared targets and qualitative interviews. Require evidence that supported clients block a core job before approving custom-client scope; assign maintenance ownership, security/update budget, accessibility criteria, and an upstream/exit strategy.

**Phase to address:** Phase 7; custom client is deferred unless the gate fails for a documented reason.

## Moderate Pitfalls

### Invitation State Races and Stale Access

**What goes wrong:** Concurrent invite acceptance exceeds limits, removed users retain subscriptions, or expired/used invites can be replayed.

**Prevention:** Make invite redemption atomic; bind to intended identity where appropriate; expire and consume once; re-authorize every subscription/query and terminate live subscriptions on removal.

**Validation:** Race multiple redemptions, replay old invites, change roles during active subscriptions, remove a member while connected, and restart/restore. Map to Phases 2 and 4.

### Root Key as an Operational Skeleton Key

**What goes wrong:** The internal relay/root secret is copied to laptops, logs, broad-readable settings, or shared by both operators. Compromise bypasses community roles.

**Prevention:** Separate machine signing material from operator identities; mode `0600`; no chat/ticket copies; encrypted backups; minimal offline recovery; two distinct operator identities; rotation/recovery runbook.

**Validation:** File-permission and process-access tests, canary scans, operator-loss tabletop, and rotation on staging. Map to Phases 1, 2, and 6.

### Single-VPS Failure Disguised as High Availability

**What goes wrong:** DNS, provider account, disk, host, or region failure takes down all relays, Blossom, previews, search, and admin.

**Prevention:** Be explicit that the MVP is single-host. Focus on off-provider restore, low TTLs where useful, exported DNS/config, and measured RTO/RPO. Add a NIP-29 replica only with tested permissions, deletion convergence, and failover.

**Validation:** Destroy a disposable host and restore elsewhere; simulate provider lockout and DNS cutover. Map to Phase 6.

### Admin UX That Makes Irreversible Actions Look Routine

**What goes wrong:** An operator wipes a group, changes a root/role, publishes an update, or exposes a secret due to ambiguous labels and broad screens.

**Prevention:** Separate routine moderation from infrastructure/root actions; show exact scope; step-up authentication; typed confirmation for irreversible operations; preview permission changes; record actor and reason.

**Validation:** Two-operator usability test using realistic incidents; ensure cancel/recovery paths and least-privilege visibility. Map to Phase 2.

### Search and Preview Indexes Become Shadow Data Stores

**What goes wrong:** A private or deleted event disappears from the relay query path but remains in search, link preview, cache, or static rendered output.

**Prevention:** Central classification and deletion pipeline; never index private content unless explicitly required; attach audience and tombstone metadata; purge caches and derived views transactionally or through a monitored queue.

**Validation:** Canary/private/deletion tests against every derived store and rebuild. Map to Phases 3 and 6.

## Technical Debt Patterns

| Pattern | Why It Is Dangerous Here | Better Approach | Phase |
|---------|--------------------------|-----------------|-------|
| Editing upstream Pyramid directly without a patch ledger | Upgrades silently lose security fixes or local semantics | Maintain a small reviewed fork, pinned upstream commit, patch inventory, and rebase tests | 1-6 |
| Encoding policy only in UI | Nostr clients can call relay endpoints directly | Enforce at relay/API boundary; UI mirrors policy | 2-5 |
| One global “member” boolean | Alumni, friends, admins, moderators, operators have different powers | Explicit capability matrix with negative tests | 0, 2 |
| Event deletion by physical removal only | Re-import resurrects content | Signed persistent tombstones plus scoped erasure lifecycle | 3, 6 |
| Using Origin/CORS as authentication | Non-browser clients and attackers bypass it | Cryptographic/session authorization; CORS only limits browsers | 1, 2, 5 |
| One writable volume for every component | Corruption/compromise has maximum blast radius | Inventory, least-writable mounts, quota/isolation, consistent backup | 1, 6 |
| “Latest” deployments | Behavior changes outside change control | Commit and digest pins, staged promotion | 1, 6 |
| Permanent rich logs | Privacy and secret exposure compound with time | Allowlists, redaction, bounded retention | 0, 6 |
| Custom client before pilot | Creates security and maintenance surface without evidence | Upstream clients/config/contributions first; evidence gate | 7 |

## Integration Gotchas

| Integration | Gotcha | Required Test |
|-------------|--------|---------------|
| NIP-29 + ordinary multi-relay clients | Client may publish group content beyond the host relay; `previous` context protection can be absent | Capture exact outbound EVENT destinations and try cross-relay replay |
| NIP-29 + NIP-77/negentropy | Current Pyramid advertises different capability for a client because sync can conflict with groups | Pin versions and test sync without membership/history leakage |
| NIP-46 + browser/mobile clients | Client key, signer key, user key, and connection secret have different lifecycles | Least-permission, reconnect, revoke, lost-device, and log-canary tests |
| Blossom + private groups | Standard blob URL is public; group ACL does not automatically protect bytes | Retrieve hash as non-member and unauthenticated browser |
| Aggregation + deletion | Source and local tombstones can diverge | Delete at source/local, re-fetch, rebuild, restore |
| Caddy + Pyramid | Forwarded IP trust, WebSocket upgrade, host/path canonicalization are separate | External topology test with forged headers and every URL |
| Link preview/imgproxy + DNS | Redirect/rebinding and IPv6 can bypass naive host checks | SSRF corpus plus egress firewall verification |
| Backup + mmap/indexes | Files copied at different instants can boot but be inconsistent | Blank-host invariant-based restore |
| Provider abuse + immutable backups | Provider suspension may remove both primary and same-account backup | Cross-provider credential and restore drill |

## Performance Traps

| Trap | Early Warning | Mitigation/Test |
|------|---------------|-----------------|
| Whole-body blob buffering | RSS rises near upload size × concurrency | Stream or hard-cap before allocation; concurrency load test |
| Filter/subscription fan-out | CPU and outbound bytes rise faster than users | Cost budget, per-account/IP limits, worst-shape query tests |
| Large tag arrays with small content | NIP-11 content limit passes but frame/parse work explodes | Full-frame and tag count/size limits |
| Image/video decompression bombs | Tiny file drives huge decode CPU/RAM | Quarantine; resolution/frame/time caps; sandboxed media worker |
| Link preview infinite/large body | Worker/connection pool saturates | Header/body/redirect/total caps and circuit breaker |
| Log amplification | Invalid traffic fills disk faster than content | Rate-limit, sample, bound fields, reserve disk |
| Shared host noisy neighbor | Blob scan/search starves relay WebSockets | Resource controls, priority budgets, split services when measured |

## Security Mistakes to Explicitly Reject

- Do not expose Pyramid's origin/admin port directly to the internet.
- Do not call a valid signature authorization without checking freshness, audience, method, payload, role, and replay.
- Do not use one shared root/operator credential.
- Do not store NIP-46 connection secrets, user private keys, or bunker URIs.
- Do not serve user-controlled HTML/SVG on an origin carrying admin cookies.
- Do not permit arbitrary server-side HTTP or WebSocket destinations.
- Do not use mutable tags or unverified self-update in production.
- Do not depend on CORS, hidden URLs, or NIP-70 for confidentiality.
- Do not make production backups writable by the same unrestricted credential as the live service.
- Do not equate encryption with metadata privacy or group access control with E2EE.

## UX Pitfalls

| UX Failure | Consequence | Acceptance Criterion |
|------------|-------------|----------------------|
| “Private” with no operator/backup disclosure | Members overshare | Composer/onboarding state access-controlled, not E2EE |
| Hidden relay destination | Private event cross-posting | Destination preview and group-host-only default |
| Role names without capability preview | Accidental privilege escalation | Before/after action list and confirmation |
| Delete button with absolute language | False erasure expectation | Scope, remote-copy caveat, backup aging shown |
| Broad signer permission prompt | Users approve more than intended | Human-readable exact operations and duration |
| Upload appears complete before quarantine | Broken links or unsafe publication | Explicit scanning/quarantine/published states |
| Aggregated post lacks provenance | Trust/moderation confusion | Source author, source relay, import reason, local status |
| Admin and member controls mixed | Higher operator-error rate | Separate routine moderation and root/infrastructure surfaces |

## Looks Done But Is Not

- [ ] HTTPS homepage works, but every WebSocket/NIP-11/AUTH/path/subdomain has not been tested.
- [ ] Private-group UI hides content, but raw queries, logs, backups, replicas, and other clients have not been tested.
- [ ] Delete disappears from one timeline, but search, aggregation, restore, and re-import have not been tested.
- [ ] Backup job is green, but a blank-host restore has not passed.
- [ ] Client advertises a NIP, but the project's complete workflow matrix has not passed.
- [ ] Blob hash matches, but MIME, malware, privacy, quota, and legal workflows have not passed.
- [ ] Admin event has a valid signature, but timestamp/audience/method/replay/CSRF have not passed.
- [ ] Dependency scan is green, but deployment inputs are mutable or unsigned.
- [ ] Replica receives events, but failover, roles, private reads, and deletion convergence have not passed.
- [ ] Thirty days elapsed, but activation, return, conversation quality, moderation load, and operator burden did not meet predeclared targets.

## Recovery Strategies

| Failure | Recovery Strategy | Proof Required Before Launch |
|---------|-------------------|------------------------------|
| Compromised admin session | Revoke all sessions, rotate server session secret, audit privileged actions, step-up re-enrollment | Staging incident drill with bounded detection/recovery time |
| Compromised root/server secret | Isolate host, rotate keys/integration secrets, rebuild from known-good image, assess signed-event implications | Key inventory and rotation drill; no secret canaries in logs/backups |
| Disk exhaustion | Stop/quarantine writes, preserve database integrity, free only policy-approved derived data, expand/rebuild | Disk-full test and documented safe degradation |
| Corrupt database/index | Quiesce, retain forensic copy, restore or rebuild index from authoritative events/tombstones | Hash/count/invariant comparison |
| Bad upgrade | Stop promotion, restore compatible binary/data snapshot, run post-rollback checks | Failed-migration rehearsal |
| Provider suspension | Activate alternate provider, restore off-provider backup, switch DNS, communicate status | Blank-provider restore and DNS cutover timing |
| Malicious/illegal blob report | Quarantine access, preserve minimal authorized records, follow counsel-approved reporting/notice process | Tabletop without unnecessary operator exposure |
| Aggregation poisoning | Disable fetcher, tombstone imported content, block source/author, rebuild derived feed | Re-import resistance and provenance audit |
| Client regression | Freeze supported version guidance, disable affected workflow, publish workaround, upstream report/patch | Versioned compatibility suite |

## Pitfall-to-Phase Mapping

| Phase | Must Resolve Before Exit | Deeper Research Flag |
|-------|--------------------------|----------------------|
| 0 — Governance/legal | Permission matrix; operator identity; private-vs-E2EE language; retention/deletion contract; entity/jurisdiction/provider; abuse and privacy policy | **Required:** jurisdiction/provider-specific counsel and provider AUP review |
| 1 — Hardened foundation | Pinned build; non-root isolation; secret layout; Caddy/TLS/WS; origin firewall; egress policy; baseline limits | **Required:** Pyramid packaging and safe patch/fork strategy |
| 2 — Authorization/admin | Replace long-lived bearer; NIP-98 validation; sessions/CSRF; admin-only invite enforcement; distinct operators; audit/redaction | **Required:** audit every Pyramid privileged endpoint and authorization branch |
| 3 — Public/aggregation | Admission, provenance, dedup/replaceables, protected/private rejection, deletion/tombstones, re-import resistance | **Required:** curation code and source-deletion behavior under real relays |
| 4 — Private/client/signer | Non-member isolation; destination containment; NIP-29 role flows; signer custody; versioned compatibility matrix | **Required:** client-specific behavior because NIP-29 is draft and implementations vary |
| 5 — Blossom/abuse | Isolated origin; quotas; streaming/resource proof; MIME/quarantine/scanning; SSRF-safe media; report/takedown workflow | **Required:** content-safety tooling, counsel-approved handling, attachment confidentiality design |
| 6 — Resilience/ops | Off-host encrypted backup; blank-VPS restore; RPO/RTO; update rollback; capacity/DoS; logs/alerts/runbooks | **Required:** consistent snapshot procedure for Pyramid data layout and replica semantics |
| 7 — Pilot/launch | 30-day metrics; two-operator drills; no open high-severity findings; full compatibility/load/restore/legal gates | Standard pilot practice, but thresholds must be selected before observation |

**Ordering rationale:** Governance determines authorization, retention, and provider constraints. The hardened network/build boundary must precede exposing Pyramid. Authorization must be trustworthy before client/private-group testing. Public aggregation and private groups require different leakage/deletion tests. Blossom expands the legal and resource surface and should follow core relay controls. Restore/load/incident proof needs a feature-complete production-shaped stack. Only then can the pilot produce meaningful launch evidence.

## Legal and Provider Questions That Remain Open

These require facts or professional advice not available in protocol/source research:

1. Who is the legal operator—individual, alumni association, company, or another entity?
2. Where are operators, users, primary VPS, logs, and each backup located?
3. Which provider and plan will be used, and does its AUP permit a user-content relay and general-purpose public blobs?
4. Does the service qualify for any provider/intermediary category under applicable US, EU, Sri Lankan, or other law?
5. What copyright safe-harbor, designated-agent, notice/action, transparency, privacy, retention, and mandatory-reporting duties apply?
6. Which content classes are prohibited by policy beyond law, and who handles appeals?
7. What records may or must be retained after a report, deletion, or legal request, and for how long?

The roadmap should treat answers as Phase 0 inputs and Phase 5 acceptance criteria. It should not turn the statutes below into an unsupported conclusion about this project.

## Sources

### Pyramid and Deployment Sources

- [Pyramid repository, current release line](https://github.com/fiatjaf/pyramid) — **MEDIUM**, primary source inspected at v1.3.2 / commit `e12e81641bfe6cacc6dd246e9433d602c1240e66`.
- [Pyramid settings and defaults](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/global/settings.go) — **MEDIUM**, primary source.
- [Pyramid authentication utility](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/global/utils.go) — **MEDIUM**, primary source.
- [Pyramid admin layout/session JavaScript](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/layout/layout.templ) — **MEDIUM**, primary source.
- [Pyramid member/invitation behavior](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/pyramid/members.go) — **MEDIUM**, primary source.
- [Pyramid group authorization](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/groups/reject-event.go) — **MEDIUM**, primary source.
- [Pyramid group query/privacy behavior](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/groups/queries.go) — **MEDIUM**, primary source.
- [Pyramid group deletion processing](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/groups/process-event.go) — **MEDIUM**, primary source.
- [Pyramid relay server/event deletion paths](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/main.go) — **MEDIUM**, primary source.
- [Pyramid Blossom handler](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/blossom/handler.go) — **MEDIUM**, primary source.
- [Pyramid link preview handler](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/linkpreview/handler.go) — **MEDIUM**, primary source.
- [Pyramid curation/aggregation logic](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/curation.go) — **MEDIUM**, primary source.
- [Pyramid data-path initialization](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/global/global.go) and [logging configuration](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/global/logging.go) — **MEDIUM**, primary sources.
- [Pyramid easy installer](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/easy.sh) and [built-in updater](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/updates.go) — **MEDIUM**, primary sources.
- [Pyramid container build](https://github.com/fiatjaf/pyramid/blob/e12e81641bfe6cacc6dd246e9433d602c1240e66/Dockerfile) and [Docker build best practices](https://docs.docker.com/build/building/best-practices/) — **MEDIUM**, primary sources.
- [Caddy reverse proxy documentation](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy) and [global trusted-proxy options](https://caddyserver.com/docs/caddyfile/options) — **MEDIUM**, official documentation.
- [imgproxy configuration controls](https://docs.imgproxy.net/3.25.x/configuration/options) — **MEDIUM**, official documentation.

### Nostr and Blossom Specifications

- [NIP-29: Relay-based groups](https://github.com/nostr-protocol/nips/blob/master/29.md) — **MEDIUM**, primary draft specification.
- [NIP-46: Nostr remote signing](https://github.com/nostr-protocol/nips/blob/master/46.md) — **MEDIUM**, primary specification.
- [NIP-44: Encrypted payloads](https://github.com/nostr-protocol/nips/blob/master/44.md) — **MEDIUM**, primary specification.
- [NIP-59: Gift wrap](https://github.com/nostr-protocol/nips/blob/master/59.md) — **MEDIUM**, primary specification.
- [NIP-09: Event deletion request](https://github.com/nostr-protocol/nips/blob/master/09.md) and [NIP-62: Request to vanish](https://github.com/nostr-protocol/nips/blob/master/62.md) — **MEDIUM**, primary specifications.
- [NIP-42: Relay authentication](https://github.com/nostr-protocol/nips/blob/master/42.md), [NIP-11: Relay information](https://github.com/nostr-protocol/nips/blob/master/11.md), and [NIP-65: Relay list metadata](https://github.com/nostr-protocol/nips/blob/master/65.md) — **MEDIUM**, primary specifications.
- [NIP-70: Protected events](https://github.com/nostr-protocol/nips/blob/master/70.md), [NIP-37: Draft events](https://github.com/nostr-protocol/nips/blob/master/37.md), and [NIP-98: HTTP authentication](https://github.com/nostr-protocol/nips/blob/master/98.md) — **MEDIUM**, primary specifications.
- [Blossom BUD-02: Blob upload/retrieval](https://github.com/hzrd149/blossom/blob/master/buds/02.md), [BUD-06](https://github.com/hzrd149/blossom/blob/master/buds/06.md), and [BUD-11: Authorization](https://github.com/hzrd149/blossom/blob/master/buds/11.md) — **MEDIUM**, primary draft specifications.

### Legal/Policy Sources — Applicability Unresolved

- [18 U.S.C. §2258A](https://uscode.house.gov/view.xhtml?edition=2023&num=0&req=granuleid%3AUSC-2023-title18-section2258A) — **MEDIUM**, official statute; cited only to identify a counsel question.
- [US Copyright Office DMCA designated-agent directory](https://www.copyright.gov/dmca-directory/), [DMCA overview](https://www.copyright.gov/dmca/), and [Section 512 study](https://www.copyright.gov/512/) — **MEDIUM**, official sources; cited only to identify safe-harbor questions.
- [EU Digital Services Act, Regulation (EU) 2022/2065](https://eur-lex.europa.eu/eli/reg/2022/2065/oj) — **MEDIUM**, official legislation; cited only to identify notice/action and scope questions.

## Confidence Notes

| Area | Confidence | Reason |
|------|------------|--------|
| Pyramid-specific implementation risks | MEDIUM | Direct source inspection at a pinned current release, but deployment patches/configuration may change behavior |
| NIP/Blossom semantics | MEDIUM | Primary specifications, several intentionally optional or draft; client/relay behavior varies |
| Infrastructure/operations | MEDIUM | Official documentation plus project-specific inference requiring deployment tests |
| Client compatibility | MEDIUM | Confirmed protocol variability and Pyramid special case; exact current app versions must be tested |
| Adoption/cold start | MEDIUM | Strong product inference, not a protocol fact; pilot data required |
| Legal obligations | LOW for applicability | Official legal texts identify questions, but facts and counsel are missing; no legal conclusion is asserted |
