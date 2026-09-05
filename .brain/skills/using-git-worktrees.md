# Using Git Worktrees

> **Source:** Adapted from obra/superpowers (using-git-worktrees)
> **Domain:** Shared — Cross-Domain
> **Use when:** Ensuring feature work happens in isolated workspaces, especially when running multiple AI agents.

---

## Overview

Worktrees allow multiple branches to be checked out simultaneously in different directories. This is essential when running multiple agents on the same repo, or when you need an isolated workspace for experimental changes.

## Process

### Step 0: Detect Existing Isolation
Check if you're already in a linked worktree by comparing `GIT_DIR` vs `GIT_COMMON_DIR`. If already isolated, skip to project setup.

### Step 1: Create Isolated Workspace
```bash
git worktree add ../project-feature-x feature/x
```

**Directory selection priority:**
1. User preference (if specified)
2. Existing `.worktrees/` or `worktrees/` directory
3. Default `.worktrees/`

**Safety:** Verify the worktree directory is in `.gitignore` to avoid accidentally committing worktree metadata.

### Step 2: Project Setup
Auto-detect project type and install dependencies:
```bash
# Node.js
npm install

# Rust
cargo build

# Python
pip install -r requirements.txt

# Go
go mod download
```

### Step 3: Verify Clean Baseline
Run project-appropriate tests to confirm the worktree starts in a clean state. Ask permission before proceeding if tests fail.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Already in a worktree | Skip creation, proceed to setup |
| Submodule | Use native tool, not git worktree add |
| Native tool available | Prefer it over git worktree add |
| No native tool | Manual `git worktree add` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Fighting the harness | If the harness already provides isolation, use it |
| Skipping isolation detection | Always check first |
| Skipping .gitignore verification | The worktree directory must be gitignored |
| Proceeding with failing tests | Fix or flag before building |

## Red Flags

| Never | Always |
|-------|--------|
| Use `git worktree add` when a native tool exists | Check `.gitignore` for the worktree directory |
| Start implementation on main/master without consent | Ask the user first |
| Skip clean baseline verification | Run tests to confirm the starting state is clean |
