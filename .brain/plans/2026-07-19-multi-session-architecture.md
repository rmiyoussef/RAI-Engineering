# Plan: Multi-Session Architecture for RAI-Engineering

> Date: 2026-07-19
> Status: Draft for approval
> Version Impact: v1.1 → v1.2

---

## Goal

Enable multiple RAI-Engineering sessions (each running in its own Claude conversation) to discover each other, send messages, delegate work, and share results — all through the shared `.brain/` filesystem.

---

## Architecture Overview

```
                    ┌──────────────────────────────────────┐
                    │        INTER-SESSION BUS             │
                    │   (.brain/session-bus/ queue)        │
                    └──┬───────────┬───────────┬───────────┘
                       │           │           │
                 ┌─────▼───┐ ┌─────▼───┐ ┌─────▼───┐
                 │Session A │ │Session B │ │Session C │
                 │          │ │          │ │          │
                 │ PLANNER  │ │ PLANNER  │ │ PLANNER  │
                 │ EXECUTOR │ │ EXECUTOR │ │ EXECUTOR │
                 │ REVIEWER │ │ REVIEWER │ │ REVIEWER │
                 │ TESTER   │ │ TESTER   │ │ TESTER   │
                 │ MEMORY   │ │ MEMORY   │ │ MEMORY   │
                 │ORCHESTRTR│ │ORCHESTRTR│ │ORCHESTRTR│
                 └──────────┘ └──────────┘ └──────────┘
                       │           │           │
                       └───────────┼───────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │     SHARED .brain/ STORE     │
                    │   memory/ decisions/         │
                    │   lessons/ sessions/         │
                    │   session-bus/ sessions/     │
                    └─────────────────────────────┘
```

---

## New Components

### 1. ORCHESTRATOR Agent (New)

A new agent that handles session lifecycle and inter-session communication for its local session.

**Role:** Session lifecycle manager. Registers, heartbeats, polls inbox, routes incoming inter-session messages to local agents.

**Responsibilities:**
- Register this session in `.brain/sessions/live/{uuid}.json`
- Write heartbeat every 60s (TTL-based liveness)
- Poll `.brain/session-bus/inbox/{our-uuid}/` for incoming messages
- Route incoming inter-session messages to appropriate local agent
- Handle session shutdown (deregister + flush remaining messages)

**Output Schema:**
```json
{
  "sessionId": "uuid",
  "sessionName": "builder-1",
  "sessionRole": "builder | reviewer | tester | gateway | general",
  "status": "registered",
  "registeredAt": "2026-07-19T12:00:00Z",
  "lastHeartbeat": "2026-07-19T12:01:00Z",
  "inboxCount": 2,
  "outboxCount": 1,
  "peersDiscovered": ["session-uuid-b", "session-uuid-c"],
  "actions": ["send_message", "poll_inbox", "broadcast", "delegate"]
}
```

### 2. Session Registry (.brain/sessions/)

A file-based directory where each live session registers itself.

**Structure:**
```
.brain/sessions/
├── README.md                    ← Protocol documentation
└── live/
    ├── {session-uuid-A}.json    ← Session A's registration + heartbeat
    ├── {session-uuid-B}.json    ← Session B's registration + heartbeat
    └── ...
```

**Registration file format:**
```json
{
  "sessionId": "uuid",
  "name": "builder-1",
  "role": "builder",
  "capabilities": ["execute", "review", "test"],
  "status": "alive",
  "startedAt": "2026-07-19T12:00:00Z",
  "lastHeartbeat": "2026-07-19T12:01:00Z",
  "model": "deepseek-v4-flash"
}
```

**TTL:** If `lastHeartbeat` is > 120s old, session is considered dead. ORCHESTRATOR cleans up stale entries during poll cycle.

### 3. Inter-Session Message Bus (.brain/session-bus/)

A file-based message queue for asynchronous communication between sessions.

**Structure:**
```
.brain/session-bus/
├── README.md                    ← Bus protocol documentation
├── outbox/
│   └── {session-uuid-A}/
│       └── {timestamp}--{msg-id}.json
└── inbox/
    └── {session-uuid-B}/
        └── {timestamp}--{msg-id}.json
```

**Message file format (extended Message Protocol):**
```json
{
  "from": "session_A::planner",
  "to": "session_B::executor",
  "type": "inter_session_delegate | inter_session_request | inter_session_consult | inter_session_done | inter_session_error",
  "messageId": "uuid",
  "timestamp": "2026-07-19T12:00:00Z",
  "ttl": "2026-07-19T13:00:00Z",
  "context": {
    "task": "Original task description",
    "files": ["affected file list"],
    "originSession": "session_A_uuid",
    "correlationId": "tracks request-response pairs"
  },
  "payload": { }
}
```

### 4. Extended Message Types

| Type | Meaning | Pattern |
|------|---------|---------|
| `inter_session_request` | "I need information from you" | A asks B, B responds via inbox |
| `inter_session_delegate` | "Take over this work and report back" | A delegates to B, B completes and sends done/error |
| `inter_session_consult` | "Review this specific thing" | A asks B for opinion, B responds |
| `inter_session_done` | "Task complete, here's my output" | Response to delegate |
| `inter_session_error` | "Something went wrong processing your message" | Error response |

---

## Modified Components

### 5. Brain Extension (SYSTEM.md)

Current Brain routes messages between agents within one session. Extended Brain also:
- Detects `inter_session_*` message types
- Instead of routing to a local agent, writes to the outbox for the target session
- Validates the target session exists in the registry
- Returns a correlation ID to the sending agent so it can wait for response

