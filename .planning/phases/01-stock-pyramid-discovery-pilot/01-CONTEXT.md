# Phase 1: Stock Pyramid Discovery Pilot - Context

**Gathered:** 2026-07-31
**Status:** Ready for planning

<domain>
## Phase Boundary

Deploy an exact current, source-unmodified upstream Pyramid build at `niten.sovereignengineering.io` behind the minimum safe operating envelope. Let the allowlisted Sovereign Engineering alumni roster use stock Pyramid through existing clients and member-controlled signers. Capture executable behavior, failures, operations evidence, and participant feedback, then make a hard proceed, revise, replace, or stop decision. Hosted clients, standalone Blossom, federation, curation, companion APIs, Pyramid source patches, and Napplet/headless-applet work are not part of this phase.

</domain>

<decisions>
## Implementation Decisions

### Relay Visibility and Identity
- **D-01:** Expose a public HTTPS/WSS origin at `niten.sovereignengineering.io`.
- **D-02:** Anonymous users may read explicitly public content. Publishing is restricted to allowlisted alumni, and restricted groups require authorization.
- **D-03:** Pyramid and operator administration remain privately restricted even though the relay origin is public.
- **D-04:** Quietly list the relay in common relay directories without broader promotion.
- **D-05:** Public relay metadata identifies it as “Niten by Sovereign Engineering,” clearly labels it experimental, and includes concise operator contact, publishing rules, and operator-readable/non-E2EE privacy language.

### Alumni Roster and Joining
- **D-06:** Use the user-supplied Nostr alumni roster event as the source for a one-time pilot-start allowlist snapshot. The event identifier and extracted pubkeys are private operational inputs and must not be committed to Git or GitHub.
- **D-07:** Send one shared Niten link to the full snapshotted roster. Participation is voluntary; measure actual uptake rather than imposing a participant target or staged waves.
- **D-08:** Later roster changes require an operator-reviewed manual refresh. Do not periodically or continuously synchronize the source event during Phase 1.
- **D-09:** An allowlisted alumnus authenticates with the existing key and onboards immediately. No individual invitation or operator approval queue is intended.

### Client, Signer, and Identity Coverage
- **D-10:** Nostrord and Flotilla are required for NIP-29 group coverage. Jumble is required only for public-feed and publishing flows it actually supports. Other clients provide opportunistic evidence.
- **D-11:** Phase 1 requires one proven path for each signer family: nos2x Chromium, nos2x Firefox, Amber/NIP-55, one iOS NIP-46 signer, and one member-chosen bunker flow. The full target-client × signer cross-product belongs to Phase 3.
- **D-12:** Alumni use real existing identities for normal workflows. Operators use disposable identities for denial, removal, ban, role-change, and destructive tests.
- **D-13:** Discovery continues despite client, signer, privacy, or authorization failures. Record the failure and isolate the affected client/group/action where possible; stop the entire pilot only when the host itself is unsafe.

### Stock Link and Quickstart
- **D-14:** The shared URL opens the stock Niten/Pyramid instance. Phase 1 does not build a custom portal or client chooser.
- **D-15:** The accompanying invitation is a concise quickstart covering experimental status, URL, allowlist eligibility, job-based client/signer guidance, privacy warning, and reporting paths.
- **D-16:** Recommend Flotilla for general community use, Nostrord for focused NIP-29/group testing, and Jumble only for supported public-feed flows.
- **D-17:** Alumni may self-troubleshoot and switch to a documented alternate path. Reports should identify client/version, signer, attempted flow, and error. Never ask anyone to paste, transmit, or expose an `nsec`.

### Content, Privacy, and Transition
- **D-18:** Pilot content is real but provisional. Encourage normal public conversation and preserve it when feasible, while warning that Pyramid-local groups, metadata, and test content may be reset during redeployment.
- **D-19:** Ordinary confidential conversation is allowed in access-controlled groups only after a clear warning that NIP-29 access control is operator-readable, not end-to-end encrypted, and under active compatibility testing.
- **D-20:** If Pyramid is revised, replaced, or redeployed, provide advance notice and make a best-effort migration/export of standard signed events and membership/group configuration before retiring old state.
- **D-21:** Phase 1 has no calendar-duration or participant-count minimum. The decision gate opens when every required stock flow and signer-family path has an observed pass/fail result.

### Failure Disclosure
- **D-22:** After rapid confirmation of a privacy or authorization failure, notify directly affected alumni. Post a cohort bulletin when impact may be systemic; do not wait for full root-cause analysis or a fix.
- **D-23:** Isolate only the affected client, group, or action where possible while unrelated discovery continues.
- **D-24:** Every failure notice is concise and redacted: time, affected scope, possible impact, containment, user action, and next update. Never include private event bodies or signer material.

