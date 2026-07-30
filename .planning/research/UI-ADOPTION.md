# UI Adoption Architecture

**Project:** Sovereign Engineering Nostr Community Infrastructure  
**Researched:** 2026-07-30  
**Question:** How can Dialogos gain a coherent Pyramid community UX without accidentally creating another authority or an unmaintainable client product?  
**Confidence:** MEDIUM — current client repositories and official browser-security guidance support the boundary and count analysis; live Pyramid/client/signer interoperability remains unproven.

## Recommendation in One Sentence

Launch with a branded portal and upstream clients, then self-host **one pinned, source-unmodified static web client on its own origin** only after pilot evidence selects it; permit a web-only narrow fork when upstream configuration cannot close a measured high-frequency workflow gap, and build a new full client only behind the existing v2 evidence and ownership gate.

This sequence adds coherence without changing the v1 server authority model. Strategies A, B, C, and a static web-only D all add **zero always-on server processes, zero server-side persistent stores, and zero Nostr-aware server services**. B–D add one public origin. The cost is mainly frontend supply chain, test, release, and long-term maintenance—not VPS runtime.

## Non-Negotiable State Boundary

```text
browser UI
  ├─ disposable cache, drafts, layout, relay preferences
  ├─ requests signatures from member-selected NIP-07/46/55 signer
  └─ sends standard signed events / authenticated HTTP requests
            │
            ▼
       Caddy public boundary
            │
            ├─ Pyramid: sole membership, role, group, moderation,
            │           accepted-event, search, and relay authority
            └─ Blossom: sole public-blob ownership and lifecycle authority
```

No UI strategy may add a backend-for-frontend that stores membership, roles, group policy, events, search truth, signer sessions, or blob ownership. Client-side validation improves errors but grants no permission. Pyramid revalidates every event and request. Browser IndexedDB, Web Storage, service-worker caches, drafts, and view state are local and disposable; clearing them must not remove community data or membership. Member and operator private keys, bunker URIs, and signer connection secrets remain outside Dialogos infrastructure.

Configuration is also bounded. Relay URLs, Blossom URL, recommended signer relays, brand assets, and deep-link templates are immutable build/config artifacts. They are not a role database. A member may still publish public events to their chosen public relays, while private/group routes remain explicitly isolated.

## Count Baseline

The project baseline is fixed by `OPS-02`: seven always-on processes, eleven managed systemd units, three local public origins during pilot, three runtime stores, and two Nostr-aware server processes. Counts below are deltas from that baseline.

The compatibility-cell count uses the required **3 clients × 5 signer paths × 12 flows = 180 cells** before browser/device permutations:

- Clients: Nostrord, Flotilla, Jumble.
- Signer paths: nos2x Chromium, nos2x Firefox, Amber/NIP-55, selected iOS NIP-46, member-chosen NIP-46 bunker.
- Flows: login, reconnect, public publish, invitation, role display/action, private read allow, private read deny, search, upload, delete, rejected write, and error behavior.

Unsupported combinations are recorded as evidenced N/A, not silently skipped.

## Strategy Comparison

| Measure | A. Branded portal only | B. Self-host unmodified client | C. Narrow downstream fork | D. New full custom client |
|---|---:|---:|---:|---:|
| Always-on server processes | +0 | +0 static | +0 static | +0 static web; native apps are endpoint processes |
| Systemd units | +0 | +0 | +0 | +0 |
| Public origins | +0; use `community…` | +1 `app…` or `feed…` | +1 `app…` | +1 `app…` |
| Server persistent stores | +0 | +0 | +0 | +0 |
| Nostr-aware server processes | +0 | +0 | +0 | +0 |
| Independent build/release lanes | +0; existing site pipeline | +1 web artifact | +1 web fork | +4: web/PWA, Android, iOS, desktop |
| Minimum compatibility checks | 188: 180 + 8 portal | 192: 180 + 12 hosting | 216: 180 + 12 hosting + 24 fork | 252: 180 + 60 custom-client + 12 hosting |
| Recommended cadence | Monthly link/pin review | Four-week pin/release; urgent security rebuild ≤72h | Weekly upstream review; monthly rebase/release; urgent fix ≤48h | Fortnightly web; monthly native; urgent fix ≤24h |
| Security surface | Existing portal and outbound links | Full client JS/Wasm dependency graph, CSP, service worker, local storage, signer origin grant | B plus maintained diff and merge-conflict risk | Entire protocol/UI/storage/native/supply-chain surface |
| Upstream drift | Low | Medium: pin lag | High: continual rebase | None externally; all protocol drift becomes local work |
| Mobile/desktop burden | Upstream owns it | Web only; upstream apps remain recommended | Keep fork web/PWA only or burden becomes XL | Android+iOS+desktop packaging, stores, signing, updates |
| Operator burden | Low | Low/medium | High | Very high |
| Relative engineering complexity | **S / 1 of 5** | **M / 2 of 5** | **L / 4 of 5** | **XL / 5 of 5** |
| Rough initial effort | 1–2 engineer-weeks | 3–6 engineer-weeks | 2–4 engineer-months | 18–36 engineer-months cross-platform |
| Architecture fit now | **Best v1** | Best post-pilot experiment | Conditional only | Reject before v2 gate |

