# Orchestration & Parallel Execution Protocol

> Defines how the ORCHESTRATOR ENGINE decomposes tasks, dispatches sub-agents in parallel, relays inter-agent requests, and runs the autonomous completion loop.
> Protocol version: 1.0
> Model: host default, model-neutral per R9

---

## Overview

The Orchestration Protocol transforms a sequential agent pipeline into a **parallel execution mesh**.

When a task involves multiple domains or independent pieces of work, the ORCHESTRATOR ENGINE:

1. **Decomposes** the task into independent sub-tasks
2. **Resolves** the dependency graph (which sub-tasks block which)
3. **Dispatches** sub-tasks in parallel waves (no-dependency tasks first)
4. **Relays** inter-agent requests so sub-agents don't block on each other
5. **Verifies** the work fits together, re-dispatches if gaps found
6. **Reports** a structured summary of everything that happened

```
┌─────────────────────────────────────────────────────────────────┐
│                     ORCHESTRATION PROTOCOL                       │
│                                                                  │
│  User Task                                                       │
│      │                                                           │
│      ▼                                                           │
│  ┌──────────────────────┐                                        │
│  │ 1. TASK DECOMPOSITION │  Break task into sub-tasks,           │
│  │                      │  identify domains, build dep graph     │
│  └──────────┬───────────┘                                        │
│             │                                                     │
│             ▼                                                     │
│  ┌──────────────────────┐                                        │
│  │ 2. DEPENDENCY RESOLVE │  Compute parallel waves from graph    │
│  │                      │  Wave 1: no deps → parallel            │
│  │                      │  Wave 2: deps on Wave 1 → parallel     │
│  └──────────┬───────────┘                                        │
│             │                                                     │
│             ▼                                                     │
│  ┌──────────────────────┐                                        │
│  │ 3. PARALLEL DISPATCH  │  Launch all Wave 1 sub-agents         │
│  │ ┌──────────────────┐  │  simultaneously                       │
│  │ │ Backend Executor ├──┼──► Write code                         │
│  │ │ Frontend Executor├──┼──► Write components                   │
│  │ │ DevOps Executor  ├──┼──► Write configs                      │
│  │ └──────────────────┘  │                                       │
│  └──────────┬───────────┘                                        │
│             │                                                     │
│             ▼                                                     │
│  ┌──────────────────────┐    requests     ┌───────────────────┐  │
│  │ 4. INTER-AGENT RELAY │◄──────────────►│  Sub-agent A needs │  │
│  │  Log → Relay → Resolve│                │  X from sub-agent B │  │
│  └──────────┬───────────┘                └───────────────────┘  │
│             │                                                     │
│             ▼                                                     │
│  ┌──────────────────────┐                                        │
│  │ 5. VERIFICATION LOOP  │  Check contracts, todos, wiring        │
│  │  (max 3 cycles)       │  If gaps → re-dispatch affected sub    │
│  │  If OK → done         │  If stuck 3x → escalate               │
│  └──────────┬───────────┘                                        │
│             │                                                     │
│             ▼                                                     │
│  ┌──────────────────────┐                                        │
│  │ 6. FINAL REPORT      │  Summary of all work, relays,           │
│  │                      │  conflicts, verification cycles         │
│  └──────────────────────┘                                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Task Decomposition Schema

The ORCHESTRATOR ENGINE receives a task and produces a structured decomposition:

```json
{
  "taskDecomposition": {
    "originalRequest": "User's original request text",
    "domainTags": ["backend", "frontend"],
    "subTasks": [
      {
        "id": "subtask-uuid",
        "domainTags": ["backend"],
        "description": "Clear description of this sub-task",
        "dependsOn": ["subtask-uuid-of-predecessor"],
        "definedInput": {
          "requiredFrom": [
            { "subTaskId": "other-uuid", "output": "api-contract" }
          ],
          "filesProvided": ["path/to/file"],
          "contextProvided": "Relevant memory context"
        },
        "expectedOutput": {
          "description": "What this sub-agent will produce",
          "deliverables": ["file/path/1", "file/path/2"],
          "contract": { "interface description if applicable" }
        },
        "subAgent": {
          "type": "planner | executor | reviewer",
          "domainTags": ["backend"]
        },
        "estimatedComplexity": "low | medium | high"
      }
    ],
    "dependencyGraph": {
      "waves": [
        { "wave": 1, "subTaskIds": ["indep-1", "indep-2", "indep-3"] },
        { "wave": 2, "subTaskIds": ["dep-on-wave1"] }
      ]
    }
  }
}
```

### Decomposition Rules

1. **Smallest independent unit** — If a sub-task can be done without waiting for another sub-task's output, it's independent. Split until you find the smallest unit that still has clear value.
2. **Domain tags, not domain silos** — Each sub-task carries `domainTags` metadata (e.g. `["backend", "frontend"]`). If a piece of work spans areas (e.g., "add validation that touches backend and frontend"), split it into two sub-tasks with a dependency so each stays reviewable.
3. **Clear expected output** — Every sub-task must state what it produces. If you can't describe the output, the sub-task is too vague.
4. **Every sub-task maps to an existing sub-agent** — Domain executors, planners, security, reviewers. No abstract sub-tasks that no agent can own.

### Dependency Types

| Type | Meaning | Example |
|------|---------|---------|
| `contract` | Sub-agent B needs the API contract/interface from sub-agent A | Frontend needs the POST /users response shape |
| `data` | Sub-agent B needs data/files from sub-agent A | Tests need the controller and service files |
| `decision` | Sub-agent B needs an architectural decision from sub-agent A | Frontend needs to know auth approach before building login |
| `sequential` | Sub-agent B literally builds on sub-agent A's output | Migration must run before seeder can be written |
| `none` | No dependency — can run in any order | Backend API and DevOps CI config are independent |

---

## 2. Dependency Graph Resolution

The ORCHESTRATOR ENGINE resolves the dependency graph into **parallel waves**:

### Algorithm

```
Input: List of sub-tasks with dependsOn edges
Output: Ordered list of waves

