# 📋 Memory System & Template Index

> **Purpose:** Everything an AI tool needs to understand this project.
> **How to use:** Start here, identify which domain your task belongs to, then read the relevant subtree.

---

## Domain-Isolated Structure

```
.brain/
├── INDEX.md                              ← You are here
├── README.md                             ← What this folder is
├── TIMELINE.md                           ← Auto-generated memory timeline (run .ai/memory-timeline.py)
├── agents/                               ← Agent definitions (framework-agnostic)
├── brain/                                ← Core system files
├── templates/                            ← Summary & testing templates
├── shared/skills/                        ← Cross-domain skills (27 skills from 6 repos)
├── session-bus/                          ← Inter-session message bus (gitignored)
├── sessions/                             ← Session registry
│
├── backend/                              ← Backend domain
│   ├── README.md
│   ├── memory/guidelines.md              ← Architecture, conventions, stack
│   ├── memory/decisions/                 ← Past architecture decisions
│   ├── memory/architecture/              ← Component maps
│   ├── memory/lessons/                   ← Things learned
│   ├── memory/sessions/                  ← Every interaction logged
│   ├── memory/tests/                     ← Test summaries per feature
│   ├── memory/tasks/                     ← Task summaries with results
│   ├── memory/business/                  ← Business rules
│   ├── rules/                            ← Project rules
│   ├── skills/                           ← Code templates & patterns
│   ├── plans/                            ← Project plans
│   └── connections/                      ← DB connections (gitignored)
│
├── frontend/                             ← Frontend domain
│   ├── README.md
│   ├── INDEX.md                          ← Frontend skills, rules & reference
│   ├── FRONTEND_BEST_PRACTICES.md        ← Human-readable guide (11 rule sets)
│   ├── skills/                           ← UI eng, design, devtools, animations, Mantine
│   ├── rules/                            ← 11 rule files (component, state, perf, a11y, etc.)
│   └── reference/                        ← Mantine UI docs & integration guide
│
├── mobile-ios/                           ← iOS domain (for future projects)
├── mobile-android/                       ← Android domain (for future projects)
│
└── devops/                               ← DevOps domain
    ├── README.md
    ├── DEVOPS_BEST_PRACTICES.md           ← Team-readable guide (13 rule sets)
    ├── skills/                            ← CI/CD automation
    ├── rules/                             ← 13 devops engineering rules
    └── reference/                         ← External docs (coming soon)
```

---

## 🧩 Skills Library

### Shared Skills — `.brain/shared/skills/`

| Skill | Source | Use When |
|-------|--------|----------|
| context-engineering | addyosmani | Structuring what an AI sees; session setup |
| verification-before-completion | obra | Before claiming any task is done |
| systematic-debugging | obra + addyosmani | Any bug, test failure, unexpected behavior |
| test-driven-development | mattpocock + addyosmani + obra | New features, bug fixes, refactoring |
| writing-plans | obra + addyosmani | Multi-step tasks before touching code |
| executing-plans | obra | Working through a written plan inline |
| codebase-design | mattpocock | Designing new modules, evaluating architecture |
| subagent-driven-development | obra | Fresh subagents per task with review gates |
| dispatching-parallel-agents | obra | Multiple independent tasks in parallel |
| brainstorming | obra + addyosmani | Turning vague ideas into actionable specs |
| code-review | addyosmani + mattpocock | Reviewing code changes before merge |
| code-simplification | addyosmani | Simplifying code without changing behavior |
| incremental-implementation | addyosmani | Building in thin vertical slices |
| source-driven-development | addyosmani | Grounding implementation in official docs |
| spec-driven-development | addyosmani | Four-phase gated workflow with specs |
| documentation-and-adrs | addyosmani | Writing ADRs, READMEs, inline docs |
| deprecation-and-migration | addyosmani | Removing old systems, migrating users |
| performance-optimization | addyosmani | Measurement-first performance work |
| shipping-and-launch | addyosmani | Pre-launch checklists, staged rollouts |
| observability-and-instrumentation | addyosmani | Logging, metrics, tracing, alerting |
| domain-modeling | mattpocock | Building shared vocabulary (CONTEXT.md) |
| research | mattpocock | Investigating questions against primary sources |
| prototype | mattpocock | Throwaway code that answers a question |
| resolving-merge-conflicts | mattpocock | In-progress merge/rebase conflicts |
| improve-codebase-architecture | mattpocock | Deepening shallow modules |
| using-git-worktrees | obra | Isolated workspaces for parallel agents |
| finishing-a-development-branch | obra | Merging/pushing/discarding branches |

### Frontend Skills — `.brain/frontend/skills/`

| Skill | Source | Use When |
|-------|--------|----------|
| frontend-ui-engineering | addyosmani | Production-quality, accessible UIs |
| design-engineering | emilkowalski | Design-system-driven, animation-rich UIs |
| animation-vocabulary | emilkowalski | CSS transitions, Framer Motion, gestures |
| apple-design-principles | emilkowalski | iOS/macOS design language |
| frontend-design-principles | anthropics | UI design fundamentals |
| browser-testing-with-devtools | addyosmani | Testing UI in browser devtools |
| mantine | — | Mantine UI component reference, theming |

