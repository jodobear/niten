# Feature Research

**Domain:** Sovereign, Pyramid-centered Nostr alumni community
**Researched:** 2026-07-30
**Confidence:** MEDIUM

## Recommendation

Do not force one client to be the whole product. Ship a composed v1:

- **Pyramid** owns membership, relay policy, public/member relays, NIP-29 groups, NIP-05, search, and signed administrative state.
- **Flotilla** is the recommended default alumni workspace: strongest current UX for rooms, threads, events, search, notifications, moderation, Blossom, and signer choices.
- **Jumble** is the public front door: relay-first chronological feeds, community relay presets, long-form rendering, discovery, search, reactions, Blossom, and public notifications.
- **Nostrord** is the focused NIP-29 compatibility client and simpler chat-first alternative.
- **Thin companion UI** owns the seams no client covers coherently: onboarding, authoritative alumni/friend labels, admin-only friend admission, service status, client/signer guidance, public “Best of,” and links into specialist clients.

This is an ecosystem feature, not an implementation compromise: Nostr identity and events are portable, while each client remains focused. Full custom-client work should start only after real weekly usage proves the composed experience inadequate.

**Confidence note:** GSD confidence classification rates verified web-search research `MEDIUM`. Core claims below were cross-checked against official NIPs, official project docs, and current source snapshots from 2026-07-29/30. Negative client claims mean “not found in current official source/docs,” not “impossible.”

## Feature Landscape

### Table Stakes — Launch Is Incomplete Without These

