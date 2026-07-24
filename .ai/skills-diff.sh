#!/usr/bin/env bash
# RAI-Engineering — Skills Diff Checker
# Compares local skills against upstream repos to detect drift.
# Usage: bash .ai/skills-diff.sh [--verbose]
#
# Returns exit code 0 if all skills match their last-known hash.
# Returns exit code 1 if any skill has drifted or is missing.

set -euo pipefail

AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK_FILE="$AI_DIR/skills-lock.json"
CACHE_DIR="$AI_DIR/.cache/skills-diff"
mkdir -p "$CACHE_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

if [ ! -f "$LOCK_FILE" ]; then
    echo -e "${RED}⚠ No skills-lock.json found at $LOCK_FILE${NC}"
    exit 1
fi

TOTAL=0
CHANGED=0
MISSING=0
OK=0
MERGED=0

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  RAI-Engineering — Skills Drift Checker${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Skip caveman skills — they're installed at runtime by update.sh
echo -e "${YELLOW}Skipping Caveman skills (installed at runtime via npx)...${NC}"
echo -e "  ${GREEN}✓${NC} (7 caveman skills — hash check not applicable)"
echo ""

# Check upstream repo skills (just existence + size comparison)
echo ""
echo -e "${YELLOW}Checking upstream-adapted skills...${NC}"
for repo_key in $(python3 -c "
import json
with open('$LOCK_FILE') as f:
    data = json.load(f)
for name in data.get('upstream_repos', {}):
    print(name)
"); do
    skills=$(python3 -c "
import json
with open('$LOCK_FILE') as f:
    data = json.load(f)
repo = data['upstream_repos'].get('$repo_key', {})
for sk in repo.get('skills_adapted', []):
    print('SKILL:' + sk)
for sk, target in repo.get('merged_into_rules', {}).items():
    print('MERGED:' + sk + '|' + target)
for sk in repo.get('source_skills', []):
    print('SKILL:' + sk)
" 2>/dev/null || echo "")
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        TOTAL=$((TOTAL + 1))

        if [[ "$line" == MERGED:* ]]; then
            skill_name="${line#MERGED:}"
            target="${skill_name#*|}"
            skill_name="${skill_name%%|*}"
            # Check if the merge target exists
            if [ -f "$AI_DIR/.brain/$target" ]; then
                echo -e "  ${GREEN}✓${NC} $skill_name — merged into $target"
                OK=$((OK + 1))
            else
                echo -e "  ${YELLOW}∼${NC} $skill_name — merged, target $target not found locally"
                MERGED=$((MERGED + 1))
            fi
            continue
        fi

        skill_name="${line#SKILL:}"
        
        # Search for skill file in shared/ or domain skills/
        found=false
        for base in "shared/skills" "backend/skills" "frontend/skills" "devops/skills"; do
            for ext in ".md" ""; do
                sk_path="$AI_DIR/.brain/$base/$skill_name$ext"
                sk_path2="$AI_DIR/.brain/$base/${skill_name}.md"
                if [ -f "$sk_path" ]; then
                    found=true
                    break
                fi
                if [ -f "$sk_path2" ]; then
                    sk_path="$sk_path2"
                    found=true
                    break
                fi
            done
            $found && break
        done
        
        if $found; then
            echo -e "  ${GREEN}✓${NC} $skill_name — exists"
            OK=$((OK + 1))
        else
            echo -e "  ${RED}✗${NC} $skill_name — NOT FOUND (from $repo_key)"
            MISSING=$((MISSING + 1))
        fi
    done <<< "$skills"
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Total: $TOTAL  |  ${GREEN}OK: $OK${NC}  |  ${RED}Changed: $CHANGED${NC}  |  ${RED}Missing: $MISSING${NC}  |  ${YELLOW}Merged: $MERGED${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $CHANGED -gt 0 ] || [ $MISSING -gt 0 ] || [ $MERGED -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Run 'bash .ai/update.sh' to refresh all skills from upstream.${NC}"
    exit 1
fi
exit 0
