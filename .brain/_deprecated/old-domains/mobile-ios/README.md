# Mobile iOS Domain

> Domain-isolated knowledge base for iOS (Swift/SwiftUI/UIKit) projects.
> Plans, rules, skills, and memory live directly in `.brain/mobile-ios/` — no nesting.

## Structure

```
mobile-ios/
├── plans/       ← Project plans (coming soon)
├── rules/       ← Framework-specific rules (e.g. swiftui-rules.md)
├── skills/      ← Code templates (coming soon)
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

iOS plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
