# Phase 1: Stock Pyramid Discovery Pilot - Pattern Map

**Mapped:** 2026-07-31
**Repository state:** Greenfield deployment; planning and research only

## Valid source and deployment anchors

No runtime/deployment analog exists in this repository. Executors must use the current `01-RESEARCH.md` source audit, then revalidate fast-moving upstream pins and route inventory at execution. Planning excerpts are constraints, not proof of deployed behavior.

| File | Purpose | Primary anchor |
|---|---|---|
| `config/pyramid.lock` | Current canonical Pyramid repository/tag/full commit/artifact checksum and source-reproduction result | `01-RESEARCH.md` Standard Stack and Source Reproduction Contract |
| `deploy/caddy/Caddyfile` | Public HTTPS/WSS plus private admin origin and public privileged-route denial | `01-RESEARCH.md` Pattern 2 |
| `deploy/nftables/niten.nft` | Host-level dual-stack default-deny policy with public 80/443 only and private SSH/admin | ROADMAP Phase 1 criterion 2; D-01/D-03 |
| `deploy/systemd/pyramid.service` | Loopback, least-privilege, bounded stock Pyramid process | `01-RESEARCH.md` Pattern 3 |
| `deploy/systemd/niten-journal.conf` | Explicit journal bounds | `01-RESEARCH.md` Pattern 3 |
| `deploy/settings/settings.example.json` | Secret-free minimum settings and D-05 relay metadata | `01-RESEARCH.md` Pattern 4 |
| `scripts/verify-pyramid.sh` | Current-pin provenance and source-unmodified checks | `01-RESEARCH.md` Artifact Installation and Source Reproduction Contract |
| `scripts/local-stock-smoke.sh` | Disposable loopback NIP-11/WSS tracer | PILOT-01/PILOT-07/DOC-01 |
| `scripts/deploy-private-host.sh` | Private-first host bootstrap, firewall failsafe, internal CA trust, effective-settings review | `01-RESEARCH.md` Patterns 2-4 |
| `scripts/backup.sh` | Quiesced off-host restic backup and check | `01-RESEARCH.md` Backup/Restore/Discard Contract |
| `scripts/restore-drill.sh` | Blank restore, rollback, discard/redeploy rehearsal | `01-RESEARCH.md` Backup/Restore/Discard Contract |
| `scripts/verify-public-boundary.sh` | Dual-vantage route checks and all-address IPv4/IPv6 external exposure scan | D-01/D-03; Phase 1 host-safety gate |
| `scripts/import-roster.sh` | Private one-time roster validation, allow, and reconciliation | D-06/D-08/D-09; `01-RESEARCH.md` Pattern 5 |
| `scripts/repo-preflight.sh` | Small tracked/staged high-confidence leak and exact-private-path check | D-24/D-27 |
| `docs/private-journal.md` | Outside-Git journal layout, fields, retention, and redaction procedure | DOC-01 |
| `docs/pilot-test-matrix.md` | Plain Markdown test-case checklist and required columns | PILOT-05/PILOT-06/D-21 |
| `docs/pilot-review.md` | Manual completeness review and hard verdict criteria | PILOT-08 |

## Deployment patterns

### Exact stock subject

- Audit canonical `fiatjaf/pyramid` releases and selected source at execution.
- Record repository, tag, full commit, artifact size/checksum, source archive checksum, toolchain/runtime versions, clean-tree proof, and independent source-build result.
- Install immutable artifact directories and select with an atomic `current` symlink.
- Never use mutable `master`, `easy.sh`, or a local Pyramid patch as the discovery subject.

### Private-first two-origin boundary

- Pyramid binds `127.0.0.1:3334`; Caddy is sole public listener.
- Public origin is `niten.sovereignengineering.io`; public routes support NIP-11, WSS, stock public surface, and anonymous explicitly-public reads.
- Private origin binds only the approved private mesh interface and is trusted on an isolated operator device with out-of-band CA fingerprint comparison.
- Generate public privileged-route denial from the execution-selected source. Denial precedes reverse proxy; public NIP-86 management POST is denied.
- Keep public DNS/ingress disabled until backup, rollback, route, firewall, and external-scan gates pass.

### Lockout-safe host firewall

