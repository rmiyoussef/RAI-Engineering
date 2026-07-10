# Standard Development Workflow

> This workflow is the default execution pipeline for all development tasks.
> It orchestrates Brain → Planner → Executor → Reviewer → Tester → Memory Scribe.

---

## Overview

```
User Task
   │
   ├─► [BRAIN] Load context (rules, memory, skills)
   │
   ├─► [PLANNER] Return structured plan
   │
   ├─► [BRAIN] Validate plan, write decision to memory
   │
   ├─► [EXECUTOR] Write code per plan
   │
   ├─► [REVIEWER] Review code, return issues + score
   │     │
   │     ├─ Score < 7 ──► [EXECUTOR] Fix issues → [REVIEWER] re-review
   │     │                    (max 3 iterations, then escalate)
   │     │
   │     └─ Score >= 7 ──► proceed
   │
   ├─► [BACKEND QA] (if backend code changed)
   │     │          Deep audit: clean code, queries, security, tests
   │     │
   │     ├─ Dimension fails ──► [EXECUTOR] Fix → [BACKEND QA] re-audit
   │     │                         (max 5 iterations, then escalate)
   │     │
   │     └─ All pass ──► proceed
   │
   ├─► [TESTER] Run tests
   │     │
   │     ├─ Tests fail ──► [EXECUTOR] Fix → [TESTER] re-run
   │     │
   │     └─ Tests pass ──► proceed
   │
   ├─► [MEMORY SCRIBE] Write decisions, lessons, architecture updates
   │
   └─► [BRAIN] Respond to user with summary
```

---

## When to Use

This workflow runs on every task that involves changing code:
- New features
- Bug fixes
- Refactoring
- Performance improvements
- Dependency updates
- Documentation updates

For read-only tasks (questions, exploration), skip to Planner → respond directly.

---

## Workflow Steps

### Phase 1: Context Loading

```
BRAIN loads:
├── Rules              → brain/RULES.md
├── Mission            → brain/MISSION.md
├── Principles         → brain/PRINCIPLES.md
├── Limitations        → brain/LIMITATIONS.md
└── Project Memory
    ├── decisions/     → past architecture decisions
    ├── architecture/  → current system map
    ├── lessons/       → known pitfalls and patterns
    └── sessions/      → recent session context
```

**Output:** Enhanced task prompt with full project context.

### Phase 2: Planning

```
PLANNER receives:
├── User request
├── Project memory context
└── Relevant skills

PLANNER returns:
├── goal:              What we're accomplishing
├── affectedFiles:     Files to create/modify
├── risks:             Risks and assumptions
├── dependencies:      What must exist first
├── executionPlan:     Step-by-step implementation
└── questions:         Open questions for the user
```

**Validation:** Brain checks all fields are present. If `risks` is empty, PLANNER must justify.

**Memory hook:** If a similar plan exists in `memory/decisions/`, flag it to the user.

### Phase 3: Decision Recording

```
BRAIN writes to memory/decisions/<date>-<slug>.md:
├── decision:          What was decided
├── context:           Why this matters
├── options:           Alternatives considered
├── chosen:            Which option was selected
├── rationale:         Why this option was chosen
└── date:              Today's date
```

### Phase 4: Execution

```
EXECUTOR receives:
├── Execution plan (from PLANNER)
├── Affected files list
├── Relevant skills
└── Project memory context

EXECUTOR returns:
├── filesChanged:      List of files modified/created
├── testResults:       Summary of test outcomes
├── lintResults:       Lint/format check results
└── status:            success | partial_failure | blocked
```

### Phase 5: Review

```
REVIEWER receives:
├── Original plan
├── Changed files (diff)
├── Test results
└── Code review skill

REVIEWER returns:
├── issues:            List of problems found [ { file, line, severity, description } ]
├── suggestions:       Improvement suggestions
├── performance:       Performance assessment
├── security:          Security assessment
└── score:             Overall score (1-10)
```

**Fix loop:**
- Score 1-6: Route to EXECUTOR with `fixedIssues` list
- Score 7-8: Accept, flag suggestions for future
- Score 9-10: Accept, no follow-up

**Max iterations:** 3. After 3 failed reviews, escalate to user.

### Phase 6: Testing

```
TESTER receives:
├── Changed files
├── Test files (new + existing)
└── Testing skill

TESTER returns:
├── testResults:       Pass/fail per test
├── coverage:          Coverage assessment
└── status:            passed | failed | skipped
```

**On failure:** Route to EXECUTOR with test failures, re-run tests after fix.

### Phase 7: Memory Recording

```
MEMORY SCRIBE receives:
├── Plan (from PLANNER)
├── What was built (from EXECUTOR)
├── Review outcome (from REVIEWER)
├── Test results (from TESTER)
└── Project memory context

MEMORY SCRIBE writes:
├── memory/decisions/<date>-<slug>.md      → architecture decisions
├── memory/lessons/<date>-<slug>.md        → what was learned
├── memory/architecture/<component>.md     → update if structure changed
└── memory/sessions/<date>-<slug>.md       → session summary
```

### Phase 8: Response

```
BRAIN returns to user:
├── What was done
├── Files changed
├── Review score
├── Test results
├── Memory written
└── Open questions / next steps
```

---

## GitHub Workflow (Optional)

When a GitHub PR is requested:

```
After Phase 7 (memory written):

GITHUB receives:
├── Plan
├── Changed files
├── Review results
├── Test results
└── Memory entries

GITHUB returns:
├── branch:            Branch name created
├── prUrl:             PR URL
├── status:            open | merged | draft
└── issues:            Any remaining issues noted in PR
```

---

## Workflow Variants

### Read-only (Question / Exploration)

```
Phase 1: Context loading
Phase 2: Planning (light — just goal and files to read)
Phase 8: Response (skip execution, review, testing, memory)
```

### Quick Fix (Small, Well-Defined)

```
Phase 1: Context loading
Phase 2: Planning (minimal — goal, files, plan only)
Phase 4: Execution
Phase 5: Review
Phase 6: Testing
Phase 7: Memory recording
Phase 8: Response
```

### Full Feature (Complex, Multi-File)

```
Complete pipeline with all phases. May include multiple execution-review loops
for different parts of the feature (backend first, then frontend).
```
