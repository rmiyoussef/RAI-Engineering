# Memory System

> How the BRAIN organizes, indexes, and queries project memory.
> Memory is the project's persistent knowledge. It grows with every session.

---

## Memory Layout

```
memory/
├── INDEX.md                         ← Master index (auto-maintained)
├── guidelines.md                    ← Project structure & conventions
├── decisions/                       ← Architecture decisions
│   └── 2026-07-10-jwt-auth.md
├── architecture/                    ← Component maps
│   └── auth-system.md
├── lessons/                         ← Things learned
│   └── 2026-07-10-n-plus-one-fix.md
├── sessions/                        ← Session summaries
│   └── 2026-07-10-implement-auth.md
├── business/                        ← Business rules
│   └── two-factor-auth.md
└── connections/                     ← Database connections ⚠️ GITIGNORED
    └── database.md
```

### guidelines.md

The `memory/guidelines.md` file holds the project's architecture, conventions, commands, middleware, database rules, and security setup. It is created by ARCHITECT on first install using `templates/GUIDELINES.md` as a starting point.

See `agents/ARCHITECT.md` for how guidelines are managed.

### Git Safety

| Path | Committed? | Why |
|------|-----------|-----|
| `memory/decisions/` | ✅ Yes | Architecture decisions are project knowledge |
| `memory/architecture/` | ✅ Yes | Component maps are part of the project |
| `memory/lessons/` | ✅ Yes | Lessons benefit the whole team |
| `memory/sessions/` | ✅ Yes | Session history helps onboard new devs |
| `memory/business/` | ✅ Yes | Business rules are project knowledge |
| `memory/guidelines.md` | ✅ Yes | Project structure is shared knowledge |
| `memory/INDEX.md` | ✅ Yes | Master index helps everyone navigate |
| `memory/connections/` | ❌ **No** | Contains schema info but lives near potential secrets |

---

## INDEX.md — The Master Index

The `memory/INDEX.md` file is the **entry point for all memory queries**. It's auto-maintained by the MEMORY SCRIBE after every session.

### Format

```markdown
# Memory Index

> Auto-maintained. Last updated: 2026-07-10

## Active Decisions
- [JWT Authentication](decisions/2026-07-10-jwt-auth.md) — Using JWT over session auth

## Architecture
- [Auth System](architecture/auth-system.md) — Login, register, password reset
- [Order Processing](architecture/order-processing.md) — Order lifecycle

## Lessons
- [N+1 Query Fix](lessons/2026-07-10-n-plus-one-fix.md) — Eager loading posts

## Sessions
- [Implement JWT Auth](sessions/2026-07-10-implement-auth.md) — Completed score 9/10
```

### How it's maintained

After every session, MEMORY SCRIBE calls:
```
MEMORY SCRIBE: "I need to update INDEX.md"
  ├─► List files in memory/decisions/ → add new ones
  ├─► List files in memory/lessons/ → add new ones
  ├─► List files in memory/sessions/ → add new ones
  └─► List files in memory/architecture/ → add new ones
```

---

## Memory Flow

### Before Any Work

```
BRAIN receives task
    │
    ├─► Read memory/INDEX.md         ← What does the project know?
    ├─► Read memory/guidelines.md    ← What are the project's conventions?
    ├─► Read memory/decisions/       ← Past decisions about this area
    ├─► Read memory/architecture/    ← Current component map
    ├─► Read memory/lessons/         ← Known pitfalls
    └─► Read memory/connections/     ← Database schema (if needed)
```

### After Any Work

```
Task complete
    │
    ├─► MEMORY SCRIBE writes decisions/   ← What was decided
    ├─► MEMORY SCRIBE writes lessons/      ← What was learned
    ├─► MEMORY SCRIBE writes session/      ← What happened
    ├─► ARCHITECT updates guidelines/      ← Did architecture change?
    └─► MEMORY SCRIBE updates INDEX.md     ← Keep index in sync
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

### Session File

```markdown
# Session: {{date}} - {{goal}}

**Goal:** {{what we wanted to achieve}}
**Outcome:** {{what actually happened}}
**Agents Involved:** PLANNER, EXECUTOR, REVIEWER, etc.

## Summary
{{paragraph summary}}

## Files Changed
- {{path}} — {{change description}}

## Review
- Score: {{score}}/10
- Issues: {{count}}

## Next Steps
- {{open items}}
```

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
| **TESTER** | Nothing specific | test files |
| **MEMORY SCRIBE** | All stores (to build index) | decisions/, lessons/, sessions/, INDEX.md |
| **GITHUB** | decisions/, INDEX.md | Nothing |
