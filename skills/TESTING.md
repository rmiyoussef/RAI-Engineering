# Testing Skill

> **How to test software comprehensively — APIs, flows, database, performance, code quality.**
> **Loaded by:** TESTER, EXECUTOR, REVIEWER, BACKEND QA agents.

---

## When to Use

- Writing tests for new code
- Reviewing existing test coverage
- Adding missing scenarios to existing tests
- Creating test templates for business flows

## Five Testing Modes

### 1. API Testing

Every endpoint needs tests for ALL scenarios:

| Layer | Scenarios |
|-------|-----------|
| 🟢 Happy Path | Create, Read (single), Read (list), Update, Delete |
| 🔴 Validation | Empty payload, missing fields, wrong types, max length, SQL injection attempt |
| 🔒 Auth | No token, invalid token, expired token, wrong auth header format |
| 🚫 Authorization | Wrong role, insufficient permissions, scoped access |
| 🔍 Not Found | Nonexistent ID, soft-deleted resource, wrong UUID format |
| 📄 Edge Cases | Empty collection, pagination bounds, special characters, batch operations |
| 🔄 Idempotency | Duplicate submission, unique key violation, repeated requests |

**Template:** `templates/testing/API_ENDPOINT.md`

### 2. Business Flow Testing

Test multi-step processes as complete workflows:

```
Step 1: Create       → 201 {id}
Step 2: Process      → 200 {uuid}
Step 3: Create Child → 201 {childId}
Step 4: Finalize     → 200 {status: active}
```

Each flow test covers:
- **Full flow** — all steps pass, final DB state correct
- **Partial flow** — each step independently fails with bad input
- **Per-step auth** — every step requires authentication (not just step 1)
- **Per-step authorization** — every step gates by role
- **Rollback** — step 1 creates data but step 2 fails → no orphaned data

**Template:** `templates/testing/BUSINESS_FLOW.md`

### 3. Database Testing

Test queries, not just ORM calls:

```
Query Correctness → Right rows returned for WHERE/filter/scope
N+1 Detection     → Query log has ≤ N+1 queries (not 1+N)
Eager Loading     → Relations loaded in single additional query
Index Coverage    → Foreign keys and WHERE columns have indexes
Migration Safety  → Up AND down both work, columns are correct types
Constraints       → Unique, FK cascade, NOT NULL all enforced
```

**Template:** `templates/testing/DATABASE_QUERY.md`

### 4. Performance Testing

Set thresholds and assert against them:

```php
const MAX_RESPONSE_MS = 500;
$start = microtime(true);
$response = $this->getJson('/api/v1/resources');
$duration = (microtime(true) - $start) * 1000;
$this->assertLessThan(MAX_RESPONSE_MS, $duration);
```

Test: response time, query count, payload size, throughput under load.

**Template:** `templates/testing/PERFORMANCE.md`

### 5. Code Quality Testing

Automated checks for clean code standards:

```
Naming    → PascalCase classes, camelCase methods, descriptive variables
SOLID     → SRP (≤15 methods/class), DIP (interface injection)
Complexity → Methods ≤ 30 lines, cyclomatic ≤ 10
Docblocks → Every public method has @param/@return
```

**Template:** `templates/testing/CODE_QUALITY.md`

---

## Template Protocol

```
User says "test onboarding"
  → Check templates/testing/ for onboarding flow
  → Found? Use it to generate tests
  → Not found? Ask: "Create onboarding template first?"
    → Yes: Read templates/testing/BUSINESS_FLOW.md → map steps → write template → generate tests
```

User says "create template for {feature}"
  → Read relevant base template (API_ENDPOINT / BUSINESS_FLOW / etc.)
  → Fill in feature-specific details
  → Write to templates/testing/{feature}.md
  → Confirm and ask if ready to generate tests

---

## Coverage Goals

| Area | Minimum | Template |
|------|---------|----------|
| API endpoints | 80% (all 15+ scenarios) | `API_ENDPOINT.md` |
| Business flows | 100% (full + partial + auth) | `BUSINESS_FLOW.md` |
| Database queries | 80% (correctness + N+1 + indexes) | `DATABASE_QUERY.md` |
| Performance (critical) | 100% of thresholds | `PERFORMANCE.md` |
| Code quality | All public methods checked | `CODE_QUALITY.md` |

## Test File Organization

```
tests/
├── Feature/
│   ├── Api/V1/          ← One file per endpoint
│   └── Flows/           ← One file per business flow
├── Unit/
│   ├── Queries/         ← Query tests
│   ├── CodeQuality/     ← Clean code checks
│   └── Services/        ← Unit tests for services
└── Performance/         ← Benchmark tests
```

## Patterns to Avoid

- **Testing the framework.** Don't test that Laravel's QueryBuilder works. Test that your query logic is correct.
- **Brittle selectors.** Don't use CSS class names in feature tests. Use data attributes or text content.
- **Slow unit tests.** A unit test should take milliseconds. If it takes seconds, it's an integration test.
- **Shared mutable state.** Tests should not depend on each other or on execution order.
- **Fake data.** No `test@test.com`. Use realistic factories with real-looking data.
- **Single-scenario tests.** One endpoint = 15+ scenarios minimum.
