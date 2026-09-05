# Systematic Debugging

> **Source:** Adapted from obra/superpowers (systematic-debugging) + addyosmani (debugging-and-error-recovery)
> **Domain:** Shared — Cross-Domain
> **Use when:** Any bug, test failure, or unexpected behavior — before proposing fixes.

---

## The Iron Law

**Always find root cause before attempting fixes. Symptom fixes are failure.**

## The Four Phases

### Phase 1 — Build a Feedback Loop

Before theorizing, construct a tight, deterministic, pass/fail signal:

- Failing test, curl command, CLI invocation, headless browser script
- Must be red-capable (fails when bug is present, passes when fixed)
- **No red-capable command? No Phase 2.**

### Phase 2 — Reproduce + Minimise

1. Run the loop to confirm the symptom
2. Shrink inputs/config/steps until every remaining element is load-bearing
3. For non-reproducible bugs: check timing-dependence, environment-dependence, state-dependence, randomness

### Phase 3 — Hypothesise

Generate 3-5 falsifiable hypotheses with testable predictions before testing any. Show the ranked list.

### Phase 4 — Instrument

- Change one variable at a time
- Prefer debugger/REPL over print/log statements
- Tag debug logs with unique prefixes for cleanup

### Phase 5 — Fix + Regression Test

1. Write the regression test **before** the fix
2. Fix at a correct seam that exercises the real bug pattern
3. If no such seam exists, flag the architectural issue

### Phase 6 — Cleanup + Post-Mortem

- Verify the fix
- Remove instrumentation, delete throwaway code
- State the correct hypothesis in the commit
- Ask: "What would have prevented this bug?"

## Stop-The-Line Rule

When tests fail, builds break, or behavior doesn't match expectations:

1. **STOP** adding features
2. **Preserve** evidence (error output, stack trace, state)
3. **Diagnose** following the phases above
4. **Fix** root cause, not symptom
5. **Guard** with regression test
6. **Resume**

## Error-Specific Patterns

| Error Type | First Check |
|------------|-------------|
| Test failure | Is it a real failure or flaky? Run 3x. |
| Build failure | Type error? Import error? Config error? |
| TypeError (runtime) | What's the actual type vs expected? |
| Network/CORS | Check request/response in devtools |
| White screen | Check console for JS errors |

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "I know what the bug is" | Verify with evidence first |
| "It works on my machine" | Environment difference IS the bug |
| "Quick fix for now" | Symptom fixes compound into unmaintainable code |
| "We'll refactor later" | No you won't. Fix it properly now. |

## Verification Checklist

- [ ] Root cause documented before fix attempted
- [ ] Symptom vs. cause distinguished (fix addresses cause)
- [ ] Regression test written (fails without fix, passes with it)
- [ ] All existing tests still pass
- [ ] Build succeeds
- [ ] Instrumentation code removed
