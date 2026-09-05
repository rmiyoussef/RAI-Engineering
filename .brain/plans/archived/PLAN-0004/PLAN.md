# Plan: Orchestration & Parallel Execution Engine

> **Date:** 2026-07-23
> **Domain:** Backend (RAI-Engineering core)
> **Status:** Draft for approval
> **Model Lock:** deepseek-v4-flash

---

## 1. GOAL

Transform the main agent from a sequential task runner into an **orchestrator** that:
1. Decomposes tasks into independent sub-tasks across multiple domains
2. Dispatches sub-agents in parallel wherever dependencies allow
3. Relays inter-agent requests/conflicts in real-time
4. Runs an autonomous completion loop (dispatch → verify → fix → verify)
5. Reports a structured summary of all parallel work

---

## 2. WHY THIS CAN'T BE THE BRAIN ITSELF

The BRAIN's role is **routing, validation, and persistence** — it never writes code, plans, reviews, or tests. Adding orchestration to the BRAIN violates R10 (one responsibility per file) and its core limitations.

**Solution:** A new agent — the **ORCHESTRATOR ENGINE** — dedicated to task-level orchestration. It has the same role as a project manager/technical lead: decompose, dispatch, coordinate, verify, deliver.

---

## 3. ARCHITECTURE

### 3.1 Agent Hierarchy

```
User Request
    │
    ▼
┌────────────────────────────────────────────────────┐
│  BRAIN                                              │
│  (routes → validates → persists)                    │
│  ├── Phase 0:  SESSION MANAGER (session lifecycle)  │
│  ├── Phase 0a: ARCHITECT (guidelines)              │
│  ├── Phase 0b: ORCHESTRATOR ENGINE (NEW) ◄─────────│
│  │   ├── Task decomposition                         │
│  │   ├── Parallel dispatch to domain sub-agents    │
│  │   ├── Inter-agent request relay                 │
│  │   └── Autonomous completion loop                │
│  ├── Phase 1:  PLANNER                             │
│  ├── Phase 4:  EXECUTOR                            │
│  ├── Phase 6:  REVIEWER                            │
│  └── Phase 8:  MEMORY SCRIBE                       │
└────────────────────────────────────────────────────┘
```

### 3.2 Parallel Dispatch Model

```
ORCHESTRATOR ENGINE
    │
    ├── Decompose task into N sub-tasks
    ├── Resolve dependency graph
    │
    ├── WAVE 1 (no dependencies):                 WAVE 2 (after WAVE 1 resolves):
    │   ├── Sub-agent: Backend PLANNER             ├── Sub-agent: Frontend EXECUTOR
    │   ├── Sub-agent: Frontend PLANNER            ├── Sub-agent: DevOps EXECUTOR
    │   └── Sub-agent: SECURITY audit             └── ...
    │
    ├── Sub-agents communicate via ORCHESTRATOR ENGINE relay
    │   ├── "Backend needs API contract from Frontend"
    │   ├── "Frontend needs DB schema from Backend"
    │   └── ORCHESTRATOR ENGINE relays + logs every exchange
    │
    ├── Verification loop (auto, max 3 cycles):
    │   ├── Check contracts match
    │   ├── Check no unresolved TODOs
    │   ├── Check dependencies wired
    │   └── If gaps → re-dispatch relevant sub-agent
    │
    └── Final report
```

---

## 4. FILES TO CREATE

### 4.1 `.brain/agents/ORCHESTRATOR_ENGINE.md` — New Agent Definition

The full agent specification with:

**Identity:** "You are the ORCHESTRATOR ENGINE. You do not write code, plan features, review, test, or audit. You decompose tasks, dispatch sub-agents in parallel, relay inter-agent requests, and verify completion."

**Input Schema:**
- Original user request
- Domain classification (from BRAIN)
- Available sub-agents and their capabilities
- Project memory context

**Output Schema:**
```json
{
  "taskDecomposition": {
    "originalRequest": "...",
    "primaryDomain": "backend",
    "subTasks": [ ... ],
    "dependencyGraph": { ... }
  },
  "parallelDispatches": [
    {
      "wave": 1,
      "subTaskIds": ["uuid-1", "uuid-2"],
      "dispatchedAt": "timestamp"
    }
  ],
  "crossAgentCommunications": [
    {
      "requestId": "uuid",
      "fromAgent": "backend_executor",
      "toAgent": "frontend_executor",
      "need": "API contract for POST /users",
      "response": "...",
      "resolvedAt": "timestamp"
    }
  ],
  "conflictsResolved": [
    {
      "between": ["backend", "frontend"],
      "issue": "Field name for full_name vs displayName",
      "resolution": "full_name (per snake_case API convention)",
      "autoResolved": true
    }
  ],
  "verificationCycles": [
    {
      "cycle": 1,
      "checks": [
        { "check": "contracts_match", "status": "pass" },
        { "check": "no_pending_todos", "status": "fail" },
        { "check": "dependencies_wired", "status": "pass" }
      ],
      "fixes": [
        { "subTaskId": "uuid-3", "fix": "...", "redispatched": true }
      ]
    }
  ],
  "status": "complete | needs_user_input | stuck",
  "finalReport": "Structured summary"
}
```

