---
domains: [backend]
---

# Orchestration Rules — R41 to R45

> **Domain:** Backend (RAI-Engineering core)
> **Scope:** Applied by ORCHESTRATOR ENGINE during Phase 0b
> **Model:** host default (model-neutral per R9)

---

## R41 — Decompose Before Dispatch

**Rule:** Before sending any sub-task to a sub-agent, the ORCHESTRATOR ENGINE must produce a complete task decomposition with all sub-tasks, dependency graph, and parallel waves.

**Why:** Partial decomposition leads to mid-task context switches, re-planning, and missed dependencies. The full picture must be understood before any work begins.

**Violation:** The BRAIN detects a dispatch with no corresponding decomposition in the session log and rejects it.

**Exception:** Trivial tasks (single sub-task, single area) don't need formal decomposition — they run without orchestration.

---

## R42 — Default to Parallel

**Rule:** Launch every sub-task whose dependencies are resolved at the same time. Serialize only when a real dependency blocks it. "Simpler to reason about sequentially" is not a valid reason to serialize.

**Why:** The core value of orchestration is throughput through parallelism. Serializing independent work negates the benefit.

**Violation:** The BRAIN auditors flag excessive serialization during post-task review.

**Exception:** If the task is trivial (1 sub-task, 1 area), sequential execution is fine.

---

## R43 — Relay Every Cross-Agent Request

**Rule:** When sub-agent A needs something from sub-agent B, the ORCHESTRATOR ENGINE must log the request, relay it to sub-agent B within the same turn, and deliver the response back to sub-agent A within the same turn it receives it.

**Why:** Blocked sub-agents waste the parallelism advantage. A sub-agent waiting for information cannot make progress. Fast relay keeps the pipeline moving.

**Violation:** A cross-agent request that goes unanswered for more than one verification cycle is a protocol violation. The BRAIN logs the delay.

---

## R44 — Auto-Resolve Conflicts Using Project Rules

**Rule:** When two sub-agents disagree (naming, contracts, approach), the ORCHESTRATOR ENGINE must attempt resolution in this order:
1. Project rules
2. Past decisions
3. Guidelines
4. Conventions (R26 naming, API consistency)
5. Framework defaults

Only escalate to the user if none of the above resolve it AND the decision has real consequences (breaking change, cost, security tradeoff).

**Why:** Every escalation interrupts the user. Auto-resolving routine disagreements keeps the pipeline flowing. The user should only be interrupted for decisions that genuinely need human judgment.

**Violation:** Escalating a conflict that could have been resolved by an existing rule wastes the user's time and is flagged during review.

---

## R45 — Max 3 Verification Cycles Before Escalating

**Rule:** The autonomous completion loop runs a maximum of 3 verification cycles. If the same sub-task fails the same check 3 times in a row within any cycle, escalate immediately (mid-cycle). If after 3 cycles any check still fails, stop and escalate to the user.

**Why:** An infinite loop wastes tokens without making progress. Three cycles give enough room for genuine fixes while preventing runaway loops.

**Violation:** The BRAIN detects more than 3 verification cycles in the session log and interprets it as a protocol violation, forcing escalation.

---

## Summary Table

| Rule | Summary | Escalation Trigger |
|------|---------|-------------------|
| R41 | Decompose before dispatch | Dispatch without decomposition |
| R42 | Default to parallel | Unnecessary serialization |
| R43 | Relay every cross-agent request | Unanswered request > 1 cycle |
| R44 | Auto-resolve conflicts by rules | Escalating resolvable conflicts |
| R45 | Max 3 verification cycles | 4th cycle or 3x same failure |
