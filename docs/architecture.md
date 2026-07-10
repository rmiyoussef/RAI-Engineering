# AI Engineering OS — Architecture

> Version 0.1 — Foundation

---

## 1. What Is the Brain?

The **Brain** is the central orchestrator. Every request enters the Brain, and every response exits through it. It does not perform work itself — it routes, validates, and coordinates.

The Brain is defined by:

- `brain/SYSTEM.md` — How the Brain routes work
- `brain/MISSION.md` — The system's purpose (immutable)
- `brain/PRINCIPLES.md` — Design values that guide all decisions
- `brain/LIMITATIONS.md` — Hard boundaries the system must not cross
- `brain/RULES.md` — Enforceable rules that constrain every agent

```
Request → Brain → Router → Agent → Structured Output → Brain → Response
              ↘           ↗
             Memory (side effect)
```

**The Brain never writes code.** It delegates to agents. It enforces the rules. It persists decisions to Memory.

---

## 2. What Is a Skill?

A **Skill** is a single-responsibility capability. It is the smallest unit of reusable behavior.

```
skills/
  laravel.md          # One framework
  redis.md            # One technology
  sql.md              # One pattern
  review.md           # One process
  testing.md          # One discipline
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
3. What patterns/patterns does it teach?
4. What are its conventions and gotchas?
5. What files does it typically touch?

---

## 3. What Is an Agent?

An **Agent** is a specialized role with a defined responsibility. Each agent receives a goal and returns a structured output — never free-form text.

### Agent Contract

Every agent must return a structured object following a defined schema:

| Agent | Returns | File |
|-------|---------|------|
| `PLANNER` | `{ goal, affectedFiles, risks, dependencies, executionPlan, questions }` | `agents/PLANNER.md` |
| `EXECUTOR` | `{ filesChanged, testResults, lintResults, status }` | `agents/EXECUTOR.md` |
| `REVIEWER` | `{ issues, suggestions, performance, security, score }` | `agents/REVIEWER.md` |
| `BACKEND QA` | `{ overallStatus, dimensions: { cleanCode, queryOptimization, security, testing }, fixes }` | `agents/BACKEND.md` |
| `MEMORY SCRIBE` | `{ decisions, lessons, architectureChanges, sessionSummary }` | `agents/MEMORY.md` |
| `GITHUB` | `{ branch, commits, prUrl, prBody, status }` | `agents/GITHUB.md` |

### Why Structured Outputs

Because every agent returns the same shape every time:

1. **Agents can talk to each other.** The Planner's output feeds the Executor. The Executor's output feeds the Reviewer.
2. **The Brain can validate.** If a Planner returns `{...}` missing `risks`, the Brain rejects it.
3. **Memory can index.** Structured decisions are searchable and linkable.
4. **You can test agents.** Mock the input, assert the output shape.

### Agent Lifecycle

1. **Instantiate** — Brain loads the agent's definition + required skills
2. **Equip** — Brain injects relevant memory, context, and rules
3. **Execute** — Agent performs its task, returns structured output
4. **Validate** — Brain checks the output against the agent's schema
5. **Persist** — Brain writes decisions, changes, and lessons to Memory
6. **Respond** — Brain returns the result to the caller

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

Memory lives **in the project**, not in AI Engineering OS. The OS provides the interface and schema; the project provides the storage.

```
AI-Engineering-OS/brain/       # System brain (interface, schemas, rules)
BenchHR/memory/                # Project memory (decisions, architecture, business rules)
```

### Memory Interface

```
Brain.memory.write(store, entry)
Brain.memory.read(store, query)
Brain.memory.link(from, to, relationship)
```

---

## 5. How Do They Communicate?

### The Message Contract

Every message between components follows:

```
{
  "from": "planner | reviewer | brain | ...",
  "to": "brain | executor | memory | ...",
  "type": "request | response | event | error",
  "payload": { ... },
  "schema": "planner-v1 | executor-v1 | ...",
  "timestamp": "...",
  "session": "uuid"
}
```

### The Pipeline

```
User Request
    ↓
[1] Brain.loadRules()
    ↓
[2] Brain.loadMemory()        ← pulls relevant context
    ↓
[3] Brain.route(Planner)      ← Planner returns structured plan
    ↓
[4] Brain.validate(plan)      ← rejects if schema doesn't match
    ↓
[5] Brain.storeDecision()     ← writes to Memory
    ↓
[6] Brain.route(Executor)     ← Executor loads plan + skills
    ↓
[7] Executor → modify files → return { filesChanged, status }
    ↓
[8] Brain.route(Reviewer)     ← Reviewer loads changes
    ↓
