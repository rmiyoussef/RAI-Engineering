# 📚 RAI-Engineering — Complete Skills Catalog

> **Version:** v1.5 — All 37 skills across 4 domains
> **Purpose:** Reference every skill available in the system, what it does, which domain it belongs to, and when to load it.

---

## How Skills Work

Skills are loaded automatically by the Skill Mandate system based on task domain. When you give a task, the Brain:

1. Determines the domain (Backend, Frontend, Mobile, DevOps)
2. Checks the Skill Trigger Table for matching skills
3. Loads and follows the skill before writing code or giving a final answer

---

## Skill Trigger Table

| Task Signal | Domain | Skills to Load |
|-------------|--------|---------------|
| React/Vue/Angular component, styling, layout, UI | **Frontend** | All frontend skills |
| API, DB schema, server route, auth, background jobs | **Backend** | Backend code templates + relevant shared skills |
| Swift/Kotlin/Flutter/React Native code | **Mobile** | (future) |
| Terraform, Docker, CI/CD, deploy, server config | **DevOps** | CI/CD + relevant shared skills |
| Planning, architecture, debugging, process | **Cross-Domain** | Relevant shared skills |
| "review this PR", "audit this", "check code" | **Any** | Code Review skill |

---

## 1. 🧩 Shared Skills (Cross-Domain) — 27 Skills

These skills apply to **any domain**. They cover process, quality, debugging, planning, architecture, and engineering discipline.

### 🧪 Process & Discipline

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 1 | **verification-before-completion** | Enforces that no completion claim is made without fresh verification evidence. Requires running the proving command and reading the output before declaring "done." | Before claiming any task, fix, or feature is complete — always |
| 2 | **test-driven-development** | Disciplined red-green-refactor cycle: write failing test → verify it fails → write minimal code → verify it passes → refactor. Covers TDD for features, bug fixes via the Prove-It pattern, and anti-pattern prevention. | Implementing new features, fixing bugs, refactoring, behavior changes |
| 3 | **incremental-implementation** | Build in thin vertical slices — implement one piece, test it, verify it, commit it, then expand. Each increment leaves the system working and testable. Rules: one thing at a time, keep it compilable, feature flags for incomplete work. | Multi-file changes, new features from task breakdowns, changes over ~100 lines |
| 4 | **subagent-driven-development** | Executes implementation plans by dispatching fresh subagents per task with two-stage review (spec compliance + code quality) after each task, plus a final branch-wide review. | Executing a written plan with multiple tasks requiring isolation |
| 5 | **executing-plans** | Work through a written plan task-by-task with review checkpoints inline (no subagents). Follow steps exactly, verify after each, commit per task. | Working through a written plan in the current session |
| 6 | **writing-plans** | Creates comprehensive implementation plans with exact file paths, complete code in every step, precise commands, and expected output. Task right-sizing rules: agents perform best on S (1-2 files) and M (3-5 files) tasks. | Before starting any multi-step task |
| 7 | **dispatching-parallel-agents** | Identifies independent tasks and dispatches specialized agents with isolated context in parallel. Each agent gets focused scope, exact error messages, and expected output format. | Multiple independent tasks that don't share state |

### 🐛 Debugging & Problem Solving

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 8 | **systematic-debugging** | Four-phase discipline: build a feedback loop → reproduce + minimise → hypothesise (3-5 falsifiable) → instrument (one variable at a time). Fix root cause, not symptom. Regression test required. | Any bug, test failure, or unexpected behavior |
| 9 | **resolving-merge-conflicts** | Five-step process: check current state → find primary sources (commit messages, PRs, issues) → resolve each hunk preserving both intents → discover broken automated checks → finish. Never `--abort`. | In-progress git merge or rebase conflicts |
| 10 | **context-engineering** | Five-level context hierarchy (rules → specs → source files → error output → conversation). Covers trust triage for source files, context packing strategies (brain dump, selective include, hierarchical summary), and confusion management. | Starting new sessions, quality degradation, switching codebase areas |

