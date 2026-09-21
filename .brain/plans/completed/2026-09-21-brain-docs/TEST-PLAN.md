# Test plan 2026-09-21-brain-docs

| Task | TC | Type | Required |
|------|----|------|----------|
| T4 updater support | TC-01 | installer fixture (fresh + existing + idempotent) | yes |
| T1–T3 scaffolds/skill/wiring | TC-02 | static content verification | yes |

Execution order: TC-02 (static) → TC-01 (suite + live updater run).
