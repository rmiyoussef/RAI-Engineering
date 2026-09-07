# .brain INDEX

> Fast navigation map. Compact by design — progressive disclosure per `ARCHITECTURE.md` §10. Always load `ARCHITECTURE.md` + `INSTRUCTIONS.md` first.

## Authority

- Structure: `ARCHITECTURE.md` — what lives where, lifecycles, conventions
- Operations: `INSTRUCTIONS.md` — mandatory agent workflow, completion contract
- Project overview: `README.md` — human-readable intro

## Constitution (values + canonical rules)

- `constitution/MISSION.md` `constitution/PRINCIPLES.md` `constitution/RULES.md` (canonical R1-R45) `constitution/CONSTRAINTS.md` `constitution/QUALITY.md`

## Project context (current facts, ARCHITECT-maintained)

- `context/PROJECT.md` `context/STACK.md` `context/ARCHITECTURE.md` `context/STRUCTURE.md` `context/ENVIRONMENT.md` `context/INTEGRATIONS.md` (+ gitignored `context/connections/`)

## Knowledge (how-things-work, by purpose; `domains:` frontmatter = domain metadata)

- `knowledge/architecture/` `knowledge/components/` `knowledge/database/` `knowledge/api/` `knowledge/infrastructure/` `knowledge/security/` `knowledge/patterns/` (incl. `backend-service-layer-guidelines.md`, `frontend-best-practices.md`; `knowledge/infrastructure/devops-practices.md`)

## Memory (what happened and why, append-only)

- `memory/decisions/` (5 records incl. orchestration-engine, brain-migration, mantine-reference) · `memory/discoveries/` · `memory/lessons/` (`version-bump-before-push.md`) · `memory/incidents/` · `memory/sessions/`

## Planning / Tests / Summaries (lifecycle: plan-id ↔ TC-NN ↔ SUMMARY)

- Plans: `plans/active|completed|blocked|archived/` (archived: 2026-07-19-multi-session-arch … 2026-07-23-update-setup-scripts, pre-lifecycle)
- Test cases: `test-cases/active|completed|failed|archived/` (`PENDING RUNNING PASSED FAILED BLOCKED SKIPPED`)
- Summaries: `summaries/active|completed|archived/` (archived: 3 pre-lifecycle task records)
- Templates: `templates/plan/PLAN_TEMPLATE.md` `templates/test-case/TC_TEMPLATE.md` `templates/summary/PLAN_SUMMARY.md` (+ `testing/` modes, `summary/` team outputs, `MEMORY_DECISION.md`, `GUIDELINES.md`)

## Agents / Skills / Rules

- Agents: `agents/` (16: PLANNER EXECUTOR REVIEWER TESTER ARCHIVIST ARCHITECT MEMORY SECURITY DATABASE BACKEND CLEAN_CODE GITHUB GITHUB_TASKS SUMMARY ORCHESTRATOR ORCHESTRATOR_ENGINE)
- Skills: `skills/` (39: universal process skills untagged + `backend-*` `frontend-*` `devops-*` domain-tagged how-tos)
- Rules by purpose: `rules/coding|architecture|database|api|testing|security|performance|infrastructure|git/` (categories organizational only)

## Reference / Sessions / State

- Protocols: `reference/message-protocol.md` `reference/orchestration-protocol.md` `reference/inter-session-protocol.md` (+ `reference/mantine.md`)
- Sessions: `sessions/` registry + `session-bus/` (ephemeral, gitignored)
- State pointers: `state/current.yaml` `state/plans.yaml` `state/tasks.yaml` `state/tests.yaml` `state/agents.yaml`
- History: `_deprecated/DOMAINS_MIGRATION.md` + `old-domains/` (retired domain-first layout)
- Generated view: `TIMELINE.md` (via `.ai/memory-timeline.py`)