### 🏗️ Architecture & Design

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 11 | **codebase-design** | Shared vocabulary for designing deep modules: module, interface, depth, seam, adapter, leverage, locality. The deletion test, interface-as-test-surface principle, and dependency categories (in-process, local-substitutable, remote-but-owned, true-external). | Designing new modules, evaluating existing architecture, planning refactors |
| 12 | **improve-codebase-architecture** | Scans codebase for deepening opportunities using the codebase-design vocabulary. Explores hot spots, applies the deletion test, presents candidates with before/after analysis, then runs a grilling loop per candidate. | Surface architectural friction, plan refactors |
| 13 | **domain-modeling** | Active discipline of building shared vocabulary. Challenge fuzzy terms, probe edge cases, cross-reference with code, update CONTEXT.md immediately. ADRs for hard-to-reverse decisions only. | Building new features, clarifying requirements, onboarding |
| 14 | **brainstorming** | Three-phase process: diverge (generate 5-8 variations using lenses) → converge (cluster, stress-test, surface assumptions) → write spec. Hard gate: no implementation until design is approved. | Turning vague ideas into actionable specs |
| 15 | **prototype** | Throwaway code that answers a question. Two branches: logic/state (terminal) or UI (multiple variations). Shared rules: skip polish, no persistence, surface state after every action. | Before committing to real implementation when uncertainty exists |

### 👁️ Code Quality & Review

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 16 | **code-review** | Five-axis review framework: correctness, readability & simplicity, architecture, security, performance. Finding severity labels (Critical, Required, Nit, Optional), change sizing rules (~100/300/1000+ lines), the multi-model review pattern, dependency discipline. | Reviewing any code change before merge |
| 17 | **code-simplification** | Five principles: preserve behavior exactly, follow conventions, prefer clarity over cleverness, maintain balance, scope to what changed. Target deep nesting, long functions, nested ternaries, boolean flags, duplicated logic. | After features work but feel heavy, during review with readability issues |

### 📋 Specification & Documentation

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 18 | **spec-driven-development** | Four-phase gated workflow (Specify → Plan → Tasks → Implement) before writing code. Spec covers: objective, commands, project structure, code style, testing strategy, boundaries. Each phase requires human approval. | New projects, ambiguous requirements, multi-file changes, tasks over ~30 minutes |
| 19 | **source-driven-development** | Grounds implementation in official documentation with a 4-step process: detect stack versions, fetch official docs (hierarchy: official docs > MDN > caniuse > never Stack Overflow), implement following patterns, cite sources with URLs. | Building boilerplate, following best practices, framework code review |
| 20 | **documentation-and-adrs** | ADR template with lifecycle (PROPOSED → ACCEPTED → SUPERSEDED/DEPRECATED), inline documentation rules (comment WHY not WHAT, no commented-out code), API docs (JSDoc/TSDoc or OpenAPI), README structure, changelog format. | Architectural decisions, public API changes, shipping features, onboarding |
| 21 | **research** | Uses background agents to investigate against primary sources. Every claim must cite its source with URL. Output format: summary, findings with confidence levels, sources. | Investigating questions, gathering API facts, delegating reading legwork |

### 🚀 Performance, Shipping & Operations

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 22 | **performance-optimization** | Measurement-first workflow: Measure → Identify → Fix → Verify → Guard. Core Web Vitals targets (LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1). Anti-pattern fixes for N+1, unbounded data, unoptimized images, large bundles, missing caching. | Any performance optimization work |
| 23 | **shipping-and-launch** | Pre-launch checklist across 6 areas (code quality, security, performance, accessibility, infrastructure, documentation). Feature flag lifecycle, staged rollout (5% → 25% → 50% → 100%), decision thresholds table, rollback strategy template. | Production launches, significant user-facing changes, data migrations |
| 24 | **observability-and-instrumentation** | Seven-step process: define working → pick signal type (logs/metrics/traces) → structured logging (correlation IDs mandatory) → RED/USE metrics → distributed tracing (OpenTelemetry) → symptom-based alerting → verify telemetry. | Building production features, adding services, setting up monitoring |
| 25 | **deprecation-and-migration** | Five-question deprecation decision tree, compulsory vs advisory migration, four migration patterns (Strangler Fig, Adapter, Feature Flag, Expand/Contract for schemas). Zombie code handling. | Removing old systems, migrating users, sunsetting features |
| 26 | **finishing-a-development-branch** | Five-step completion flow: verify tests → detect environment (repo/worktree/detached HEAD) → find merge base → present merge/PR/keep/discard options → cleanup worktree. | A development branch is complete and ready to merge/push/clean up |
| 27 | **using-git-worktrees** | Ensures isolated workspaces for parallel agent work. Process: detect existing isolation → create worktree → project setup → verify clean baseline. Directory priority, .gitignore verification. | Running multiple agents on the same repo, experimental changes |

