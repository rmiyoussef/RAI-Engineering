# .brain INSTRUCTIONS

> Operational authority for AI agents. Structural authority is `ARCHITECTURE.md`. Navigation map is `INDEX.md`. Follow this file literally; deviations require a decision record.

## 1. Session Boot (Mandatory)

Entering an RAI-managed project (a project containing `.brain`) means following this sequence. No exceptions.

```
[1] LOCATE .brain (project root).
[2] READ .brain/ARCHITECTURE.md + .brain/INSTRUCTIONS.md (this file).
[3] READ current brain state (.brain/state/current.yaml + plans.yaml + tests.yaml).
[4] LOAD relevant rules (.brain/rules/<purpose>/, selected by sub-task).
[5] LOAD relevant context (.brain/context/).
[6] LOAD relevant knowledge (.brain/knowledge/, domains: filter as metadata).
[7] LOAD relevant memory (.brain/memory/decisions|discoveries|lessons touching affected areas).
[8] DETERMINE whether an active plan exists; continue it or create the appropriate plan.
[9] LOAD agent definitions (.brain/agents/{NAME}.md) only for agents this task needs.
[10] CHECK skill triggers; load matching skills before coding. Re-check per sub-task.
```

Progressive disclosure throughout — never read the whole brain. Details per §2 below (kept for precision):

```
[A] READ .brain/INDEX.md — locate relevant context/rules/knowledge/memory.
[B] LOAD selectively: context/ files; rules/<purpose>/; knowledge/ (domains: filter);
    memory/ decisions/discoveries/lessons; active plan dir (plans/active/<plan-id>/)
    + its test-cases/active/<plan-id>/.
```

Old behavior this replaces: deriving a single domain then reading `.brain/{domain}/`. Domains are metadata now. A task touching backend+frontend+security loads rules from `rules/api/`, `rules/security/`, knowledge tagged accordingly — never a domain subtree.

## 2. Before Planning

- Read ARCHITECTURE.md + INSTRUCTIONS.md + relevant context/rules/knowledge/memory (per §1).
- Check `state/plans.yaml` for conflicting active plans and next plan ID.
- If project context missing (no `context/PROJECT.md` facts for affected area), load ARCHITECT to create it before planning.
- Never plan from the request text alone when memory exists for the affected areas (R8).

## 3. During Planning (PLANNER)

Produce `plans/active/<plan-id>/` with `PLAN.md TASKS.md CONTEXT.md DECISIONS.md TEST-PLAN.md STATUS.md` per `templates/plan/PLAN_TEMPLATE.md`. Every plan contains: ID, title, objective, problem, scope, non-goals, requirements, relevant context links, affected areas, technical approach, architecture considerations, dependencies, risks, tasks with acceptance criteria, required test cases (initial test strategy — see §4), status. The plan MUST hold enough for another agent to continue without the original conversation.

### When planning is required

New features, architectural changes, database changes, multi-file changes, complex bug fixes, refactors, infrastructure changes, security changes, significant performance work. Planning signals from the user ("plan this", "create a plan", "design this", "how should we implement this", "break this down") MUST produce a persistent plan under `plans/` — never chat-only plans.

### When planning may be skipped

Typo fixes, formatting, simple one-line changes, explicit trivial fixes, documentation corrections — especially when the user says so ("do not create a plan, just fix this typo"). Mandatory when applicable, never blind bureaucracy. Relevant rules and testing requirements still apply.

Test strategy is part of planning, not an afterthought:

```
Requirement → Analysis → Plan → Tasks → Acceptance Criteria → Test Cases
```

PLANNER writes the initial TC files (`test-cases/active/<plan-id>/TC-*.md` + `INDEX.md`) from `templates/test-case/TC_TEMPLATE.md` before handoff to EXECUTOR. Tests influence the plan: if something cannot be verified, replan until it can. Unverifiable requirements are flagged, never silently accepted.

## 4. During Implementation (EXECUTOR + specialists)