| Feature | Why Expected Here | Complexity | Dependencies | Current delivery path |
|---|---|---:|---|---|
| Authoritative alumni allowlist | Public may read, but only approved alumni/friends may publish. This is the community boundary. | MEDIUM | Pyramid identity, operator roster, recovery procedure | Pyramid main relay member policy; thin roster/admin UI for auditable adds/removals. |
| Admin-only friend invitations | Friends must be invited by admins, never recursively by ordinary members. | MEDIUM | Allowlist, admin role, invite policy tests | Configure non-admin invite quotas to zero; root/admin approves friend joins. Pyramid hierarchy supports quotas and join requests, but exact “alumni may not invite friends” policy needs companion validation/UI. |
| Alumni / friend / administrator distinction | Members need visible provenance and operators need real authority separation. | MEDIUM | Authoritative roster, role issuer, client rendering | Pyramid current source has root-managed role labels; Flotilla displays roles but explicitly separates labels from relay admin power. Use labels/badges for display; relay/root policy for authority. Never use a badge as ACL. |
| Portable identity and profile | Expert users expect one Nostr identity across clients, with no platform account lock-in. | LOW | NIP-01 identity, signer, profile relays | Standard Nostr key/profile; NIP-05 address from Pyramid. |
| Bring-your-own-key signing | Infrastructure must never receive member private keys. | MEDIUM | NIP-07/46/55 support, documented onboarding, compatibility matrix | nos2x/nos2x Firefox via NIP-07; Amber via NIP-55 or NIP-46; chosen iOS NIP-46 signer/deep link; member-selected bunkers. Disable or strongly discourage raw-key login in branded surfaces. |
| Public chronological member feed | Outsiders need a transparent, high-signal stream; members need a non-algorithmic common timeline. | MEDIUM | Member roster, public relay, deterministic ordering | Pyramid main relay + branded Jumble community relay set, reverse chronological by `created_at`. |
| Public notes, replies, reactions | Basic weekly conversation loop. | LOW | Public feed, signer, kinds 1/1111/7 support | Jumble already covers public notes, replies, reactions, quotes, zaps; Pyramid stores allowed kinds. Flotilla/Nostrord cover room conversation. |
| Public town-square room | Alumni need one shared live place, not only isolated personal feeds. | MEDIUM | NIP-29 relay, membership, chat client | Pyramid NIP-29 group + Flotilla default room; Nostrord compatibility. |
| Access-controlled alumni rooms | Sensitive alumni discussion needs read/write restrictions at launch. | MEDIUM | NIP-29 private/restricted/hidden/closed flags, operator trust, leak tests | Pyramid NIP-29 + Flotilla/Nostrord. Label these **operator-readable access-controlled rooms**, not E2EE. |
| Clear room privacy labeling | “Private” in NIP-29 does not mean encrypted from the relay operator. Users must understand the boundary before posting. | LOW | Room policy, client copy, onboarding | Thin companion guidance plus upstream client copy where missing. Flotilla already distinguishes E2EE DMs from operator-readable room messages. |
| Long-form publishing and reading | Builders need durable essays, design notes, and educational material beyond chat. | MEDIUM | NIP-23 kind 30023, Markdown, Blossom images, compatible reader/editor | Pyramid stores allowed kind 30023; Jumble renders NIP-23. Publishing may use Jumble or a specialist NIP-23 editor. Flotilla/Nostrord are not the primary long-form surface. |
| General-purpose Blossom files | Community needs images, videos, PDFs, archives, release artifacts, and technical files—not image-only hosting. | HIGH | BUD-01/02/11/12, auth, quotas, MIME/size policy, deletion, storage forecast, backup | Pyramid has member-only Blossom, per-member size limits, self-delete, operator management. Standalone `hzrd149/blossom-server` offers stronger retention/S3/report/admin controls if modular operations win. Verify arbitrary MIME behavior before launch. |
| Safe private attachments | A private-room attachment must never become public plaintext at a guessable/content-addressed URL. | HIGH | Client-side encryption, key distribution, encrypted metadata, deletion semantics | Launch rule: attachments in access-controlled NIP-29 rooms are disabled or limited to non-sensitive content. Flotilla already encrypts NIP-17 DM files before Blossom upload; this does **not** extend to NIP-29 rooms. |
| NIP-05 community addresses | Alumni need memorable, community-linked identity without replacing their keys. | LOW | Domain, HTTPS well-known endpoint, roster | Pyramid provides member-claimable community NIP-05. Reserve names and define removal/rename policy. |
| Search | A weekly community becomes unusable if old discussions and posts cannot be found. | MEDIUM | NIP-50 index, accepted kinds, language settings, room privacy filtering | Pyramid NIP-50; Jumble relay search; Flotilla per-space/per-room search. Search index must enforce the same read boundary as source rooms. |
| Member discovery / directory | About 100 experts must be able to find one another by name, role, cohort, and expertise. | MEDIUM | Roster, profiles, labels, privacy choices | Flotilla member directory + thin authoritative roster view. NIP-29 kind 39002 cannot be assumed complete, so do not derive the official alumni roster solely from group metadata. |
| Notifications and unread state | Weekly habit fails if mentions, replies, room activity, and admin requests disappear silently. | MEDIUM | Client notification support, push bridge/server where needed, privacy settings | Flotilla has per-room/per-space alerts and push; Nostrord has group unread/browser notifications; Jumble has social notifications. Treat cross-client read state as best-effort. |
| Signed deletion handling | Members need meaningful damage control and operators need a consistent policy. | HIGH | NIP-09, NIP-62, group admin delete, Blossom delete, backup aging | Honor valid author deletion and vanish requests in active systems; propagate to copied/aggregate stores; delete media ownership; expire backups per published schedule. Never promise global erasure. |
| Minimal moderation | Spam, abuse, illegality, and security threats require relay action; ordinary disagreement should remain user-controlled. | MEDIUM | Reports, admin actions, mute lists, incident policy | Pyramid root/group moderation; Flotilla reports, delete, ban, mute; NIP-51 user mute lists. Keep reasons and signed/admin audit evidence. |
| Onboarding / discovery / status front door | Multiple clients and signer options otherwise become confusing, even for experts. | MEDIUM | Stable URLs, roster, service health, deep links | Thin companion website: choose signer/client, claim NIP-05, join rooms, open public feed, inspect system status, learn privacy boundaries. |

### Differentiators — Why Alumni Return Weekly

