# 2026-09-21 — Per-feature docs/ folder with mandatory-read rule

**Status:** accepted
**Context:** Feature knowledge scattered across plans/memory with no living per-feature home.
**Decision:** `.brain/docs/<feature>.md` (one file per feature) is user-owned and mandatory reading before feature work; `docs/README.md` + `docs/_TEMPLATE.md` + `skills/writing-docs.md` are system-managed; updater installs scaffolds and never touches user feature files; brain version stays v3 (additive change via ensure_tree).
**Consequences:** Agents gain one authoritative per-feature reference; EXECUTOR must update the file in the same change as behavior; future feature-doc requests land in docs/ instead of ad-hoc locations.
