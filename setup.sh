#!/usr/bin/env bash
#
# RAI-Engineering — Brain Installer
# Installs the AI Brain into your project's .ai/ directory
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rmiyoussef/RAI-Engineering/master/setup.sh | bash
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
YELLOW='\033[1;33m'
NC='\033[0m'

# Box-drawing characters
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
if [ -n "$_LOCAL_CHECK" ] && [ -f "$(dirname "$_LOCAL_CHECK")/.brain/ARCHITECTURE.md" ] 2>/dev/null; then
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

# Create base directories
mkdir -p "$AI_DIR"/{brain,agents,rules,skills,templates,workflows}

# The brain itself (.brain/ tree + system files + version) is owned by update.sh,
# the official non-destructive migration mechanism. setup.sh only prepares
# the project (.ai/ mirror, adapters) and then delegates.
mkdir -p ".claude"

# .gitignore entries for brain secrets/ephemeral paths are managed by update.sh.

download_file() {
    local src="$1"
    local dest="$2"
    if [ "$LOCAL_FILES" = true ]; then
        cp "$(dirname "${_LOCAL_CHECK:-.}")/$src" "$dest"
    else
        curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/$src" -o "$dest"
    fi
}

# All OS content (.brain/ tree + system files, .ai/ mirror, adapters) is
# installed by update.sh — the single non-destructive installation path.
# setup.sh only fetched update.sh itself here, then delegates.
download_file "update.sh"               "$AI_DIR/update.sh"
chmod +x "$AI_DIR/update.sh"
download_file "VERSION"                 "$AI_DIR/VERSION"
download_file "$CLAUDE_FILE"            "$AI_DIR/CLAUDE.md"

# Create symlink (Claude Code reads ./CLAUDE.md)
ln -sf "$AI_DIR/CLAUDE.md" "./CLAUDE.md"

# Delegate: update.sh detects fresh state and installs non-destructively.
if [ "$LOCAL_FILES" = true ]; then
    RAI_SOURCE_DIR="$(dirname "${_LOCAL_CHECK:-.}")" bash "$AI_DIR/update.sh" --yes --local
else
    bash "$AI_DIR/update.sh" --yes
fi

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

# Always write repo caveman config + rule file
echo '{"defaultMode":"ultra"}' > ".caveman.json"

if [ ! -f "AGENTS.md" ]; then
  cat > "AGENTS.md" << 'CAVEOF'
CAVEMAN ULTRA — max compression. Active every response. No revert.

RAI-Engineering installed. `.brain/` exists → mandatory OS: read `.brain/INSTRUCTIONS.md`, then `.brain/ARCHITECTURE.md`, follow workflow. Plans → `plans/`. Tests → `test-cases/`. Summaries → `summaries/`. Done = Implemented + Verified + Tested + Documented + Summarized + Brain Updated.

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
elif ! grep -qF ".brain/INSTRUCTIONS.md" "AGENTS.md" 2>/dev/null; then
  AGENTS_BOOTSTRAP='RAI-Engineering installed. `.brain/` exists → mandatory OS: read `.brain/INSTRUCTIONS.md`, then `.brain/ARCHITECTURE.md`, follow workflow. Plans → `plans/`. Tests → `test-cases/`. Summaries → `summaries/`. Done = Implemented + Verified + Tested + Documented + Summarized + Brain Updated.'
  _tmp_agents="$(mktemp)"
  { printf "%s\n\n" "$AGENTS_BOOTSTRAP"; cat "AGENTS.md"; } > "$_tmp_agents"
  cat "$_tmp_agents" > "AGENTS.md"
  rm -f "$_tmp_agents"
  echo -e "   ${GREEN}✓${NC} AGENTS.md brain bootstrap enforced (user content preserved)"
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
echo -e "${GREEN}✅  RAI-Engineering v1.8 — Vendor-neutral engineering OS installed!${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  Project structure:"
echo ""
echo "  $(pwd)/"
echo "  ├── CLAUDE.md → .ai/CLAUDE.md        ← The Brain"
echo "  ├── .ai/"
echo "  │   ├── brain/                       ← System definitions"
echo "  │   ├── agents/                      ← 16 agent roles"
echo "  │   ├── skills/                      ← Universal + area-tagged skills"
echo "  │   ├── rules/                       ← Engineering rules"
echo "  │   ├── templates/                   ← Memory templates"
echo "  │   └── workflows/                   ← Workflow references"
echo "  ├── .caveman.json                    ← Token compression (ULTRA)"
echo "  ├── AGENTS.md                        ← Caveman per-repo rules"
echo -e "  $TREE_LEAF.brain/                  $RIGHT Purpose-organized knowledge base"
echo -e "      $TREE_BRANCH ARCHITECTURE.md + INSTRUCTIONS.md + INDEX.md"
echo -e "      $TREE_BRANCH constitution/ + context/ + knowledge/"
echo -e "      $TREE_BRANCH memory/ + plans/ + test-cases/ + summaries/"
echo -e "      $TREE_BRANCH agents/ + skills/ + rules/<purpose>/"
echo -e "      $TREE_LEAF reference/ + templates/ + state/"
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
echo -e "${CYAN}  Orchestration Engine active — parallel multi-area execution.${NC}"
echo -e "${CYAN}  Caveman ULTRA active — ~67% output token savings.${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
