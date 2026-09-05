# Frontend Domain

> Domain-isolated knowledge base for Frontend projects.
> Plans, rules, skills, and memory live directly in `.brain/frontend/` — no nesting.
> Skills: 7 (Mantine, UI eng, design, devtools, animations, Apple design, browser testing)
> Reference: [Mantine UI](reference/mantine.md) — full docs at mantine.dev/llms-full.txt (~4MB)

## Structure

```
frontend/
├── plans/       ← Project plans for this domain
├── rules/       ← 11 frontend engineering rules (component, state, perf, a11y, etc.)
├── skills/      ← Code templates & patterns (Mantine, UI eng, design, animations)
├── reference/   ← External docs (Mantine UI integration guide)
├── FRONTEND_BEST_PRACTICES.md ← Team-readable guide
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

Frontend plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
