# RAI-Engineering — Architecture

> Version 0.2 — Agent Mesh

---

## 1. What Is the Brain?

The **Brain** is a **message broker**. It does not write code, plan features, review changes, or test anything.

The Brain does exactly three things:
1. **Route** messages from one agent to another
2. **Validate** every message's structure before delivery
3. **Persist** decisions and conversations to memory

Agents talk to each other. The Brain facilitates.

```
Agent A ──message──► Brain ──validated message──► Agent B
                         ◄──response──────────────
```

The Brain is defined by:

- `brain/SYSTEM.md` — Message broker protocol and routing rules
- `brain/MISSION.md` — The system's purpose (immutable)
- `brain/PRINCIPLES.md` — Design values that guide all decisions
- `brain/LIMITATIONS.md` — Hard boundaries the system must not cross
- `brain/RULES.md` — 16 enforceable rules including mesh communication (R11-R16)

**The Brain never writes code.** It routes messages between agents.

---

## 2. What Is a Skill?

A **Skill** is a single-responsibility capability. It is the smallest unit of reusable behavior.

```
skills/
  CODE_REVIEW.md          # Code review patterns
  TESTING.md              # Testing discipline
  GIT.md                  # Git workflow
  MEMORY.md               # Memory management
  BACKEND_ENGINEERING.md  # Backend patterns (queries, security, SOLID)
```

### Rules for Skills

- **One file, one responsibility.** A skill teaches the AI how to do exactly one thing well.
- **Context, not instructions.** Skills describe *what to know*, not step-by-step prompts. They assume an agent is executing them.
- **Framework-agnostic where possible.** A `testing.md` skill teaches testing principles, not just how to test one framework.
- **Composable.** Agents load multiple skills as needed: `planner + laravel + redis + testing`.

### Skill Contract

Every skill file should answer:

1. What is this skill?
2. When should it be used?
3. What patterns does it teach?
4. What are its conventions and gotchas?
5. What files does it typically touch?

---

## 3. What Is an Agent?

An **Agent** is a specialized role with a defined responsibility. Each agent receives a goal and returns a structured output — never free-form text.

Agents communicate with each other through the Brain using the **Message Protocol**. Any agent can call any other agent for information, delegation, or consultation.

### Agent Contract

| Agent | Returns | Can Call |
|-------|---------|----------|
| `PLANNER` | `{ goal, affectedFiles, risks, dependencies, executionPlan, questions }` | ARCHIVIST, MEMORY, REVIEWER |
| `EXECUTOR` | `{ filesChanged, testResults, lintResults, status }` | ARCHIVIST, BACKEND QA, CLEAN CODE, TESTER, REVIEWER |
| `REVIEWER` | `{ issues, suggestions, performance, security, score }` | BACKEND QA, TESTER, CLEAN CODE, ARCHIVIST, MEMORY |
| `BACKEND QA` | `{ overallStatus, dimensions: { cleanCode, queryOptimization, security, testing }, fixes }` | CLEAN CODE, TESTER, ARCHIVIST |
| `TESTER` | `{ generatedTests, testResults, coverage, status }` | ARCHIVIST, EXECUTOR |
| `CLEAN CODE` | `{ refactored, violationsFixed, qualityScore }` | ARCHIVIST, TESTER |
| `ARCHIVIST` | `{ answers, relevantFiles, relatedDecisions, status }` | *(read-only, no calls)* |
| `MEMORY SCRIBE` | `{ decisions, lessons, architectureChanges, sessionSummary }` | PLANNER, EXECUTOR, REVIEWER, TESTER |
| `GITHUB` | `{ branch, commits, prUrl, prBody, status }` | EXECUTOR, REVIEWER, TESTER, MEMORY |
| `BRAIN` | Routes, validates, persists | *(broker, all agents)* |

### Agent-to-Agent Communication Types

| Type | Meaning |
|------|---------|
| `request` | "I need information from you" — ask questions |
| `delegate` | "Take over this work and report back" — assign subtasks |
| `consult` | "Review this specific piece and give feedback" — mid-work advice |
| `escalate` | "I can't resolve this — needs human input" |
| `done` | "Task complete, here's my output" |

### Agent Lifecycle

1. **Brain activates agent** — injects role, skills, memory context
2. **Agent works** — reads files, thinks, produces structured output
3. **Agent calls for help (optional)** — sends message through Brain to another agent
4. **Helper responds** — Brain validates and routes response back
5. **Agent completes output** — returns structured result to Brain
6. **Brain validates schema** — rejects malformed output
7. **Brain persists** — writes decisions, conversation to memory

---

## 4. What Is Memory?

**Memory** is the project's persistent knowledge base. It is not a log — it is indexed, structured, and queryable.

