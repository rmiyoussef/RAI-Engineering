# Decision: AGENTS.md carries one guard line, rest by reference (v1.8.3)

**Date:** 2026-09-05
**Domains:** all
**Context:** CLAUDE.md full text assessed for portable content into AGENTS.md. Opencode reads AGENTS.md only.

## Options Considered
- Duplicate identity/index/routing/rules into AGENTS.md (rejected: token cost, divergence risk, violates thin-adapter §14)
- Pointer only, no guard (rejected: no-bypass rule surfaces too late)
- Pointer + one guard line (chosen)

## Decision
**Chosen:** guard line added to canonical template. Repair prepend unchanged.
**Rationale:** highest-leverage rule up front, everything else by reference.

## Consequences
- Fresh installs and missing-file copies teach the guard immediately.
- One-line duplication to maintain across repo file + setup.sh template; §12 guards both.
