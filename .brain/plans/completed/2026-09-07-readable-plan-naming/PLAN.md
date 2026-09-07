# 2026-09-07-readable-plan-naming — Readable slug-based plan/test/summary naming

**Objective:** Plan folders carry readable date-slug names instead of PLAN-XXXX numbers.
**Status:** active
**Owner:** opencode agent
**Created:** 2026-09-07

## Problem
`PLAN-0007` says nothing. `2026-09-05-mandatory-vendor-neutral-os` says everything. Numbers need lookup, slugs read directly.

## Scope / Non-goals
- In scope: repo-wide rename (plans, test-cases, summaries, cross-refs, state), ARCHITECTURE/INSTRUCTIONS/templates/INDEX/agents rewrite, update.sh v2→v3 consumer migration, tests rewrite, TIMELINE regen, v1.9.0 sync.
- Non-goals: memory content rewrite beyond ID substitution (append-only preserved, mapping recorded).

## Requirements
- [ ] R1 Every plan dir/test dir/summary uses `<YYYY-MM-DD>-<slug>`, TC files `TC-NN.md`, refs qualified
- [ ] R2 Zero dangling PLAN-XXXX/TC-YYYY refs (except this plan's own history + deprecation notes)
- [ ] R3 Consumer brains migrate v2→v3 via update.sh (heading + mtime slugify)
- [ ] R4 Suite green, v1.9.0 synced, pushed

## Relevant context
- ARCHITECTURE.md §§6,7,10, INSTRUCTIONS.md §§3,8,9, templates, update.sh dispatch, tests/test-update.sh

## Affected areas
- .brain/plans|test-cases|summaries, ARCHITECTURE, INSTRUCTIONS, INDEX, agents, templates, update.sh, tests, state, README, VERSION (domains: [all])

## Technical approach
Explicit mapping table, scripted git mv + scoped sed per plan context, hand rewrite of authority files, generic slugify migration in update.sh, fixture-tested.

## Mapping
| Old | New |
|---|---|
| PLAN-0006 | 2026-09-05-central-engineering-brain |
| PLAN-0007 | 2026-09-05-mandatory-vendor-neutral-os |
| PLAN-0008 | 2026-09-05-agents-bootstrap-enforcement |
| PLAN-0009 | 2026-09-05-updater-self-refresh |
| PLAN-0010 | 2026-09-05-agents-no-bypass-guard |
| PLAN-0001 | 2026-07-19-multi-session-architecture |
| PLAN-0002 | 2026-07-24-domain-isolation-protocol |
| PLAN-0003 | 2026-07-23-flatten-domain-structure |
| PLAN-0004 | 2026-07-23-orchestration-parallel-execution |
| PLAN-0005 | 2026-07-23-update-setup-scripts |

TC renumber per plan in sort order → TC-01..NN. tests.yaml refs qualified `<slug>/TC-NN`.

## Dependencies
None.

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| Missed refs break traceability | medium | final grep sweep must show zero stragglers |
| Consumer migration mangles custom names | low | only touches PLAN-XXXX-pattern dirs, .bak-style caution, tested fixture |
| Memory append-only tension | low | substitution mechanical, mapping in decision record |

## Tasks
See TASKS.md. Covering TC: TC-01.

## Required test cases
See test-cases/active/2026-09-07-readable-plan-naming/INDEX.md.

## Completion requirements
INSTRUCTIONS.md §8 contract.
