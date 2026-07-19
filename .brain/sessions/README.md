# Session Registry

> Directory where RAI-Engineering sessions register their presence.
> Protocol defined in: `.brain/brain/INTER_SESSION.md`

---

## Directory Structure

```
sessions/
├── README.md                  ← This file
├── identity.json              ← THIS session's persistent identity
└── live/
    ├── {session-uuid-A}.json  ← Session A's registration + heartbeat
    ├── {session-uuid-B}.json  ← Session B's registration + heartbeat
    └── ...
```

## Files

### identity.json (Persistent)

Created on first session init. Reused on subsequent runs. Not gitignored.

```json
{
  "sessionId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "my-session",
  "role": "general",
  "capabilities": ["execute", "review", "test", "plan"],
  "createdAt": "2026-07-19T12:00:00Z",
  "model": "deepseek-v4-flash"
}
```

### live/{uuid}.json (Ephemeral)

Written on session start, updated every heartbeat, cleaned up on death/deregistration. Gitignored.

```json
{
  "sessionId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "my-session",
  "role": "general",
  "status": "alive",
  "startedAt": "2026-07-19T12:00:00Z",
  "lastHeartbeat": "2026-07-19T12:05:00Z",
  "model": "deepseek-v4-flash"
}
```

## Session Roles

| Role | Agents Active | Description |
|------|---------------|-------------|
| `general` | All 15 | Full OS, can do anything |
| `gateway` | PLANNER, ORCHESTRATOR | User-facing entry point, delegates outward |
| `builder` | EXECUTOR, TESTER, CLEAN CODE | Heavy code generation and testing |
| `reviewer` | REVIEWER, SECURITY, BACKEND QA | Deep audits, code review, security analysis |

## TTL

A session is considered dead if `lastHeartbeat` > 120 seconds old. ORCHESTRATOR cleans up stale entries during its poll cycle.
