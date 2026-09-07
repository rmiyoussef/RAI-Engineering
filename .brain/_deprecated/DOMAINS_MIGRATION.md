# Domains Migration (2026-09-05)

> Why `.brain/backend|frontend|devops|mobile-*|shared|brain` no longer exist. Read-only history.

## Reason

Domain-first layout forced single-domain filing for multi-domain work (e.g. real-time notifications spanning backend, DB, queue, WebSocket, frontend, security, testing, infra). Domains are metadata now (`domains:` frontmatter), structure follows purpose per `ARCHITECTURE.md`.

## Map (old → new)

- `brain/MISSION|PRINCIPLES|RULES.md` → `constitution/` (+ new `QUALITY.md`); `brain/LIMITATIONS.md` → `constitution/CONSTRAINTS.md`
- `brain/SYSTEM|ORCHESTRATION|INTER_SESSION.md` → `reference/message-protocol|orchestration-protocol|inter-session-protocol.md`
- `brain/MEMORY_SYSTEM.md` → superseded by `ARCHITECTURE.md` + `INSTRUCTIONS.md` (copy kept in `old-domains/`)
- `{backend,frontend,devops}/rules/*` (33 files + backend project-rules → context/provenance) → `rules/<purpose>/` with `domains:` tags
- `{backend,frontend,devops}/skills/*` + `shared/skills/*` → `skills/` (`backend-*`/`frontend-*`/`devops-*` prefixes where domain-specific; universal skills untagged)
- `{backend,frontend}/memory/decisions|lessons` → `memory/decisions|lessons` (tagged); `backend/memory/tasks/*` → `summaries/archived/` (pre-lifecycle records); `backend/memory/guidelines.md` → `knowledge/patterns/backend-service-layer-guidelines.md`
- `backend/plans/*` → `planning/archived/` pre-lifecycle plans (renamed to date-slugs in v1.9.0, STATUS.md notes provenance)
- `frontend/reference/mantine.md` → `reference/mantine.md`; `frontend/FRONTEND_BEST_PRACTICES.md` → `knowledge/patterns/`; `devops/DEVOPS_BEST_PRACTICES.md` → `knowledge/infrastructure/`
- Domain `README.md`/`INDEX.md` stubs → `old-domains/` (this folder)
- `{domain}/connections/` (gitignored) → `context/connections/` (gitignored); `{domain}/memory/{sessions,tests,architecture,business}` had no files — concepts now at `memory/sessions/`, `test-cases/`+`summaries/`, `knowledge/`

## Compatibility

No symlinks/shims: stale-path references in repo docs/scripts/agents updated in same refactor. `git log --follow` preserves file history across the moves.
