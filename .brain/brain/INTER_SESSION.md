# Inter-Session Communication Protocol

> Defines how multiple RAI-Engineering sessions discover, message, and delegate to each other.
> Protocol version: 1.0
> Model lock: deepseek-v4-flash (enforced per-message validation)

---

## Overview

Each RAI-Engineering session runs in its own Claude conversation. Normally these sessions are isolated — they share `.brain/` memory but cannot communicate in real time.

The Inter-Session Protocol bridges this gap. Sessions register in a shared registry, send messages through a file-based bus, and route incoming work to their local agents.

```
Session A                    Session B                    Session C
   │                            │                            │
   ├── Register ───────────────►├── Register ───────────────►├── Register
   ├── Write msg to B ─────────►├── Poll inbox ──────────────┤
   │                            ├── Process msg              │
   │◄─── Write response ────────┤                            │
   ├── Poll for response ───────┤                            │
   │                            ├── Broadcast to all ────────►├── Process
   │◄───────────────────────────┤◄───────────────────────────┤
```

---

## Components

### 1. Session Identity

Every session has a persistent identity stored in `.brain/sessions/identity.json`:

```json
{
  "sessionId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "builder-west",
  "role": "builder",
  "capabilities": ["execute", "test", "clean_code"],
  "createdAt": "2026-07-19T12:00:00Z",
  "model": "deepseek-v4-flash"
}
```

The identity file is created on first session init and reused on subsequent runs. It is **not** gitignored — a session's identity persists across conversations.

### 2. Session Registry

Live sessions register in `.brain/sessions/live/{sessionId}.json`:

```json
{
  "sessionId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "builder-west",
  "role": "builder",
  "status": "alive",
  "startedAt": "2026-07-19T12:00:00Z",
  "lastHeartbeat": "2026-07-19T12:05:00Z",
  "model": "deepseek-v4-flash"
}
```

**TTL:** Sessions are considered dead if `lastHeartbeat` is more than 120 seconds old. ORCHESTRATOR agents clean stale entries during their poll cycle.

### 3. Message Bus

Messages travel through `.brain/session-bus/`:

```
.brain/session-bus/
├── inbox/
│   └── {target-session-id}/
│       ├── {timestamp}--{message-id}.json   ← incoming messages
│       └── ...
└── archive/
    └── {timestamp}--{from}--{to}--{message-id}.json  ← processed messages
```

---

## Message Format

Every inter-session message follows this structure:

```json
{
  "from": "session_A::agent_name",
  "to": "session_B::agent_name",
  "type": "inter_session_request | inter_session_delegate | inter_session_consult | inter_session_done | inter_session_error",
  "messageId": "uuid",
  "correlationId": "uuid",
  "timestamp": "2026-07-19T12:00:00Z",
  "ttl": "2026-07-19T13:00:00Z",
  "session": "<sender_session_uuid>",
  "context": {
    "task": "Description of the work",
    "plan": "reference to plan if applicable",
    "files": ["affected/file/path"],
    "originSession": "sender-uuid",
    "targetAgent": "executor | tester | reviewer | archivist"
  },
  "payload": { }
}
```

### Field Descriptions

| Field | Required | Description |
|-------|----------|-------------|
| `from` | Yes | Sender in `sessionId::agentName` format |
| `to` | Yes | Recipient in `sessionId::agentName` format |
| `type` | Yes | One of the 5 inter-session types |
| `messageId` | Yes | UUIDv4, globally unique per message |
| `correlationId` | Yes | Shared between request and response — used for matching |
| `timestamp` | Yes | ISO 8601 UTC |
| `ttl` | No | ISO 8601 UTC — if set, messages past this are dropped |
| `session` | Yes | Sender's session UUID |
| `context.task` | Yes | Human-readable task description |
| `context.files` | No | Array of affected file paths |
| `payload` | Yes | The actual data being sent |
| `context.targetAgent` | No | Hint for routing to a specific local agent |

---

## Message Types

### inter_session_request

Ask another session for information.

```
from: session_A::planner
to: session_B::archivist
type: inter_session_request
payload: {
  "query": "What is the current auth schema?",
  "scope": ["database", "middleware"]
}
```

**Expected response:** `inter_session_done` with payload containing the answer.

### inter_session_delegate

Assign work to another session.

```
from: session_A::planner
to: session_B::executor
type: inter_session_delegate
payload: {
  "goal": "Generate tests for UserController",
  "specs": { "endpoints": ["GET /users", "POST /users"] },
  "constraints": { "testFramework": "pest", "coverage": "100%" }
}
```

**Expected response:** `inter_session_done` with payload containing results, or `inter_session_error` on failure.

### inter_session_consult

Ask another session for an opinion or review.

```
from: session_A::reviewer
to: session_B::reviewer
type: inter_session_consult
payload: {
  "files": ["app/Http/Controllers/UserController.php"],
  "concern": "This auth logic looks fragile — second opinion?",
  "score": 6
}
```

**Expected response:** `inter_session_done` with the consulted session's assessment.

