# Resolving Merge Conflicts

> **Source:** Adapted from mattpocock/skills (resolving-merge-conflicts)
> **Domain:** Shared — Cross-Domain
> **Use when:** Resolving an in-progress git merge or rebase conflict.

---

## Process

### 1. See the Current State

Check the state of the merge/rebase:
- `git status` — which files are conflicted?
- `git log --oneline` — what commits are involved?
- `git diff` — what's the current diff?

### 2. Find the Primary Sources

For each conflict, understand **why each change was made** and what the original intent was:
- Read commit messages from both sides
- Check related PR descriptions
- Look at linked issues

### 3. Resolve Each Hunk

- Preserve both intents where possible
- If they conflict, pick the one that aligns with the merge's goal
- **Do not invent new behavior** — resolve, don't redesign
- **Always resolve; never `--abort`** — the only way out is through

### 4. Discover Automated Checks

After resolving all conflicts:
- `git status` to see staged/unstaged files
- Run typecheck, tests, format — fix anything broken by the merge
- Don't assume the merge is clean just because there are no conflict markers

### 5. Finish

1. Stage resolved files: `git add <files>`
2. Commit (for a merge) or continue (for a rebase)
3. For rebase: `git rebase --continue` until all commits are replayed
4. Verify the final state: tests pass, build succeeds

## Key Rules

| Rule | Why |
|------|-----|
| Never `--abort` | You'll face the same conflicts again. Resolve them now. |
| Don't invent new behavior | Merging is not designing. Stay faithful to both sources. |
| Fix merge-created issues | Dependencies may change. Run the full suite. |
| Investigate intent | Understanding WHY helps you decide WHAT to keep. |