[9] Reviewer → { issues, performance, score }
    ↓
[10] If score < threshold → Brain.route(Executor)     ← loop
    ↓
[10b] If backend code changed → Brain.route(Backend QA)  ← deep audit
      │
      ├─ Dimension fails → route to Executor (fix loop, max 5 iters)
      └─ All pass → proceed
    ↓
[11] Brain.route(Tester)      ← run tests
    ↓
[12] Brain.storeLessons()     ← writes lessons to Memory
    ↓
[13] Brain.respond(user)      ← summarized result
```

---

## 6. Build Order

| Step | Layer | What It Produces | Status |
|------|-------|------------------|--------|
| 1 | **Brain** | `CLAUDE.md`, `brain/SYSTEM.md`, `MISSION.md`, `PRINCIPLES.md`, `LIMITATIONS.md`, `RULES.md` | ✅ v0.1 |
| 2 | **Workflow** | `workflows/STANDARD.md` | ✅ v0.1 |
| 3 | **Rules** | `rules/` | 🔲 v0.2 planned |
| 4 | **Skills** | `skills/CODE_REVIEW.md`, `TESTING.md`, `GIT.md`, `MEMORY.md` | ✅ v0.1 |
| 5 | **Agents** | `agents/PLANNER.md`, `EXECUTOR.md`, `REVIEWER.md`, `MEMORY.md`, `GITHUB.md` | ✅ v0.1 |
| 6 | **Templates** | `templates/MEMORY_DECISION.md` | ✅ v0.1 |
| 7 | **Memory** | OS memory interface (protocol defined in `brain/SYSTEM.md`) | ✅ v0.1 |
| 8 | **Install System** | Install scripts | 🔲 v0.7 planned |

---

## 7. Design Principles

1. **Single responsibility.** Every file does one thing. One skill per file. One agent per role.
2. **Structured over free-form.** Agents return schemas, not paragraphs. Validatable, testable, composable.
3. **Context over instructions.** Give the AI context about the domain, not step-by-step prompts. Trust the model to execute.
4. **Memory is a first-class citizen.** Every decision, every lesson, every architectural change is indexed. Nothing is lost.
5. **Validation at boundaries.** The Brain validates every input and output. Bad data stops at the border.
6. **Framework-agnostic core.** The OS knows how to engineer software, not how to build Laravel apps. Domain knowledge lives in Skills.
7. **Versioned product.** AI Engineering OS has releases. Projects pin a version and upgrade deliberately.
8. **Testable pieces.** Every agent, every skill, every rule can be tested in isolation.
9. **Progressive complexity.** Start simple. Add layers as the project grows. Don't build what you don't need yet.
10. **Nothing exists because it's useful today.** Every file must be reusable across projects.

---

## 8. How to Add a New Agent

1. Create `agents/<name>.md`
2. Define its purpose, inputs, and structured output schema
3. Define what skills it loads
4. Register it in the Brain's router
5. Add validation for its output schema
6. Write a test

## 9. How to Add a New Skill

1. Create `skills/<name>.md`
2. Describe what the skill teaches and when to use it
3. Keep it to one responsibility
4. Link to related skills

---

## 10. Version Roadmap

| Version | Focus | Contents | Status |
|---------|-------|----------|--------|
| v0.1 | **Foundation** | Brain (`CLAUDE.md`, SYSTEM, MISSION, PRINCIPLES, LIMITATIONS, RULES), Workflow (STANDARD), Skills (CODE_REVIEW, TESTING, GIT, MEMORY), Agents (PLANNER, EXECUTOR, REVIEWER, MEMORY, GITHUB), Templates (MEMORY_DECISION), architecture docs | ✅ **Done** |
| v0.2 | **Skills expansion** | Framework skills (laravel, sql, redis, react, vue), language skills (php, js, python) | 🔲 Planned |
| v0.3 | **Rules expansion** | `rules/` directory with domain-agnostic rule files | 🔲 Planned |
| v0.4 | **Memory enhancements** | Memory querying, linking, lifecycle management | 🔲 Planned |
| v0.5 | **GitHub release workflow** | Changelog, semantic versioning, release automation | 🔲 Planned |
| v0.6 | **Templates expansion** | Project scaffolding, agent templates, skill templates | 🔲 Planned |
| v0.7 | **Install system** | Install script that bootstraps any repo with AI-Engineering-OS | 🔲 Planned |
| v1.0 | **Stable** | Battle-tested, documented, versioned, with upgrade guides | 🔲 Planned |

---

*This document is the source of truth for AI Engineering OS architecture. All implementation must conform to it. Changes to this document require full team consensus.*
