# Project Rules

> **Location:** `.brain/backend/rules/project-rules.md`
> **Purpose:** Project-specific conventions for any AI tool.

---

## R1 — RAI-Engineering is the Engine

RAI-Engineering is the **main engine** for this project. It provides:
- The agent mesh (PLANNER, EXECUTOR, TESTER, REVIEWER, etc.)
- The memory system (`.brain/`)
- The testing templates (`templates/testing/`)
- The summary system

All AI tools should defer to RAI-Engineering patterns. If CLAUDE.md says something different from what another tool suggests, **CLAUDE.md wins**.

## R2 — Domain-Isolated Memory

All knowledge lives in domain-isolated subtrees under `.brain/{domain}/`:

- Decisions → `.brain/{domain}/memory/decisions/`
- Lessons → `.brain/{domain}/memory/lessons/`
- Sessions → `.brain/{domain}/memory/sessions/`
- Tests → `.brain/{domain}/memory/tests/`
- Tasks → `.brain/{domain}/memory/tasks/`
- Skills → `.brain/{domain}/skills/`
- Rules → `.brain/{domain}/rules/`

No other location stores project knowledge. Each domain is self-contained.

## R3 — Summaries Are Always Written

Every task, test, or discussion writes a summary to `.brain/{domain}/memory/tasks/` or `.brain/{domain}/memory/tests/`. If an AI asks for a summary and none exists, it must create one before responding.

## R4 — Use Domain Skills

Before writing code, check `.brain/{domain}/skills/` for templates:
- Creating a service? → Read `skills/service.md`
- Creating a controller? → Read `skills/controller.md`
- Creating an API resource? → Read `skills/resource.md`
- Full CRUD? → Read `skills/crud.md`

## R5 — Read Before Write (Domain-Aware)

Before making decisions, read from the correct domain:
1. `.brain/INDEX.md`
2. `.brain/{domain}/memory/guidelines.md`
3. `.brain/{domain}/memory/decisions/` (for similar past decisions)
4. `.brain/{domain}/memory/lessons/` (for known pitfalls)
5. Relevant `.brain/{domain}/skills/` file

## R6 — Database Connections Are Gitignored

`.brain/{domain}/connections/` is in `.gitignore`. Never push credentials.
