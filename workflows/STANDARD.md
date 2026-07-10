# Standard Development Workflow — Agent Mesh

> There is no fixed pipeline. Agents talk to each other through the Brain.
> This document shows how the conversation typically flows, not a rigid sequence.

---

## Overview

```
User gives task
    │
    ▼
┌────────────────────────────────────────────────────────────┐
│                    BRAIN (message broker)                   │
│  Routes messages between agents, validates every message,  │
│  persists decisions to memory, escalates when needed       │
└────────────────────────────────────────────────────────────┘
    │
    ▼
                        ┌─────────────┐
                  ┌────►│  ARCHIVIST  │◄────┐
                  │     └─────────────┘     │
                  │                         │
            ┌─────┴─────┐           ┌───────┴──────┐
            │  PLANNER   │◄────────►│   EXECUTOR   │
            └─────┬─────┘           └──────┬───────┘
                  │                        │
            ┌─────┴─────┐           ┌──────┴───────┐
            │  REVIEWER │◄────────►│  BACKEND QA  │
            └─────┬─────┘           └──────┬───────┘
                  │                        │
            ┌─────┴─────┐           ┌──────┴───────┐
            │   TESTER  │◄────────►│  CLEAN CODE  │
            └─────┬─────┘           └──────────────┘
                  │
            ┌─────┴─────┐
            │   MEMORY  │
            │   SCRIBE  │
            └───────────┘
                  │
            ┌─────┴─────┐
            │   GITHUB  │
            └───────────┘
```

---

## How the Conversation Unfolds

This is not a pipeline. This is what a typical conversation looks like:

### Phase 1: Initiation

```
USER: "Add user authentication with JWT"

  BRAIN loads context:
  ├── brain/MISSION.md, PRINCIPLES.md, RULES.md, LIMITATIONS.md
  ├── brain/SYSTEM.md (message broker protocol)
  └── project memory/ (if exists)

  BRAIN: "Let me start with planning."
  ── routes to PLANNER ──
```

### Phase 2: Planning (PLANNER leads)

```
PLANNER starts working on the plan.

  PLANNER: "I need to understand the current auth setup."
  ── request → BRAIN → ARCHIVIST ──

  ARCHIVIST: "The project has User model with email/password.
              No existing auth system. No JWT package installed."
  ── response → BRAIN → PLANNER ──

  PLANNER: "What past decisions exist about auth?"
  ── request → BRAIN → MEMORY (if project memory exists) ──

  MEMORY: "No past decisions about auth found."

  PLANNER: "Let me check if this design approach is sound."
  ── consult → BRAIN → REVIEWER ──

  REVIEWER: "Service layer approach is good. Use DTOs for registration data."
  ── response → BRAIN → PLANNER ──

  PLANNER produces the plan:
  ├── Goal: Implement JWT authentication
  ├── Files: AuthController, AuthService, JwtService, LoginRequest, RegisterRequest
  ├── Risks: Token storage, refresh token rotation
  ├── Dependencies: tymon/jwt-auth package
  └── Plan: Install package → create DTOs → service → controller → routes → tests

  BRAIN validates the plan schema.
  BRAIN presents to user for approval.
  BRAIN writes decision to memory/decisions/.
```

### Phase 3: Execution (EXECUTOR leads)

```
User approves.

  BRAIN: "Plan approved. Starting execution."
  ── routes to EXECUTOR ──

  EXECUTOR starts building.

  EXECUTOR: "I need to see the User model before I extend it."
  ── request → BRAIN → ARCHIVIST ──

  ARCHIVIST: "User model: id, name, email, password, role, timestamps.
              Located at app/Models/User.php."
  ── response → BRAIN → EXECUTOR ──

  EXECUTOR writes AuthService.

  EXECUTOR: "I'm about to write a complex query to find users by role
             with their posts. Review this approach before I continue."
  ── consult → BRAIN → BACKEND QA ──

  BACKEND QA: "Use scoped query with eager loading. Here's the pattern."
  ── response → BRAIN → EXECUTOR ──

  EXECUTOR writes the query correctly the first time.

  EXECUTOR: "I need tests for AuthService (register, login, refresh)."
  ── delegate → BRAIN → TESTER ──

  TESTER generates tests:
  ├── tests/Unit/Services/AuthServiceTest.php
  ├── tests/Feature/Auth/RegistrationTest.php
  └── tests/Feature/Auth/LoginTest.php

  TESTER: "Tests generated. Covering: happy path, duplicate email,
            invalid credentials, token expiration."
  ── done → BRAIN → EXECUTOR ──

  EXECUTOR: "This controller is getting heavy. Can you refactor it?"
  ── delegate → BRAIN → CLEAN CODE ──

  CLEAN CODE extracts service layer from controller.
  ├── Controller went from 120 lines → 25 lines
  └── Service layer created at app/Services/Auth/RegistrationService.php

  CLEAN CODE: "Refactored. Controller now delegates to service.
               Quality score: 9/10."
  ── done → BRAIN → EXECUTOR ──

  EXECUTOR reports completion:
  ├── Files changed: 8
  ├── Tests: 24 pass, 0 fail
  └── Status: success
```

