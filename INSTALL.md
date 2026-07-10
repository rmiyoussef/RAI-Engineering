# Installation

Install the **AI Engineering OS Brain** into any project.

## Prerequisites

- [Claude Code](https://claude.ai/code) or compatible AI agent
- A project you want to install the Brain into (Laravel, Django, Node.js, etc.)

---

## Quick Install

One command from your project root:

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/rmiyoussef/AI-Engineering-OS/master/setup.sh | bash
```

The script will:
1. Create `.ai/` directory with all Brain files
2. Create `memory/` directory for your project's memories
3. Symlink `.ai/CLAUDE.md` → `CLAUDE.md` in your project root
4. Show you the installed structure

---

## Manual Install

```bash
cd /path/to/your-project

# 1. Create the .ai/ directory
mkdir -p .ai/{brain,agents,skills,rules,templates,workflows}

# 2. Copy all OS files
cp -r /path/to/AI-Engineering-OS/brain/*.md .ai/brain/
cp -r /path/to/AI-Engineering-OS/agents/*.md .ai/agents/
cp -r /path/to/AI-Engineering-OS/skills/*.md .ai/skills/
cp -r /path/to/AI-Engineering-OS/rules/*.md .ai/rules/
cp -r /path/to/AI-Engineering-OS/templates/*.md .ai/templates/
cp -r /path/to/AI-Engineering-OS/workflows/*.md .ai/workflows/

# 3. Copy the installable CLAUDE.md
cp /path/to/AI-Engineering-OS/CLAUDE.install.md .ai/CLAUDE.md

# 4. Create project memory directory
mkdir -p memory/{decisions,architecture,lessons,sessions,business}

# 5. Symlink CLAUDE.md to project root (Claude Code reads this)
ln -sf .ai/CLAUDE.md ./CLAUDE.md
```

---

## ## Installing from GitHub

Same command, works from anywhere:

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/rmiyoussef/AI-Engineering-OS/master/setup.sh | bash
```

---

## What Gets Installed

```
your-project/
├── CLAUDE.md → .ai/CLAUDE.md        ← The Brain (symlink)
├── .ai/
│   ├── CLAUDE.md                     ← Master system prompt
│   ├── brain/                        ← System definitions
│   │   ├── SYSTEM.md                 ← Message broker protocol
│   │   ├── MISSION.md                ← Purpose (immutable)
│   │   ├── PRINCIPLES.md             ← Design values
│   │   ├── LIMITATIONS.md            ← Hard boundaries
│   │   └── RULES.md                  ← 16 enforced rules
│   ├── agents/                       ← Specialized roles
│   │   ├── PLANNER.md                ← Designs the approach
│   │   ├── EXECUTOR.md               ← Writes the code
│   │   ├── REVIEWER.md               ← Scores code 1-10
│   │   ├── BACKEND.md                ← Backend audit
│   │   ├── TESTER.md                 ← Test specialist
│   │   ├── CLEAN_CODE.md             ← Refactoring
│   │   ├── ARCHIVIST.md              ← Knowledge base
│   │   ├── MEMORY.md                 ← Memory keeper
│   │   └── GITHUB.md                 ← GitHub integration
│   ├── skills/                       ← Domain knowledge
│   │   ├── CODE_REVIEW.md
│   │   ├── TESTING.md
│   │   ├── GIT.md
│   │   ├── MEMORY.md
│   │   └── BACKEND_ENGINEERING.md
│   ├── rules/                        ← Engineering rules
│   │   ├── COMMIT_MESSAGES.md
│   │   ├── ERROR_HANDLING.md
│   │   ├── NAMING_CONVENTIONS.md
│   │   ├── SECURITY.md
│   │   ├── DATABASE.md
│   │   └── API_DESIGN.md
│   ├── templates/                    ← Templates
│   │   ├── MEMORY_DECISION.md        ← Decision entry template
│   │   └── GUIDELINES.md             ← Project guidelines template
│   └── workflows/
│       └── STANDARD.md
└── memory/                           ← YOUR project memory
    ├── decisions/                    ← Architecture decisions
    ├── architecture/                 ← System component map
    ├── lessons/                      ← Lessons learned
    ├── sessions/                     ← Session summaries
    └── business/                     ← Business rules
```

---

## How to Use

### 1. Start a Session

Open your project root in VS Code and run:

```bash
claude
```

The Brain loads automatically from `CLAUDE.md`.

### 2. Give a Task

Try one of these to see the Brain in action:

```text
"Show me the structure of this project"
"Add input validation to the UserController"
"Review the code quality of the auth system"
"Generate tests for the OrderService"
"Create a new API endpoint for user profiles"
```

### 3. Watch the Agents Work

When you give a task, the Brain orchestrates agents:

| Agent | What It Does | You'll See |
|-------|-------------|------------|
| **PLANNER** | Plans before coding | Structured plan with files & risks |
| **ARCHIVIST** | Reads your codebase | "Reading UserController..." |
| **EXECUTOR** | Writes the code | "Creating AuthService..." |
| **REVIEWER** | Reviews the code | "Score: 9/10. Issues: 1 minor." |
| **BACKEND QA** | Audits backend | "Clean Code: Pass. Security: Pass." |
| **TESTER** | Generates tests | "Generated 5 test scenarios." |
| **MEMORY** | Saves decisions | "Written to memory/decisions/..." |

### 4. Check Project Memory

After working, look at what was saved:

```bash
ls memory/decisions/
ls memory/lessons/
ls memory/sessions/
```

Each file is a structured record of what happened.

### 5. Resume Later

When you come back, the Brain reads `memory/` and knows the project's context before you say anything.

---

## Updating

To update the Brain after installing:

```bash
# Replace the .ai/ files with the new version
cp -r /path/to/new/AI-Engineering-OS/.ai/* .ai/

# Or re-run setup
bash setup.sh
```

---

## Removing

To uninstall:

```bash
rm -rf .ai/ CLAUDE.md
# Keep memory/ if you want to preserve project history
```

---

## Upgrading from v0.1 / v0.2

If you installed an earlier version (before the `.ai/` convention):

```bash
# Rename old install to .ai/
mv agents/ .ai/agents/
mv brain/ .ai/brain/
mv skills/ .ai/skills/
mv rules/ .ai/rules/
mv templates/ .ai/templates/
mv workflows/ .ai/workflows/
mv CLAUDE.md .ai/CLAUDE.md

# Symlink
ln -sf .ai/CLAUDE.md ./CLAUDE.md

# Create memory if missing
mkdir -p memory/{decisions,architecture,lessons,sessions,business}
```
