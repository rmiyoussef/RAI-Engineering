# 2026-09-07-loose-plan-recovery — Move loose plans/ files to completed via update.sh

**Objective:** Loose `.brain/plans/*.md` files auto-wrap into completed slug dirs on every update.
**Status:** completed
**Owner:** opencode agent
**Created:** 2026-09-07

## Problem
bench/backend held 6 loose plan files in plans/ root. No updater path handled them. Same run exposed backup self-inclusion: tar archived `.brain/.migration` into itself (`file changed as we read it`, fatal under set -e).

## Scope / Non-goals
- In scope: recover_loose_plans(), plan_id_for filename fallback, backup exclude fix, §14 + backup self-exclusion test, v1.9.1 sync.
- Non-goals: loose test-case/summary handling, state backfill beyond pointer append.

## Requirements
- [x] R1 Loose files wrapped to completed with STATUS, names kept when slug-shaped
- [x] R2 Backup excludes its own .migration dir deterministically
- [x] R3 Suite green, bench healed, v1.9.1 pushed

## Tasks
See TASKS.md. Covering TC: TC-01.

## Completion requirements
INSTRUCTIONS.md §8 contract.