| Feature | Value Proposition | Complexity | Dependencies | Current delivery path |
|---|---|---:|---|---|
| Two-track public experience: **All** + **Best of** | Preserves transparent chronology while creating a showcase outsiders intentionally follow. | MEDIUM | Public feed, editor role, curation workflow | “All” = Pyramid main relay in Jumble. “Best of” = Pyramid favorites subrelay and/or portable NIP-51 kind 30004 curation set, exposed by thin editorial page. Use manual selection, not engagement ranking. |
| Living community map | Makes the alumni network visible as people, cohorts, projects, interests, and recent work—not a flat user list. | HIGH | Directory, explicit profile fields, opt-in privacy, project/event data | Thin companion directory over signed profiles + authoritative role/cohort registry; link to Flotilla profiles/rooms and public Nostr content. |
| Alumni and friend recognition badges | Signals provenance without making identity non-portable. | MEDIUM | NIP-58 issuer, authoritative roster, image assets, revocation/expiry policy | Sovereign Engineering issuer publishes badge definitions/awards; users choose profile display. Thin UI guarantees visibility because target clients do not render badges uniformly. |
| Community-first relay discovery | Public can explore this community by relay and provenance rather than opaque global ranking. | MEDIUM | Jumble relay sets, NIP-50, source labels | Branded Jumble with fixed community relay sets; show relay/source and direct Nostr links. |
| Public-event aggregation with provenance | Alumni remain visible even when they publish elsewhere; community does not become a silo. | HIGH | Member roster, relay discovery, dedupe, source tracking, deletion watcher, moderation boundary | Start with Jumble querying configured public relays per roster/follow sets—no copying. Materialize only after load evidence; use separate aggregate subrelay/index, preserve original event IDs and relay provenance. |
| Durable knowledge beside chat | Turns good conversations into essays, library entries, pinned references, and later education. | MEDIUM | Long-form, curation, links, editorial owner | NIP-23 + Flotilla Featured/Library + “Best of” editorial page. Keep the original signed event as canonical. |
| Verifiable exit | Members can keep key, export relay/list config, read events through other clients, and leave without support intervention. | MEDIUM | Standard events, documented relay endpoints, backup/export probes | Publish compatibility matrix and exit guide; periodically verify Nostrord/Flotilla/Jumble can read same public/group events. |
| Visible build evidence after stabilization | Makes deployment a reference for other sovereign communities without exposing an unstable private build journal. | MEDIUM | Stable operations, sanitized ADRs/runbooks, long-form | Post-launch educational site + NIP-23 series + reproducible configuration. |

### Later Capabilities — Valuable, Not Launch Gates

| Feature | Why Later | Complexity | Dependencies | Likely delivery path |
|---|---|---:|---|---|
| NIP-52 calendar and RSVPs | Useful after conversation habit exists; otherwise becomes an empty calendar. | MEDIUM | Member roles, event moderation, reminders | Flotilla already exposes calendar events; enable after pilot demand. |
| Optional zaps / V4V | Aligns with philosophy, but wallet setup must not block community participation. | MEDIUM | NIP-57, LNURL/NWC-compatible wallet UX, recipient profiles | Flotilla and Jumble have zap UX; Pyramid accepts member-related zap receipts. Keep fully optional. |
| Project and expertise directories | Strong network value once roster data is accurate and members opt in. | MEDIUM | Living community map, profile schema, search | Thin directory; signed project links where practical. |
| Advisory governance | Helps shared decisions without pretending protocol polls automatically create legitimacy. | MEDIUM | Proposal template, eligible voter snapshot, result archive | Flotilla NIP-88 polls plus signed NIP-23 proposals and a published human decision record. |
| NIP-34 / GRASP collaboration | Excellent fit for expert builders, but specialist Git UX is separate from weekly town-square adoption. | HIGH | Repository announcements, Git hosting, patch/PR client, maintainer keys | Pyramid has GRASP/NIP-34 server support. Add specialist NIP-34 tooling and links from project directory; do not rebuild GitHub in chat. |
| Live audio/video | High-value for demos and office hours, but adds LiveKit operation and moderation. | HIGH | NIP-29 LiveKit endpoint, TURN/networking, consent, capacity tests | Pyramid supports integrated LiveKit; Flotilla supports voice/video rooms. |
| E2EE group rooms | Correct end state for sensitive rooms, but target clients do not provide an audited interoperable path today. | VERY HIGH | Marmot/MLS maturity, audited clients, key rotation, multi-device, encrypted media, recovery | Separate pilot with Marmot-compatible clients. Do not imply NIP-29 ACL rooms will “upgrade” automatically. |
| Private attachment workflow | Must follow, not precede, audited E2EE group transport and compatible encrypted media. | VERY HIGH | E2EE rooms, client-side encryption, metadata protection, deletion | Marmot encrypted-media path or another audited design; Flotilla NIP-17 encrypted attachments cover DMs only. |
| Rich cross-relay aggregation cache | Direct multi-relay reads should prove inadequate before introducing a copied-content lifecycle. | HIGH | Aggregation query MVP, provenance, dedupe, deletion, moderation | Dedicated indexer/aggregate relay, never the private room relay. |
| Advanced notification digest | Weekly digest may aid retention, but email/push centralization and privacy need deliberate limits. | MEDIUM | Notification signals, opt-in, minimal metadata | Client-side or privacy-minimized server digest after notification telemetry shows need. |
| Full custom client | Only justified if composed clients fail measured weekly workflows. | VERY HIGH | Stable protocol contracts, usage data, UX spec, maintenance budget | Future client consuming same Pyramid/Blossom/NIP interfaces; no new private protocol unless unavoidable. |

