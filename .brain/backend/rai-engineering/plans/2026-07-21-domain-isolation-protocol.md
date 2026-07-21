# Plan: Domain Isolation Protocol — RAI-Engineering Refactoring

> **Date:** 2026-07-21
> **Status:** Draft for approval
> **Version Impact:** v1.2 → v1.3
> **Domain:** Backend (RAI-Engineering self-refactoring)

---

## Goal

Restructure RAI-Engineering's `.brain/` system to enforce strict **domain isolation**: Backend, Frontend, Mobile (iOS/Android), and DevOps each get their own isolated subtree of plans, rules, skills, and memory. No domain leaks into another.

---

## Rationale

Currently all project knowledge lives flat under `.brain/memory/`, `.brain/rules/`, `.brain/skills/`. If you install RAI-Engineering into a full-stack project with Laravel backend + React frontend, the backend rules and frontend rules would mix. This refactoring ensures:

- Backend work only reads/writes backend's subtree
- Frontend work only reads/writes frontend's subtree
- Cross-domain projects stay organized
- AI tools never accidentally apply backend patterns to frontend code

---

## New Structure

### Engine (meta) Level — Always Available

```
.brain/
├── agents/                           ← Agent definitions — UNCHANGED
├── brain/                            ← Core OS files — UNCHANGED
├── templates/                        ← Summary & testing templates — UNCHANGED  
├── session-bus/                      ← Inter-session message bus — UNCHANGED
├── sessions/                         ← Session registry — UNCHANGED
├── INDEX.md                          ← Updated master index
└── README.md                         ← UNCHANGED

skills/                               ← Cross-domain RAI-Engineering skills
├── CODE_REVIEW.md                    ← Framework-agnostic review patterns
├── TESTING.md                        ← Framework-agnostic testing patterns
├── GIT.md                            ← Git workflow patterns
├── MEMORY.md                         ← Memory management patterns
└── BACKEND_ENGINEERING.md            ← Backend engineering patterns
```

### Domain-Isolated Subtrees

```
.brain/backend/{project-name}/
├── plans/                            ← Backend project plans
├── rules/                            ← Backend project rules
├── skills/                           ← Backend project code templates
└── memory/                           ← Backend project knowledge
    ├── guidelines.md
    ├── decisions/
    ├── architecture/
    ├── lessons/
    ├── sessions/
    ├── tests/
    ├── tasks/
    └── business/

.brain/frontend/{project-name}/
├── plans/
├── rules/
├── skills/
└── memory/

.brain/mobile-ios/{project-name}/
├── plans/
├── rules/
├── skills/
└── memory/

.brain/mobile-android/{project-name}/
├── plans/
├── rules/
├── skills/
└── memory/

.brain/devops/{project-name}/
├── plans/
├── rules/
├── skills/
└── memory/
```

---

## Migration of Existing Content

RAI-Engineering itself is a **Backend** project. Its existing memory, rules, skills, and plans move into `.brain/backend/rai-engineering/`.

| Current Path | New Path | Action |
|---|---|---|
| `.brain/memory/` | `.brain/backend/rai-engineering/memory/` | Move |
| `.brain/rules/` | `.brain/backend/rai-engineering/rules/` | Move |
| `.brain/skills/` | `.brain/backend/rai-engineering/skills/` | Move |
| `.brain/connections/` | `.brain/backend/rai-engineering/connections/` | Move |
| `.brain/plans/` | `.brain/backend/rai-engineering/plans/` | Move |
| `.brain/INDEX.md` | `.brain/INDEX.md` (updated) | Modify |
| `.brain/README.md` | `.brain/README.md` (updated) | Modify |
| `.gitignore` | `.gitignore` (updated) | Modify |

---

## Files to Create/Modify

### Phase 1: Create Backend Domain Structure

| Action | Path | Purpose |
|--------|------|---------|
| Create | `.brain/backend/` | New domain root |
| Create | `.brain/backend/rai-engineering/` | RAI-Engineering's own subtree |
| Create | `.brain/backend/rai-engineering/memory/` | Domain-isolated memory |
| Create | `.brain/backend/rai-engineering/rules/` | Domain-isolated rules |
| Create | `.brain/backend/rai-engineering/skills/` | Domain-isolated skills |
| Create | `.brain/backend/rai-engineering/plans/` | Domain-isolated plans |
| Create | `.brain/backend/rai-engineering/connections/` | Domain-isolated connections |
| Create | `.brain/frontend/` | Stub (empty, for future projects) |
| Create | `.brain/mobile-ios/` | Stub (empty) |
| Create | `.brain/mobile-android/` | Stub (empty) |
| Create | `.brain/devops/` | Stub (empty) |

### Phase 2: Migrate Content

