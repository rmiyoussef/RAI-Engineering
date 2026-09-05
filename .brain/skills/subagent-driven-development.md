# Subagent-Driven Development (SDD)

> **Source:** Adapted from obra/superpowers (subagent-driven-development)
> **Domain:** Shared — Cross-Domain
> **Use when:** Executing a written implementation plan with multiple tasks. Fresh subagent per task for isolation and quality.

---

## Core Flow

```
Plan → Extract Tasks → Per Task: Implementer → Reviewer → Fix (if needed)
                                                       ↓
                                              All tasks done?
                                                       ↓
                                              Final branch review
```

## Process

### 1. Read the Plan, Extract All Tasks

Read the full implementation plan up front. Extract every task into a tracking ledger.

### 2. Per Task: Implementer Subagent

Dispatch a fresh subagent per task. Give them:
- **Task brief** — exact what to build, not the full plan (keeps focus)
- **Context** — relevant files, interfaces from earlier tasks
- **Constraints** — TDD, single responsibility, project conventions

The implementer:
1. Implements the code (following TDD where appropriate)
2. Writes tests
3. Verifies (run test, build, lint)
4. Commits
5. Self-reviews

### 3. Per Task: Reviewer Subagent

After each task completes, generate a review package (diff + brief) and dispatch a reviewer subagent. The reviewer checks:

**Spec Compliance:**
- Missing features
- Extra/unasked-for features
- Misunderstandings of requirements

**Code Quality:**
- Separation of concerns
- Error handling
- DRYness / unnecessary duplication
- Edge cases
- Test quality
- File structure

### 4. Fix Loop

If the reviewer finds issues, dispatch a fix subagent for the same task, then re-review. Max 3 iterations before escalating.

### 5. Final Branch Review

After all tasks complete, dispatch a final whole-branch reviewer. This reviewer sees the full diff and checks for:
- Cross-task consistency
- Integration issues
- Overall architecture fit

### 6. Finish

Use the finishing-a-development-branch workflow to merge/PR.

## Key Rules

| Rule | Why |
|------|-----|
| Fresh subagent per task | No context bleed, no conversation bloat |
| Never skip either verdict | Spec + Quality, both required |
| Track in a ledger file | Conversation memory is lost to compaction |
| Never parallelize implementation subagents | Sequential tasks prevent conflicts |
| Pre-flight scan for contradictions | Catch plan issues before execution |

## Model Selection

| Task Type | Model |
|-----------|-------|
| Mechanical / boilerplate | Cheap/fast |
| Standard integration | Standard |
| Architecture / design | Most capable |
| Final branch review | Most capable |

**Note:** Turn count beats token price. A cheap model taking many turns can cost more overall than a capable model finishing in fewer turns.

## Verification Checklist

- [ ] All tasks extracted from plan
- [ ] Each task brief written with exact interfaces and exit criteria
- [ ] Per-task implementer dispatched and completed
- [ ] Per-task review completed (spec + quality)
- [ ] Fix loops closed (max 3 iterations)
- [ ] Final branch review completed
- [ ] Progress ledger file is up to date
