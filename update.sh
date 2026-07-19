#!/usr/bin/env bash
#
# RAI-Engineering — Update Script
# Updates the AI Brain in your project to the latest version from GitHub.
#
# Usage:
#   bash .ai/update.sh
#   curl -fsSL https://raw.githubusercontent.com/rmiyoussef/RAI-Engineering/master/update.sh | bash
#
# Or via Claude:
#   "Update the RAI-Engineering to the latest version"

set -euo pipefail

REPO="rmiyoussef/RAI-Engineering"
BRANCH="master"
AI_DIR=".ai"
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  RAI-Engineering — Updater${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if we're in a project with .ai/ installed
if [ ! -f "$AI_DIR/CLAUDE.md" ]; then
    echo -e "${RED}⚠  RAI-Engineering is not installed in this project.${NC}"
    echo "   Run the installer first:"
    echo "   curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/setup.sh | bash"
    echo ""
    exit 1
fi

# Read current version
CURRENT_VERSION=""
if [ -f "$AI_DIR/VERSION" ]; then
    CURRENT_VERSION=$(cat "$AI_DIR/VERSION")
fi

# Fetch latest version from GitHub
echo -e "   Checking for updates..."
LATEST_VERSION=$(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/VERSION" 2>/dev/null || echo "")

NEEDS_UPDATE=false
if [ -z "$LATEST_VERSION" ]; then
    echo -e "   ${YELLOW}Could not check latest version. Updating anyway...${NC}"
    NEEDS_UPDATE=true
elif [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo -e "   Current version: ${YELLOW}$CURRENT_VERSION${NC}"
    echo -e "   Latest version:  ${GREEN}$LATEST_VERSION${NC}"
    NEEDS_UPDATE=true
fi

if [ "$NEEDS_UPDATE" = false ]; then
    echo -e "   ${GREEN}Already at latest version: $CURRENT_VERSION${NC}"
    echo ""
    # Still run caveman install (new config/files may be missing from older installs)
    echo -e "   Checking caveman install..."
else
    # Confirm with user
    echo -e "   ${YELLOW}This will update .ai/ files. Your .brain/ directory will NOT be touched.${NC}"
    echo -e "   ${YELLOW}Existing .ai/ files will be overwritten.${NC}"
    echo ""
    read -rp "   Proceed with update? (y/N): " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo -e "   ${RED}Update cancelled.${NC}"
        exit 0
    fi
fi

if [ "$NEEDS_UPDATE" = true ]; then
echo ""
echo -e "📦 Updating AI Brain in ${CYAN}$AI_DIR/${NC}..."
echo ""

download_file() {
    local src="$1"
    local dest="$2"
    curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/$src" -o "$dest"
}

# Backup current VERSION if exists
if [ -f "$AI_DIR/VERSION" ]; then
    cp "$AI_DIR/VERSION" "$AI_DIR/VERSION.bak"
fi

echo -e "   ├── Updating brain..."
download_file "brain/SYSTEM.md"   "$AI_DIR/brain/SYSTEM.md"
download_file "brain/MISSION.md"   "$AI_DIR/brain/MISSION.md"
download_file "brain/PRINCIPLES.md"   "$AI_DIR/brain/PRINCIPLES.md"
download_file "brain/LIMITATIONS.md"   "$AI_DIR/brain/LIMITATIONS.md"
download_file "brain/RULES.md"   "$AI_DIR/brain/RULES.md"
download_file "brain/MEMORY_SYSTEM.md"   "$AI_DIR/brain/MEMORY_SYSTEM.md"

echo -e "   ├── Updating agents..."
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

echo -e "   ├── Updating skills..."
download_file "skills/CODE_REVIEW.md"   "$AI_DIR/skills/CODE_REVIEW.md"
download_file "skills/TESTING.md"   "$AI_DIR/skills/TESTING.md"
download_file "skills/GIT.md"   "$AI_DIR/skills/GIT.md"
download_file "skills/MEMORY.md"   "$AI_DIR/skills/MEMORY.md"
download_file "skills/BACKEND_ENGINEERING.md"   "$AI_DIR/skills/BACKEND_ENGINEERING.md"

echo -e "   ├── Updating rules..."
download_file "rules/COMMIT_MESSAGES.md"   "$AI_DIR/rules/COMMIT_MESSAGES.md"
download_file "rules/ERROR_HANDLING.md"   "$AI_DIR/rules/ERROR_HANDLING.md"
download_file "rules/NAMING_CONVENTIONS.md"   "$AI_DIR/rules/NAMING_CONVENTIONS.md"
download_file "rules/SECURITY.md"   "$AI_DIR/rules/SECURITY.md"
download_file "rules/DATABASE.md"   "$AI_DIR/rules/DATABASE.md"
download_file "rules/API_DESIGN.md"   "$AI_DIR/rules/API_DESIGN.md"
download_file "rules/GIT_SAFETY.md"   "$AI_DIR/rules/GIT_SAFETY.md"

echo -e "   ├── Updating templates..."
download_file "templates/MEMORY_DECISION.md"   "$AI_DIR/templates/MEMORY_DECISION.md"
download_file "templates/GUIDELINES.md"   "$AI_DIR/templates/GUIDELINES.md"

echo -e "   ├── Updating workflows..."
download_file "workflows/STANDARD.md"   "$AI_DIR/workflows/STANDARD.md"

echo -e "   └── Updating CLAUDE.md..."
download_file "CLAUDE.install.md"   "$AI_DIR/CLAUDE.md"

# Update VERSION file
if [ -n "$LATEST_VERSION" ]; then
    echo "$LATEST_VERSION" > "$AI_DIR/VERSION"
else
    echo "updated-$(date +%Y%m%d)" > "$AI_DIR/VERSION"
fi
fi

# ── Caveman install (runs every update, even if version unchanged) ──
echo ""
echo -e "   ${CYAN}●  Caveman token compression (ULTRA mode)...${NC}"

# Write/refresh .caveman.json
echo '{"defaultMode":"ultra"}' > ".caveman.json"
echo -e "   ${GREEN}✓${NC} .caveman.json (ULTRA)"

# Write/refresh AGENTS.md if missing
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
  echo -e "   ${GREEN}✓${NC} Created AGENTS.md"
else
  echo -e "   ${GREEN}✓${NC} AGENTS.md exists"
fi

# Install/update caveman plugin via npx
if command -v node &>/dev/null && [ "$(node -e "console.log(process.version.slice(1).split('.')[0])")" -ge 18 ] 2>/dev/null; then
  if npx -y github:JuliusBrussee/caveman -- --only claude --non-interactive --force 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} Caveman plugin installed — ~67% output token savings"
  else
    echo -e "   ${YELLOW}⚠  Caveman plugin install skipped. Config files still updated.${NC}"
  fi
else
  echo -e "   ${YELLOW}⚠  Node ≥18 required for caveman plugin. Config files still updated.${NC}"
fi

# Exit if version already latest (only caveman needed)
if [ "$NEEDS_UPDATE" = false ]; then
    echo ""
    echo -e "${GREEN}✅  RAI-Engineering already at latest version. Caveman checked.${NC}"
    echo ""
    exit 0
fi

# ── Done ─────────────────────────────────────────────────────────
if [ "$NEEDS_UPDATE" = true ]; then
download_file "update.sh"   "$AI_DIR/update.sh"
chmod +x "$AI_DIR/update.sh"

echo ""
echo -e "${GREEN}✅  RAI-Engineering updated successfully!${NC}"
echo ""

NEW_VERSION=$(cat "$AI_DIR/VERSION")
echo -e "   Version: ${GREEN}$NEW_VERSION${NC}"
echo ""
echo -e "   ${CYAN}Changes:${NC}"
echo -e "   Check https://github.com/$REPO/releases for changelog."
echo ""
echo -e "   ${YELLOW}Note:${NC} .brain/ directory was not modified."
if [ -f "$AI_DIR/VERSION.bak" ]; then
    rm "$AI_DIR/VERSION.bak"
fi
fi
