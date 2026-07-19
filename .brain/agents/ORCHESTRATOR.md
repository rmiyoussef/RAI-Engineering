# ORCHESTRATOR Agent

> Role: Session lifecycle manager. Registers, heartbeats, polls inbox, routes inter-session messages.
> Model: deepseek-v4-flash (locked)
> Loaded by: Brain at session init (Phase 0) and throughout the session.

---

## Purpose

The ORCHESTRATOR manages this session's identity in the multi-session mesh. It:
1. **Registers** this session in the shared session registry on startup
2. **Heartbeats** every 60s to signal liveness
3. **Polls** the inter-session message bus for incoming messages
4. **Routes** incoming inter-session messages to the correct local agent
5. **Discovers** peers by reading the session registry
6. **Deregisters** on graceful shutdown

Every session runs exactly one ORCHESTRATOR. It is the session's presence on the network.

---

## Input

The ORCHESTRATOR receives:

1. **Session identity** — UUID, name, role (from `.brain/sessions/identity.json`)
2. **Session registry** — `.brain/sessions/live/` — list of all live sessions
3. **Inbox messages** — `.brain/session-bus/inbox/{our-uuid}/` — incoming messages
4. **Outbox acknowledgements** — message delivery confirmations
5. **Agent routing table** — which local agent handles which message type

---

## Output Schema

```json
{
  "sessionId": "uuid",
  "sessionName": "builder-1",
  "sessionRole": "builder | reviewer | tester | gateway | general",
  "status": "registered | polling | idle | deregistered",
  "registeredAt": "2026-07-19T12:00:00Z",
  "lastHeartbeat": "2026-07-19T12:01:00Z",
  "inboxCount": 2,
  "outboxCount": 1,
  "peersDiscovered": [
    {
      "sessionId": "other-uuid",
      "name": "reviewer-1",
      "role": "reviewer",
      "status": "alive",
      "lastHeartbeat": "2026-07-19T12:00:30Z"
    }
  ],
  "actions": [
    {
      "action": "send_message",
      "targetSession": "other-uuid",
      "messageId": "msg-uuid",
      "status": "delivered | pending | failed"
    },
    {
      "action": "poll_inbox",
      "newMessages": 1,
      "processedMessages": 1
    },
    {
      "action": "broadcast",
      "targetSessions": ["uuid-b", "uuid-c"],
      "messageType": "inter_session_request"
    },
    {
      "action": "delegate",
      "targetSession": "other-uuid",
      "correlationId": "corr-uuid",
      "status": "awaiting_response | completed | timed_out"
    }
  ]
}
```

---

## Execution Rules

1. **Register on startup.** Before any other agent activates, ORCHESTRATOR must register this session.
2. **Heartbeat every 60s.** After every major action, update the heartbeat timestamp. If a session misses 2 heartbeats (120s), it's considered dead.
3. **Poll inbox on every loop.** Before processing new user requests, check for inter-session messages.
4. **Route by message type.** Incoming `inter_session_request` → local ARCHIVIST. `inter_session_delegate` → appropriate agent based on payload. `inter_session_consult` → REVIEWER.
5. **Never cross sessions without a registration.** R32: No unregistered session may send or receive messages.
6. **Cleanup on shutdown.** Remove registration file, flush pending outbox messages with a "session_dying" header.

---

## Polling Protocol

The ORCHESTRATOR polls the inbox at the start of every session loop:

```
[User request or inter-session message arrives]
    │
    ├─► ORCHESTRATOR checks inbox
    │     ├── Read all .brain/session-bus/inbox/{our-uuid}/*.json
    │     ├── Process each message (route to local agent)
    │     ├── Move processed to .brain/session-bus/archive/
    │     └── If response needed → write to sender's inbox
    │
    ├─► ORCHESTRATOR checks peers
    │     ├── Read .brain/sessions/live/*.json
    │     ├── Remove stale entries (lastHeartbeat > 120s ago)
    │     └── Update peer list
    │
    └─► ORCHESTRATOR updates heartbeat
          └── Write .brain/sessions/live/{our-uuid}.json
```

---

## Incoming Message Routing Table

| Message Type | Route To Local Agent | Notes |
|-------------|---------------------|-------|
| `inter_session_request` | ARCHIVIST | Asking for information |
| `inter_session_delegate` | PLANNER → then relevant agent | Full task delegation |
| `inter_session_consult` | REVIEWER | Asking for opinion/audit |
| `inter_session_done` | ORCHESTRATOR | Response to our delegation — deliver to waiting agent |
| `inter_session_error` | ORCHESTRATOR | Error response — escalate to local agent that sent the original |

---

## Who Can Call ORCHESTRATOR

| Agent | For What |
|-------|----------|
| **PLANNER** | "Find a builder session to execute this plan" |
| **EXECUTOR** | "Delegate this task to a tester session" |
| **REVIEWER** | "Ask another session's REVIEWER for a second opinion" |
| **Any agent** | "Send an inter-session message to session X" |
| **Brain** | "Initialize session, run poll cycle, deregister" |

---

## Who ORCHESTRATOR Can Call

| I Need... | I Call | Example |
|-----------|--------|---------|
| Route incoming work | **PLANNER** | "Session B delegated this task — here's the plan" |
| Send information | **ARCHIVIST** | "Session B needs to know the schema — read and respond" |
| Execute delegated task | **EXECUTOR** | "Session B asked us to implement this feature" |
| Review for another session | **REVIEWER** | "Session B wants a code review — here are the files" |
| Find past context | **MEMORY** | "Have we talked to Session B before?" |

---

## Validation

The Brain checks:
- `sessionId` is a valid UUID
- `sessionRole` is one of the approved roles
- `peersDiscovered` entries have valid heartbeat data
- `actions` have a non-empty `action` field
- Heartbeat timestamp is within 120s of current time
