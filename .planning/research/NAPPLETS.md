# Napplet / Kehto Applicability to the Pyramid Community

**Project:** Sovereign Engineering Nostr Community Infrastructure  
**Researched:** 2026-07-30  
**Mode:** Ecosystem and feasibility supplement  
**Confidence:** MEDIUM

## Verdict

**Defer Napplet/Kehto from the production critical path, but design explicit extension seams now.** Do not use it as the primary community UX/runtime and do not make it the launch companion shell. After Pyramid's core conversation and recovery gates pass, run one isolated experiment: a read-only public-feed or public-directory napplet hosted by a separately deployed Kehto shell.

The paradigm is relevant, but it does not already contain Pyramid's relay features. Current code can mediate untrusted client tools through a host-controlled relay, signer, upload, fetch, storage, notification, and intent boundary. It does **not** implement a relay server, authoritative community policy, or server operations. Pyramid must still own membership, invites, roles, NIP-29 enforcement, NIP-42 relay behavior, NIP-86 administration, NIP-05, NIP-50, event persistence, moderation, and deletion. A Blossom server must still own blob persistence, quotas, deletion, abuse handling, and backup.

This is also a maturity decision. NIP-5D remains an open draft. Most NAPs needed here remain draft. `napplet/web` calls the SDK **alpha**. `kehto/web` calls itself an early alpha, says it is far from complete, and explicitly leaves envelope security, process isolation, performance optimization, and real host adapters to the integrator. Those are incompatible with this project's quality-gated launch unless the project effectively becomes a Kehto productization effort.

## Repository Names and Exact Source Pins

The canonical namespace is **`napplet`**, singular and lower-case. “Napplets” describes multiple applets; it is not the GitHub organization or SDK name. The three repositories are:

| Canonical repository | Inspected commit | Role |
|---|---|---|
| [`napplet/naps`](https://github.com/napplet/naps/tree/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24) | `5ac0490461ca6fec2f0d2e45b4835cf9bc08de24` (2026-07-24) | Registry/governance for NAP capability contracts and archetypes. No runtime code. |
| [`napplet/web`](https://github.com/napplet/web/tree/03ad65b66413e5798536ef48695ffc4c2508f2c3) | `03ad65b66413e5798536ef48695ffc4c2508f2c3` (2026-07-28) | Portable napplet-side SDK, shims, types, build/deploy tooling, and conformance tooling. It is not a host runtime or relay. |
| [`kehto/web`](https://github.com/kehto/web/tree/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f) | `3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f` (2026-07-29) | One early browser host runtime implementation plus reference services and a playground. It is not Pyramid and is not a production community client. |

Historical README badges/links still mention `napplet/napplet` or `sandwichfarm/napplet`; use `napplet/web` as the current canonical SDK repository.

## Terms: Keep These Layers Separate

| Term | Exact meaning | It does not mean |
|---|---|---|
| **NIP-5A manifest substrate** | Draft nsite manifest schema: `path` tags map paths to Blossom hashes; `x` can carry a deterministic aggregate hash. NIP-5D adopts this tag schema. | A napplet runtime, permission system, relay protocol, or Pyramid API. |
| **NIP-5D shell** | Open draft web projection for verified, single-file napplets loaded through `srcdoc` into `sandbox="allow-scripts"` iframes. The shell injects selected `window.napplet.<domain>` surfaces and binds messages to verified `(dTag, aggregateHash)` identity through `MessageEvent.source`. | A Nostr relay server or generic browser plugin. |
| **NAP capability seam** | Transport-neutral contracts for operations a runtime offers an untrusted napplet, such as `relay`, `storage`, or `upload`. | Nostr protocol replacement, server implementation, or application business rules. |
| **`napplet/web` SDK** | Types, shims, wrappers, manifest/build/deploy tools, and conformance checks used by napplet authors and runtime implementers. | A host application with real persistence, signers, relay sockets, notification delivery, or policy. |
| **Kehto runtime** | Alpha host-side packages for iframe lifecycle, dispatch, ACLs, service registration, persistence interfaces, and reference services. The embedding host supplies real adapters. | A ready-to-deploy end-user shell or server-side community platform. |
| **Pyramid server** | Relay/community authority: persistent Nostr event service, member hierarchy, group policy, NIP-29, NIP-42, NIP-86 subset, NIP-05, NIP-50, moderation, and operator state. | A napplet shell or SDK domain. |

NIP-5D uses napplet kinds `5129`, `15129`, and `35129`, adopting the NIP-5A `path`/aggregate scheme while keeping napplets separate from nsite kinds `5128`, `15128`, and `35128`. This distinction is current at NIP-5D PR head [`eb45dfd7335b7f88cb53781984c553581d2b4c34`](https://github.com/nostr-protocol/nips/blob/eb45dfd7335b7f88cb53781984c553581d2b4c34/5D.md).

## Boundary

```text
untrusted napplet iframe
        │ NAP envelopes only
        ▼
Kehto shell/runtime ── capability ACL, consent, signer mediation, routing
        │ host-provided adapters and reference-service replacements
        ├──────────────► Pyramid WSS/HTTP endpoints
        ├──────────────► member-selected NIP-07/NIP-46/NIP-55 signer path
        └──────────────► standalone Blossom service

Pyramid and Blossom remain authoritative servers.
Kehto mediates a client. It does not become either server.
```

## Requested NAP Surface: Specification and Implementation Status

“Implemented” below means package/runtime code exists at the inspected commits. It does not mean the contract is stable or the handler is production-complete.

| Domain | Spec status | `napplet/web` | Kehto current implementation | Suitability here |
|---|---|---|---|---|
| **NAP-RELAY** | Open draft [PR #2](https://github.com/napplet/naps/pull/2), head `0be8abce18beb46ca37bd4ddd042f58d30b4eedc` | SDK/shim/types for subscribe, query, shell-signed publish, and shell-encrypted publish. | Core handler plus injectable relay-pool reference service. Host supplies real sockets, routing, signer, validation, and NIP behavior. | Useful client mediation seam. Not a relay. Current `group` subscription option is declared by the SDK but discarded by its shim; only explicit `relay` is sent. |
| **NAP-OUTBOX** | Open draft [PR #32](https://github.com/napplet/naps/pull/32), head `4589a8f9a16d8aa29b3740e2b3b0cdca11e0976e` | SDK/shim/types for get/query/subscribe/publish/relay-plan. | Reference service and relay-pool router implement NIP-65 discovery injection, per-relay fan-out, signature validation, deduplication, relay hints, and fallbacks. Host supplies relay lists, sockets, signer, verifier, and policy. | Strongest future fit: public member aggregation without giving a napplet raw relay access. Still draft and not a deletion/moderation lifecycle system. |
| **NAP-IDENTITY** | Merged but still marked `draft` in [`NAP-IDENTITY.md`](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/naps/NAP-IDENTITY.md) | Read-only current signer/profile/relay/follow/list/zap/mute/block/badge queries. | Reference service returns real pubkey/relay data when a signer exists; every richer query requires a host provider and otherwise returns empty values. | Good BYOK identity view. It is not the authoritative alumni roster, membership, role, or invite system. |
| **NAP-UPLOAD** | Open draft [PR #33](https://github.com/napplet/naps/pull/33), head `a7cc17463cbf5d9cb87884b31071bc4fc826034c` | SDK/shim/types for info, upload, status, and progress. | Reference service plus HTTP uploader for NIP-96 and Blossom. It constructs/signs auth, uploads bytes, and checks returned Blossom hash/size. | Useful future public-upload mediation. Missing delete, roster/quota synchronization, abuse/report workflow, retention, scanning, private attachments, and server operations. |
| **NAP-RESOURCE** | Merged but still marked `draft` in [`NAP-RESOURCE.md`](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/naps/NAP-RESOURCE.md) | SDK/shim/types for policy-mediated bytes, batches, object URLs, and schemes including HTTPS/Blossom/Nostr. | Reference fetch proxy requires host fetch, identity resolution, origin grants, and policy. Default disclosed scheme is HTTPS; other schemes need host resolution. Source says SSRF, redirect, MIME, and private-IP hardening remain host responsibility. | Useful read-only seam only after a hardened resolver exists. Never an admin HTTP escape hatch. |
| **NAP-CONFIG** | Open draft [PR #14](https://github.com/napplet/naps/pull/14), head `448013e6d8cb8c75dce49576b3e7c0d46d960eac` | SDK/shim/types for schema registration, read, subscribe, and shell settings UI. No `config.set`. | Reference service exposes host-owned values; shell is sole writer; strict schema/persistence/settings UI remain host work. | Good non-authoritative per-tool settings. Not community policy or Pyramid configuration authority. |
| **NAP-STORAGE** | Open draft [PR #3](https://github.com/napplet/naps/pull/3), head `f71e84ebca7474db260346cbfc2d88f41b4e421e` | SDK/shim/types for scoped string KV. | Runtime implements per-`(dTag, aggregateHash)` shared/instance namespaces and quota over an injected `StatePersistence`. | Good drafts/layout/cache. It is **not** Nostr event storage, relay persistence, backup, or roster state. |
| **NAP-NOTIFY** | Open draft [PR #11](https://github.com/napplet/naps/pull/11), head `e14f5c9d6a6dd2a69ccf79668c4a3c1e955e1ac9` | SDK/shim/types for notifications, permission, badge, channels, and actions. | Kehto source labels its canonical handler **stub-level**: no real Notification API, channel registry, push delivery, or interaction pushes. | Not launch-ready. A real host notification backend, privacy policy, push lifecycle, and platform tests are required. |
| **NAP-INTENT** | Active in registry at [`NAP-INTENT.md`](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/naps/NAP-INTENT.md) | SDK/shim/types for invoking installed napplets by archetype and discovering handlers. | Reference service delegates catalog, chooser/default, window lifecycle, and delivery to an injected resolver. | Good future composition/navigation seam. It routes to another napplet; it is not a privileged Pyramid management RPC. |

### Cross-cutting maturity facts

- [`napplet/web` README](https://github.com/napplet/web/blob/03ad65b66413e5798536ef48695ffc4c2508f2c3/README.md) says the project is alpha, experimental, and expected to drift.
- [`kehto/web` README](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/README.md) and [`docs/alpha-status.md`](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/docs/alpha-status.md) explicitly limit current use to experimentation with draft host-side shape.
- Package versions remain pre-1.0 (`@napplet/core`/`nap` 0.31.0; `@kehto/runtime` 0.20.1; `@kehto/shell` 0.19.1; `@kehto/services` 0.18.1).
- Kehto is a package set plus playground. Its minimal-host tutorial begins with no-op/in-memory adapters and requires the integrator to replace them with real relay, signer, cache, persistence, policy, and UI implementations.
- Current source has visible drift: the NAP-RELAY SDK accepts a `group` option but the shim does not transmit it; relay publish options are accepted then ignored; `NostrFilter` lacks NIP-50's `search` field; older Kehto docs/test names retain legacy `AUTH` terminology around a NIP-5D model that no longer uses a napplet authentication handshake.

## Pyramid Requirement Map

| Pyramid need | Does Napplet/Kehto already provide it? | Evidence-based conclusion / work required |
|---|---|---|
| Authoritative membership, alumni/friend/admin roles, admin-only invites | **No** | Kehto ACL authorizes a napplet identity `(dTag, aggregateHash)` to call runtime capabilities. It does not authorize community pubkeys or model Pyramid hierarchy. Keep one Pyramid/companion roster authority; a napplet may only display it or submit an operator-reviewed action. |
| NIP-29 group reads/posts | **Partial mediation** | Generic filters/events can pass through NAP-RELAY, and an explicit Pyramid relay URL can be targeted. Build and test a Pyramid-specific host relay adapter. Fix upstream group/scoped-relay helper drift. |
| NIP-29 group creation, membership, roles, moderation | **No dedicated capability** | Some control events could be submitted as generic signed event templates, but safe authorization, exact relay destination, consent, result interpretation, and refresh are application work. Server enforcement remains Pyramid. Never infer authority from Kehto's napplet ACL. |
| NIP-42 client authentication | **Host adapter work** | Napplet iframes have no WebSocket access. The Pyramid relay connection must answer NIP-42 inside the shell-owned relay pool using the user signer and exact relay challenge. Current reference relay interface does not define or prove this lifecycle. |
| NIP-86 relay administration | **Missing / unsuitable** | No NAP provides privileged relay JSON-RPC administration. NAP-RESOURCE is read-only and must not become generic authenticated HTTP. Keep NIP-86 in a trusted operator UI/backend, or propose a narrowly scoped upstream NAP before any napplet exposure. |
| NIP-05 names | **No** | Serving and managing `/.well-known/nostr.json` is Pyramid/web infrastructure. NAP-IDENTITY may read a profile's `nip05`; it does not provision or revoke names. |
| NIP-50 search | **Missing from current relay filter type** | `@napplet/core` `NostrFilter` has standard ids/authors/kinds/time/limit/tag filters but no `search`. Add it upstream through the canonical NAP/package chain, then implement/query-test the Pyramid adapter and private-boundary behavior. |
| Relay-wide moderation and NIP-29 moderation | **Server missing; client surface partial** | Kehto can gate what a napplet asks the signer/relay to do. It cannot enforce what Pyramid accepts or serves. Operator moderation actions need trusted UI, exact authority, audit, and server confirmation. |
| Signed event deletion | **Generic event possible; lifecycle missing** | A napplet can ask the shell to sign/publish a kind-5 event. Kehto does not track deletion propagation, search/cache removal, backup aging, or outside copies. Those remain project services/runbooks. |
| Relay persistence, indexing, backup, restore, upgrades | **No** | NAP-STORAGE is small per-napplet KV. Kehto's caches and persistence interfaces are host/browser state. They do not replace Pyramid's mmap event store, NIP-50 index, coherent snapshots, or VPS operations. |
| General Blossom upload | **Partial reference implementation** | NAP-UPLOAD + Kehto HTTP uploader can upload public bytes with NIP-98/Blossom auth and integrity checks. Build real size/MIME/quota/consent policy, roster coupling, upload deletion, reports, scanning/quarantine, capacity, backup/restore, and private-content guardrails. |
| Public cross-relay aggregation | **Promising but alpha** | NAP-OUTBOX and Kehto's router already model NIP-65 discovery, fan-out, signature validation, dedup, and provenance hints. Add bounded roster input, relay-URL policy, deletion/vanish tracking, moderation boundary, metrics, and load tests. Start read-only. |
| Admin UX | **UI paradigm only** | Napplet isolation and composition can host focused admin tools, but no current NAP exposes safe Pyramid management. A trusted host page is simpler and safer for launch. |
| Server observability and operations | **No** | Kehto's runtime ACL/firewall/audit callbacks concern embedded applets. VPS health, Caddy, Pyramid logs/metrics, alerting, backup, upgrades, disaster recovery, and two-operator handover remain separate. |

## Choice Assessment

| Choice | Assessment | Decision |
|---|---|---|
| **Use now as primary community UX/runtime** | Would require productizing Kehto, building real services/adapters, resolving draft drift, implementing Pyramid admin seams, and creating all community napplets before validating the community itself. | **Reject.** Too much critical-path protocol/runtime/UI scope. |
| **Use now for thin companion shell** | Architecturally attractive, but the current companion only needs onboarding, roster/admin, discovery, and status. A conventional trusted web surface is smaller, more accessible across devices, and easier to secure. | **Reject for launch.** Revisit only after the shell is independently production-ready. |
| **Use only as an experimental lane now** | Provides learning, but any pre-launch deployment still consumes scarce compatibility/security effort and risks confusing pilot users. | **Do not deploy now.** A local spike is acceptable only if it cannot block roadmap work. |
| **Defer but design extension seams** | Preserves future portability and focused app composition without importing an alpha runtime into the trust/availability boundary. | **Recommend.** First post-stability experiment: read-only public feed/directory. |

## Minimal Future Integration Contract

This is a project-side adapter contract, not a new NAP specification. Implement it only with canonical NAP operations that exist at the selected pinned refs. If a needed operation is absent, propose it in `napplet/naps` before adding wire surface.

### Host-owned inputs

| Boundary | Minimum contract | Safety rule |
|---|---|---|
| `PyramidRelayAdapter` | Subscribe/query/publish through exact allowlisted `wss://` endpoints; sign via selected member signer; return relay hints and per-relay results. | Shell owns URL validation, NIP-42, reconnect, rate limits, signer consent, and public/private destination policy. |
| `CommunityReadModel` | Read-only roster labels, public group metadata, service URLs/status, and feature flags sourced from the authoritative systems. | No napplet-written membership, invite, role, moderation, or deletion state. |
| `PublicOutboxAdapter` | Query roster pubkeys' public events; validate signatures; deduplicate by event ID; retain relay provenance and incomplete state. | Explicit public kinds/relays only; no private/protected group imports; bounded authors, connections, time, and results. |
| `PublicUploadAdapter` | NAP-UPLOAD to configured standalone Blossom; disclose max size/MIME; return verified hash/size/URL. | Public-content warning, member signer, quota check, delete linkage, and no private-room plaintext. |
| `NappletStateAdapter` | Per-content-version KV for drafts, preferences, and layout. | Never authoritative; disposable without community data loss. |
| `ShellConfigAdapter` | Read-only community endpoint/theme/config values and shell settings UI. | Secrets and operator tokens never enter napplet-visible values. |
| `NotificationAdapter` | Opt-in host-rendered alerts from already-authorized public/user-visible events. | Minimal metadata; no raw private event body in push infrastructure. |
| `IntentCatalog` | Route between focused public feed, profile, article, directory, and upload napplets. | Navigation only; not a substitute for privileged server commands. |

### Explicitly outside the napplet boundary

- Pyramid process/configuration, NIP-86 credentials, root admin sessions, and operator recovery.
- Authoritative roster, invite issuance, role assignment, NIP-05 provisioning, group ACL, moderation, and audit log.
- Blossom server credentials, retention, deletion authority, abuse queue, quarantine, backup, and restore.
- Monitoring, alerts, deployment, upgrades, rollback, disaster recovery, and billing.

## Anti-Duplication Rule

**A Kehto shell or napplet MUST NOT become a second source of truth for community state.** It may cache or project authoritative state, but it must never independently own membership, invitations, roles, group access, NIP-05 names, moderation decisions, event deletion/tombstones, Blossom ownership, or relay configuration.

Each projected record must retain its authority and provenance:

```text
record = { authority, stableId/eventId, sourceVersion, observedAt, stale }
```

Writes go to the authoritative system and succeed only after authoritative confirmation. Local optimistic UI is marked pending and is recoverable. If Pyramid or the companion authority is unavailable, admin tools fail closed; they do not mutate a Kehto-local shadow roster and reconcile later.

## What Would Need Building Before Production Use

1. Pin NIP-5D, all selected NAP proposal heads, `@napplet/*`, and `@kehto/*`; generate a single compatibility ledger and re-audit on every update.
2. Replace playground/no-op services with a production host application and durable adapters; close every item in Kehto's own alpha warning.
3. Implement and test Pyramid relay transport, including NIP-42, explicit relay/group targeting, NIP-29 control flows, reconnect, EOSE/CLOSED/OK errors, rate limits, and signer consent.
4. Add NIP-50 filter support through the upstream NAP/package/runtime chain rather than a Kehto-only field.
5. Keep NIP-86 and root administration outside napplets until a narrowly scoped, audited upstream capability exists; likely retain a trusted host/operator surface permanently.
6. Complete public upload policy and deletion lifecycle; do not use NAP-UPLOAD for private plaintext.
7. Build a real notification backend only if pilot demand justifies it.
8. Audit NIP-5D iframe loading against the live draft: verified bytes, `srcdoc`, exact sandbox, source binding, injected CSP/namespace, and no `window.nostr`.
9. Run adversarial tests for malicious napplets: signer abuse, event-kind/tag tricks, arbitrary relay URLs, SSRF, resource redirects, upload exhaustion, storage exhaustion, notification spam, intent confusion, and private/public routing leaks.
10. Prove mobile/desktop accessibility, update/rollback, artifact resolution, offline behavior, and exit with production-shaped clients and signers.

## Acceptance Gate for the First Experiment

The first experiment should be a **read-only public surface** and must pass all of these before alumni see it:

- Exact NIP-5D/NAP/package/Kehto pins recorded; no floating package ranges.
- Verified manifest/blob/aggregate path; `srcdoc`; `sandbox="allow-scripts"`; no `allow-same-origin`; no raw signer or network global.
- Only `shell`, read-only `identity`, bounded `relay` or `outbox`, `resource`, non-authoritative `storage`, `config`, and `intent` domains exposed.
- Pyramid relay allowlist fixed; private group relays and kinds impossible to request; packet/event capture proves this.
- No admin, invite, role, moderation, deletion, NIP-05, or Blossom write surface.
- CPU, memory, connection, request, event, resource-byte, and storage quotas enforced.
- Malicious test napplet cannot bypass domain grants, forge source identity, reach arbitrary URLs, or trigger signing.
- Removing the Kehto deployment has zero effect on Pyramid, Blossom, member identities, or community data.

## Learnings Worth Applying Even If Deferred

1. **Small tools, composed by a shell, fit the project's Unix-like philosophy.** Keep public feed, directory, long-form, upload, moderation, and relay diagnostics as separable surfaces rather than one custom-client monolith.
2. **Runtime mediation is a useful least-authority model.** Existing companion UI should isolate signer, relay destinations, upload servers, and privileged administration behind narrow adapters even without Kehto.
3. **Content-addressed UI artifacts improve auditability and rollback.** The NIP-5A aggregate / NIP-5D verified-byte model is valuable for later educational or community tools.
4. **Capabilities must bind to code identity and source.** Kehto's `(dTag, aggregateHash)` lesson translates to pinned UI releases, per-tool permissions, and explicit upgrade review.
5. **Higher-level outbox routing belongs outside each feature UI.** NAP-OUTBOX's discovery/dedup/provenance decomposition is a strong model for the project's future public aggregation sidecar.
6. **Local UI storage is not community state.** Preserve that boundary in the launch companion app.
7. **A generic network escape destroys mediation.** Keep relay, fetch, upload, and admin APIs distinct; never turn a fetch proxy into arbitrary authenticated HTTP.
8. **Protocol text outranks reference code.** Current Napplet/Kehto drift demonstrates why every integration needs a pin plus executable conformance, not a package-presence claim.

## Roadmap Implication

Do not add a Napplet implementation phase before the 30-day alumni pilot or public launch gate. Add one sentence to architecture contracts now: **all client-facing features consume replaceable adapters and authoritative server APIs; no UI owns community authority**. After stable launch, open a bounded research spike under the existing Phase 8 custom-client/education track:

1. Revalidate NIP-5D and selected NAP heads.
2. Build the read-only public feed/directory experiment.
3. Measure security burden, load, accessibility, maintainability, and whether composition is better than Jumble/Flotilla plus the conventional companion UI.
4. Promote only if it replaces existing code or solves a measured user job; otherwise retain the architectural learnings and remove the experiment.

## Primary Sources

- [NIP-5A at NIPs commit `6d2979b3f503a8539c983efbcdcf901bbcf9ed23`](https://github.com/nostr-protocol/nips/blob/6d2979b3f503a8539c983efbcdcf901bbcf9ed23/5A.md) — draft nsite manifest and aggregate-hash substrate; `MEDIUM`.
- [NIP-5D PR #2303, exact head `eb45dfd7335b7f88cb53781984c553581d2b4c34`](https://github.com/nostr-protocol/nips/blob/eb45dfd7335b7f88cb53781984c553581d2b4c34/5D.md) — draft napplet web projection; `MEDIUM`.
- [`napplet/naps` registry at `5ac0490`](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/README.md) and [web projection](https://github.com/napplet/naps/blob/5ac0490461ca6fec2f0d2e45b4835cf9bc08de24/projections/web.md) — canonical terms/status; `MEDIUM`.
- [`napplet/web` README at `03ad65b`](https://github.com/napplet/web/blob/03ad65b66413e5798536ef48695ffc4c2508f2c3/README.md), [`packages/nap/src`](https://github.com/napplet/web/tree/03ad65b66413e5798536ef48695ffc4c2508f2c3/packages/nap/src), and [`NostrFilter`](https://github.com/napplet/web/blob/03ad65b66413e5798536ef48695ffc4c2508f2c3/packages/core/src/types/nostr.ts) — SDK/type implementation; `MEDIUM`.
- [`kehto/web` README at `3a4d71a`](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/README.md), [alpha status](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/docs/alpha-status.md), and [architecture](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/docs/concepts/architecture.md) — official maturity/boundaries; `MEDIUM`.
- [Kehto runtime dispatcher](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/runtime/src/runtime.ts), [relay handler](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/runtime/src/relay-handler.ts), and [storage handler](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/runtime/src/state-handler.ts) — implemented host/runtime surfaces; `MEDIUM`.
- [Kehto reference services](https://github.com/kehto/web/tree/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/services/src), especially [outbox](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/services/src/outbox-service.ts), [upload](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/services/src/upload-service.ts), [HTTP uploader](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/services/src/http-uploader.ts), [resource](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/services/src/resource-service.ts), [identity](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/services/src/identity-service.ts), [notify](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/services/src/notify-service.ts), and [intent](https://github.com/kehto/web/blob/3a4d71a8f8860890cdcbf8fa25a11780fbe7a55f/packages/services/src/intent-service.ts) — reference-handler depth and gaps; `MEDIUM`.

**Confidence note:** GSD's configured classifier rates verified web research `MEDIUM`. All material claims above were cross-checked against exact current official commits and direct source. Runtime suitability remains unproven until production-shaped executable tests run.