| Action | From | To |
|--------|------|----|
| Move | `.brain/memory/guidelines.md` | `.brain/backend/rai-engineering/memory/guidelines.md` |
| Move | `.brain/memory/decisions/` | `.brain/backend/rai-engineering/memory/decisions/` |
| Move | `.brain/memory/architecture/` | `.brain/backend/rai-engineering/memory/architecture/` |
| Move | `.brain/memory/lessons/` | `.brain/backend/rai-engineering/memory/lessons/` |
| Move | `.brain/memory/sessions/` | `.brain/backend/rai-engineering/memory/sessions/` |
| Move | `.brain/memory/tests/` | `.brain/backend/rai-engineering/memory/tests/` |
| Move | `.brain/memory/tasks/` | `.brain/backend/rai-engineering/memory/tasks/` |
| Move | `.brain/memory/business/` | `.brain/backend/rai-engineering/memory/business/` |
| Move | `.brain/rules/` | `.brain/backend/rai-engineering/rules/` |
| Move | `.brain/skills/` | `.brain/backend/rai-engineering/skills/` |
| Move | `.brain/connections/` | `.brain/backend/rai-engineering/connections/` |
| Move | `.brain/plans/` | `.brain/backend/rai-engineering/plans/` |

### Phase 3: Update Meta Files

| Action | Path | Purpose |
|--------|------|---------|
| Modify | `.brain/INDEX.md` | Reflect new domain-isolated structure |
| Modify | `.brain/README.md` | Document domain isolation |
| Modify | `.gitignore` | Update paths for gitignored content |

### Phase 4: Update CLAUDE.md

| Action | Section | Changes |
|--------|---------|---------|
| Modify | Memory System | New domain-isolated layout |
| Modify | Principles | Add Domain Isolation principle |
| Modify | Rules | Add Domain Isolation rules (new R36-R40) |
| Modify | Version | Bump to v1.3 |

### Phase 5: Update Session & Memory System Docs

| Action | Path | Changes |
|--------|------|---------|
| Modify | `.brain/brain/MEMORY_SYSTEM.md` | Domain-isolated memory layout |
| Modify | `.brain/brain/SYSTEM.md` | Add domain isolation to Initial Load Protocol |

---

## New Rules (for CLAUDE.md)

### R36 — Domain Identity Required
Every task must declare its domain (Backend, Frontend, Mobile iOS, Mobile Android, DevOps) before work begins. The Brain must ask if unknown.

### R37 — Domain-Isolated Storage
Plans, rules, skills, and memory for one domain must never be stored in or read from another domain's subtree. Each domain is self-contained.

### R38 — Cross-Domain Reference Protocol
When a task spans multiple domains, explicitly cross-reference between domain subtrees. Do not duplicate content across domains — use relative links: `See [backend rules](../backend/{project}/rules/api-design.md)`.

### R39 — Framework-Scoped Rules
Rules and skills within a domain folder must be scoped to the declared framework (e.g., `backend/laravel/rules/query-optimization.md`, not a generic `backend/rules/query-optimization.md`).

### R40 — Domain Folder Initialization
When starting work on a new project in a domain, the Brain must first check if the domain folder exists. If not, create it with `plans/`, `rules/`, `skills/`, and `memory/` subdirectories before proceeding.

---

## Updated Initial Load Protocol

The current Phase 0 → Phase 1 load sequence gets an additional domain-isolation step:

```
[1] Read .brain/brain/MISSION.md, PRINCIPLES.md, RULES.md, LIMITATIONS.md, SYSTEM.md
[2] **DETERMINE DOMAIN** — Ask user or derive from task context
[3] **CHECK DOMAIN FOLDER** — .brain/{domain}/{project-name}/ exists?
    |   If not → create with plans/, rules/, skills/, memory/
[4] Read .brain/{domain}/{project-name}/INDEX.md (or .brain/INDEX.md for meta)
[5] Read .brain/{domain}/{project-name}/memory/guidelines.md
[6] Read .brain/{domain}/{project-name}/memory/decisions/
...
```

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Agent files reference old `.brain/memory/` paths | Low | Agent files currently use generic references ("check INDEX.md") not absolute paths. Verify none hardcode paths. |
| Breaking existing installs | Medium | Install script (setup.sh) creates `.brain/` — update it to create domain structure |
| Users confused by old vs new paths | Medium | Keep symlinks or README notices during transition |
| File move loses git history | Low | Use `git mv` for moves — preserves history |
| `session-bus/` and `sessions/live/` paths in CLAUDE.md | None | Already at `.brain/` root, not affected |

---

## Summary

| Phase | Files Created | Files Moved | Files Modified | Risk |
|-------|-------------|-------------|----------------|------|
| P1: Create structure | 5 domain dirs + 5 project dirs = ~25 dirs | 0 | 0 | None |
| P2: Migrate content | 0 | ~20 files | 0 | Low (git mv) |
| P3: Update meta files | 0 | 0 | 3 | Low |
| P4: Update CLAUDE.md | 0 | 0 | 1 | Medium |
| P5: Update session docs | 0 | 0 | 2 | Low |

**Total: 25 new directories, 20 file moves, 6 file modifications.**
