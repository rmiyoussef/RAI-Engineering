# Mobile Android Domain

> Domain-isolated knowledge base for Android (Kotlin/Jetpack Compose) projects.
> Plans, rules, skills, and memory live directly in `.brain/mobile-android/` — no nesting.

## Structure

```
mobile-android/
├── plans/       ← Project plans (coming soon)
├── rules/       ← Framework-specific rules (e.g. compose-rules.md)
├── skills/      ← Code templates (coming soon)
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

Android plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
