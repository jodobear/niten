# Phase 1 NIP-86 Coverage

This is a plain reviewed coverage table, not an executable contract. It was manually reconciled on 2026-07-31 against official NIP-86 at commit `0bcdd7a07953d3c34d5eb0da1921f1c19050e86b`, stock Pyramid `v1.3.2` at `e12e81641bfe6cacc6dd246e9433d602c1240e66`, selected-source registrations, and one authenticated `supportedmethods` observation. Immutable captures and the comparison remain in the private build journal.

`INTEGRATE` means the documented case in `docs/pilot-test-matrix.md` must be invoked and receive an observed pass/fail. A client/tool gap cannot substitute. If the execution-selected pin/operator path genuinely cannot invoke a method, the operator must first amend that row to `OPT-OUT`, cite immutable upstream/source evidence, retain the reasoned decision privately, and keep it non-invoked. `OPT-OUT` means the method is not invoked and its reason/evidence must be reviewed at the final gate. Hyphenated aliases are ordinary method names.

| Method | Disposition | Documented test case or reason |
|---|---|---|
| `supportedmethods` | INTEGRATE | `P1-NIP86-SUPPORTEDMETHODS` |
| `banpubkey` | INTEGRATE | `P1-NIP86-BANPUBKEY` |
| `unbanpubkey` | OPT-OUT | Official method is not registered by selected stock pin; do not invoke |
| `listbannedpubkeys` | INTEGRATE | `P1-NIP86-LISTBANNEDPUBKEYS` |
| `allowpubkey` | INTEGRATE | `P1-NIP86-ALLOWPUBKEY` |
| `unallowpubkey` | OPT-OUT | Official method is not registered by selected stock pin; do not invoke |
| `listallowedpubkeys` | INTEGRATE | `P1-NIP86-LISTALLOWEDPUBKEYS` |
| `createrole` | INTEGRATE | `P1-NIP86-CREATEROLE` |
| `editrole` | INTEGRATE | `P1-NIP86-EDITROLE` |
| `deleterole` | INTEGRATE | `P1-NIP86-DELETEROLE` |
| `assignrole` | INTEGRATE | `P1-NIP86-ASSIGNROLE` |
| `unassignrole` | INTEGRATE | `P1-NIP86-UNASSIGNROLE` |
| `listeventsneedingmoderation` | OPT-OUT | Official method is not registered by selected stock pin; do not invoke |
| `allowevent` | OPT-OUT | Official method is not registered by selected stock pin; do not invoke |
| `banevent` | INTEGRATE | `P1-NIP86-BANEVENT` |
| `listbannedevents` | OPT-OUT | Official method is not registered by selected stock pin; do not invoke |
| `changerelayname` | INTEGRATE | `P1-NIP86-CHANGERELAYNAME` |
| `changerelaydescription` | INTEGRATE | `P1-NIP86-CHANGERELAYDESCRIPTION` |
| `changerelayicon` | INTEGRATE | `P1-NIP86-CHANGERELAYICON` |
| `allowkind` | INTEGRATE | `P1-NIP86-ALLOWKIND` |
| `disallowkind` | INTEGRATE | `P1-NIP86-DISALLOWKIND` |
| `listallowedkinds` | INTEGRATE | `P1-NIP86-LISTALLOWEDKINDS` |
| `blockip` | INTEGRATE | `P1-NIP86-BLOCKIP` |
| `unblockip` | INTEGRATE | `P1-NIP86-UNBLOCKIP` |
| `listblockedips` | INTEGRATE | `P1-NIP86-LISTBLOCKEDIPS` |

## Completion check

- Current official NIP-86 ref, selected Pyramid tag/full commit, `supportedmethods` observation, UTC, and comparison pointer exist in private journal.
- Every method present in either the current official specification or selected runtime registration is listed once above.
- Every retained `INTEGRATE` row maps to a case in `docs/pilot-test-matrix.md` and has an observed pass/fail; no supported-client gap substitutes.
- Every `OPT-OUT` row has reviewed immutable upstream/source evidence, a private-journal decision/reason, and no invocation.
