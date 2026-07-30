# Client Hosting and Live-Verification Supplement

**Project:** Sovereign NIP-29 community relay
**Researched:** 2026-07-30
**Scope:** Official repositories, their current default branches, tagged release sources, build files, CI, and maintainer-authored QA notes only
**Confidence:** HIGH for repository/build/runtime facts; MEDIUM for protocol behavior not exercised against this project's Pyramid instance

## Recommendation

Use a **narrow, hardened fork of Flotilla 1.9.0** as the base for `community.<domain>`, compile it as a static PWA, and serve the immutable build from the existing Caddy process. Do not run Flotilla's optional Node/Hono server and do not deploy its Coracle Hosting, Dufflepud, Pomade, Plausible, or third-party push defaults.

Flotilla is the only inspected web client that already models a deployment as a branded NIP-29 platform: `VITE_PLATFORM_RELAYS` makes the first configured relay home and removes space browse/add/select, while build-time variables cover name, logo, accent, theme, policy links, relay sets, indexers, signer relays, and Blossom servers. Its source and changelog contain real NIP-29, NIP-42, NIP-50, Blossom, NIP-07/46/55, and Pyramid/relay29 synchronization work. That makes the remaining work a bounded policy and supply-chain fork, not a new client.

It is not deployable unchanged. The upstream artifact loads Plausible, stores notification-check state at a hardcoded Coracle Dufflepud endpoint, opens entity links on `coracle.social`, exposes a Coracle Hosting control plane, and ships many public relay/signer/media defaults. It also lacks source-confirmed NIP-23 article support and has too little automated browser coverage for an authority-sensitive deployment. Those are launch gates, not follow-up polish.

Nostrord is the best fallback/reference for deep NIP-29 group behavior. Jumble is the best later reference for a public feed, NIP-23 reading, Blossom, and NIP-50, but is not a NIP-29 group-administration client. Amethyst is a strong native interoperability client, not a web-hosting base.

## Primary-Source Snapshot

