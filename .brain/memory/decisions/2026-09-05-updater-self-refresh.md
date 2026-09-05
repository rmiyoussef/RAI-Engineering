# Decision: Updater self-refresh for installed copies (v1.8.2)

**Date:** 2026-09-05
**Domains:** all
**Context:** .ai/update.sh copies in consumer projects never refreshed. PLAN-0008 fix sat on master while installs ran stale updaters showing no change.

## Options Considered
- Track .ai/update.sh in manifest (rejected: manifest compares installed tree files; the runner overwriting itself mid-run via generic path risks cwd writes)
- Manual re-fetch instructions (rejected: forgotten, exactly the reported bug)
- Dedicated refresh_self() with guards (chosen)

## Decision
**Chosen:** refresh_self() after dispatch. Guard parent .ai or --local. cmp no-op, single .bak, warn-only fetch failures.
**Rationale:** runner is RAI-owned. Propagation must be automatic.

## Consequences
- Every consumer run self-heals the updater first. Future logic fixes land without manual steps.
- Brain version unchanged (2). Product version v1.8.2 signals the change.
