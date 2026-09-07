# Project Brain

> `.brain/` is the central intelligence of this project — the single source of truth for architecture, instructions, rules, planning, testing, memory, and state. Every AI tool (Claude, Cursor, Copilot, Windsurf, Gemini) reads this folder and operates from the same knowledge.

## Purpose-Organized Knowledge

Knowledge is organized by purpose, not by technical domain. A task like "real-time notifications" spans backend, database, queue, WebSocket, frontend, security, testing — so domains are metadata (`domains:` frontmatter), never directories.

```
.brain/
├── ARCHITECTURE.md  ← structural authority: what lives where, lifecycles
├── INSTRUCTIONS.md  ← operational authority: mandatory agent workflow
├── INDEX.md         ← navigation map (start here after the two above)
├── constitution/    ← mission, principles, canonical rules, constraints, quality
├── context/         ← current project facts (stack, architecture, environment)
├── knowledge/       ← how-things-work, by purpose (api, database, security, ...)
├── memory/          ← what happened and why (decisions, lessons, sessions)
├── plans/        ← plans <date>-<slug> with tasks (active/completed/blocked/archived)
├── test-cases/      ← first-class test cases TC-NN per plan
├── summaries/       ← final summary per completed plan
├── agents/          ← agent definitions (retrieve knowledge, never duplicate it)
├── skills/          ← how to perform work (universal unless domain-tagged)
├── rules/           ← engineering rules by purpose (categories, not domain brains)
├── reference/       ← stable protocols + external references
├── templates/       ← scaffolds for plans, test cases, summaries
├── sessions/        ← session registry (live data gitignored)
└── state/           ← machine-readable pointers to current work
```

## Lifecycle

Every plan follows `PLAN → TASKS → TEST CASES → IMPLEMENTATION → TEST EXECUTION → VALIDATION → SUMMARY → COMPLETE`. A plan is complete only when implemented, verified, tested, documented, summarized, and recorded in the brain. See `INSTRUCTIONS.md` §8 for the completion contract.

## For AI Agents

1. Read `ARCHITECTURE.md` + `INSTRUCTIONS.md`.
2. Read `state/current.yaml`, then selectively load relevant context/rules/knowledge/memory via `INDEX.md`.
3. Never bulk-read the whole brain. Never create domain directories.

## For Humans

- Commit this folder. Every team member's AI tool reads the same knowledge; nothing is lost between sessions.
- Retired domain-first layout documented in `_deprecated/DOMAINS_MIGRATION.md`.