### Memory Stores

| Store | Content | Schema |
|-------|---------|--------|
| `decisions` | Architectural decisions with rationale | `{ decision, context, options, chosen, rationale, date }` |
| `architecture` | Current system architecture and component map | `{ component, responsibility, dependsOn, interfaces }` |
| `business` | Business rules, domain logic, glossary | `{ term, definition, source, related }` |
| `lessons` | Things the AI learned while working | `{ what, why, impact, files }` |
| `sessions` | Summary of what happened in each work session | `{ goal, outcome, filesChanged, openQuestions }` |

### Memory Is Project-Specific

Memory lives **in the project**, not in RAI-Engineering. The OS provides the interface and schema; the project provides the storage.

```
RAI-Engineering/              # OS source project (development)
├── CLAUDE.md                   # Development version (loads from ./)
├── CLAUDE.install.md           # Installable version (loads from .ai/)
├── brain/, agents/, skills/...
└── setup.sh                    # One-command installer

Your-Project/                   # Installed into any project
├── CLAUDE.md → .ai/CLAUDE.md   # Symlink — the Brain entry point
├── .ai/                        # All OS files live here
│   └── CLAUDE.md               # Installable version with .ai/ paths
├── brain/, agents/, skills/...
└── memory/                     # YOUR project's memory
    ├── decisions/architecture/lessons/sessions/business/
```

### Memory Interface

```
Brain.memory.write(store, entry)
Brain.memory.read(store, query)
Brain.memory.link(from, to, relationship)
```

---

## 5. How Do They Communicate?

### The Message Protocol

Every message between agents follows this structure:

```json
{
  "from": "planner | executor | reviewer | backend_qa | tester | clean_code | archivist | memory | github | brain",
  "to": "planner | executor | reviewer | backend_qa | tester | clean_code | archivist | memory | github | brain",
  "type": "request | delegate | consult | escalate | error | done",
  "session": "<uuid>",
  "context": {
    "task": "Original user request",
    "plan": "Active plan reference (if one exists)",
    "files": ["affected files"]
  },
  "payload": { }
}
```

### The Agent Mesh

```
                    ┌───────────────────┐
                    │     ARCHIVIST     │── Read-only knowledge base
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

### How a Conversation Unfolds

There is no fixed pipeline. The workflow emerges from agent communication. A typical flow looks like:

```
User request
    │
    ▼
BRAIN → PLANNER (starts planning)
    │
    ├─► PLANNER → ARCHIVIST: "What's the current architecture?"
    │     ◄─ ARCHIVIST responds
    │
    ├─► PLANNER → MEMORY: "Any past decisions about this?"
    │     ◄─ MEMORY responds
    │
    ├─► PLANNER → REVIEWER: "Does this design approach look right?"
    │     ◄─ REVIEWER validates
    │
    ◄─ PLANNER produces plan → BRAIN validates → user approves
    │
    ▼
BRAIN → EXECUTOR (starts building)
    │
    ├─► EXECUTOR → ARCHIVIST: "What columns does the X table have?"
    │     ◄─ ARCHIVIST responds
    │
    ├─► EXECUTOR → BACKEND QA: "Review this query mid-write"
    │     ◄─ BACKEND QA: "Use eager loading, N+1 risk"
    │
    ├─► EXECUTOR → TESTER: "Generate tests for this service"
    │     ◄─ TESTER returns test files
    │
    ├─► EXECUTOR → CLEAN CODE: "Refactor this controller"
    │     ◄─ CLEAN CODE: "Extracted service layer, quality 9/10"
    │
    ◄─ EXECUTOR reports completion
    │
    ▼
BRAIN → REVIEWER (reviews everything)
    │
    ├─► REVIEWER → BACKEND QA: "Verify these security concerns"
    │     ◄─ BACKEND QA audits
    │
    ├─► REVIEWER → TESTER: "Generate missing edge case tests"
    │     ◄─ TESTER adds scenarios
    │
    ├─► REVIEWER → CLEAN CODE: "Fix naming violations"
    │     ◄─ CLEAN CODE refactors
    │
    ◄─ REVIEWER scores 9/10 → passes
    │
    ▼
BRAIN → MEMORY SCRIBE (persists everything)
    │
    ├─► MEMORY → PLANNER: "What was the plan?"
    ├─► MEMORY → EXECUTOR: "What files changed?"
    ├─► MEMORY → REVIEWER: "What was the outcome?"
    │
    ◄─ MEMORY writes decisions, lessons, architecture, session
    │
    ▼