1. Create empty wave list
2. Find all sub-tasks with empty dependsOn → Wave 1
3. Remove Wave 1 sub-tasks from remaining pool
4. Find all remaining sub-tasks whose dependsOn are all in completed waves → Wave 2
5. Repeat until all sub-tasks are assigned to a wave
6. If at any point no sub-tasks can be assigned but pool is not empty → circular dependency detected
```

### Example

```
Sub-tasks:
  A: []              (no deps)
  B: []              (no deps)
  C: [A]             (depends on A)
  D: [A, B]          (depends on A and B)
  E: [C]             (depends on C)

Waves:
  Wave 1: [A, B]     → run in parallel
  Wave 2: [C, D]     → run in parallel (both deps met)
  Wave 3: [E]        → run after C completes
```

### What "Parallel" Means in a Single-Threaded Model

In the current RAI-Engineering architecture, all agents run in the same thread. "Parallel" means:

1. Sub-agents in the same wave are **dispatched within the same turn**, not sequentially
2. The ORCHESTRATOR ENGINE sends all sub-task messages in one batch
3. The BRAIN routes them concurrently (each is a separate message)
4. Sub-agents that have no dependency on each other do not wait for each other's output

This achieves logical parallelism even within a single thread — the key benefit is that sub-agent A doesn't block sub-agent B when they could both be working on their independent pieces.

---

## 3. Parallel Dispatch Protocol

### Dispatch Message Format

When dispatching a sub-task, the ORCHESTRATOR ENGINE sends a delegate message:

```json
{
  "from": "orchestrator_engine",
  "to": "{area}::{sub_agent_type}",
  "type": "delegate",
  "session": "<session_uuid>",
  "context": {
    "task": "Sub-task description",
    "plan": "Reference to the task decomposition",
    "files": ["affected/files"],
    "orchestration": {
      "subTaskId": "uuid",
      "wave": 1,
      "totalWaves": 3,
      "peerSubTasks": ["uuid-other-in-same-wave"],
      "dependencyOutputs": [
        {
          "fromSubTask": "other-uuid",
          "output": {}
        }
      ],
      "crossAgentRelayChannel": "orchestrator_engine"
    }
  },
  "payload": {
    "goal": "Specific goal for this sub-agent",
    "constraints": ["constraint 1", "constraint 2"],
    "definedInput": {},
    "expectedOutput": {}
  }
}
```

### Wave Dispatch Rules

1. **All sub-tasks in a wave are dispatched in one batch.** No sequential dispatch within a wave.
2. **Wave N+1 starts as soon as all sub-tasks in Wave N are complete.** No need to wait for all waves to complete before relaying — relay happens continuously.
3. **If a sub-task fails in a wave, the remaining sub-tasks in that wave still complete.** Failure of one sub-task does not cancel other parallel work (unless the failed sub-task produces a dependency required by others, in which case the dependent sub-tasks must wait for re-dispatch).

---

## 4. Inter-Agent Request/Response Relay

This is the protocol for sub-agents to request information from other sub-agents during parallel execution.

### Protocol Flow

```
Sub-agent A needs data from Sub-agent B
    │
    ├─► A sends: INTER_AGENT_REQUEST to ORCHESTRATOR ENGINE
    │     {
    │       "requestId": "uuid",
    │       "need": "What I need",
    │       "reason": "Why I need it",
    │       "fromSubTask": "uuid-of-A",
    │       "targetSubTask": "uuid-of-B",
    │       "priority": "blocking | nice_to_have"
    │     }
    │
    ├─► ORCHESTRATOR ENGINE logs request
    │     ✏️ Logged: "Sub-agent A needs API contract from Sub-agent B"
    │
    ├─► ORCHESTRATOR ENGINE relays to Sub-agent B
    │     "Sub-agent A needs: [need]. Please respond with: [response]"
    │
    ├─► Sub-agent B responds
    │     { "requestId": "uuid", "response": { ... } }
    │
    ├─► ORCHESTRATOR ENGINE logs response
    │     ✏️ Logged: "Sub-agent B responded to A's request: [response summary]"
    │
    └─► ORCHESTRATOR ENGINE delivers response to Sub-agent A
          "Here is the response from Sub-agent B: [response]"
