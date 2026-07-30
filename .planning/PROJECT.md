# Sovereign Engineering Nostr Community Infrastructure

**Working title:** Dialogos (not final)

## What This Is

Sovereign Engineering is building a Pyramid-centered, modular Nostr community infrastructure for roughly 100 alumni and a small number of admin-invited friends. It will provide a reliable public town square, private alumni spaces, media and file hosting, long-form publishing, and an expansion path toward badges, Git collaboration, events, value-for-value support, governance, and other Nostr-native community tools.

The community should become the alumni's default place for broad professional, technical, philosophical, and social conversation while producing a high-signal public feed that outsiders actively follow. After the live system is internally stable, the project will turn its private build journal into an educational website experience, reproducible guidance, and Nostr long-form material that helps other communities understand, deploy, and adapt sovereign community infrastructure.

## Core Value

Give Sovereign Engineering alumni a reliable, high-signal online town square they choose to use every week without surrendering identity, keys, portability, or exit.

## Business Context

- **Community:** Approximately 100 Sovereign Engineering alumni plus admin-invited friends and a public readership
- **Economic model:** Value for value; membership is never paywalled and financial support is always optional
- **Six-month success metric:** 80 alumni onboarded, 40 weekly active alumni, and approximately 20 invited friends
- **Priority order:** Adoption, conversation quality, public influence, then value as a reusable reference deployment

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Deploy a stable Pyramid relay as the community's central relay component on a fresh, dedicated VPS.
- [ ] Keep the system modular and Unix-like: Pyramid owns only the relay/community functions it supports well; separate services own media, Git, web, observability, and other concerns.
- [ ] Allow approved alumni and admin-invited friends to publish while the public can read public content.
- [ ] Distinguish alumni, invited-friend, and administrator roles; only administrators can invite friends.
- [ ] Support a public chronological member feed plus a manually curated "Best of" showcase.
- [ ] Support public town-square conversations and access-controlled alumni rooms in the first release.
- [ ] Add audited end-to-end encrypted rooms later where protocol and client support permit.
- [ ] Support public notes, replies, reactions, and long-form posts in the first release.
- [ ] Operate a Blossom-compatible general-purpose file and media service with authentication, quotas, deletion, abuse controls, storage forecasting, and backups.
- [ ] Ensure private attachments are never exposed as publicly retrievable plaintext; research client-side encryption and authenticated delivery before selecting a design.
- [ ] Let members bring their own keys and use browser signing extensions, Amber, iOS remote signing, and NIP-46 bunker workflows without exposing private keys to Dialogos infrastructure.
- [ ] Target compatibility with nos2x, nos2x Firefox, Amber, iOS remote signing, NIP-46 bunker signers, Nostrord, Flotilla, and Jumble.
- [ ] Prefer focused upstream contributions and a thin onboarding/admin/discovery UI where needed, without making upstream acceptance a critical-path dependency.
- [ ] Permit a full custom client in a later phase if existing clients cannot deliver the intended coherent experience after core infrastructure works.
- [ ] Allow members to publish public events to any relays configured in their clients while preventing private events from leaking to public relays.
- [ ] Aggregate members' public posts from other relays into the community experience with deduplication, provenance, deletion propagation, and moderation boundaries defined.
- [ ] Honor valid signed event and media deletion requests in active systems and expire deleted data from backups under a documented retention policy.
- [ ] Apply minimal relay-wide moderation limited to spam, abuse, illegal content, and security threats; ordinary disagreement remains member-filtered.
- [ ] Run one primary operator and one trained backup operator with documented access, handover, incident response, upgrades, and disaster recovery.
- [ ] Keep recurring infrastructure cost below US$100 per month, excluding operator time.
- [ ] Measure success using minimal aggregate telemetry and periodic alumni feedback without behavioral profiling or ad-tech analytics.
- [ ] Launch early to alumni and expand continuously, but open publicly only after all internal stability gates pass.
- [ ] Capture architecture decisions, failures, operational evidence, and lessons privately from day one.
- [ ] After stable launch, publish education that explains the philosophy, provides a reproducible quickstart, and teaches production trade-offs and safe adaptation.
- [ ] Choose an appropriate final repository name, create the GitHub remote, and use contextual issues plus branch-based draft pull requests for implementation work.
- [ ] Integrate the external Codex GitHub review loop: poll each pull request for review results, fix actionable defects, and preserve verification evidence before merge.
- [ ] Keep all client-facing surfaces replaceable and non-authoritative: Pyramid remains the sole membership, policy, group, moderation, event, and search authority.

### Out of Scope

