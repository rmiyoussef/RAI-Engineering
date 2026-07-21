# Decision: Migrate to .brain/ Folder

**Date:** 2026-07-13
**Context:** Project memory was in `.claude/memory/` (Claude-only). Need a tool-agnostic knowledge base.

## Options Considered
- Stay in `.claude/memory/` — works for Claude only, not for team
- `.brain/` — clear but doesn't convey "AI knowledge base"
- `.brain/` — self-documenting, tells any AI "this is the project brain"

## Decision
**Chosen:** `.brain/`
**Rationale:** `.brain/` is self-documenting. Any AI tool sees the folder name and knows it's the project's knowledge base. Contains memory, skills, rules in one place.

## Structure
```
.brain/
├── INDEX.md           ← Master index
├── README.md          ← What this is
├── memory/            ← Decisions, lessons, sessions, tests, tasks
├── skills/            ← Project code templates (service, controller, resource, crud)
├── rules/             ← Project conventions
└── connections/       ← DB schema (gitignored)
```
