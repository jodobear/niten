---
phase: 01-stock-pyramid-discovery-pilot
plan: 01
subsystem: supply-chain-and-protocol-discovery
tags: [pyramid, nip-11, nip-86, websocket, provenance, privacy]
requires: []
provides:
  - Exact execution-current stock Pyramid release and source provenance lock
  - Protected private-journal procedure and repository leak boundary
  - Disposable loopback stock Pyramid NIP-11 and WebSocket tracer
  - Reviewed official/source/runtime NIP-86 coverage table
affects: [01-02-host-authorization, 01-03-private-deployment, 01-07-live-observation]
tech-stack:
  added: [shellcheck, curl, jq, node-websocket, podman]
  patterns: [journal-before-command, immutable-public-pin, disposable-marked-state, value-free-leak-diagnostics]
key-files:
  created:
    - .gitignore
    - docs/private-journal.md
    - config/pyramid.lock
    - scripts/verify-pyramid.sh
    - scripts/local-stock-smoke.sh
    - scripts/repo-preflight.sh
  modified:
    - .planning/phases/01-stock-pyramid-discovery-pilot/COVERAGE.md
key-decisions:
  - "Retain stock Pyramid v1.3.2 at the exact official release commit and verified amd64 digest."
  - "Treat the independently reproduced checksum difference as provenance evidence; never substitute the local build for the official asset."
  - "Keep exact-stock local transport as loopback WS; TLS/WSS belongs to the later Caddy envelope and no companion proxy enters this tracer."
  - "INTEGRATE every callable selected-pin NIP-86 method and keep official but unregistered methods as reasoned non-invoked OPT-OUT rows."
patterns-established:
  - "Private evidence precedes all audit/build/tracer commands and stays outside Git under restrictive modes."
  - "Public lock values are verified independently; mutable installers, dirty source, and mismatched artifacts fail closed."
  - "Repository privacy checks report only file and rule names, never matched values."
requirements-completed: [PILOT-01, PILOT-07, DOC-01]
coverage:
  - id: D1
    description: "Exact current stock Pyramid provenance lock and disposable local protocol tracer"
    requirement: PILOT-01
    verification:
      - kind: integration
        ref: "./scripts/verify-pyramid.sh --self-test and --audit-current"
        status: pass
      - kind: e2e
        ref: "timeout 60 ./scripts/local-stock-smoke.sh --self-test"
        status: pass
    human_judgment: false
  - id: D2
    description: "Private journal chronology, retention, redaction, restore, incident, feedback, and upstream-note procedure"
    requirement: DOC-01
    verification:
      - kind: manual_procedural
        ref: "private chronology, permission, capture, and cleanup acceptance checks"
        status: pass
    human_judgment: true
    rationale: "Private operational evidence must be reviewed without copying protected contents into repository artifacts."
  - id: D3
    description: "Current official/source/runtime NIP-86 coverage with concrete integration cases and reasoned opt-outs"
    requirement: PILOT-07
    verification:
      - kind: integration
        ref: "authenticated selected-pin supportedmethods comparison against official NIP-86 and source registrations"
        status: pass
    human_judgment: true
    rationale: "Disposition quality and non-invocation of opt-outs require operator review at the final evidence gate."
  - id: D4
    description: "Tracked and staged repository privacy preflight with value-free diagnostics"
    requirement: DOC-01
    verification:
      - kind: integration
        ref: "./scripts/repo-preflight.sh --self-test and --tracked --staged"
        status: pass
    human_judgment: false
duration: 37 min
completed: 2026-07-31
status: complete
---

# Phase 1 Plan 1: Stock Pyramid Discovery Foundation Summary

**Exact stock Pyramid v1.3.2 provenance, protected day-one evidence, disposable loopback protocol proof, and current NIP-86 coverage**

## Performance

- **Duration:** 37 min
- **Started:** 2026-07-31T11:32:31Z
- **Completed:** 2026-07-31T12:09:19Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Revalidated the current canonical Pyramid release, exact tag/commit, official amd64 size/digest, source archive digest, and build toolchain; independently reproduced the clean tag and retained its checksum difference as an observation.
- Proved the verified source-unmodified binary starts on loopback, returns NIP-11 and REQ/EOSE, exposes no wildcard listener, and removes its marked disposable process/state on exit.
- Reconciled current official NIP-86, selected-source registrations, and authenticated runtime `supportedmethods`: 20 callable methods map to concrete cases; 5 unregistered official methods remain reasoned non-invoked opt-outs.
- Added a narrow tracked/staged preflight whose self-tests detect seeded secret/protected values, tolerate harmless documentation terminology, and never print matched values.

## Task Commits

Each task was committed atomically:

1. **Task 1: Trace current exact stock Pyramid from private journal to local protocol result** - `b3e8a98` (feat)
2. **Task 2: Record simple current NIP-86 coverage and repository privacy preflight** - `eab95fa` (feat)

## Files Created/Modified

