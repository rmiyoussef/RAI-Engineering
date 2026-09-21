# Summary 2026-09-21-brain-docs

**Objective:** Per-feature `.brain/docs/` + writing-docs skill + mandatory-read wiring + updater support.
**Result:** completed 2026-09-21. Suite 87/87, TC-01 + TC-02 PASSED.

## Changes
- New: `docs/README.md` (rules, naming, lifecycle), `docs/_TEMPLATE.md` (8-section feature anatomy), `skills/writing-docs.md` (triggers, create/update/read decision, gather-write-organize workflow, anti-patterns, checklist).
- Wiring: ARCHITECTURE.md (§2 table, §3 relation, §4 flow, §10 retrieval, §11 staleness, §12 ownership split); INSTRUCTIONS.md (§1 boot step [8] mandatory docs load, §2/§4/§7/§9/§11); INDEX.md (feature-docs section, skills 39→40); README.md (tree + agent step); templates/GUIDELINES.md (Feature Docs section + Important Notes bullet); reference/message-protocol.md ([8] docs load).
- update.sh: SYSTEM_FILES += skill + docs scaffolds; AI_FILES += WRITING_DOCS.md mirror; ensure_tree creates docs/. Version stays v3 (additive).
- tests/test-update.sh: block 1 (+4 asserts) + new block 15 (user doc preservation, +4 asserts).

## Decisions
- docs/<feature>.md user-owned, scaffolds system-managed (see plan DECISIONS.md D1–D4).

## Files affected
`.brain/docs/`, `.brain/skills/writing-docs.md`, `.brain/{ARCHITECTURE,INSTRUCTIONS,INDEX,README}.md`, `.brain/templates/GUIDELINES.md`, `.brain/reference/message-protocol.md`, `update.sh`, `tests/test-update.sh`.

## Tests
- TC-01 PASSED (isolated fixture: install + 2 re-runs, user file stable, version 3).
- TC-02 PASSED (static wiring verification).
- Full suite: 87/87.

## Limitations
- No feature docs written yet (onboarding.md created on demand).
- Updater not run in repo root (suite fixtures cover it; avoids .ai mirror noise in source tree).

## Lessons
- Additive brain-OS changes ride ensure_tree without version bumps; keeps version asserts green.
