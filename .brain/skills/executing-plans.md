# Executing Plans

> **Source:** Adapted from obra/superpowers (executing-plans)
> **Domain:** Shared — Cross-Domain
> **Use when:** Working through a written implementation plan with review checkpoints.

---

## Overview

Execute a pre-written plan task-by-task with review checkpoints. This is the inline execution alternative to subagent-driven development.

## Process

### Step 1: Load and Review Plan

Read the plan file. Review it critically:
- Does this make sense?
- Are there any concerns?
- Create task todos and proceed

### Step 2: Execute Tasks

For each task:
1. Mark it in progress
2. Follow each step exactly
3. Run verifications after each step (TDD cycle)
4. Mark completed
5. Commit

### Step 3: Complete Development

After all tasks are done and verified:
- Run the full test suite
- Verify build succeeds
- Announce the finishing-a-development-branch skill and follow it

## Stop Conditions

Stop immediately when:
- Blocked on a dependency (need another task first)
- Tests fail and can't be quickly resolved
- Instructions are unclear
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## Revisit Rules

Return to Step 1 if:
- The partner updates the plan
- The approach needs rethinking
- A blocker reveals a fundamental issue

## Required Integrations

- `using-git-worktrees` — for isolated workspace (if not already in one)
- `writing-plans` — created the plan you're executing
- `finishing-a-development-branch` — for the completion phase

## Key Rules

| Rule | Why |
|------|-----|
| Follow the plan, don't redesign | The plan was approved. Execute it. |
| Verify after every step | Catch issues early, not after 10 steps |
| Commit after each task | Clean history, easy rollback |
| Surface blockers immediately | Don't waste time fighting unclear instructions |
| Never start on main/master without consent | Always branch first |
