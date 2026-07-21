# Testing Rules

> **Rules for writing comprehensive, production-quality tests.**
> **Loaded by:** TESTER agent, REVIEWER agent, BACKEND QA agent.

---

## R1 — Every Task Has Tests

Every code change includes or updates tests. No exceptions.

- If a task has no tests, TESTER asks user: *"Create test template for this feature?"*
- If tests exist but miss coverage, TESTER adds missing scenarios
- If the task is read-only (docs, research), tests not required

## R2 — Cover ALL API Scenarios Per Endpoint

| Scenario | Code | Required |
|----------|------|----------|
| Happy Path | 200/201 | ✅ Always |
| Validation Error | 422 | ✅ Always |
| Auth Failure (no token) | 401 | ✅ Always |
| Auth Failure (invalid token) | 401 | ✅ Always |
| Forbidden (wrong role) | 403 | ✅ If role-gated |
| Not Found | 404 | ✅ Always |
| Empty Collection | 200, `data: []` | ✅ For list endpoints |
| Pagination | 200 with meta | ✅ For list endpoints |
| Edge Case (max length) | 200/422 | ✅ Always |
| Idempotency / Duplicate | 409 | ✅ If unique constraints |
| Soft Delete | 404 after delete | ✅ If soft deletes |

## R3 — Business Flow Tests Are Chained

A business flow test must:

1. Execute each step in sequence, passing data between steps
2. Assert every step's response before proceeding
3. Test the **full flow** end-to-end
4. Test **partial flows** — each step in isolation
5. Test **auth at every step** — a flow can't skip auth after step 1
6. Verify **final database state** after the flow

**Best practice:** Save intermediate state (`$this->flowState`) and pass through steps.

## R4 — Database Tests Cover N+1, Indexes, Migrations

| Check | Method |
|-------|--------|
| N+1 detection | Enable query log, assert query count ≤ relations + 1 |
| Index usage | Verify `SHOW INDEX FROM table` includes foreign keys |
| Migration rollback | `migrate:rollback` and assert table gone |
| Column types | `Schema::getColumnListing()` + type assertions |

## R5 — Performance Tests Have Thresholds

Every performance test must define and assert against thresholds:

```php
const MAX_ACCEPTABLE_MS = 500;
const P95_ACCEPTABLE_MS = 300;
```

Thresholds should be based on:
- API response time: P95 < 300ms, max < 500ms
- Query execution: < 100ms for indexed queries
- Response size: < 100KB for list endpoints
- Query count: ≤ 3 per page load (including eager loads)

## R6 — Code Quality Tests Check Naming and SOLID

| Check | Rule |
|-------|------|
| Class naming | PascalCase |
| Method naming | camelCase |
| Variable naming | Descriptive (no single-letter except i/j/k) |
| Method length | ≤ 30 lines |
| Class methods | ≤ 15 methods (consider splitting) |
| Dependency injection | Interfaces, not concretions |
| Docblocks | All public methods documented |

## R7 — Test Data Is Realistic

- Use factories with realistic attribute values
- Real names, real emails, real UUIDs
- No `test@test.com`, no `John Doe`
- Related models created via factory relationships
- Seed data volumes that match production patterns

## R8 — Tests Are Deterministic

- No random data that can cause flaky tests
- No `now()` or `today()` without time freezing
- No shared state between tests
- Each test cleans up after itself
- Factories use sequences for unique data where needed

## R9 — Template-Led Testing

TESTER always checks `templates/testing/` before generating tests:

1. Does a template exist for this type? → Use it.
2. Is there a business flow template matching the feature? → Map to it.
3. User asks "create template for X" → Write to `templates/testing/X.md`.
4. User asks "test X" → Look for `templates/testing/X.md` → Generate from it.

## R10 — Coverage Targets

| Area | Minimum |
|------|---------|
| API endpoints | 80%+ |
| Business logic | 90%+ |
| Error handling | 90%+ |
| Database queries | 80%+ |
| Performance (critical paths) | 100% of thresholds |
| Code quality checks | All public methods |

## R11 — Test File Organization

```
tests/
├── Feature/
│   ├── Api/V1/          ← API endpoint tests (one per endpoint)
│   └── Flows/           ← Business flow tests (one per flow)
├── Unit/
│   ├── Queries/         ← Database query tests
│   ├── CodeQuality/     ← Naming, SOLID, duplication checks
│   └── Services/        ← Service/class unit tests
└── Performance/         ← Response time and load benchmarks
```
