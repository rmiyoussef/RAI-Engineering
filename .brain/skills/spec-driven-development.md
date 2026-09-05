# Spec-Driven Development

> **Source:** Adapted from addyosmani (spec-driven-development)
> **Domain:** Shared — Cross-Domain
> **Use when:** Starting new projects, ambiguous requirements, multi-file changes, or any task exceeding ~30 minutes.

---

## Overview

Code without a spec is guessing. Spec-driven development establishes a four-phase, gated workflow before writing any code.

## The Four Phases

Each phase requires human approval before advancing.

### Phase 1: Specify

Surface assumptions explicitly ("I'm assuming PostgreSQL — correct me now"). Then write a spec covering:

| Section | What to Include |
|---------|-----------------|
| **Objective** | What are we building? Why? |
| **Commands** | Full executable flags and expected output |
| **Project Structure** | Files and directories |
| **Code Style** | One real snippet showing conventions |
| **Testing Strategy** | How will we verify correctness? |
| **Boundaries** | Always / Ask First / Never |

Spec template with **Success Criteria** and **Open Questions**:
```markdown
# Spec: [Feature Name]

## Objective
[One paragraph on what and why]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Boundaries
- Always: [things the agent should just do]
- Ask First: [things needing human approval]
- Never: [hard prohibitions]

## Open Questions
- [ ] Question 1
```

### Phase 2: Plan

Generate a technical plan identifying components, dependencies, implementation order, risks, and parallelization. Save to `tasks/plan.md`.

### Phase 3: Tasks

Break the plan into small, ordered tasks (each ≤ ~5 files) with explicit acceptance criteria and verification steps. Save to `tasks/todo.md`.

### Phase 4: Implement

Execute tasks one at a time, following incremental-implementation and test-driven-development skills.

## Living Document

The spec should be updated when decisions or scope change, committed to version control, and referenced in PRs.

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "It's too simple for a spec" | Simple is where assumptions hide |
| "Specs slow us down" | Debugging wrong implementations is slower |
| "The code is the spec" | Code tells you WHAT, not WHY |

## Verification Checklist

- [ ] Spec covers all six areas (Objective, Commands, Structure, Style, Testing, Boundaries)
- [ ] Spec is human-approved
- [ ] Success criteria are testable
- [ ] Boundaries defined
- [ ] Spec saved to repo