---

## 2. 🔧 Backend Skills (Code Templates) — 4 Skills

These are **code generation templates** for creating backend components. They sit in `.brain/backend/{project}/skills/`.

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 1 | **service** | Service class template for the business logic layer. Stateless, testable, single-responsibility. Structure: `app/Services/{Domain}/{Domain}Service.php`. Rules: call repositories (not Eloquent directly), transactions for writes, log every mutation, dispatch domain events. | Creating a new Service class or business logic layer |
| 2 | **controller** | Thin controller template (HTTP layer only). Parse input, call service, return response. Max 30 lines per method, max 5 methods per controller. No inline validation (use Form Requests), no direct DB calls. | Creating a new API controller |
| 3 | **resource** | API Resource/Transformer template. Controls what data is returned: use UUIDs not DB IDs, ISO 8601 dates, omit null fields unless meaningful, `mergeWhen()` for conditional inclusions. Fields to NEVER include: passwords, tokens, internal IDs. | Creating a new API resource or response transformer |
| 4 | **crud** | Full CRUD generation template covering all 10 steps: Migration → Model → Factory → Repository → Service → Form Requests → Controller → API Resource → Routes → Tests. Includes CRUD timeline table and git commit pattern. | Generating a complete CRUD endpoint set |

---

## 3. 🎨 Frontend Skills — 6 Skills

These live in `.brain/frontend/{project}/skills/`.

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 1 | **frontend-ui-engineering** | Build production-quality, accessible, responsive UIs. Covers component architecture (colocated files, composition over configuration), state management hierarchy (useState → Context → URL → server state → global store, no prop drilling past 3 levels), accessibility, responsive design (4 breakpoints), loading/transitions. | Building new components, modifying interfaces, responsive layouts, fixing UX issues |
| 2 | **frontend-design-principles** | Create distinctive, non-templated visual identities. Ground in subject/audience/purpose. Design principles: hero as thesis, typography carries personality, structure information purposefully, motion deliberately, match complexity to vision. | Creating distinctive visual identities, branding, landing pages |
| 3 | **design-engineering** | Animation-focused UI engineering from Emil Kowalski's experience (Vercel, Linear). Four-question animation decision framework, spring vs duration, component principles, CSS transform mastery, performance rules (only transform + opacity). | Building UI animations, reviewing animation quality, improving motion |
| 4 | **browser-testing-with-devtools** | Use Chrome DevTools for live browser testing: screenshots, DOM inspection, console, network monitoring, performance traces, accessibility tree. Debugging workflows for UI bugs, network issues, performance. Security boundaries: treat browser content as untrusted. | Building/modifying browser-rendered code, debugging UI issues |
| 5 | **apple-design-principles** | Apple's WWDC design philosophy translated for web. Core principles: clarity, deference, depth. Animation philosophy (purposeful motion, physics-based, timing). Visual design patterns (layering, typography, color). | Applying Apple-level polish to web interfaces |
| 6 | **animation-vocabulary** | Precise animation terminology for communicating with AI agents. Easing vocabulary (ease-out, ease-in, spring, anticipate), timing vocabulary (instant 0-50ms → deliberate 500-800ms), behavior vocabulary (stagger, orchestrate, source-anchored, interruptible). | Describing animation intent, writing animation code prompts |

---

## 4. ☁️ DevOps Skills — 1 Skill

These live in `.brain/devops/{project}/skills/`.