### Feedback, Operations, and Repository
- **D-25:** Collect feedback through a dedicated Niten pilot group, a private operator channel for sensitive reports, and GitHub issues for non-sensitive actionable defects.
- **D-26:** Use a concise report template: client/version, signer, action, expected result, actual result, and timestamp. Mirror these fields in GitHub issue templates.
- **D-27:** Feedback is shared by default. Privacy and security reports remain private until safely redacted. GitHub never receives private events, alumni roster data, signer material, bunker details, credentials, or live secrets.
- **D-28:** Post concise restart, failure, and configuration-change notices to both a Niten announcement group and the existing out-of-band alumni channel.
- **D-29:** Continuous pilot changes are allowed, with concise notice before and after disruptive work.
- **D-30:** Use `https://github.com/jodobear/niten` as the single canonical repository for deployment code, configuration templates, runbooks, redacted evidence, issues, and pull requests. — **Reversibility:** costly — changing the repository later requires remote migration and updating issue, PR, automation, and documentation links.

### the agent's Discretion
- Select the exact current upstream Pyramid pin after re-auditing it against the researched baseline.
- Choose the minimum source-unmodified build/package method, systemd hardening, Caddy routing, private operator-access mechanism, backup implementation, rollback layout, and redacted evidence format that satisfy PILOT-01 through PILOT-08.
- Define the detailed order of stock-flow tests and compatible pairing used to prove each required signer family.
- Choose concise wording and formatting for quickstart, relay metadata, issue templates, incident notices, and operational notices while preserving the decisions above.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Scope and Phase Contract
- `.planning/PROJECT.md` — Project value, stock-Pyramid-first implementation decision, BYOK boundary, companion-service deferral, and project exclusions.
- `.planning/REQUIREMENTS.md` — PILOT-01 through PILOT-08 and DOC-01 acceptance requirements; later client-matrix requirements remain out of Phase 1.
- `.planning/ROADMAP.md` — Phase 1 goal, dependency boundary, required success criteria, and hard next-milestone gate.
- `.planning/STATE.md` — Current phase position and known execution inputs/blockers.

### Research Baseline
- `.planning/research/SUMMARY.md` — Implementation sequencing decision, researched Pyramid baseline, known stock limitations, and distinction between discovery and production topology.

### Captured Later Work
- `.planning/todos/pending/2026-07-31-test-full-client-signer-compatibility-matrix.md` — Full client × signer cross-product explicitly deferred from Phase 1 to the later core-community phase.

### Canonical Remote
- `https://github.com/jodobear/niten` — User-selected single repository for code, redacted evidence, issues, and pull requests.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- No runtime or deployment code exists yet; the repository currently contains GSD planning and research artifacts only.
- The retained Pyramid, client, signer, service-boundary, and UI research provides evidence and test targets without becoming implementation code.

### Established Patterns
- GSD planning artifacts and narrow atomic commits are already established.
- Runtime state, alumni rosters, private events, signer material, credentials, and live secrets must remain outside committed artifacts.
- Stock Pyramid must remain source-unmodified during Phase 1; safeguards belong in deployment configuration and the host envelope.

### Integration Points
- Current upstream `fiatjaf/pyramid` source/release selected during phase research.
- DNS/TLS for `niten.sovereignengineering.io`.
- Caddy public ingress and privately restricted operator administration.
- Existing Nostrord, Flotilla, and Jumble clients with member-controlled NIP-07/46/55 signers.
- GitHub repository `jodobear/niten` for issues, PRs, and redacted evidence.

</code_context>

<specifics>
## Specific Ideas

- “Niten by Sovereign Engineering” is the pilot identity.
- A single shared Niten URL goes to the entire snapshotted alumni roster; whoever joins becomes the observed cohort.
- The stock instance is itself the entry point. Keep all invitations, incident notices, issue templates, and change notices concise.
- Discovery optimizes for learning: failures remain evidence and do not halt unrelated testing.

</specifics>

<deferred>
## Deferred Ideas

- Full target-client × signer cross-product — Phase 3; captured as a major todo.
- Standalone Blossom, hosted community UI, public-event aggregation, curation, companion APIs, and Pyramid source patches — blocked until the Phase 1 decision gate.
- Napplet/Kehto and hosted headless community applets — outside this project; require a separate future project if pursued.

</deferred>

---

*Phase: 1-stock-pyramid-discovery-pilot*
*Context gathered: 2026-07-31*
