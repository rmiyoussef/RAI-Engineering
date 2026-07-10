#!/usr/bin/env bash
#
# AI Engineering OS — Update Script
# Updates the AI Brain in your project to the latest version from GitHub.
#
# Usage:
#   bash .ai/update.sh
#   curl -fsSL https://raw.githubusercontent.com/rmiyoussef/AI-Engineering-OS/master/update.sh | bash
#
# Or via Claude:
#   "Update the AI Engineering OS to the latest version"

set -euo pipefail

REPO="rmiyoussef/AI-Engineering-OS"
BRANCH="master"
AI_DIR=".ai"
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  AI Engineering OS — Updater${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if we're in a project with .ai/ installed
if [ ! -f "$AI_DIR/CLAUDE.md" ]; then
    echo -e "${RED}⚠  AI Engineering OS is not installed in this project.${NC}"
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

if [ -z "$LATEST_VERSION" ]; then
    echo -e "   ${YELLOW}Could not check latest version. Updating anyway...${NC}"
elif [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo -e "   ${GREEN}Already at latest version: $CURRENT_VERSION${NC}"
    echo ""
    echo -e "   No update needed."
    echo ""
    exit 0
else
    echo -e "   Current version: ${YELLOW}$CURRENT_VERSION${NC}"
    echo -e "   Latest version:  ${GREEN}$LATEST_VERSION${NC}"
    echo ""
fi

# Confirm with user
echo -e "   ${YELLOW}This will update .ai/ files. Your memory/ directory will NOT be touched.${NC}"
echo -e "   ${YELLOW}Existing .ai/ files will be overwritten.${NC}"
echo ""
read -rp "   Proceed with update? (y/N): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "   ${RED}Update cancelled.${NC}"
    exit 0
fi

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

# Download the latest update.sh into .ai/
download_file "update.sh"   "$AI_DIR/update.sh"
chmod +x "$AI_DIR/update.sh"

echo ""
echo -e "${GREEN}✅  AI Engineering OS updated successfully!${NC}"
echo ""

NEW_VERSION=$(cat "$AI_DIR/VERSION")
echo -e "   Version: ${GREEN}$NEW_VERSION${NC}"
echo ""
echo -e "   ${CYAN}Changes:${NC}"
echo -e "   Check https://github.com/$REPO/releases for changelog."
echo ""
echo -e "   ${YELLOW}Note:${NC} memory/ directory was not modified."
if [ -f "$AI_DIR/VERSION.bak" ]; then
    rm "$AI_DIR/VERSION.bak"
fi
