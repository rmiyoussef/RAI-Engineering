#!/usr/bin/env bash
#
# RAI-Engineering — Brain Installer
# Installs the AI Brain into your project's .ai/ directory
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rmiyoussef/RAI-Engineering/main/setup.sh | bash
#   cd your-project && bash setup.sh
#
# Or locally:
#   bash /path/to/RAI-Engineering/setup.sh

set -euo pipefail

AI_DIR=".ai"
REPO="rmiyoussef/RAI-Engineering"
BRANCH="master"
CLAUDE_FILE="CLAUDE.install.md"
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Box-drawing characters for tree output
TREE_BRANCH="├── "
TREE_LEAF="└── "
TREE_VLINE="│   "
RIGHT="←"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  RAI-Engineering — Brain Installer${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect mode: local or remote
LOCAL_FILES=false
_LOCAL_CHECK="${BASH_SOURCE:-}"
if [ -n "$_LOCAL_CHECK" ] && [ -f "$(dirname "$_LOCAL_CHECK")/brain/SYSTEM.md" ] 2>/dev/null; then
    LOCAL_FILES=true
fi

# Check if we're in the project root
if [ ! -f "./composer.json" ] && [ ! -f "./package.json" ] && [ ! -f "./artisan" ] && [ ! -f "./package-lock.json" ] && [ ! -f "./yarn.lock" ] && [ ! -f "./pubspec.yaml" ] && [ ! -f "./Cargo.toml" ] && [ ! -f "./go.mod" ] && [ ! -f "./requirements.txt" ] && [ ! -f "./pyproject.toml" ]; then
    echo -e "${RED}⚠  Not a project root${NC}"
    echo "   Run this from your project's root directory."
    echo ""
    echo "   Example:"
    echo "   cd /path/to/your-project"
    echo "   curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/setup.sh | bash"
    echo ""
    exit 1
fi

# Check if already installed
if [ -f "$AI_DIR/CLAUDE.md" ]; then
    echo -e "${RED}⚠  RAI-Engineering is already installed in .ai/${NC}"
    echo "   To reinstall: rm -rf .ai/ CLAUDE.md && bash setup.sh"
    echo ""
    exit 1
fi

echo -e "📦 Installing AI Brain into ${CYAN}$AI_DIR/${NC}..."
echo ""

# Create directories
mkdir -p "$AI_DIR"/{brain,agents,skills,rules,templates,workflows}

# Determine project name from directory
PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

# Interactive domain selection
echo -e "   ${CYAN}Which domain does your project belong to? (10s timeout → Backend)${NC}"
echo -e "   ${CYAN}  1) Backend${NC}"
echo -e "   ${CYAN}  2) Frontend${NC}"
echo -e "   ${CYAN}  3) Mobile iOS${NC}"
echo -e "   ${CYAN}  4) Mobile Android${NC}"
echo -e "   ${CYAN}  5) DevOps / System Management${NC}"
echo -e "   ${CYAN}  6) Full Stack (Backend + Frontend)${NC}"
echo -e "   ${CYAN}(default: 1)${NC}"
read -r -t 10 DOMAIN_CHOICE || DOMAIN_CHOICE="1"
DOMAIN_CHOICE="${DOMAIN_CHOICE:-1}"

DOMAINS=()
case "$DOMAIN_CHOICE" in
    2) DOMAINS=("frontend") ;;
    3) DOMAINS=("mobile-ios") ;;
    4) DOMAINS=("mobile-android") ;;
    5) DOMAINS=("devops") ;;
    6) DOMAINS=("backend" "frontend") ;;
    *) DOMAINS=("backend") ;;
esac

DOMAIN_LABEL=$(IFS=,; echo "${DOMAINS[*]}")
echo -e "   ${GREEN}✓${NC} Domain(s): ${CYAN}$DOMAIN_LABEL${NC}, Project: ${CYAN}$PROJECT_NAME${NC}"

