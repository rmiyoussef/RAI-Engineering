# RAI-Engineering

**Your project's AI brain — v1.6.0**

Instead of behaving like a chatbot, the AI behaves like an **engineering organization** — with specialized agents that plan, build, review, test, audit, and remember. All project knowledge is organized into **domain-isolated subtrees** so Backend rules never leak into Frontend, and vice versa.

```
curl -fsSL https://raw.githubusercontent.com/rmiyoussef/RAI-Engineering/master/setup.sh | bash
```

---

## What's New in v1.6

| Feature | Description |
|---------|-------------|
| ⚡ **Lazy-load boot** | CLAUDE.md cut from 36KB → 8KB. Agents load on demand |
| 📋 **Consolidated rules** | R3/R28 merged. R41-R45 canonical in RULES.md only |
| 🎯 **Model Tiering** | Route agents to different models via `.brain/config.yaml` |
| ✅ **Approval modes** | Quick one-liner + full approval box, switchable mid-session |
| 📊 **Memory Timeline** | `python3 .ai/memory-timeline.py` — cross-reference all memory by date |
| 🔍 **Skills Drift Check** | `bash .ai/skills-diff.sh` — compare local vs upstream hashes |
| 🗄️ **Migration Testing** | New 7-scenario migration test template |
| 📦 **Skills-lock v2** | Tracks upstream repos + commit SHAs for all 34 imported skills |

See [docs/architecture.md](docs/architecture.md) for full details.

---

## Why?

Most AI coding assistants behave like chatbots — they answer questions, write code on demand, and forget everything between sessions.

RAI-Engineering is different. It turns your AI into a **disciplined engineering team** that:

- **Understands architecture** before touching code
- **Plans** every change before writing it
- **Maintains project memory** — decisions, lessons, architecture
- **Reviews its own work** for quality, security, and performance
- **Writes tests** with realistic mock data
- **Tracks decisions** so nothing is forgotten
- **Learns project architecture** over time
- **Optimizes continuously** through self-review loops
- **Orchestrates complex tasks** — decomposes multi-domain work, dispatches in parallel, verifies autonomously
- **Isolates by domain** — Backend, Frontend, Mobile, DevOps each in their own subtree
- **Can be installed** into any repository, any framework

---

## How It Works

The system is built around **17 specialized agents** that talk to each other through the **Brain** (a message broker). Before any work begins, the Brain identifies the **domain** (Backend, Frontend, Mobile, or DevOps) and routes to the correct isolated knowledge subtree — so Backend rules never mix with Frontend patterns.

For complex or multi-domain tasks, the **ORCHESTRATOR ENGINE** takes over: it decomposes the work into independent sub-tasks, dispatches them in parallel across domain agents, relays cross-agent requests in real-time, and runs an autonomous verify loop — all without waiting for a pipeline.

### The Agent Mesh

```
                    ╔═══════════════════════════════════╗
                    ║   ORCHESTRATOR ENGINE             ║── Decomposes → dispatches → verifies
                    ║   (task orchestration)            ║
                    ╚══════════════════╤════════════════╝
                                       │  decomposes & dispatches
           ┌───────────────────────────┼───────────────────────────┐
           ▼                           ▼                           ▼
    ┌──────────────┐           ┌──────────────┐           ┌──────────────┐
    │   PLANNER    │           │   EXECUTOR   │           │   REVIEWER   │
    │ (architect)  │◄─────────►│  (builder)   │◄─────────►│ (inspector)  │
    └──────┬───────┘           └──────┬───────┘           └──────┬───────┘
           │                          │                          │
           ▼                          ▼                          ▼
    ┌──────────────┐           ┌──────────────┐           ┌──────────────┐
    │  ARCHIVIST   │           │  CLEAN CODE  │           │  BACKEND QA  │
    │ (librarian)  │           │ (refactorer) │           │  (auditor)   │
    └──────┬───────┘           └──────────────┘           └──────┬───────┘
           │                                                      │
           ▼                                                      ▼
    ┌──────────────┐     ┌──────────────┐                 ┌──────────────┐
    │ MEMORY SCRIBE│     │   DATABASE   │                 │   SECURITY   │
    │ (historian)  │     │    (DBA)     │                 │  (auditor)   │
    └──────┬───────┘     └──────────────┘                 └──────┬───────┘
           │                                                      │
           ▼                                                      ▼
    ┌──────────────┐     ┌──────────────┐                 ┌──────────────┐
    │   GITHUB     │     │ ORCHESTRATOR  │                 │    TESTER    │
    │   TASKS      │     │(session mesh) │                 │              │
    └──────┬───────┘     └──────────────┘                 └──────────────┘
           │
           └── GITHUB (PRs & commits)

    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║              DOMAIN-ISOLATED .brain/                                       ║
    ║  backend/ │ frontend/ │ mobile-ios/ │ android/ │ devops/                   ║
    ╚═══════════════════════════════════════════════════════════════════════════╝

```

