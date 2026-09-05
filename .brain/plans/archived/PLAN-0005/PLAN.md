# Plan: Update setup.sh, update.sh, and CLAUDE.install.md

> **Date:** 2026-07-23
> **Domain:** Backend (RAI-Engineering core)
> **Model Lock:** deepseek-v4-flash

---

## 1. GOAL

Make `setup.sh` install the new flat structure and all v1.4+ features. Make `update.sh` detect old nested `.brain/backend/{project-name}/` structure and auto-migrate it. Regenerate `CLAUDE.install.md` for installed projects.

## 2. CHANGES BY FILE

### 2.1 `setup.sh` — For new installations

**Structural changes:**
- Create flat `.brain/backend/` (not `.brain/backend/{project}/`)
- Remove `PROJECT_NAME` variable (no longer needed in paths)
- Create domain subdirs: `memory/`, `rules/`, `skills/`, `plans/`, `connections/` directly under `.brain/{domain}/`

**Content changes:**
- Install ORCHESTRATOR ENGINE agent: `agents/ORCHESTRATOR_ENGINE.md`
- Install ORCHESTRATION protocol: `brain/ORCHESTRATION.md`
- Install orchestration rules: `rules/orchestration-rules.md` → correct domain folder
- Install `workflows/STANDARD.md` if it exists (currently listed but not included)
- Update `.gitignore` to flat patterns: `.brain/backend/connections/` not `.brain/*/*/connections/`

**Display:**
- Show flat structure tree (no `{project-name}/` nesting)
- Version: v1.4+

### 2.2 `update.sh` — For existing installations

**Add migration logic (key new feature):**
- Detect old nested structure: `[ -d ".brain/backend/$(basename $(pwd) | tr '[:upper:]' '[:lower:]')" ]`
- If found, ask user: "Found old nested .brain/ structure. Auto-migrate to flat format? (y/N)"
- If yes, run the flatten migration: move `memory/`, `rules/`, `skills/`, `plans/`, `connections/` up one level
- Update `.gitignore` patterns automatically

**Content changes (same as setup.sh):**
- Install ORCHESTRATOR ENGINE agent
- Install ORCHESTRATION protocol
- Install orchestration rules
- Update CLAUDE.install.md
- Update VERSION

**Display:**
- Show migration instructions
- Show changes included in update
- Version: v1.4+

### 2.3 `CLAUDE.install.md` — Installed CLAUDE.md

**Full rewrite to v1.4 structure:**
- 17 agents (including ORCHESTRATOR ENGINE)
- 45 rules (R1-R45)
- Flat domain structure (`.brain/{domain}/` not `.brain/{domain}/{project}/`)
- Orchestration engine Phase 0b
- All skill mandate rules
- Security, code quality, naming rules
- Inter-session rules

## 3. EXECUTION STEPS

1. Rewrite `setup.sh` — flat structure, new agents, updated paths
2. Rewrite `update.sh` — migration detection + flatten, new agents
3. Rewrite `CLAUDE.install.md` — full v1.4 installable CLAUDE.md
4. Update `VERSION` file to `v1.5 — Orchestration & Parallel Execution`
5. Verify: run both scripts mentally/in a test dir to validate