**Execution Rules:**
1. Decompose before dispatching — understand the full task graph first
2. Default to parallel — only serialize when a real dependency blocks it
3. Relay every cross-agent request within 1 turn — never let a sub-agent wait
4. Log every exchange — user should see the conversation if they check
5. Resolve conflicts using project rules first, ask user only if no rule applies
6. Run max 3 verification cycles before escalating
7. Never expand scope — fixes must serve the original request
8. Respect domain isolation — sub-agents only touch their own domain folder

**Who It Calls:**
| Need | Agent | Message |
|------|-------|---------|
| Run a sub-task | Any domain agent | "Delegating sub-task X to you" |
| Get file knowledge | ARCHIVIST | "Read these files for context" |
| Request from another sub-agent | ORCHESTRATOR ENGINE (self-relay) | "Sub-agent A needs X from sub-agent B" |
| Check project rules | ARCHITECT | "Is this conflict covered by a rule?" |
| Escalate | BRAIN (→ user) | "Decision needed: X conflicts with Y" |

### 4.2 `.brain/brain/ORCHESTRATION.md` — Orchestration Protocol

Defines:
- Task decomposition schema
- Dependency graph resolution algorithm
- Parallel wave dispatch protocol
- Inter-agent request/response relay protocol
- Conflict detection and resolution rules
- Autonomous completion loop protocol (verify → fix → verify → max 3)
- Stuck detection criteria (same failure 3 times)

### 4.3 `.brain/backend/rai-engineering/rules/orchestration-rules.md` — Project Rules

Rules R41-R45 for orchestration:
- R41: Decompose before dispatch
- R42: Default to parallel
- R43: Relay every cross-agent request
- R44: Auto-resolve conflicts using project rules
- R45: Max 3 verification cycles before escalating

### 4.4 Rule/Decision Memory Files

- `.brain/backend/rai-engineering/memory/decisions/2026-07-23-orchestration-engine.md`

---

## 5. FILES TO MODIFY

### 5.1 `CLAUDE.md` — Major Updates

**A. Agent Directory table** — Add ORCHESTRATOR ENGINE:
```
| ORCHESTRATOR ENGINE | Task orchestrator — decomposes, dispatches, verifies | `.brain/agents/ORCHESTRATOR_ENGINE.md` |
```

**B. Execution Phases** — Add Phase 0b between Phase 0 and Phase 1:
```
### Phase 0b: Task Orchestration (ORCHESTRATOR ENGINE leads)
When a task spans multiple domains or has multiple independent sub-tasks:
- Decompose task into sub-tasks with dependency graph
- Map each sub-task to its domain sub-agent
- Dispatch independent sub-tasks in parallel waves
- Relay cross-agent requests in real-time
- Resolve conflicts using project rules
- Run autonomous completion loop (max 3 cycles)
- Produce structured final report
```

**C. Add New Rules R41-R45** in the Rules section.

**D. Update version footer** to v1.4.

### 5.2 `.brain/brain/SYSTEM.md` — Updates

- Add ORCHESTRATOR ENGINE to the agent mesh diagram and agent list
- Add `orchestrator_engine` to the `from`/`to` fields in message protocol
- Add new message types (`inter_agent_request`, `inter_agent_response`) if needed
- Add validation rules for orchestration messages

### 5.3 `.brain/brain/RULES.md` — Add R41-R45

### 5.4 `.brain/INDEX.md` — Add new decision entry

### 5.5 `.brain/backend/rai-engineering/memory/guidelines.md` — Add orchestration patterns section

---

## 6. RISKS AND MITIGATIONS

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Parallel sub-agents produce conflicting outputs | Medium | Conflict detection rules + auto-resolution by project conventions |
| Completion loop runs indefinitely | Low | Hard cap of 3 verification cycles, then escalate |
| Token explosion from parallel dispatch | Medium | Each sub-agent returns structured output (compact), BRAIN validates |
| Cross-agent requests pile up waiting for response | Low | ORCHESTRATOR ENGINE must relay within same context turn |
| Domain isolation violation | Low | ORCHESTRATOR ENGINE enforces: sub-agents only write to their domain folder |
| Feature scope creep from "fix gaps" | Medium | Rule: fixes must serve original request, no open-ended improvement |

---

## 7. EXECUTION STEPS

1. **Create** `.brain/agents/ORCHESTRATOR_ENGINE.md` — Full agent definition with schemas
2. **Create** `.brain/brain/ORCHESTRATION.md` — Orchestration protocol
3. **Create** `.brain/backend/rai-engineering/rules/orchestration-rules.md` — R41-R45
4. **Create** `.brain/backend/rai-engineering/memory/decisions/2026-07-23-orchestration-engine.md`
5. **Modify** `CLAUDE.md` — Add agent, phases, rules, update version
6. **Modify** `.brain/brain/SYSTEM.md` — Add to mesh, message protocol, routing
7. **Modify** `.brain/brain/RULES.md` — Add R41-R45
8. **Modify** `.brain/INDEX.md` — Add new entries
9. **Modify** `.brain/backend/rai-engineering/memory/guidelines.md` — Add orchestration section
10. **Verify** — REVIEWER scores implementation (target 9+)
11. **Memory** — MEMORY SCRIBE writes session summary

---

## 8. OPEN QUESTIONS

None — requirements are clear from the user's specification.

---

## 9. APPROVAL

Ready for user review.
