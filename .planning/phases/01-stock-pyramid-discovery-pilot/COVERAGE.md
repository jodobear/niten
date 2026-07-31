# Phase 1 NIP-86 Coverage

This is a plain planning-time coverage table, not an executable contract. Before live testing, compare the current official NIP-86 document with `supportedmethods` and the selected source-unmodified Pyramid pin. Update this table manually, record immutable references and the comparison in the private build journal, and keep unsupported methods visible.

`INTEGRATE` means the documented case in `docs/pilot-test-matrix.md` must be invoked and receive an observed pass/fail. A client/tool gap cannot substitute. If the execution-selected pin/operator path genuinely cannot invoke a method, the operator must first amend that row to `OPT-OUT`, cite immutable upstream/source evidence, retain the reasoned decision privately, and keep it non-invoked. `OPT-OUT` means the method is not invoked and its reason/evidence must be reviewed at the final gate. Hyphenated aliases are ordinary method names.

| Method | Disposition | Documented test case or reason |
|---|---|---|
| `supportedmethods` | INTEGRATE | `P1-NIP86-SUPPORTEDMETHODS` |
| `banpubkey` | INTEGRATE | `P1-NIP86-BANPUBKEY` |
| `unbanpubkey` | INTEGRATE | `P1-NIP86-UNBANPUBKEY` |
| `listbannedpubkeys` | INTEGRATE | `P1-NIP86-LISTBANNEDPUBKEYS` |
| `allowpubkey` | INTEGRATE | `P1-NIP86-ALLOWPUBKEY` |
| `unallowpubkey` | INTEGRATE | `P1-NIP86-UNALLOWPUBKEY` |
| `listallowedpubkeys` | INTEGRATE | `P1-NIP86-LISTALLOWEDPUBKEYS` |
| `createrole` | INTEGRATE | `P1-NIP86-CREATEROLE` |
| `editrole` | INTEGRATE | `P1-NIP86-EDITROLE` |
| `deleterole` | INTEGRATE | `P1-NIP86-DELETEROLE` |
| `assignrole` | INTEGRATE | `P1-NIP86-ASSIGNROLE` |
| `unassignrole` | INTEGRATE | `P1-NIP86-UNASSIGNROLE` |
| `create-role` | INTEGRATE | `P1-NIP86-CREATE-ROLE-ALIAS` |
| `edit-role` | INTEGRATE | `P1-NIP86-EDIT-ROLE-ALIAS` |
| `delete-role` | INTEGRATE | `P1-NIP86-DELETE-ROLE-ALIAS` |
| `assign-role` | INTEGRATE | `P1-NIP86-ASSIGN-ROLE-ALIAS` |
| `unassign-role` | INTEGRATE | `P1-NIP86-UNASSIGN-ROLE-ALIAS` |
| `listeventsneedingmoderation` | OPT-OUT | Moderated relay module is disabled; do not invoke |
| `signevent` | OPT-OUT | Current official baseline and researched pin do not expose it; re-evaluate if execution surfaces it |
| `allowevent` | OPT-OUT | Moderated module is disabled; do not invoke |
| `banevent` | INTEGRATE | `P1-NIP86-BANEVENT` |
| `listbannedevents` | INTEGRATE | `P1-NIP86-LISTBANNEDEVENTS` |
| `changerelayname` | OPT-OUT | D-05 identity is reviewed configuration; do not mutate during comparable tests |
| `changerelaydescription` | OPT-OUT | D-05 wording is reviewed configuration; do not mutate |
| `changerelayicon` | OPT-OUT | Icon mutation adds no required pilot observation |
| `allowkind` | OPT-OUT | Mutable kind-policy expansion is outside the selected minimum settings |
| `disallowkind` | OPT-OUT | Mutable kind policy is outside the selected minimum settings |
| `listallowedkinds` | OPT-OUT | Accepted and rejected events are tested directly |
| `blockip` | OPT-OUT | Network admission is owned by Caddy, private mesh, and host firewall |
| `unblockip` | OPT-OUT | Network admission is not delegated to stock Pyramid |
| `listblockedips` | OPT-OUT | Host and ingress evidence is authoritative for network admission |

## Completion check

- Current official NIP-86 ref, selected Pyramid tag/full commit, `supportedmethods` observation, UTC, and comparison pointer exist in private journal.
- Every method present in either current source is listed once above.
- Every retained `INTEGRATE` row maps to a case in `docs/pilot-test-matrix.md` and has an observed pass/fail; no supported-client gap substitutes.
- Every `OPT-OUT` row has reviewed immutable upstream/source evidence, a private-journal decision/reason, and no invocation.
