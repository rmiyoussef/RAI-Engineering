# Decision: Date-slug plan naming with v2→v3 migration (v1.9.0)

**Date:** 2026-09-07
**Domains:** all
**Context:** PLAN-XXXX numbers need lookup. User requested readable folder names with full history rename.

## Options Considered
- New plans slugs only, old numbers stay (rejected by user: dual scheme confusion)
- Rename all + generic consumer migration (chosen)

## Decision
**Chosen:** `<YYYY-MM-DD>-<slug>` everywhere, TC-NN per plan, qualified refs in state. Brain v3. update.sh slugifies consumer PLAN-XXXX dirs by heading + mtime.
**Rationale:** readability at listing time, zero lookup.

## Consequences
- Old IDs survive only in this plan's mapping table, history prose, test fixture, migration code.
- Consumers migrate automatically on update.sh --yes with backup first.
- Plan counter retired; plans.yaml drops next_plan_id.
