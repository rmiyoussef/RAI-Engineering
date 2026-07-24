# RAI-Engineering — Architecture

> Version 1.6.0 — Lazy-load boot, consolidated rules, model tiering, approval modes, memory timeline, skills-diff, migration testing templates
> **17 agents, 45 rules, domain isolation, inter-session mesh, 6 testing templates, 34 imported skills**

---

## 1. What Is the Brain?

The **Brain** is a **message broker** embedded in `CLAUDE.md`. It does not write code, plan features, review changes, or test anything directly.

The Brain does exactly three things:
1. **Route** messages from one agent to another
2. **Validate** every message's structure before delivery
3. **Persist** decisions and conversations to memory

Agents talk to each other. The Brain facilitates. No slash commands or special prefixes — the system auto-detects what agents to call based on the task.

The Brain is defined by:
- `.brain/brain/SYSTEM.md` — Message broker protocol and routing rules
- `.brain/brain/MISSION.md` — The system's purpose (immutable)
- `.brain/brain/PRINCIPLES.md` — Design values that guide all decisions
- `.brain/brain/LIMITATIONS.md` — Hard boundaries the system must not cross
- `.brain/brain/RULES.md` — Enforceable rules (R1-R45)
- `.brain/brain/ORCHESTRATION.md` — Parallel dispatch and multi-agent orchestration protocol
- `.brain/brain/INTER_SESSION.md` — Multi-session mesh communication protocol
- `.brain/brain/MEMORY_SYSTEM.md` — Memory indexing, storage, and retrieval protocol

All system files live under `.brain/`, making it compatible with any AI tool — Claude Code, Cursor, Windsurf, Copilot.

---

## 2. The Skill Mandate

Skills are **mandatory**, not optional. Before any task starts, the Brain checks the **Skill Trigger Table** and loads matching skills.

### Skill Trigger Table

| Task signal | Domain | Skill(s) to load |
|---|---|---|
| React/Vue/Angular, UI, Mantine | Frontend | UI/Frontend Skill + relevant frontend rules |
| API, DB, server, auth, jobs | Backend | Backend Skill |
| Swift/Kotlin/Flutter/RN | Mobile | Mobile Skill |
| Terraform, Docker, CI/CD, deploy | DevOps | DevOps Skill + devops rules |
| "review this", "audit" | Any | Code Review Skill |

### Skill Locations

- **Shared skills** (`.brain/shared/skills/`) — 27 framework-agnostic skills from 6 upstream repos
- **Domain skills** — `.brain/{domain}/skills/` (backend templates, frontend UI, devops automation)
- **Full catalog:** `.brain/INDEX.md` and `SKILLS.md`

---

## 3. What Is an Agent?

An **Agent** is a specialized role with a defined responsibility. Each agent receives a goal and returns a structured output — never free-form text.

Agents communicate through the Brain using the **Message Protocol**. Any agent can call any other agent for information, delegation, or consultation.

### Current Agent Roster (17 agents)

