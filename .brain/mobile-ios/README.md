# Mobile iOS Domain

> Domain-isolated knowledge base for iOS (Swift/SwiftUI/UIKit) projects.
> Plans, rules, skills, and memory live in `.brain/mobile-ios/{project-name}/`.

## Structure

```
mobile-ios/{project-name}/
├── plans/       ← Project plans for this domain
├── rules/       ← Framework-specific rules (e.g. swiftui-rules.md)
├── skills/      ← Code templates for this domain
└── memory/      ← Project knowledge (guidelines, decisions, lessons, etc.)
```

## Isolation Rule

iOS plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
