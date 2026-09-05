# Plan Template

> Scaffold for `plans/active/PLAN-XXXX/PLAN.md`. See `INSTRUCTIONS.md` §3.

```markdown
# PLAN-XXXX — {{title}}

**Objective:** {{one sentence}}
**Status:** active
**Owner:** {{agent/user}}
**Created:** {{YYYY-MM-DD}}

## Problem
{{what and why}}

## Scope / Non-goals
- In scope: ...
- Non-goals: ...

## Requirements
- [ ] R1 ...

## Relevant context
- context/..., knowledge/..., memory/decisions/... (links)

## Affected areas
- {{files/components}} (domains: [backend, frontend, ...] as metadata)

## Technical approach
{{how}}

## Architecture considerations
{{patterns, constraints from rules/<purpose>/}}

## Dependencies
- ...

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|

## Tasks
See TASKS.md. Each task has acceptance criteria + covering TC IDs.

## Required test cases
See test-cases/active/PLAN-XXXX/INDEX.md. Initial test strategy defined during planning.

## Completion requirements
Completion contract (`INSTRUCTIONS.md` §8) checklist state.
```
```

Plan directory also contains: `TASKS.md` (task list w/ acceptance criteria + TC links), `CONTEXT.md` (loaded context snapshot), `DECISIONS.md` (plan-level decisions log), `TEST-PLAN.md` (test strategy: coverage map task→TC, required vs optional cases, execution order), `STATUS.md` (current state + blocker reasons).