| Agent | Role | Returns | Can Call |
|-------|------|---------|----------|
| `ARCHITECT` | System architect — guidelines, patterns, consistency | `{ guidelines, architecturePattern, conventions }` | Any agent |
| `PLANNER` | Designer — produces structured plans | `{ goal, affectedFiles, risks, dependencies, executionPlan, questions }` | ARCHIVIST, MEMORY, REVIEWER |
| `ARCHIVIST` | Librarian — reads files, answers questions | `{ answers, relevantFiles, relatedDecisions, status }` | *(read-only)* |
| `DATABASE` | DB specialist — schema, migrations, queries, indexes | `{ schema, migrations, indexes, risks }` | ARCHIVIST |
| `SECURITY` | Security auditor — OWASP, CVSS, STRIDE, LLM/SSRF | `{ vulnerabilities, scores, mitigations }` | ARCHIVIST, DATABASE |
| `EXECUTOR` | Builder — writes the code | `{ filesChanged, testResults, lintResults, status }` | ARCHIVIST, BACKEND QA, CLEAN CODE, TESTER, REVIEWER |
| `BACKEND QA` | Backend auditor — clean code, queries, tests | `{ overallStatus, dimensions, fixes }` | CLEAN CODE, TESTER, ARCHIVIST |
| `CLEAN CODE` | Refactorer — SOLID, naming, duplication | `{ refactored, violationsFixed, qualityScore }` | ARCHIVIST, TESTER |
| `TESTER` | Test specialist — 6 testing modes (incl. migration) | `{ generatedTests, testResults, coverage, status }` | ARCHIVIST, EXECUTOR |
| `REVIEWER` | Inspector — scores code 1-10, manages fix loop | `{ issues, suggestions, performance, security, score }` | BACKEND QA, TESTER, CLEAN CODE, ARCHIVIST, MEMORY, SECURITY, DATABASE |
| `MEMORY SCRIBE` | Historian — persists decisions, lessons, index | `{ decisions, lessons, architectureChanges, sessionSummary }` | PLANNER, EXECUTOR, REVIEWER, TESTER |
| `GITHUB` | Integrator — branches, commits, PRs | `{ branch, commits, prUrl, prBody, status }` | EXECUTOR, REVIEWER, TESTER, MEMORY |
| `GITHUB TASKS` | GitHub task manager — issues to delivery | `{ subTasks, plan, branch, summary }` | All agents |
| `SUMMARY` | Documentation specialist — professional summaries | `{ document, metrics, tables }` | All agents |
| `ORCHESTRATOR` | Session manager — registration, heartbeat, inter-session | `{ registered, peers, messages }` | All agents |
| `ORCHESTRATOR ENGINE` | Task orchestrator — decomposition, parallel dispatch, verification | `{ decomposition, waves, results, conflicts, status }` | All domain agents |
| `BRAIN` | Message broker — routes, validates, persists | Routes and validates | *(broker, all agents)* |

---

## 4. Lazy-Load Boot System (NEW in v1.6.0)

The new CLAUDE.md is **~8KB** (was ~36KB). Core boot files are loaded on every session start via the Boot Protocol — a structured sequence of `read_file()` calls that reads brain files, determines domain, checks memory, and loads only relevant agent definitions.

This means:
- **Lower token overhead** per session — the system prompt is 75% smaller
- **Faster startup** — only load what's needed
- **On-demand agent loading** — agent definitions are read only when that agent is activated
- **Full capability preserved** — every agent, rule, and skill is still accessible, just not loaded upfront

---

## 5. Model Tiering Protocol (NEW in v1.6.0)

Set via `.brain/config.yaml` at project root or per-session override.

| Tier | Use For | Example Models |
|---|---|---|
| `fast` | Routine codegen, ARCHIVIST reads, GITHUB ops | `deepseek-v4-flash` |
| `balanced` | EXECUTOR, PLANNER, CLEAN CODE, SUMMARY | `deepseek-v4-flash` |
| `deep` | SECURITY audit, DATABASE schema, REVIEWER, BACKEND QA | `deepseek-v4-flash` |
| `architect` | ORCHESTRATOR ENGINE, ARCHITECT, complex planning | `deepseek-v4-flash` |

When no config exists, all agents use `deepseek-v4-flash` (backward compatible, zero disruption).

---

## 6. Approval Modes (NEW in v1.6.0)

Two modes, switchable mid-session:

| Mode | Format | When |
|------|--------|------|
| **Full** (default) | Complete approval box with task/commands/files/risks | Database changes, destructive commands, complex multi-file changes |
| **Quick** | One-liner: `[action] / [file] / [risk]? (y/n)` | Low-risk single-file edits, safe commands |

Read-only tasks need no approval (R22).

---

## 7. Domain Isolation

Every task belongs to exactly one domain. **Domain knowledge never leaks** between domains.

### Domain Subtrees

