# Writing Plans

> **Source:** Adapted from obra/superpowers (writing-plans) + addyosmani (planning-and-task-breakdown)
> **Domain:** Shared — Cross-Domain
> **Use when:** You have a spec or requirements for a multi-step task, before touching code.

---

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for the codebase and questionable taste. Document everything: which files to touch, exact code, testing approach. Give them the whole plan as bite-sized tasks.

## Scope Check

If the spec covers multiple independent subsystems, break into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for:

- Design units with clear boundaries and well-defined interfaces
- Prefer smaller, focused files over large ones that do too much
- Files that change together should live together
- Follow established patterns in existing codebases

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a fresh reviewer's gate.

| Size | Files | Scope |
|------|-------|-------|
| XS | 1 | Single function/config change |
| S | 1-2 | One component/endpoint |
| M | 3-5 | One feature slice |
| L | 5-8 | Multi-component feature |
| XL | 8+ | Too large — break it down further |

Agents perform best on **S and M** tasks. A task is too large if it takes 2+ hours, has more than 3 acceptance criteria, or has "and" in its title.

## Plan Document Header

Every plan starts with:

```markdown
# [Feature] Implementation Plan

**Goal:** [One sentence describing what this builds]
**Architecture:** [2-3 sentences about approach]
**Tech Stack:** [Key technologies/libraries]

## Global Constraints
[Project-wide requirements — version floors, naming rules, platform requirements]

---
```

## Task Structure

Each task includes:
- **Files** — exact paths (Create:, Modify:, Test:)
- **Interfaces** — what this consumes from earlier tasks and produces for later ones
- **Steps** — each step is one action (2-5 minutes)
- **Verification** — exact commands and expected output at each step

## No Placeholders

Plan failures — never write:
- "TBD", "TODO", "implement later"
- "Add appropriate error handling" (without specifics)
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — engineer may read tasks out of order)

## Self-Review

After writing the complete plan:
1. **Spec coverage:** Can you point to a task for every requirement?
2. **Placeholder scan:** Any of the patterns above?
3. **Type consistency:** Do signatures in later tasks match earlier definitions?

## Dependency Graph

Map what depends on what. Build bottom-up:
- Independent feature slices → parallelize
- Database migrations → sequential
- Shared API contracts → define first, then parallelize

## Output Files

- `tasks/plan.md` — The implementation plan document
- `tasks/todo.md` — The checklist-style task list

## Verification Checklist

- [ ] Every task has acceptance criteria
- [ ] Every task has verification steps
- [ ] Dependencies are ordered correctly
- [ ] No task exceeds ~5 files
- [ ] Checkpoints exist every 2-3 tasks
- [ ] Human has approved before execution begins
