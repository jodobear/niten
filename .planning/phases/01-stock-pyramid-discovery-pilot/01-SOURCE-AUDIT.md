# Phase 1 Multi-Source Coverage Audit

## Goal, requirements, research, and context

| Source | ID | Item | Plan(s) | Status | Notes |
|---|---|---|---|---|---|
| GOAL | — | Named alumni cohort safely exercises exact current source-unmodified stock Pyramid through existing clients/member signers and produces hard-decision evidence | 01-01–01-09 | COVERED | Tracer, authorized target, private deployment, recovery/public boundary, consent, roster/onboarding, live testing, human verdict, enactment. |
| REQ | PILOT-01 | Exact upstream pin/source/build/runtime/effective configuration, source unmodified | 01-01, 01-03 | COVERED | Execution-time revalidation, independent source build, private live settings plus redacted hash/review. |
| REQ | PILOT-02 | Caddy/TLS, loopback systemd, least privilege, bounded logs, backup, rollback | 01-02–01-04 | COVERED | Authorized target, lockout-safe dual-stack host, blank restore and rollback. |
| REQ | PILOT-03 | Public protocol/private admin boundary | 01-02–01-04 | COVERED | Private origin/trust, pin-derived route denial, authorized target-independent all-address scans. |
| REQ | PILOT-04 | Named cohort, existing clients, NIP-07/46/55, no key custody | 01-05–01-07 | COVERED | Exact disclosure before roster access, private per-member consent, consenting-subset import, five signer-family paths. |
| REQ | PILOT-05 | Membership/invitations/groups/roles/NIP-42/NIP-50/content/delete/reconnect/reject/error | 01-06, 01-07 | COVERED | Plain complete case checklist plus live observations. |
| REQ | PILOT-06 | Exact pass/fail, destinations, operations, feedback, five categories | 01-06–01-08 | COVERED | Private filled checklist/raw captures; redacted aggregates; manual review. |
| REQ | PILOT-07 | No companion product/service or Pyramid patch dependency | 01-01, 01-06, 01-09 | COVERED | Scope fences carried through tracer, docs, and outcome. |
| REQ | PILOT-08 | Evidence-selected milestone and disposable/portable exit | 01-04, 01-06, 01-08, 01-09 | COVERED | Recovery/discard rehearsal, manual verdict, selected branch enactment. |
| REQ | DOC-01 | Private build journal from day one | 01-01, 01-06–01-09 | COVERED | Journal exists before first audit; all live/review/exit work appended privately. |
| RESEARCH | R-01 | Re-audit researched Pyramid baseline; exact provenance/source reproduction | 01-01, 01-03 | COVERED | Pin may move; no silent substitution. |
| RESEARCH | R-02 | Two-origin Caddy, pin-derived public denial, mesh-only admin | 01-03, 01-04 | COVERED | Private trust lifecycle and two-vantage route checks. |
| RESEARCH | R-03 | Hardened process, 0700/0600 state, UMask, bounded logs | 01-03 | COVERED | Exact service/log thresholds plus installed-target systemd verify/security score gate. |
| RESEARCH | R-04 | Minimum settings; groups/search; risky/unrelated modules and auto-update disabled | 01-03 | COVERED | Protected live comparison, hash, operator review. |
| RESEARCH | R-05 | Private one-time roster through NIP-86, counts/status only, manual refresh | 01-05, 01-06 | COVERED | Exact prior disclosure/private consent, consenting-subset import, no timer/daemon. |
| RESEARCH | R-06 | One S1-S5 signer-family path; exact live-time client/signer builds | 01-06, 01-07 | COVERED | S5 selected during session; client/signer platforms may differ. |
| RESEARCH | R-07 | Stock-flow ordering, negative controls, destination traps | 01-06, 01-07 | COVERED | Harmless traps and disposable destructive identities. |
| RESEARCH | R-08 | Private journal plus plain Markdown checklist/redacted summaries | 01-01, 01-06–01-09 | COVERED | No reusable evidence product; human completeness review. |
| RESEARCH | R-09 | Quiesced generation backup, restic check, blank restore, rollback, discard | 01-04 | COVERED | Snapshot existence cannot pass. |
| RESEARCH | R-10 | Stock admin cookie/CDN risk and dedicated pilot identity/profile | 01-03, 01-05 | COVERED | Technical private boundary plus consent checkpoint. |
| RESEARCH | R-11 | Hard PROCEED/REVISE/REPLACE/STOP decision; missing observation blocks | 01-06–01-09 | COVERED | Manual review and branch enactment. |
| RESEARCH | R-12 | No new npm/PyPI/crates dependency; canonical release legitimacy | 01-01, 01-03 | COVERED | Canonical checksum/source audit only. |
| CONTEXT | D-01 | Public HTTPS/WSS `niten.sovereignengineering.io` | 01-03, 01-04 | COVERED | Public 80/443 only after full boundary pass. |
| CONTEXT | D-02 | Anonymous public read; allowlisted publish; restricted-group authorization | 01-03, 01-06, 01-07 | COVERED | Settings, roster negative controls, live cases. |
| CONTEXT | D-03 | Pyramid/operator administration private | 01-02–01-04 | COVERED | Mesh origin, private trust, public route/port denial. |
| CONTEXT | D-04 | Quiet common-directory listing | 01-06 | COVERED | Verified presence required; pending/error is gap. |
| CONTEXT | D-05 | Niten identity, experimental/contact/rules/privacy metadata | 01-03, 01-06 | COVERED | Effective settings and listing/quickstart. |
| CONTEXT | D-06 | Private one-time roster event/snapshot, never Git | 01-05, 01-06 | COVERED | Disclosure/consent precedes protected consenting-subset import/reconciliation. |
| CONTEXT | D-07 | One link to full consenting snapshot; voluntary; actual uptake | 01-05–01-07 | COVERED | Decline/non-response excluded without penalty; no quota/waves/calendar minimum. |
| CONTEXT | D-08 | Later roster changes manual operator-reviewed only | 01-06 | COVERED | No recurring sync. |
| CONTEXT | D-09 | Existing-key immediate onboarding | 01-06, 01-07 | COVERED | Allowlisted write; no approval queue. |
| CONTEXT | D-10 | Nostrord/Flotilla groups; Jumble supported public flows | 01-06, 01-07 | COVERED | Explicit checklist and live run. |
| CONTEXT | D-11 | One path per signer family; full cross-product deferred | 01-06, 01-07 | COVERED | Five families, live-time S5, no full product. |
| CONTEXT | D-12 | Real normal identities; disposable destructive identities | 01-07 | COVERED | Explicit identity classes in procedure. |
| CONTEXT | D-13 | Continue on client failures; stop entire pilot only for unsafe host | 01-01, 01-07 | COVERED | Narrow containment versus ingress stop. |
| CONTEXT | D-14 | Stock link; no portal/chooser | 01-06 | COVERED | Quickstart only. |
| CONTEXT | D-15 | Concise quickstart fields | 01-06 | COVERED | Experimental/link/eligibility/jobs/privacy/reporting. |
| CONTEXT | D-16 | Flotilla/Nostrord/Jumble job guidance | 01-06 | COVERED | Exact recommended roles. |
| CONTEXT | D-17 | Alternate path/report fields/no `nsec` request | 01-06, 01-07 | COVERED | Docs and live signer safety. |
| CONTEXT | D-18 | Real provisional content/reset warning | 01-06, 01-07 | COVERED | Quickstart and transition evidence. |
| CONTEXT | D-19 | Confidential groups only after operator-readable/not-E2EE warning | 01-05, 01-06 | COVERED | Blocking consent and quickstart. |
| CONTEXT | D-20 | Advance notice and best-effort export on transition | 01-04, 01-09 | COVERED | Rehearsal and selected outcome. |
| CONTEXT | D-21 | Gate after all required observed pass/fail; no time/count minimum | 01-06–01-08 | COVERED | Missing row blocks human verdict. |
| CONTEXT | D-22 | Rapid affected/systemic notice | 01-06, 01-07 | COVERED | No root-cause wait. |
| CONTEXT | D-23 | Narrow isolation where possible | 01-07, 01-09 | COVERED | Scoped containment; host-unsafe stop. |
| CONTEXT | D-24 | Concise redacted notice fields | 01-06, 01-07 | COVERED | Fixed template. |
| CONTEXT | D-25 | Pilot/private/GitHub feedback channels | 01-06, 01-07 | COVERED | Three channels. |
| CONTEXT | D-26 | Report template mirrored in GitHub | 01-06 | COVERED | Exact six fields plus timestamp. |
| CONTEXT | D-27 | Shared default; sensitive private; forbidden Git data | 01-01, 01-06–01-09 | COVERED | Private journal and narrow preflight. |
| CONTEXT | D-28 | Notices to Niten and out-of-band channel | 01-04, 01-06, 01-07, 01-09 | COVERED | Disruptive and outcome notices. |
| CONTEXT | D-29 | Continuous pilot changes with pre/post notice | 01-04, 01-06, 01-07 | COVERED | Runbooks/templates/live handling. |
| CONTEXT | D-30 | Canonical `jodobear/niten` repository | 01-01, 01-06 | COVERED | Public planning/templates only; costly repository choice retained. |