```

### Request Schema

```json
{
  "requestId": "uuid",
  "fromSubTask": "uuid-of-requesting-subtask",
  "targetSubTask": "uuid-of-target-subtask",
  "need": "Description of what is needed",
  "reason": "Why it's needed — what it blocks",
  "priority": "blocking | nice_to_have",
  "context": {
    "files": ["relevant/files"],
    "constraints": ["any constraints on the answer"]
  }
}
```

### Response Schema

```json
{
  "requestId": "uuid",
  "fromSubTask": "uuid-of-responding-subtask",
  "response": {
    "answer": "The actual response data",
    "additionalContext": "Any extra context that might help",
    "blockers": ["anything preventing a complete answer"]
  },
  "deliveredAt": "timestamp"
}
```

### Relay Rules

1. **Every request is logged before relay.** The user must be able to see what exchanges happened.
2. **Blocking requests are relayed immediately.** Nice-to-have requests are batched (max 3 per relay turn).
3. **If target sub-agent is in a different wave (not yet started), the request is queued.** The ORCHESTRATOR ENGINE holds it and delivers it when the target sub-agent starts.
4. **If a request goes unanswered for 3 relay attempts, it's escalated.** The ORCHESTRATOR ENGINE marks the requesting sub-agent as stuck.

---

## 5. Conflict Detection & Resolution

### How Conflicts Arise

When two sub-agents produce outputs that disagree:

| Conflict Type | Example | Detection |
|---------------|---------|-----------|
| **Naming** | Backend: `full_name`, Frontend: `displayName` | Contract comparison |
| **Contract** | Backend says 3 fields, Frontend expects 4 | Schema mismatch |
| **Approach** | Backend uses cursor pagination, Frontend expects offset | Design divergence |
| **Boundary** | Backend rejects null, Frontend sends null | Validation mismatch |
| **Timing** | Backend completes in 10ms, UI expects 2s animation | Expectation mismatch |

### Resolution Hierarchy

The ORCHESTRATOR ENGINE resolves conflicts by checking these sources in order:

1. **Rules** (`.brain/rules/<purpose>/`, selected by sub-task — never a domain folder) — Does a rule govern this?
2. **Past decisions** (`.brain/memory/decisions/`) — Was this decided before?
3. **Context + knowledge** (`.brain/context/`, `.brain/knowledge/`) — What does the architecture say?
4. **Convention** (R26 — Naming, API consistency) — What's the existing pattern?
5. **Framework default** — What does the framework (Laravel, React, etc.) prefer?

**If #1-#5 resolve it** → Auto-resolve, log which source was used.
**If none resolve it** → Check if the decision has real consequences:
- Breaking API change → Escalate to user
- Cost implication → Escalate to user
- Security tradeoff → Escalate to user
- Minor naming difference → Pick the dominant convention, log the choice

### Conflict Record Format

```json
{
  "between": ["subtask-uuid-A", "subtask-uuid-B"],
  "issue": "What they disagree on",
  "positions": {
    "subtask-uuid-A": "Position of sub-agent A",
    "subtask-uuid-B": "Position of sub-agent B"
  },
  "resolution": "The resolved decision",
  "ruleUsed": "Which rule/decision/convention resolved it (or 'user' if escalated)",
  "autoResolved": true,
  "resolvedAt": "timestamp"
}
```

---

## 6. Autonomous Completion Loop

The completion loop is the heartbeat of the orchestration. It runs until the task is fully verified or hits a terminal state.

### Loop State Machine

```
                    ┌──────────────┐
                    │  DISPATCHED  │
                    └──────┬───────┘
                           │
                           ▼
              ┌─────────────────────────┐
        ┌────►│   WAITING FOR COMPLETION │
        │     └────────────┬────────────┘
        │                  │
        │                  ▼
        │     ┌───────────────────────┐
        │     │  COLLECTING OUTPUTS   │
        │     └──────────┬────────────┘
        │                │
        │                ▼
        │     ┌───────────────────────┐
        │     │    VERIFICATION       │──────────► If pass → DONE
        │     └──────────┬────────────┘
        │                │
        │                ▼ fail
        │     ┌───────────────────────┐
        │     │   CAN WE FIX?         │
        │     │   (cycle < 3 AND      │
        │     │    fix is in-scope?)   │
        │     └──────────┬────────────┘
        │                │
        │            yes │     no
        │                ▼     ▼
        │     ┌────────────┐  ┌──────────┐
        │     │ RE-DISPATCH │  │ ESCALATE │
        │     │ (fix)       │  │ (to user) │
        │     └──────┬─────┘  └──────────┘
        │            │
        └────────────┘
