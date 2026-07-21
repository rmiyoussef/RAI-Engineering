# DevOps / System Management Domain

> Domain-isolated knowledge base for DevOps and system management projects.
> Plans, rules, skills, and memory live in `.brain/devops/{project-name}/`.

## Structure

```
devops/{project-name}/
├── plans/       ← Project plans for this domain
├── rules/       ← Tool-specific rules (e.g. terraform-rules.md, kubernetes-rules.md)
├── skills/      ← Code templates for this domain
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

DevOps plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