## Specless edge-probe coverage

| Edge/backstop | Plan(s) | Resolution |
|---|---|---|
| Journal precedes first provenance command | 01-01 | Private creation timestamp and chronology reviewed. |
| Exact pin/manual source review | 01-01, 01-03 | Current canonical audit, clean source, source-build result, no substitution. |
| Loopback versus wildcard/public listener | 01-01, 01-03 | Local tracer plus target sockets. |
| Firewall threshold and one step outside | 01-03, 01-04 | Complete inet policy and TCP 1-65535 per address. |
| External scan vantage authority/freshness | 01-02, 01-04 | Target-independent IPv4/IPv6 runners selected, privately identified/authorized/preflighted, then revalidated before cutover. |
| Installed-target service sandbox | 01-03 | `systemd-analyze verify` plus security exposure score at most 4.0 and no unresolved high finding. |
| IPv4/IPv6/secondary/A+AAAA mismatch | 01-03, 01-04 | Host/provider/DNS reconciliation before/after apply/scan/reboot. |
| Public admin exact/adjacent/empty/unauthorized/precedence | 01-03, 01-04 | Pin-derived route list, fixed empty denial, private positive. |
| Log size/rate/retention | 01-03 | Exact journald and Caddy values verified. |
| Backup existence versus recoverability | 01-04 | Restic check, blank restore, protocol acceptance, rollback. |
| Consent chronology/membership equality/manual refresh | 01-05–01-07 | Exact disclosure and private explicit consent precede roster access; consenting-subset reconciliation and disposable add/remove controls. |
| Group/role/event boundary and empty cases | 01-06, 01-07 | Explicit Markdown rows and live observations. |
| Destination leakage | 01-06, 01-07 | Harmless trap cases and immediate containment. |
| Missing observations/OPT-OUT invocation | 01-06–01-08 | Every retained NIP-86 INTEGRATE has observed pass/fail; non-invokable methods require prior reasoned OPT-OUT amendment/source evidence/private decision; ordinary supported-client gaps remain distinct. |
| Mutable client/signer facts | 01-06, 01-07 | Exact product/version/build observed with result; S5 selected live. |
| Directory pending/error | 01-06 | Actual presence in one common directory required. |
| Hard verdict/critical-high rule | 01-08, 01-09 | Human selection then exact branch enactment. |

## Exclusions, not gaps

- Full target-client × signer cross-product: deferred to Phase 3.
- Hosted UI, standalone Blossom, federation, aggregation, curation, companion APIs, Pyramid patches: blocked until selected Phase 1 outcome and new planning decision.
- Napplet/Kehto/headless applet architecture: outside project.

## Result

All GOAL, REQ, RESEARCH, CONTEXT, and edge-probe items are covered. No deferred item appears as Phase 1 implementation. No source item is missing.