### Backend Skills — `.brain/backend/skills/`

| Skill | Use When |
|-------|----------|
| service.md | Creating a service class with transactions |
| controller.md | Creating a thin HTTP controller |
| resource.md | Creating an API resource transformer |
| crud.md | Generating full CRUD (migration → model → service → controller → routes → tests) |

### DevOps Skills — `.brain/devops/skills/`

| Skill | Use When |
|-------|----------|
| ci-cd-and-automation.md | Setting up CI/CD pipelines, automation scripts |

---

## 📝 Template Catalog

### Testing Templates — `.brain/templates/testing/`

| Template | Use When | Scenarios |
|----------|----------|-----------|
| API_ENDPOINT.md | Testing a single API endpoint | Happy path, validation, auth, not found, edge cases, idempotency (15+) |
| BUSINESS_FLOW.md | Testing a multi-step business flow | Full flow, partial failures, auth per step, final DB state |
| DATABASE_QUERY.md | Testing database queries | N+1 detection, index checks, migration safety, query performance |
| DATABASE_MIGRATION.md | Testing database migrations | Up/down idempotency, index integrity, foreign keys, defaults, data migration safety (7 scenarios) |
| PERFORMANCE.md | Performance benchmarking | Response time benchmarks, query load tests, cache hit ratios |
| CODE_QUALITY.md | Code quality audit | Naming, SOLID, method length, docblocks, duplication |

### Summary Templates — `.brain/templates/summary/`

| Template | Use When |
|----------|----------|
| TEST_SUMMARY.md | After every test session — team-ready output |
| TASK_SUMMARY.md | After every completed task — full record |

### Memory Templates — `.brain/templates/`

| Template | Use When |
|----------|----------|
| MEMORY_DECISION.md | Recording an architecture decision |
| GUIDELINES.md | Creating project guidelines |

---

## 🔧 Tools & Scripts

| Script | Location | Purpose | Usage |
|--------|----------|---------|-------|
| 📊 Memory Timeline | `.ai/memory-timeline.py` | Cross-reference decisions, lessons, sessions by date | `python3 .ai/memory-timeline.py [--days N] [--domain X] [--all]` |
| 🔍 Skills Drift Check | `.ai/skills-diff.sh` | Compare local skills against upstream repos | `bash .ai/skills-diff.sh [--verbose]` |
| ⚡ Smart Update | `.ai/update.sh` | Refresh all skills from upstream | `bash .ai/update.sh` |

---

## Memory Flow

### Before Any Work

```
BRAIN receives task
    │
    ├─► DETERMINE DOMAIN — Ask user or derive from task
    ├─► CHECK DOMAIN FOLDER — .brain/{domain}/ exists?
    │   If not → create with plans/, rules/, skills/, memory/
    │
    ├─► Read .brain/INDEX.md               ← What does the project know?
    ├─► Read .brain/{domain}/memory/guidelines.md
    ├─► Read .brain/{domain}/memory/decisions/
    ├─► Read .brain/{domain}/memory/architecture/
    ├─► Read .brain/{domain}/memory/lessons/
    ├─► Read .brain/{domain}/memory/tests/
    ├─► Read .brain/{domain}/memory/tasks/
    └─► Read .brain/{domain}/connections/ (if needed)
```

### After Any Work (Always — in the correct domain)

```
Task/Discussion/Question complete — ALWAYS write
    │
    ├─► MEMORY SCRIBE writes .brain/{domain}/memory/sessions/
    ├─► MEMORY SCRIBE writes .brain/{domain}/memory/tests/
    ├─► MEMORY SCRIBE writes .brain/{domain}/memory/tasks/
    ├─► MEMORY SCRIBE writes .brain/{domain}/memory/decisions/
    ├─► MEMORY SCRIBE writes .brain/{domain}/memory/lessons/
    ├─► ARCHITECT updates .brain/{domain}/memory/guidelines/
    └─► MEMORY SCRIBE updates .brain/INDEX.md
```

---

## Git Safety

| Path | Committed? | Why |
|------|-----------|-----|
| `.brain/{domain}/memory/decisions/` | ✅ | Architecture decisions are project knowledge |
| `.brain/{domain}/memory/architecture/` | ✅ | Component maps are part of the project |
| `.brain/{domain}/memory/lessons/` | ✅ | Lessons benefit the whole team |
| `.brain/{domain}/memory/sessions/` | ✅ | Session history helps resume work |
| `.brain/{domain}/memory/tests/` | ✅ | Test summaries are team knowledge |
| `.brain/{domain}/memory/tasks/` | ✅ | Task records show what was done |
| `.brain/{domain}/memory/business/` | ✅ | Business rules are project knowledge |
| `.brain/{domain}/skills/` | ✅ | Code templates are project standards |
| `.brain/{domain}/memory/guidelines.md` | ✅ | Project structure is shared knowledge |
| `.brain/{domain}/connections/` | ❌ **Never** | Contains schema info — never push secrets |
