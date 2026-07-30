# UI Candidate Research: Sovereign Engineering Pyramid

**Researched:** 2026-07-30  
**Mode:** ecosystem/comparison supplement  
**Scope:** open-source clients that can be self-hosted, branded, adopted, or integrated without displacing Pyramid as the sole membership, policy, group, moderation, event, and search authority  
**Overall confidence:** MEDIUM — current official repositories, documentation, release metadata, and exact source commits were cross-checked; no candidate was built against Pyramid or run through the signer/privacy matrix in this research pass

## Decision

No current client safely delivers the whole required experience unchanged.

- **Closest single base: Flotilla.** It is the only mature, actively maintained candidate that combines white-label deployment, deep NIP-29 group administration, NIP-50 search, Blossom uploads, notifications, and NIP-07/46/55 signers. Extend it only after compatibility tests. It still needs Pyramid-specific public `All`, manual `Best of`, NIP-23 authoring, NIP-58 badges, authoritative directory labels, NIP-05 provisioning, and general-file validation.
- **Best composition now: a thin Pyramid portal + branded Flotilla + branded Jumble.** Flotilla owns authenticated rooms and administration; Jumble owns the public chronological member feed and article reading; the portal owns onboarding, global navigation, authoritative directory/badges, status, and explicit client/signer guidance. Keep Nostrord as a separately deployed compatibility oracle, not the primary brand surface.
- **Best future consolidation path: upstream or fork Flotilla.** Its Svelte/Welshman boundaries are the nearest foundation for adding the missing public, article, and badge surfaces. Do not start a ground-up client until pilot telemetry and executable failures prove the composed route inadequate.

“Unified” should mean one information architecture, one visual system, stable deep links, and clear authority—not one unreviewable monolith. Do not iframe clients: signer access, storage, navigation, accessibility, and origin boundaries become harder to reason about. Use branded subdomains or reverse-proxy paths with a persistent cross-client header and explicit handoffs.

## Non-negotiable authority boundary

```text
Portal / Flotilla / Jumble / reference clients
              │ reads, signs, publishes, renders
              ▼
          Pyramid relay ─── authoritative membership, ACLs, moderation,
              │              events, NIP-50 search, relay policy
              └──────────► Blossom server ─── authoritative file bytes
```

The UI may project membership and badges, but it must not invent or persist a second ACL, moderation state, search index, relay database, or member registry. Client-side “private” group visibility is not confidentiality: unless content is separately encrypted, the relay operator and anyone who can receive the event can read it.

## Current source pins

These pins are observation points, not automatic dependency recommendations. Re-run license, build, and security checks before adoption.

None of the six requested candidates was archived or inactive at inspection. Rejection here is about fit, missing capability, maturity, or safety—not a stale repository label.

