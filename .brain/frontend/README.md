# Frontend Domain

> Domain-isolated knowledge base for Frontend projects.
> Plans, rules, skills, and memory live in `.brain/frontend/{project-name}/`.

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
