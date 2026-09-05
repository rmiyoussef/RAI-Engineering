# Finishing a Development Branch

> **Source:** Adapted from obra/superpowers (finishing-a-development-branch)
> **Domain:** Shared — Cross-Domain
> **Use when:** A development branch is complete and ready to be merged, pushed, or cleaned up.

---

## Overview

Guide for completing development work: verify tests → detect environment → present options → execute choice → clean up.

## Process

### Step 1: Verify Tests

Run the full test suite. Stop if tests fail — resolve before finishing.

### Step 2: Detect Environment

Check whether you're in:
- **Normal repo** — directly in the repo directory
- **Named-branch worktree** — git worktree on a specific branch
- **Detached HEAD** — not on a branch (e.g., CI or bisect)

### Step 3: Determine Base Branch

`git merge-base` against `main` or `master` to find the merge point.

### Step 4: Present Options

| # | Option | When to Choose |
|---|--------|----------------|
| 1 | **Merge locally** — merge into base branch | Branch is complete, ready to integrate |
| 2 | **Push & create PR** — push branch, open PR | Branch needs review before merging |
| 3 | **Keep as-is** — leave the branch, don't merge | Not ready or not desired to merge yet |
| 4 | **Discard** — delete the branch and worktree | Learning was done, code not needed |

### Step 5: Execute Choice

**Option 1 — Merge Locally:**
```bash
git checkout main
git merge --no-ff feature/branch-name
git push origin main
git branch -d feature/branch-name
```

**Option 2 — Push & PR:**
```bash
git push origin feature/branch-name
gh pr create --fill
```

**Option 3 — Keep As-Is:**
Simply leave the branch. Note it for future reference.

**Option 4 — Discard:**
```bash
git branch -D feature/branch-name
```

### Step 6: Cleanup Workspace

For Options 1 and 4, remove worktrees:
```bash
git worktree remove ../feature-branch-dir
```

## Common Mistakes

| Mistake | Correct |
|---------|---------|
| Merging with failing tests | Fix tests first |
| Forgetting to push the merge | Push after merging |
| Merging a branch that isn't reviewed | Open a PR instead |
| Not checking the merge base | Verify with `git merge-base` |
| Keeping worktrees around indefinitely | Clean up after merge/discard |

## Red Flags

| Never | Always |
|-------|--------|
| Merge with failing tests | Verify the full suite passes first |
| Force push to shared branches | Use `git push --force-with-lease` if needed |
| Discard without verifying tests passed | Even for throwaway work, know the state |
| Close a PR without merging | Use "Close" only when the work is truly abandoned |
