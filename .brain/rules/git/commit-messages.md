---
domains: [backend]
---

# Commit Message Rules

> **Merged v2.0** — Original 8 rules + trunk-based development, worktrees, save-point pattern, pre-commit hygiene, changelogs, semantic versioning.
> **Loaded by:** EXECUTOR agent, GITHUB agent, GITHUB TASKS agent, REVIEWER agent.

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

## R9 — Pre-Commit Hygiene

Before every commit, verify:

- [ ] `git diff` reviewed — no debug code, no `dd()`/`dump()`/`console.log()`
- [ ] No secrets, tokens, or credentials in the diff
- [ ] Tests pass (run the relevant test, not the full suite without approval)
- [ ] Linting passes (or fix warnings if they exist)
- [ ] No hardcoded URLs, IPs, or environment-specific values

## R10 — Trunk-Based Development

Keep `main` always deployable. Work in short-lived feature branches that merge back within 1-3 days.

Branch naming:
```
feature/description     — new features
fix/description         — bug fixes
chore/description       — maintenance, deps, config
refactor/description    — code restructuring (no behavior change)
```

## R11 — Git Worktrees for Parallel Work

When running multiple AI agents on the same repo, use git worktrees to avoid conflicts:

```bash
git worktree add ../project-feature-x feature/x
```

Each worktree is an independent working directory with its own branch. Agents don't interfere.

## R12 — The Save-Point Pattern

For experimental or risky changes, commit early and often:

```
1. Make a small change
2. Test
3. Commit (or revert if broken)
4. Repeat
```

This gives you safe rollback points and clean diffs. Don't accumulate 100+ lines of uncommitted changes.

## R13 — Changelog Maintenance

Keep a human-readable changelog, written at change time (not retroactively):

```
# Changelog

## [1.2.0] - 2026-07-15
### Added
- Bulk order export (closes #456)
- Password reset flow

### Fixed
- Null pointer in profile endpoint (fixes #123)

## [1.1.0] - 2026-06-30
...
```

Format: **Keep a Changelog** (https://keepachangelog.com). Categorize: Added, Fixed, Changed, Deprecated, Removed, Security.

## R14 — Semantic Versioning

| Version | When | Example |
|---------|------|---------|
| MAJOR | Breaking API/behavior changes | 2.0.0 |
| MINOR | New features, backward-compatible | 1.2.0 |
| PATCH | Bug fixes, backward-compatible | 1.1.3 |

Tag releases: `git tag v1.2.0 && git push origin v1.2.0`
