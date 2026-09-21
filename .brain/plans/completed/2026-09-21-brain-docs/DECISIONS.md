# Decisions 2026-09-21-brain-docs

- D1 docs/<feature>.md user-owned (never overwritten); docs/README.md + docs/_TEMPLATE.md system-managed scaffolds. Reason: updater conflict policy needs the split.
- D2 No version bump (stays v3). Reason: additive change, ensure_tree covers all updater paths, avoids breaking version asserts.
- D3 No pre-created onboarding.md. Reason: no invented content; feature docs created on demand via skill.
- D4 Skill mirrors to .ai/skills/WRITING_DOCS.md. Reason: consistent with other process skills.
