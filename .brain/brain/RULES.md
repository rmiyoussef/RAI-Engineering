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
Every change must include or update tests. If tests don't exist for the area being changed, create them. If no test template exists for the feature, TESTER asks the user to create one first. Business flows use `.brain/templates/testing/` templates. (Consolidated: this replaces former R28 — template-led testing is part of the same rule.)

**Violation:** The pipeline blocks on missing tests.

### R4 — Memory Is Written After Every Session
After any significant work:
1. Write the architectural decision to `memory/decisions/`
2. Write session summary to `memory/sessions/`
3. Write lessons learned to `memory/lessons/`
4. Update architecture map if structure changed

**Violation:** The Brain considers the session incomplete if memory was not updated.

### R5 — No Repository-Specific Content in OS Files
Skills, agents, rules, and brain files in RAI-Engineering must never reference:
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

### R9 — Model Lock (Default)
By default, all agents run on `deepseek-v4-flash`. When a `.brain/config.yaml` model_tiers config exists, agents route to their tier-assigned model. See CLAUDE.md Model Tiering Protocol section.

**Violation:** A model change without matching config is rejected.

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

---

## Memory & Guidelines Rules

### R17 — Always Read Guidelines First
Before any planning or execution, read `memory/guidelines.md`. If it doesn't exist, call ARCHITECT to create it from project analysis. The guidelines define the project's patterns, conventions, and structure.

**Violation:** The BRAIN must justify why guidelines were not consulted.

### R18 — Always Read Memory Before Writing
Before making any decision or writing any code, check existing memory:
- Check `memory/INDEX.md` for relevant entries
- Check `memory/decisions/` for past decisions about this area
- Check `memory/lessons/` for known pitfalls
- Check `memory/architecture/` for current system map

**Violation:** The agent's output is rejected until memory is consulted.

### R19 — Update Guidelines When Architecture Changes
If a task introduces a new pattern, command, middleware, convention, or technology, ARCHITECT must update `memory/guidelines.md` to reflect the change. The guidelines must always represent the current state of the project.

**Violation:** MEMORY SCRIBE flags the session as incomplete.

### R20 — Never Push Connection Info to Git
The `memory/connections/` directory contains database schema and connection information. It must never be committed to Git. The `.gitignore` must include `memory/connections/`. The DATABASE agent must verify this before writing any connection file.

**Violation:** Git Safety is triggered. The commit is blocked.

---

## User Approval Rules

### R21 — Always Ask Before Changing or Deleting Anything

You must **always ask for explicit approval** before any of these actions. Two modes available (see CLAUDE.md Approval Protocol):

| Mode | When | Format |
|------|------|--------|
| **Full** (default) | Database changes, destructive commands, complex multi-file changes | Complete approval box with all risks |
| **Quick** | Low-risk single-file edits, safe commands | One-liner: `[cmd/action] / [file] / [risk]? (y/n)` |

**Before Database Changes:**
- Dropping, renaming, or altering any table or column
- Running any migration (up or down)
- Truncating or deleting data from any table
- Modifying seeders or factories that change test data
- Executing raw SQL that modifies data (INSERT, UPDATE, DELETE, DROP, ALTER)

**Before File Operations:**
- Deleting any file, no matter how small or temporary
- Modifying any existing file (exception: files you just created in the current task)
- Renaming or moving any file
- Running destructive shell commands (`rm -rf`, `mv`, etc.)

**Before Running Commands:**
- Any shell command (`git`, `artisan`, `npm`, `composer`, `php`, `curl`, etc.)
- Any command that has side effects (installing packages, clearing cache, running builds)

### What Needs Approval — Detailed Breakdown

| Action | Approval Required? | Example |
|--------|-------------------|---------|
| Creating a new file | ✅ Yes | Creating a new controller |
| Modifying an existing file | ✅ Yes | Editing UserController.php |
| Deleting a file | ✅ Yes | Removing a old migration |
| Running a migration | ✅ Yes | `php artisan migrate` |
| Dropping a table | ✅ Yes | `Schema::drop('users')` |
| Altering a column | ✅ Yes | `$table->string('email')->nullable()->change()` |
| Deleting from the database | ✅ Yes | `User::where('active', false)->delete()` |
| Installing a package | ✅ Yes | `composer require laravel/sanctum` |
| Running a git command | ✅ Yes | `git commit`, `git push`, `git rebase` |
| Clearing cache | ✅ Yes | `php artisan cache:clear` |
| Reading a file | ❌ No | `cat app/Models/User.php` |
| Showing project structure | ❌ No | `ls app/` |
| Answering a question | ❌ No | "How does the auth system work?" |
| Generating a plan | ❌ No | "What files would this task affect?" |

