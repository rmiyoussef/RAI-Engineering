# Summary 2026-09-05-updater-self-refresh — Updater self-refresh for installed copies

**Objective:** Updater fixes reach existing installs on every run.
**Status:** completed
**Date:** 2026-09-05

## What was implemented
- update.sh refresh_self(): refreshes running .ai/update.sh from source after dispatch. Guard parent dir .ai or --local. cmp no-op when current. Single .bak. Fetch failures warn only. migrate_log entry.
- tests/test-update.sh §11: 4 assertions (logic present, stale gone, .bak kept, idempotent).
- v1.8.2 sync: VERSION, CLAUDE.md, CLAUDE.install.md x2, README header/What's New/roadmap/footer/suite count, setup.sh output.

## What changed (files/components)
- update.sh, tests/test-update.sh, VERSION, CLAUDE.md, CLAUDE.install.md, README.md, setup.sh, .brain/plans/completed/2026-09-05-updater-self-refresh/, .brain/test-cases/completed/2026-09-05-updater-self-refresh/, .brain/summaries/completed/2026-09-05-updater-self-refresh.md, .brain/memory/decisions/2026-09-05-updater-self-refresh.md, state yamls.

## Important architectural decisions
- See plans/completed/2026-09-05-updater-self-refresh/DECISIONS.md (D1-D3): dedicated function over manifest, single .bak, cwd/workspace guards.

## Tests executed + results
| TC | Result | Notes |
|---|---|---|
| TC-01 self-refresh | PASSED | §11 4/4 |
| Full suite | PASSED | 61/61 exit 0 |

## Known limitations / remaining issues
- Brain version stays 2. No structural migration in this change.
- bench/backend healed manually with fixed copy; future fixes propagate automatically.

## Performance / security considerations
- One extra fetch per run in consumer layouts only. No secret logging. chmod +x preserved.

## Lessons learned
- The updater must update itself or fixes never land. System files list had a blind spot for the runner.
- Consumer-layout fixtures (run the installed copy, not the repo copy) catch propagation bugs.

## Future recommendations
- CI: run tests/test-update.sh on every update.sh/setup.sh change.