- `.gitignore` - Narrow operator-local private-root ignores without the protected runtime value.
- `docs/private-journal.md` - Journal-first layout, fields, retention, redaction, incident, restore, feedback, and upstream-note rules.
- `config/pyramid.lock` - Current canonical release, commit, artifact/source sizes and SHA-256 values, and toolchain pins.
- `scripts/verify-pyramid.sh` - Fail-closed lock, artifact, source, and execution-current upstream verifier.
- `scripts/local-stock-smoke.sh` - Verified-asset disposable loopback NIP-11 and WebSocket tracer with cleanup.
- `scripts/repo-preflight.sh` - Narrow tracked/staged secret-shape and exact protected-value scanner.
- `.planning/phases/01-stock-pyramid-discovery-pilot/COVERAGE.md` - Reviewed current NIP-86 integration and opt-out table.

## Decisions Made

- Selected official Pyramid `v1.3.2` at the locked full commit because it remains the current canonical release.
- Kept the official release binary as the discovery subject after the clean independent reproduction produced a different checksum; checksum equality was never assumed or used to authorize substitution.
- Exercised stock loopback WS rather than adding a TLS proxy solely to manufacture local WSS; later Caddy work owns HTTPS/WSS while this tracer remains source-unmodified and companion-free.
- Classified only runtime-callable NIP-86 methods as `INTEGRATE`; official methods absent from selected runtime registration are explicit non-invoked `OPT-OUT` rows.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Preserved exact-stock boundary when local WSS contradicted upstream behavior**
- **Found during:** Task 1
- **Issue:** Selected stock source deliberately uses `ws://` for localhost and provides no local TLS listener; adding a proxy would violate the companion-free tracer constraint.
- **Fix:** Proved the exact stock WebSocket protocol path on loopback and assigned TLS/WSS to the planned Caddy envelope.
- **Files modified:** `scripts/local-stock-smoke.sh`
- **Verification:** NIP-11, REQ/EOSE, loopback-only listener, and cleanup gate passed.
- **Committed in:** `b3e8a98`

**2. [Rule 3 - Blocking] Used rootless Podman after local Docker frontend lacked a daemon**
- **Found during:** Task 1 source reproduction
- **Issue:** Installed Docker CLI/build plugin could not connect to a Docker API.
- **Fix:** Executed the same selected upstream Node/Go/musl build inputs in rootless Podman and retained exact toolchain/dependency/checksum evidence privately.
- **Files modified:** None; private build evidence only.
- **Verification:** Clean exact tag built with embedded `v1.3.2` and Go 1.26.2; comparison completed.
- **Committed in:** `b3e8a98` (task outcome)

**3. [Rule 1 - Bug] Normalized canonical Git remote suffix in source verification**
- **Found during:** Task 1 acceptance
- **Issue:** Git's conventional `.git` suffix caused a false repository mismatch against the canonical browser URL.
- **Fix:** Normalize only the optional terminal `.git` suffix before exact canonical comparison.
- **Files modified:** `scripts/verify-pyramid.sh`
- **Verification:** Exact tag/commit/clean-tree verification and current upstream audit passed.
- **Committed in:** `b3e8a98`

**4. [Rule 1 - Bug] Prevented bare documentation terminology from matching signer URI rule**
- **Found during:** Task 2 tracked-content acceptance
- **Issue:** A bare documented `nostrconnect://` token matched the initial signer-connection expression despite containing no connection material.
- **Fix:** Require a 64-hex identity and query component before reporting a signer connection URI.
- **Files modified:** `scripts/repo-preflight.sh`
- **Verification:** Harmless tracked prose passes; seeded full sensitive shapes still fail without exposing values.
- **Committed in:** `eab95fa`

---

**Total deviations:** 4 auto-fixed (3 Rule 1 bugs, 1 Rule 3 blocker).
**Impact on plan:** All fixes preserved the stock, privacy, and reproducibility boundaries. No product or companion service entered scope.

## Issues Encountered

- Upstream release workflow metadata and source requirements were not assumed consistent; exact embedded release metadata and independent toolchain results were measured.
- The reproduced binary checksum differed from the official release checksum. This remains a retained provenance observation, not a failure and not permission to substitute artifacts.

## Private Journal Gate

Operator-approved durable private journal precondition passed before provenance, network, build, or tracer actions. No protected path, journal content, raw capture, signer material, roster data, private event, live address, or credential entered Git.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for `01-02-PLAN.md` host-input authorization using the exact public Pyramid lock and journal-first pattern.
- Fresh VPS/provider, private-mesh, DNS, backup, recovery, and independent scanner inputs remain Plan 01-02 gates; none were inferred here.

## Self-Check: PASSED

- All seven created/modified plan artifacts exist.
- Task commits `b3e8a98` and `eab95fa` exist with no accidental deletions.
- Full automated verification, fresh official-pin audit, stock loopback tracer, NIP-86 comparison, and tracked/staged privacy preflight passed.
- No known stubs, skipped tests, unrun automated verifications, or untracked generated files remain.

---
*Phase: 01-stock-pyramid-discovery-pilot*
*Completed: 2026-07-31*