### The Agents

| Agent | Role | What It Does |
|-------|------|-------------|
| **ORCHESTRATOR ENGINE** | Task Orchestrator | Decomposes complex tasks into sub-tasks, dispatches across domain agents in parallel, relays cross-agent requests, runs autonomous verify loop (R41-R45) |
| **ORCHESTRATOR** | Session Manager | Manages session lifecycle, inter-session message bus, heartbeat, peer discovery |
| **PLANNER** | Architect | Produces structured plans before any code is written. Lists affected files, risks, dependencies. |
| **ARCHIVIST** | Librarian | Reads your codebase and answers questions. "What's in the User model?" "What does AuthController do?" |
| **EXECUTOR** | Builder | Writes code following the plan. Creates/modifies files, runs linters. |
| **CLEAN CODE** | Refactorer | Fixes SOLID violations, naming, duplication. Extracts services from fat controllers. Never changes behavior. |
| **BACKEND QA** | Auditor | Deep backend audit: clean code, query optimization (N+1 detection), security (injection, auth, CSRF), test quality. |
| **SECURITY** | Security Auditor | OWASP Top 10, authentication/authorization audit, input validation, CVSS scoring |
| **DATABASE** | Database Specialist | Schema design, migration safety, index analysis, query optimization |
| **TESTER** | Test specialist | Generates tests, fixes brittle tests, ensures coverage. Uses factories, covers edge cases. |
| **REVIEWER** | Inspector | Scores code 1-10. Checks correctness, performance, security, maintainability. Manages the fix loop. |
| **MEMORY SCRIBE** | Historian | Writes decisions, lessons, architecture changes to persistent memory. |
| **SUMMARY** | Documentation Specialist | Produces professional summaries with tables, metrics, security/perf assessments |
| **ARCHITECT** | System Architect | Creates guidelines, enforces consistency, updates project structure documentation |
| **GITHUB** | Integrator | Creates branches, commits, and pull requests with full documentation. |
| **GITHUB TASKS** | Task Manager | Fetches GitHub issues, analyzes requirements, breaks into subtasks, manages delivery |

### Orchestration Engine

For complex or multi-domain tasks, the **ORCHESTRATOR ENGINE** takes the helm. It doesn't write code — it **orchestrates** the other agents:

1. **Decompose** — Breaks the task into the smallest independent sub-tasks, mapping each to its domain (Backend, Frontend, Mobile, DevOps)
2. **Dispatch** — Launches independent sub-tasks in parallel across domain agents. Serializes only where real dependencies exist
3. **Relay** — Routes cross-agent requests in real-time so sub-agents never block waiting for information
4. **Verify** — Checks that everything fits together, re-dispatches if gaps are found, repeats until done (max 3 cycles — R45)

This replaces sequential pipelines with a **dependency graph resolved into parallel waves** — sub-tasks with no dependencies run concurrently, only what blocks waits.

### How They Talk to Each Other

Agents don't wait for a pipeline. They **ask each other for help** in real-time:

```
PLANNER needs schema info          → calls ARCHIVIST
PLANNER needs design feedback      → calls REVIEWER, ARCHITECT
EXECUTOR writes a complex query    → consults BACKEND QA mid-write
EXECUTOR needs tests               → delegates to TESTER
EXECUTOR finds messy code          → delegates to CLEAN CODE
EXECUTOR writes a migration        → consults DATABASE
REVIEWER finds code quality issues → delegates to CLEAN CODE
REVIEWER needs security audit      → delegates to SECURITY
REVIEWER needs DB index review     → consults DATABASE
BACKEND QA finds missing tests     → delegates to TESTER
BACKEND QA confirms vulnerability  → escalates to SECURITY for CVSS scoring
MEMORY SCRIBE needs session data   → calls PLANNER, EXECUTOR, REVIEWER
ARCHITECT needs project structure  → calls ARCHIVIST for analysis
GITHUB TASKS breaks down issues    → calls PLANNER, EXECUTOR, REVIEWER
GITHUB needs PR body               → calls EXECUTOR, REVIEWER, TESTER
ORCHESTRATOR discovers peers       → registers in session registry
ORCHESTRATOR ENGINE decomposes task → calls PLANNER for each sub-task
ORCHESTRATOR ENGINE dispatches work → sends sub-tasks to domain agents in parallel
ORCHESTRATOR ENGINE relays between agents → routes requests so sub-agents don't block
ORCHESTRATOR ENGINE verifies result → runs autonomous loop (max 3 cycles)
SUMMARY produces reports           → calls all agents for outputs
```

### The Fix Loop

When code doesn't pass review, the fix loop isn't a simple retry — agents collaborate:

```
REVIEWER scores 4/10
    │
    ├─► REVIEWER: "5 issues found"
    │     ├─► SECURITY confirms SQL injection risk (CVSS 9.1)
    │     ├─► BACKEND QA confirms N+1 query pattern
    │     ├─► DATABASE recommends composite index
    │     ├─► CLEAN CODE refactors fat controller
    │     └─► TESTER generates missing edge case tests
    │
    ├─► EXECUTOR fixes all issues
    │
    └─► REVIEWER re-scores 9/10 → passes
```

Max 3 iterations. If still below 7 after 3 rounds, the system escalates to the user.

---

## Quick Start

### Install into Any Project

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/rmiyoussef/RAI-Engineering/master/setup.sh | bash
```

This creates:

```
your-project/
├── CLAUDE.md → .ai/CLAUDE.md     ← The Brain (loaded automatically by Claude Code)
├── .ai/                          ← RAI-Engineering
│   ├── brain/                    ← System definitions
│   ├── agents/                   ← Agent roles
│   ├── skills/                   ← Cross-domain skills
│   ├── rules/                    ← Engineering rules
│   ├── templates/                ← Memory templates
│   └── workflows/                ← Workflow references
└── .brain/                       ← YOUR project knowledge — domain-isolated
    ├── backend/        ← Backend memory, skills, rules, plans
    ├── frontend/       ← Frontend memory, skills, rules, plans
    ├── mobile-ios/     ← iOS memory, skills, rules, plans
    ├── mobile-android/ ← Android memory, skills, rules, plans
    └── devops/         ← DevOps memory, skills, rules, plans
