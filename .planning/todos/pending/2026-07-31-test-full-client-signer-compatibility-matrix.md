---
created: 2026-07-30T23:30:26.510Z
title: Test full client-signer compatibility matrix
area: planning
severity: major
files:
  - .planning/REQUIREMENTS.md:66
  - .planning/REQUIREMENTS.md:67
  - .planning/ROADMAP.md:42
---

## Problem

The stock-Pyramid discovery pilot deliberately requires only one proven client path for each approved signer family. That is enough to start live testing, but it does not prove the eventual full compatibility contract across Flotilla, Nostrord, Jumble, nos2x Chromium, nos2x Firefox, Amber/NIP-55, the selected iOS NIP-46 signer, and member-chosen NIP-46 bunkers.

Before the broader community experience is treated as supported, every applicable client/signer/relay combination needs retained evidence for login, reconnect, public publishing, invitations and roles, access-controlled read allow/deny, search, upload/delete where supported, rejection, timeout, and error behavior. Unsupported combinations must be recorded explicitly rather than silently skipped.

## Solution

Keep Phase 1 scoped to one proven path per signer family. During the later Core Community Experience phase, define and execute the complete cross-product matrix required by CLNT-02 and CLNT-03, with exact version pins and evidence for each cell.
