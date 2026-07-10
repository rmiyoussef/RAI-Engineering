# Rules

These are hard rules. Every agent must follow them. The Brain enforces them.

---

## Execution Rules

### R1 — Plan First
Before writing any code, produce a plan. The plan must include:
- Goal of the task
- Files that will be affected (or created)
- Risks and assumptions
- Dependencies (what must exist first)
- Execution steps in order
- Open questions (if any)

**Violation:** The Brain rejects any execution that has no corresponding plan in memory.

### R2 — Review Before Accepting
Every code change must be reviewed before it is considered complete. The reviewer must check for:
- Correctness (does it work?)
- Performance (will it scale?)
- Security (is it safe?)
- Style (does it match project conventions?)
- Test coverage (is it tested?)

**Violation:** Code is not merged or committed without a passing review.

### R3 — Everything Is Tested
Every change must include or update tests. If tests don't exist for the area being changed, create them.

**Violation:** The pipeline blocks on missing tests.

### R4 — Memory Is Written After Every Session
After any significant work:
1. Write the architectural decision to `memory/decisions/`
2. Write session summary to `memory/sessions/`
3. Write lessons learned to `memory/lessons/`
4. Update architecture map if structure changed

**Violation:** The Brain considers the session incomplete if memory was not updated.

### R5 — No Repository-Specific Content in OS Files
Skills, agents, rules, and brain files in AI-Engineering-OS must never reference:
- Specific project names (BenchHR, Acme, etc.)
- Specific business logic
- Specific domain terms

That content belongs in the project's `memory/` directory.

**Violation:** File is rejected and must be refactored.

### R6 — Structured Output Only
Every agent must return its response in the schema defined in its agent file. Free-form output is not accepted.

**Violation:** The Brain rejects the response and asks the agent to retry with correct schema.

### R7 — No Circular Delegation
Agent A cannot call Agent A. Agent A cannot call Agent B if Agent B calls Agent A (directly or through a chain).

**Violation:** The routing is rejected and the Brain returns an error.

### R8 — Memory Reads Before Writes
Before planning or executing, load relevant memory. Check:
- Past decisions about the same area
- Architecture map: relevant components
- Lessons learned: known pitfalls in this area

**Violation:** The Planner must justify why memory was not consulted.

### R9 — Model Lock
All agents, all skills, all brain operations use `deepseek-v4-flash`. No other model may be invoked.

**Violation:** The agent invocation is rejected.

### R10 — One Responsibility Per File
If a file has two separable concerns, it must be split.

**Violation:** The file is rejected by review until split.

---

## Mesh Communication Rules

### R11 — Agents Ask for Help, They Don't Guess
If an agent is unsure about something another agent knows, it must ask. Guessing is a violation.
- PLANNER unsure about architecture? Call ARCHIVIST.
- EXECUTOR unsure about a query? Call BACKEND QA.
- REVIEWER unsure about test coverage? Call TESTER.

**Violation:** The Brain flags the issue: "You should have consulted [agent] for [reason]."

### R12 — Consult Before Committing
If an agent is about to make a decision that affects another agent's domain, it should consult that agent *before* committing.
- PLANNER designing a database schema? Consult BACKEND QA first.
- EXECUTOR writing a complex algorithm? Consult CLEAN CODE mid-write.
- REVIEWER scoring low on tests? Consult TESTER before flagging.

**Violation:** Work is rejected and the consultation must happen retroactively.

### R13 — Delegate, Don't Duplicate
If a subtask belongs to another agent's domain, delegate it. Don't do it yourself poorly.
- Need tests? Delegate to TESTER.
- Need refactoring? Delegate to CLEAN CODE.
- Need security audit? Delegate to BACKEND QA.

**Violation:** The Brain rejects: "This task belongs to [agent], not you."

### R14 — Escalate After 3 Failed Attempts
If an agent fails the same task 3 times, it must escalate to the user. It can't keep trying the same approach.

**Violation:** The Brain forces escalation.

### R15 — One Message at a Time
An agent sends one message, waits for the response, then continues. No parallel conversations. If an agent needs multiple pieces of information, it requests them sequentially.

**Violation:** The Brain rejects concurrent messages from the same agent.

### R16 — Message Protocol Compliance
Every agent-to-agent message must follow the Message Protocol defined in `brain/SYSTEM.md`. Messages missing required fields are rejected.

**Violation:** The Brain returns validation error to the sender.
