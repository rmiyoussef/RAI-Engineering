# Dispatching Parallel Agents

> **Source:** Adapted from obra/superpowers (dispatching-parallel-agents)
> **Domain:** Shared — Cross-Domain
> **Use when:** Facing multiple independent tasks that don't require shared state or sequential dependencies.

---

## Core Concept

Delegate tasks to specialized agents with isolated context. Each agent receives precisely crafted instructions — they should never inherit your session's context or history. You construct exactly what they need, preserving your own context for coordination.

## When to Use

| Use When | Don't Use When |
|----------|----------------|
| 3+ test files failing with different root causes | Failures are related/interdependent |
| Multiple independent subsystems broken | Need to understand full system state first |
| Problems can be understood without cross-context | Agents would interfere with each other |
| Clear division of responsibility | Sequential dependency required |

## Pattern (4 Steps)

### 1. Identify Independent Domains

Group failures/tasks by what's broken — each group should require no context from the others.

### 2. Create Focused Agent Tasks

Each agent gets a specific scope, clear goal, constraints, and expected output format. Good prompts are:
- **Focused** — one domain per agent
- **Self-contained** — include exact error messages, file paths, test names
- **Specific about output** — "Return root cause and fix as a summary"
- **Constrained** — "Do NOT just increase timeouts — find the real issue"

### 3. Dispatch in Parallel

Issue all subagent dispatches in the same response. Multiple dispatch calls in one response = parallel execution.

### 4. Review and Integrate

- Read summaries from each agent
- Verify no conflicts between changes
- Run full test suite
- Integrate changes

## Prompt Structure

```
Scope: [exactly what this agent should investigate]
Goal: [what success looks like]
Context: [error messages, file paths, relevant code]
Constraints: [what NOT to do, boundaries]
Output: [expected format — summary, root cause, changes]
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Too broad scope | Split into independent concerns |
| No context given | Include exact error messages and file paths |
| No constraints | Set explicit boundaries |
| Vague output expectations | Specify exact summary format |

## Verification Steps

- [ ] All agent summaries read and understood
- [ ] No conflicts between agent changes
- [ ] Full test suite passes
- [ ] Spot-check since agents can make systematic errors