### Anti-Features — Explicitly Do Not Build

| Anti-Feature | Why It Is Tempting | Why It Is Wrong Here | Better Alternative |
|---|---|---|---|
| Full custom client in v1 | One coherent brand and navigation. | Delays infrastructure validation, signer interoperability, and actual conversations; creates permanent client maintenance. | Compose Flotilla + Jumble + Nostrord with a thin companion shell. |
| Calling NIP-29 private rooms “encrypted” | Familiar promise users understand. | Relay/operator can read room state; false privacy claim creates real harm. | Say “access-controlled, operator-readable”; ship audited E2EE separately. |
| Plaintext private-room Blossom uploads | Upload UX already exists. | Blossom retrieval is public by content hash unless extra design exists; URL secrecy is not access control. | Disable sensitive room attachments; use encrypted NIP-17 DM files or later audited group encrypted media. |
| Server custody of member nsecs | Smooth signup and recovery. | Violates core value and concentrates identity compromise. | NIP-07, NIP-55, NIP-46, encrypted user-controlled backups. |
| Raw-key paste as recommended login | Broad compatibility. | Trains unsafe behavior and expands client compromise blast radius. | Keep only as explicitly warned emergency path, if present at all. |
| Badge-driven authorization | Badge looks like a role credential. | NIP-58 awards are display/recognition events; users choose display; revocation and client rendering are not ACL semantics. | Relay policy is authority; badge mirrors status for humans. |
| Mandatory payments or paid rooms | Pyramid and Nostr support payment features. | Breaks V4V principle and turns belonging into entitlement. | Optional zaps, funding goals, transparent voluntary support. |
| Engagement-ranked default feed | Appears to solve discovery and retention. | Recreates attention-economy incentives the project rejects; hides editorial responsibility. | Chronological “All,” manual “Best of,” explicit user-selected lists. |
| Automatic AI moderation or reputation scoring | Scales moderation cheaply. | Opaque enforcement conflicts with minimal moderation and inspectable state; false positives damage a 100-person trust network. | Human admin actions for severe cases; member mutes/blocks for disagreement. |
| Global deletion guarantee | Familiar web-app promise. | NIP-09 is a request and copied events may survive elsewhere. | Strong local deletion SLA plus honest limits and backup aging. |
| Silent copying of outside posts | Makes aggregation fast and durable. | Loses provenance, complicates deletion, and can bypass source moderation. | Query sources directly first; label and lifecycle-manage any later cache. |
| Any private-to-public relay bridge | Convenient unified search/feed. | One routing mistake irreversibly leaks sensitive events. | Separate relay configs, explicit allowed-kind/source rules, negative leak tests. |
| Behavioral profiling / ad analytics | Easy retention dashboards. | Conflicts with sovereignty and creates data risk disproportionate to 100 users. | Aggregate uptime, counts, latency, storage, and periodic human feedback. |
| Pyramid-as-everything monolith | Many features are already bundled. | Couples community availability to every experimental service and weakens replaceability. | Enable only proven Pyramid functions; keep companion UI, backups, education, and optional services separable. |

## Client and Tool Fit

### Current Client UX Matrix