### Phase 4: Review (REVIEWER leads)

```
  BRAIN: "Code written. Starting review."
  ── routes to REVIEWER ──

  REVIEWER examines all changes.

  REVIEWER: "I see JWT token handling — verify this is secure."
  ── consult → BRAIN → BACKEND QA ──

  BACKEND QA audits the auth code:
  ├── Clean Code: Pass
  ├── Query Optimization: Pass (no queries in auth flow)
  ├── Security: Conditional pass — token not blacklisted on logout
  └── Testing: Adequate

  BACKEND QA: "One issue: no token blacklist on logout.
               Suggest adding token invalidation."
  ── response → BRAIN → REVIEWER ──

  REVIEWER: "Fix the token blacklist issue."
  ── delegate → BRAIN → EXECUTOR ──

  EXECUTOR adds token blacklist to logout flow.

  REVIEWER: "Tests look thin on edge cases. Generate more."
  ── delegate → BRAIN → TESTER ──

  TESTER adds: expired token test, malformed token test, refresh token test.

  REVIEWER re-scores:
  ├── Issues: 1 minor (add logging)
  ├── Performance: Good
  ├── Security: Good
  └── Score: 9/10

  BRAIN: "Score 9/10. Passing."
```

### Phase 5: Backend Audit (BACKEND QA leads, if applicable)

```
  BRAIN: "Backend code changed. Running backend audit."
  ── routes to BACKEND QA ──

  BACKEND QA audits all backend files.

  BACKEND QA: "Clean Code dimension needs work — AuthController has
               registration validation inline."
  ── delegate → BRAIN → CLEAN CODE ──

  CLEAN CODE extracts validation to RegisterRequest form request.

  BACKEND QA: "Testing dimension missing token refresh test."
  ── delegate → BRAIN → TESTER ──

  TESTER generates refresh token test.

  BACKEND QA final report:
  ├── Clean Code: Pass
  ├── Query Optimization: Pass
  ├── Security: Pass
  └── Testing: Pass
  ├── Overall: PASS
```

### Phase 6: Testing (TESTER leads)

```
  BRAIN: "Running final test suite."
  ── routes to TESTER ──

  TESTER runs all tests:
  ├── 28 passed
  ├── 0 failed
  ├── 1 skipped (mailhog not running)
  └── Coverage: 92%

  TESTER: "All tests pass. Coverage adequate."
  ── done → BRAIN ──
```

### Phase 7: Memory (MEMORY SCRIBE leads)

```
  BRAIN: "Persisting to memory."
  ── routes to MEMORY SCRIBE ──

  MEMORY SCRIBE gathers data:

  MEMORY SCRIBE: "What was the plan?"
  ── request → BRAIN → PLANNER ──

  PLANNER: "Goal: Implement JWT authentication. Files: 8 changed."
  ── response → BRAIN → MEMORY SCRIBE ──

  MEMORY SCRIBE: "What was the outcome?"
  ── request → BRAIN → REVIEWER ──

  REVIEWER: "Score 9/10. One minor issue: add logging."
  ── response → BRAIN → MEMORY SCRIBE ──

  MEMORY SCRIBE writes:
  ├── decisions/2026-07-10-jwt-authentication.md
  ├── lessons/2026-07-10-token-blacklist-logout.md
  ├── architecture/auth-system.md (updated)
  └── sessions/2026-07-10-jwt-auth-implementation.md
```

### Phase 8: GitHub (GITHUB leads, if requested)

```
  BRAIN: "User requested GitHub PR."
  ── routes to GITHUB ──

  GITHUB: "What changed and what was the review outcome?"
  ── request → BRAIN → EXECUTOR → REVIEWER ──

  GITHUB creates:
  ├── Branch: feat/jwt-authentication
  ├── Commits: 3 conventional commits
  └── PR: Full body with what/why/how/testing/review score
```

### Phase 9: Response

```
  BRAIN summarizes for user:
  ├── What: JWT authentication implemented
  ├── Files: 8 created/modified
  ├── Review: 9/10
  ├── Tests: 28 pass, 92% coverage
  ├── Memory: 3 entries created
  └── Agent interactions: 14 messages between 7 agents
```

---

## Key Principles of the Mesh Workflow

1. **Agents drive the conversation.** PLANNER decides when it needs architecture info. EXECUTOR decides when it needs a query review. REVIEWER decides when it needs security verification.
2. **The Brain doesn't force handoffs.** It validates and routes. The agents decide the flow.
3. **Fix loops are collaborative.** REVIEWER might call BACKEND QA, TESTER, and CLEAN CODE in parallel within the same fix cycle.
4. **No pipeline stages.** There's no "step 3" that must happen before "step 4". EXECUTOR can call CLEAN CODE mid-write while REVIEWER hasn't started yet.
5. **Memory is always consulting.** ARCHIVIST and MEMORY are available at any point for any agent.
