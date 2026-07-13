# TEST PLAN TEMPLATE

> **Use:** Master template for planning any test task.
> **Location:** `templates/testing/TEST_PLAN_TEMPLATE.md`

---

## 1. Test Objective

```
What feature/fix/endpoint is being tested?
Why is this important? What risk does it cover?
```

## 2. Areas to Test

| Area | Included? | Priority |
|------|-----------|----------|
| API Endpoints | ☐ Yes / ☐ No | P0/P1/P2 |
| Business Flow | ☐ Yes / ☐ No | P0/P1/P2 |
| Database Queries | ☐ Yes / ☐ No | P0/P1/P2 |
| Performance | ☐ Yes / ☐ No | P0/P1/P2 |
| Code Quality | ☐ Yes / ☐ No | P0/P1/P2 |

## 3. Coverage Matrix

| Scenario | Status | Notes |
|----------|--------|-------|
| Happy Path | ☐ Covered | |
| Validation Errors | ☐ Covered | |
| Auth Failures | ☐ Covered | |
| Forbidden | ☐ Covered | |
| Not Found | ☐ Covered | |
| Edge Cases | ☐ Covered | |
| Idempotency | ☐ Covered | |

## 4. Test Files to Create/Update

```
☐ tests/Feature/...
☐ tests/Unit/...
☐ tests/Performance/...
```

## 5. Dependencies

```
- Factories: [which models need factories]
- Mock Services: [which services to mock]
- Test Data: [specific test data needed]
```

## 6. Coverage Target

```
Lines:     ☐ 90%+   ☐ 80%+   ☐ 70%+
Branches:  ☐ 90%+   ☐ 80%+   ☐ 70%+
APIs:      ☐ All    ☐ Critical only
```

## 7. Output

```json
{
  "testPlan": "templates/testing/TEST_PLAN_TEMPLATE.md",
  "testGenerated": 8,
  "testPassed": 8,
  "coverage": {
    "lines": "85%",
    "branches": "80%"
  },
  "templatesUsed": ["API_ENDPOINT", "BUSINESS_FLOW"],
  "blockersFound": 0,
  "notes": "All scenarios covered. No security issues found."
}
```
