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

**Violation:** R3 (Git Safety) is triggered. The commit is blocked.

---

## User Approval Rules

### R21 — Always Ask Before Changing or Deleting Anything

You must **always ask for explicit approval** before any of these actions:

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

### Approval Format

Every approval request must show this box:

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
| Database credentials | `DB_PASSWORD`, `mysql://user:pass@host` |
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