| Candidate | Exact source observed | Release/maturity signal | License | Current activity | Adoptability |
|---|---|---|---|---|---|
| **Flotilla** | [`d02e0ed56a50fe16fa8208b9c96c5568f6b8655f`](https://gitea.coracle.social/coracle/flotilla/commit/d02e0ed56a50fe16fa8208b9c96c5568f6b8655f) | package/tag 1.9.0; production Docker and static-build instructions | MIT | commit 2026-07-29; repository updated 2026-07-30 | **Adopt as primary workspace base** |
| **Nostrord** | [`d0f031685dcec3cc0119b152c56a59fe5f52f1f1`](https://github.com/nostrord/nostrord/tree/d0f031685dcec3cc0119b152c56a59fe5f52f1f1) | [v2.4.0](https://github.com/nostrord/nostrord/releases/tag/v2.4.0), 2026-07-24; KMP native/web surfaces | Unlicense | commit 2026-07-30 | **Reference and fallback client** |
| **Jumble** | [`f828c8fae394ed24a3015cc377b2bbf1b89fd92b`](https://github.com/CodyTseng/jumble/tree/f828c8fae394ed24a3015cc377b2bbf1b89fd92b) | [v26.7.2](https://github.com/CodyTseng/jumble/releases/tag/v26.7.2), 2026-07-29; PWA/Electron/Docker | MIT | commit 2026-07-29 | **Adopt as public front door** |
| **Coracle** | [`85868b9b52187dfa700c303a244be5c3827f723c`](https://github.com/coracle-social/coracle/tree/85868b9b52187dfa700c303a244be5c3827f723c) | [0.6.35](https://github.com/coracle-social/coracle/releases/tag/0.6.35), 2026-06-16; PWA/Docker/Android | MIT | commit 2026-07-27 | Alternative public client; not NIP-29 base |
| **noStrudel** | [`1261b4f0de6fc9fd059edc2271347a2b91401a97`](https://github.com/hzrd149/nostrudel/tree/1261b4f0de6fc9fd059edc2271347a2b91401a97) | package/tag 1.1.0; README calls it in-development and buggy | MIT | source commit 2026-07-01; repository pushed 2026-07-29 | Protocol/reference tool only |
| **Snort** | [`3cc8317af0b95ca227d8c91b014eea414e0ac26f`](https://github.com/v0l/snort/tree/3cc8317af0b95ca227d8c91b014eea414e0ac26f) | [v0.5.3](https://github.com/v0l/snort/releases/tag/v0.5.3), 2026-04-08; mature monorepo/PWA | MIT | commit 2026-07-29 | Library/white-label reference; not NIP-29 base |
| **Obelisk** | [`e76afb2fa7a5eb69cde656d58eb11768f9f82ff4`](https://github.com/obelisk-app/obelisk/tree/e76afb2fa7a5eb69cde656d58eb11768f9f82ff4) | `0.1.0`; “the-comeback” release 2026-07-28; 25 stars/0 forks | **None detected** by GitHub API; README badge points to an absent file | commit 2026-07-30 | **Watch only; cannot adopt without license** |
| **The Wired** | [`364112ef924ceeef43a1f13cf66ee3cb4738129d`](https://github.com/ishtarservices/TheWired/tree/364112ef924ceeef43a1f13cf66ee3cb4738129d) | [v0.6.5](https://github.com/ishtarservices/TheWired/releases/tag/v0.6.5), 2026-07-28; 9 stars/1 fork | MIT | commit 2026-07-28 | **Exclude from this architecture** |

## Capability matrix

Legend: **Yes** = source-backed current capability; **Partial** = useful but not the required end-to-end job; **No** = absent from current documented/source surface; **Gap** = plausible but requires executable confirmation. “Groups” means actionable NIP-29 groups, not generic chats or NIP-72/NIP-87 communities.

### Community and content

| Candidate | Public chronological feed | NIP-29 groups | Admin/moderation | NIP-23 | Blossom/files | NIP-05 | NIP-50 | Notifications | Directory | NIP-58 badges |
|---|---|---|---|---|---|---|---|---|---|---|
| **Flotilla** | Partial: space/room activity, not verified roster-wide `All` | **Yes** | **Yes:** create/join/invite/approve/roles/ban and custom-role methods | No first-class surface found | Yes for uploads; general MIME/delete/Pyramid server are Gaps | Identity display; provisioning No | **Yes** for rooms/spaces | **Yes**, including push/badges | **Yes**, space members/roles | No NIP-58 found; in-app “badges” are unrelated |
| **Nostrord** | No: official positioning is communities, not timelines | **Yes** | **Yes:** strong group/member/role/mod flows | Partial: native article card; web link/display, not publication | Partial: current uploader targets nostr.build; general Blossom not proven | Partial: profile identity display | Gap: search exists, exact NIP-50 path not proven | Partial: in-app/native; iOS reliability incomplete | Group members/roles | No NIP-58 found |
| **Jumble** | **Yes:** relay-first chronological feeds/community mode; exact roster filtering is a Gap | Partial: renders group metadata preview only | No | **Yes read/render**; no authoring route found | **Yes:** signed, configurable Blossom media uploads; general files/delete Gap | **Yes**, display/verify | **Yes**, relay capability-aware | **Yes** | No authoritative community directory | No NIP-58 found |
| **Coracle** | **Yes:** rich public/custom feeds; exact roster scope is a Gap | **No NIP-29**; NIP-72 and NIP-87 instead | No NIP-29 admin | **Yes read/render**; no dedicated authoring route found | Source has Blossom; README/config retains NIP-96 defaults, so deploy matrix needed | **Yes**, display/verify | **Yes** | **Yes** | Social profiles/lists, not Pyramid directory | **Yes**, render/inspect |
| **noStrudel** | **Yes**, broad social/protocol views | Partial: explore/read/post to exact group relay | No NIP-29 admin/join/mod UI found | **Yes read/render**; no authoring route found | **Yes**, strong multi-server upload/inspect tools | **Yes**, display/verify | **Yes** | **Yes** | No authoritative community directory | **Yes**, rich badge views |
| **Snort** | **Yes**, mature social feed | No current actionable NIP-29 surface found | No | **Yes** per current protocol checklist | **Yes:** changelog says Blossom replaced NIP-96 | **Yes** | **Yes** | **Yes** | Social profiles/lists | **Yes** |
| **Obelisk** | No general public social timeline | **Yes** | **Yes**, young implementation | No NIP-23 found | Partial: Blossom image uploads, not general files | Profile identity Gap | **Yes** | Partial and documented unreliable | Group member list/roles | No NIP-58 found |
| **The Wired** | Yes, but backed by its own feed/search stack | **Yes**, through bundled relay/backend | **Yes**, through bundled RBAC/backend | **Yes** | **Yes**, bundled service | **Yes** | Yes, bundled Meilisearch path | **Yes**, bundled push/backend | **Yes**, backend-owned | Gap |

None supplies Pyramid's moderator-curated `Best of` contract. Implement it as a verified projection from authoritative Pyramid events—prefer the chosen NIP-51 representation after relay-level testing—not as a client-local bookmark list.

### Delivery, signers, safety, and extensibility

| Candidate | Build/deployment | Branding/fork | NIP-07 | NIP-46 | NIP-55 | Mobile/PWA/desktop | Relay configuration | Private-group safety | Extension seam |
|---|---|---|---|---|---|---|---|---|---|
| **Flotilla** | pnpm; Node 24 non-root Docker server; static build also documented | **Strong env-based white label**: name, URL, logo, accent, description, terms/privacy, platform relays, defaults | Yes | Yes | Yes | PWA + Capacitor Android/iOS source | Strong: platform/default/search/signer/message/Blossom/blocked relay controls | NIP-29 ACL UX strong, but no confidentiality; exact relay routing must be trap-tested | Svelte + Welshman packages; no stable plugin API |
| **Nostrord** | Gradle Android; JVM desktop/deb; Kotlin/Wasm web; Xcode iOS | Hard-coded assets/names; broad fork work; web production packaging Gap | Yes, web | Yes | Yes, Android/Amber | Android + desktop + web; iOS marked in development | Strong group relay selection; broader defaults vary by platform | Exact group-relay semantics are core; current head fixed cross-relay same-ID admin leakage | Shared KMP core/UI; React/DOM web migration; no plugin API |
| **Jumble** | npm/Vite; static Nginx Docker; Compose; Electron | Community relay env is strong; visual brand requires asset/code fork | Yes | Yes | No | PWA + Electron; no native mobile | Strong community/default/search/media relay lists | Not a private-group client; public feed must not query private authors/content broadly | React providers/services; no plugin API |
| **Coracle** | pnpm/Vite; static Nginx Docker; PWA + Android build | **Strong env-based white label** and feature flags | Yes | Yes | Yes in current source | PWA + Android; no documented iOS deliverable | Strong defaults/search/onboarding/NIP-96/feature config | Not suitable for NIP-29 privacy; avoid mapping NIP-87/NIP-72 semantics onto Pyramid | Svelte + Welshman packages; reusable architecture, no plugin API |
| **noStrudel** | pnpm/Vite; GHCR Docker/Compose; PWA; Capacitor source | No supported white-label config found; fork assets/code | Yes | Yes | Yes via Android/Amber account path | PWA + Android source/iOS dependencies | Very strong expert relay controls | Group publishing targets the group's relay; no admin/private UX and needs trap test | Modular Applesauce packages; no stable app plugin API |
| **Snort** | Bun monorepo; static/PWA; Docker | **Strong JSON app configs**, multiple branded examples | Yes | Yes | Yes | PWA/web; no current native mobile or desktop artifact found | Strong, but branded configs include external services | No current NIP-29 private-group workflow | Reusable `@snort/*` packages; no app plugin API |
| **Obelisk** | Next.js app, **not a verified static export**; build ignores TypeScript errors | NIP-78 brand settings; source/asset fork otherwise | Yes | Yes | No | PWA/responsive web | Group/relay selection | **Fails present bar:** known bug exposes hidden-channel membership via mention autocomplete; voice presence/signaling plaintext | Bridge/state-store boundary, young and unstable |
| **The Wired** | Tauri desktop plus Rust relay/backend, PostgreSQL, Redis, Meilisearch, LiveKit, gateway | Forkable but broad stack branding | Yes | Yes | Claimed/source Gap | Desktop current; mobile/plugin system roadmap | Coupled to bundled relay/gateway | Adds a second authority/data plane; private safety then spans many extra services | Planned plugins, not current stable extension surface |

## Candidate findings

### 1. Flotilla — adopt as the community workspace base

**Why it leads:** Flotilla's current platform mode can lock the first relay as home and inject platform identity, terms, defaults, signer relays, messaging relays, and Blossom servers. Its source contains group access, member, role, invite, ban, join, and NIP-86 custom-role flows, plus directory, room/space search, uploads, push, and all three signer families. It aligns with Pyramid instead of importing another server authority.

**Deployment/brand facts:** `pnpm install`, `pnpm run build`, and `pnpm run start` are documented. The repository provides Docker and static-copy paths. Its Dockerfile builds and runs as a non-root Node 24 user. Branding is configuration-driven rather than a hard fork for name/logo/color/basic policy. A Pyramid deployment must remove the upstream `plausible.coracle.social` analytics script called out in the README and audit any optional email, hosting, zap, marketplace, or third-party surfaces before exposing them.

**Required fork/upstream work:**

1. Add exact roster-scoped chronological `All` and moderator `Best of` views.
2. Add NIP-23 read/author flows and NIP-58 badge rendering, or deep-link those jobs to a companion client initially.
3. Label role/directory data as Pyramid-derived and prevent client-local state from masquerading as policy.
4. Add the project-specific NIP-05 claim/manage flow and general Blossom file browser/delete UI.
5. Apply shared Pyramid tokens/navigation and hide unrelated product surfaces.

**Executable evidence gaps:** build both server and static variants from the pin; test Pyramid group creation, joins, approvals, bans, roles, deletes, and custom NIP-86 calls; prove every private-room subscription/publish targets only intended relays; exercise NIP-07/46/55 on desktop and Android; upload/download/delete each required MIME type; prove push infrastructure can be self-hosted or safely omitted.

**Confidence:** MEDIUM-HIGH on source-visible capability; MEDIUM on Pyramid interoperability.

### 2. Jumble — adopt as the public front door

**Why it fits:** Jumble is an active, straightforward React/Vite social client with relay-first chronological feeds, community-mode relay presets, article rendering, relay-aware NIP-50 search, notifications, configurable signed Blossom upload, NIP-05 presentation, NIP-07/46, PWA delivery, Electron desktop, and a small static Nginx container. It is easier to constrain to “public posts, replies, reactions, articles, search” than broader social clients.

**Brand/fork facts:** relay community mode is environment-configurable; full Pyramid branding requires changing assets/source. The README lists maintained forks, supporting practical forkability. The optional Compose proxy image uses a mutable `latest` tag; pin by digest or omit it. Build and serve static assets locally rather than depending on upstream infrastructure.

**Limits:** Jumble is not a NIP-29 workspace. It does not provide group membership/admin/moderation, an authoritative directory, NIP-58 badges, NIP-55, NIP-05 provisioning, or article authoring. A relay-only feed is not automatically “current Pyramid members only”; either Pyramid must expose the intended public projection or the client needs an authoritative roster author filter.

**Executable evidence gaps:** verify deterministic chronological ordering across replaceable/article timestamps; confirm public-only routing and no private-room query leakage; test the exact NIP-50 behavior Pyramid implements; test Blossom MIME/delete/auth; prove deep links and signer handoff from the portal; verify static PWA and Electron updater behavior without upstream services.

**Confidence:** MEDIUM-HIGH on public-client capability; MEDIUM on exact member-feed semantics.

### 3. Nostrord — retain as NIP-29 oracle and fallback

Nostrord is the strongest independent cross-platform NIP-29 reference. Its current code covers group/member/role/moderation flows, threads/subgroups, join approval, NIP-07/46/55, and multiple native/web build targets. The 2026-07-30 head fixes a same-group-ID-at-another-relay admin-badge leak, showing both active maintenance and the need to pin and regression-test relay-scoped identity.

It is not a unified base: the project deliberately focuses on communities rather than a general timeline; branding is not a supported environment layer; web production packaging is not documented like the native builds; NIP-23 is partial; current upload code does not prove user-selected general Blossom; and iOS remains in development. A prior local acceptance run also found Amber 6.3.0 could publish while Nostrord remained stuck on its QR screen even though a disposable standards-compliant signer worked. Treat every signer/client pairing as executable evidence, never inferred NIP support.

**Use:** keep pinned native/web builds in the compatibility lab and offer a clearly labeled fallback link during pilot. Do not make it the main Pyramid shell.

**Confidence:** HIGH on its NIP-29 focus; MEDIUM on Pyramid/signers until tested.

### 4. Coracle — credible public alternative, wrong group model

Coracle is active, MIT, highly white-labelable, and feature-rich: public/custom feeds, NIP-23 rendering, NIP-50, notifications, NIP-05, NIP-58, Blossom-related source, NIP-07/46/55, PWA, Docker, and Android. Its Svelte/Welshman family makes it architecturally adjacent to Flotilla.

It does **not** implement current NIP-29 administration; its group/community features center on NIP-72 and NIP-87. Mapping those semantics onto Pyramid would create user confusion and parallel policy concepts. Choose it over Jumble only if NIP-58 presentation and flexible feed construction outweigh Jumble's simpler public-front-door posture. Current README configuration still references NIP-96 while source includes Blossom, so deploy behavior needs an exact test.

**Confidence:** MEDIUM-HIGH on public capability; HIGH that it is not the NIP-29 workspace base.

### 5. noStrudel — protocol-rich reference, not the product shell

noStrudel has the broadest specialist tooling here: public feeds, detailed relay controls, NIP-23 reading, NIP-50, notifications, NIP-05, NIP-58, extensive multi-server Blossom tools, NIP-07/46, Android/Amber account support, PWA, Docker, and Capacitor source. Its current group view can read and publish to an exact NIP-29 group relay.

No current NIP-29 join/invite/role/moderation UI was found. The project README explicitly warns that it is in development, has bugs/missing features, and should not be trusted with an `nsec`. It has no supported white-label layer and exposes a wide expert surface that conflicts with a coherent newcomer experience. Use its Applesauce implementations as references and perhaps deep-link advanced inspectors for operators; do not adopt the app as the primary community UI.

**Confidence:** MEDIUM-HIGH on protocol surfaces; MEDIUM on native packaging and production polish.

### 6. Snort — strong reusable social stack, no current NIP-29 workspace

Snort is active, mature, MIT, and unusually forkable through JSON app configurations for brand, hostname, NIP-05 domain, features, public assets, and default relays. It supports the broader social set—including NIP-23, NIP-50, NIP-58, Blossom in current changelog, notifications, and NIP-07/46/55—and publishes reusable `@snort/*` packages.

No current actionable NIP-29 group/admin implementation was found; a historical changelog mention and a generic `PublicGroupChat` enum are not sufficient evidence. Default branded configs can depend on external profile, analytics, push, or other services. Dockerfiles use mutable base tags and the branch can be ahead of the latest release. Snort is a good source/library candidate for a later custom client, not the current unified base.

**Confidence:** MEDIUM-HIGH on mature social features; HIGH on the NIP-29 gap found at the inspected pin.

## Strong-looking candidates excluded now

### Obelisk — revisit only after license and safety gates

Obelisk is a promising Discord-like NIP-29 PWA with NIP-07/46, NIP-42, NIP-50, NIP-78 branding, group administration, responsive UI, and Blossom image upload. It is also very young: package version 0.1.0, a recent comeback release, 25 stars, and zero forks at inspection.

It cannot be adopted now because the repository has no license according to GitHub metadata and contains no license file despite its README badge. Its Next configuration explicitly ignores TypeScript build errors and does not configure a static export. Its own [known-bugs document at the pinned commit](https://github.com/obelisk-app/obelisk/blob/e76afb2fa7a5eb69cde656d58eb11768f9f82ff4/docs/known-bugs.md) records unreliable notifications, stale membership, hidden/private-channel membership leakage through mention autocomplete, and plaintext voice presence/signaling that exposes channel participation and ICE/IP data. It also recommends/persists raw-key login and lacks the required public timeline, NIP-23, NIP-58, NIP-55, and general-file path.

**Re-entry gates:** explicit OSI-compatible license; no ignored build errors; fixed private-channel and voice leaks; reproducible self-hosted production build; BYOK signer matrix; Pyramid interoperability suite; one stable release cycle.

### The Wired — feature match, architectural mismatch

The Wired appears closest on a feature checklist, but packages its own Rust NIP-29 relay, backend RBAC, feed/search/push systems, Blossom service, gateway, PostgreSQL, Redis, Meilisearch, and LiveKit around a Tauri desktop client. Adopting it would introduce a second authoritative policy/data plane, duplicate Pyramid and Blossom, expand the trust and operations surface, and exceed the project's deliberately small service/cost envelope. Its mobile companion and plugin system are roadmap items, not current stable capabilities.

Do not integrate The Wired as a server or primary client. Individual UI ideas can be studied under MIT, but any reuse must be isolated from its backend assumptions.

## Recommended composed experience

| Surface | Adopt | User job | Authority rule |
|---|---|---|---|
| `community.<domain>` | Thin Pyramid portal/custom shell | Onboarding, signer choice, status, global nav, directory, badges, client handoff | Read-only projection of Pyramid facts; no shadow ACL/database |
| `rooms.<domain>` | Branded, pinned Flotilla | Town square, rooms, joins, roles, moderation, group search, uploads | Every mutation goes directly to Pyramid; Blossom bytes go to configured Blossom |
| `feed.<domain>` | Branded, pinned Jumble | Public chronological member feed, replies, reactions, article reading, public search | Query only approved public projection/relays; never infer membership locally |
| Compatibility lab | Pinned Nostrord plus Flotilla/Jumble test builds | Cross-client protocol and signer regression | Test-only; not an authority or promised default UX |

Use the same logo, typography, colors, privacy/help language, route vocabulary, and persistent top-level destinations across portal and forks. Prefer normal links with `nprofile`, `nevent`, `naddr`, relay hints, and NIP-29 group coordinates; define and test a canonical deep-link contract. Do not promise shared login across origins: browser NIP-07 can be re-authorized per origin, NIP-46 sessions are client-specific, and local signer state must not be copied between apps.

## Custom work that remains

| Work item | Why no candidate closes it | Recommended implementation |
|---|---|---|
| Exact public `All` | Existing feeds are relay/follow/space scoped, not the authoritative active-member projection | Pyramid-backed public filter or roster-author query; chronological, no engagement ranking |
| Manual `Best of` | No client implements moderator curation contract | Verified NIP-51 list/projection after event-shape and deletion tests |
| Authoritative directory | Client group lists are contextual and social profiles are not membership truth | Portal view derived from Pyramid membership, roles, NIP-05, and public profile events |
| Alumni/member badges | Flotilla/Jumble lack NIP-58; generic clients cannot assert Pyramid status | Pyramid-issued/verifiable NIP-58 events rendered in portal; Coracle/noStrudel as references |
| Long-form authoring | leading candidates render but do not provide the required editorial path | Small NIP-23 editor/publisher module or explicit compatible-client handoff |
| General files | current upload flows skew image/media and differ on server selection/delete | Blossom file browser with MIME, size, auth, download, deletion, and failure-state tests |
| NIP-05 provisioning | clients mostly verify/display existing identifiers | Portal claim/manage flow backed by the chosen Pyramid-integrated provisioning service |
| Signer onboarding | nominal NIP support does not guarantee interoperability | Capability-driven NIP-07/46/55 guide, QR/deep-link fallbacks, no raw-key default |
| Privacy guardrails | ACL UI does not guarantee relay routing or encryption | Public/private labels, allowed-relay policy, trap-relay tests, and explicit no-confidentiality copy |
| Cohesive navigation | separate apps otherwise feel fragmented | Shared design tokens/header/help language and tested canonical deep links |

## Adoption sequence

1. **Executable bake-off:** build pinned Flotilla, Jumble, and Nostrord; run the Pyramid NIP-29/NIP-50/Blossom/signer/privacy matrix. No branding work before the protocol gate passes.
2. **Pilot composition:** deploy a minimal portal, branded/configured Flotilla, and constrained Jumble. Remove upstream analytics/external-service defaults. Publish exact source pins and license notices.
3. **Close identity/content gaps:** add authoritative directory, NIP-05 flow, exact `All`, `Best of`, general files, NIP-23 authoring, and NIP-58 badges in the portal or as small Flotilla modules.
4. **Upstream first:** contribute generic missing surfaces and interoperability fixes to Flotilla/Jumble. Maintain a small patch ledger and reproducible fork builds.
5. **Consolidate only on evidence:** if cross-client handoff, accessibility, signer friction, or maintenance remains unacceptable after pilot, move public/article/badge modules into the Flotilla/Welshman base. A full custom client is a last resort, not phase one.

## Required executable acceptance matrix

Claims above are source evidence, not operational acceptance. Before selecting production pins, record pass/fail evidence for:

- reproducible lockfile install, typecheck, unit tests, production build, container/static serve, offline/PWA update, and license/SBOM output;
- Pyramid join/leave/invite/approve/kick/ban/unban/role/custom-role/delete semantics and relay-scoped same-ID groups;
- public note/reply/reaction, NIP-23 render/publish/edit/delete, NIP-50 note/profile/group search, and moderator-curated list behavior;
- Blossom image, audio, video, PDF, archive, generic binary, oversize, auth expiry, download, delete, and unavailable-server behavior;
- NIP-05 valid/invalid/changed identifier display plus claim/manage flow;
- NIP-07 browser extension, NIP-46 QR/bunker reconnect/reject/timeout, and NIP-55 Amber flows on every supported OS/client pairing;
- a trap relay that must receive **zero** private-room filters/events; no hidden membership in autocomplete, notification previews, logs, analytics, or push payloads;
- keyboard-only navigation, screen reader names, contrast, reduced motion, narrow mobile layout, localization overflow, and deep-link round trips;
- clean behavior with all non-Pyramid analytics, proxies, push, profile, image, and telemetry services blocked.

## Primary sources

- Flotilla [repository README at pin](https://gitea.coracle.social/coracle/flotilla/src/commit/d02e0ed56a50fe16fa8208b9c96c5568f6b8655f/README.md), [source tree](https://gitea.coracle.social/coracle/flotilla/src/commit/d02e0ed56a50fe16fa8208b9c96c5568f6b8655f)
- Nostrord [repository at pin](https://github.com/nostrord/nostrord/tree/d0f031685dcec3cc0119b152c56a59fe5f52f1f1), [official site](https://nostrord.github.io/)
- Jumble [repository at pin](https://github.com/CodyTseng/jumble/tree/f828c8fae394ed24a3015cc377b2bbf1b89fd92b), [v26.7.2 release](https://github.com/CodyTseng/jumble/releases/tag/v26.7.2)
- Coracle [repository at pin](https://github.com/coracle-social/coracle/tree/85868b9b52187dfa700c303a244be5c3827f723c), [official site](https://coracle.social/)
- noStrudel [repository at pin](https://github.com/hzrd149/nostrudel/tree/1261b4f0de6fc9fd059edc2271347a2b91401a97)
- Snort [repository at pin](https://github.com/v0l/snort/tree/3cc8317af0b95ca227d8c91b014eea414e0ac26f), [v0.5.3 release](https://github.com/v0l/snort/releases/tag/v0.5.3)
- Obelisk [repository at pin](https://github.com/obelisk-app/obelisk/tree/e76afb2fa7a5eb69cde656d58eb11768f9f82ff4), [known bugs at pin](https://github.com/obelisk-app/obelisk/blob/e76afb2fa7a5eb69cde656d58eb11768f9f82ff4/docs/known-bugs.md)
- Obelisk [official GitHub repository metadata](https://api.github.com/repos/obelisk-app/obelisk) for current license/activity status
- The Wired [repository at pin](https://github.com/ishtarservices/TheWired/tree/364112ef924ceeef43a1f13cf66ee3cb4738129d), [v0.6.5 release](https://github.com/ishtarservices/TheWired/releases/tag/v0.6.5)

## Confidence and open questions

| Area | Confidence | Reason |
|---|---|---|
| License/activity/releases | HIGH | Official repository files and hosting/release APIs at exact observed commits |
| Build/deployment/branding | MEDIUM-HIGH | README, manifests, Dockerfiles, and config source inspected; production builds not executed |
| Protocol feature presence | MEDIUM-HIGH | Exact source paths and official protocol lists inspected; negative findings are “not found at pin,” not proof of impossibility |
| Pyramid compatibility | MEDIUM-LOW | No candidate was exercised against the current Pyramid implementation |
| Privacy/signer behavior | MEDIUM-LOW | Source-visible paths and documented defects exist, but complete device/relay matrices remain unrun |

Phase-specific research remains necessary for Pyramid's exact NIP-29/NIP-86 dialect, search filters, NIP-51 `Best of` representation, Blossom auth/deletion, NIP-05 provisioning API, push architecture, and canonical cross-client deep links.