### Full Approval Format

```
═══════════════════════════════════════════════
  APPROVAL REQUIRED — Review before continuing
═══════════════════════════════════════════════

  Task: [what we're trying to accomplish]

  Database Actions:
    • [table/column] — [action] — [reason]
    • [query] — [reason]

  Commands:
    • [command 1]
    • [command 2]

  Files to create:
    • [path] — [reason]

  Files to modify:
    • [path] — [summary of change]

  Files to delete:
    • [path] — [reason]

  Risks:
    • [risk 1] — [data loss? breaking change?]
    • [risk 2]

  Ready to proceed? (yes/no)
═══════════════════════════════════════════════
```

### Quick Approval Format (one line)

```
[create: UserController.php] [modify: routes/api.php] [cmd: composer dump] [risk: low]? (y/n)
```

**Violation:** The BRAIN must not execute anything without explicit user approval. If you proceed without asking, you've violated the user's trust.

### R22 — Read-Only Tasks Don't Need Approval
Reading files, showing structure, answering questions, and other read-only operations do not require approval. Only mutations (commands, file writes, file deletes, database changes).

### R23 — Repeat Approval If Context Changes
If after receiving approval the plan changes significantly (different files, different commands, different database actions), ask again. Don't assume blanket approval covers unexpected changes.

---

## Code Quality Rules

### R24 — Never Hardcode Secrets or Configuration Keys
Scan every file for hardcoded values that belong in `.env` or environment variables. This includes:

| What to Scan For | Examples |
|-----------------|----------|
| API keys, tokens | `sk_live_xxx`, `api_key`, `access_token = "..."` |
| Database credentials | `DB_PASSWORD`, `mysql://user:***@host` |
| App secrets | `APP_KEY`, `APP_SECRET`, `JWT_SECRET` |
| URLs to external services | `https://api.some-service.com` (should be env config) |
| Storage paths | `/var/www/`, `/home/`, `C:\` (should be configurable) |
| Debug/test mode flags | `APP_DEBUG=true`, `APP_ENV=local` hardcoded |
| CORS origins | `'allowed_origins' => ['http://localhost:3000']` (should be env) |
| Encryption keys | Any 32-char string that looks like a key |

**Scan timing:** Run this scan at the end of every task, before presenting results. If found, flag immediately and suggest moving to `.env`.

**Violation:** Code with hardcoded secrets is blocked from commit. The SECURITY agent must verify resolution.

### R25 — Never Run Full Test Suite Without Asking
When testing, do not run the entire application test suite unless the user explicitly asks for it. Instead:
- Create new tests specific to the task (one test file per API endpoint)
- Test all scenarios: happy path, validation failure, auth failure, not found, edge cases
- Mock data must be realistic (use factories, not hardcoded arrays)
- Run only the new tests to verify they pass

**Violation:** Running the full test suite without approval uses too many tokens and time.

### R26 — Clear Variable and Input Names
All variables, inputs, parameters, and function names must be self-documenting:
- `$userId` not `$id`, `$postTitle` not `$title`, `$orderStatus` not `$s`
- Method names describe behavior: `getActiveUsers()` not `getUsers()`
- Controller parameters: `Request $request`, `Post $post` not `$req`, `$p`
- No single-letter variables except loop counters ($i, $j) and mathematical operations

**Violation:** Code review drops score for unclear naming.

### R27 — Refactoring Requires Approval
If a task reveals code that needs refactoring (unrelated to the task):
- Flag it in the plan with a note: "Found potential refactoring in [file]"
- Ask the user: "Should I refactor [file] as part of this task, or create a separate ticket?"
- Never refactor unrelated code without asking

**Violation:** Refactoring outside task scope without approval is a violation of R21.

---

## Domain Isolation Rules (R36-R40)

### R36 — Domain Identity Required
Every task must declare its domain (Backend, Frontend, Mobile iOS, Mobile Android, DevOps) before work begins. If the domain is unknown, the Brain must ask the user before proceeding. Never guess or assume the domain.

### R37 — Domain-Isolated Storage
Plans, rules, skills, and memory for one domain must never be stored in or read from another domain's subtree. Each domain is self-contained under `.brain/{domain}/`.

### R38 — Cross-Domain Reference Protocol
When a task spans multiple domains, explicitly reference the other domain's subtree using relative links — never duplicate content across domains. Cross-domain references must be explicit, not implicit.

### R39 — Framework-Scoped Rules
Rules and skills within a domain folder must be scoped to the declared framework (e.g., `backend/laravel/rules/query-optimization.md`, not a generic `backend/rules/query-optimization.md`). If multiple frameworks exist in one domain, each gets its own directory or file prefix.

### R40 — Domain Folder Initialization
When starting work on a new project in a domain, check if `.brain/{domain}/` exists first. If it doesn't, create it with `plans/`, `rules/`, `skills/`, and `memory/` subdirectories before proceeding. Never write domain knowledge without first verifying the target subtree exists.

---

## Inter-Session Rules (R32-R35)

### R32 — Session Identity Required
No session may send or receive inter-session messages without first registering in `.brain/sessions/live/`. Registration must include a valid UUID, role, and model declaration.

**Violation:** The ORCHESTRATOR rejects the message and refuses to send.

### R33 — Heartbeat Obligation
Every registered session must maintain its heartbeat in `.brain/sessions/live/{uuid}.json`. The heartbeat must be updated at least every 60 seconds. Sessions with heartbeats older than 120 seconds are considered dead and removed from the registry.

**Violation:** Other sessions will not discover or route to this session.

### R34 — Message Idempotency
Every inter-session message must be idempotent. The same message delivered twice must produce the same result. ORCHESTRATOR uses `messageId` deduplication: processed message IDs are cached for 5 minutes.

**Violation:** Duplicate processing may cause inconsistent state.

### R35 — No Cross-Session Circular Delegation
Session A cannot delegate to Session B if Session B delegates back to Session A (directly or through a chain). ORCHESTRATOR rejects messages that would create a cycle, tracked via `correlationId` ancestry.

**Violation:** The message is rejected with "circular inter-session delegation detected".

---

## Orchestration Rules (R41-R45)

### R41 — Decompose Before Dispatch
Before sending any sub-task to a sub-agent, produce the full task decomposition and dependency graph. No sub-agent is dispatched until the full graph is understood. Simple/single sub-task tasks are exempt.

**Violation:** Dispatch with no corresponding decomposition is rejected by the BRAIN.

### R42 — Default to Parallel
Launch every sub-task whose dependencies are resolved at the same time. Serialize only when a real dependency blocks it. "Simpler to reason about sequentially" is not a valid reason to serialize.

**Violation:** Excessive serialization is flagged during review.

### R43 — Relay Every Cross-Agent Request
When sub-agent A needs something from sub-agent B, the ORCHESTRATOR ENGINE must log the request, relay it to sub-agent B within the same turn, and deliver B's response back to A within the same turn it receives it. No sub-agent should wait more than one verification cycle for information.

**Violation:** An unanswered request persisting more than one cycle is a protocol error.

### R44 — Auto-Resolve Conflicts Using Project Rules
When two sub-agents disagree, the ORCHESTRATOR ENGINE must attempt resolution in order: project rules → past decisions → guidelines → conventions (R26 naming, API consistency) → framework defaults. Only escalate to the user if none of the above resolve it AND the decision has real consequences (breaking change, cost, security tradeoff).

**Violation:** Escalating a conflict that could have been resolved by an existing rule wastes the user's time.

### R45 — Max 3 Verification Cycles Before Escalating
The autonomous completion loop runs a maximum of 3 verification cycles. If the same sub-task fails the same check 3 times in a row within any cycle, escalate immediately (mid-cycle). If after 3 cycles any check still fails, stop and escalate to the user. Never loop indefinitely.

**Violation:** The BRAIN detects more than 3 verification cycles and forces escalation.
