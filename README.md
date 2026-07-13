# AI Engineering OS

**An operating system for AI software engineering.**

Instead of behaving like a chatbot, the AI behaves like an **engineering organization** — with specialized agents that plan, build, review, test, audit, and remember.

```
curl -fsSL https://raw.githubusercontent.com/rmiyoussef/AI-Engineering-OS/master/setup.sh | bash
```

---

## Why?

Most AI coding assistants behave like chatbots — they answer questions, write code on demand, and forget everything between sessions.

AI Engineering OS is different. It turns your AI into a **disciplined engineering team** that:

- **Understands architecture** before touching code
- **Plans** every change before writing it
- **Maintains project memory** — decisions, lessons, architecture
- **Reviews its own work** for quality, security, and performance
- **Writes tests** with realistic mock data
- **Tracks decisions** so nothing is forgotten
- **Learns project architecture** over time
- **Optimizes continuously** through self-review loops
- **Can be installed** into any repository, any framework

---

## How It Works

The system is built around **9 specialized agents** that talk to each other through the **Brain** (a message broker).

### The Agent Mesh

```
                    ┌───────────────────┐
                    │     ARCHIVIST     │── Knowledge base (reads files)
                    └────────┬──────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
   ┌──────────┐       ┌──────────┐       ┌──────────┐
   │ PLANNER  │◄─────►│ EXECUTOR │◄─────►│ REVIEWER │
   └─────┬────┘       └─────┬────┘       └─────┬────┘
         │                  │                  │
         ▼                  ▼                  ▼
   ┌──────────┐       ┌──────────┐       ┌──────────┐
   │  MEMORY  │       │ CLEAN    │       │ BACKEND  │
   │  SCRIBE  │       │ CODE     │       │   QA     │
   └──────────┘       └──────────┘       └────┬─────┘
         │                                    │
         ▼                                    ▼
   ┌──────────┐                       ┌──────────┐
   │  GITHUB  │                       │  TESTER  │
   └──────────┘                       └──────────┘
```

### The Agents

| Agent | Role | What It Does |
|-------|------|-------------|
| **PLANNER** | Architect | Produces structured plans before any code is written. Lists affected files, risks, dependencies. |
| **ARCHIVIST** | Librarian | Reads your codebase and answers questions. "What's in the User model?" "What does AuthController do?" |
| **EXECUTOR** | Builder | Writes code following the plan. Creates/modifies files, runs linters. |
| **CLEAN CODE** | Refactorer | Fixes SOLID violations, naming, duplication. Extracts services from fat controllers. Never changes behavior. |
| **BACKEND QA** | Auditor | Deep backend audit: clean code, query optimization (N+1 detection), security (injection, auth, CSRF), test quality. |
| **TESTER** | Test specialist | Generates tests, fixes brittle tests, ensures coverage. Uses factories, covers edge cases. |
| **REVIEWER** | Inspector | Scores code 1-10. Checks correctness, performance, security, maintainability. Manages the fix loop. |
| **MEMORY SCRIBE** | Historian | Writes decisions, lessons, architecture changes to persistent memory. |
| **GITHUB** | Integrator | Creates branches, commits, and pull requests with full documentation. |

### How They Talk to Each Other

Agents don't wait for a pipeline. They **ask each other for help** in real-time:

```
PLANNER needs schema info          → calls ARCHIVIST
EXECUTOR writes a complex query    → consults BACKEND QA mid-write
EXECUTOR needs tests               → delegates to TESTER
REVIEWER finds code quality issues → delegates to CLEAN CODE
REVIEWER needs security audit      → consults BACKEND QA
BACKEND QA finds missing tests     → delegates to TESTER
MEMORY SCRIBE needs session data   → calls PLANNER, EXECUTOR, REVIEWER
GITHUB needs PR body               → calls EXECUTOR, REVIEWER, TESTER
```

### The Fix Loop

When code doesn't pass review, the fix loop isn't a simple retry — agents collaborate:

```
REVIEWER scores 6/10
    │
    ├─► REVIEWER: "3 issues found"
    │     ├─► BACKEND QA confirms SQL injection risk
    │     ├─► CLEAN CODE refactors fat controller
    │     └─► TESTER generates missing edge case tests
    │
    └─► REVIEWER re-scores 9/10 → passes
```

---

## Quick Start

### Install into Any Project

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/rmiyoussef/AI-Engineering-OS/master/setup.sh | bash
```

This creates:

```
your-project/
├── CLAUDE.md → .ai/CLAUDE.md     ← The Brain (loaded automatically by Claude Code)
├── .ai/                          ← AI Engineering OS
│   ├── brain/                    ← System definitions
│   ├── agents/                   ← Agent roles
│   ├── skills/                   ← Domain knowledge
│   ├── rules/                    ← Engineering rules
│   ├── templates/                ← Memory templates
│   └── workflows/                ← Workflow references
└── memory/                       ← YOUR project memory (grows over time)
    ├── decisions/
    ├── architecture/
    ├── lessons/
    ├── sessions/
    └── business/
