# 2026-09-05-mandatory-vendor-neutral-os — Mandatory RAI OS: safe update.sh, thin entrypoints, model neutrality

**Objective:** Make RAI-Engineering the mandatory vendor-neutral engineering OS with a non-destructive versioned migration system.
**Status:** active
**Owner:** opencode agent
**Created:** 2026-09-05

## Problem
update.sh replaced flattened structures destructively with no versioning, no backup, no conflict policy. Entry files duplicated brain instructions per vendor. A hard-coded model assumption violated vendor neutrality. Planning directory was `planning/` instead of conventional `plans/`.

## Scope / Non-goals
- In scope: plans/ rename + TEST-PLAN.md; ARCHITECTURE §§12-14; INSTRUCTIONS §§1,3,4,11; thin CLAUDE.md/AGENTS.md; R9 neutrality; update.sh rewrite; setup.sh delegation; tests/test-update.sh; validation §36.
- Non-goals: agent roster changes, R1-R45 semantics beyond R9/R16-R20/R36-R40 paths, CI wiring.

## Requirements
- [ ] R1 plans/ primary with TEST-PLAN.md
- [ ] R2 Ownership/migration/AI-integration in ARCHITECTURE.md
- [ ] R3 Entry sequence, thresholds, no-bypass in INSTRUCTIONS.md
- [ ] R4 Thin entrypoints; no model hard-coding
- [ ] R5 update.sh: versioned, manifest conflicts, backup, log, idempotent, tool detection, secure
- [ ] R6 53-test suite green; temp-project fresh/upgrade/repeat verified; stale sweep clean

## Relevant context
- context/PROJECT.md, ARCHITECTURE.md §§12-14, INSTRUCTIONS.md, plans/completed/2026-09-05-central-engineering-brain/ (prior refactor pattern)

## Affected areas
- `.brain/` (plans rename, ARCHITECTURE, INSTRUCTIONS, RULES R9, agents, state/version), CLAUDE.md, CLAUDE.install.md, AGENTS.md, README.md, SKILLS.md, docs/, setup.sh, update.sh, tests/, .gitignore, VERSION (domains: [all])

## Technical approach
Mechanical rename (history: 2026-09-05-central-engineering-brain records kept append-only); authority-file sections; entrypoint thinning; update.sh fresh rewrite reusing proven v1→v2 map with merge-safe primitives; fixture-generated test suite in temp dirs.

## Architecture considerations
Data safety > clean look: merge-only migration, .new conflicts, backups, logs. Entry files thin per §31. Model neutrality per §33.

## Dependencies
None.

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| update.sh destroys user data | low | merge-only primitives, backup, 53-test suite incl. conflict cases |
| set -e pitfalls in bash | medium | found + fixed 3 live (gitignore return, &&-lists audited) |
| Thin CLAUDE.md loses behavior | low | all behavior lives in .brain; entry points at it |

## Tasks
See TASKS.md. Covering TCs: TC-01..TC-08.

## Required test cases
See test-cases/active/2026-09-05-mandatory-vendor-neutral-os/INDEX.md.

## Completion requirements
INSTRUCTIONS.md §8 contract.
