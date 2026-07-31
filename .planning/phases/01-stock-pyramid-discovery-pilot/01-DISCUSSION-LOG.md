# Phase 1: Stock Pyramid Discovery Pilot - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-31
**Phase:** 1-stock-pyramid-discovery-pilot
**Areas discussed:** Relay visibility, Testing cohort, Client and signer coverage, Data and exit gate, Failure disclosure, Shared-link onboarding, Feedback channel, Operating cadence

---

## Relay Visibility

| Question | Options considered | Selected |
|----------|--------------------|----------|
| Relay exposure | Public WSS with scoped access; public WSS member-only; private network only | Public WSS with anonymous public reads, allowlisted publishing, authorized restricted groups, and private administration |
| Hostname | `relay-pilot.sovereignengineering.io`; `dialogos.sovereignengineering.io`; `pyramid.sovereignengineering.io`; freeform | `niten.sovereignengineering.io` |
| Pilot discovery | Unlisted; quiet public listing; fully announced | Quiet public listing without broad promotion |
| Relay metadata | Explicit SE pilot; minimal technical listing; product-like identity | “Niten by Sovereign Engineering,” explicitly experimental, with contact, rules, and privacy warning |

**User's choice:** Public but scoped Niten pilot with quiet directory discovery.
**Notes:** Administration remains privately restricted. The pilot must not be presented as stable production.

---

## Testing Cohort

| Question | Options considered | Selected |
|----------|--------------------|----------|
| Cohort size | 5–8; 2–4; 9–15; freeform | Entire user-supplied alumni roster, with voluntary participation |
| Rollout | Fast staged; two waves; all immediately; freeform | Whitelist the roster snapshot, send one shared link, and let any number join |
| Roster updates | Snapshot/manual refresh; periodic refresh; live authority | Snapshot at pilot start; operator-reviewed manual refresh only |
| Join flow | Immediate self-onboarding; individual invitations; approval after login | Immediate authentication and onboarding for allowlisted keys |

**User's choice:** Invite the full roster at once and observe natural uptake.
**Notes:** The supplied Nostr roster event and extracted alumni pubkeys stay outside committed artifacts.

---

## Client and Signer Coverage

| Question | Options considered | Selected |
|----------|--------------------|----------|
| Client commitment | Tiered; equal across three clients; bring any client | Tiered: Nostrord/Flotilla for groups, Jumble for supported public flows, other clients opportunistic |
| Signer commitment | One path per signer family; full cross-product; participant-driven only | One proven path for nos2x Chromium, nos2x Firefox, Amber/NIP-55, iOS NIP-46, and bunker signing |
| Test identities | Mixed real/disposable; real only; disposable only | Real alumni identities for normal use; disposable operator identities for destructive and denial tests |
| Failure policy | Severity-based stop; any required failure blocks; discovery never blocks | Continue discovery through client/signer/privacy/authorization failures; stop the whole pilot only when the host is unsafe |

**User's choice:** Small required compatibility slice now; full cross-product later.
**Notes:** Full cross-product captured as the major todo “Test full client-signer compatibility matrix.” Narrowly affected workflows may be isolated while unrelated testing continues.

---

## Data and Exit Gate

| Question | Options considered | Selected |
|----------|--------------------|----------|
| Content lifetime | Real but provisional; disposable sandbox; production-grade persistence | Real but provisional |
| Restricted-group content | Non-sensitive only; normal private conversation; synthetic test messages only | Ordinary confidential conversation after explicit operator-readable/non-E2EE/testing warning |
| Replacement transition | Notice and best-effort migration; freeze read-only; clean reset | Notice and best-effort export/migration before retiring old state |
| Exit gate | Evidence plus 14 days; evidence only; 30-day discovery | Evidence only; no duration or participant-count minimum |

**User's choice:** Treat conversation as real but retain freedom to redeploy after warning and best-effort migration.
**Notes:** The decision gate opens after every required flow has an observed pass/fail result.

---

## Failure Disclosure

| Question | Options considered | Selected |
|----------|--------------------|----------|
| Audience | Affected users plus cohort bulletin; affected only; whole cohort always | Affected users directly, plus cohort notice when impact may be systemic |
| Timing | After rapid confirmation; at first suspicion; after diagnosis | After rapid confirmation, before root cause or fix is complete |
| Containment | Isolate narrow path; leave available with warning; freeze all writes | Isolate the affected client/group/action while unrelated discovery continues |
| Notice content | Redacted incident record; brief warning only; full technical disclosure | Always-concise redacted record with time, scope, impact, containment, user action, and next update |

**User's choice:** Fast, concise, scoped disclosure and containment.
**Notes:** Private event bodies and signer material never enter notices.

---

## Shared-Link Onboarding

| Question | Options considered | Selected |
|----------|--------------------|----------|
| Link destination | Stock instance; client chooser; primary-client deep link | Stock Niten instance |
| Invitation guidance | Concise quickstart; detailed technical guide; link only | Concise quickstart |
| Client recommendation | Job-based; Flotilla first; Nostrord first | Job-based: Flotilla general use, Nostrord NIP-29 testing, Jumble supported public flows |
| Failure fallback | Report then alternate; remain on failure; self-troubleshoot | Alumni may self-troubleshoot, report exact evidence, and switch to a documented alternate |

**User's choice:** Direct stock experience with concise, job-based guidance.
**Notes:** No custom portal. Never request or share an `nsec`.

---

## Feedback Channel

| Question | Options considered | Selected |
|----------|--------------------|----------|
| Primary paths | Niten group plus private channel; private only; external tracker only | Niten pilot group, private operator channel, and GitHub issues |
| Report format | Concise template; freeform; live debugging only | Concise client/version/signer/action/expected/actual/timestamp template, including GitHub issue template |
| Visibility | Shared by default with sensitive private; everything private; everything cohort-visible | Shared by default; privacy/security reports private until safely redacted |

**User's choice:** Community-visible learning plus private handling of sensitive reports and GitHub tracking of safe actionable defects.
**Notes:** GitHub excludes private events, alumni roster data, signer/bunker material, credentials, and live secrets.

---

## Operating Cadence

| Question | Options considered | Selected |
|----------|--------------------|----------|
| Notice channels | Niten plus out-of-band alumni channel; Niten only; out-of-band only | Both Niten announcements and existing out-of-band alumni channel |
| Change cadence | Continuous with notices; daily window; weekly window | Continuous changes with concise before/after notice for disruptive work |
| Repository | Current project renamed; separate pilot repo; defer; freeform | One canonical repository: `https://github.com/jodobear/niten` |

**User's choice:** Fast continuous operation, redundant notices, one repository for the whole project.
**Notes:** The repository holds deployment code, templates, runbooks, redacted evidence, issues, and pull requests.

## the agent's Discretion

- Exact current upstream Pyramid pin after re-audit.
- Source-unmodified build and packaging method.
- Caddy/systemd/private-admin/backup/rollback implementation details.
- Detailed test order and compatible pairing used for each signer-family proof.
- Concise wording and formatting of quickstarts, metadata, notices, and issue templates.

## Deferred Ideas

- Full target-client × signer compatibility cross-product — Phase 3; captured as a major todo.
- Standalone Blossom, hosted UI, federation, curation, companion APIs, and Pyramid source patches — await the Phase 1 decision gate.
- Napplet/Kehto and hosted headless applets — outside this project.
