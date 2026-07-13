---
name: super-tester-upgrade
description: TESTER agent upgraded to 5 modes with template system
metadata:
  type: project
---

# Super TESTER Upgrade

TESTER agent overhauled from basic API test generator to comprehensive testing system with 5 modes.

## Files Created

| File | Purpose |
|------|---------|
| `templates/testing/TEST_PLAN_TEMPLATE.md` | Master plan template for any test task |
| `templates/testing/API_ENDPOINT.md` | 15+ scenarios per endpoint (happy path + all errors + edge cases) |
| `templates/testing/BUSINESS_FLOW.md` | Chained multi-step flow tests (full flow + partial + per-step auth) |
| `templates/testing/DATABASE_QUERY.md` | N+1 detection, index coverage, migration safety |
| `templates/testing/PERFORMANCE.md` | Response time benchmarks, query load tests |
| `templates/testing/CODE_QUALITY.md` | Naming conventions, SOLID, method length, docblocks |
| `rules/TESTING_RULES.md` | 11 testing rules (R1-R11) covering all modes |

## Files Updated

| File | Changes |
|------|---------|
| `agents/TESTER.md` | Full rewrite — 5 modes, template protocol, flow mapping |
| `skills/TESTING.md` | Enhanced with 5 modes, template protocol, coverage targets |
| `CLAUDE.md` | R28, R29 added. Phase 7 expanded. Agent directory updated. Version v0.6 |
| `README.md` | New "Super TESTER" section with coverage table |
| `VERSION` | v0.6 — Super TESTER |

## Key Behaviors

- **"Test onboarding"** → reads templates/testing/BUSINESS_FLOW.md → maps flow → generates tests
- **"Create template for X"** → fills template with feature details → writes to templates/
- **"I need test X"** → if no template → asks "Create template first?"
- Every task must have tests (R28). If no tests → TESTER asks.
