# Documentation and ADRs

> **Source:** Adapted from addyosmani (documentation-and-adrs)
> **Domain:** Shared — Cross-Domain
> **Use when:** Making architectural decisions, changing public APIs, shipping features, onboarding new team members.

---

## When to Document

| Document | Don't Document |
|----------|----------------|
| Architectural decisions | Obvious code (well-named methods don't need comments) |
| Public API changes | Redundant comments that restate the code |
| Feature shipping | Throwaway prototypes |
| Repeated onboarding questions | |
| Gotchas and pitfalls | |

## Architecture Decision Records (ADRs)

ADRs capture the **reasoning** behind technical decisions, not just the decision itself.

### When to Write an ADR

Write an ADR when ALL three conditions are met:
1. The decision is **hard to reverse**
2. The decision would be **surprising** without context to a future reader
3. The decision is the **result of a real trade-off**

### ADR Template

```markdown
# ADR-NNN: [Title]

**Status:** Proposed → Accepted → Superseded/Deprecated
**Date:** YYYY-MM-DD

## Context
What's the problem? What constraints exist? What options were considered?

## Decision
What did we decide? Why this option over others?

## Alternatives Considered
| Option | Pros | Cons |
|--------|------|------|
| Option A | ... | ... |
| Option B | ... | ... |

## Consequences
What becomes easier? What becomes harder? What does this enable?
```

### ADR Lifecycle

```
PROPOSED ──► ACCEPTED ──► SUPERSEDED (by new ADR)
                  │
                  └──► DEPRECATED (no longer relevant)
```

ADRs are **never deleted**. They capture historical context even when superseded.

### Storage

Store in `docs/decisions/` with sequential numbering: `docs/decisions/0001-use-postgresql.md`.

## Inline Documentation

| Good | Bad |
|------|-----|
| "Rate limit uses a sliding window — reset counter at boundary" | "Increment counter" (obvious from code) |
| Document WHY, not WHAT | "This function adds two numbers" (obvious) |
| Document known gotchas with warnings | TODO comments for things you should do now |
| Clear error messages with context | Commented-out code ("Delete it, git has history") |

## API Documentation

For public APIs:
- TypeScript: Use inline JSDoc/TSDoc with `@param`, `@returns`, `@throws`, `@example`
- REST: Use OpenAPI/Swagger schemas

## README Structure

Every project needs: project description, quick start steps, commands table, architecture overview (linking to ADRs), contributing guidelines.

## Changelog

Keep a changelog written at change time (not retroactively):
- Version numbers + dates
- Categorized entries: Added, Fixed, Changed, Deprecated, Removed, Security
- Reference issue/PR numbers
- Follow Keep a Changelog format

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "The code is self-documenting" | Code doesn't show WHY |
| "Nobody reads docs" | Agents do. Future engineers do. |
| "ADRs are overhead" | They prevent re-debating the same decisions. |

## Verification Checklist

- [ ] ADRs exist for all architectural decisions
- [ ] README has quick start and architecture overview
- [ ] Public APIs have documentation
- [ ] Known gotchas documented
- [ ] No commented-out code in source files
- [ ] Rules files are current
