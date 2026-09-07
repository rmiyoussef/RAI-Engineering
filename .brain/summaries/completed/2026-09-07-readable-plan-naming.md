# Summary 2026-09-07-readable-plan-naming — Readable slug-based plan/test/summary naming

**Objective:** Plan folders carry readable date-slug names instead of PLAN-XXXX numbers.
**Status:** completed
**Date:** 2026-09-07

## What was implemented
- Repo rename: 10 plan dirs, 5 test dirs (TC files renumbered per plan), 5 summaries → date-slug scheme. Scoped sed per plan context.
- Authority rewrite: ARCHITECTURE §§4,6,7,8, INSTRUCTIONS §§1,3,5,7,9, templates x3, INDEX, agents MEMORY/PLANNER/SUMMARY, message-protocol, brain README, CLAUDE.install, README, memory-timeline docstring, DOMAINS_MIGRATION note.
- update.sh: TARGET 3, migrate_v2_to_v3 (heading + mtime slugify, 4 phases, .bak-free merge), v1→v2 archived creation emits slugs, chained dispatch.
- tests/test-update.sh: slug fixtures, §13 v2→v3 migration test, version asserts 3. Suite 72/72.
- TIMELINE.md regenerated. v1.9.0 synced everywhere.

## What changed (files/components)
- .brain/plans|test-cases|summaries layout, authority files, update.sh, tests/, state yamls, VERSION, CLAUDE.md, CLAUDE.install.md, README.md, setup.sh output.

## Important architectural decisions
- See plans/completed/2026-09-07-readable-plan-naming/DECISIONS.md (D1-D4): scheme, TC refs, tests.yaml attribution, consumer migration scope.

## Tests executed + results
| TC | Result | Notes |
|---|---|---|
| TC-01 slug naming e2e | PASSED | sweep clean, suite 72/72 |

## Known limitations / remaining issues
- Intentional old-ID mentions remain: mapping table in this plan, D3 attribution note, §13 fixture, migration code patterns.
- Bare TC-XXXX refs in consumer state/tests.yaml kept verbatim with warning (unresolvable attribution).
- Repo AGENTS.md vs setup.sh template caveman wording drift persists (pre-existing).

## Performance / security considerations
- Migration is mv + sed, quoted paths, backup before structural change preserved.

## Lessons learned
- Per-plan TC numbers were never globally unique (TC-0001 in two plans). New scheme makes per-plan scoping explicit.
- Generated files (TIMELINE.md) regen cleanly when the generator is layout-generic.

## Future recommendations
- CI: run tests/test-update.sh on every update.sh/setup.sh change.
- Consumers run update.sh --yes to migrate to brain v3.
