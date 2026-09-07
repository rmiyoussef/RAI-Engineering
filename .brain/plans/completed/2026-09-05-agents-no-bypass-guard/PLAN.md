# 2026-09-05-agents-no-bypass-guard — AGENTS.md rewrite with no-bypass guard

**Objective:** Canonical AGENTS.md teaches the no-parallel-system rule up front.
**Status:** completed
**Owner:** opencode agent
**Created:** 2026-09-05

## Problem
Opencode reads AGENTS.md only, ignores CLAUDE.md. Canonical adapter held caveman style + one brain pointer. The no-parallel-system prohibition surfaced only after reading INSTRUCTIONS.md. CLAUDE.md identity/index/routing/rules already cover sessions that read it; duplicating them into AGENTS.md costs tokens and divergence risk.

## Scope / Non-goals
- In scope: one guard line in repo AGENTS.md + setup.sh template, tests/test-update.sh §12, v1.8.3 sync.
- Non-goals: identity/index/routing/rules duplication (stays in .brain/), update.sh repair-path change (stays single pointer line).

## Requirements
- [x] R1 Guard line present in repo AGENTS.md and setup.sh template
- [x] R2 Fresh setup installs carry the guard
- [x] R3 Suite green

## Relevant context
- AGENTS.md, CLAUDE.md (assessed, not duplicated), setup.sh template, ARCHITECTURE.md §14 (thin parallel adapters)

## Affected areas
- AGENTS.md, setup.sh, tests/test-update.sh, version files, README.md (domains: [all])

## Technical approach
Single line after bootstrap: no parallel planning/memory/testing system, canonical dirs listed. Test §12 asserts pointer + guard in repo file, guard in setup.sh template, guard in fresh-install output.

## Architecture considerations
Thin-adapter principle kept. One high-leverage guard duplicated by value, everything else by reference via brain pointer.

## Dependencies
None.

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| Template drift repo vs setup.sh | low | §12 asserts both; pre-existing caveman wording drift noted, untouched |

## Tasks
See TASKS.md. Covering TC: TC-01.

## Required test cases
See test-cases/completed/2026-09-05-agents-no-bypass-guard/INDEX.md.

## Completion requirements
INSTRUCTIONS.md §8 contract.
