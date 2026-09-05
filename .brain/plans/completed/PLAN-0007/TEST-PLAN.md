# Test Strategy PLAN-0007

**Coverage map (task → TC):** T1→TC-0008; T2→TC-0007/TC-0008; T3→TC-0007/TC-0008; T4→TC-0007; T5→TC-0001..TC-0006; T6→TC-0001..TC-0008.
**Required:** all 8 TCs. **Optional:** none.
**Execution order:** TC-0001 (suite) → TC-0002..TC-0006 (suite sections + spot re-verification) → TC-0007/TC-0008 (content grep).
**Method:** tests/test-update.sh in temp dirs (--local, no network) + repo-wide grep + file reads.