```

### Verification Checks

After all sub-agents in all waves report done, the ORCHESTRATOR ENGINE runs these checks:

| Check | What It Tests | Pass Condition |
|-------|---------------|----------------|
| `all_subtasks_complete` | Every sub-task reported "done" | No sub-task in "running" or "failed" |
| `contracts_match` | API contracts between sub-agents align | No field mismatch, type mismatch, or missing endpoint |
| `no_pending_todos` | No sub-agent left `// TODO` or `// FIXME` markers | Zero unresolved markers in new code |
| `no_blockers_left` | No sub-agent flagged a blocker | Zero items in `crossAgentCommunications` with status "pending" |
| `dependencies_wired` | Cross-sub-agent references are correctly wired | Frontend calls the actual Backend endpoint created |
| `purpose_placement` | No knowledge filed by technical domain | All brain writes land in purpose dirs (`rules/<purpose>/`, `knowledge/<purpose>/`); domains only as `domains:` frontmatter |
| `scope_contained` | No changes outside original task scope | Only files in the original plan were touched |

### Re-Dispatch Rules

When verification fails, the ORCHESTRATOR ENGINE:

1. **Identifies exactly which sub-task failed which check** — not a vague "something's wrong"
2. **Creates a fix sub-task** — smaller than the original, focused only on the gap
3. **Dispatches the fix sub-task to the same sub-agent** — the sub-agent that caused the gap
4. **Does NOT re-dispatch unrelated sub-tasks** — only affected sub-tasks are re-run

### Scope Containment Check

The ORCHESTRATOR ENGINE must verify that fixes don't expand scope:

```
Allowed:
  "The form doesn't wire to the error handler" → Fix the error handler binding
  "The API response has a typo in the field name" → Fix the field name

Not Allowed:
  "The form works but could be prettier" → Skip (scope creep)
  "The API is done, but the auth system could also use X" → Skip (new work)
  "We could also add caching while we're here" → Skip (unrelated improvement)
```

### Terminal States