- Mandatory payments or paywalled membership — the community follows a value-for-value model.
- Server custody of member private keys — members bring their own keys and choose their own signing tools or bunkers.
- A Dialogos-hosted bunker service — the system interoperates with member-chosen remote signers instead.
- A Pyramid monolith containing every Nostr service — components remain small, replaceable, and independently operable.
- Dependence on upstream contributions landing on schedule — upstream work is preferred but never blocks delivery.
- A full custom client in the first infrastructure release — existing clients, upstream improvements, and thin companion surfaces come first.
- Public release before internal stability evidence exists — no calendar deadline overrides acceptance gates.
- Public release of the live deployment repository before launch — publication strategy will be decided after the system is stable, while portability is preserved from day one.
- Public plaintext attachments for private rooms — private media must be encrypted or access-controlled.
- Napplet/Kehto runtime integration in the current roadmap — use the Pyramid relay method with existing clients and conventional thin web surfaces; preserve only the architectural learning that UI must remain replaceable and non-authoritative.

## Context

### Community and Product Shape

- Sovereign Engineering alumni are highly technical and include leading Nostr developers. Onboarding can assume strong technical fluency.
- The community is broad rather than topic-restricted. Freedom tech is central to its identity, but alumni should also use it for professional, philosophical, and social conversation.
- Alumni and admin-invited friends may publish. Friends receive a distinct role and can only be invited by administrators.
- The intended public experience combines a full chronological public member feed with a curated "Best of" surface designed to create genuine interest and FOMO through conversation quality rather than artificial engagement mechanics.
- Initial release includes relay access, invitations, public notes and long-form posts, replies and reactions, public and access-controlled rooms, general-purpose Blossom storage, signing compatibility, manual curation, moderation, observability, backup/restore, and a minimal discovery/onboarding/status website.
- Continuous releases later add badges, richer Git/NIP-34 collaboration, V4V tooling, events, directories, governance, E2EE rooms, stronger discovery, and potentially a custom client.

### Sovereign Engineering Philosophy and Aesthetics

- Desired emotional direction: living sovereign network first, ancient agora second, elite hacker commons third.
- The existing Sovereign Engineering identity uses maritime exploration, stark red/white/black contrast, editorial serif typography, retro-futurist imagery, and direct language.
- Product and system decisions should reflect software people can verify, fork, host, and leave; users hold keys; dependencies stay lean; state stays inspectable; exit costs stay low.
- The product should feel like a place humans inhabit, not a SaaS dashboard.
- Naming must be researched across three territories: direct Sovereign Engineering extension, endorsed sub-brand, and independent identity. "Dialogos" remains a working title only.

### Deployment and Architecture

- Deployment target is a fresh, dedicated VPS from a private provider. Exact provider region, OS, compute, storage, backup destination, and network topology remain research and inspection tasks.
- The likely topology uses flat per-service subdomains, but research must compare this with client compatibility, TLS, authentication, isolation, and operational simplicity before hostnames are fixed.
- Pyramid is the center of the relay/community stack, not the owner of all Nostr infrastructure.
- Focused improvements should be recorded and contributed upstream where useful without expanding Pyramid into a monolith.
- The project should be easy to clone, configure, and build for another community if the repository is later made public.
- The local repository has no remote yet. Remote creation waits for naming research and an explicit repository-owner decision.
- Delivery should use contextual GitHub issues and draft pull requests. An external Codex GitHub connector reviews pull requests; the implementation workflow must poll its results, address actionable findings, and re-verify before merge.
- Napplet research confirmed that NAP/Kehto is a client-side capability-composition model, not a replacement for Pyramid's server authority. It is deferred; current delivery uses Pyramid, existing Nostr clients, and narrowly scoped companion surfaces.

### Privacy, Portability, and Federation

- Access-controlled private rooms ship first. Trusted server operators may technically access unencrypted room state; audited E2EE rooms follow when compatible.
- Public events remain portable and can be published through member-configured relay sets. Private events must not reach public relays.
- The community experience should aggregate member public events from other relays without confusing duplicates or ownership.
- Member-side mute and block tools handle ordinary disagreement. Relay-wide intervention is deliberately narrow.
- Signed deletions are honored in active services, with deleted material aged out of backups under a published retention schedule.

### Internal Stability Gate

Public opening requires all of the following:

1. A 30-day alumni pilot.
2. A successful backup-and-restore drill.
3. Load testing above expected usage.
4. A security review and repository-grounded threat model.
5. No unresolved critical or high-severity defects.
6. A verified compatibility matrix across recommended clients and signers.
7. Monitoring, alerting, incident response, upgrade, and recovery runbooks.

### Educational Objective

- Keep the build journal private during implementation and stabilization.
- After launch, turn evidence into a flagship educational experience on `sovereignengineering.io`, Nostr long-form material, architecture diagrams, a reproducible quickstart, and production guidance.
- Another community should be able to understand why Nostr fits sovereign communities, reproduce a basic deployment, and adapt identity, access, moderation, media, backups, and federation safely.
- Repository publication remains a post-launch decision; internal architecture must preserve a clean path to a public, cloneable setup.

