# Project Rules

> **Location:** `.brain/rules/project-rules.md`
> **Purpose:** Project-specific conventions for any AI tool.

---

## R1 — RAI-Engineering is the Engine

RAI-Engineering is the **main engine** for this project. It provides:
- The agent mesh (PLANNER, EXECUTOR, TESTER, REVIEWER, etc.)
- The memory system (`.brain/`)
- The testing templates (`templates/testing/`)
- The summary system

All AI tools should defer to RAI-Engineering patterns. If CLAUDE.md says something different from what another tool suggests, **CLAUDE.md wins**.

## R2 — All Memory Lives in `.brain/`

- Decisions → `.brain/memory/decisions/`
- Lessons → `.brain/memory/lessons/`
- Sessions → `.brain/memory/sessions/`
- Tests → `.brain/memory/tests/`
- Tasks → `.brain/memory/tasks/`
- Skills → `.brain/skills/`
- Rules → `.brain/rules/`

No other location stores project knowledge.

## R3 — Summaries Are Always Written

Every task, test, or discussion writes a summary to `.brain/memory/tasks/` or `.brain/memory/tests/`. If an AI asks for a summary and none exists, it must create one before responding.

## R4 — Use Project Skills

Before writing code, check `.brain/skills/` for templates:
- Creating a service? → Read `skills/service.md`
- Creating a controller? → Read `skills/controller.md`
- Creating an API resource? → Read `skills/resource.md`
- Full CRUD? → Read `skills/crud.md`

## R5 — Read Before Write

Before making decisions, read:
1. `.brain/INDEX.md`
2. `.brain/memory/guidelines.md`
3. `.brain/memory/decisions/` (for similar past decisions)
4. `.brain/memory/lessons/` (for known pitfalls)
5. Relevant `.brain/skills/` file

## R6 — Database Connections Are Gitignored

`.brain/connections/` is in `.gitignore`. Never push credentials.