| State | Condition | Action |
|-------|-----------|--------|
| `complete` | All checks pass within 3 cycles | Produce final report |
| `needs_user_input` | Framework-level conflict, breaking change, cost decision | Pause, present to user |
| `stuck_same_failure` | Same sub-task fails same check 3 times in a row | Escalate to user |
| `stuck_cycle_limit` | 3 verification cycles completed with remaining failures | Escalate to user with summary |
| `stuck_unresolved_relay` | Cross-agent request unanswered after 3 relay attempts | Escalate to user |

---

## 7. Guardrails

### Never File Knowledge by Domain

- There are no domain folders in `.brain`. Sub-agents write to purpose dirs (`rules/<purpose>/`, `knowledge/<purpose>/`, `memory/`, `plans/`, `test-cases/`, `summaries/`) and tag technical areas with `domains:` frontmatter.
- Cross-area data flows through the ORCHESTRATOR ENGINE relay, not side-channel files.
- The verification check `purpose_placement` enforces this.

### Never Run Indefinitely

- Hard cap of 3 verification cycles
- Same-failure-3-times detection (escalates mid-cycle)
- Each verification cycle has a defined max time budget (inferred from sub-task complexity)

### Never Expand Scope

- The `scope_contained` check compares changed files against the original plan
- Fixes must serve the original request, not open-ended improvement
- If a sub-agent proposes additional improvements, the ORCHESTRATOR ENGINE flags them as out of scope and logs them for future consideration

---

## 8. Error Handling

| Error | Response |
|-------|----------|
| Circular dependency in sub-task graph | ORCHESTRATOR ENGINE rejects, asks BRAIN to escalate |
| Sub-agent fails to start | Mark sub-task as failed, continue with remaining wave |
| Sub-agent returns invalid output | Request fix re-dispatch (counts toward 3-cycle limit) |
| Cross-agent request to unknown sub-task | ORCHESTRATOR ENGINE returns error to requester |
| Verification check uncovers domain-folder write | Flag as purpose-placement violation, fix re-dispatch |
| Scope expansion detected in fix | Reject the fix, re-dispatch with narrower instructions |
| 3 verification cycles exhausted | Stop loop, produce escalation report for user |

---

## 9. Reporting

### Final Report Format

After the completion loop ends (success or terminal state), the ORCHESTRATOR ENGINE produces:

```json
{
  "orchestrationSummary": {
    "originalRequest": "Full task description",
    "totalSubTasks": 5,
    "parallelWaves": 3,
    "domainsTouched": ["backend", "frontend"],
    "duration": "N cycles"
  },
  "subTaskResults": [
    {
      "id": "uuid",
      "domain": "backend",
      "description": "Sub-task description",
      "wave": 1,
      "status": "completed | fixed | failed",
      "outputSummary": "What this sub-task produced",
      "filesChanged": ["file/path"],
      "testResults": { "passed": 5, "failed": 0 }
    }
  ],
  "crossAgentExchanges": [
    {
      "from": "backend",
      "to": "frontend",
      "need": "API contract",
      "resolved": true,
      "responseSummary": "Response description"
    }
  ],
  "conflicts": [
    {
      "between": ["backend", "frontend"],
      "issue": "Naming conflict on field X",
      "resolution": "Used project convention",
      "autoResolved": true
    }
  ],
  "verificationCycles": {
    "total": 2,
    "checksPerformed": ["contracts_match", "no_pending_todos"],
    "fixesApplied": 1,
    "finalStatus": "pass"
  },
  "scopeContainment": {
    "filesPlanned": 4,
    "filesChanged": 4,
    "filesOutsideScope": 0,
    "status": "clean"
  },
  "domainIsolation": {
    "violations": 0,
    "status": "clean"
  },
  "status": "complete | needs_user_input | stuck",
  "handoffNote": "Summary for the next agent or the user"
}
```

---

## Related Documents

- [ORCHESTRATOR ENGINE Agent Definition](../agents/ORCHESTRATOR_ENGINE.md) — Agent that executes this protocol
- [Orchestration Rules (R41-R45)](../rules/orchestration-rules.md) — Enforced rules
- [System Message Protocol](SYSTEM.md) — Message routing and validation
- [Inter-Session Protocol](INTER_SESSION.md) — Cross-session communication (not parallel dispatch)
