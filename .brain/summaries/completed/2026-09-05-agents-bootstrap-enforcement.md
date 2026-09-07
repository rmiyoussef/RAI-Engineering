# Summary 2026-09-05-agents-bootstrap-enforcement — Enforce .brain bootstrap in AGENTS.md on install/update

**Objective:** Opencode sessions always load .brain even with pre-existing custom AGENTS.md.
**Status:** completed
**Date:** 2026-09-05

## What was implemented
- update.sh ensure_adapters: missing AGENTS.md chain (local copy, fetched, minimal fallback). Existing without `.brain/INSTRUCTIONS.md` marker gets canonical bootstrap prepended, user content preserved, migrate_log entry.
- setup.sh: pre-existing AGENTS.md without marker repaired same way. Fresh creation unchanged.
- tests/test-update.sh §10: 4 assertions (bootstrap present, custom preserved, single marker, idempotent).

## What changed (files/components)
- update.sh, setup.sh, tests/test-update.sh, .brain/plans/completed/2026-09-05-agents-bootstrap-enforcement/, .brain/test-cases/completed/2026-09-05-agents-bootstrap-enforcement/, .brain/summaries/completed/2026-09-05-agents-bootstrap-enforcement.md, .brain/memory/decisions/2026-09-05-agents-bootstrap.md, state yamls.

## Important architectural decisions
- See plans/completed/2026-09-05-agents-bootstrap-enforcement/DECISIONS.md (D1-D4): prepend priority, marker substring, no CLAUDE chaining, missing-file fallback chain.

## Tests executed + results
| TC | Result | Notes |
|---|---|---|
| TC-01 bootstrap enforcement | PASSED | §10 4/4, manual repro idempotent + good-file untouched |
| Full suite | PASSED | 57/57 exit 0 |

## Known limitations / remaining issues
- /var/www/bench/backend/AGENTS.md itself not patched here. Run update.sh there to apply repair.
- Intentionally brain-free AGENTS.md gets bootstrap anyway. Additive only, logged.

## Performance / security considerations
- Tmpfile + cat overwrite, quoted paths, no secret logging. Marker grep only.

## Lessons learned
- Copy-if-missing adapters rot when users predate installer. Enforce marker on every run.
- Opencode precedence makes AGENTS.md critical path. CLAUDE.md correctness insufficient alone.

## Future recommendations
- CI: run tests/test-update.sh on every update.sh/setup.sh change.
- Notify bench/backend owner to run update.sh --yes to heal AGENTS.md.
