# Summary 2026-09-05-mandatory-vendor-neutral-os — Mandatory RAI OS: safe update.sh, thin entrypoints, model neutrality

**Objective:** Make RAI-Engineering the mandatory vendor-neutral engineering OS with a non-destructive versioned migration system.
**Status:** completed
**Date:** 2026-09-05

## What was implemented
- plans/ rename (was planning/); plan dirs gain TEST-PLAN.md (strategy file; TCs stay verdict truth).
- ARCHITECTURE.md §§12-14: data ownership (system vs user vs ephemeral), 7 migration principles, vendor-neutral AI integration diagram.
- INSTRUCTIONS.md: 10-step entry sequence, planning thresholds (required vs skippable), no-bypass rule + done-verification, implementation plan-first load.
- Thin entrypoints: CLAUDE.md 258→66 lines bootstrap; AGENTS.md RAI pointer (OpenCode entrypoint); CLAUDE.install.md model-neutral.
- Model neutrality: R9 rewritten, 16 agent headers, 3 protocols, CONSTRAINTS, sessions/README, config guide, README, docs.
- update.sh rewrite (~800 lines): state detection (fresh/current/upgrade/migrate-domains), RAI_BRAIN_VERSION=2, manifest conflict policy (.new), pre-migration tarball backups to .brain/.migration/, migrations.log, idempotent re-runs, legacy user-dir merges, tool detection (claude/opencode/codex), secure practices. setup.sh delegates all OS installation to update.sh.
- tests/test-update.sh: 53 assertions across 9 sections, all green.

## What changed (files/components)
- `.brain/`: planning/→plans/ (git mv), ARCHITECTURE.md, INSTRUCTIONS.md, constitution/RULES.md (R9), CONSTRAINTS.md, 16 agents, 3 protocols, sessions/README, context/PROJECT+ENVIRONMENT, state/version (new), state/migrations.log (new), plans/active/2026-09-05-mandatory-vendor-neutral-os, test-cases/..., templates/plan.
- Root: CLAUDE.md, CLAUDE.install.md, AGENTS.md, README.md, SKILLS.md (v1.8), docs/architecture.md, docs/config-guide.yaml, setup.sh, update.sh, tests/test-update.sh (new), .gitignore (.migration/), VERSION (v1.8.0).

## Important architectural decisions
- See plans/completed/2026-09-05-mandatory-vendor-neutral-os/DECISIONS.md (D1-D6): append-only history, TEST-PLAN vs TC split, manifest policy, update.sh ownership, R9 neutrality, uniform .ai policy.

## Tests executed + results
| TC | Result | Notes |
|---|---|---|
| TC-01 suite green | PASSED | 53/53, exit 0 |
| TC-02 fresh install | PASSED | version/manifest/log/mirror/symlink/gitignore |
| TC-03 domain upgrade | PASSED | data preserved, backup verified |
| TC-04 custom files safe | PASSED | hash-stable + .new |
| TC-05 idempotency | PASSED | stable, no spam |
| TC-06 merges + conflicts | PASSED | _imported, --check clean |
| TC-07 entrypoints neutral | PASSED | thin, no model lock |
| TC-08 plans mandatory | PASSED | thresholds, contract |

## Known limitations / remaining issues
- skills/ repo-level mirrors still legacy snapshots (prior debt, unchanged).
- Universal skills keep upstream `Domain: Shared — Cross-Domain` headers (means cross-area, not directories).
- Remote (curl) path of update.sh untested here (no network assertion); --local covers logic identically modulo transport.

## Performance / security considerations
- update.sh: read-only network, no project-file execution, no secret logging/touching, quoted paths, set -euo pipefail; 3 set -e hazards found by tests and fixed.
- Boot stays token-light: CLAUDE.md 66 lines + progressive disclosure.

## Lessons learned
- Fixture-generated migration tests catch live bugs fast (3 fixes from 53 tests: gitignore return code, late-legacy gap, misleading conflict message).
- `set -e` + trailing `&&` lists + `ls -A` emptiness checks are the top bash hazards; file-based checks + explicit returns required.

## Future recommendations
- CI: run tests/test-update.sh on every change to update.sh/setup.sh.
- Next plan: reconcile repo-level skills/ mirrors with .brain/skills/.