Effort ranges are planning estimates, not vendor facts. They assume one experienced frontend/Nostr engineer, existing design assets, and no new server-side feature.

### A. Branded configuration and deep-link portal

Build one coherent `community.<domain>` portal that explains public versus operator-readable rooms, recommends clients by device/job, provides signer-safe onboarding, displays the roster/directory and Best-of, and deep-links into upstream Nostrord, Flotilla, Jumble, and signer applications. Keep the portal mostly static. It may derive public read-only display from standard relay queries, but it must not publish, administer groups, or retain signer state in v1.

The eight portal-specific checks are: Nostr URI copy/open, Nostrord link, Flotilla link, Jumble community link, Android signer handoff, iOS NIP-46 handoff, return-to-portal behavior, and safe failure when an app/protocol handler is absent.

**Benefits:** smallest attack surface; upstream teams own native packaging; instant rollback by replacing static assets; real pilot evidence before client ownership. **Limit:** visual and navigational coherence ends when the member enters another client. State and read markers will differ across clients.

**Use now.** This is the only strategy that does not add a new software supply chain beyond the already-required public site.

### B. Self-host one unmodified primary client

Build a pinned upstream commit into static assets, generate an SBOM and checksums, test it, and let the existing Caddy serve it from a dedicated origin. Do not run the project's development/Node/Docker web server in production when an immutable static export works. This keeps the process, unit, store, and Nostr-aware-server deltas at zero.

Candidate fit differs:

| Candidate | Best hosted role | Architecture implication |
|---|---|---|
| **Jumble** | Public chronological feed, discovery, long-form | Easiest current B candidate. Official community mode accepts preset relay sets and relays; its web build is independent of Electron ([README at researched pin](https://github.com/CodyTseng/jumble/blob/f828c8fae394ed24a3015cc377b2bbf1b89fd92b/README.md)). It does not replace NIP-29 administration. |
| **Flotilla** | Coherent Discord-like alumni workspace | Strongest product candidate: official platform branding, platform relays, defaults, Blossom, signer, and blocked-relay configuration exist. But official instructions tell custom deployments to remove the maintainer-hosted Plausible script, so current Flotilla is **not strictly strategy B** for this privacy posture; it belongs in C unless upstream adds an analytics-off build switch ([official README](https://gitea.coracle.social/coracle/flotilla/src/commit/d02e0ed56a50fe16fa8208b9c96c5568f6b8655f/README.md)). |
| **Nostrord** | NIP-29 reference and focused group operations | Strong protocol baseline. Its official project targets Web, Android, iOS, and Desktop through Kotlin Multiplatform with separate Gradle/Xcode paths ([README at researched pin](https://github.com/nostrord/nostrord/blob/d0f031685dcec3cc0119b152c56a59fe5f52f1f1/README.md)). Host only its web artifact; do not inherit all native release lanes merely for branding. |

The twelve hosting checks are: CSP, connect-source allowlist, frame policy, service-worker scope, old-cache upgrade, blank-cache recovery, browser storage clearing, NIP-07 origin prompt, NIP-46 reconnect, relay-destination capture, Blossom CORS/auth, and instant rollback to the prior artifact.

**Recommended first hosted experiment:** pinned Jumble community mode on `feed.<domain>` after the core pilot, because it fills the public-feed job with configuration rather than source changes. Select a primary alumni workspace only after Flotilla/Nostrord live evidence; current documentation alone does not justify forcing either on all members.

### C. Maintain a narrow downstream fork

Fork the best proven web candidate only when a high-frequency job cannot be solved by upstream configuration or a deep link. Current evidence makes a web-only Flotilla fork the likeliest C candidate because it has the broadest workspace UX and documented platform mode, while its analytics removal already requires a controlled source difference.

The fork contract must remain narrow:

- Web/PWA only; do not fork Android/iOS/desktop packages.
- Branding, relay/Blossom/signer defaults, analytics removal, privacy labels, route links, and proven Pyramid compatibility fixes only.
- No server API, private event format, membership database, signer custody, push service, or custom event authority.
- Keep all community-specific policy in a small adapter/config layer. Upstream general fixes first.
- Pin upstream commit, record patch series, produce reproducible assets/SBOM, and keep one-click rollback to the last source-unmodified artifact.

The 24 fork checks cover eight fork-owned behaviors across Chromium, Firefox, and mobile Safari: branding/config load, public relay destination, private/group destination, signer handoff, Blossom destination, privacy labels, deep-link routing, and upstream-artifact rollback.

**Fork entry gate:** at least 10 pilot members or 20% of the active pilot cohort must report the same core-job failure in two consecutive feedback rounds; the failure must reproduce on pinned upstream; a configuration/upstream fix must be unavailable within one release cycle; and two named maintainers must accept a 12-month maintenance budget.

**Fork removal gate:** return to upstream/configuration if either monthly rebase exceeds two engineer-days twice in a row, a critical security update cannot be integrated within 48 hours, the required matrix falls below 95% pass for two weeks, upstream absorbs the patch, or the hosted fork serves fewer than 25% of weekly active members for eight consecutive weeks.

### D. Build a new full custom client

A real full client means more than a static feed. It owns subscription lifecycle, event validation and rendering, thread/group semantics, moderation/admin UX, search, uploads, deletion, relay routing, offline state, signer mediation, notifications, accessibility, upgrades, and platform delivery. To meet the intended reach, it creates four release lanes: web/PWA, Android, iOS, and desktop. The browser build still adds no server daemon or canonical store, but project maintenance becomes a permanent product line.

The custom client adds a fourth client to the five-signer/twelve-flow matrix: **4 × 5 × 12 = 240 protocol cells**, plus the twelve hosting checks = 252 before platform permutations. Native stores, code signing, update mechanisms, OS keychain behavior, app review, and notification infrastructure add further matrices. If push is later selected, count it separately; it is deliberately not smuggled into the zero-server estimate.

**Entry gate:** existing clients plus portal and one narrow fork must fail at least three weekly core jobs for two consecutive release cycles; at least two long-term maintainers and funded 0.5 FTE for 12 months must be named; a UI/protocol/state specification and repository-grounded threat model must exist; and the 252-cell pre-device matrix must be automatable. This matches `CLIENT-01`: the custom client is v2 evidence-gated, not a branding shortcut.

**Removal gate:** stop before public promotion if core-flow pass rate is below 95%, urgent security fixes miss 72 hours, either maintainer exits without replacement, maintenance exceeds the approved budget for two quarters, or the client cannot be removed while leaving Pyramid, Blossom, identities, and events usable through upstream clients.

## One Origin Versus Separate Origins

Do **not** mount multiple independent clients at paths such as `/flotilla` and `/jumble` under one origin. Paths are not browser security boundaries. Same-origin applications can access the same origin-scoped storage and broadly script one another; browser Web Storage and IndexedDB separation is by scheme/host/port, not path ([MDN same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Same-origin_policy)). They also share the NIP-07 permission identity presented to the signer, complicate service-worker scope, and force a union CSP/connect allowlist.

Use one top-level client per separate origin:

```text
community.<domain>  portal, onboarding, directory, Best-of
feed.<domain>       optional pinned Jumble web build
app.<domain>        later selected primary workspace; never two clients here
relay.<domain>      Pyramid WSS
blobs.<domain>      standalone Blossom HTTPS
```

Each extra client origin adds **+1 origin, +0 process, +0 unit, +0 server store, +0 Nostr-aware server** when Caddy serves static assets. It also creates a separate CSP, service worker, browser cache, storage namespace, and signer permission prompt. That extra prompt is useful evidence that trust is changing.

Prefer top-level links/deep links, not an iframe “super-app.” Cross-origin iframes isolate storage, but signer injection and navigation can fail; a sandbox without `allow-same-origin` receives an opaque origin and loses normal local storage, while combining powerful sandbox allowances weakens isolation ([MDN CSP sandbox](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/sandbox)). CSP `frame-ancestors`, narrow `connect-src`, Permissions Policy, and top-level COOP can harden independent origins ([MDN CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP), [Permissions Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Permissions_Policy)).

If later composition truly requires messaging, pass only public identifiers and explicit intent envelopes through origin-checked `postMessage`; never send private event bodies, signer objects, auth tokens, bunker URIs, membership claims, or raw database state. A shared header/theme can be reproduced at build time. It does not require shared runtime state.

## Phased Migration and Rollback

### Phase 0 — v1 internal pilot: A only

Ship the static portal with device/job-specific recommendations and deep links. Keep Nostrord as protocol baseline, Flotilla as candidate workspace, and Jumble as public feed. Run the 180-cell compatibility matrix and eight portal checks. Collect aggregate task completion plus periodic qualitative feedback; do not add behavioral analytics.

**Rollback:** replace the portal artifact or remove a broken link. No data migration exists.

### Phase 1 — post-pilot public-feed trial: B

Deploy a pinned, unmodified Jumble community-mode build on `feed.<domain>`. Caddy serves immutable static assets. Enforce per-origin CSP/connect destinations, no external analytics, signer-safe login, destination capture, and cached-version rollback. Trial for eight weeks against upstream Jumble links.

**Promote if:** at least 25% of weekly active members use it in four of eight weeks, its relevant matrix is 100% pass, and support burden stays below two operator-hours per week. **Remove if:** any private relay destination appears, a critical issue cannot be rebuilt within 72 hours, or usage stays below 10% WAU for four consecutive weeks.

### Phase 2 — coherent workspace: B if possible, C only if necessary

Choose Flotilla or Nostrord from measured group, signer, privacy, upload, notification, and error-path evidence. Prefer an upstream-configured static build. Until Flotilla can disable its external analytics without a source change, treat a hosted Flotilla as C and keep the patch series minimal. Keep upstream native apps available; never make the hosted web app the only exit.

**Rollback:** DNS/Caddy switches to the prior immutable artifact or portal; client cache clearing is documented; all durable events and memberships remain usable in upstream clients.

### Phase 3 — v2 custom-client decision: D gate

Only consider D after the portal and narrow-client path has generated evidence of persistent unmet jobs. Build protocol/state adapters before visual replacement, keep public standard interfaces, and prove removal with another approved client at every milestone.

## Architecture Score

**Recommended phased option (A now → one static B → bounded C only on evidence): 8.5/10.**

It scores well because it preserves one authority, adds no server state/process, keeps native clients and signers replaceable, isolates hosted code by origin, and makes each ownership increase reversible. It loses points for current client immaturity, an unexecuted compatibility matrix, external-client visual discontinuity, and Flotilla's current analytics-removal requirement.

Exact improvements to 10/10:

| Improvement | Score gain | Proof |
|---|---:|---|
| Upstream analytics-free, config-only white-label mode for selected primary client | +0.4 | Zero downstream source diff; blocked outbound capture |
| Reproducible pinned web build with checksums, SBOM, provenance, and ≤72h security rebuild drill | +0.3 | Two independent builds match; rollback exercised |
| Full 180-cell required matrix plus relevant hosting checks passes | +0.3 | Retained automated/manual evidence against production candidate |
| Standard deep links and relay/Blossom/signer adapters work across all approved clients without private-route leakage | +0.3 | Destination-capture tests and missing-handler fallbacks pass |
| Eight-week evidence shows one hosted client completes at least 90% of measured weekly core jobs while remaining removable | +0.2 | Feedback/task evidence plus successful upstream-client exit drill |
| **Total** | **+1.5 → 10.0** | All five gates current |

The score must fall again when evidence expires, a client pin changes, or a new signer/platform is added. Architecture quality here is a maintained property, not a one-time selection.

## Primary Evidence

- [Nostrord repository at researched commit `d0f0316`](https://github.com/nostrord/nostrord/tree/d0f031685dcec3cc0119b152c56a59fe5f52f1f1) — Kotlin Multiplatform Web, Android, iOS, Desktop build ownership.
- [Flotilla repository at researched commit `d02e0ed`](https://gitea.coracle.social/coracle/flotilla/src/commit/d02e0ed56a50fe16fa8208b9c96c5568f6b8655f) — platform branding/mode, relay/signer/Blossom/push configuration, static build option, custom-deployment analytics warning.
- [Jumble repository at researched commit `f828c8f`](https://github.com/CodyTseng/jumble/tree/f828c8fae394ed24a3015cc377b2bbf1b89fd92b) — web/Electron split and community relay presets.
- [NIP-07 browser signer](https://github.com/nostr-protocol/nips/blob/master/07.md), [NIP-46 remote signing](https://github.com/nostr-protocol/nips/blob/master/46.md), [NIP-55 Android signer](https://github.com/nostr-protocol/nips/blob/master/55.md), [NIP-29 groups](https://github.com/nostr-protocol/nips/blob/master/29.md).
- [MDN same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Same-origin_policy), [CSP guidance](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP), [CSP sandbox](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/sandbox), [Permissions Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Permissions_Policy).
