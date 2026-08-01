# Roadmap: Sovereign Engineering Nostr Community Infrastructure

## Overview

Delivery begins with a bounded, source-unmodified stock-Pyramid discovery pilot. That pilot produces executable compatibility, safety, operations, and cohort evidence, then ends at a hard decision gate. Only an affirmative evidence-backed decision unlocks production authority hardening, community experience, companion services, public launch, and post-launch expansion. Every client-facing surface remains replaceable and non-authoritative; Pyramid remains community authority. The separate hosted headless-applet product direction is excluded from this roadmap.

## Phases

- [ ] **Phase 1: Stock Pyramid Discovery Pilot** - Learn what current stock Pyramid and existing clients/signers actually deliver inside a minimal safe live-testing envelope.
- [ ] **Phase 2: Production Authority and Governance** - Establish reproducible, secure Pyramid authority, enforceable membership policy, operator continuity, and binding operating decisions.
- [ ] **Phase 3: Core Community Experience** - Deliver the complete text-conversation experience through replaceable existing and thin hosted client surfaces without taking custody of keys.
- [ ] **Phase 4: Media, Federation, and Public Launch** - Add independently bounded files and public discovery, then prove recovery, load, operations, security, cost, and launch readiness.
- [ ] **Phase 5: Evidence-Led Expansion and Education** - Add optional post-core capabilities and publish reusable guidance only after stable launch and measured demand.

## Phase Details

### Phase 1: Stock Pyramid Discovery Pilot

**Goal**: A small named alumni cohort can safely exercise an exact current, source-unmodified stock Pyramid build through existing clients and member-controlled signers, producing the evidence needed for a hard next-milestone decision.
**Depends on**: Nothing (first phase)
**Requirements**: PILOT-01, PILOT-02, PILOT-03, PILOT-04, PILOT-05, PILOT-06, PILOT-07, PILOT-08, DOC-01
**Success Criteria** (what must be TRUE):

  1. Operators can identify, reproduce, deploy, and verify the exact current upstream Pyramid pin and its effective configuration without modifying Pyramid source.
  2. The disposable pilot exposes only Caddy/TLS publicly, keeps Pyramid and administration restricted, runs under least privilege and bounded logs, and has executable backup and rollback evidence.
  3. A small named alumni cohort can use existing clients with NIP-07, NIP-46, or NIP-55 signers without giving private keys or signer secrets to project infrastructure.
  4. Membership, invitations, group privacy modes, roles, NIP-42, NIP-50, conversation, deletion, reconnect, rejection, and destination behavior have retained pass/fail captures plus participant feedback in the private build journal.
  5. A documented review classifies each finding and makes a hard proceed, revise, replace, or stop decision; no hosted client, standalone media, federation, curation, companion API, or Pyramid patch is assumed before that decision.

**Plans**: 1/9 plans executed

Plans:
**Wave 1**

- [x] 01-01-PLAN.md — Start private journal first; revalidate, build, and locally trace exact stock Pyramid; record simple NIP-86 coverage

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 01-02-PLAN.md — Authorize disposable VPS, private mesh, DNS, backup, recovery, and independent IPv4/IPv6 scan runners

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 01-03-PLAN.md — Deploy exact stock Pyramid private-first with least privilege, dual-stack firewall, and reviewed effective settings

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 01-04-PLAN.md — Prove backup/restore/rollback/discard and expose only public 80/443 after complete external verification

**Wave 5** *(blocked on Wave 4 completion)*

- [ ] 01-05-PLAN.md — Send exact stock-membership disclosure and retain private per-member consent before roster access/mutation

**Wave 6** *(blocked on Wave 5 completion)*

- [ ] 01-06-PLAN.md — Import consenting roster subset, verify quiet directory listing, and publish plain onboarding/test/review documents

**Wave 7** *(blocked on Wave 6 completion)*

- [ ] 01-07-PLAN.md — Run every required live stock, signer, strict NIP-86, destination, failure, and feedback observation through blocking sessions

**Wave 8** *(blocked on Wave 7 completion)*

- [ ] 01-08-PLAN.md — Manually review all private evidence and select exactly one hard verdict

**Wave 9** *(blocked on Wave 8 completion)*

- [ ] 01-09-PLAN.md — Enact selected containment, exit, discard, or next-milestone branch

### Phase 2: Production Authority and Governance

**Goal**: Operators and members can rely on a reproducible Pyramid production authority with enforceable roles, secure administration, clear policies, and two-operator continuity.
**Depends on**: Phase 1 hard decision gate approves continued Pyramid-centered implementation
**Requirements**: GOV-01, GOV-02, GOV-03, GOV-04, GOV-05, GOV-06, SEC-01, SEC-02, SEC-03, SEC-04, SEC-05, SEC-06, SEC-07, MEM-01, MEM-02, MEM-03, MEM-04, MEM-05, MEM-06, MEM-07, OPS-01, DOC-06
**Success Criteria** (what must be TRUE):

  1. Either root operator can reproduce and deploy the selected pinned Pyramid build to a fresh Debian VPS with verified provenance, least-privilege state, Caddy as the only public listener, no infrastructure-held member keys, and risky unused modules disabled.
  2. Administrators can manage alumni and friend admission, NIP-05 identifiers, roster-derived badges, and an opt-in directory through an executable capability matrix; display roles never substitute for authorization.
  3. Browser administration uses one-time authentication, short secure server-side sessions, CSRF and destructive-action checks, while every privileged endpoint passes repository-grounded allow/deny tests.
  4. Members can read the applicable operator, jurisdiction, privacy, moderation, retention, deletion, federation, and attachment policies; permanent names, domains, NIP-05 namespace, GitHub owner, and repository identity are decided before dependent public assets exist.
  5. Two independent root operators can complete recovery and handover without sharing keys, implementation changes follow the approved issue/branch/draft-PR/review loop, and public launch remains blocked until all evidence gates pass.