```

### Update

```bash
bash .ai/update.sh
```

Or just ask: *"Update AI Engineering OS"*

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

---

## Project Memory

Every decision, lesson, test result, and task is saved to `.brain/` — a **team-wide, AI-tool-agnostic** knowledge base. Works with Claude, Cursor, Copilot, Windsurf, and any AI tool.

```
.brain/
├── INDEX.md                 ← Master index — start here
├── README.md                ← What .brain/ is
├── memory/
│   ├── guidelines.md        ← Architecture, conventions, stack
│   ├── decisions/           ← Past architecture decisions
│   ├── architecture/        ← Component maps
│   ├── lessons/             ← Things learned
│   ├── sessions/            ← Session summaries
│   ├── tests/               ← Test summaries (per feature)
│   ├── tasks/               ← Task summaries (files, tests, security, perf)
│   └── business/            ← Business rules
├── skills/                  ← Project code templates
│   ├── service.md           ← How to create services
│   ├── controller.md        ← How to create controllers
│   ├── resource.md          ← How to create API resources
│   └── crud.md              ← Full CRUD generation
├── rules/                   ← Project conventions
└── connections/             ← DB schema (gitignored)
```

**Summaries are always written.** Every task, test, and discussion saves a summary. If you ask for a summary and it doesn't exist yet, it's created before responding.

The Brain reads this before every session so nothing is forgotten.

---

## Rules

When installed, your project gets access to domain-agnostic engineering rules:

| Rule File | Covers |
|-----------|--------|
| `rules/COMMIT_MESSAGES.md` | Conventional commit format, types, scopes |
| `rules/ERROR_HANDLING.md` | Exceptions, logging, fail-fast, HTTP codes |
| `rules/NAMING_CONVENTIONS.md` | Classes, methods, variables, tests naming |
| `rules/SECURITY.md` | Input validation, SQL injection, XSS, CSRF, auth |
| `rules/DATABASE.md` | Migrations, indexing, N+1, pagination, constraints |
| `rules/API_DESIGN.md` | RESTful URLs, consistent responses, versioning |

| `rules/TESTING_RULES.md` | Writing tests — coverage, scenarios, templates |

| Template | When Used |
|----------|-----------|
| `templates/summary/TEST_SUMMARY.md` | Team-ready test summary (icons, tables, security, perf, DB) |
| `templates/summary/TASK_SUMMARY.md` | Full task summary (files, tests, security, quality scores) |
| `.brain/skills/service.md` | Service class — structure, rules, transactions |
| `.brain/skills/controller.md` | Controller — thin HTTP layer, action methods |
| `.brain/skills/resource.md` | API Resource — response transformation, field filtering |
| `.brain/skills/crud.md` | Full CRUD — migration, model, service, controller, routes, tests |

Rules are loaded automatically based on what the task touches.

---

## Skills

| Skill | When Used |
|-------|-----------|
| `skills/CODE_REVIEW.md` | Reviewing code |
| `skills/TESTING.md` | Writing or reviewing tests |
| `skills/GIT.md` | Committing, branching, PRs |
| `skills/MEMORY.md` | Writing to project memory |
| `skills/BACKEND_ENGINEERING.md` | Backend QA audit or query work |

---

## Architecture

The full architecture specification is in [docs/architecture.md](docs/architecture.md).

Key design decisions:

- **The Brain is a message broker.** It routes messages between agents — it never writes code.
- **Agents ask for help.** Unsure about architecture? Call ARCHIVIST. Unsure about a query? Call BACKEND QA.
- **Structured outputs.** Every agent returns a defined schema, not free-form text.
- **Memory is project-specific.** The OS provides the interface; `memory/` lives in your project.
- **Framework-agnostic.** The OS knows engineering patterns; domain knowledge lives in Skills.
- **Model-locked.** All agents run on `deepseek-v4-flash`. No exceptions.

---

## Token Optimization — Caveman ULTRA

AI Engineering OS ships with **[Caveman](https://github.com/juliusbrussee/caveman)** at **ULTRA** compression level — built-in token optimization that cuts output tokens by **~67%** without losing technical accuracy.

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

TESTER agent now handles **5 testing modes** with reusable templates in `templates/testing/`.

### Testing Modes

| Mode | Template | What It Covers |
|------|----------|----------------|
| 🅰️ **API** | `templates/testing/API_ENDPOINT.md` | 15+ scenarios: happy path, validation, auth, edge cases |
| 🔗 **Flow** | `templates/testing/BUSINESS_FLOW.md` | Multi-step chained APIs (full flow + per-step auth) |
| 🗄️ **Database** | `templates/testing/DATABASE_QUERY.md` | N+1 detection, index checks, migration safety |
| ⚡ **Performance** | `templates/testing/PERFORMANCE.md` | Response time benchmarks, query load tests |
| 🧹 **Code Quality** | `templates/testing/CODE_QUALITY.md` | Naming, SOLID, method length, docblocks |

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

- **"Create template for onboarding"** — writes to `templates/testing/onboarding.md`
- **"Test onboarding"** — checks templates, generates tests from existing template
- **"I need test {xyz}"** — if no template exists, TESTER asks to create one first

### Rules

```yaml
R28: Every task includes tests. If no tests exist, TESTER asks.
R29: Template-led testing. Templates are the source of truth.
```

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

---

---

<div align="center">
  <br>
  <sub>
    Built with ❤️ by
    <a href="https://github.com/rmiyoussef">
      <b>Rami Youssef</b>
    </a>
    <br>
    <small>AI Engineering OS — v1.0</small>
  </sub>
  <br>
</div>

---

## Development

To work on AI Engineering OS itself:

```bash
git clone git@github.com:rmiyoussef/AI-Engineering-OS.git
cd AI-Engineering-OS
```

The `CLAUDE.md` in the root is the **development version** (loads from `./`).
The `CLAUDE.install.md` is the **installable version** (loads from `.ai/`).

---

## License

MIT