| Capability | Flotilla | Nostrord | Jumble | Product implication |
|---|---|---|---|---|
| Core posture | Broad Discord-like community client | Focused NIP-29 group chat | Relay-feed/public-social explorer | Use all three for their strengths. |
| NIP-29 rooms | Strong: room policies, members, invites, admin/report UI | Strong: groups, invite codes, join review, roles/moderation | No NIP-29 implementation found in current source | Default workspace = Flotilla; compatibility fallback = Nostrord. |
| Public chronological member feed | Recent Activity is space-scoped, not the desired public member timeline | Explicitly “built for communities, not timelines” | Strong relay/community preset feed | Public front door = Jumble. |
| Manual curation | Featured content + Library, Flotilla-specific relay app data | Pins/group focus | Can browse a curated relay set; no authoritative editorial workflow | Pyramid favorites + thin “Best of”; optionally mirror portable NIP-51 curation set. |
| Threads / events / polls / directory | Strong current UX | Chat-focused | Public-social features vary; not community-admin surface | Enable later in Flotilla. |
| NIP-23 long-form | Not primary surface | Not primary surface | Current source renders/previews long-form | Jumble/specialist editor for essays. |
| Search | Space/room content search; relay-dependent | No documented broad discovery/search surface | NIP-50 note/profile/relay search | Pyramid NIP-50 + both Flotilla/Jumble query paths. |
| Blossom | Authenticated upload; current source supports optional encryption for DM files | Media upload documented; general-file behavior needs matrix test | Current source supports Blossom upload/server lists and media resolution | General file acceptance must be tested per MIME and client. |
| Private messaging | NIP-17 E2EE one-to-one/small-group DMs; encrypted attachments | NIP-44 encrypted DM support documented, group rooms remain ACL | Current source includes NIP-17-style DM service | Do not equate DMs with E2EE community rooms. |
| Notifications | Per-room/space types, push, mute controls | Group unread, browser notifications, native work | Social notifications/read sync | Pilot each platform; avoid assuming read-state portability. |
| NIP-07 browser signer | Yes | Yes on web | Yes | nos2x path available. |
| NIP-55 / Amber | Yes on Android | Present in current Android source | No native NIP-55 path found | Android default = Flotilla/Amber; Nostrord requires matrix test. |
| NIP-46 bunker / QR | Yes; bunker, QR, iOS signer deep link | Yes; QR/URL; iOS client still marked in development | Yes; bunker and `nostrconnect://` QR | Test every selected signer/client/relay triple before recommendation. |
| Native platforms | Web/PWA, Android, iOS; no separate desktop app | Web, Android, desktop; iOS still marked in development | Web + Electron desktop | Publish device-specific recommendations, not one universal client. |

### Infrastructure / Protocol Delivery Map

| Need | Deliver Now | Gap / Required Work |
|---|---|---|
| Member-only publishing, public read | Pyramid main relay | Admission policy and role mapping need explicit configuration/tests. |
| Alumni-private shared state | Pyramid internal relay and/or NIP-29 private groups | Private relay is operator-readable; isolate from public relay lists. |
| Public and access-controlled rooms | Pyramid groups + Flotilla/Nostrord | Verify public/private/restricted/hidden/closed combinations across clients. |
| Chronological public feed | Jumble community mode over Pyramid main | Branded config and clear member roster scope. |
| Best of | Pyramid favorites subrelay/pins + thin page | Portable NIP-51 kind 30004 publication and editor workflow are companion work. |
| Search | Pyramid NIP-50 + Jumble + Flotilla | Privacy boundary and language/index tuning. |
| NIP-05 | Pyramid | Namespace, rename, departure policy. |
| General Blossom | Pyramid built-in or standalone `hzrd149/blossom-server` | MIME matrix, quotas, abuse handling, backups; neither makes private plaintext safe. |
| Long-form | NIP-23 on Pyramid + Jumble/specialist editor | Unified navigation and editorial promotion. |
| Notifications | Client-native; Flotilla push bridge/server | Minimal-metadata operating policy and end-to-end pilot. |
| Deletion | NIP-09/NIP-62 + Pyramid/group/Blossom admin APIs | Cross-relay cache ledger and backup aging need companion operations. |
| Events / polls / directory / zaps | Flotilla now | Enable only after core usage; document signer/wallet requirements. |
| Git / NIP-34 | Pyramid GRASP service | Specialist client/tooling, project directory integration, operational review. |
| E2EE groups | Marmot ecosystem is the current direction | Target clients here do not offer a validated common path; needs phase research, audit review, interop pilot. |

## Feature Dependencies

