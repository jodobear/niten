# Private build journal

The build journal is operational evidence, not repository content. Set
`NITEN_PRIVATE_JOURNAL` to an operator-approved absolute path on durable,
access-controlled storage outside every Git worktree. Never use an in-repository
directory, an ignored directory as a substitute, or `/tmp` as the journal root.

## Create the journal before work

Use `umask 0077`. Resolve both the repository and journal with `realpath`, fail
closed if either path is ambiguous, and prove the resolved journal is outside
the resolved repository. The root, date, run, and raw-capture directories must
be mode `0700`; Markdown logs and captures must be mode `0600`.

Create this tree before the first provenance query, download, build, tracer,
host, roster, or live-client command:

```text
$NITEN_PRIVATE_JOURNAL/
├── .active-run
└── YYYY-MM-DD/
    └── YYYYMMDDTHHMMSSZ-purpose/
        ├── journal.md
        └── raw/
            ├── audit/
            ├── build/
            ├── tracer/
            ├── nip86/
            ├── operations/
            ├── restore/
            ├── incidents/
            └── feedback/
```

Create `.active-run` as a mode-`0600` regular file containing only the
canonical absolute path of the current run directory. It must not be a symlink,
and its resolved target must remain beneath the canonical journal root:

```bash
set -euo pipefail
umask 0077
journal_candidate=${NITEN_PRIVATE_JOURNAL:?set an absolute private journal path}
[[ $journal_candidate == /* && ! -L $journal_candidate ]]
install -d -m 0700 -- "$journal_candidate"
journal_root=$(realpath -e -- "$journal_candidate")
repo_root=$(realpath -e -- "$(git rev-parse --show-toplevel)")
[[ $journal_root != "$repo_root" && $journal_root != "$repo_root/"* ]]
[[ $(git -C "$journal_root" rev-parse --is-inside-work-tree 2>/dev/null || true) != true ]]
journal_utc=$(date -u +%Y-%m-%dT%H%M%SZ)
run_dir="$journal_root/${journal_utc%%T*}/${journal_utc//-/}-discovery"
install -d -m 0700 -- "$run_dir/raw/"{audit,build,tracer,nip86,operations,restore,incidents,feedback}
install -m 0600 /dev/null "$run_dir/journal.md"
printf '%s\n' "$(realpath -e -- "$run_dir")" > "$journal_root/.active-run"
chmod 0600 -- "$journal_root/.active-run"
```

Append the intent before each command. Append actual result, exit status, and a
relative capture label immediately afterward. Do not rely on shell history as
evidence. Raw stdout/stderr goes beside the journal, never into Git.

## Minimum entry fields

Each entry records:

- run ID, UTC timestamp, operator role, purpose, expected result, actual result,
  pass/fail, and a private capture label;
- upstream repository, tag, full commit, source/archive and release checksums,
  artifact size, toolchain/runtime versions, resolved dependencies, clean-tree
  proof, build result, and checksum comparison;
- decision/change, reason, failures, fixes, diagrams, effective non-secret
  configuration review, and verdict impact;
- case ID, expected/actual behavior, exact component/client/signer build facts,
  destination and protocol capture labels, and pass/fail;
- cost and capacity observations, backup/restore/rollback evidence, RPO/RTO,
  incident/containment actions, participant feedback, and upstream improvement
  notes.

A missing observation stays missing. A failed observation is retained and safe
discovery continues where possible. Calendar time and participant counts never
close an evidence gate.

## Data boundary

Never put journal content or raw captures in GitHub, issues, pull requests,
commits, summaries, or generated reports. Repository artifacts may contain only
public pins, procedures, blank templates, case IDs, and manually reviewed,
redacted conclusions.

Never store any signer private key, raw `nsec`, seed phrase, NIP-46 bunker or
`nostrconnect` URI, connection secret, authorization header, session cookie,
API token, credential, recovery secret, or unredacted secret-bearing settings —
not even in the private journal. Keep signing inside the selected signer. Record
only product/version, approved role, result, and an opaque private capture label.

Roster event identifiers, pubkeys, member relationships, private group IDs,
invite codes, private event IDs/bodies, live addresses, provider details, mesh
coordinates, and raw logs remain in access-controlled captures only when the
test strictly requires them. Use harmless trap content for routing tests.

## Retention, restore, and incidents

- Back up the journal to an encrypted, access-controlled destination in an
  independent failure domain. Record the retention class and deletion owner.
- Test restore into a blank protected location. Verify modes, ownership,
  checksums, capture links, and operator readability without copying material
  into the repository.
- Preserve failed generations and their evidence until the approved retention
  policy expires. Never overwrite the only copy during rollback.
- For suspected disclosure, stop the affected capture, preserve it privately,
  rotate exposed credentials through their owning system, record scope and
  containment, and publish only a concise redacted notice.

## Feedback and upstream notes

Feedback entries use client/version, signer product/version, action, expected,
actual, UTC, scope, and result. Security and privacy reports stay private until
manually redacted. Upstream notes contain the smallest reproducible public facts
possible; re-review every attachment and command transcript before publication.