**Plans**: TBD
**UI hint**: yes

### Phase 3: Core Community Experience

**Goal**: Members can participate in the community's complete core text-conversation loop through supported BYOK clients and coherent, replaceable, non-authoritative web surfaces.
**Depends on**: Phase 2
**Requirements**: CONV-01, CONV-02, CONV-03, CONV-04, CONV-05, CONV-06, CONV-07, CONV-08, CONV-09, CONV-10, CONV-11, CLNT-01, CLNT-02, CLNT-03, CLNT-04, CLNT-05, UI-01, UI-02, UI-03, UI-04, UI-05, UI-06, UI-07, FED-01
**Success Criteria** (what must be TRUE):

  1. Public visitors can read an approved-member chronological feed and signature-preserving manual Best of, while members can use a public town square for notes, replies, reactions, and long-form posts.
  2. Authorized alumni can use access-controlled rooms and scoped search while anonymous or unauthorized readers are denied; every such room is labeled operator-readable, and supported notifications plus member-side mute/block remain available.
  3. Only approved identities can publish to Pyramid; members can also publish unchanged signed public events to chosen public relays, while destination captures prove access-controlled events never reach trap or public relays.
  4. Pinned client/signer/relay triples cover Flotilla, Nostrord, Jumble and approved NIP-07/46/55 signers with executable login, reconnect, publish, invitation, role, privacy, search, rejection, and error evidence—without raw-key onboarding.
  5. The portal and any evidence-gated hosted client provide coherent onboarding, privacy/status/help and canonical deep links on isolated origins, use reproducible immutable artifacts with no unapproved endpoints, analytics, signer custody, server authority, or durable auth state, and can be removed or rolled back without changing community state.

**Plans**: TBD
**UI hint**: yes

### Phase 4: Media, Federation, and Public Launch

**Goal**: The community can safely handle public files and bounded external discovery while operators prove the complete system recoverable, observable, supportable, affordable, and ready for public opening.
**Depends on**: Phase 3
**Requirements**: MEDIA-01, MEDIA-02, MEDIA-03, MEDIA-04, MEDIA-05, MEDIA-06, MEDIA-07, FED-02, FED-03, FED-04, FED-05, OPS-02, OPS-03, OPS-04, OPS-05, OPS-06, OPS-07, OPS-08, OPS-09, OPS-10, OPS-11, OPS-12
**Success Criteria** (what must be TRUE):

  1. Approved members can upload, retrieve, report, and delete allowed public files through signed authorization on an isolated Blossom service with roster-based access, quotas, MIME/hash enforcement, quarantine, capacity protection, and proven blank-host restore; sensitive room attachments remain disabled.
  2. The community can query bounded allowlisted relays for approved members' public events with provenance, deduplication, incomplete-source reporting, strict private/protected/control-event rejection, and no direct Pyramid writes.
  3. Valid local deletions remove active and derived state, preserve anti-resurrection tombstones, document remote-copy limits, and age deleted events and media out of encrypted off-host backups on schedule.
  4. Both operators can observe protocol and resource health, detect secret/private-data canaries, restore a blank host within measured RPO/RTO, and exercise incident, moderation, abuse, deletion, upgrade, rollback, capacity, credential, and handover procedures.
  5. Public opening occurs only after the 30-day alumni pilot, full compatibility and destination matrix, restore and load drills, threat model and security review, no unresolved critical/high defects, exercised runbooks, and a measured monthly forecast below US$100.

**Plans**: TBD

### Phase 5: Evidence-Led Expansion and Education

**Goal**: After stable launch, members gain demand-proven optional capabilities and other communities gain evidence-based material they can safely reproduce and adapt.
**Depends on**: Phase 4 public launch gate passes
**Requirements**: EXT-01, EXT-02, EXT-03, EXT-04, EXT-05, DOC-02, DOC-03, DOC-04, DOC-05, MET-01, MET-02, MET-03
**Success Criteria** (what must be TRUE):

  1. Members can opt into a richer community map, NIP-52 events, and value-for-value support without creating a second identity authority or making payment a condition of participation.
  2. Members can discover community Git projects and use a separately operated kind-restricted NIP-34/GRASP collaboration relay without admitting ordinary social or group events.
  3. A materialized public-event aggregator is introduced only if direct-query evidence proves need, and remains a bounded non-public client with provenance/checkpoint state rather than a second relay or search authority.
  4. Operators can evaluate aggregate adoption, activity, storage, reliability, moderation load, operator burden, and qualitative alumni feedback without profiling, including the six-month 80-alumni, 40-weekly-active, and approximately 20-friend targets.
  5. After stable launch, readers can use a verified educational website, sanitized quickstart, and Nostr long-form series; operators make an explicit repository-publication decision that excludes secrets, member data, credentials, and unsafe defaults.

**Plans**: TBD
**UI hint**: yes

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Stock Pyramid Discovery Pilot | 1/9 | In Progress|  |
| 2. Production Authority and Governance | 0/TBD | Not started | - |
| 3. Core Community Experience | 0/TBD | Not started | - |
| 4. Media, Federation, and Public Launch | 0/TBD | Not started | - |
| 5. Evidence-Led Expansion and Education | 0/TBD | Not started | - |

## Coverage Summary

- v1 requirements: 89
- Mapped exactly once: 89
- Unmapped: 0
- Duplicate mappings: 0
