# Backend Domain

> Domain-isolated knowledge base for Backend projects.
> Plans, rules, skills, and memory live directly in `.brain/backend/` — no nesting.

## Structure

```
backend/
├── plans/       ← Project plans
├── rules/       ← Framework-specific rules (e.g. laravel-rules.md, express-rules.md)
├── skills/      ← Code templates & patterns (service, controller, resource, crud)
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

Backend plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
