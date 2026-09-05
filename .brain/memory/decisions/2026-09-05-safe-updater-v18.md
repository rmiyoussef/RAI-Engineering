# Decision: Non-destructive versioned updater + mandatory RAI workflow (v1.8)

**Date:** 2026-09-05
**Domains:** all
**Context:** update.sh replaced structures destructively with no versioning; entry files duplicated instructions per vendor; model assumption hard-coded; planning dir misnamed.

## Options Considered
- Patch old update.sh incrementally (rejected: migration logic needed merge-safe rewrite anyway)
- Symlink/shim old domain paths (rejected: perpetuates dual truth; update.sh carries forward migration instead)
- Per-vendor instruction duplicates (rejected: thin bootstraps pointing at .brain)

## Decision
**Chosen:** fresh update.sh with version dispatch + manifest conflicts + backups + log; thin CLAUDE.md/AGENTS.md; R9 model neutrality; plans/ primary.
**Rationale:** data safety > clean look; vendor independence; automation.

## Consequences
- Consumers upgrade via ./update.sh with backup + .new conflicts + log.
- Brain version 2 stamped in state/version; future migrations incremental.
- 53-test suite guards update.sh/setup.sh changes (run in CI).