```text
[Authoritative roster]
    ├──> [member-only publishing]
    ├──> [alumni/friend/admin labels]
    │        └──> [badges + directory]
    ├──> [admin-only friend invites]
    └──> [public-member aggregation scope]

[BYOK signer matrix] ──> [onboarding] ──> [publishing + admin actions + Blossom auth]

[Pyramid public relay] ──> [chronological All feed]
                        └──> [manual selection] ──> [Best of]

[NIP-29 ACL groups] ──> [access-controlled rooms]
                     X──> [E2EE claim]

[Marmot/MLS audit + client interop]
    └──> [E2EE rooms] ──> [private group attachments]

[Blossom auth + quotas + deletion + backup]
    └──> [general files]
    └──> [encrypted bytes + protected key distribution] ──> [private attachments]

[direct public multi-relay reads]
    └──> [measured need] ──> [materialized aggregation cache]
                              ├──> [provenance/dedupe]
                              └──> [deletion + moderation propagation]

[conversation habit] ──> [events / zaps / governance / NIP-34]
```

### Dependency Notes

- **Roster before roles/badges/directory:** NIP-29 membership lists are optional and may be partial. Keep one authoritative admission record; derive display artifacts from it.
- **Authority separate from recognition:** Pyramid root/relay policy grants power. NIP-58 badges and Flotilla-style role labels communicate status only.
- **Signer matrix before onboarding:** A protocol checkbox does not prove a specific client, signer version, QR flow, and relay set interoperate.
- **ACL before rooms, but not E2EE:** NIP-29 controls relay delivery. E2EE requires a different cryptographic system and compatible clients.
- **Encryption key delivery before private files:** Encrypting bytes is insufficient if decryption metadata appears in a public room event.
- **Direct queries before copied aggregation:** Avoid creating deletion/provenance obligations until latency/load proves fan-out inadequate.
- **Core habit before extensions:** Empty calendars, governance polls, and Git surfaces do not create a town square. Conversation quality comes first.

## MVP Definition

### Launch With — Internal Alumni Pilot

- [ ] Pyramid member roster: alumni/friend/admin labels, non-admin invite quota disabled, admin admission audit.
- [ ] Public Pyramid main relay readable in branded Jumble community mode.
- [ ] Manual “Best of” workflow using Pyramid favorites and a thin public page.
- [ ] One public NIP-29 town square and a small number of purpose-named alumni ACL rooms in Flotilla; Nostrord compatibility verified.
- [ ] Public notes, replies, reactions, and NIP-23 long-form reading/publishing route.
- [ ] General-purpose Blossom with auth, quota, MIME/size matrix, member delete, operator abuse flow, forecast, and restore test.
- [ ] Private-room attachment guardrail: no sensitive plaintext; encrypted NIP-17 attachments limited to DMs.
- [ ] NIP-05 names and minimal member directory.
- [ ] NIP-50 search with private-boundary tests.
- [ ] Device-specific signer recommendations covering nos2x/nos2x Firefox, Amber, chosen iOS NIP-46 signer, and member bunkers.
- [ ] Notes/group/media deletion workflow plus backup-retention statement.
- [ ] Notifications, muting, onboarding, status, privacy labels, and exit guide.

### Add After Pilot Validation — v1.x

- [ ] NIP-58 alumni/friend badges once roster reconciliation is reliable.
- [ ] Rich directory with cohorts, projects, and expertise, all member-controlled.
- [ ] NIP-52 events/RSVP and optional LiveKit demo rooms when recurring events exist.
- [ ] Optional zaps/V4V after wallet/signing UX passes pilot.
- [ ] Advisory proposals and NIP-88 polls after a real shared decision needs them.
- [ ] Public cross-relay aggregation through direct queries; materialize only if measured performance demands it.
- [ ] NIP-34 project discovery and GRASP pilot for a few willing repositories.

### Future Consideration — v2+

- [ ] Marmot-based E2EE room pilot after protocol/client audit and interop review.
- [ ] E2EE group attachments after encrypted group messaging is stable.
- [ ] Full custom client only when tracked workflow failures justify permanent product code.
- [ ] Reusable educational release and cloneable deployment after stability gates and publication decision.

## Prioritization Matrix

