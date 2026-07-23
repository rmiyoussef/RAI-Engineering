# Frontend Domain

> Domain-isolated knowledge base for Frontend projects.
> Plans, rules, skills, and memory live in `.brain/frontend/{project-name}/`.
> Skills: 7 (Mantine, UI eng, design, devtools, animations, Apple design, browser testing)
> Reference: [Mantine UI](reference/mantine.md) — full docs at mantine.dev/llms-full.txt (~4MB)

## Structure

```
frontend/{project-name}/
├── plans/       ← Project plans for this domain
├── rules/       ← Framework-specific rules (e.g. react-rules.md, vue-rules.md)
├── skills/      ← Code templates for this domain
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

Frontend plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
