# Commit Message Rules

> Conventional commit format. Every project should adopt these rules for consistent, readable history.

---

## R1 — Format

Every commit message must follow this structure:

```
type(scope): short description

Longer explanation if needed. Wrap at 72 characters.

- Bullet points for context
- Reference issues: #123
```

## R2 — Types

| Type | When to Use |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `refactor` | Code change with no behavior change |
| `docs` | Documentation only |
| `test` | Adding or fixing tests |
| `chore` | Maintenance, deps, config, tooling |
| `perf` | Performance improvement |
| `style` | Formatting, linting, whitespace (no logic change) |
| `ci` | CI/CD configuration or scripts |
| `revert` | Reverts a previous commit |

## R3 — Scope

The scope is the module or area affected. Be specific:

```
feat(auth): add password reset flow
fix(api): handle null user in profile endpoint
refactor(controllers): extract validation to form requests
```

Use the directory or component name as scope. If unsure, omit.

## R4 — Body Rules

- Separate body from subject with a blank line
- Wrap at 72 characters
- Explain **what** and **why**, not **how** (the diff shows how)
- Use bullet points for multiple points

```
feat(orders): add bulk order export

Export allows admins to download all orders as CSV.
Useful for accounting and external reporting.

- Adds ExportOrders action
- Streams response to avoid memory issues with large datasets
- Closes #456
```

## R5 — Breaking Changes

Append `!` after the type and note in the body:

```
feat!(api): change order status endpoint response

BREAKING CHANGE: Order status now returns an object instead of a string.
Migrate from `response.status` to `response.data.status`.
```

## R6 — Referencing Issues

| Prefix | Meaning |
|--------|---------|
| `Closes #123` | This commit fixes the issue |
| `Fixes #123` | This commit fixes the issue |
| `Refs #123` | This commit relates to the issue |
| `See also: #123` | Related but separate |

## R7 — What NOT to Commit

```
❌ fix: fixed stuff
❌ Update file.php
❌ WIP
❌ asdf
❌ Merge branch 'main' into feature/xxx
❌ Fixing things Frank broke
```

## R8 — One Concern Per Commit

- Don't mix refactoring with feature work
- Don't fix two unrelated bugs in one commit
- Don't include formatting changes with logic changes

If you need to do multiple things, make multiple commits:

```
1. refactor(users): extract validation to form request
2. feat(users): add profile photo upload
```