| Candidate | Canonical source and license | Current source at cutoff | Latest release/tag | Host at `community.<domain>`? | Base verdict |
|---|---|---|---|---|---|
| **Flotilla** | [coracle/flotilla](https://gitea.coracle.social/coracle/flotilla), MIT. The old [GitHub mirror](https://github.com/coracle-social/flotilla) is archived and points to Gitea. | Default `dev`: [`d02e0ed`](https://gitea.coracle.social/coracle/flotilla/commit/d02e0ed56a50fe16fa8208b9c96c5568f6b8655f), 2026-07-29, “Add hosting nav item.” | [`1.9.0`](https://gitea.coracle.social/coracle/flotilla/src/tag/1.9.0), `b0ebb988f133d862711cda4d7beb62b6b4d7476e`, 2026-07-29. | **Yes.** Static `build/` works behind Caddy; optional Node server is unnecessary. | **Recommended, after narrow hardening fork.** |
| **Nostrord** | [nostrord/nostrord](https://github.com/nostrord/nostrord), Unlicense/public domain. | Default `main`: [`d0f0316`](https://github.com/nostrord/nostrord/commit/d0f031685dcec3cc0119b152c56a59fe5f52f1f1), 2026-07-29, cross-relay same-ID admin-badge fix. | [`v2.4.0`](https://github.com/nostrord/nostrord/tree/v2.4.0), `5cc04b2287f8b22f568f429db33cdd0344ad6e52`, 2026-07-23. Current main is 57 commits ahead. | **Yes.** Official production workflow emits a static JS distribution. | Strong NIP-29 fallback; larger branding/configuration fork, narrower town-square surface. |
| **Jumble** | [CodyTseng/jumble](https://github.com/CodyTseng/jumble), MIT. | Default `master` and latest tag: [`f828c8f`](https://github.com/CodyTseng/jumble/commit/f828c8fae394ed24a3015cc377b2bbf1b89fd92b), 2026-07-29. | [`v26.7.2`](https://github.com/CodyTseng/jumble/tree/v26.7.2), same commit. | **Yes.** Static `dist/` works behind Caddy; official Compose stack is not suitable unchanged. | Feed/article companion only; reject as primary NIP-29 UI. |
| **Amethyst** | [vitorpamplona/amethyst](https://github.com/vitorpamplona/amethyst), MIT. | Default `main`: [`1f4d972`](https://github.com/vitorpamplona/amethyst/commit/1f4d9728be9b29105d40ca4cc4b9b771b123e877), 2026-07-29. | [`v1.13.1`](https://github.com/vitorpamplona/amethyst/tree/v1.13.1), `1bda3ab31b2e9bb54301698f6c2e0baca0da16d2`, 2026-07-28. Main is 153 commits ahead. | **No.** Android and desktop application, no hosted web target. | Native compatibility/reference client; do not fork for the web origin. |

Dates above are commit timestamps from the fetched canonical Git objects. “Latest release/tag” means the newest stable tag present in canonical source at the research cutoff; it does not imply this project has accepted that artifact.

## Capability and Dependency Matrix

| Area | Flotilla 1.9.0 | Nostrord v2.4.0 / current main | Jumble v26.7.2 | Amethyst v1.13.1 / current main |
|---|---|---|---|---|
| Product shape | Discord-like “relays as groups”; web/PWA plus Capacitor Android/iOS | Focused NIP-29 client; web, Android, JVM desktop, iOS source | Relay-feed explorer; web/PWA plus Electron/Flatpak | Android and Compose desktop; iOS work exists in shared layers but no user-facing web build |
| NIP-29 | **Native core.** Spaces, rooms, membership, invites, roles/admin, public/restricted/private flows, pins and several room content types | **Native core and deepest inspected implementation.** Full 9000-series admin flows, group metadata/member/admin streams, hierarchy, invites, relay-scoped identity | **No primary group UI.** Kind 39000 rendering and NIP-43 join/invite/leave exist, but no source evidence of 9000-series NIP-29 administration | README checks NIP-29; Android UI includes browse/join/admin surfaces, but maintainer QA left metadata edits, invite creation, subgroups, and pins unexercised |
| Pyramid-specific | Changelog explicitly says synchronization was improved “especially for pyramid and relay29” | Source refreshes live subscriptions for relays that drop idle subscriptions and names `pyramid.fiatjaf.com`; current main fixes same-ID groups leaking state across relays | No Pyramid-specific source path found | No Pyramid-specific path found; generic NIP-29 only |
| NIP-42 | Implemented with explicit auth states, retry, privacy policy, and publish-time auth | Implemented; private group loading accounts for slow NIP-46 AUTH | Implemented for browser and Electron | README/source support; maintainer QA shows broad relay-client coverage but not a Pyramid acceptance run |
| NIP-23 | **Not source-confirmed.** No kind 30023/article implementation found | Renders kind 30023 article cards when embedded in chat; no article feed/editor found | Reads and renders kind 30023 in an Articles feed; no article authoring path found | README checks NIP-23; native client feature, not web-hosted |
| Blossom/media | Configurable Blossom defaults and kind 10063 settings; signed upload/get flows | **No Blossom path found.** Uploads are hardcoded to `https://nostr.build/api/v2/upload/files` with NIP-98 and NIP-68 metadata | Strong Blossom SDK, BUD/NIP-98 upload auth, kind 10063 server list, metadata stripping; several public fallback servers hardcoded | README checks Blossom; native Android implementation and desktop work exist; platform parity still needs acceptance |
| NIP-05 / NIP-50 | Profile/NIP-05 behavior through Welshman; NIP-50 relay detection, search-relay settings, and relay search | NIP-05 string display/shape checks; no source-confirmed domain verification. Search is local/paginated group-chat search, not NIP-50 | NIP-05 lookup plus configurable/hardcoded search relays and NIP-50 flows | README checks both; source includes broad native support |
| Notifications | In-app/browser behavior; Capacitor background push requires `VITE_PUSH_SERVER` and `VITE_PUSH_BRIDGE`; notification read/check state uses hardcoded Dufflepud | Browser notifications via service worker/page APIs while the client is active; Android notification `notify()` is empty at current main, although sound works; no push backend | In-app unread list/title/favicon only; no web Push API/service-worker notification code found. Electron uses OS notifications for updater events, not social push | In-app plus Google Firebase Messaging for Play and UnifiedPush/de-googled paths; requires external push infrastructure/providers |
| NIP-07 / NIP-46 / NIP-55 | NIP-07 web; NIP-46 remote signer; NIP-55 via Android/Capacitor plugin | NIP-07 web; NIP-46; NIP-55 Android only (JS implementation throws unsupported) | NIP-07 and NIP-46; no NIP-55 source found | NIP-46 and NIP-55; NIP-07 is not applicable to native clients. QA says Amber/NIP-55 was not live-tested |
| Public feed | Space recent/feed surfaces exist; must acceptance-test strict chronological ordering and member/non-member views | Group messages/threads, not a general public town-square feed | **Strongest inspected feed client:** relay sets, chronological relay exploration, articles, search | Rich native feeds; not a community-hosted public landing surface |
| Analytics/telemetry | **Plausible is loaded unconditionally** from `plausible.coracle.social`; pageview calls depend on a user setting. Empty GlitchTip env exists. Remove both script and code | No analytics/telemetry dependency or endpoint found in source scan; still makes many configured/hardcoded relay/HTTP connections | No first-party analytics/telemetry call found. `workbox-google-analytics` is a transitive package but is not enabled in Vite PWA config | No analytics library found. Play flavor uses Firebase Messaging; a maintainer QA note mentions Crashlytics delivery, but current build has no Crashlytics dependency—treat note as stale/conflicting |
| Automated gates | `check`, lint, and Playwright scripts exist; only one actual smoke spec and no canonical workflow running them was found. Gitea workflow only builds/publishes container | CI runs Spotless, Detekt, JVM/JS compile, and JVM/common tests; 96 test files found. No browser E2E in CI | Seven test files found; lint/Vitest scripts exist. Only canonical workflow builds Electron/Flatpak releases; no web lint/test/build CI gate found | Strong multi-platform CI: formatting/KMP purity, JVM/common/desktop/Android/iOS tests, packaging, desktop smoke. Protocol checkbox breadth still exceeds live acceptance evidence |

No candidate alone proves every required behavior. In particular, a README NIP checkbox is evidence of maintainer intent, not Pyramid compatibility or feature parity across web/native targets.

## Candidate Details

### Flotilla — Recommended Base

**Build and runtime.** Upstream pins `pnpm@11.5.1`, declares Svelte 5.55, SvelteKit 2.61, TypeScript 5.9, Vite 6.4, and uses Node 24 in its Dockerfile. Production source commands are `pnpm install`, `pnpm run build`, optionally `pnpm run build:server`, then `pnpm run start`. For this project, use Corepack plus `pnpm install --frozen-lockfile`, run `pnpm check`, `pnpm lint`, `pnpm test`, and `pnpm build`, then publish `build/` to Caddy. Do **not** run `build:server` or `start`.

The optional server is a Hono/Node static server that also derives OpenGraph metadata by connecting to relay URLs embedded in request routes/query parameters. That creates another long-lived process and server-side outbound destination surface for a non-essential social-preview feature. Static hosting avoids both and keeps the project's exact seven-process budget unchanged.

**Self-host and configuration.** The [official README](https://gitea.coracle.social/coracle/flotilla/src/tag/1.9.0/README.md) explicitly supports copying `build/*` to any static host. Configuration is build-time, not runtime: upstream warns that environment values do not alter an already-built image. Useful variables include:

- brand: `VITE_PLATFORM_URL`, `VITE_PLATFORM_NAME`, `VITE_PLATFORM_LOGO`, `VITE_PLATFORM_ACCENT`, `VITE_PLATFORM_DESCRIPTION`, `VITE_PLATFORM_TERMS`, `VITE_PLATFORM_PRIVACY`, and `VITE_THEME`;
- authority: `VITE_PLATFORM_RELAYS`, which enables platform mode and makes the first relay home;
- routing/defaults: `VITE_DEFAULT_SPACES`, `VITE_DEFAULT_RELAYS`, `VITE_DEFAULT_MESSAGING_RELAYS`, `VITE_INDEXER_RELAYS`, `VITE_SIGNER_RELAYS`, and `VITE_BLOCKED_RELAYS`;
- media and optional infrastructure: `VITE_DEFAULT_BLOSSOM_SERVERS`, `VITE_PUSH_SERVER`, `VITE_PUSH_BRIDGE`, `VITE_POMADE_SIGNERS`, `VITE_THUMBNAIL_URL`, and hosting-backend variables.

The committed upstream `.env` is operationally significant. It defaults to Primal Blossom, Damus/Primal/nostr.mom outbox relays, public search and messaging relays, Coracle/Pomade signers, Coracle indexer/thumbnail/push/hosting endpoints, and a large seed-pubkey list. A community build must start from an explicit allowlist, not inherit this file.

**Required fork.** Environment configuration handles basic brand and relay preset without source edits. A maintained source fork is still required to:

1. remove `src/app.html` Plausible loading and analytics code;
2. make/remove hardcoded `DUFFLEPUD_URL=https://dufflepud.coracle.social` and `entityLink=https://coracle.social/...`;
3. remove Coracle Hosting navigation/routes/API. `HOSTING_ENABLED` currently checks only “not iOS,” not whether a backend is configured;
4. remove or hide email/Pomade, raw `nsec`, and generated-key onboarding; retain NIP-07, NIP-46, and supported NIP-55 entry points;
5. replace every relay/indexer/signer/media default with the project's explicit routing matrix and forbid access-controlled writes outside Pyramid;
6. disable public source maps for the production build, add a real CI workflow, and expand Playwright coverage;
7. implement or separately surface NIP-23 if long-form reading/authoring is launch-critical.

**Update path.** Pin tag plus commit and lockfile; build an immutable artifact; stage browser/PWA acceptance; atomically switch the Caddy symlink; retain the previous artifact for rollback. The PWA uses automatic service-worker updates, so release checks must include cache migration, open-tab behavior, and rollback. Track upstream tags and rebase the small hardening patchset; do not follow mutable `latest` images or the `dev` head automatically.

**Host impact.** Static mode adds one Caddy site/root, zero services, zero databases, and zero server-side stores. Browser IndexedDB/local state remains per client. Native push, Dufflepud, hosting backend, LiveKit, and thumbnail services are optional upstream dependencies and are excluded from the initial host budget.

### Nostrord — NIP-29 Fallback and Interop Reference

**Build and runtime.** The official repository uses Kotlin Multiplatform/Gradle. Documented builds include `./gradlew :composeApp:assembleDebug`, `:composeApp:run`, `:composeApp:fixDebPackage`, JS/Wasm development tasks, and Xcode for iOS. The actual production Pages workflow uses JDK 17, Node 20, `./gradlew :composeApp:jsBrowserDistribution`, and `:composeApp:copyJsCompressedFiles`, then publishes `composeApp/build/dist/js/productionExecutable`. Serve that directory statically with Caddy.

The checked-in deployment Caddyfile points instead at `wasmJs/productionExecutable` and adds COEP/COOP for WASM threads. That conflicts with the current production workflow, which builds the JS/React-DOM target. Treat the workflow as authoritative and write a project-specific Caddy site.

**Configuration and fork.** No deployment env surface comparable to Flotilla was found. Branding is hardcoded in HTML, manifest, icons, theme, document/share labels, `nostrord.com`/`web.nostrord.com` links, and package metadata. Relay defaults include `groups.fiatjaf.com`, Pyramid as a suggested relay, Damus/nos.lol bootstrap fallbacks, and public NIP-46 relay choices. Media upload is fixed to nostr.build. A fork is therefore required for brand, Pyramid home/preset, media server, external login pruning, and outbound allowlisting.

**Behavior.** Nostrord has the most source-visible NIP-29 correctness work: relay-scoped `(relay,id)` state, full admin kinds, private-group AUTH sequencing, hierarchy, invite/member/admin flows, and periodic subscription refresh for Pyramid-like idle drops. The newest main commit fixes an admin-badge leak where a cached same-ID group from another relay could affect the current group. That fix is **not in v2.4.0**. Do not deploy the release tag without backporting it; alternatively pin a reviewed post-release commit after CI and Pyramid interop.

NIP-23 support is rendering-only in the inspected source. NIP-50 was not found. NIP-05 is formatted/displayed but domain verification was not found. Browser notifications are local/service-worker notifications driven by the live client; they are not a privacy-preserving background push system. Current Android `NotificationService.notify()` is empty. Uploads use NIP-98 to nostr.build, not Blossom.

**Update/host impact.** Static hosting again adds no process or DB. The build is materially heavier than Flotilla (Gradle is configured for a 6 GiB heap), and upstream releases package Android and desktop installers too. For the hosted UI, pin one reviewed JS artifact and ignore native release machinery. This candidate needs a wider long-lived source fork and still lacks the public-feed/search/article breadth required for the full town square.

### Jumble — Feed Companion, Not Primary Group UI

**Build and runtime.** Jumble requires Node 20+, with `npm run build` executing `tsc -b && vite build`; the output is static `dist/`. Its Dockerfile uses mutable `node:20-alpine` and `nginx:alpine` plus `npm install`, while the release workflow correctly uses `npm ci`. Build directly from the pinned tag/lockfile and serve `dist/` with existing Caddy instead of adding Nginx.

The official Compose file also launches `ghcr.io/danvergara/jumble-proxy-server:latest`; the development file adds `scsibug/nostr-rs-relay:latest`. The proxy is only used to fetch arbitrary web metadata through `/sites/...` when `VITE_PROXY_SERVER` is set. The extra relay directly violates Pyramid's sole-authority boundary. Deploy neither. Link previews may be degraded by browser CORS without the proxy; that is preferable to an unreviewed public proxy process at launch.

**Community mode and fork.** `VITE_COMMUNITY_RELAY_SETS` and `VITE_COMMUNITY_RELAYS` provide administrator-pinned relay sets that visitors cannot remove. This is excellent for a branded public feed preset. It is not branding: the manifest, title/favicon logic, artwork, share surfaces, and app name remain Jumble. Source also hardcodes `api.jumble.social` for translation/transaction features, multiple Blossom/search/trending/big relays, NIP-46 relays, and Pomegranate/Google operators. A source fork is required to brand it and remove those services.

**Behavior.** Jumble is strong for relay feeds, NIP-23 reading, NIP-50, NIP-05, Blossom, NIP-42, and NIP-07/46. Its only group-related protocol implementation found was kind 39000 display plus NIP-43 join/invite/leave; no NIP-29 9000-series administration or group chat surface was found. It therefore cannot satisfy the primary community-client requirement. Its notifications are session/in-app unread state and title/favicon badges, not browser or background push. No NIP-55 implementation was found.

**Update/host impact.** The PWA and Electron updater both use automatic updates; web rollout needs the same immutable-artifact and service-worker rollback discipline as Flotilla. Static mode adds no process/store. Adding the optional proxy adds a process, GitHub credential handling, pprof exposure, logs, and outbound fetch policy; reject it unless a later phase explicitly designs and budgets a hardened metadata proxy. Consider Jumble only after launch if measured users need a dedicated public read surface and Flotilla cannot meet feed/article requirements.

### Amethyst — Native Compatibility Reference

Amethyst builds with Java 21+: `./gradlew assembleDebug`, `:desktopApp:run`, full `./gradlew build`, tests with `./gradlew test` and `connectedAndroidTest`. Official release automation packages signed Android, `.deb`, `.dmg`, `.msi`, Flatpak/Homebrew/Winget and related artifacts. It has no web artifact or static server, so it cannot back `community.<domain>`.

Its value is compatibility testing: official source advertises NIP-23, 29, 42, 46, 50, 55, Blossom, NIP-05, and Google/UnifiedPush notifications. CI is substantially broader than the web candidates. However, the maintainer-authored `amethyst/plans/2026-07-20-v1.13.0-release-qa.md` explicitly says NIP-29 admin metadata edits, invite creation, subgroups, pins, push notifications, search, and Amber/NIP-55 were not live-tested in that release session. It also records stale join-state and misleading unreachable-relay behavior. Use the checklist as feature discovery, and the QA note as the stronger statement of verified behavior.

There is no host process/store delta. Operational cost is user support and distribution across Android/Desktop channels, not server capacity. Use upstream binaries first; do not create a community-branded app-store fork until measured demand justifies signing keys, store accounts, release engineering, privacy disclosures, and multi-platform regression testing.

## Documentation-Only Claims and Source Conflicts

| Claim/conflict | Finding | Roadmap consequence |
|---|---|---|
| Flotilla README says custom deploys should remove Plausible | Source confirms the script remains in every upstream build and calls are merely gated by a setting | Fork/removal plus outbound-network test is mandatory before launch |
| Flotilla README describes an `.env.template` | Canonical tag/default branch contains a committed `.env`, not the named template, and it carries many public service defaults | Generate a project-owned environment manifest; fail builds on unset/unknown endpoints |
| Flotilla “self-host” suggests `pnpm run start` or `:latest` container | Static output is sufficient; Node server adds dynamic relay metadata fetches and mutable image use | Serve static artifact; pin source and toolchain; no new service |
| Nostrord README/product language emphasizes Wasm | Canonical production workflow builds JS; checked-in Caddyfile still targets Wasm | Pin the JS workflow artifact and write fresh Caddy config |
| Nostrord v2.4.0 is the latest release | Current main is 57 commits ahead and includes a cross-relay authorization-display correctness fix | Backport reviewed fix or pin reviewed post-release source; tag alone is insufficient |
| Nostrord advertises broad platforms/notifications/media | iOS is source/build-only in inspected release machinery; Android notification display is empty; media upload is nostr.build rather than Blossom | Acceptance must be target-specific; do not infer parity from shared code |
| Jumble “community mode” sounds like community administration | Source makes relay presets immutable to users but does not implement NIP-29 admin events | Use only as a feed UI, never as authority/admin UI |
| Jumble Docker Compose is an easy production deployment | It uses mutable images, `npm install`, an optional credentialed proxy with pprof, and in dev a second relay | Do not adopt Compose; static-only Caddy build |
| Amethyst README checks many NIPs | Maintainer QA explicitly leaves key NIP-29, push, search, and NIP-55 paths untested and records known defects | Treat README as inventory, not acceptance evidence |
| Amethyst QA refers to Crashlytics | Current source has Firebase Messaging in Play flavor but no Crashlytics dependency found | Do not claim Crashlytics telemetry; verify packaged network behavior if native client becomes in-scope |

## Required Production Shape

```text
browser / installed PWA
        |
        v
existing Caddy :443
  community.<domain> -> immutable Flotilla build directory
        |
        +--> wss://<Pyramid origin>       sole access-control authority
        +--> https://<Blossom origin>     media only
        +--> explicitly approved public relays/indexers for public events only
        +--> user-selected NIP-07 / NIP-46 signer transport

No Flotilla Node server
No Coracle Hosting backend
No Dufflepud/Plausible/Pomade defaults
No bundled relay
No new database or long-lived process
```

### Build Pin

Start from Flotilla tag `1.9.0` / commit `b0ebb988f133d862711cda4d7beb62b6b4d7476e`, `pnpm@11.5.1`, a pinned Node 24 patch/container digest, and the checked-in lockfile. Record the fork commit and built-artifact hash in the compatibility matrix. Review the single post-tag default-branch commit and later upstream fixes individually; never float to `dev` or `latest`.

### Minimum Fork Deltas

- Community name/logo/accent/theme/policy URLs and canonical origin.
- Pyramid as the sole platform/authority relay; explicit public/search/messaging/signer relay allowlists.
- Project Blossom origin; no Primal fallback.
- Plausible and GlitchTip removal; build must contain no analytics hosts.
- Dufflepud, Coracle entity links, Hosting UI/API, external thumbnail service, Pomade/email login, and raw-key onboarding removal.
- NIP-07 and NIP-46 first-class login; NIP-55 retained only where the platform actually supports it.
- Access-controlled event routing guard: no private/group/admin event may reach an outbox/search/public relay.
- Clear public chronological feed; document whether “best of year” is client logic or a later deterministic index.
- NIP-23 gap decision: implement in the fork or provide an explicitly separate reader after measured need.
- Local notification semantics without profiling; background push deferred until an owned, privacy-reviewed design exists.

### Release and Acceptance Gates

1. Reproducible frozen-lockfile build from exact source/toolchain pins; generate SBOM and artifact digest.
2. Static Caddy deploy only; no additional process or DB; hardened CSP/connect-src generated from the approved endpoint list.
3. Source scan and browser network capture prove absence of Plausible, Coracle, Pomade, Primal, Damus, nostr.mom, public signer, hosting, thumbnail, and unapproved push calls.
4. Pyramid live matrix covers anonymous/member/moderator/admin; public/restricted/private groups; NIP-42; NIP-07 and NIP-46; add/remove/ban/edit/invite; same group ID on two relays; reconnect and idle-subscription recovery.
5. Trap-relay tests prove access-controlled events never leave Pyramid. Public-event multi-relay behavior remains explicit and user-visible.
6. Blossom upload/read/delete/auth tests use only the project media origin and preserve media/relay failure isolation.
7. Feed tests prove canonical chronological ordering, pagination, duplicate handling, deleted events, NIP-23 decision, NIP-50 behavior, and non-member public access.
8. Notification tests distinguish in-app unread state, foreground browser notifications, and true background push. No profiling or third-party notification state is allowed.
9. Playwright covers Chromium/Firefox/WebKit, mobile widths, NIP-07 denial, slow NIP-46 approvals, offline/PWA update, and rollback from the next artifact to the previous one.
10. Two-operator runbook covers build, staged deploy, rollback, upstream update review, endpoint inventory diff, and compatibility-matrix refresh.

## Roadmap Implication

Adopt Flotilla in three bounded slices:

1. **Static fork and endpoint closure** — reproducible build, brand/platform variables, remove third parties/hosting/unsafe login, Caddy origin, CSP and zero-new-process proof.
2. **Pyramid authority acceptance** — NIP-29/42/signer live matrix, trap-relay routing tests, Blossom isolation, same-ID and reconnect cases.
3. **Town-square completion** — canonical public feed, NIP-50, notification semantics, and an explicit NIP-23 decision. Only after measured failure should the roadmap add Jumble as a separate feed client or build a custom UI.

Do not choose a custom client now. The verified gap is small enough to harden Flotilla, but large enough that an unmodified upstream deployment would violate the project's privacy, authority, and process-budget requirements.

## Primary Sources

- Flotilla: [repository](https://gitea.coracle.social/coracle/flotilla), [README/self-host/env](https://gitea.coracle.social/coracle/flotilla/src/tag/1.9.0/README.md), [package/build definition](https://gitea.coracle.social/coracle/flotilla/src/tag/1.9.0/package.json), [container](https://gitea.coracle.social/coracle/flotilla/src/tag/1.9.0/Dockerfile), [changelog](https://gitea.coracle.social/coracle/flotilla/src/tag/1.9.0/CHANGELOG.md).
- Nostrord: [repository](https://github.com/nostrord/nostrord), [README/builds](https://github.com/nostrord/nostrord/blob/d0f031685dcec3cc0119b152c56a59fe5f52f1f1/README.md), [production Pages workflow](https://github.com/nostrord/nostrord/blob/d0f031685dcec3cc0119b152c56a59fe5f52f1f1/.github/workflows/deploy-pages.yml), [CI](https://github.com/nostrord/nostrord/blob/d0f031685dcec3cc0119b152c56a59fe5f52f1f1/.github/workflows/ci.yml), [current correctness fix](https://github.com/nostrord/nostrord/commit/d0f031685dcec3cc0119b152c56a59fe5f52f1f1).
- Jumble: [repository](https://github.com/CodyTseng/jumble), [README/community mode](https://github.com/CodyTseng/jumble/blob/v26.7.2/README.md), [package/build definition](https://github.com/CodyTseng/jumble/blob/v26.7.2/package.json), [container](https://github.com/CodyTseng/jumble/blob/v26.7.2/Dockerfile), [Compose topology](https://github.com/CodyTseng/jumble/blob/v26.7.2/docker-compose.yml), [release workflow](https://github.com/CodyTseng/jumble/blob/v26.7.2/.github/workflows/electron-release.yml).
- Amethyst: [repository](https://github.com/vitorpamplona/amethyst), [README/NIP inventory/builds](https://github.com/vitorpamplona/amethyst/blob/1f4d9728be9b29105d40ca4cc4b9b771b123e877/README.md), [CI](https://github.com/vitorpamplona/amethyst/blob/1f4d9728be9b29105d40ca4cc4b9b771b123e877/.github/workflows/build.yml), [maintainer release QA](https://github.com/vitorpamplona/amethyst/blob/1f4d9728be9b29105d40ca4cc4b9b771b123e877/amethyst/plans/2026-07-20-v1.13.0-release-qa.md).
