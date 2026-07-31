---
schema_version: 1
open_count: 1
waived_count: 0
fixed_count: 3
total_count: 4
last_updated: 2026-07-31T12:12:18.139Z
---

# Broken Windows Ledger

> Cross-phase defect register. `/gsd-ship` blocks while `open_count > 0`.
> Waive with `gsd-tools windows waive <id> "<reason>"` (reason required).
> Mark fixed with `gsd-tools windows fixed <id>`.

| id | phase | kind | file | line | description | status | reason | recorded_at | resolved_at |
|----|-------|------|------|------|-------------|--------|--------|-------------|-------------|
| 1 | 01 | deviation | scripts/local-stock-smoke.sh |  | Exact-stock local tracer uses loopback WS; TLS/WSS belongs to the later Caddy envelope | open |  | 2026-07-31T12:11:54.555Z |  |
| 2 | 01 | deviation | scripts/verify-pyramid.sh |  | Rootless Podman supplied exact upstream build inputs after Docker daemon was unavailable | fixed |  | 2026-07-31T12:12:05.252Z | 2026-07-31T12:12:17.995Z |
| 3 | 01 | deviation | scripts/verify-pyramid.sh |  | Canonical remote comparison normalizes only an optional terminal .git suffix | fixed |  | 2026-07-31T12:12:05.320Z | 2026-07-31T12:12:18.064Z |
| 4 | 01 | deviation | scripts/repo-preflight.sh |  | Signer URI detection requires a complete identity and query to avoid harmless documentation false positives | fixed |  | 2026-07-31T12:12:05.390Z | 2026-07-31T12:12:18.139Z |

````json
[
  {
    "id": 1,
    "kind": "deviation",
    "phase": "01",
    "file": "scripts/local-stock-smoke.sh",
    "line": null,
    "description": "Exact-stock local tracer uses loopback WS; TLS/WSS belongs to the later Caddy envelope",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-07-31T12:11:54.555Z",
    "resolved_at": null
  },
  {
    "id": 2,
    "kind": "deviation",
    "phase": "01",
    "file": "scripts/verify-pyramid.sh",
    "line": null,
    "description": "Rootless Podman supplied exact upstream build inputs after Docker daemon was unavailable",
    "status": "fixed",
    "reason": "",
    "recorded_at": "2026-07-31T12:12:05.252Z",
    "resolved_at": "2026-07-31T12:12:17.995Z"
  },
  {
    "id": 3,
    "kind": "deviation",
    "phase": "01",
    "file": "scripts/verify-pyramid.sh",
    "line": null,
    "description": "Canonical remote comparison normalizes only an optional terminal .git suffix",
    "status": "fixed",
    "reason": "",
    "recorded_at": "2026-07-31T12:12:05.320Z",
    "resolved_at": "2026-07-31T12:12:18.064Z"
  },
  {
    "id": 4,
    "kind": "deviation",
    "phase": "01",
    "file": "scripts/repo-preflight.sh",
    "line": null,
    "description": "Signer URI detection requires a complete identity and query to avoid harmless documentation false positives",
    "status": "fixed",
    "reason": "",
    "recorded_at": "2026-07-31T12:12:05.390Z",
    "resolved_at": "2026-07-31T12:12:18.139Z"
  }
]
````