| Feature cluster | User Value | Cost | Priority |
|---|---:|---:|---:|
| Roster, admission, roles, invites | HIGH | MEDIUM | P1 |
| Public chronological feed | HIGH | MEDIUM | P1 |
| Public + ACL NIP-29 rooms | HIGH | MEDIUM | P1 |
| Notes/replies/reactions/long-form | HIGH | MEDIUM | P1 |
| Signer compatibility | HIGH | HIGH | P1 |
| General Blossom + safe attachment policy | HIGH | HIGH | P1 |
| NIP-05, search, directory | HIGH | MEDIUM | P1 |
| Deletion/moderation/notifications | HIGH | HIGH | P1 |
| Manual Best of | HIGH | MEDIUM | P1 |
| Badges / living network map | MEDIUM | MEDIUM/HIGH | P2 |
| Events / V4V / governance | MEDIUM | MEDIUM | P2 |
| Public outside-event aggregation | MEDIUM/HIGH | HIGH | P2 |
| NIP-34 / GRASP | MEDIUM | HIGH | P2 |
| E2EE rooms and private group media | HIGH | VERY HIGH | P3 research gate |
| Full custom client | UNKNOWN | VERY HIGH | P3 evidence gate |

## Brand / Product Territory

**Recommendation: endorsed sub-brand.** It preserves Sovereign Engineering trust while letting this become a living place rather than an institutional feature page. Official language already gives a strong maritime vocabulary: ship, shipyard, captains, Madeira, exploration, weekly shipping, dialogue.

| Territory | Example direction, not cleared name | Strength | Risk | Fit |
|---|---|---|---|---|
| Direct extension | **Sovereign Engineering Network**, **Sovereign Commons**, **SEC Network** | Immediate trust and discoverability | Institutional, generic, or confused with the program itself; “SEC” has unrelated meanings | Good launch descriptor, weaker lasting place-name |
| Endorsed sub-brand | **Shipyard Commons — by Sovereign Engineering**, **The Yard — by Sovereign Engineering**, or another maritime/living-network name | Feels inhabited; connects cohorts, shipping, exploration, and shared construction; can grow beyond chat | Needs naming, domain, NIP-05, and trademark clearance | **Best territory** |
| Independent identity | **Dialogos**, **Tidemark**, **Common Signal**, with “from Sovereign Engineering” endorsement | Maximum portability and future community autonomy | Weakest immediate recognition; `Dialogos`/agora vocabulary can feel academic or static | Keep as fallback if community wants independence |

Naming hierarchy should be: **living sovereign network first → maritime/shipyard place second → ancient agora as a subtle layer → hacker culture as texture, never an exclusion signal.** Avoid leading with “Agora,” “Guild,” or “Elite Hacker” language; these make the place feel historical, closed, or status-driven. Perform actual availability/legal checks before selecting any candidate.

## Roadmap Implications

1. **Identity and admission first:** authoritative roster, roles, admin-only invites, NIP-05, signer compatibility.
2. **Conversation surfaces second:** public relay/Jumble feed, NIP-29 rooms in Flotilla, Nostrord compatibility, notes/replies/reactions/long-form.
3. **Files and trust guarantees third:** Blossom, private-attachment guardrails, deletion, moderation, backups, notifications.
4. **Editorial/network layer fourth:** Best of, directory, badges, external public-event aggregation.
5. **Community extensions fifth:** events, V4V, governance, NIP-34, voice/video.
6. **Cryptographic/private expansion last:** Marmot E2EE pilot, encrypted group media, then custom client only if justified.

## Research Flags for Later Phases

- **Pyramid role/admission phase:** verify current role event/API semantics, number of root admins, invite quota behavior, and whether roles remain purely descriptive.
- **Client compatibility phase:** executable matrix across Pyramid + Flotilla/Nostrord/Jumble + nos2x variants/Amber/iOS signer/bunkers. Include create/join/post/reply/react/delete/upload/search/private-read-denial.
- **Blossom phase:** general MIME matrix, quota accounting, owner semantics, authenticated delete, reports, backup restore, and client-side encryption metadata placement.
- **Aggregation phase:** source discovery, relay fan-out bounds, dedupe, provenance UI, delete/vanish watchers, moderation inheritance, and private-event negative tests.
- **E2EE phase:** Marmot version, security review findings, interoperable clients, MLS state recovery, multi-device, member removal, metadata, encrypted attachments, and backup behavior.
- **Brand phase:** member naming workshop plus domain, NIP-05 namespace, GitHub org/repo, social handle, and trademark checks.

## Sources

All confidence levels below are `MEDIUM` under the configured GSD classifier because the research provider was verified web search; current repositories were also cloned/read directly for cross-checking.

### Protocols

