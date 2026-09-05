# Structure

> Repo layout. ARCHITECT updates when layout changes.

```
RAI-Engineering/
├── .brain/          ← central engineering brain (this folder)
├── .agents/ .claude/ ← runner/agent config
├── .ai/             ← scripts (memory-timeline.py)
├── skills/ workflows/ ← repo-level skill/workflow extensions
├── docs/            ← documentation
├── CLAUDE.md        ← boot protocol + routing (agent entry point)
├── AGENTS.md        ← communication mode
├── SKILLS.md        ← skills catalog (human-readable)
├── setup.sh update.sh ← install/update target projects
└── VERSION
```

`.brain/` internals: see `ARCHITECTURE.md` §2. Ephemeral/gitignored: `session-bus/`, `sessions/live/`, `context/connections/`.
