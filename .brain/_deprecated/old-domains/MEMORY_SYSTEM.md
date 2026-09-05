# Memory System

> How the BRAIN organizes, indexes, and queries project memory.
> Memory is the project's persistent knowledge. It grows with every session.
> Memory lives in `.brain/` — in your project root. Works with ANY AI tool (Claude, Cursor, Copilot, etc.).
> **Every task, test, and discussion saves a summary — always.**

---

## Domain-Isolated Memory Layout

Knowledge is organized into **domain-isolated subtrees**. Each domain is self-contained.

```
.brain/
├── INDEX.md                         ← Master index (auto-maintained)
├── agents/                          ← Agent definitions (framework-agnostic)
├── brain/                           ← Core system files (MISSION, PRINCIPLES, RULES, SYSTEM)
├── templates/                       ← Summary & testing templates
├── session-bus/                     ← Inter-session message bus ⚠️ GITIGNORED
│   ├── inbox/{uuid}/                ← Incoming messages
│   ├── outbox/{uuid}/               ← Outgoing messages
│   └── archive/                     ← Processed messages
├── sessions/                        ← Session registry
│   ├── identity.json                ← This session's persistent identity
│   └── live/                        ← Live session registrations ⚠️ GITIGNORED
│
└── backend/              ← Backend domain
│   ├── memory/
│   │   ├── guidelines.md            ← Project structure & conventions
│   │   ├── INDEX.md                 ← Domain-specific index (auto-maintained)
│   │   ├── decisions/               ← Architecture decisions
│   │   ├── architecture/            ← Component maps
│   │   ├── lessons/                 ← Things learned
│   │   ├── sessions/                ← Every interaction, task, discussion
│   │   ├── tests/                   ← Team-ready test summaries (per feature)
│   │   ├── tasks/                   ← Full task summaries
│   │   └── business/                ← Business rules
│   ├── skills/                      ← Domain code templates
│   ├── rules/                       ← Domain conventions
│   ├── plans/                       ← Domain plans
│   └── connections/                 ← Database connections ⚠️ GITIGNORED
│
├── frontend/             ← Frontend domain (same structure)
├── mobile-ios/            ← iOS domain (same structure)
├── mobile-android/        ← Android domain (same structure)
└── devops/                ← DevOps domain (same structure)
```

### Why Domain Isolation?

| Reason | Explanation |
|--------|-------------|
| **No cross-contamination** | Backend rules never apply to frontend code |
| **Multi-project clarity** | Each project in a domain has its own subtree |
| **Framework-agnostic core** | `.brain/agents/` and `.brain/brain/` stay framework-agnostic |
| **Future-proof** | Add new domains without restructuring |

### guidelines.md

The `.brain/{domain}/memory/guidelines.md` file holds the project's architecture, conventions, commands, middleware, database rules, and security setup. Created by ARCHITECT on first install.

### Test & Task Summaries

**Always written — never skipped.**

| Summary | Location | When | Template |
|---------|----------|------|----------|
| 🧪 Test Summary | `.brain/{domain}/memory/tests/{date}-{feature}.md` | After every test session | `templates/summary/TEST_SUMMARY.md` |
| 📋 Task Summary | `.brain/{domain}/memory/tasks/{date}-{task}.md` | After every completed task | `templates/summary/TASK_SUMMARY.md` |

If you ask for a summary and none exists, I create it before responding.

### Git Safety

| Path | Committed? | Why |
|------|-----------|-----|
| `.brain/{domain}/memory/decisions/` | ✅ Committed | Architecture decisions are project knowledge |
| `.brain/{domain}/memory/architecture/` | ✅ Committed | Component maps are part of the project |
| `.brain/{domain}/memory/lessons/` | ✅ Committed | Lessons benefit the whole team |
| `.brain/{domain}/memory/sessions/` | ✅ Committed | Session history helps resume work |
| `.brain/{domain}/memory/tests/` | ✅ Committed | Test summaries are team knowledge |
| `.brain/{domain}/memory/tasks/` | ✅ Committed | Task records show what was done |
| `.brain/{domain}/skills/` | ✅ Committed | Code templates are project standards |
| `.brain/{domain}/memory/business/` | ✅ Committed | Business rules are project knowledge |
| `.brain/{domain}/memory/guidelines.md` | ✅ Committed | Project structure is shared knowledge |
| `.brain/{domain}/connections/` | ❌ **Never** | Contains schema info — never push secrets |

