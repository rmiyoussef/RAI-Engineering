---
domains: [all]
---

# Decision: Orchestration & Parallel Execution Engine

**Date:** 2026-07-23
**Domain:** Backend (RAI-Engineering core)
**Project:** RAI-Engineering
**Context:** The existing agent pipeline runs sequentially — PLANNER → EXECUTOR → REVIEWER → MEMORY. Complex tasks that span multiple domains (e.g., Backend + Frontend + DevOps) have no mechanism for parallel dispatch, inter-agent coordination, or autonomous gap-filling. The user must babysit every step.

## Options Considered

- **Option A: Extend the BRAIN to orchestrate.** Rejected because the BRAIN's role is routing, validation, and persistence (R10). Adding orchestration violates single responsibility and the core limitation "The Brain never plans or executes."

- **Option B: Extend the ORCHESTRATOR (session manager) to also do task orchestration.** Rejected because the ORCHESTRATOR's role is session lifecycle (registration, heartbeat, inter-session routing). Merging task orchestration would conflate two distinct responsibilities.

- **Option C (Chosen): Create a dedicated ORCHESTRATOR ENGINE agent.** A new agent that does exactly one thing — task decomposition, parallel dispatch, inter-agent relay, and verification. It is a sibling to PLANNER, EXECUTOR, REVIEWER, etc., not a replacement for any of them.

## Decision

**Chosen:** Option C — Dedicated ORCHESTRATOR ENGINE agent

**Rationale:**
1. Follows R10 (one responsibility per file/agent)
2. The ORCHESTRATOR ENGINE has a well-defined scope: decompose, dispatch, relay, verify — nothing else
3. It can be loaded only when needed (multi-domain tasks), keeping simple tasks fast
4. It respects the existing agent mesh — domain sub-agents remain unchanged
5. It enforces domain isolation through built-in verification checks

## Consequences

- **Enables:** Parallel execution of multi-domain tasks without user babysitting
- **Enables:** Autonomous gap-filling loop with a hard cap of 3 cycles
- **Enables:** Real-time inter-agent request relay without blocking
- **Enables:** Conflict detection and auto-resolution using project rules
- **Enables:** Structured reports showing exactly what each sub-agent did

## Files Created
- `.brain/agents/ORCHESTRATOR_ENGINE.md` — Agent definition with full schema
- `.brain/brain/ORCHESTRATION.md` — Orchestration protocol specification
- `.brain/backend/rules/orchestration-rules.md` — R41-R45

## Files Modified
- `CLAUDE.md` — Added agent, Phase 0b, R41-R45, version v1.4
- `.brain/brain/SYSTEM.md` — Added ORCHESTRATOR ENGINE to mesh, protocol
- `.brain/brain/RULES.md` — Added R41-R45
- `.brain/INDEX.md` — Added new entries
- `.brain/backend/memory/guidelines.md` — Added orchestration section

## Related
- See also: [[orchestration-rules]] — Rules R41-R45
- See also: [[ORCHESTRATION.md]] — Protocol specification
- See also: [[ORCHESTRATOR_ENGINE.md]] — Agent definition
- See also: [[backend/plans/2026-07-23-flatten-domain-structure]] — Domain flattening decision
