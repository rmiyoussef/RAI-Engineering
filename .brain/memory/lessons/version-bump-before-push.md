---
name: version-bump-before-push
description: VERSION must be bumped and synced across all files before every push
metadata:
  type: rule
---

# Rule: Version Bump Before Every Push

**Every push MUST bump the version.** No exceptions.

## Sync Checklist

Before `git push`, update ALL of these:

| File | What to Update |
|------|----------------|
| `VERSION` | `vX.Y — Description` |
| `CLAUDE.md` header | `> **Version:** vX.Y — Description` |
| `CLAUDE.md` bottom | `AI Engineering OS vX.Y — Description` + rules/agents count |
| `README.md` roadmap | Add completed version row + shift planned versions |
| `README.md` footer | `<small>AI Engineering OS — vX.Y</small>` |
| `setup.sh` | Version string in installer output (if displayed) |
| `update.sh` | Version string in updater output (if displayed) |

## Why

Multiple files display the version. If they diverge, users and the update script see stale versions and think nothing changed. Every push is a new version — even small fixes.

## How to Bump

- **Minor fix/doc** → bump patch/minor: `v0.7` → `v0.8`
- **New feature** → bump minor: `v0.7` → `v0.8`
- **Breaking change** → bump major: `v0.x` → `v1.0`

Use semver-ish scheme: `v{Major}.{Minor}` with a short description.