- Reconcile every routable interface, assigned/provider public IPv4 and IPv6 address including secondary addresses, and every A/AAAA answer before apply.
- Render one complete `inet` policy: loopback and established traffic preserved; input/forward default denied; public TCP 80/443 permitted; public 22/admin denied; SSH/admin allowed only on validated private interface/address inputs.
- Preserve an independent recovery session and arm timed rollback before apply. Persist only after both sessions, both address families, reboot, and fresh inventory pass.
- Keep rendered addresses, interface names, prior/live rulesets, mesh details, and raw scans outside Git.
- Before target work, select and authorize protected target-independent IPv4 and IPv6 external runners with TCP 1-65535 authority, private source identity/tool/route evidence, reachability preflight, and expiry. Revalidate this handoff before cutover; one off-host host may cover both only with independently proven routes.

### Least-privilege stock process

- Dedicated `pyramid` user; `0700` state directories; `UMask=0077`; `0600` settings and management files.
- Strict writable paths, empty capability set, no automatic updates, no SFTP.
- Enable only groups and search needed by pilot. Disable unrelated stock modules and risky egress features.
- Bound journald and Caddy logs; retain exact target values and effective checks in private journal.

### Immutable artifact, coherent mutable generation

- Stop Pyramid before authoritative backup.
- Snapshot matching state, protected settings reference, artifact manifest, membership/search state, and component versions to encrypted off-host restic.
- Restore only into a blank marked non-live target; prove protocol behavior before calling backup recoverable.
- Preserve failed generation before rollback; never run older binary against mutable newer state in place.
- Rehearse export, public-ingress revocation, discard, and exact-lock redeploy before cohort use.

## Private evidence patterns

### Journal first

Before any provenance, audit, build, tracer, or host command, create the dated private journal tree outside the worktree with restrictive permissions and append the initial run entry. Store raw captures beside the dated Markdown log. No custom parser reads or validates this journal.

Minimum entries: UTC, operator role, command purpose/result, decisions, failures/fixes, diagrams, costs, exact component/build facts, effective-settings review, test case ID, expected/actual, private capture pointer, restore/rollback evidence, incidents, feedback, upstream notes, and verdict impact. Never store signer private keys or connection secrets anywhere.

### Repository-safe formats

Repository contains only concise Markdown templates, checklists, runbooks, public pins, and redacted summaries. No participant rows, fake identities, live addresses, raw logs/events, roster values, private group identifiers, signer/bunker material, cookies, credentials, or private journal paths.

`scripts/repo-preflight.sh` may inspect tracked/staged files for high-confidence secret shapes and exact protected path/address values supplied at runtime. It must not parse the private journal, judge test completeness, or become general evidence tooling.

### Human completeness

- `docs/pilot-test-matrix.md` defines required rows and columns. Operators fill a private copy during testing.
- Exact client and signer product/version/build are observed in the same live session as each result. S5 remains member-chosen until then.
- Ordinary stock/signer/destination rows end with pass/fail or same-session exact-build supported-client-gap evidence. Each mandatory operational gate has a private-journal pointer.
- Every retained NIP-86 `INTEGRATE` case is invoked and receives observed pass/fail. A genuinely non-invokable method becomes reasoned `OPT-OUT` only after operator amendment, immutable upstream/source evidence, and private decision; it remains non-invoked. Generic client-gap text cannot close this lane.
- `docs/pilot-review.md` is manually reconciled against private journal and redacted summaries. No generic readiness program decides the verdict.

### Consent before roster access

- Prepare identity-free membership/privacy disclosure before cohort work.
- Before reading, extracting, or importing the roster source—or mutating stock membership—send exact disclosure through existing out-of-band channel and retain explicit consent privately for every affected participant.
- Import only consenting subset. Decline/non-response is excluded without penalty. No viable consenting cohort stops/revises before roster access or mutation; identities and consent records never enter Git.

## Failure handling

- Host-unsafe conditions disable public ingress immediately.
- Client, signer, group, privacy, or authorization failures are recorded and isolated narrowly when possible; unrelated discovery continues per D-13/D-23.
- Notify directly affected alumni rapidly; use cohort bulletin for possible systemic impact. Notices contain only time, scope, possible impact, containment, user action, and next update.
- A directory submission is incomplete until the relay is observed in at least one common directory. Pending/error is a gap.

## Scope fence

Phase 1 contains stock Pyramid, Caddy, systemd, nftables, restic, existing clients/signers, private journal, and concise runbooks/templates only. It contains no hosted UI, Blossom, federation, aggregation, curation, companion API, Pyramid patch, or Napplet/headless-applet architecture.
