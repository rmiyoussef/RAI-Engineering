# 2026-09-21-brain-docs — Per-feature docs/ folder + writing-docs skill

**Objective:** Add user-owned `.brain/docs/` (one file per feature, e.g. `onboarding.md`), a `writing-docs` skill governing it, mandatory-read wiring across the brain OS, and updater support.
**Status:** active
**Owner:** opencode agent
**Created:** 2026-09-21

## Problem
Feature knowledge scatters across plans/memory/knowledge with no living per-feature home. New work on an existing feature re-derives context instead of reading one organized doc.

## Scope / Non-goals
- In scope: `docs/` + `docs/README.md` + `docs/_TEMPLATE.md` scaffolds, `skills/writing-docs.md`, mandatory-read wiring (ARCHITECTURE, INSTRUCTIONS, INDEX, README, templates/GUIDELINES), `update.sh` support (SYSTEM_FILES, AI_FILES, ensure_tree), test-suite coverage.
- Non-goals: writing actual feature docs (e.g. onboarding.md content) — created on demand later; version bump (additive v3 change, no migration needed).

## Requirements
- [ ] R1 `docs/<feature>.md` created/updated on request, organized per template, never duplicated
- [ ] R2 Agents must read relevant `docs/` file before any feature work
- [ ] R3 Updater installs/preserves `docs/` on fresh + existing brains, idempotent, user feature files never overwritten
- [ ] R4 Test suite green including new docs asserts

## Tasks
See TASKS.md. Covering TC: TC-01, TC-02.

## Completion requirements
INSTRUCTIONS.md §8 contract.
