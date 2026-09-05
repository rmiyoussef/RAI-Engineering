# Skill Library Import — 6 External Repos

> **Date:** 2026-07-23
> **Domain:** Backend (core rules merged) + Frontend (new) + DevOps (new) + Shared (new)
> **Sources:** mattpocock/skills, anthropics/skills, addyosmani/agent-skills, obra/superpowers, emilkowalski/skills, nextlevelbuilder/ui-ux-pro-max-skill

---

## Summary

Imported and adapted knowledge patterns from 6 external GitHub skill repositories into RAI-Engineering's domain-isolated skill/rules structure.

## What Was Added

### 🆕 34 New Skill Files

| Location | Count | Sources |
|----------|-------|---------|
| `.brain/shared/skills/` | 27 | addyosmani, mattpocock, obra |
| `.brain/frontend/skills/` | 6 | addyosmani, anthropics, emilkowalski |
| `.brain/devops/skills/` | 1 | addyosmani |

### 🔄 4 Rule Files Merged & Upgraded

| File | Additions |
|------|-----------|
| `SECURITY.md` (250 lines) | +STRIDE threat modeling, OWASP LLM Top 10, SSRF with DNS rebinding, dependency audit triage, secrets management protocol |
| `API_DESIGN.md` (258 lines) | +Hyrum's Law, contract-first design, TypeScript interface patterns (discriminated unions, branded types, I/O separation) |
| `COMMIT_MESSAGES.md` (184 lines) | +Trunk-based development, git worktrees, save-point pattern, pre-commit hygiene, changelogs, semantic versioning |
| `GIT_SAFETY.md` (101 lines) | +Generated files handling, `.gitignore` discipline, expanded sensitive file detection |

### ❌ What Was Skipped

| Reason | Examples |
|--------|----------|
| Requires external packages | emilkowalski/improve-animations (CLI tool), nextlevelbuilder/ui-ux-pro-max (python search script) |
| Agent-specific config, not knowledge | nextlevelbuilder `CLAUDE.md` (project-specific setup) |
| Deprecated | mattpocock/skills `deprecated/` directory |
| Personal/misc with no team value | mattpocock `personal/`, `productivity/`, `ask-matt` |
| Already covered by existing rules | anthropics/skills `claude-api`, `mcp-builder`, `skill-creator` (tool-specific, not general skills) |

## Files Changed

- **4** rules files modified (merges)
- **34** new skill files created
- **1** INDEX.md updated
- **0** existing skills/rules deleted or overwritten (merges were additive)

## Verification

- [x] All new skills classified by domain into correct subtree
- [x] No conflicts between new skills and existing agent definitions
- [x] No conflicts between new skills in the same domain
- [x] Merged rules are supersets of originals (all original rules preserved)
- [x] Core orchestrator behavior (domain intake, folder isolation, skill-triggering) untouched
- [x] INDEX.md updated with full skills library table
