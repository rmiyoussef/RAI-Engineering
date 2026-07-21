# 🧠 Project Brain Index

> **Last updated:** 2026-07-21
> **Purpose:** Everything an AI tool needs to understand this project.
> **How to use:** Start here, identify which domain your task belongs to, then read the relevant subtree.

---

## Domain Isolation Structure

RAI-Engineering organizes knowledge into **domain-isolated subtrees**. Each domain is self-contained.

```
.brain/
├── INDEX.md                              ← You are here
├── README.md                             ← What this folder is
├── agents/                               ← Agent definitions (framework-agnostic)
├── brain/                                ← Core OS files
├── templates/                            ← Summary & testing templates
├── session-bus/                          ← Inter-session message bus (gitignored)
├── sessions/                             ← Session registry
│
├── backend/                              ← Backend domain
│   ├── README.md
│   └── rai-engineering/                  ← RAI-Engineering's own knowledge
│       ├── memory/guidelines.md          ← Architecture, conventions, stack
│       ├── memory/decisions/             ← Past architecture decisions
│       ├── memory/architecture/          ← Component maps
│       ├── memory/lessons/               ← Things learned
│       ├── memory/sessions/              ← Every interaction logged
│       ├── memory/tests/                 ← Test summaries per feature
│       ├── memory/tasks/                 ← Task summaries with results
│       ├── memory/business/              ← Business rules
│       ├── rules/                        ← Project-specific rules
│       ├── skills/                       ← Code templates & patterns
│       ├── plans/                        ← Project plans
│       └── connections/                  ← DB connections (gitignored)
│
├── frontend/                             ← Frontend domain (for future projects)
├── mobile-ios/                           ← iOS domain (for future projects)
├── mobile-android/                       ← Android domain (for future projects)
└── devops/                               ← DevOps domain (for future projects)
```

---

## Quick Start

| If you want to... | Read this |
|-------------------|-----------|
| Understand project architecture | `.brain/backend/rai-engineering/memory/guidelines.md` |
| Check past decisions | `.brain/backend/rai-engineering/memory/decisions/` |
| Learn from past mistakes | `.brain/backend/rai-engineering/memory/lessons/` |
| See what was done recently | `.brain/backend/rai-engineering/memory/tasks/` |
| Create a service | `.brain/backend/rai-engineering/skills/service.md` |
| Create a controller | `.brain/backend/rai-engineering/skills/controller.md` |
| Create an API resource | `.brain/backend/rai-engineering/skills/resource.md` |
| Generate a full CRUD | `.brain/backend/rai-engineering/skills/crud.md` |
| Follow project conventions | `.brain/backend/rai-engineering/rules/project-rules.md` |
| Check DB schema | `.brain/backend/rai-engineering/connections/database.md` |
| Browse plans | `.brain/backend/rai-engineering/plans/` |

---

## Active Decisions

- [Caveman ULTRA Install](backend/rai-engineering/memory/decisions/caveman-ultra-install.md) — 67% token compression
- [Super TESTER Upgrade](backend/rai-engineering/memory/decisions/super-tester-upgrade.md) — 5 testing modes
- [.brain/ Migration](backend/rai-engineering/memory/decisions/brain-migration.md) — Team-wide AI knowledge base

## Lessons

- [Version Bump Before Push](backend/rai-engineering/memory/lessons/version-bump-before-push.md) — R30

## Task Summaries

- [Super TESTER Upgrade](backend/rai-engineering/memory/tasks/2026-07-13-super-tester-upgrade.md)
- [.brain/ Migration](backend/rai-engineering/memory/tasks/2026-07-13-brain-migration.md)

## Plans

- [Multi-Session Mesh](backend/rai-engineering/plans/2026-07-19-multi-session-architecture.md)
- [Domain Isolation Protocol](backend/rai-engineering/plans/2026-07-21-domain-isolation-protocol.md)