```

### Update

```bash
bash .ai/update.sh
```

Or just ask: *"Update RAI-Engineering"*

### What's New in v1.5

RAI-Engineering v1.5 imports **34 skills from 6 external repositories** — learned patterns, best practices, and prompt techniques from the broader AI-engineering ecosystem:

| Source | Skills Adapted |
|--------|----------------|
| **mattpocock/skills** | TDD, codebase-design, domain-modeling, research, prototype, merge-conflicts, code-review (2-axis), improve-architecture |
| **anthropics/skills** | Frontend design principles |
| **addyosmani/agent-skills** | Context-engineering, planning, incremental-implementation, source/spec-driven-dev, code-simplification, documentation & ADRs, deprecation & migration, performance, shipping, observability, debugging, git-workflow, API design, security-hardening (+4 rule merges), frontend-UI, CI/CD, browser-testing |
| **obra/superpowers** | Verification-before-completion, subagent-driven-dev, parallel-agents, executing-plans, writing-plans, brainstorming, using-git-worktrees, finishing-a-branch, systematic-debugging |
| **emilkowalski/skills** | Design engineering, animation vocabulary, Apple design principles |
| **nextlevelbuilder/ui-ux-pro-max** | Design intelligence patterns (palettes, typography, UX guidelines) |

**4 rule files upgraded** — SECURITY (+STRIDE/OWASP LLM/SSRF/dep audit), API_DESIGN (+Hyrum/contract-first/TypeScript patterns), COMMIT_MESSAGES (+trunk-based/semver/changelogs), GIT_SAFETY (+generated-files discipline)

See `.brain/shared/skills/`, `.brain/frontend/*/skills/`, and `.brain/devops/*/skills/` for all 34 new files.

### Use It

```bash
cd /path/to/your-project
claude
```

Then give it a task:

- *"Show me the structure of this project"*
- *"Add validation to the UserController"*
- *"Review the code quality of the auth system"*
- *"Generate tests for the OrderService"*
- *"Create a new API endpoint for user profiles"*
- *"Build a search component with debounce, loading states, and error handling"*
- *"Review the accessibility of the checkout form"*

For a **complete reference of all 37 skills** across Backend, Frontend, DevOps, and Shared domains — see [SKILLS.md](SKILLS.md).

### What's New in v1.5.2 — Frontend Rules System

**11 frontend engineering rule files** — senior-level standards for building production frontends:

| Rule file | Covers |
|-----------|--------|
| `COMPONENT_ARCHITECTURE` | Single responsibility, props design, smart/presentational, error boundaries |
| `STATE_MANAGEMENT` | State ownership ladder, context optimization, URL-first, `useEffect` hygiene |
| `PERFORMANCE` | Core Web Vitals, bundle budgets, image optimization, lazy loading |
| `ACCESSIBILITY` | WCAG 2.2 AA, semantic HTML, keyboard nav, screen readers, reduced motion |
| `STYLING` | Token system, mobile-first, dark mode, flat specificity |
| `ERROR_LOADING_UX` | Four States Contract — loading, error, empty, success |
| `API_INTEGRATION` | Cache layer, typed client, optimistic updates, request deduplication |
| `TESTING` | Testing trophy, RTL queries, MSW, what to test |
| `SECURITY` | XSS, CSP, token storage, SRI, dependency audit |
| `FORMS_AND_INPUT` | Validation, autocomplete, confirmation patterns, keyboard support |
| `BUILD_TOOLING` | CI pipeline, TypeScript strict, code splitting, pre-commit hooks |

Plus: [Mantine UI skill](.brain/frontend/skills/mantine.md) (100+ component reference) and a team-readable [Best Practices Guide](.brain/frontend/FRONTEND_BEST_PRACTICES.md).

The Brain auto-loads the relevant rule files based on what your task touches — component work loads architecture rules, API work loads integration rules, etc.

---

## Project Memory — Domain Isolated

Every decision, lesson, test result, and task is saved to `.brain/` — a **team-wide, AI-tool-agnostic** knowledge base organized by **domain**. Works with Claude, Cursor, Copilot, Windsurf, and any AI tool.

```
.brain/
├── INDEX.md                 ← Master index — start here
├── README.md                ← What .brain/ is
├── agents/                  ← Agent definitions (ARCHITECT, PLANNER, etc.)
├── brain/                   ← Core system files (MISSION, PRINCIPLES, RULES, SYSTEM)
├── templates/               ← Summary & testing templates
├── shared/skills/           ← Cross-domain skills (27 from 6 repos)
│
├── backend/       ← Backend domain
│   ├── memory/              ← guidelines, decisions, lessons, sessions, tests, tasks
│   ├── skills/              ← Code templates (service, controller, resource, crud)
│   ├── rules/               ← Project conventions
│   ├── plans/               ← Project plans
│   └── connections/         ← DB schema (gitignored)
│
├── frontend/      ← Frontend domain (isolated)
│   ├── INDEX.md              ← Frontend index
│   ├── FRONTEND_BEST_PRACTICES.md ← Human-readable guide
│   ├── skills/               ← 7 skills (Mantine, UI eng, design, animations)
│   ├── rules/                ← 11 engineering rules
│   ├── reference/            ← Mantine UI integration guide
│   └── memory/               ← Decisions, lessons, tests, tasks
│
├── mobile-ios/    ← iOS domain (isolated)
├── mobile-android/← Android domain (isolated)
├── devops/        ← DevOps domain (isolated)
│   ├── DEVOPS_BEST_PRACTICES.md ← Human-readable guide
│   ├── skills/               ← CI/CD automation
│   ├── rules/                ← 13 devops engineering rules
│   ├── reference/            ← External docs (coming soon)
│   └── memory/               ← Coming soon
```

**Summaries are always written.** Every task, test, and discussion saves a summary. If you ask for a summary and it doesn't exist yet, it's created before responding.

The Brain reads this before every session so nothing is forgotten.

---

## Rules

When installed, your project gets access to domain-isolated engineering rules:

**Backend (7 rules):**

| Rule File | Covers |
|-----------|--------|
| `backend/rules/COMMIT_MESSAGES.md` | Conventional commit format, types, scopes |
| `backend/rules/ERROR_HANDLING.md` | Exceptions, logging, fail-fast, HTTP codes |
| `backend/rules/NAMING_CONVENTIONS.md` | Classes, methods, variables, tests naming |
| `backend/rules/SECURITY.md` | Input validation, SQL injection, XSS, CSRF, auth |
| `backend/rules/DATABASE.md` | Migrations, indexing, N+1, pagination, constraints |
| `backend/rules/API_DESIGN.md` | RESTful URLs, consistent responses, versioning |
| `backend/rules/TESTING_RULES.md` | Writing tests — coverage, scenarios, templates |

**Frontend (11 rules):**

| Rule File | Covers |
|-----------|--------|
| `frontend/rules/COMPONENT_ARCHITECTURE.md` | Single responsibility, props design, smart/presentational, error boundaries |
| `frontend/rules/STATE_MANAGEMENT.md` | State ownership, context optimization, `useEffect` hygiene |
| `frontend/rules/PERFORMANCE.md` | Core Web Vitals, bundle budgets, image optimization |
| `frontend/rules/ACCESSIBILITY.md` | WCAG 2.2 AA, semantic HTML, keyboard nav, screen readers |
| `frontend/rules/STYLING.md` | Token system, mobile-first, dark mode, flat specificity |
| `frontend/rules/ERROR_LOADING_UX.md` | Four States Contract — loading, error, empty, success |
| `frontend/rules/API_INTEGRATION.md` | Cache layer, typed client, optimistic updates |
| `frontend/rules/TESTING.md` | Testing trophy, RTL queries, MSW, what to test |
| `frontend/rules/SECURITY.md` | XSS, CSP, token storage, dependency audit |
| `frontend/rules/FORMS_AND_INPUT.md` | Validation, autocomplete, confirmation patterns |
| `frontend/rules/BUILD_TOOLING.md` | CI pipeline, TypeScript strict, pre-commit hooks |

**DevOps (13 rules):**

| Rule File | Covers |
|-----------|--------|
| `devops/rules/CONTAINERS.md` | Multi-stage builds, layer ordering, image scanning |
| `devops/rules/KUBERNETES.md` | Pod spec, probes, network policies, HPA, cluster security |
| `devops/rules/CI_CD.md` | Pipeline perf, caching, secrets, branch protection |
| `devops/rules/INFRASTRUCTURE_AS_CODE.md` | Terraform state, modules, CI for IaC |
| `devops/rules/CLOUD_SERVICES.md` | Multi-AZ, VPC, IAM, storage, cost optimization |
| `devops/rules/MONITORING_OBSERVABILITY.md` | RED metrics, structured logging, alerting, SLO |
| `devops/rules/DEVOPS_SECURITY.md` | Supply chain, secrets, runtime security, compliance |
| `devops/rules/NETWORKING_DNS.md` | VPC design, DNS, TLS, load balancers, WAF |
| `devops/rules/DATABASE_OPS.md` | DB provisioning, connection pooling, zero-downtime migrations |
| `devops/rules/BACKUP_DR_INCIDENT.md` | DR tiers, incident response, postmortem template |
| `devops/rules/COST_OPTIMIZATION.md` | Right-sizing, pricing models, budget alerts |
| `devops/rules/RELEASE_MANAGEMENT.md` | Deploy process, rollback, feature flags, semver |
| `devops/rules/AUTOMATION_SCRIPTING.md` | Shell script standards, idempotency, Makefiles |

| Template | When Used |
|----------|-----------|
| `.brain/templates/summary/TEST_SUMMARY.md` | Team-ready test summary (icons, tables, security, perf, DB) |
| `.brain/templates/summary/TASK_SUMMARY.md` | Full task summary (files, tests, security, quality scores) |
| `.brain/backend/skills/service.md` | Service class — structure, rules, transactions |
| `.brain/backend/skills/controller.md` | Controller — thin HTTP layer, action methods |
| `.brain/backend/skills/resource.md` | API Resource — response transformation, field filtering |
| `.brain/backend/skills/crud.md` | Full CRUD — migration, model, service, controller, routes, tests |

Rules are loaded automatically based on what domain the task touches.

---

## Skills

| Skill | When Used |
|-------|-----------|
| `skills/CODE_REVIEW.md` | Reviewing code (framework-agnostic) |
| `skills/TESTING.md` | Writing or reviewing tests (framework-agnostic) |
| `skills/GIT.md` | Committing, branching, PRs (framework-agnostic) |
| `skills/MEMORY.md` | Writing to project memory (framework-agnostic) |
| `skills/BACKEND_ENGINEERING.md` | Backend QA audit or query work |
| `frontend/skills/mantine.md` | Mantine UI component reference, form patterns, theming |
| `devops/skills/ci-cd-and-automation.md` | CI/CD pipeline setup and automation patterns |

---

## Architecture

The full architecture specification is in [docs/architecture.md](docs/architecture.md).

Key design decisions:

- **The Brain is a message broker.** It routes messages between agents — it never writes code.
- **Agents ask for help.** Unsure about architecture? Call ARCHIVIST. Unsure about a query? Call BACKEND QA.
- **Structured outputs.** Every agent returns a defined schema, not free-form text.
- **Domain-isolated memory.** `.brain/backend/`, `.brain/frontend/`, `.brain/mobile-ios/`, `.brain/mobile-android/`, `.brain/devops/` are fully isolated subtrees.
- **Framework-agnostic.** The system knows engineering patterns; domain knowledge lives in Skills.
- **Model-locked by default.** All agents default to `deepseek-v4-flash`. Config-driven tiering available via `.brain/config.yaml`.

---

## Token Optimization — Caveman ULTRA

RAI-Engineering ships with **[Caveman](https://github.com/juliusbrussee/caveman)** at **ULTRA** compression level — built-in token optimization that cuts output tokens by **~67%** without losing technical accuracy.

### How It Works

Caveman compresses AI agent output by eliminating filler while preserving every byte of code, commands, file paths, and error messages.

| Component | Status |
|-----------|--------|
| Code blocks | 🟢 Untouched — byte-perfect |
| Commands | 🟢 Untouched |
| File paths | 🟢 Untouched |
| Error messages | 🟢 Untouched — quoted exact |
| Explanations | 🔧 Compressed — fragments replace prose |
| Filler (articles, pleasantries, hedging) | 🔥 Dropped |

### Benchmark Results (5 Response Types)

| Response Type | Normal | ULTRA | Saved |
|---|---|---|---|
| Debug help | 41 tok | 13 tok | **68%** |
| Code explanation | 38 tok | 11 tok | **71%** |
| Architecture suggestion | 34 tok | 11 tok | **68%** |
| Step-by-step fix | 42 tok | 17 tok | **60%** |
| Code review feedback | 53 tok | 17 tok | **68%** |
| **Average** | **41.6 tok** | **13.8 tok** | **67%** |

### Compression Levels

| Level | Effect |
|-------|--------|
| `lite` | No filler/hedging. Professional but tight |
| `full` | Drop articles, fragments OK, short synonyms (default) |
| `ultra` | Strip conjunctions when unambiguous. One word when enough. **Max compression** |
| `wenyan` | Classical Chinese — 80-90% character reduction |

### Commands

- `/caveman [lite\|full\|ultra\|wenyan]` — switch level mid-session
- `/caveman-stats` — show tokens saved
- `normal mode` — disable caveman
- Statusline shows `[CAVEMAN] ⛏ 12.4k` when active

### Per-Session Savings

| Metric | Without | With ULTRA |
|--------|---------|------------|
| Output tokens (100-turn session) | ~40,000 | ~13,200 |
| **Saved per session** | — | **~26,800 tokens** |

---

## Super TESTER — Comprehensive Testing

TESTER agent handles **6 testing modes** with reusable templates in `.brain/templates/testing/`.

### Testing Modes

| Mode | Template | What It Covers |
|------|----------|----------------|
| 🅰️ **API** | `.brain/templates/testing/API_ENDPOINT.md` | 15+ scenarios: happy path, validation, auth, edge cases |
| 🔗 **Flow** | `.brain/templates/testing/BUSINESS_FLOW.md` | Multi-step chained APIs (full flow + per-step auth) |
| 🗄️ **Database** | `.brain/templates/testing/DATABASE_QUERY.md` | N+1 detection, index checks, migration safety |
| 🗄️ **Migration** | `.brain/templates/testing/DATABASE_MIGRATION.md` | Up/down idempotency, index integrity, foreign keys, defaults, data safety — 7 scenarios |
| ⚡ **Performance** | `.brain/templates/testing/PERFORMANCE.md` | Response time benchmarks, query load tests |
| 🧹 **Code Quality** | `.brain/templates/testing/CODE_QUALITY.md` | Naming, SOLID, method length, docblocks |

### API Coverage (Per Endpoint)

| Scenario | Status |
|----------|--------|
| ✅ Happy Path — Create, Read, Update, Delete | 🟢 Required |
| ❌ Validation — Empty, missing, wrong types, max length | 🟢 Required |
| 🔒 Auth — No token, invalid token, expired token | 🟢 Required |
| 🚫 Authorization — Wrong role, insufficient permissions | 🟢 Required |
| 🔍 Not Found — Nonexistent ID, deleted resource | 🟢 Required |
| 📄 Edge Cases — Empty list, pagination, special chars | 🟢 Required |
| 🔄 Idempotency — Duplicate submission, unique violation | 🟢 Required |

### Business Flow Testing

When you say *"Test onboarding"*, TESTER maps the business flow to API steps:

```
Step 1: POST /api/v1/employees          → employee ID
Step 2: GET  /api/v1/employees/{id}/uuid → UUID
Step 3: POST /api/v1/contracts          → contract ID
Step 4: POST /api/v1/contracts/{id}/finalize → "active"
```

Each flow tested: **full flow**, **partial failures**, **auth at every step**, **final DB state**.

### Template System

- **"Create template for onboarding"** — writes to `.brain/templates/testing/onboarding.md`
- **"Test onboarding"** — checks templates, generates tests from existing template
- **"I need test {xyz}"** — if no template exists, TESTER asks to create one first

### Rules

```yaml
R28: Every task includes tests. If no tests exist, TESTER asks.
R29: Template-led testing. Templates are the source of truth.
```

---

## Domain Isolation Protocol — v1.3

Every task belongs to exactly one domain: **Backend**, **Frontend**, **Mobile (iOS)**, **Mobile (Android)**, or **DevOps/System Management**. Domain knowledge is stored in isolated subtrees — no cross-contamination.

### Structure

```
.brain/
├── backend/         ← Backend domain
│   ├── plans/                 ← Project plans
│   ├── rules/                 ← Framework-specific rules (laravel, express, django...)
│   ├── skills/                ← Code templates (service, controller, resource, crud)
│   └── memory/                ← Guidelines, decisions, lessons, sessions, tests, tasks
│
├── frontend/        ← Frontend domain (isolated)
│   ├── plans/                 ← Project plans
│   ├── rules/                 ← Framework-specific rules (react, vue, angular...)
│   ├── skills/                ← Component templates, UI patterns
│   └── memory/                ← Frontend-specific knowledge
│
├── mobile-ios/      ← iOS domain (isolated)
├── mobile-android/  ← Android domain (isolated)
└── devops/          ← DevOps domain (isolated)
```

### Isolation Rules

| Rule | Description |
|------|-------------|
| **R36** | **Domain Identity Required** — Every task declares its domain before work begins |
| **R37** | **Domain-Isolated Storage** — Plans, rules, skills, memory never cross domains |
| **R38** | **Cross-Domain Reference Protocol** — Use relative links, never duplicate content |
| **R39** | **Framework-Scoped Rules** — Rules are scoped to the declared framework |
| **R40** | **Domain Folder Initialization** — Create domain subdirs before writing knowledge |

### Why Isolate?

| Problem | Without Isolation | With Isolation |
|---------|-----------------|----------------|
| Full-stack project | Backend rules apply to React code | Backend and Frontend have separate rule sets |
| Multi-project repo | All memory in one flat folder | Each project gets its own domain subtree |
| New team member | Unclear which patterns apply where | Domain folder tells the AI what to use |

---

## Version Roadmap

| Version | Focus | Status |
|---------|-------|--------|
| v0.1 | **Foundation** — Brain, agents, skills, workflow | ✅ Done |
| v0.2 | **Agent Mesh** — message broker, agent-to-agent communication | ✅ Done |
| v0.3 | **Rules + Install** — 6 rule files, .ai/ convention, setup.sh | ✅ Done |
| v0.4 | **Skills expansion** — framework skills (Laravel, React, SQL) | ✅ Done |
| v0.5 | **Caveman ULTRA** — 67% token compression, built into setup/update | ✅ Done |
| v0.6 | **Super TESTER** — 5 testing modes, flow testing, templates | ✅ Done |
| v0.7 | **Memory Summaries** — test + task summaries with team-ready templates | ✅ Done |
| v0.8 | **R30 Version Bump Rule** — enforce version sync before every push | ✅ Done |
| v0.9 | **`.brain/` Project Brain** — team-wide AI knowledge base with skills, memory, rules | ✅ Done |
| v1.0 | **Stable** — battle-tested, documented, versioned | 🔲 Planned |
| v1.1 | **Multi-Session Mesh** — ORCHESTRATOR, inter-session bus, session registry | ✅ Done |
| v1.2 | **Multi-Session Mesh (v1.1 release)** | ✅ Done |
| v1.3 | **Domain Isolation Protocol** — per-domain plans, rules, skills, memory | ✅ Done |
| v1.4 | **Orchestration Engine** — task decomposition, parallel dispatch, verify loop | ✅ Done |
| v1.5 | **Skill Library Import** — 34 skills from 6 external repos, 4 rule merges | ✅ Done |
| v1.5.1 | **Path separator fix** — `.brain.` → `.brain/` in setup.sh & update.sh download paths | ✅ Done |
| v1.5.2 | **Frontend Rules System** — 11 engineering rules, Mantine reference, human-readable guide | ✅ Done |
| v1.5.3 | **DevOps Rules System** — 13 engineering rules, CI/CD skill, human-readable guide | ✅ Done |
| **v1.6.0** | **Lazy-load boot, consolidated rules, model tiering, approval modes, memory timeline, skills-diff, migration testing** | ✅ Done |

---

<div align="center">
  <br>
  <sub>
    Built with ❤️ by
    <a href="https://github.com/rmiyoussef">
      <b>Rami Youssef</b>
    </a>
    <br>
    <small>RAI-Engineering — v1.6.0</small>
  </sub>
  <br>
</div>

---

## Development

To work on RAI-Engineering itself:

```bash
git clone git@github.com:rmiyoussef/RAI-Engineering.git
cd RAI-Engineering
```

The `CLAUDE.md` in the root is the **development version** (loads from `./`).
The `CLAUDE.install.md` is the **installable version** (loads from `.ai/`).

---

## License

MIT