**New routing logic:**
```
Agent sends inter_session message
    ↓
Brain validates message structure
    ↓
Brain checks session registry for target session
    ↓
If target alive → write message to .brain/session-bus/outbox/{target}/
If target dead → return error "session not found"
    ↓
Brain returns correlation ID to sending agent
    ↓
Sending agent can poll for response via ORCHESTRATOR
```

### 6. CLAUDE.md Updates

- Add ORCHESTRATOR to agent directory table
- Add Phase 0: Session Init (runs before every request)
- Add new inter-session message types to the protocol section
- Update VERSION header and footer to v1.2
- Update rules section with inter-session rules

### 7. New Rules

- **R32** — Session identity required. Every session must register before sending messages.
- **R33** — Heartbeat obligation. Every session must maintain its heartbeat.
- **R34** — Message idempotency. Inter-session messages must be idempotent (safe to replay).
- **R35** — No cross-session circular delegation. A→B→A is detected and rejected.

### 8. .gitignore Update

Add ephemeral session data:
```
.brain/session-bus/
.brain/sessions/live/
```

---

## Communication Patterns

### Pattern 1: Synchronous Delegate

```
Session A (PLANNER needs tests written)
    │
    ├─► ORCHESTRATOR_A: "Find a TESTER session"
    │     ├── Check .brain/sessions/live/ for sessions with role=tester
    │     └── Found: Session B (role=tester)
    │
    ├─► ORCHESTRATOR_A: "Delegate test generation to Session B"
    │     ├── Write message to .brain/session-bus/outbox/{session_B_uuid}/
    │     └── Return correlationId to local PLANNER
    │
    ├─► ORCHESTRATOR_A polls for response (every 30s)
    │     └── Checks .brain/session-bus/inbox/{session_A_uuid}/{correlationId}
    │
Session B (ORCHESTRATOR_B polls inbox)
    │
    ├─► ORCHESTRATOR_B: "Incoming delegate — routing to local TESTER"
    ├─► TESTER generates tests
    ├─► ORCHESTRATOR_B writes response to Session A's inbox
    │
Session A (receives response)
    ├─► PLANNER gets test results
    └─► Continues execution
```

### Pattern 2: Broadcast

```
Session A wants all sessions to know about a security vulnerability
    │
    ├─► ORCHESTRATOR_A reads .brain/sessions/live/ → finds 3 live sessions
    ├─► ORCHESTRATOR_A writes to each session's outbox
    └─► Each session processes independently
```

### Pattern 3: Async Fire-and-Forget

```
Session A: "Update the shared memory — I just finished a task"
    │
    └─► Writes to .brain/ (shared) — other sessions see it on next memory read
        No message needed — shared filesystem handles this
```

---

## Session Roles (Optional — Phase 1 Supports Roles)

| Role | Active Agents | Description |
|------|---------------|-------------|
| `gateway` | PLANNER, ORCHESTRATOR | User-facing entry point, delegates work outward |
| `builder` | EXECUTOR, TESTER, CLEAN CODE | Heavy code generation |
| `reviewer` | REVIEWER, SECURITY, BACKEND QA | Deep audits and code review |
| `general` | All 15 agents | Full OS, can do anything |

---

## Implementation Order

### Phase 0: Foundation (Files 1-6)

1. Create `.brain/agents/ORCHESTRATOR.md` — Agent definition with schema
2. Create `.brain/brain/INTER_SESSION.md` — Cross-session protocol documentation
3. Create `.brain/session-bus/` and `.brain/sessions/` directories with README
4. Update `.brain/brain/SYSTEM.md` — Extended routing logic
5. Update `.brain/brain/RULES.md` — New rules R32-R35
6. Update `.brain/brain/LIMITATIONS.md` — Update limitation #8

### Phase 1: Core Integration (Files 7-10)

7. Update `CLAUDE.md` — Add ORCHESTRATOR, inter-session phases, version bump
8. Update `.gitignore` — Add session-bus/ and sessions/live/
9. Update `VERSION` — Bump to v1.2
10. Update `.brain/brain/MEMORY_SYSTEM.md` — Add session-bus to memory layout

### Phase 2: Scripting (Files 11-12)

11. Create session lifecycle script (entry point for session init)
12. Create message polling mechanism (ORCHESTRATOR loop)

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| File contention under high message volume | Medium | Advisory file locking (flock); move to Redis if needed |
| Zombie sessions in registry | High | Aggressive TTL (120s), cleanup on every poll |
| Cross-session deadlock (A waits for B, B waits for A) | Low | Correlation IDs + timeout per message TTL |
| Claude context limit with polling | Medium | ORCHESTRATOR runs in background agent, not main loop |
| Message ordering race conditions | Low | Design messages to be idempotent; timestamp-based ordering |
| Model lock violation across sessions | Low | Every session validates model on startup |

---

## Files to Create/Modify (Summary)

| Action | File | Purpose |
|--------|------|---------|
| Create | `.brain/agents/ORCHESTRATOR.md` | New agent definition |
| Create | `.brain/brain/INTER_SESSION.md` | Cross-session protocol docs |
| Create | `.brain/session-bus/README.md` | Bus protocol spec |
| Create | `.brain/sessions/README.md` | Registry protocol spec |
| Modify | `.brain/brain/SYSTEM.md` | Extended routing + message types |
| Modify | `.brain/brain/RULES.md` | Add R32-R35 |
| Modify | `.brain/brain/LIMITATIONS.md` | Update persistent processes limitation |
| Modify | `.brain/brain/MEMORY_SYSTEM.md` | Add session-bus to layout |
| Modify | `CLAUDE.md` | Add ORCHESTRATOR, inter-session phases |
| Modify | `.gitignore` | Add ephemeral session data |
| Modify | `VERSION` | Bump to v1.2 |