---

## INDEX.md — The Master Index

The `.brain/INDEX.md` file is the **entry point for all memory queries**. Auto-maintained by MEMORY SCRIBE after every session. It points to domain-specific subtrees.

### Format

```markdown
# Memory Index

> Auto-maintained. Last updated: 2026-07-21

## Active Decisions
- [JWT Authentication](backend/memory/decisions/2026-07-10-jwt-auth.md)

## Architecture
- [Auth System](backend/memory/architecture/auth-system.md)

## Lessons
- [N+1 Query Fix](backend/memory/lessons/2026-07-10-n-plus-one-fix.md)

## Sessions
- [Implement JWT Auth](backend/memory/sessions/2026-07-10-implement-auth.md)
```

### How it's maintained

After every session, MEMORY SCRIBE calls:
```
MEMORY SCRIBE: "I need to update INDEX.md"
  ├─► List files in .brain/{domain}/memory/decisions/ → add new ones
  ├─► List files in .brain/{domain}/memory/lessons/ → add new ones
  ├─► List files in .brain/{domain}/memory/sessions/ → add new ones
  ├─► List files in .brain/{domain}/memory/tests/ → add new ones
  ├─► List files in .brain/{domain}/memory/tasks/ → add new ones
  └─► List files in .brain/{domain}/memory/architecture/ → add new ones
```

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
    ├─► Read .brain/INDEX.md                 ← What does the project know?
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

## Session Entry — Written After EVERY Interaction

This is the most important rule. Every interaction writes a session entry.

### Session File Format

```markdown
# Session: 2026-07-10 — Discussion about API Design

**Date:** 2026-07-10
**Domain:** Backend
**Project:** my-project
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
**Domain:** Backend | Frontend | Mobile iOS | Mobile Android | DevOps
**Project:** {{project-name}}
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
**Domain:** Backend | Frontend | Mobile iOS | Mobile Android | DevOps
**Project:** {{project-name}}
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
| `templates/summary/TEST_SUMMARY.md` | Test results with icons, tables, perf, DB, security | `.brain/{domain}/memory/tests/` |
| `templates/summary/TASK_SUMMARY.md` | Full task record with quality assessment | `.brain/{domain}/memory/tasks/` |

Use these templates to ensure consistent, team-readable summaries every time.

---

## How Agents Use Memory

| Agent | Reads | Writes |
|-------|-------|--------|
| **BRAIN** | INDEX.md — before any task | Creates session UUID |
| **PLANNER** | {domain}/memory/decisions/, architecture/, guidelines.md | Nothing — passes to MEMORY SCRIBE |
| **ARCHITECT** | {domain}/memory/guidelines.md | {domain}/memory/guidelines.md |
| **EXECUTOR** | {domain}/memory/architecture/, connections/ | Nothing — passes to MEMORY SCRIBE |
| **REVIEWER** | {domain}/memory/decisions/ (for precedent) | Nothing — passes to MEMORY SCRIBE |
| **BACKEND QA** | {domain}/memory/architecture/ | Nothing — passes to MEMORY SCRIBE |
| **DATABASE** | {domain}/connections/ | {domain}/connections/ (schema only) |
| **SECURITY** | {domain}/memory/architecture/ | Nothing — passes to MEMORY SCRIBE |
| **TESTER** | templates/testing/ | test files + test summaries in {domain}/memory/tests/ |
| **MEMORY SCRIBE** | All domain stores (to build index) | {domain}/memory/decisions/, lessons/, sessions/, tests/, tasks/, INDEX.md |
| **GITHUB** | decisions/, INDEX.md | Nothing |
| **SUMMARY** | All agent outputs | {domain}/memory/tests/, tasks/ summaries |

---

## Template

Use `templates/MEMORY_DECISION.md` for decision entries.
