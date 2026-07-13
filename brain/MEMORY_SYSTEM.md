# Memory System

> How the BRAIN organizes, indexes, and queries project memory.
> Memory is the project's persistent knowledge. It grows with every session.
> Memory lives in `.brain/` — in your project root. Works with ANY AI tool (Claude, Cursor, Copilot, etc.).
> **Every task, test, and discussion saves a summary — always.**

---

## Memory Layout

```
.brain/
├── INDEX.md                         ← Master index (auto-maintained)
├── guidelines.md                    ← Project structure & conventions
├── decisions/                       ← Architecture decisions
│   └── 2026-07-10-jwt-auth.md
├── architecture/                    ← Component maps
│   └── auth-system.md
├── lessons/                         ← Things learned
│   └── 2026-07-10-n-plus-one-fix.md
├── sessions/                        ← Every interaction, task, discussion
│   ├── 2026-07-10-implement-auth.md
│   └── 2026-07-10-discussion-api-design.md
├── tests/                           ← Team-ready test summaries (per feature)
│   └── 2026-07-13-onboarding-api.md
├── tasks/                           ← Full task summaries (files, tests, security, perf)
│   └── 2026-07-13-create-onboarding.md
├── templates/                       ← Project code templates
│   ├── service.md
│   ├── controller.md
│   ├── resource.md
│   └── crud.md
├── business/                        ← Business rules
│   └── two-factor-auth.md
└── connections/                     ← Database connections ⚠️ GITIGNORED
    └── database.md
```

### Why `.brain/` (not `.claude/memory/`)?

| Reason | Explanation |
|--------|-------------|
| **Any AI tool** | Not tied to Claude. Cursor, Copilot, Windsurf — all can read `.brain/` |
| **Team-wide** | Commit to repo. Every developer and every AI sees the same knowledge |
| **Clean root** | Single `.brain/` folder is self-documenting |
| **No lock-in** | Switch AI tools without losing project memory |

### Session Entry — Every Interaction

**Every single interaction** — task, discussion, question, exploration — must write a session entry into `.brain/sessions/`. This ensures:

- If you close the terminal, you can resume exactly where you left off
- Nothing is lost between sessions
- The BRAIN reads past sessions before starting new work
- Continuity is maintained across days

A session entry is written after:
- ✅ Completing a task
- ✅ Having a design discussion
- ✅ Exploring the codebase
- ✅ Answering a question
- ✅ Making any decision
- ✅ Any interaction that produced value

### guidelines.md

The `.brain/guidelines.md` file holds the project's architecture, conventions, commands, middleware, database rules, and security setup. Created by ARCHITECT on first install.

### Test & Task Summaries

**Always written — never skipped.**

| Summary | Location | When | Template |
|---------|----------|------|----------|
| 🧪 Test Summary | `.brain/tests/{{date}}-{{feature}}.md` | After every test session | `templates/summary/TEST_SUMMARY.md` |
| 📋 Task Summary | `.brain/tasks/{{date}}-{{task}}.md` | After every completed task | `templates/summary/TASK_SUMMARY.md` |

If you ask for a summary and none exists, I create it before responding.

### Git Safety

| Path | Committed? | Why |
|------|-----------|-----|
| `.brain/decisions/` | ✅ Committed | Architecture decisions are project knowledge |
| `.brain/architecture/` | ✅ Committed | Component maps are part of the project |
| `.brain/lessons/` | ✅ Committed | Lessons benefit the whole team |
| `.brain/sessions/` | ✅ Committed | Session history helps resume work |
| `.brain/tests/` | ✅ Committed | Test summaries are team knowledge |
| `.brain/tasks/` | ✅ Committed | Task records show what was done |
| `.brain/skills/` | ✅ Committed | Code templates are project standards |
| `.brain/business/` | ✅ Committed | Business rules are project knowledge |
| `.brain/guidelines.md` | ✅ Committed | Project structure is shared knowledge |
| `.brain/INDEX.md` | ✅ Committed | Master index helps everyone navigate |
| `.brain/connections/` | ❌ **Never** | Contains schema info — never push secrets |

---

## INDEX.md — The Master Index

The `.brain/INDEX.md` file is the **entry point for all memory queries**. Auto-maintained by MEMORY SCRIBE after every session.

### Format

```markdown
# Memory Index

> Auto-maintained. Last updated: 2026-07-13

## Active Decisions
- [JWT Authentication](decisions/2026-07-10-jwt-auth.md) — Using JWT over session auth

## Architecture
- [Auth System](architecture/auth-system.md) — Login, register, password reset

## Lessons
- [N+1 Query Fix](lessons/2026-07-10-n-plus-one-fix.md) — Eager loading posts

## Sessions
- [Implement JWT Auth](sessions/2026-07-10-implement-auth.md) — Completed score 9/10

## Test Summaries
- [Onboarding API](tests/2026-07-13-onboarding-api.md) — 15 tests, all pass

## Task Summaries
- [Create Onboarding](tasks/2026-07-13-create-onboarding.md) — 4 files, 15 tests
```

