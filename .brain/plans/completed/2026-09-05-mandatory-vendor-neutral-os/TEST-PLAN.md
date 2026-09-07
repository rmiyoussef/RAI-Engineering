# Test Strategy 2026-09-05-mandatory-vendor-neutral-os

**Coverage map (task → TC):** T1→TC-08; T2→TC-07/TC-08; T3→TC-07/TC-08; T4→TC-07; T5→TC-01..TC-06; T6→TC-01..TC-08.
**Required:** all 8 TCs. **Optional:** none.
**Execution order:** TC-01 (suite) → TC-02..TC-06 (suite sections + spot re-verification) → TC-07/TC-08 (content grep).
**Method:** tests/test-update.sh in temp dirs (--local, no network) + repo-wide grep + file reads.