### inter_session_done

Response to any of the above. Carries the result of the work.

```
from: session_B::executor
to: session_A::planner
type: inter_session_done
correlationId: <matches the original request>
payload: {
  "result": "success | failure",
  "filesChanged": ["tests/Feature/UserControllerTest.php"],
  "testResults": { "passed": 12, "failed": 0 },
  "summary": "Generated 12 tests for UserController"
}
```

### inter_session_error

Something went wrong processing a message.

```
from: session_B::orchestrator
to: session_A::orchestrator
type: inter_session_error
correlationId: <matches the original request>
payload: {
  "error": "Target agent not available in this session",
  "originalMessageId": "msg-uuid",
  "suggestion": "Try session_C which has a tester role"
}
```

---

## Communication Patterns

### Synchronous Delegate (Wait for Response)

1. Session A ORCHESTRATOR writes message to Session B's outbox
2. Session A ORCHESTRATOR starts polling its own inbox for the correlationId
3. Session B ORCHESTRATOR picks up the message on its next poll cycle
4. Session B routes to local agent, processes, writes response to Session A's inbox
5. Session A ORCHESTRATOR finds the response, delivers to waiting agent

**Timeout:** If `ttl` is exceeded, Session A ORCHESTRATOR cancels the wait and returns a timeout error.

### Async Fire-and-Forget

1. Session A writes message to Session B's outbox
2. Session A continues processing — does not wait for response
3. Session B processes when it polls next

### Broadcast

1. Session A ORCHESTRATOR reads all live sessions from registry
2. For each session, writes the same message to their outbox
3. Each session processes independently

### Round-Robin Delegate

1. Session A ORCHESTRATOR reads all live sessions with a specific role
2. Picks one (round-robin, or least-recently-used)
3. Delegates to the chosen session

---

## Peer Discovery

The ORCHESTRATOR discovers peers by reading `.brain/sessions/live/`:

```
ORCHESTRATOR.poll_peers():
    live_sessions = read_all(".brain/sessions/live/*.json")
    for session in live_sessions:
        if session.lastHeartbeat < (now - 120s):
            delete(session.file)  # stale
        else:
            add_to_peers(session)
    remove_stale_peers()
    return peer_list
```

---

## Message Flow Diagram

```
┌──────────────────┐                     ┌──────────────────┐
│   Session A      │                     │   Session B      │
│                  │                     │                  │
│ Agent X needs    │                     │                  │
│ info from B      │                     │                  │
│       │          │                     │                  │
│       ▼          │                     │                  │
│ ORCHESTRATOR_A   │                     │                  │
│  generates msg   │                     │                  │
│  with correlationId                     │                  │
│       │          │                     │                  │
│       ▼          │                     │                  │
│ Write to outbox  │                     │                  │
│ → B's inbox      │────────────────────>│ Inbox receives   │
│       │          │                     │       │          │
│       ▼          │                     │       ▼          │
│ Poll own inbox   │                     │ ORCHESTRATOR_B   │
│ for correlationId│                     │  reads message   │
│       │          │                     │       │          │
│       │          │                     │       ▼          │
│       │          │                     │ Route to Agent Y │
│       │          │                     │       │          │
│       │          │                     │       ▼          │
│       │          │                     │ Agent Y processes│
│       │          │                     │       │          │
│       │          │                     │       ▼          │
│       │          │                     │ ORCHESTRATOR_B   │
│       │          │                     │  writes response │
│       │          │◄────────────────────│  → A's inbox     │
│       ▼          │                     │                  │
│ Response found   │                     │                  │
│ Deliver to Agent X                    │                  │
│       │          │                     │                  │
│       ▼          │                     │                  │
│ Agent X continues│                     │                  │
└──────────────────┘                     └──────────────────┘
```

---

## Validation Rules

| Check | Failure Action |
|-------|---------------|
| `from` format is `sessionId::agentName` | Reject message, return error |
| `to` format is `sessionId::agentName` | Reject message, return error |
| `type` is a valid inter-session type | Reject, return error |
| `messageId` is a valid UUID | Reject, return error |
| `correlationId` is present | Reject, return error |
| Target session exists in registry | Return error to sender |
| Target session heartbeat is fresh | Queue message (session may come back) |
| Model is deepseek-v4-flash | Reject with model lock violation |
| Message TTL not expired | Drop silently if expired |

---

## Security Considerations

1. **No authentication between sessions.** The protocol trusts that any process writing to `.brain/session-bus/` is a valid session. Add auth if deploying across machines.
2. **No encryption.** Messages are plain JSON. Do not send secrets, passwords, or API keys through the bus.
3. **Message integrity.** Validate message schema on every read. Malformed messages are dropped with an error response.
4. **Denial of service.** A session that floods the bus with messages can be rate-limited by ORCHESTRATOR (max 10 messages per poll cycle per sender).
5. **Model lock enforcement.** Every inter-session message validates that the sender's registered model is `deepseek-v4-flash`. Messages from unregistered or incorrect-model sessions are rejected.