```
.brain/
├── backend/                   ← Backend domain
│   ├── memory/                ← decisions, architecture, lessons, sessions, tests, tasks, business
│   │   ├── guidelines.md      ← Project structure & conventions
│   │   ├── decisions/         ← Architecture Decision Records (ADRs)
│   │   ├── architecture/      ← System component maps
│   │   ├── lessons/           ← Things learned
│   │   ├── sessions/          ← Session summaries
│   │   ├── tests/             ← Test summaries
│   │   ├── tasks/             ← Task summaries
│   │   └── business/          ← Business rules & glossary
│   ├── rules/                 ← Framework-scoped conventions
│   ├── skills/                ← Code templates (controller, service, resource, crud)
│   ├── plans/                 ← Project plans
│   └── connections/           ← DB connections ⚠️ GITIGNORED
│
├── frontend/                  ← Frontend domain (self-contained)
├── mobile-ios/                ← iOS domain (self-contained)
├── mobile-android/            ← Android domain (self-contained)
├── devops/                    ← DevOps domain (self-contained)
└── shared/                    ← Cross-domain shared skills
    └── skills/                ← 27+ framework-agnostic skills
```

---

## 8. Tools & Automation (NEW in v1.6.0)

| Script | Location | Purpose |
|--------|----------|---------|
| 📊 **Memory Timeline** | `.ai/memory-timeline.py` | Cross-references decisions, lessons, sessions by date. Run: `python3 .ai/memory-timeline.py [--days N] [--domain X]` |
| 🔍 **Skills Drift Check** | `.ai/skills-diff.sh` | Compares local skills against upstream repos using hashes from `skills-lock.json`. Run: `bash .ai/skills-diff.sh [--verbose]` |
| 🔄 **Smart Update** | `update.sh` | Refreshes all skills from upstream |
| ⚡ **Setup** | `setup.sh` | Installs RAI-Engineering into a project |

### Skills-Lock System

`skills-lock.json` (v2) now tracks:
- **Upstream repos** — GitHub URLs, branch refs, and which skills were adapted from each
- **Hash-locked caveman skills** — SHA256 hashes for local caveman skills
- **Upgrade check command** — `bash .ai/skills-diff.sh` to detect drift

---

## 9. Testing Templates (6 modes)

| Template | Path | Scenarios |
|----------|------|-----------|
| ✅ API Endpoint | `.brain/templates/testing/API_ENDPOINT.md` | 15+ scenarios per endpoint |
| 🔗 Business Flow | `.brain/templates/testing/BUSINESS_FLOW.md` | Multi-step chained APIs |
| 🗄️ Database Query | `.brain/templates/testing/DATABASE_QUERY.md` | N+1 detection, indexes |
| 🗄️ **Database Migration** (NEW) | `.brain/templates/testing/DATABASE_MIGRATION.md` | Up/down idempotency, indexes, FKs, defaults, data migration safety — 7 scenarios |
| ⚡ Performance | `.brain/templates/testing/PERFORMANCE.md` | Response time, query load |
| 🧹 Code Quality | `.brain/templates/testing/CODE_QUALITY.md` | Naming, SOLID, structure |

---

## 10. Rule System Consolidation (v1.6.0)

- **R3 consolidated** with former R28 — testing + template-led testing is now one rule
- **R41-R45** — canonical source is `.brain/brain/RULES.md`; CLAUDE.md references them but no longer duplicates the full text
- **R9 updated** — model lock is now the default; config-driven tiering can override
- **R21 updated** — dual-mode approval (full/quick)

---

## 11. Memory Timeline

`.brain/TIMELINE.md` is an auto-generated chronological view of all project memory entries. Generated by `.ai/memory-timeline.py`:

```
python3 .ai/memory-timeline.py        # Last 30 days
python3 .ai/memory-timeline.py --all  # Full history
python3 .ai/memory-timeline.py --domain backend --days 7  # Last week, backend only
```

The timeline groups entries by date and category, showing what happened when. Useful for standups, retrospectives, and onboarding.
