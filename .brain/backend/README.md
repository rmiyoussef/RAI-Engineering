# Backend Domain

> Domain-isolated knowledge base for Backend projects.
> Plans, rules, skills, and memory live in `.brain/backend/{project-name}/`.

## Structure

```
backend/{project-name}/
├── plans/       ← Project plans for this domain
├── rules/       ← Framework-specific rules (e.g. laravel-rules.md, express-rules.md)
├── skills/      ← Code templates for this domain
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

Backend plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
