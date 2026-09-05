# Test Case Template

> Scaffold for `test-cases/active/PLAN-XXXX/TC-YYYY.md`. See `INSTRUCTIONS.md` §5.

```markdown
# TC-YYYY — {{title}}

**Plan:** PLAN-XXXX
**Status:** PENDING
**Purpose:** {{what this verifies}}
**Related task:** {{TASKS.md id}}
**Related code/component:** {{paths}}

## Preconditions
- ...

## Input
- ...

## Steps
1. ...

## Expected result
- ...

## Actual result
- (filled at execution)

## Execution
- **Date:**
- **Executor/agent:**
- **Notes:**

## Failure information
- (filled when FAILED: error, cause, fix, re-run verdict)
```
```

Statuses: `PENDING RUNNING PASSED FAILED BLOCKED SKIPPED`. Required cases unresolved ⇒ plan cannot complete. Group dir holds `INDEX.md` mapping TC → task → status.
