# Code Simplification

> **Source:** Adapted from addyosmani (code-simplification)
> **Domain:** Shared — Cross-Domain
> **Use when:** After features are working but feel heavier than needed, or during code review with readability issues.

---

## Five Principles

### 1. Preserve Behavior Exactly
Don't change what code does, only how it expresses it. Before every change, verify output, error behavior, side effects, and test compatibility remain identical.

### 2. Follow Project Conventions
Match the existing codebase's style for imports, naming, error handling. Simplification that breaks project consistency is not simplification — it's churn.

### 3. Prefer Clarity Over Cleverness
Explicit code beats compact code when the compact version requires a mental pause. Replace dense ternary chains with readable if/else mappings. Replace chained reduces with named intermediate steps.

### 4. Maintain Balance
Avoid over-simplification traps:
- Inlining helpers that named a concept
- Combining unrelated logic
- Removing abstractions that served extensibility
- Optimizing for line count rather than comprehension

### 5. Scope to What Changed
Default to simplifying recently modified code only. Unscoped refactoring creates noise in diffs and risks unintended regressions.

## Process

### Step 1: Understand Before Touching (Chesterton's Fence)
Before changing anything, understand why it exists. Investigate the code's responsibility, callers, callees, edge cases, tests, and git history.

### Step 2: Identify Opportunities

| Signal | What to Check |
|--------|---------------|
| Deep nesting | Can early returns or guard clauses flatten this? |
| Long functions | Can this be split by responsibility? |
| Nested ternaries | Would a mapping or if/else be clearer? |
| Boolean parameter flags | Does the function do two different things? |
| Repeated conditionals | Missing model or dispatcher? |
| Generic/abbreviated names | Can this be more descriptive? |
| Comments explaining "what" | Can the code itself express this? |
| Duplicated logic | Extract once, reference everywhere |
| Dead code | Remove it |
| Unnecessary abstractions | If it has one implementation and one caller, inline it |

### Step 3: Apply Changes Incrementally
- One simplification at a time with tests after each
- Separate refactoring from feature changes
- If a refactoring exceeds 500 lines, stop — automate rather than hand-edit

### Step 4: Verify the Result
- All tests still pass
- Build succeeds
- Lint/type check passes
- Clean diff (no unrelated changes)
- Conforms to project conventions

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "Fewer lines is always simpler" | Simplicity is about comprehension speed, not line count |
| "This abstraction might be useful later" | Remove speculative abstractions. Add when needed. |
| "I'll refactor while adding this feature" | Separate the concerns. One change per commit. |
| "The types make it self-documenting" | Types document structure, not intent |

## Verification Checklist

- [ ] All tests pass
- [ ] Build succeeds
- [ ] Lint/format clean
- [ ] Changes are incremental and reviewable
- [ ] Diff is clean (no unrelated changes)
- [ ] Error handling preserved
- [ ] No dead code left behind
