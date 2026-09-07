# 2026-09-05-updater-self-refresh — Updater self-refresh for installed .ai/update.sh copies

**Objective:** Updater fixes propagate to existing installs on every run.
**Status:** completed
**Owner:** opencode agent
**Created:** 2026-09-05

## Problem
.ai/update.sh in consumer projects is a stale copy. Not in SYSTEM_FILES/AI_FILES, never refreshed. 2026-09-05-agents-bootstrap-enforcement AGENTS.md repair logic sat on master while bench/backend kept running the old updater. Update reported no visible change.

## Scope / Non-goals
- In scope: refresh_self() in update.sh, tests/test-update.sh §11, v1.8.2 sync.
- Non-goals: brain version bump (stays 2, no structural migration), setup.sh changes.

## Requirements
- [x] R1 Installed .ai/update.sh copy refreshes from source every run
- [x] R2 One .bak kept, fetch failures never fail the run
- [x] R3 Guards: no write into bare cwd, no remote clobber of repo workspace
- [x] R4 Idempotent, suite green

## Relevant context
- update.sh ensure_adapters/fetch_source/refresh_system_files, .ai/update.sh consumer copies, tests/test-update.sh §§10-11

## Affected areas
- update.sh, tests/test-update.sh, version files, README.md (domains: [all])

## Technical approach
refresh_self() after dispatch: skip unless parent dir is .ai or --local. fetch_source update.sh to tmp, cmp with running copy, replace + chmod +x + single .bak + migrate_log. Called once after esac; check mode exits before.

## Architecture considerations
Updater is RAI-owned, overwrite safe. User-owned content untouched. Guard protects curl-pipe runs and repo workspaces.

## Dependencies
None.

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| Remote clobbers dev workspace | low | basename + local guards, cmp no-op |
| Fetch failure breaks update | low | warn + return 0, run continues |

## Tasks
See TASKS.md. Covering TC: TC-01.

## Required test cases
See test-cases/completed/2026-09-05-updater-self-refresh/INDEX.md.

## Completion requirements
INSTRUCTIONS.md §8 contract.
