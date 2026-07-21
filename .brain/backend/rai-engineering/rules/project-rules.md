# Project Rules

> **Location:** `.brain/backend/rai-engineering/rules/project-rules.md`
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

All knowledge lives in domain-isolated subtrees under `.brain/{domain}/{project}/`:

- Decisions → `.brain/{domain}/{project}/memory/decisions/`
- Lessons → `.brain/{domain}/{project}/memory/lessons/`
- Sessions → `.brain/{domain}/{project}/memory/sessions/`
- Tests → `.brain/{domain}/{project}/memory/tests/`
- Tasks → `.brain/{domain}/{project}/memory/tasks/`
- Skills → `.brain/{domain}/{project}/skills/`
- Rules → `.brain/{domain}/{project}/rules/`

No other location stores project knowledge. Each domain is self-contained.

## R3 — Summaries Are Always Written

Every task, test, or discussion writes a summary to `.brain/{domain}/{project}/memory/tasks/` or `.brain/{domain}/{project}/memory/tests/`. If an AI asks for a summary and none exists, it must create one before responding.

## R4 — Use Domain Skills

Before writing code, check `.brain/{domain}/{project}/skills/` for templates:
- Creating a service? → Read `skills/service.md`
- Creating a controller? → Read `skills/controller.md`
- Creating an API resource? → Read `skills/resource.md`
- Full CRUD? → Read `skills/crud.md`

## R5 — Read Before Write (Domain-Aware)

Before making decisions, read from the correct domain:
1. `.brain/INDEX.md`
2. `.brain/{domain}/{project}/memory/guidelines.md`
3. `.brain/{domain}/{project}/memory/decisions/` (for similar past decisions)
4. `.brain/{domain}/{project}/memory/lessons/` (for known pitfalls)
5. Relevant `.brain/{domain}/{project}/skills/` file

## R6 — Database Connections Are Gitignored

`.brain/{domain}/{project}/connections/` is in `.gitignore`. Never push credentials.