## Constraints

- **Architecture:** Modular Pyramid-centered stack — follow Unix philosophy and keep services independently replaceable.
- **Identity:** Bring-your-own-key only — no Dialogos custody or hosted bunker service.
- **Compatibility:** Existing Nostr clients and signers first — upstream contributions preferred, custom work allowed when necessary.
- **Privacy:** No public plaintext leakage from private rooms or attachments.
- **Economics:** Value for value and under US$100/month recurring infrastructure spend — no mandatory payment.
- **Operations:** Fresh dedicated VPS with two trained operators — deployment choices must remain supportable by a small team.
- **Release:** Quality-gated rather than date-gated — public launch waits for the complete internal stability gate.
- **Moderation:** Minimal relay-wide intervention — preserve open disagreement while controlling spam, abuse, illegality, and security threats.
- **Analytics:** Aggregate operational metrics and periodic feedback only — no behavioral profiling.
- **Portability:** Members retain identities, content portability, and exit; deployment must remain reproducible.
- **Documentation:** Capture evidence from day one; publish educational material only after stable launch.
- **Brand:** Final name and domain topology remain open research decisions.
- **GitHub:** Repository name and owner must be chosen before remote creation; implementation uses contextual issues, draft PRs, and external Codex review feedback.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Use Pyramid as center of a modular stack | Demonstrate Pyramid well while keeping each service focused and replaceable | — Pending |
| Alumni and admin-invited friends may publish | Preserve trusted community growth while welcoming selected friends | — Pending |
| Only administrators invite friends | Keep admission accountable during early operation | — Pending |
| Combine chronological public feed with curated highlights | Preserve transparency while showcasing exceptional signal | — Pending |
| Ship access-controlled rooms before E2EE rooms | Deliver useful private spaces while researching protocol/client constraints | — Pending |
| Bring your own key; no hosted bunker | Preserve member key custody and reduce critical infrastructure risk | — Pending |
| Existing clients first; custom client allowed later | Avoid unnecessary client work without sacrificing product goal | — Pending |
| Broad general-purpose Blossom service | Support media, documents, archives, and technical collaboration | — Pending |
| Bidirectional community discovery with strict privacy boundary | Keep community connected to wider Nostr without leaking private events | — Pending |
| Honor signed deletions | Respect user agency while documenting backup-retention limits | — Pending |
| Minimal relay-wide moderation | Protect open discourse while controlling severe abuse | — Pending |
| Value for value; never mandatory payment | Align economics with community philosophy | — Pending |
| Quality-gated public launch | Reliability and safety matter more than arbitrary schedule | — Pending |
| Defer repository publication decision until after launch | Preserve optionality while designing for reproducibility now | — Pending |
| Research brand relationship across three territories | Working title and final relationship to Sovereign Engineering remain unresolved | — Pending |
| Defer GitHub remote creation until naming is resolved | Avoid cementing a misleading repository identity while preserving local planning progress | — Pending |
| Use issues, draft PRs, and external Codex review | Keep implementation contextual, reviewable, and defect-driven | — Pending |
| Defer Napplet/Kehto and use Pyramid relay method | Current Napplet/Kehto stack is alpha and client-side; it does not provide Pyramid membership, NIP-29 enforcement, persistence, moderation, or operations | — Pending |

## Open Research Questions

- Which Pyramid repository and release are canonical, and what is its actual supported feature/NIP matrix?
- How does Pyramid deploy, persist, authenticate, authorize, moderate, back up, upgrade, and expose administration?
- Which launch requirements are native to Pyramid, which require configuration, and which require separate services?
- What do NIP-29 public/private and open/closed group semantics guarantee in practice?
- Which target clients and signers work today, and what focused upstream or companion work is needed?
- How should inward public-event aggregation work without duplication, deletion loss, moderation bypass, or confusing provenance?
- Which Blossom server best fits general-purpose storage under the budget, and how should quotas, scanning, retention, and backups work?
- Should private attachments use client-side encryption, authenticated delivery, or both?
- What VPS size, OS, container strategy, reverse proxy, database, object storage, backup destination, and monitoring stack fit the workload and budget?
- Should services use flat subdomains, nested subdomains, paths, or protocol-aware routing?
- Which naming territory and visual system best extend Sovereign Engineering's philosophy without becoming a generic sub-brand?
- What repository name and GitHub owner best fit the final product name, architecture scope, and potential future publication?
- How should later badges, Git/NIP-34, events, V4V, directories, governance, E2EE, and custom-client work be sequenced?
- Which jurisdictional, illegal-content, data-retention, and provider-policy obligations apply before production?

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-07-30 after initialization*
