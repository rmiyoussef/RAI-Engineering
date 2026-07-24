#!/usr/bin/env bash
#
# RAI-Engineering — Update Script
# Updates the AI Brain in your project to the latest version from GitHub.
# Automatically migrates old nested .brain/ structure to flat format.
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

# ── STRUCTURE MIGRATION: Detect old nested .brain/{domain}/{project-name}/ ──
# In v1.4+, the structure was flattened from .brain/{domain}/{project-name}/ to .brain/{domain}/
MIGRATION_NEEDED=false
MIGRATION_DOMAINS=()

detect_nested_structure() {
    local domain="$1"
    # Look for subdirectories inside .brain/{domain}/ that match old project-name pattern
    if [ -d ".brain/${domain}" ]; then
        for subdir in ".brain/${domain}"/*/; do
            subname=$(basename "$subdir")
            # Skip known flat-structure directories
            if [ "$subname" != "memory" ] && [ "$subname" != "rules" ] && [ "$subname" != "skills" ] && [ "$subname" != "plans" ] && [ "$subname" != "connections" ] && [ "$subname" != "README.md" ]; then
                # Check if this looks like an old nested project folder (has memory/, rules/, etc.)
                if [ -d "${subdir}memory" ] || [ -d "${subdir}rules" ] || [ -d "${subdir}skills" ]; then
                    MIGRATION_NEEDED=true
                    MIGRATION_DOMAINS+=("${domain}/${subname}")
                fi
            fi
        done
    fi
}

detect_nested_structure "backend"
detect_nested_structure "frontend"
detect_nested_structure "mobile-ios"
detect_nested_structure "mobile-android"
detect_nested_structure "devops"

if [ "$MIGRATION_NEEDED" = true ]; then
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  Structure Migration Available${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "   RAI-Engineering v1.4+ uses ${GREEN}flat${NC} domain structure:"
    echo -e "   ${CYAN}.brain/backend/memory/${NC} instead of ${RED}.brain/backend/project-name/memory/${NC}"
    echo ""
    echo -e "   Old nested folders found:"
    for folder in "${MIGRATION_DOMAINS[@]}"; do
        echo -e "     ${YELLOW}📁 .brain/${folder}/${NC}"
    done
    echo ""
    echo -e "   The update will ${GREEN}auto-migrate${NC} these to flat structure."
    echo -e "   All your memory, decisions, rules, and skills will be preserved."
    echo ""

    # Only prompt if we also need version update
    if [ "$NEEDS_UPDATE" = true ]; then
        read -rp "   Proceed with update + migration? (y/N): " CONFIRM
    else
        read -rp "   Proceed with migration only? (y/N): " CONFIRM
    fi

    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo -e "   ${RED}Migration cancelled.${NC}"
        echo -e "   ${YELLOW}You can migrate manually:${NC}"
        echo "   for domain in backend frontend devops mobile-ios mobile-android; do"
        echo "     for sub in \$(ls .brain/\$domain/); do"
        echo "       if [ \"\$sub\" != \"README.md\" ]; then"
        echo "         for item in memory rules skills plans connections; do"
        echo "           [ -d \".brain/\$domain/\$sub/\$item\" ] && mv \".brain/\$domain/\$sub/\$item\" \".brain/\$domain/\$item\""
        echo "         done"
        echo "         rmdir \".brain/\$domain/\$sub\" 2>/dev/null || true"
        echo "       fi"
        echo "     done"
        echo "   done"
        echo ""
        # Still proceed with update if needed
        if [ "$NEEDS_UPDATE" = false ]; then
            exit 0
        fi
    else
        # ── Run migration ──
        echo ""
        echo -e "   ${CYAN}●  Migrating .brain/ to flat structure...${NC}"
        for entry in "${MIGRATION_DOMAINS[@]}"; do
            domain=$(dirname "$entry")
            project=$(basename "$entry")
            old_path=".brain/${domain}/${project}"
            echo -e "   ${CYAN}   Migrating .brain/${domain}/${project}/ → .brain/${domain}/${NC}"

            for item in memory rules skills plans connections; do
                if [ -d "${old_path}/${item}" ]; then
                    # Check if target already has content — merge if so
                    if [ -d ".brain/${domain}/${item}" ] && [ "$(ls -A ".brain/${domain}/${item}" 2>/dev/null)" ]; then
                        echo -e "   ${YELLOW}   Merging ${item}/ into existing target...${NC}"
                        cp -r "${old_path}/${item}/" ".brain/${domain}/${item}/"
                    else
                        mv "${old_path}/${item}" ".brain/${domain}/${item}"
                    fi
                fi
            done

            # Remove old project folder if empty
            rmdir "$old_path" 2>/dev/null || true

            # Update domain README if exists
            if [ -f ".brain/${domain}/README.md" ]; then
                echo -e "   ${GREEN}✓${NC} .brain/${domain}/ migrated"
            fi
        done

        # ── Update .gitignore patterns ──
        if [ -f ".gitignore" ]; then
            if grep -q "brain/\\*/\\*/connections" ".gitignore" 2>/dev/null; then
                echo -e "   ${CYAN}   Updating .gitignore patterns to flat structure...${NC}"
                # Replace old wildcard patterns with explicit flat paths
                sed -i 's|\.brain/\*/\*/connections/|.brain/backend/connections/\n.brain/frontend/connections/\n.brain/mobile-ios/connections/\n.brain/mobile-android/connections/\n.brain/devops/connections/|g' ".gitignore"
                # Remove duplicate lines if any
                awk '!seen[$0]++' ".gitignore" > ".gitignore.tmp" && mv ".gitignore.tmp" ".gitignore"
                echo -e "   ${GREEN}✓${NC} .gitignore updated"
            fi
        fi

        echo -e "   ${GREEN}✓${NC} Structure migration complete!"
        echo ""
    fi
fi

# ── VERSION UPDATE ──
if [ "$NEEDS_UPDATE" = true ]; then
    # Confirm with user
    if [ "$MIGRATION_NEEDED" = false ]; then
        echo -e "   ${YELLOW}This will update .ai/ files. Your .brain/ directory will NOT be touched.${NC}"
        echo -e "   ${YELLOW}Existing .ai/ files will be overwritten.${NC}"
        echo ""
        read -rp "   Proceed with update? (y/N): " CONFIRM
        if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
            echo -e "   ${RED}Update cancelled.${NC}"
            exit 0
        fi
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
    download_file ".brain/brain/SYSTEM.md"          "$AI_DIR/brain/SYSTEM.md"
    download_file ".brain/brain/MISSION.md"         "$AI_DIR/brain/MISSION.md"
    download_file ".brain/brain/PRINCIPLES.md"      "$AI_DIR/brain/PRINCIPLES.md"
    download_file ".brain/brain/LIMITATIONS.md"     "$AI_DIR/brain/LIMITATIONS.md"
    download_file ".brain/brain/RULES.md"           "$AI_DIR/brain/RULES.md"
    download_file ".brain/brain/MEMORY_SYSTEM.md"   "$AI_DIR/brain/MEMORY_SYSTEM.md"
    download_file ".brain/brain/ORCHESTRATION.md"   "$AI_DIR/brain/ORCHESTRATION.md"

    echo -e "   ├── Updating agents..."
    download_file ".brain/agents/PLANNER.md"        "$AI_DIR/agents/PLANNER.md"
    download_file ".brain/agents/EXECUTOR.md"       "$AI_DIR/agents/EXECUTOR.md"
    download_file ".brain/agents/REVIEWER.md"       "$AI_DIR/agents/REVIEWER.md"
    download_file ".brain/agents/BACKEND.md"        "$AI_DIR/agents/BACKEND.md"
    download_file ".brain/agents/TESTER.md"         "$AI_DIR/agents/TESTER.md"
    download_file ".brain/agents/CLEAN_CODE.md"     "$AI_DIR/agents/CLEAN_CODE.md"
    download_file ".brain/agents/ARCHIVIST.md"      "$AI_DIR/agents/ARCHIVIST.md"
    download_file ".brain/agents/MEMORY.md"         "$AI_DIR/agents/MEMORY.md"
    download_file ".brain/agents/GITHUB.md"         "$AI_DIR/agents/GITHUB.md"
    download_file ".brain/agents/DATABASE.md"       "$AI_DIR/agents/DATABASE.md"
    download_file ".brain/agents/SECURITY.md"       "$AI_DIR/agents/SECURITY.md"
    download_file ".brain/agents/ARCHITECT.md"      "$AI_DIR/agents/ARCHITECT.md"
    download_file ".brain/agents/GITHUB_TASKS.md"   "$AI_DIR/agents/GITHUB_TASKS.md"
    download_file ".brain/agents/SUMMARY.md"        "$AI_DIR/agents/SUMMARY.md"
    download_file ".brain/agents/ORCHESTRATOR.md"   "$AI_DIR/agents/ORCHESTRATOR.md"
    download_file ".brain/agents/ORCHESTRATOR_ENGINE.md" "$AI_DIR/agents/ORCHESTRATOR_ENGINE.md"

    echo -e "   ├── Updating skills..."
    download_file ".brain/skills/CODE_REVIEW.md"    "$AI_DIR/skills/CODE_REVIEW.md"
    download_file ".brain/skills/TESTING.md"        "$AI_DIR/skills/TESTING.md"
    download_file ".brain/skills/GIT.md"            "$AI_DIR/skills/GIT.md"
    download_file ".brain/skills/MEMORY.md"         "$AI_DIR/skills/MEMORY.md"
    download_file ".brain/skills/BACKEND_ENGINEERING.md" "$AI_DIR/skills/BACKEND_ENGINEERING.md"

    echo -e "   ├── Updating rules..."
    download_file ".brain/rules/COMMIT_MESSAGES.md" "$AI_DIR/rules/COMMIT_MESSAGES.md"
    download_file ".brain/rules/ERROR_HANDLING.md"  "$AI_DIR/rules/ERROR_HANDLING.md"
    download_file ".brain/rules/NAMING_CONVENTIONS.md" "$AI_DIR/rules/NAMING_CONVENTIONS.md"
    download_file ".brain/rules/SECURITY.md"        "$AI_DIR/rules/SECURITY.md"
    download_file ".brain/rules/DATABASE.md"        "$AI_DIR/rules/DATABASE.md"
    download_file ".brain/rules/API_DESIGN.md"      "$AI_DIR/rules/API_DESIGN.md"
    download_file ".brain/rules/GIT_SAFETY.md"      "$AI_DIR/rules/GIT_SAFETY.md"

    # Install orchestration rules to the first found .brain/{domain}/rules/
    for domain_dir in .brain/backend .brain/frontend .brain/devops .brain/mobile-ios .brain/mobile-android; do
        if [ -d "${domain_dir}/rules" ]; then
            download_file ".brain/backend/rules/orchestration-rules.md" "${domain_dir}/rules/orchestration-rules.md" 2>/dev/null || true
            echo -e "   ${GREEN}✓${NC} Installed orchestration rules to ${domain_dir}/rules/"
            break
        fi
    done

    echo -e "   ├── Updating templates..."
    download_file ".brain/templates/MEMORY_DECISION.md" "$AI_DIR/templates/MEMORY_DECISION.md"
    download_file ".brain/templates/GUIDELINES.md"      "$AI_DIR/templates/GUIDELINES.md"

    echo -e "   ├── Updating workflows..."
    download_file ".brain/workflows/STANDARD.md"    "$AI_DIR/workflows/STANDARD.md" 2>/dev/null || true

    echo -e "   ├── Updating tools..."
    download_file ".ai/memory-timeline.py"    "$AI_DIR/memory-timeline.py"
    download_file ".ai/skills-diff.sh"        "$AI_DIR/skills-diff.sh"

    echo -e "   ├── Updating config guide..."
    download_file "docs/config-guide.yaml"    "$AI_DIR/docs/config-guide.yaml" 2>/dev/null || true

    echo -e "   ├── Updating migration test template..."
    download_file ".brain/templates/testing/DATABASE_MIGRATION.md" "$AI_DIR/templates/testing/DATABASE_MIGRATION.md" 2>/dev/null || true

    echo -e "   └── Updating CLAUDE.md..."
    download_file "CLAUDE.install.md"        "$AI_DIR/CLAUDE.md"

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

# Exit early if only caveman/migration was needed
if [ "$NEEDS_UPDATE" = false ]; then
    echo ""
    echo -e "${GREEN}✅  RAI-Engineering up to date.${NC}"
    if [ "$MIGRATION_NEEDED" = true ]; then
        echo -e "   ${GREEN}  Structure migration applied.${NC}"
    fi
    echo ""
    exit 0
fi

# ── Done ─────────────────────────────────────────────────────────
download_file "update.sh" "$AI_DIR/update.sh"
chmod +x "$AI_DIR/update.sh"

echo ""
echo -e "${GREEN}✅  RAI-Engineering updated to v1.6!${NC}"
echo ""

echo -e "   Version: ${GREEN}v1.6.0${NC}"
echo ""
echo -e "   ${CYAN}New in v1.6:${NC}"
echo -e "   - Lazy-load boot system — CLAUDE.md cut from 36KB → 8KB"
echo -e "   - Consolidated rules — R3+R28 merged, canonical RULES.md only"
echo -e "   - Model Tiering Protocol — configurable model per agent role"
echo -e "   - Approval modes — quick one-liner + full detailed box"
echo -e "   - Memory Timeline — cross-reference decisions/lessons/sessions by date"
echo -e "   - Skills Drift Checker — compare local vs upstream hashes"
echo -e "   - Migration testing template — 7 scenarios"
echo -e "   - Skills-lock.json v2 — tracks upstream repos + commit SHAs"
echo ""
if [ "$MIGRATION_NEEDED" = true ]; then
    echo -e "   ${GREEN}✓ .brain/ structure migrated to flat format${NC}"
fi
echo -e "   ${YELLOW}Note:${NC} .ai/ files updated. Your .brain/ memory was NOT modified"
echo -e "   ${YELLOW}      (except for the structural flattening if migration ran).${NC}"
echo ""

if [ -f "$AI_DIR/VERSION.bak" ]; then
    rm "$AI_DIR/VERSION.bak"
fi
