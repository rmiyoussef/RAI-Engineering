# Test-Driven Development (TDD)

> **Source:** Adapted from mattpocock/skills (tdd), addyosmani (test-driven-development), obra/superpowers (test-driven-development)
> **Domain:** Shared — Cross-Domain
> **Use when:** Implementing new features, fixing bugs, refactoring, or changing behavior.

---

## The Iron Law

**No production code without a failing test first.**

If you write code before the test, you must delete it and start over. No keeping it as reference, no adapting it, no looking at it.

## Red-Green-Refactor Cycle

```
RED ──► Verify RED ──► GREEN ──► Verify GREEN ──► REFACTOR ──► Next
 │                          │
 └── Write one test         └── Write minimal code to pass
     that will fail             Test must be the simplest thing
```

### RED — Write the Failing Test

- Test one behavior per test (if "and" is in the name, split it)
- Test through public interfaces, not implementation details
- Use real code, not mocks (unless the dependency is truly external — Stripe, Twilio, etc.)
- Descriptive test name: `test_it_returns_404_when_user_not_found`

### Verify RED — Mandatory

Run the test. Confirm it fails for the **expected reason** (feature missing), not a typo. If it passes, you're testing existing behavior. If it errors, fix the error.

### GREEN — Write Minimal Code

Write the simplest code to pass the test. No extra features, no "while we're here." Don't add configurable backoff, don't extract helpers, don't refactor other code.

### Verify GREEN — Mandatory

Confirm:
- The test passes
- All other tests still pass
- Output is clean (no warnings)

### REFACTOR

Clean up: improve names, extract helpers, remove duplication. But:
- Keep tests green throughout
- Don't add behavior
- Don't change interfaces that tests cover

## The Prove-It Pattern (Bug Fixes)

1. Write a test that reproduces the bug
2. Confirm it fails (proves the bug exists)
3. Implement the fix
4. Confirm it passes (proves the fix works)
5. Never fix bugs without a test

## Good Tests

| Property | Description |
|----------|-------------|
| **Minimal** | Test one thing. Split tests with "and" in the name. |
| **Clear** | Name describes behavior, not implementation |
| **Shows intent** | Demonstrates the desired API from the caller's perspective |
| **DAMP over DRY** | Duplication in tests is acceptable when it makes each test independently understandable |
| **Real implementations** | Prefer real code over mocks. Mock only truly external dependencies. |

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Implementation-coupled | Tests break on refactor when behavior hasn't changed | Test public interfaces only |
| Tautological assertions | Expected value recomputed the same way as code | Hard-code expected values from independent source |
| Horizontal slicing | All tests first, then all implementation | Vertical slices: one test → one implementation → repeat |
| Testing framework code | Tests that verify the framework works | Remove — the framework tests itself |

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "Too simple to test" | Simple things break in production too |
| "I'll test after" | Tests-after pass immediately — proves nothing about catching bugs |
| "Already manually tested" | Manual testing is ad-hoc with no record |
| "Delete hours of work is wasteful" | Sunk cost fallacy. Keeping untrustworthy code wastes more. |
| "TDD is dogmatic" | TDD is pragmatic — finds bugs before commit, prevents regressions, documents behavior, enables refactoring |

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the API you wish you had |
| Test too complicated | Simplify the design |
| Need mocks | Use dependency injection |
| Large test setup | Extract test helpers |

## Verification Checklist

- [ ] Every function/method has a test
- [ ] Each test was watched fail before implementing (for the expected reason)
- [ ] Implementation code is minimal to pass the test
- [ ] All tests pass with clean output
- [ ] Tests use real implementations, not mocks (for in-process dependencies)
- [ ] Edge cases and errors covered