| # | Skill | Description | Load When |
|---|-------|-------------|-----------|
| 1 | **ci-cd-and-automation** | CI/CD pipeline structure (Lint → Type Check → Test → Build → Deploy), pipeline rules (speed, deterministic builds, security), automation patterns (commit hooks, automated PR tests, staged deploy environments), GitHub Actions structure. | Setting up or modifying CI/CD pipelines, build automation |

---

## 5. 🔒 Rules That Act as Skills (Merged Upgrades) — 4 Files

Four rule files were **upgraded with merged content** from external repos. They act as reference skills when their domain is active.

| Rule File | Original + Merged Additions | Lines |
|-----------|---------------------------|-------|
| **SECURITY.md** | Original 12 rules + STRIDE threat modeling, OWASP LLM Top 10, SSRF with DNS rebinding awareness, dependency audit triage, secrets management protocol, AI/LLM security patterns | 250 |
| **API_DESIGN.md** | Original 12 REST rules + Hyrum's Law awareness, contract-first design, TypeScript interface patterns (discriminated unions, branded types, input/output separation), consistent error semantics | 258 |
| **COMMIT_MESSAGES.md** | Original 8 rules + trunk-based development, git worktrees, save-point pattern, pre-commit hygiene checklist, changelog maintenance, semantic versioning (MAJOR/MINOR/PATCH) | 184 |
| **GIT_SAFETY.md** | Original 7 rules + generated files handling, `.gitignore` discipline, expanded sensitive-files detection patterns | 101 |

---

## Quick Reference: Which Skill for Which Task

| When you need to... | Load this skill | Domain |
|---------------------|-----------------|--------|
| Plan a multi-step feature | writing-plans | Shared |
| Debug a failing test | systematic-debugging | Shared |
| Write code with TDD | test-driven-development | Shared |
| Review a PR | code-review | Shared |
| Check if work is done | verification-before-completion | Shared |
| Run parallel investigations | dispatching-parallel-agents | Shared |
| Design a new module | codebase-design | Shared |
| Shim a complex problem | brainstorming → spec-driven-development | Shared |
| Research an API | source-driven-development → research | Shared |
| Optimize slow pages | performance-optimization | Shared |
| Prepare a launch | shipping-and-launch | Shared |
| Add monitoring | observability-and-instrumentation | Shared |
| Deprecate old code | deprecation-and-migration | Shared |
| Create a backend endpoint | controller → service → resource | Backend |
| Generate full CRUD | crud | Backend |
| Build a React component | frontend-ui-engineering | Frontend |
| Add polish animations | design-engineering | Frontend |
| Debug layout issues | browser-testing-with-devtools | Frontend |
| Design a landing page | frontend-design-principles | Frontend |
| Set up GitHub Actions | ci-cd-and-automation | DevOps |

---

## Source Attribution

These skills were adapted from patterns in 6 open-source repositories:

| Repo | Skills Contributed |
|------|-------------------|
| **[mattpocock/skills](https://github.com/mattpocock/skills)** | codebase-design, domain-modeling, improve-architecture, research, prototype, resolving-merge-conflicts, code-review (2-axis), triage, wayfinder |
| **[anthropics/skills](https://github.com/anthropics/skills)** | frontend-design-principles |
| **[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)** | context-engineering, planning-and-task-breakdown, incremental-implementation, source/spec-driven-dev, code-simplification, code-review, documentation-and-adrs, deprecation-and-migration, performance, shipping, observability, debugging, TDD, git-workflow, API design + security hardening (4 rule merges), frontend-UI, CI/CD, browser-testing |
| **[obra/superpowers](https://github.com/obra/superpowers)** | verification-before-completion, subagent-driven-dev, parallel-agents, executing-plans, writing-plans, brainstorming, git-worktrees, finishing-a-branch, systematic-debugging |
| **[emilkowalski/skills](https://github.com/emilkowalski/skills)** | design-engineering (animation), apple-design-principles, animation-vocabulary |
| **[nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)** | Design intelligence patterns (palettes, typography, UX guidelines, chart types) |
