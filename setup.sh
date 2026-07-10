#!/usr/bin/env bash
#
# AI Engineering OS — Brain Installer
# Installs the AI Brain into your project's .ai/ directory
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rmiyoussef/AI-Engineering-OS/main/setup.sh | bash
#   cd your-project && bash setup.sh
#
# Or locally:
#   bash /path/to/AI-Engineering-OS/setup.sh

set -euo pipefail

AI_DIR=".ai"
REPO="rmiyoussef/AI-Engineering-OS"
BRANCH="master"
CLAUDE_FILE="CLAUDE.install.md"
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  AI Engineering OS — Brain Installer${NC}"
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
    echo -e "${RED}⚠  AI Engineering OS is already installed in .ai/${NC}"
    echo "   To reinstall: rm -rf .ai/ CLAUDE.md && bash setup.sh"
    echo ""
    exit 1
fi

echo -e "📦 Installing AI Brain into ${CYAN}$AI_DIR/${NC}..."
echo ""

# Create directories
mkdir -p "$AI_DIR"/{brain,agents,skills,rules,templates,workflows}
mkdir -p "memory"/{decisions,architecture,lessons,sessions,business}

download_file() {
    local src="$1"
    local dest="$2"
    if [ "$LOCAL_FILES" = true ]; then
        cp "$SCRIPT_DIR/$src" "$dest"
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

echo -e "   ├── Installing templates..."
download_file "templates/MEMORY_DECISION.md"   "$AI_DIR/templates/MEMORY_DECISION.md"

echo -e "   ├── Installing workflows..."
download_file "workflows/STANDARD.md"   "$AI_DIR/workflows/STANDARD.md"

echo -e "   └── Installing CLAUDE.md..."
download_file "$CLAUDE_FILE"   "$AI_DIR/CLAUDE.md"

# Create symlink
ln -sf "$AI_DIR/CLAUDE.md" "./CLAUDE.md"

echo -e "${GREEN}✅  AI Engineering OS installed successfully!${NC}"
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
echo "  └── memory/                          ← YOUR project memory"
echo "      ├── decisions/"
echo "      ├── architecture/"
echo "      ├── lessons/"
echo "      ├── sessions/"
echo "      └── business/"
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
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
