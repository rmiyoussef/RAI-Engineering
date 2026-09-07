# 2026-09-05-agents-bootstrap-enforcement — Enforce .brain bootstrap in AGENTS.md on install/update

**Objective:** Opencode sessions always load .brain even when project has pre-existing custom AGENTS.md.
**Status:** completed
**Owner:** opencode agent
**Created:** 2026-09-05

## Problem
.brain/ present but /var/www/bench/backend/AGENTS.md caveman-only, zero .brain mention. Opencode loads AGENTS.md, ignores CLAUDE.md when AGENTS.md exists. update.sh ensure_adapters copied AGENTS.md only when missing. setup.sh created AGENTS.md only when missing. Pre-existing custom AGENTS.md stayed broken forever. Brain bypassed. INSTRUCTIONS.md §11 violation.

## Scope / Non-goals
- In scope: update.sh ensure_adapters repair, setup.sh pre-existing repair, tests/test-update.sh regression section 10.
- Non-goals: CLAUDE.md chaining, opencode.json auto-creation, model policy changes.

## Requirements
- [x] R1 Existing AGENTS.md without marker gets bootstrap prepended, user content preserved
- [x] R2 Missing AGENTS.md still installed (local copy, fetched, minimal fallback)
- [x] R3 Already-correct AGENTS.md untouched, idempotent re-runs
- [x] R4 setup.sh repairs pre-existing AGENTS.md same way
- [x] R5 Regression tests green

## Relevant context
- .brain/ARCHITECTURE.md §14 (parallel thin adapters), .brain/INSTRUCTIONS.md §11 (no bypass), update.sh ensure_adapters, setup.sh caveman block, tests/test-update.sh §9

## Affected areas
- update.sh, setup.sh, tests/test-update.sh (domains: [all])

## Technical approach
Marker check grep -qF .brain/INSTRUCTIONS.md. Absent marker triggers prepend of canonical bootstrap line identical to repo AGENTS.md line 3. Tmp file + cat overwrite, quoted paths, migrate_log entry. setup.sh mirrors with elif branch. update.sh missing-file path gains fetch fallback + minimal bootstrap fallback.

## Architecture considerations
Non-destructive ownership: AGENTS.md user-owned, merge never replace. Bootstrap prepend only, no reorder of user content beyond prefix. Idempotent via marker single-check.

## Dependencies
None.

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| Duplicate bootstrap on re-run | low | marker count assertion, idempotency test |
| User AGENTS.md intentionally brain-free | low | bootstrap additive only, content preserved, logged |

## Tasks
See TASKS.md. Covering TC: TC-01.

## Required test cases
See test-cases/completed/2026-09-05-agents-bootstrap-enforcement/INDEX.md.

## Completion requirements
INSTRUCTIONS.md §8 contract.