### How it's maintained

After every session, MEMORY SCRIBE calls:
```
MEMORY SCRIBE: "I need to update INDEX.md"
  ├─► List files in .brain/decisions/ → add new ones
  ├─► List files in .brain/lessons/ → add new ones
  ├─► List files in .brain/sessions/ → add new ones
  ├─► List files in .brain/tests/ → add new ones
  ├─► List files in .brain/tasks/ → add new ones
  └─► List files in .brain/architecture/ → add new ones
```

---

## Memory Flow

### Before Any Work

```
BRAIN receives task
    │
    ├─► Read .brain/INDEX.md          ← What does the project know?
    ├─► Read .brain/guidelines.md     ← Project conventions
    ├─► Read .brain/decisions/        ← Past decisions
    ├─► Read .brain/architecture/     ← Current component map
    ├─► Read .brain/lessons/          ← Known pitfalls
    ├─► Read .brain/tests/            ← Past test results (for context)
    ├─► Read .brain/tasks/            ← Past task summaries (for context)
    └─► Read .brain/connections/      ← Database schema (if needed)
```

### After Any Work (Always)

```
Task/Discussion/Question complete — ALWAYS write
    │
    ├─► MEMORY SCRIBE writes sessions/ ← WHAT happened (ALWAYS)
    ├─► MEMORY SCRIBE writes tests/    ← Test summary (if testing done)
    ├─► MEMORY SCRIBE writes tasks/    ← Task summary (always)
    ├─► MEMORY SCRIBE writes decisions/ ← WHAT was decided (if applicable)
    ├─► MEMORY SCRIBE writes lessons/  ← WHAT was learned (if applicable)
    ├─► ARCHITECT updates guidelines/  ← Did architecture change?
    └─► MEMORY SCRIBE updates INDEX.md ← Keep index in sync
```

---

## Session Entry — Written After EVERY Interaction

This is the most important rule. Every interaction writes a session entry.

### Session File Format

```markdown
# Session: 2026-07-10 — Discussion about API Design

**Date:** 2026-07-10
**Type:** Task | Discussion | Exploration | Question
**Duration:** ~15 min

## Context
What prompted this session.

## What Happened
Summary of the conversation, decisions, findings.

## Key Takeaways
- Point 1
- Point 2

## Files Referenced
- path/to/file.php

## Summary Written
- [Test Summary](tests/2026-07-13-feature.md)
- [Task Summary](tasks/2026-07-13-task.md)

## Next Steps
- [ ] Action item 1
- [ ] Action item 2

## Related
- See also: [[decisions/past-decision.md]]
```

---

## Memory Entry Format

### Decision File

```markdown
# Decision: {{title}}

**Date:** {{date}}
**Context:** {{why this decision was needed}}

## Options Considered
- Option A: {{pros/cons}}
- Option B: {{pros/cons}}

## Decision
**Chosen:** {{option}}
**Rationale:** {{why}}

## Consequences
- {{what this enables}}
- {{what this constrains}}

## Related
- See also: [[decisions/past-decision.md]]
- Affects: {{files/components}}
```

### Lesson File

```markdown
# Lesson: {{title}}

**Date:** {{date}}
**What:** {{what happened}}
**Impact:** {{low | medium | high}}
**Root Cause:** {{why it happened}}
**Prevention:** {{how to avoid in future}}
**Applies to:** {{files/patterns}}
```

---

## Summary Templates

| Template | Purpose | Output Location |
|----------|---------|----------------|
| `templates/summary/TEST_SUMMARY.md` | Test results with icons, tables, perf, DB, security | `.brain/tests/` |
| `templates/summary/TASK_SUMMARY.md` | Full task record with quality assessment | `.brain/tasks/` |

Use these templates to ensure consistent, team-readable summaries every time.

---

## How Agents Use Memory

| Agent | Reads | Writes |
|-------|-------|--------|
| **BRAIN** | INDEX.md, guidelines.md — before any task | Creates session UUID |
| **PLANNER** | decisions/, architecture/, guidelines.md | Nothing — passes to MEMORY SCRIBE |
| **ARCHITECT** | guidelines.md, architecture/ | guidelines.md |
| **EXECUTOR** | architecture/, connections/ | Nothing — passes to MEMORY SCRIBE |
| **REVIEWER** | decisions/ (for precedent) | Nothing — passes to MEMORY SCRIBE |
| **BACKEND QA** | architecture/ | Nothing — passes to MEMORY SCRIBE |
| **DATABASE** | connections/ | connections/ (schema only) |
| **SECURITY** | architecture/ | Nothing — passes to MEMORY SCRIBE |
| **TESTER** | templates/testing/ | test files + test summaries |
| **MEMORY SCRIBE** | All stores (to build index) | decisions/, lessons/, sessions/, tests/, tasks/, INDEX.md |
| **GITHUB** | decisions/, INDEX.md | Nothing |
| **SUMMARY** | All agent outputs | tests/, tasks/ summaries |

---

## Template

Use `templates/MEMORY_DECISION.md` for decision entries.
