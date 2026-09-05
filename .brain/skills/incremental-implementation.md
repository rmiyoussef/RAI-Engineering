# Incremental Implementation

> **Source:** Adapted from addyosmani (incremental-implementation)
> **Domain:** Shared — Cross-Domain
> **Use when:** Building multi-file changes, new features from a task breakdown, or any change over ~100 lines.

---

## Overview

Build in thin vertical slices — implement one piece, test it, verify it, then expand. Each increment should leave the system working and testable.

## The Increment Cycle

```
Implement → Test → Verify → Commit → Next slice
```

## Slicing Strategies

| Strategy | When | How |
|----------|------|-----|
| **Vertical Slices (Preferred)** | New features | Complete end-to-end path per slice (DB + API + UI) |
| **Contract-First** | Multiple consumers | Define API contract first, then parallel backend/frontend |
| **Risk-First** | High uncertainty | Tackle the riskiest piece first (prove WebSocket works before building on it) |

## Implementation Rules

### Rule 0: Simplicity First
Three similar lines of code is better than a premature abstraction.

### Rule 0.5: Scope Discipline
Touch only what the task requires. Note external improvements but don't fix them.

### Rule 1: One Thing at a Time
Each increment changes one logical thing.

### Rule 2: Keep It Compilable
Build must pass after each increment.

### Rule 3: Feature Flags for Incomplete Features
Use environment variables or flags to hide unfinished work.

### Rule 4: Safe Defaults
New code should default to safe, conservative behavior.

### Rule 5: Rollback-Friendly
Each increment should be independently revertable.

## Increment Checklist

- [ ] All existing tests pass
- [ ] Build succeeds
- [ ] Type checking and linting pass
- [ ] New functionality works
- [ ] Commit with descriptive message

**Note:** Re-running the same verification command on unchanged code adds no information.

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "I'll test it all at once" | Test each increment. Finding the bug is harder in a big batch. |
| "Doing it all at once is faster" | It isn't. Debugging a 500-line change takes longer than 5 × 100-line changes. |
| "I'll add feature flags later" | Add them when you create the incomplete feature. |
| "This refactor is just cleanup" | Separate refactoring from feature work. |

## Red Flags

- 100+ lines without testing
- Scope expansion (touching files outside the task)
- Skipping verification steps
- Broken builds between increments
- Accumulating large uncommitted changes
- Premature abstractions

## Verification Checklist

- [ ] Each increment was tested and committed
- [ ] Full test suite passes
- [ ] Build is clean
- [ ] Feature works end-to-end
- [ ] No uncommitted changes remain
