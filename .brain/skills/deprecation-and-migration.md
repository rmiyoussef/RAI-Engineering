# Deprecation and Migration

> **Source:** Adapted from addyosmani (deprecation-and-migration)
> **Domain:** Shared — Cross-Domain
> **Use when:** Removing old systems/APIs/features, migrating users between implementations, or deciding whether to maintain or sunset existing code.

---

## Overview

Code is a liability, not an asset. Every line carries ongoing maintenance costs. Deprecation removes code no longer worth keeping; migration moves users safely from old to new systems.

## Core Principles

**Code Is a Liability** — Every line incurs costs for tests, docs, patches, updates, and mental overhead. Value comes from functionality, not code itself.

**Hyrum's Law Makes Removal Hard** — With enough users, every observable behavior becomes depended on, including bugs and side effects. Deprecation requires active migration, not just announcements.

**Deprecation Planning Starts at Design Time** — Ask at design time how you'd remove it in three years. Clean interfaces, feature flags, and minimal surface area make deprecation easier.

## The Deprecation Decision

Five questions before deprecating:

1. Does it still provide unique value? (If yes, maintain it.)
2. How many consumers depend on it? (Quantify migration scope.)
3. Does a replacement exist? (Build it first if not.)
4. What's the migration cost per consumer? (Weigh against maintenance savings.)
5. What's the ongoing cost of **not** deprecating? (Security risk, engineer time, complexity.)

## Compulsory vs Advisory

| Type | When | Requirements |
|------|------|-------------|
| **Advisory** | Default approach | Warnings, docs, nudges |
| **Compulsory** | Security issues, progress blocks, unsustainable costs | Migration tooling, documentation, support, hard deadline |

## The Migration Process

### Step 1: Build the Replacement
Must cover all critical use cases, have migration guides, and be production-proven.

### Step 2: Announce and Document
Include: status, replacement references, removal date, rationale, migration guide with concrete steps.

### Step 3: Migrate Incrementally
One consumer at a time: identify touchpoints → update → verify → remove old references → confirm no regressions.

### Step 4: Remove the Old System
Only after verifying zero active usage. Remove code, tests, docs, config, and deprecation notices.

## Migration Patterns

| Pattern | How | Best For |
|---------|-----|----------|
| **Strangler Fig** | Run old and new in parallel, route traffic incrementally (canary → 50% → 100%) | Service/API replacement |
| **Adapter** | Adapter translates old interface to new implementation | API changes where consumers can't update immediately |
| **Feature Flag** | Flags switch individual consumers from old to new | Feature-level migration |

## Database Schema Migrations (Expand/Contract)

Never change a column in place. Three-phase process:

1. **Expand** — Add new nullable column alongside old
2. **Migrate** — Backfill rows, dual-write both columns
3. **Contract** — Drop old column in a separate deploy

| Rule | Why |
|------|-----|
| Adds go first; drops/renames get their own deploy | Old and new code run simultaneously |
| Every migration has a tested down path | Must be reversible |
| Backfill in batches off the hot path | Avoid production impact |
| Build large indexes without blocking writes | `CREATE INDEX CONCURRENTLY` |
| Decouple cutovers with feature flags | Separate deploy from release |

## Zombie Code

Code nobody owns but everyone depends on. Signs: no commits in 6+ months, no assigned owner, failing tests, unpatched vulnerabilities, outdated docs.

**Response:** Assign owner and maintain properly, or deprecate with a migration plan.

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "It still works" | Working but unmaintained code accumulates security debt |
| "Someone might need it later" | Rebuilding costs less than keeping unused code |
| "Migration is too expensive" | Compare against 2-3 years of ongoing maintenance |
| "We'll deprecate later" | Plan at design time, not after launch |
| "Users will migrate on their own" | They won't. Provide tooling or do it yourself. |

## Verification Checklist

- [ ] Replacement is production-proven
- [ ] Migration guide exists
- [ ] All consumers migrated (verified by metrics)
- [ ] Old code, docs, config, tests fully removed
- [ ] No remaining references to deprecated system
- [ ] Schema migration shipped in additive phases (expand → backfill → contract)
- [ ] Each migration step has a tested down path
- [ ] Destructive steps shipped in their own deploy after no code references old shape
