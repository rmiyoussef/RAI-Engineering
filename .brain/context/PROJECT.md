# Project

> Current facts about this project. ARCHITECT-maintained. Project-specific constraints here sit at PROJECT level in the rules hierarchy (below GLOBAL/CATEGORY, above PLAN/TASK).

- **Name:** RAI-Engineering
- **What:** Project-agnostic AI software-engineering OS: message-broker brain + 16 specialized agents + skills + memory system. Installs into any codebase via `setup.sh`.
- **Model:** host default (model-neutral per R9); optional tier overrides via `.brain/config.yaml`.
- **Communication:** CAVEMAN ULTRA default (AGENTS.md).
- **Constraints:**
  - OS files (agents, skills, rules, reference) never reference specific client projects/business logic (R5). Project knowledge lives in `knowledge/` + `memory/` + `context/`.
  - No domain directories inside `.brain` (see `ARCHITECTURE.md`, `_deprecated/DOMAINS_MIGRATION.md`).
  - Secrets never committed: DB connections in gitignored `context/connections/`, session liveness in `sessions/live/`, bus traffic in `session-bus/`.
