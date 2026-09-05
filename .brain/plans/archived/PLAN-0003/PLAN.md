# Plan: Flatten Domain Structure — Remove `{project-name}` Nesting

> **Date:** 2026-07-23
> **Domain:** Backend (RAI-Engineering core)
> **Model Lock:** deepseek-v4-flash

---

## 1. GOAL

Remove the unnecessary `{project-name}` layer from `.brain/{domain}/{project-name}/` so the structure becomes `.brain/{domain}/` directly.

**Before:**
```
.brain/backend/rai-engineering/memory/guidelines.md
.brain/backend/rai-engineering/rules/orchestration-rules.md
.brain/frontend/rai-engineering/skills/design-engineering.md
```

**After:**
```
.brain/backend/memory/guidelines.md
.brain/backend/rules/orchestration-rules.md
.brain/frontend/skills/design-engineering.md
```

## 2. WHY

- The AI agent knows which project it's working on (stored in session/memory) — no need to encode it in the path
- Users installing RAI-Engineering don't need to create a folder with their project name inside the domain
- Shorter paths, cleaner structure, less visual noise
- All existing files have the same content — just moved up one level

## 3. FILES TO MOVE

### Backend domain (using `mv` commands)
| Current Path | Target Path |
|---|---|
| `.brain/backend/rai-engineering/memory/` | `.brain/backend/memory/` |
| `.brain/backend/rai-engineering/rules/` | `.brain/backend/rules/` |
| `.brain/backend/rai-engineering/skills/` | `.brain/backend/skills/` |
| `.brain/backend/rai-engineering/plans/` | `.brain/backend/plans/` |
| `.brain/backend/rai-engineering/connections/` | `.brain/backend/connections/` |

### Frontend domain
| Current Path | Target Path |
|---|---|
| `.brain/frontend/rai-engineering/skills/` | `.brain/frontend/skills/` |

### DevOps domain
| Current Path | Target Path |
|---|---|
| `.brain/devops/rai-engineering/skills/` | `.brain/devops/skills/` |

## 4. FILES TO UPDATE

| File | What to Update |
|---|---|
| `.brain/INDEX.md` | All paths — remove `rai-engineering/` from every reference. Rework the diagram. |
| `.brain/backend/memory/guidelines.md` | Remove its own self-referencing `rai-engineering` path |
| `.brain/backend/rules/project-rules.md` | Remove its own self-referencing `rai-engineering` path (line 3) |
| `.brain/backend/memory/decisions/2026-07-23-orchestration-engine.md` | Self-referencing paths |
| `.brain/backend/plans/2026-07-21-domain-isolation-protocol.md` | All paths refer to the OLD structure (still has `rai-engineering/`) — but this is a historical plan, keep as-is |
| `.brain/backend/plans/2026-07-23-orchestration-parallel-execution.md` | All paths refer to the OLD structure — keep as-is, it's the plan document |
| `.gitignore` | Change `*.brain/backend/*/connections/` → `.brain/backend/connections/` |
| `CLAUDE.md` | Update memory section diagrams and git safety patterns |

## 5. EXECUTION STEPS

1. `mv .brain/backend/rai-engineering/* .brain/backend/` (move all subdirectories up)
2. `rmdir .brain/backend/rai-engineering/` (remove empty shell)
3. `mv .brain/frontend/rai-engineering/skills/ .brain/frontend/skills/`
4. `rmdir .brain/frontend/rai-engineering/`
5. `mv .brain/devops/rai-engineering/skills/ .brain/devops/skills/`
6. `rmdir .brain/devops/rai-engineering/`
7. Update `.brain/INDEX.md`
8. Update `.brain/backend/memory/guidelines.md`
9. Update `.brain/backend/rules/project-rules.md`
10. Update `.brain/backend/memory/decisions/2026-07-23-orchestration-engine.md`
11. Update `.gitignore`
12. Update `CLAUDE.md` (memory section, git safety patterns)
13. Verify no references remain anywhere

## 6. RISKS

| Risk | Mitigation |
|---|---|
| Broken symlinks or path references | Grep for `rai-engineering` across entire repo — fix every match |
| Old plans reference paths that no longer exist | Historical plan docs are exempt — they document what was, not what is |
| Git history shows "deleted then recreated" | Move preserves git history (`mv` keeps inodes) |
