# Decision: Recover loose plans/ files to completed every run (v1.9.1)

**Date:** 2026-09-07
**Domains:** all
**Context:** bench held 6 loose plan files invisible to lifecycle tooling. Backup tar self-inclusion aborted its migration mid-run.

## Decision
**Chosen:** recover_loose_plans() every run (completed, STATUS notes provenance). Backup excludes .brain/.migration.
**Rationale:** loose files are finished work by convention; completed is the requested home. State pointer appended so they stay discoverable.

## Consequences
- plans/*.md never lingers past one update run.
- Backup deterministic on brains of any size.
