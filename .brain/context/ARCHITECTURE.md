# Architecture

> How this project works. See also `reference/message-protocol.md` (agent mesh) and `reference/orchestration-protocol.md` (parallel dispatch).

RAI-Engineering is a message broker: the Brain routes/validates/persists; 16 agents (PLANNER, EXECUTOR, REVIEWER, TESTER, ARCHITECT, MEMORY SCRIBE, SECURITY, DATABASE, BACKEND QA, CLEAN CODE, ARCHIVIST, GITHUB, GITHUB_TASKS, SUMMARY, ORCHESTRATOR, ORCHESTRATOR ENGINE) communicate through structured messages. Cross-session work flows through `session-bus/` + `sessions/` registry. Work lifecycle is plan → tasks → test cases → implementation → test execution → validation → summary → complete (`INSTRUCTIONS.md`).

Key structures: `.brain/` (this brain), `.agents/` + `.claude/` (runner config), `skills/` + `workflows/` (repo-level extensions), `.ai/` (scripts), `docs/`.