# Create domain-isolated .brain/ structure
for DOMAIN in "${DOMAINS[@]}"; do
    DOMAIN_DIR=".brain/${DOMAIN}/${PROJECT_NAME}"
    mkdir -p "$DOMAIN_DIR/memory"/{decisions,architecture,lessons,sessions,tests,tasks,business}
    mkdir -p "$DOMAIN_DIR/skills"
    mkdir -p "$DOMAIN_DIR/rules"
    mkdir -p "$DOMAIN_DIR/plans"
    mkdir -p "$DOMAIN_DIR/connections"

    # Write domain README
    cat > "$DOMAIN_DIR/README.md" << READMEEOF
# ${DOMAIN^} — ${PROJECT_NAME}

> Domain-isolated knowledge base.
> Plans, rules, skills, and memory live here — never cross domains.

## Structure

\`\`\`
${DOMAIN}/${PROJECT_NAME}/
├── plans/       ← Project plans
├── rules/       ← Framework-specific rules
├── skills/      ← Code templates
└── memory/      ← Guidelines, decisions, lessons, sessions, tests, tasks
\`\`\`

## Isolation Rule

${DOMAIN^} plans, rules, skills, and memory must never be stored in or read from another domain's subtree.
READMEEOF

    echo -e "   ${GREEN}✓${NC} Created ${DOMAIN}/${PROJECT_NAME}/ subtree"
done

mkdir -p ".claude"

# Add domain connections/ to .gitignore (never push connection info)
GITIGNORE_LINES=$(cat << 'GITEOF'
# RAI-Engineering — Database connections (domain-isolated, schema only)
.brain/*/*/connections/
.brain/session-bus/
.brain/sessions/live/
GITEOF
)

if [ -f ".gitignore" ]; then
    if ! grep -q "brain/connections" ".gitignore" 2>/dev/null; then
        echo "" >> ".gitignore"
        echo "$GITIGNORE_LINES" >> ".gitignore"
        echo -e "   ${GREEN}✓${NC} Added domain connection paths to .gitignore"
    fi
else
    echo "$GITIGNORE_LINES" > ".gitignore"
    echo -e "   ${GREEN}✓${NC} Created .gitignore with domain connection paths excluded"
fi

download_file() {
    local src="$1"
    local dest="$2"
    if [ "$LOCAL_FILES" = true ]; then
        cp "$(dirname "${_LOCAL_CHECK:-.}")/$src" "$dest"
    else
        curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/$src" -o "$dest"
    fi
}

echo -e "   ├── Installing brain..."
download_file "brain/SYSTEM.md"   "$AI_DIR/brain/SYSTEM.md"
download_file "brain/MISSION.md"   "$AI_DIR/brain/MISSION.md"
download_file "brain/PRINCIPLES.md"   "$AI_DIR/brain/PRINCIPLES.md"
download_file "brain/LIMITATIONS.md"   "$AI_DIR/brain/LIMITATIONS.md"
download_file "brain/RULES.md"   "$AI_DIR/brain/RULES.md"
download_file "brain/MEMORY_SYSTEM.md"   "$AI_DIR/brain/MEMORY_SYSTEM.md"

echo -e "   ├── Installing agents..."
download_file "agents/PLANNER.md"   "$AI_DIR/agents/PLANNER.md"
download_file "agents/EXECUTOR.md"   "$AI_DIR/agents/EXECUTOR.md"
download_file "agents/REVIEWER.md"   "$AI_DIR/agents/REVIEWER.md"
download_file "agents/BACKEND.md"   "$AI_DIR/agents/BACKEND.md"
download_file "agents/TESTER.md"   "$AI_DIR/agents/TESTER.md"
download_file "agents/CLEAN_CODE.md"   "$AI_DIR/agents/CLEAN_CODE.md"
download_file "agents/ARCHIVIST.md"   "$AI_DIR/agents/ARCHIVIST.md"
download_file "agents/MEMORY.md"   "$AI_DIR/agents/MEMORY.md"
download_file "agents/GITHUB.md"   "$AI_DIR/agents/GITHUB.md"
download_file "agents/DATABASE.md"   "$AI_DIR/agents/DATABASE.md"
download_file "agents/SECURITY.md"   "$AI_DIR/agents/SECURITY.md"
download_file "agents/ARCHITECT.md"   "$AI_DIR/agents/ARCHITECT.md"
download_file "agents/GITHUB_TASKS.md"   "$AI_DIR/agents/GITHUB_TASKS.md"
download_file "agents/SUMMARY.md"   "$AI_DIR/agents/SUMMARY.md"

echo -e "   ├── Installing skills..."
download_file "skills/CODE_REVIEW.md"   "$AI_DIR/skills/CODE_REVIEW.md"
download_file "skills/TESTING.md"   "$AI_DIR/skills/TESTING.md"
download_file "skills/GIT.md"   "$AI_DIR/skills/GIT.md"
download_file "skills/MEMORY.md"   "$AI_DIR/skills/MEMORY.md"
download_file "skills/BACKEND_ENGINEERING.md"   "$AI_DIR/skills/BACKEND_ENGINEERING.md"

echo -e "   ├── Installing rules..."
download_file "rules/COMMIT_MESSAGES.md"   "$AI_DIR/rules/COMMIT_MESSAGES.md"
download_file "rules/ERROR_HANDLING.md"   "$AI_DIR/rules/ERROR_HANDLING.md"
download_file "rules/NAMING_CONVENTIONS.md"   "$AI_DIR/rules/NAMING_CONVENTIONS.md"
download_file "rules/SECURITY.md"   "$AI_DIR/rules/SECURITY.md"
download_file "rules/DATABASE.md"   "$AI_DIR/rules/DATABASE.md"
download_file "rules/API_DESIGN.md"   "$AI_DIR/rules/API_DESIGN.md"
download_file "rules/GIT_SAFETY.md"   "$AI_DIR/rules/GIT_SAFETY.md"

echo -e "   ├── Installing templates..."
download_file "templates/MEMORY_DECISION.md"   "$AI_DIR/templates/MEMORY_DECISION.md"
download_file "templates/GUIDELINES.md"   "$AI_DIR/templates/GUIDELINES.md"

echo -e "   ├── Installing workflows..."
download_file "workflows/STANDARD.md"   "$AI_DIR/workflows/STANDARD.md"

echo -e "   └── Installing CLAUDE.md..."
download_file "$CLAUDE_FILE"   "$AI_DIR/CLAUDE.md"

# Download update script
echo -e "   └── Installing update tools..."
download_file "update.sh"   "$AI_DIR/update.sh"
chmod +x "$AI_DIR/update.sh"
download_file "VERSION"   "$AI_DIR/VERSION"

# Create symlink
ln -sf "$AI_DIR/CLAUDE.md" "./CLAUDE.md"

# ── Caveman install (token compression) ──────────────────────────
echo ""
echo -e "   ${CYAN}●  Installing Caveman token compression (ULTRA mode)...${NC}"
CAVEMAN_OK=false

if command -v node &>/dev/null && [ "$(node -e "console.log(process.version.slice(1).split('.')[0])")" -ge 18 ] 2>/dev/null; then
  if [ "$LOCAL_FILES" = true ]; then
    CAVEMAN_SRC="$(dirname "${_LOCAL_CHECK:-.}")"
    if [ -f "$CAVEMAN_SRC/bin/install.js" ] && node "$CAVEMAN_SRC/bin/install.js" --only claude --non-interactive 2>/dev/null; then
      CAVEMAN_OK=true
    fi
  fi
  if [ "$CAVEMAN_OK" = false ] && npx -y github:JuliusBrussee/caveman -- --only claude --non-interactive --force 2>/dev/null; then
    CAVEMAN_OK=true
  fi
fi

# Always write repo caveman config + rule file — even if plugin install skipped
echo '{"defaultMode":"ultra"}' > ".caveman.json"

if [ ! -f "AGENTS.md" ]; then
  cat > "AGENTS.md" << 'CAVEOF'
CAVEMAN ULTRA — max compression. Active every response. No revert.

Rules:
- Drop articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries, hedging, conjunctions when order unambiguous
- Fragments OK. One word when enough. State each fact once.
- Code exact. Errors exact. Technical terms exact.
- NO tool-call narration, decorative tables/emoji, raw error logs unless asked
- NO causal arrows (→), NO invented abbreviations (cfg/impl/req/res/fn) — zero token saved
- Standard acronyms OK (DB/API/HTTP). Full word cheaper AND clearer.
- Pattern: `[thing] [action] [reason].`

Not: "Sure! I'd be happy to help you with that."
Yes: "Auth middleware bug. Token expiry `<` not `<=`."

Switch: /caveman lite|full|ultra|wenyan
Stop: "normal mode"

Auto-Clarity: full sentences for security/destructive ops/user confused. Resume ultra after.

Boundaries: code/commits/PRs normal.
CAVEOF
  echo -e "   ${GREEN}✓${NC} Created AGENTS.md with caveman ULTRA rules"
fi

if [ "$CAVEMAN_OK" = true ]; then
  echo -e "   ${GREEN}✓${NC} Caveman ULTRA installed — ~67% output token savings"
else
  echo -e "   ${YELLOW}⚠  Caveman plugin skipped (Node ≥18 required).${NC}"
  echo -e "   ${YELLOW}   .caveman.json + AGENTS.md still written.${NC}"
  echo -e "   ${YELLOW}   Install manually later: npm install -g npx && npx github:JuliusBrussee/caveman${NC}"
fi

# ── Done ─────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}✅  RAI-Engineering v1.3 — Domain Isolation Protocol installed!${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  Project structure:"
echo ""
echo "  $(pwd)/"
echo "  ├── CLAUDE.md → .ai/CLAUDE.md        ← The Brain"
echo "  ├── .ai/"
echo "  │   ├── brain/                       ← System definitions"
echo "  │   ├── agents/                      ← Agent roles"
echo "  │   ├── skills/                      ← Domain knowledge"
echo "  │   ├── rules/                       ← Engineering rules"
echo "  │   ├── templates/                   ← Memory templates"
echo "  │   └── workflows/                   ← Workflow references"
echo "  ├── .caveman.json                    ← Token compression (ULTRA)"
echo "  ├── AGENTS.md                        ← Caveman per-repo rules"
echo -e "  $TREE_LEAF.brain/                  $RIGHT Domain-isolated knowledge base (any AI tool)"
echo -e "      $TREE_BRANCH${DOMAINS[0]}/${PROJECT_NAME}/"
echo -e "      $TREE_VLINE"
echo -e "      $TREE_VLINE   $TREE_BRANCH memory/"
echo -e "      $TREE_VLINE   $TREE_VLINE   $TREE_BRANCH guidelines.md"
echo -e "      $TREE_VLINE   $TREE_VLINE   $TREE_BRANCH decisions/"
echo -e "      $TREE_VLINE   $TREE_VLINE   $TREE_BRANCH lessons/"
echo -e "      $TREE_VLINE   $TREE_VLINE   $TREE_BRANCH sessions/"
echo -e "      $TREE_VLINE   $TREE_VLINE   $TREE_BRANCH tests/"
echo -e "      $TREE_VLINE   $TREE_VLINE   $TREE_BRANCH tasks/"
echo -e "      $TREE_VLINE   $TREE_VLINE   $TREE_LEAF business/"
echo -e "      $TREE_VLINE   $TREE_BRANCH skills/"
echo -e "      $TREE_VLINE   $TREE_BRANCH rules/"
echo -e "      $TREE_VLINE   $TREE_BRANCH plans/"
echo -e "      $TREE_VLINE   $TREE_LEAF connections/ (gitignored)"
echo -e "      ..."
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  Next steps:"
echo ""
echo "  1. Open this project in VS Code"
echo "  2. Run: claude"
echo "  3. Try: 'Show me the structure of this project'"
echo "  4. Or:  'Add validation to the UserController'"
echo ""
echo -e "${GREEN}  The Brain is ready. Agents are waiting.${NC}"
echo -e "${CYAN}  Caveman ULTRA active — ~67% output token savings.${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
