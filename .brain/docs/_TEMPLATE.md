# <Feature Name>

> One file per feature. Keep sections in this order. Delete nothing — mark obsolete sections `_(retired YYYY-MM-DD: reason)_` instead.

**Status:** `draft | live | retired`
**Owner:** —
**Last verified:** YYYY-MM-DD (code commit or plan ref)

## Overview

What this feature does, who it serves, 3–5 sentences max. Link the plan that built it.

## Flows

Numbered end-to-end paths a user or system takes. One bullet per step, files/routes named.

1. …
2. …

## API & Data

Endpoints, models/tables, queues, caches touching this feature. Table preferred:

| Item | Location | Notes |
|------|----------|-------|
| … | … | … |

## UI

Screens/components, routes, states (empty, loading, error). Skip when backend-only — say so in one line.

## Edge Cases & Gotchas

What breaks, what surprises, what past fixes taught. Each item one line + link to decision/lesson when one exists.

## Links

- Plans: …
- Test cases: …
- Decisions: `memory/decisions/…`
- Knowledge: `knowledge/…`
- Related docs: `docs/<other>.md § …`

## Changelog

Newest first. One line per change: date, what changed, why (plan/commit ref).

- YYYY-MM-DD — Created from `<plan-id>`. Reason: …
