# 🧠 Project Brain

> **This folder is the brain of the project.**
> Every AI tool — Claude, Cursor, Copilot, Windsurf, Gemini — can read this folder and instantly understand the project.

## Domain-Isolated Structure

Knowledge is organized into **domain-isolated subtrees**. Each domain is self-contained — Backend rules never mix with Frontend rules.

```
.brain/
├── INDEX.md                   ← Master index — start here
├── agents/                    ← Agent definitions (framework-agnostic)
├── brain/                     ← Core OS files (MISSION, PRINCIPLES, RULES, SYSTEM)
├── templates/                 ← Summary & testing templates
│
├── backend/{project-name}/    ← Backend domain
│   ├── plans/                 ← Project plans
│   ├── rules/                 ← Framework-specific rules
│   ├── skills/                ← Code templates & patterns
│   └── memory/                ← Project knowledge
│
├── frontend/{project-name}/   ← Frontend domain
│   ├── plans/
│   ├── rules/
│   ├── skills/
│   └── memory/
│
├── mobile-ios/{project-name}/ ← iOS domain
├── mobile-android/{project-name}/ ← Android domain
└── devops/{project-name}/     ← DevOps domain
```

## What's Inside Each Domain

| Path | What It Tells the AI |
|------|----------------------|
| `{domain}/{project}/memory/guidelines.md` | Architecture, tech stack, conventions |
| `{domain}/{project}/memory/decisions/` | Why past decisions were made |
| `{domain}/{project}/memory/lessons/` | What went wrong and how to avoid it |
| `{domain}/{project}/memory/tasks/` | What work was done and how |
| `{domain}/{project}/memory/tests/` | Test results per feature |
| `{domain}/{project}/skills/` | How to write code in this project |
| `{domain}/{project}/rules/` | Project-specific conventions |
| `{domain}/{project}/plans/` | Active and past plans |

## For AI Tools

When you start working on this project:

1. **Identify the domain** — Backend, Frontend, Mobile, or DevOps?
2. **Read** `.brain/INDEX.md` — full map
3. **Read** `.brain/{domain}/{project}/memory/guidelines.md` — architecture & conventions
4. **Check** `.brain/{domain}/{project}/skills/` — code patterns
5. **Check** `.brain/{domain}/{project}/plans/` — active plans

## For Humans

- Commit this folder to your repo
- Every team member's AI tool reads the same knowledge
- Nothing is lost between sessions
- Always up to date
