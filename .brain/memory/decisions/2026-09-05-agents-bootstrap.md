# Decision: Enforce AGENTS.md brain bootstrap on install/update (non-destructive prepend)

**Date:** 2026-09-05
**Domains:** all
**Context:** Pre-existing custom AGENTS.md without .brain survived installs forever. Opencode ignores CLAUDE.md when AGENTS.md exists. Brain bypassed.

## Options Considered
- Overwrite AGENTS.md from template (rejected: destroys user caveman rules)
- Chain AGENTS.md through CLAUDE.md (rejected: extra hop, token waste, violates ARCHITECTURE §14 parallel adapters)
- Marker-enforced prepend (chosen)

## Decision
**Chosen:** grep marker `.brain/INSTRUCTIONS.md`. Absent triggers prepend of canonical bootstrap line. Missing file falls back local copy, fetched, minimal bootstrap. setup.sh mirrors repair.
**Rationale:** user-owned merge never replace. Single marker idempotent.

## Consequences
- Every update.sh run heals broken AGENTS.md, preserves custom content, logs agents-bootstrap.
- Bench/backend heals on next update.sh run.
