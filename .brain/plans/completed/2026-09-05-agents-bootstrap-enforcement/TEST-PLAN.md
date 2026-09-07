# Test plan 2026-09-05-agents-bootstrap-enforcement

Coverage T1,T2,T3 → TC-01 required. Execution order: fixture without marker → update → marker present + custom preserved → re-run → hash stable + single marker → good file untouched. Manual repro plus tests/test-update.sh §10 automated.