- [Nostr NIPs index](https://github.com/nostr-protocol/nips) — official protocol index; `MEDIUM`.
- [NIP-29: Relay-based Groups](https://github.com/nostr-protocol/nips/blob/master/29.md) — groups, invites, roles, private/restricted/hidden/closed, moderation, incomplete member lists; `MEDIUM`.
- [NIP-23: Long-form Content](https://github.com/nostr-protocol/nips/blob/master/23.md) — addressable Markdown articles; `MEDIUM`.
- [NIP-51: Lists](https://github.com/nostr-protocol/nips/blob/master/51.md) — curation sets, relay sets, mute lists, group lists, calendars, Git lists; `MEDIUM`.
- [NIP-58: Badges](https://github.com/nostr-protocol/nips/blob/master/58.md) — definition, award, opt-in display, sets; `MEDIUM`.
- [NIP-50: Search](https://github.com/nostr-protocol/nips/blob/master/50.md) — relay search filter and caveats; `MEDIUM`.
- [NIP-09: Event Deletion Request](https://github.com/nostr-protocol/nips/blob/master/09.md) and [NIP-62: Request to Vanish](https://github.com/nostr-protocol/nips/blob/master/62.md) — deletion semantics and limits; `MEDIUM`.
- [NIP-52: Calendar Events](https://github.com/nostr-protocol/nips/blob/master/52.md), [NIP-57: Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md), [NIP-34: Git](https://github.com/nostr-protocol/nips/blob/master/34.md) — later feature primitives; `MEDIUM`.
- [NIP-07: Browser signer](https://github.com/nostr-protocol/nips/blob/master/07.md), [NIP-46: Nostr Connect](https://github.com/nostr-protocol/nips/blob/master/46.md), [NIP-55: Android signer](https://github.com/nostr-protocol/nips/blob/master/55.md) — signing paths; `MEDIUM`.
- [Blossom protocol](https://github.com/hzrd149/blossom) — public content-addressed blobs and authenticated management; `MEDIUM`.
- [Marmot protocol](https://github.com/parres-hq/marmot) and [marmot-ts](https://marmot-protocol.github.io/marmot-ts/) — current E2EE group direction; `MEDIUM`.

### Current projects and clients

- [Pyramid repository](https://github.com/fiatjaf/pyramid) — current source snapshot `e12e81641bfe6cacc6dd246e9433d602c1240e66` (2026-07-29); membership hierarchy, roles, subrelays, NIP-29, NIP-50, NIP-05, Blossom, negentropy, GRASP; `MEDIUM`.
- [Flotilla repository](https://gitea.coracle.social/coracle/flotilla) — current source snapshot `d02e0ed56a50fe16fa8208b9c96c5568f6b8655f` (2026-07-29); `MEDIUM`.
- [Flotilla knowledge base](https://flotilla.social/articles/) — current maintainer docs for spaces, rooms, events, search, notifications, privacy, deletion, signers, Blossom; `MEDIUM`.
- [Nostrord site](https://nostrord.com/) and [repository](https://github.com/nostrord/nostrord) — current source snapshot `d0f031685dcec3cc0119b152c56a59fe5f52f1f1` (2026-07-30); NIP-29/chat and signer capabilities; `MEDIUM`.
- [Jumble repository](https://github.com/CodyTseng/jumble) — current source snapshot `f828c8fae394ed24a3015cc377b2bbf1b89fd92b` (2026-07-29); relay/community feeds, NIP-23, search, Blossom, notifications, NIP-07/46; `MEDIUM`.
- [Blossom Server](https://github.com/hzrd149/blossom-server) — authenticated upload/delete, retention rules, reports, local/S3, admin controls; `MEDIUM`.
- [Amber official site](https://greenart7c3.com/) and [Amber source](https://github.com/greenart7c3/Amber) — NIP-46/NIP-55 Android signer path; `MEDIUM`.
- [Nostrum](https://github.com/nostr-connect/nostrum) and [Aegis](https://github.com/ZharlieW/Aegis) — iOS-capable NIP-46 signer candidates requiring project-specific interop testing; `MEDIUM`.

### Product philosophy

- [Sovereign Engineering](https://sovereignengineering.io/) — open/self-sovereign systems, attention-economy rejection, shipping, weekly loop, rotating captains, maritime identity, alumni community; `MEDIUM`.

---
*Feature research for: Pyramid-centered Sovereign Engineering alumni network*
*Researched: 2026-07-30*
