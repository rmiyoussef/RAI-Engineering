# PLAN-0006 — Refactor .brain into Central Engineering Brain

**Objective:** Replace domain-first `.brain/` layout with purpose-organized central brain.
**Status:** active
**Owner:** opencode agent
**Created:** 2026-09-05

## Problem
Domain-first layout (backend/frontend/devops/mobile-*) forces single-domain filing for multi-area work. No first-class test cases, no completion contract, no machine-readable state.

## Scope / Non-goals
- In scope: new tree, ARCHITECTURE.md, INSTRUCTIONS.md, INDEX.md, migration with history, agent behavior updates, repo reference updates, validation.
- Non-goals: changing agent roster, rules content (R1-R45 untouched), CI changes.

## Requirements
- [ ] R1 Purpose-organized tree exists, domain dirs gone
- [ ] R2 ARCHITECTURE.md + INSTRUCTIONS.md authoritative and consistent
- [ ] R3 Every useful file migrated/merged/deprecated with reason (zero deletions)
- [ ] R4 Agents operate on new layout (paths + behavior)
- [ ] R5 Repo references updated (boot, docs, installers, scripts)
- [ ] R6 Validation executed and recorded

## Relevant context
- context/PROJECT.md, context/ARCHITECTURE.md
- memory/decisions/brain-migration.md (prior art), _deprecated/DOMAINS_MIGRATION.md

## Affected areas
- `.brain/` full tree (domains: [all]); CLAUDE.md, CLAUDE.install.md, README.md, SKILLS.md, setup.sh, update.sh, docs/architecture.md, .ai/memory-timeline.py, .ai/skills-diff.sh, workflows/STANDARD.md, .gitignore, VERSION

## Technical approach
git mv (history preserved) + `domains:` frontmatter tags + new authority files + sed/python path patches + installer migration code.

## Architecture considerations
Per proposed §3 structure, adapted: kept sessions/session-bus, added _deprecated/, connections → context/connections/.

## Dependencies
None (self-contained repo refactor).

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| Data loss during moves | low | git mv only; zero-D validation (TC-0003) |
| Stale references missed | medium | repo-wide grep TC + allowlist migration code |

## Tasks
See TASKS.md. Covering TCs: TC-0001..TC-0006.

## Required test cases
See test-cases/active/PLAN-0006/INDEX.md.

## Completion requirements
INSTRUCTIONS.md §8 contract. This plan self-demonstrates the lifecycle.