- Find the active plan first (`state/current.yaml` → `plans/active/`). Load plan + related test cases, then implement, run tests, update results. No active plan for non-trivial work ⇒ create one (§3) before coding.
- Follow the plan. Update `TASKS.md` + `STATUS.md` + `state/tasks.yaml` as tasks progress.
- Record important decisions in plan `DECISIONS.md` immediately. Never silently change an architectural decision: propose, record, get approval.
- Consult specialists (DATABASE, SECURITY, REVIEWER) mid-write per CLAUDE.md routing; relay through the message protocol.
- Failed test case ⇒ fix code, re-run, record in TC file. Never edit a TC's expected result to match buggy output without a decision record.

## 5. Test Execution (TESTER)

- Execute every required TC. Record inside each TC file: actual result, status (`PENDING RUNNING PASSED FAILED BLOCKED SKIPPED`), execution date, executor/agent, failure information, related task/code.
- Move failing cases to `test-cases/failed/` state tracking; fix loop max 3 iterations (R45), then escalate.
- Required TCs unresolved ⇒ plan stays incomplete. No exceptions, no waivers without user approval recorded in `DECISIONS.md`.

## 6. After Implementation

```
Execute test cases → verify acceptance criteria → record test results → fix failures → re-run affected tests
```

REVIEWER scores; score < 7 returns to EXECUTOR (max 3 cycles). BACKEND QA / SECURITY / DATABASE audit when their areas touched.

## 7. After Successful Completion

```
Generate summary → record decisions/discoveries/lessons → mark plan complete → mark test cases complete → update state
```

- SUMMARY writes `summaries/completed/<plan-id>.md` per `templates/summary/PLAN_SUMMARY.md` (objective, changes, decisions, files affected, tests + results, limitations, lessons, recommendations).
- MEMORY SCRIBE persists `memory/decisions|discoveries|lessons/` entries, moves plan → `plans/completed/`, TCs → `test-cases/completed/`, updates `state/*.yaml`, refreshes `TIMELINE.md` data.
- ARCHITECT promotes timeless findings into `knowledge/` and refreshes `context/` if architecture changed.

## 8. Plan Completion Contract

Status `COMPLETED` if and only if:

```
PLAN EXISTS AND TASKS COMPLETED AND REQUIRED TEST CASES EXIST AND TEST CASES EXECUTED
AND CRITICAL TESTS PASSED AND ACCEPTANCE CRITERIA VERIFIED AND SUMMARY GENERATED
AND IMPORTANT DECISIONS RECORDED
```

Missing any condition ⇒ status is not COMPLETED (`active` or `blocked` with reason in STATUS.md). Implementation alone never completes a plan. Definition of done:

> Implemented + Verified + Tested + Documented + Summarized + Brain Updated.

## 9. Traceability

Maintain the chain `<plan-id> → TASK → TC-NN → result → SUMMARY → decision/memory → knowledge` using IDs in every artifact. A future agent must navigate plan → tasks → tests → results → summary → decisions → knowledge without reading session history.

## 10. State Discipline

- `state/` files are pointers only. Update them at lifecycle transitions. Never store prose in state.
- Conflict between `state/` and artifacts: artifacts win; fix state and note it in the session log.

## 11. Prohibited

- Organizing new knowledge by technical domain directories (`backend/`, `frontend/`, ...). Use `domains:` frontmatter.
- Marking plans complete without test execution + summary.
- Duplicating project knowledge into agent/skill files instead of referencing `.brain`.
- Creating files merely to fill out the structure. Every file needs a purpose.
- Bypassing the brain: if `.brain` exists, do NOT create an independent planning/memory/testing system (no `random-plan.md`, `TODO.md`, `implementation-plan.md`, `ai-notes.md`, `agent-memory.md` outside the brain) unless the user explicitly requests it. Brain-owned content lives in `plans/`, `test-cases/`, `summaries/`, `memory/`.
- Saying "done" before verifying implementation + tests + acceptance criteria + summary + brain updates (§8).
