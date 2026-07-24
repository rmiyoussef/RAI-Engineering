# DevOps / System Management Domain

> Domain-isolated knowledge base for DevOps and system management projects.
> Plans, rules, skills, and memory live in `.brain/devops/{project-name}/`.
> Skills: 1 (CI/CD automation)

## Structure

```
devops/{project-name}/
├── plans/       ← Project plans (coming soon)
├── rules/       ← Tool-specific rules (coming soon)
├── skills/      ← Code templates & patterns (1 skill — CI/CD automation)
└── memory/      ← Project knowledge (coming soon)
```

## Current Contents

- `skills/ci-cd-and-automation.md` — CI/CD pipeline setup and automation patterns

## Isolation Rule

DevOps plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
