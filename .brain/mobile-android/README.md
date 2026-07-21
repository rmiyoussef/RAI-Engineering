# Mobile Android Domain

> Domain-isolated knowledge base for Android (Kotlin/Jetpack Compose) projects.
> Plans, rules, skills, and memory live in `.brain/mobile-android/{project-name}/`.

## Structure

```
mobile-android/{project-name}/
├── plans/       ← Project plans for this domain
├── rules/       ← Framework-specific rules (e.g. compose-rules.md)
├── skills/      ← Code templates for this domain
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

Android plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
