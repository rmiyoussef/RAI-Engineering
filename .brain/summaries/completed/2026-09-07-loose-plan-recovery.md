# Summary 2026-09-07-loose-plan-recovery — Loose plans/ files move to completed

**Objective:** Loose plan files auto-wrap into completed slug dirs on every update.
**Status:** completed
**Date:** 2026-09-07

## What was implemented
- update.sh recover_loose_plans(): every run wraps plans/*.md into plans/completed/<id>/ + STATUS completed. Slug-shaped names kept, others via plan_id_for (now falls back to filename). State pointer appended deduped. migrate_log per file.
- Backup exclude fixed: `.brain/.migration` no longer tars itself (was fatal under set -e on larger brains).
- tests: §14 (6 asserts) + backup self-exclusion assert. Suite 79/79.
- Bench healed live: 6 files wrapped, brain v2→v3, zero PLAN- leftovers.
- v1.9.1 synced everywhere.

## Tests executed + results
| TC | Result | Notes |
|---|---|---|
| TC-01 recovery e2e | PASSED | §14 6/6, backup assert, bench verified |

## Lessons learned
- The updater backing up its own output dir is a deterministic bug with probabilistic symptoms. Exclude paths must match tar member names.
- Fresh brains lack state/plans.yaml; recovery guards pointer append.