BRAIN responds to user with full summary
```

---

## 6. Build Order

| Step | Layer | What It Produces | Status |
|------|-------|------------------|--------|
| 1 | **Brain** | `CLAUDE.md`, `brain/SYSTEM.md`, `MISSION.md`, `PRINCIPLES.md`, `LIMITATIONS.md`, `RULES.md` | ✅ v0.1 |
| 2 | **Workflow** | `workflows/STANDARD.md` | ✅ v0.1 → v0.2 |
| 3 | **Skills** | `skills/CODE_REVIEW.md`, `TESTING.md`, `GIT.md`, `MEMORY.md`, `BACKEND_ENGINEERING.md` | ✅ v0.1 → v0.2 |
| 4 | **Agents** | `agents/PLANNER.md`, `EXECUTOR.md`, `REVIEWER.md`, `BACKEND.md`, `TESTER.md`, `CLEAN_CODE.md`, `ARCHIVIST.md`, `MEMORY.md`, `GITHUB.md` | ✅ v0.1 → v0.2 |
| 5 | **Templates** | `templates/MEMORY_DECISION.md` | ✅ v0.1 |
| 6 | **Memory** | OS memory interface (protocol defined in `brain/SYSTEM.md`) | ✅ v0.1 |
| 7 | **Rules expansion** | `rules/COMMIT_MESSAGES.md`, `ERROR_HANDLING.md`, `NAMING_CONVENTIONS.md`, `SECURITY.md`, `DATABASE.md`, `API_DESIGN.md` | ✅ v0.3 |
| 8 | **Install System** | `setup.sh`, `CLAUDE.install.md`, `.ai/` convention, `INSTALL.md` | ✅ v0.3 |

---

## 7. Design Principles

1. **Single responsibility.** Every file does one thing. One agent per role.
2. **Agents ask for help, they don't guess.** Unsure about architecture? Call ARCHIVIST. Unsure about a query? Call BACKEND QA.
3. **Delegate, don't duplicate.** Need tests? Delegate to TESTER. Need refactoring? Delegate to CLEAN CODE.
4. **Structured over free-form.** Agents return schemas, not paragraphs.
5. **Memory is a first-class citizen.** Every decision, every lesson, every architectural change is indexed. Nothing is lost.
6. **Validation at boundaries.** The Brain validates every input and output.
7. **Framework-agnostic core.** The OS knows engineering patterns. Domain knowledge lives in Skills.
8. **Versioned product.** RAI-Engineering has releases. Projects pin a version.
9. **Testable pieces.** Every agent can be tested in isolation.
10. **Reusable across projects.** Nothing exists only because it's useful today.

---

## 8. How to Add a New Agent

1. Create `agents/<name>.md`
2. Define its purpose, inputs, and structured output schema
3. Define what skills it loads
4. Define which other agents it can call (and who can call it)
5. Add "Who I Can Call" section
6. Register it in the Brain's routing table in `brain/SYSTEM.md`
7. Add validation for its output schema
8. Add it to the agent directory in `CLAUDE.md`

## 9. How to Add a New Skill

1. Create `skills/<name>.md`
2. Describe what the skill teaches and when to use it
3. Keep it to one responsibility
4. Link to related skills

---

## 10. Version Roadmap

| Version | Focus | Contents | Status |
|---------|-------|----------|--------|
| v0.1 | **Foundation** | Brain (CLAUDE.md, SYSTEM, MISSION, PRINCIPLES, LIMITATIONS, RULES), Workflow (STANDARD), Skills (CODE_REVIEW, TESTING, GIT, MEMORY), Agents (PLANNER, EXECUTOR, REVIEWER, MEMORY, GITHUB), Templates, architecture docs | ✅ **Done** |
| v0.2 | **Agent Mesh** | Message broker protocol (R11-R16), agent-to-agent communication, BACKEND QA, TESTER, CLEAN CODE, ARCHIVIST agents, BRAIN as router not dispatcher | ✅ **Done** |
| v0.3 | **Rules + Install** | Rules expansion (6 files) + Install system (setup.sh, CLAUDE.install.md, .ai/ convention) | ✅ **Done** |
| v0.4 | **Skills expansion** | Framework skills (laravel, sql, redis, react, vue), language skills (php, js, python) | 🔲 Planned |
| v0.5 | **Memory enhancements** | Memory querying, linking, lifecycle management | 🔲 Planned |
| v0.6 | **GitHub release workflow** | Changelog, semantic versioning, release automation | 🔲 Planned |
| v0.7 | **Templates expansion** | Project scaffolding, agent templates, skill templates | 🔲 Planned |
| v0.8 | **Install system** | Install script that bootstraps any repo with RAI-Engineering | 🔲 Planned |
| v1.0 | **Stable** | Battle-tested, documented, versioned, with upgrade guides | 🔲 Planned |

---

*This document is the source of truth for RAI-Engineering architecture. All implementation must conform to it. Changes to this document require full team consensus.*
