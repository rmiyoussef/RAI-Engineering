#!/usr/bin/env bash
#
# RAI-Engineering — update.sh (official migration / installation mechanism)
#
# NON-DESTRUCTIVE BY DEFAULT. Never deletes user brain data. Never replaces
# the whole .brain tree. Never silently overwrites user-customized files.
#
# Supports: fresh installation, existing installation, old (domain-first)
# structure, new (purpose-organized) structure, repeated updates, partial
# installations, user-modified files, user-generated plans/memory.
# Idempotent: run it any number of times — after the first successful run,
# later runs detect the current brain version, skip finished work, preserve
# user data, and refresh only missing or safely-updatable system files.
#
# Usage:
#   bash update.sh [--yes] [--check] [--local]
#   bash .ai/update.sh [--yes]
#   curl -fsSL https://raw.githubusercontent.com/rmiyoussef/RAI-Engineering/master/update.sh | bash
#
# Flags:
#   --yes    non-interactive (assume "yes" to safe prompts)
#   --check  report state + planned actions, change nothing
#   --local  copy system files from this script's directory instead of GitHub
#            (used by setup.sh and by the test suite)
#
# Safety rules (this script obeys them):
#   - set -euo pipefail; all paths quoted; no `eval`; no execution of
#     project files; network access is read-only GitHub raw downloads only.
#   - Never touches .env, credentials, SSH config, or secrets. Never logs
#     file contents — only paths and counts.
#   - User-owned content (plans, test cases, summaries, memory, knowledge,
#     context, sessions, custom rules/agents) is merged, never replaced.

set -euo pipefail

TARGET_BRAIN_VERSION=3
REPO="rmiyoussef/RAI-Engineering"
BRANCH="master"
AI_DIR=".ai"
BRAIN_DIR=".brain"
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

ASSUME_YES=false
CHECK_ONLY=false
LOCAL_SRC=false
for arg in "$@"; do
    case "$arg" in
        --yes) ASSUME_YES=true ;;
        --check) CHECK_ONLY=true ;;
        --local) LOCAL_SRC=true ;;
        *) echo -e "${RED}Unknown flag: $arg${NC}" >&2; exit 2 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { echo -e "   $1"; }
ok()   { echo -e "   ${GREEN}✓${NC} $1"; }
warn() { echo -e "   ${YELLOW}⚠  $1${NC}"; }
fail() { echo -e "   ${RED}✗  $1${NC}" >&2; }

WARNINGS=()

add_warning() { WARNINGS+=("$1"); }

confirm() {
    local prompt="$1"
    if [ "$ASSUME_YES" = true ] || [ "$CHECK_ONLY" = true ]; then
        return 0
    fi
    local ans=""
    read -rp "   $prompt (y/N): " ans || true
    [ "$ans" = "y" ] || [ "$ans" = "Y" ]
}

sha() { sha256sum "$1" | awk '{print $1}'; }

# ── System file inventory ──────────────────────────────────────────────
# Format per line: "<source-rel>|<dest-rel>" (both relative to repo/project root).
# These are RAI-owned. User data is NEVER listed here.
SYSTEM_FILES="$(cat << 'FILES_EOF'
.brain/ARCHITECTURE.md|.brain/ARCHITECTURE.md
.brain/INSTRUCTIONS.md|.brain/INSTRUCTIONS.md
.brain/INDEX.md|.brain/INDEX.md
.brain/README.md|.brain/README.md
.brain/constitution/MISSION.md|.brain/constitution/MISSION.md
.brain/constitution/PRINCIPLES.md|.brain/constitution/PRINCIPLES.md
.brain/constitution/RULES.md|.brain/constitution/RULES.md
.brain/constitution/CONSTRAINTS.md|.brain/constitution/CONSTRAINTS.md
.brain/constitution/QUALITY.md|.brain/constitution/QUALITY.md
.brain/reference/message-protocol.md|.brain/reference/message-protocol.md
.brain/reference/orchestration-protocol.md|.brain/reference/orchestration-protocol.md
.brain/reference/inter-session-protocol.md|.brain/reference/inter-session-protocol.md
.brain/reference/mantine.md|.brain/reference/mantine.md
.brain/agents/ARCHITECT.md|.brain/agents/ARCHITECT.md
.brain/agents/ARCHIVIST.md|.brain/agents/ARCHIVIST.md
.brain/agents/BACKEND.md|.brain/agents/BACKEND.md
.brain/agents/CLEAN_CODE.md|.brain/agents/CLEAN_CODE.md
.brain/agents/DATABASE.md|.brain/agents/DATABASE.md
.brain/agents/EXECUTOR.md|.brain/agents/EXECUTOR.md
.brain/agents/GITHUB.md|.brain/agents/GITHUB.md
.brain/agents/GITHUB_TASKS.md|.brain/agents/GITHUB_TASKS.md
.brain/agents/MEMORY.md|.brain/agents/MEMORY.md
.brain/agents/ORCHESTRATOR.md|.brain/agents/ORCHESTRATOR.md
.brain/agents/ORCHESTRATOR_ENGINE.md|.brain/agents/ORCHESTRATOR_ENGINE.md
.brain/agents/PLANNER.md|.brain/agents/PLANNER.md
.brain/agents/REVIEWER.md|.brain/agents/REVIEWER.md
.brain/agents/SECURITY.md|.brain/agents/SECURITY.md
.brain/agents/SUMMARY.md|.brain/agents/SUMMARY.md
.brain/agents/TESTER.md|.brain/agents/TESTER.md
.brain/skills/backend-controller.md|.brain/skills/backend-controller.md
.brain/skills/backend-crud.md|.brain/skills/backend-crud.md
.brain/skills/backend-resource.md|.brain/skills/backend-resource.md
.brain/skills/backend-service.md|.brain/skills/backend-service.md
.brain/skills/brainstorming.md|.brain/skills/brainstorming.md
.brain/skills/codebase-design.md|.brain/skills/codebase-design.md
.brain/skills/code-review.md|.brain/skills/code-review.md
.brain/skills/code-simplification.md|.brain/skills/code-simplification.md
.brain/skills/context-engineering.md|.brain/skills/context-engineering.md
.brain/skills/deprecation-and-migration.md|.brain/skills/deprecation-and-migration.md
.brain/skills/devops-ci-cd-and-automation.md|.brain/skills/devops-ci-cd-and-automation.md
.brain/skills/dispatching-parallel-agents.md|.brain/skills/dispatching-parallel-agents.md
.brain/skills/documentation-and-adrs.md|.brain/skills/documentation-and-adrs.md
.brain/skills/domain-modeling.md|.brain/skills/domain-modeling.md
.brain/skills/executing-plans.md|.brain/skills/executing-plans.md
.brain/skills/finishing-a-development-branch.md|.brain/skills/finishing-a-development-branch.md
.brain/skills/frontend-animation-vocabulary.md|.brain/skills/frontend-animation-vocabulary.md
.brain/skills/frontend-apple-design-principles.md|.brain/skills/frontend-apple-design-principles.md
.brain/skills/frontend-browser-testing-with-devtools.md|.brain/skills/frontend-browser-testing-with-devtools.md
.brain/skills/frontend-design-engineering.md|.brain/skills/frontend-design-engineering.md
.brain/skills/frontend-frontend-design-principles.md|.brain/skills/frontend-frontend-design-principles.md
.brain/skills/frontend-frontend-ui-engineering.md|.brain/skills/frontend-frontend-ui-engineering.md
.brain/skills/frontend-mantine.md|.brain/skills/frontend-mantine.md
.brain/skills/improve-codebase-architecture.md|.brain/skills/improve-codebase-architecture.md
.brain/skills/incremental-implementation.md|.brain/skills/incremental-implementation.md
.brain/skills/observability-and-instrumentation.md|.brain/skills/observability-and-instrumentation.md
.brain/skills/performance-optimization.md|.brain/skills/performance-optimization.md
.brain/skills/prototype.md|.brain/skills/prototype.md
.brain/skills/research.md|.brain/skills/research.md
.brain/skills/resolving-merge-conflicts.md|.brain/skills/resolving-merge-conflicts.md
.brain/skills/shipping-and-launch.md|.brain/skills/shipping-and-launch.md
.brain/skills/source-driven-development.md|.brain/skills/source-driven-development.md
.brain/skills/spec-driven-development.md|.brain/skills/spec-driven-development.md
.brain/skills/subagent-driven-development.md|.brain/skills/subagent-driven-development.md
.brain/skills/systematic-debugging.md|.brain/skills/systematic-debugging.md
.brain/skills/test-driven-development.md|.brain/skills/test-driven-development.md
.brain/skills/using-git-worktrees.md|.brain/skills/using-git-worktrees.md
.brain/skills/verification-before-completion.md|.brain/skills/verification-before-completion.md
.brain/skills/writing-plans.md|.brain/skills/writing-plans.md
.brain/rules/api/design.md|.brain/rules/api/design.md
.brain/rules/api/frontend-integration.md|.brain/rules/api/frontend-integration.md
.brain/rules/architecture/components.md|.brain/rules/architecture/components.md
.brain/rules/architecture/orchestration.md|.brain/rules/architecture/orchestration.md
.brain/rules/coding/accessibility.md|.brain/rules/coding/accessibility.md
.brain/rules/coding/error-handling.md|.brain/rules/coding/error-handling.md
.brain/rules/coding/error-ux.md|.brain/rules/coding/error-ux.md
.brain/rules/coding/forms.md|.brain/rules/coding/forms.md
.brain/rules/coding/naming.md|.brain/rules/coding/naming.md
.brain/rules/coding/state-management.md|.brain/rules/coding/state-management.md
.brain/rules/coding/styling.md|.brain/rules/coding/styling.md
.brain/rules/database/database.md|.brain/rules/database/database.md
.brain/rules/database/ops.md|.brain/rules/database/ops.md
.brain/rules/git/commit-messages.md|.brain/rules/git/commit-messages.md
.brain/rules/git/safety.md|.brain/rules/git/safety.md
.brain/rules/infrastructure/automation-scripting.md|.brain/rules/infrastructure/automation-scripting.md
.brain/rules/infrastructure/backup-dr-incident.md|.brain/rules/infrastructure/backup-dr-incident.md
.brain/rules/infrastructure/build-tooling.md|.brain/rules/infrastructure/build-tooling.md
.brain/rules/infrastructure/ci-cd.md|.brain/rules/infrastructure/ci-cd.md
.brain/rules/infrastructure/cloud-services.md|.brain/rules/infrastructure/cloud-services.md
.brain/rules/infrastructure/containers.md|.brain/rules/infrastructure/containers.md
.brain/rules/infrastructure/cost-optimization.md|.brain/rules/infrastructure/cost-optimization.md
.brain/rules/infrastructure/infra-as-code.md|.brain/rules/infrastructure/infra-as-code.md
.brain/rules/infrastructure/kubernetes.md|.brain/rules/infrastructure/kubernetes.md
.brain/rules/infrastructure/monitoring.md|.brain/rules/infrastructure/monitoring.md
.brain/rules/infrastructure/networking-dns.md|.brain/rules/infrastructure/networking-dns.md
.brain/rules/infrastructure/release-management.md|.brain/rules/infrastructure/release-management.md
.brain/rules/performance/frontend.md|.brain/rules/performance/frontend.md
.brain/rules/security/backend.md|.brain/rules/security/backend.md
.brain/rules/security/devops.md|.brain/rules/security/devops.md
.brain/rules/security/frontend.md|.brain/rules/security/frontend.md
.brain/rules/testing/frontend.md|.brain/rules/testing/frontend.md
.brain/rules/testing/testing.md|.brain/rules/testing/testing.md
.brain/templates/GUIDELINES.md|.brain/templates/GUIDELINES.md
.brain/templates/MEMORY_DECISION.md|.brain/templates/MEMORY_DECISION.md
.brain/templates/plan/PLAN_TEMPLATE.md|.brain/templates/plan/PLAN_TEMPLATE.md
.brain/templates/test-case/TC_TEMPLATE.md|.brain/templates/test-case/TC_TEMPLATE.md
.brain/templates/summary/PLAN_SUMMARY.md|.brain/templates/summary/PLAN_SUMMARY.md
.brain/templates/summary/TASK_SUMMARY.md|.brain/templates/summary/TASK_SUMMARY.md
.brain/templates/summary/TEST_SUMMARY.md|.brain/templates/summary/TEST_SUMMARY.md
.brain/templates/testing/API_ENDPOINT.md|.brain/templates/testing/API_ENDPOINT.md
.brain/templates/testing/BUSINESS_FLOW.md|.brain/templates/testing/BUSINESS_FLOW.md
.brain/templates/testing/CODE_QUALITY.md|.brain/templates/testing/CODE_QUALITY.md
.brain/templates/testing/DATABASE_MIGRATION.md|.brain/templates/testing/DATABASE_MIGRATION.md
.brain/templates/testing/DATABASE_QUERY.md|.brain/templates/testing/DATABASE_QUERY.md
.brain/templates/testing/PERFORMANCE.md|.brain/templates/testing/PERFORMANCE.md
.brain/templates/testing/TEST_PLAN_TEMPLATE.md|.brain/templates/testing/TEST_PLAN_TEMPLATE.md
FILES_EOF
)"

# .ai/ mirror inventory (regenerable byte-copies of upstream; same safe policy).
AI_FILES="$(cat << 'FILES_EOF'
.brain/ARCHITECTURE.md|.ai/ARCHITECTURE.md
.brain/INSTRUCTIONS.md|.ai/INSTRUCTIONS.md
.brain/INDEX.md|.ai/INDEX.md
.brain/constitution/MISSION.md|.ai/brain/MISSION.md
.brain/constitution/PRINCIPLES.md|.ai/brain/PRINCIPLES.md
.brain/constitution/RULES.md|.ai/brain/RULES.md
.brain/constitution/CONSTRAINTS.md|.ai/brain/LIMITATIONS.md
.brain/constitution/QUALITY.md|.ai/brain/QUALITY.md
.brain/reference/message-protocol.md|.ai/brain/SYSTEM.md
.brain/reference/orchestration-protocol.md|.ai/brain/ORCHESTRATION.md
.brain/reference/inter-session-protocol.md|.ai/brain/INTER_SESSION.md
.brain/agents/PLANNER.md|.ai/agents/PLANNER.md
.brain/agents/EXECUTOR.md|.ai/agents/EXECUTOR.md
.brain/agents/REVIEWER.md|.ai/agents/REVIEWER.md
.brain/agents/BACKEND.md|.ai/agents/BACKEND.md
.brain/agents/TESTER.md|.ai/agents/TESTER.md
.brain/agents/CLEAN_CODE.md|.ai/agents/CLEAN_CODE.md
.brain/agents/ARCHIVIST.md|.ai/agents/ARCHIVIST.md
.brain/agents/MEMORY.md|.ai/agents/MEMORY.md
.brain/agents/GITHUB.md|.ai/agents/GITHUB.md
.brain/agents/DATABASE.md|.ai/agents/DATABASE.md
.brain/agents/SECURITY.md|.ai/agents/SECURITY.md
.brain/agents/ARCHITECT.md|.ai/agents/ARCHITECT.md
.brain/agents/GITHUB_TASKS.md|.ai/agents/GITHUB_TASKS.md
.brain/agents/SUMMARY.md|.ai/agents/SUMMARY.md
.brain/agents/ORCHESTRATOR.md|.ai/agents/ORCHESTRATOR.md
.brain/agents/ORCHESTRATOR_ENGINE.md|.ai/agents/ORCHESTRATOR_ENGINE.md
.brain/skills/code-review.md|.ai/skills/CODE_REVIEW.md
.brain/skills/test-driven-development.md|.ai/skills/TESTING.md
.brain/skills/verification-before-completion.md|.ai/skills/VERIFICATION.md
.brain/skills/writing-plans.md|.ai/skills/WRITING_PLANS.md
.brain/skills/executing-plans.md|.ai/skills/EXECUTING_PLANS.md
.brain/rules/git/commit-messages.md|.ai/rules/COMMIT_MESSAGES.md
.brain/rules/coding/error-handling.md|.ai/rules/ERROR_HANDLING.md
.brain/rules/coding/naming.md|.ai/rules/NAMING_CONVENTIONS.md
.brain/rules/security/backend.md|.ai/rules/SECURITY.md
.brain/rules/database/database.md|.ai/rules/DATABASE.md
.brain/rules/api/design.md|.ai/rules/API_DESIGN.md
.brain/rules/git/safety.md|.ai/rules/GIT_SAFETY.md
.brain/rules/architecture/orchestration.md|.ai/rules/ORCHESTRATION.md
.brain/templates/MEMORY_DECISION.md|.ai/templates/MEMORY_DECISION.md
.brain/templates/GUIDELINES.md|.ai/templates/GUIDELINES.md
.brain/templates/plan/PLAN_TEMPLATE.md|.ai/templates/PLAN_TEMPLATE.md
.brain/templates/test-case/TC_TEMPLATE.md|.ai/templates/TC_TEMPLATE.md
.brain/templates/summary/PLAN_SUMMARY.md|.ai/templates/PLAN_SUMMARY.md
.ai/memory-timeline.py|.ai/memory-timeline.py
.ai/skills-diff.sh|.ai/skills-diff.sh
docs/config-guide.yaml|.ai/docs/config-guide.yaml
CLAUDE.install.md|.ai/CLAUDE.md
FILES_EOF
)"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  RAI-Engineering — Updater (non-destructive)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

MANIFEST="$BRAIN_DIR/state/system-manifest.sha256"
VERSION_FILE="$BRAIN_DIR/state/version"
MIG_LOG="$BRAIN_DIR/state/migrations.log"

# ── State detection ────────────────────────────────────────────────────
read_brain_version() {
    if [ ! -d "$BRAIN_DIR" ]; then
        echo "none"
    elif [ -f "$VERSION_FILE" ] && grep -q "^RAI_BRAIN_VERSION=" "$VERSION_FILE" 2>/dev/null; then
        grep "^RAI_BRAIN_VERSION=" "$VERSION_FILE" | cut -d= -f2 | tr -d '[:space:]'
    else
        echo "1"
    fi
}

CURRENT_VERSION="$(read_brain_version)"

has_domain_layout() {
    for d in backend frontend devops mobile-ios mobile-android shared brain; do
        [ -d "$BRAIN_DIR/$d" ] && return 0
    done
    return 1
}

legacy_structures_present() {
    has_domain_layout && return 0
    for d in planning tests tasks decisions notes; do
        [ -d "$BRAIN_DIR/$d" ] && return 0
    done
    return 1
}

case "$CURRENT_VERSION" in
    none) STATE="fresh" ;;
    "$TARGET_BRAIN_VERSION") STATE="current" ;;
    *) STATE="upgrade" ;;
esac
if [ "$STATE" = "upgrade" ] && has_domain_layout; then
    STATE="migrate-domains"
fi

echo -e "   Brain state: ${CYAN}$STATE${NC} (installed version: ${CYAN}$CURRENT_VERSION${NC}, target: ${CYAN}$TARGET_BRAIN_VERSION${NC})"

if [ "$CHECK_ONLY" = true ]; then
    echo ""
    echo -e "   ${CYAN}[check mode — no changes will be made]${NC}"
    case "$STATE" in
        fresh) echo "   Would create: $BRAIN_DIR purpose tree + system files + version $TARGET_BRAIN_VERSION" ;;
        current) echo "   Would verify: system file checksums vs manifest; refresh only missing/untouched files" ;;
        upgrade|migrate-domains)
            echo "   Would: backup .brain, migrate structure to v$TARGET_BRAIN_VERSION (merge, never delete),"
            echo "   then refresh system files with conflict policy (.new on user-modified)"
            ;;
    esac
    has_domain_layout && echo "   Legacy domain dirs present: $(for d in backend frontend devops mobile-ios mobile-android shared brain; do [ -d "$BRAIN_DIR/$d" ] && printf '%s ' "$d"; done)"
    echo ""
    exit 0
fi

# ── Helpers ────────────────────────────────────────────────────────────
fetch_source() {
    # $1 = source-rel path → prints content to stdout. Returns non-zero on failure.
    local src="$1"
    if [ "$LOCAL_SRC" = true ]; then
        # RAI_SOURCE_DIR lets callers (setup.sh, tests) point at a source tree
        # that differs from this script's own directory.
        cat "${RAI_SOURCE_DIR:-$SCRIPT_DIR}/$src"
    else
        curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/$src"
    fi
}

migrate_log() {
    # $1 = action, $2 = detail (paths/counts only — never file contents)
    local line="$(date -u +%Y-%m-%dT%H:%M:%SZ) | $1 | $2"
    mkdir -p "$(dirname "$MIG_LOG")"
    echo "$line" >> "$MIG_LOG"
}

manifest_hash() {
    # $1 = dest-rel → recorded hash or empty
    local dest="$1"
    if [ -f "$MANIFEST" ]; then
        grep -F "  $dest" "$MANIFEST" 2>/dev/null | awk '{print $1}' || true
    fi
}

record_manifest() {
    # Rebuild manifest from currently installed system files (post-operation truth).
    local tmp
    tmp="$(mktemp)"
    while IFS='|' read -r _src dest; do
        [ -z "$dest" ] && continue
        if [ -f "$dest" ] && [ "$dest" != "$dest.new" ]; then
            printf '%s  %s\n' "$(sha "$dest")" "$dest" >> "$tmp"
        fi
    done <<< "$SYSTEM_FILES"$'\n'"$AI_FILES"
    mkdir -p "$(dirname "$MANIFEST")"
    sort "$tmp" -o "$MANIFEST"
    rm -f "$tmp"
}

install_file() {
    # $1 = source-rel, $2 = dest-rel. Safe policy with manifest comparison.
    # Sets global INSTALL_RESULT: installed|updated|skipped|conflict|error
    local src="$1" dest="$2"
    local tmp
    tmp="$(mktemp)"
    if ! fetch_source "$src" > "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        INSTALL_RESULT="error"
        add_warning "fetch failed: $src"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [ ! -f "$dest" ]; then
        cat "$tmp" > "$dest"
        INSTALL_RESULT="installed"
    elif cmp -s "$tmp" "$dest"; then
        INSTALL_RESULT="skipped"
    else
        local recorded
        recorded="$(manifest_hash "$dest")"
        if [ -n "$recorded" ] && [ "$(sha "$dest")" = "$recorded" ]; then
            cat "$tmp" > "$dest"
            INSTALL_RESULT="updated"
        else
            if [ -f "$dest.new" ] && cmp -s "$tmp" "$dest.new"; then
                INSTALL_RESULT="skipped"
            else
                cat "$tmp" > "$dest.new"
                INSTALL_RESULT="conflict"
                add_warning "customized file preserved: $dest (incoming saved as $dest.new)"
            fi
        fi
    fi
    rm -f "$tmp"
}

merge_move() {
    # $1 = source file, $2 = dest file. Move only if dest absent; else keep + report.
    local src="$1" dest="$2"
    if [ ! -f "$src" ]; then
        return 0
    fi
    if [ ! -f "$dest" ]; then
        mkdir -p "$(dirname "$dest")"
        mv "$src" "$dest"
        echo "moved:$src->$dest" >> "${MERGE_REPORT:-/dev/null}"
    else
        add_warning "merge conflict (both exist, kept original): $src — not overwriting $dest"
        echo "kept:$src (dest exists: $dest)" >> "${MERGE_REPORT:-/dev/null}"
    fi
}

merge_dir_contents() {
    # $1 = source dir, $2 = dest dir. Move files over (merge); never overwrite.
    local src="$1" dest="$2"
    [ -d "$src" ] || return 0
    mkdir -p "$dest"
    local f rel
    while IFS= read -r f; do
        rel="${f#$src/}"
        merge_move "$f" "$dest/$rel"
    done < <(find "$src" -type f | sort)
}

ensure_tree() {
    mkdir -p "$BRAIN_DIR"/{constitution,context/connections,knowledge/{architecture,components,database,api,infrastructure,security,patterns},memory/{decisions,discoveries,lessons,incidents,sessions},plans/{active,completed,blocked,archived},test-cases/{active,completed,failed,archived},summaries/{active,completed,archived},agents,skills,rules/{coding,architecture,database,api,testing,security,performance,infrastructure,git},reference,templates/{plan,test-case,summary,testing},sessions/live,session-bus,state,_deprecated/old-domains}
    mkdir -p "$AI_DIR"/{brain,agents,rules,skills,templates,workflows,docs}
    # Keep lifecycle dirs present even when empty (git does not track empty dirs).
    local d
    for d in "$BRAIN_DIR"/plans/active "$BRAIN_DIR"/plans/blocked \
             "$BRAIN_DIR"/test-cases/active "$BRAIN_DIR"/test-cases/failed "$BRAIN_DIR"/test-cases/archived \
             "$BRAIN_DIR"/summaries/active \
             "$BRAIN_DIR"/memory/discoveries "$BRAIN_DIR"/memory/incidents "$BRAIN_DIR"/memory/sessions; do
        if [ -d "$d" ] && [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
            touch "$d/.gitkeep"
        fi
    done
}

ensure_gitignore() {
    local want1=".brain/context/connections/"
    local want2=".brain/.migration/"
    local want3=".brain/session-bus/"
    local want4=".brain/sessions/live/"
    local changed=false
    for want in "$want1" "$want2" "$want3" "$want4"; do
        if [ -f ".gitignore" ]; then
            grep -qF "$want" ".gitignore" 2>/dev/null || { echo "$want" >> ".gitignore"; changed=true; }
        else
            echo "$want" >> ".gitignore"; changed=true
        fi
    done
    # Drop obsolete domain connection entries (they no longer exist post-migration).
    if [ -f ".gitignore" ] && grep -q "brain/backend/connections" ".gitignore" 2>/dev/null; then
        sed -i '/\.brain\/backend\/connections\//d; /\.brain\/frontend\/connections\//d; /\.brain\/mobile-ios\/connections\//d; /\.brain\/mobile-android\/connections\//d; /\.brain\/devops\/connections\//d' ".gitignore"
        changed=true
    fi
    if [ "$changed" = true ]; then
        ok ".gitignore updated (secrets/ephemeral excluded)"
    fi
    return 0
}

do_backup() {
    # $1 = old version, $2 = new version. Snapshot .brain before structural change.
    local old="$1" new="$2"
    local ts
    ts="$(date -u +%Y%m%dT%H%M%SZ)"
    local dest="$BRAIN_DIR/.migration/backup-$ts-v$old-to-v$new.tgz"
    mkdir -p "$BRAIN_DIR/.migration"
    tar -czf "$dest" --exclude="$(basename "$BRAIN_DIR")/.migration" -C "$(dirname "$BRAIN_DIR")" "$(basename "$BRAIN_DIR")"
    ok "backup created: $dest"
    migrate_log "backup" "created $dest"
}

write_version() {
    mkdir -p "$(dirname "$VERSION_FILE")"
    printf 'RAI_BRAIN_VERSION=%s\n' "$TARGET_BRAIN_VERSION" > "$VERSION_FILE"
}

# ── v1 → v2 structural migration (domain-first → purpose-organized) ─────
migrate_v1_to_v2() {
    log "migrating brain structure v1 → v2 (merge, never delete)..."
    MERGE_REPORT="$(mktemp)"
    export MERGE_REPORT

    tag_domains() {
        local tag="$1"; shift
        local f tmp
        for f in "$@"; do
            [ -f "$f" ] || continue
            head -n 1 "$f" | grep -q "^---$" && continue
            tmp="$(mktemp)"
            printf -- "---\ndomains: [%s]\n---\n\n" "$tag" > "$tmp"
            cat "$f" >> "$tmp"
            cat "$tmp" > "$f"
            rm -f "$tmp"
        done
    }
    move_rule() {
        local src="$1" dest="$2" tag="$3"
        if [ -f "$BRAIN_DIR/$src" ]; then
            if [ ! -f "$BRAIN_DIR/rules/$dest" ]; then
                mkdir -p "$BRAIN_DIR/rules/$(dirname "$dest")"
                mv "$BRAIN_DIR/$src" "$BRAIN_DIR/rules/$dest"
                tag_domains "$tag" "$BRAIN_DIR/rules/$dest"
                echo "moved:$src->rules/$dest" >> "$MERGE_REPORT"
            else
                # Same purpose, different content: preserve user's file for review.
                local imp="$BRAIN_DIR/rules/_imported/$(echo "$src" | tr '/' '-')"
                merge_move "$BRAIN_DIR/$src" "$imp"
                add_warning "rule diverged, user version preserved for review: $imp"
            fi
        fi
    }
    import_skill() {
        # $1 = source skill file, $2 = domains tag. New location occupied → _imported/.
        local src="$1" tag="$2" b="$3"
        if [ ! -f "$BRAIN_DIR/skills/$b" ]; then
            mv "$src" "$BRAIN_DIR/skills/$b"
            tag_domains "$tag" "$BRAIN_DIR/skills/$b"
            echo "moved:$src->skills/$b" >> "$MERGE_REPORT"
        else
            local imp="$BRAIN_DIR/skills/_imported/$b"
            merge_move "$src" "$imp"
            add_warning "skill diverged, user version preserved for review: $imp"
        fi
    }

    # constitution + reference (from .brain/brain/)
    [ -f "$BRAIN_DIR/brain/MISSION.md" ] && merge_move "$BRAIN_DIR/brain/MISSION.md" "$BRAIN_DIR/constitution/MISSION.md"
    [ -f "$BRAIN_DIR/brain/PRINCIPLES.md" ] && merge_move "$BRAIN_DIR/brain/PRINCIPLES.md" "$BRAIN_DIR/constitution/PRINCIPLES.md"
    [ -f "$BRAIN_DIR/brain/RULES.md" ] && merge_move "$BRAIN_DIR/brain/RULES.md" "$BRAIN_DIR/constitution/RULES.md"
    [ -f "$BRAIN_DIR/brain/LIMITATIONS.md" ] && merge_move "$BRAIN_DIR/brain/LIMITATIONS.md" "$BRAIN_DIR/constitution/CONSTRAINTS.md"
    [ -f "$BRAIN_DIR/brain/SYSTEM.md" ] && merge_move "$BRAIN_DIR/brain/SYSTEM.md" "$BRAIN_DIR/reference/message-protocol.md"
    [ -f "$BRAIN_DIR/brain/ORCHESTRATION.md" ] && merge_move "$BRAIN_DIR/brain/ORCHESTRATION.md" "$BRAIN_DIR/reference/orchestration-protocol.md"
    [ -f "$BRAIN_DIR/brain/INTER_SESSION.md" ] && merge_move "$BRAIN_DIR/brain/INTER_SESSION.md" "$BRAIN_DIR/reference/inter-session-protocol.md"
    [ -f "$BRAIN_DIR/brain/MEMORY_SYSTEM.md" ] && merge_move "$BRAIN_DIR/brain/MEMORY_SYSTEM.md" "$BRAIN_DIR/_deprecated/old-domains/MEMORY_SYSTEM.md"
    # Any other files under brain/ are user content until proven otherwise → preserve for review.
    if [ -d "$BRAIN_DIR/brain" ] && [ -n "$(ls -A "$BRAIN_DIR/brain" 2>/dev/null)" ]; then
        mkdir -p "$BRAIN_DIR/_deprecated/old-domains/brain-leftover"
        merge_dir_contents "$BRAIN_DIR/brain" "$BRAIN_DIR/_deprecated/old-domains/brain-leftover"
        rmdir "$BRAIN_DIR/brain" 2>/dev/null || add_warning "leftover files kept for review: $BRAIN_DIR/brain/"
    else
        rmdir "$BRAIN_DIR/brain" 2>/dev/null || true
    fi

    # shared skills → skills/ (universal, untagged)
    if [ -d "$BRAIN_DIR/shared/skills" ]; then
        for f in "$BRAIN_DIR"/shared/skills/*.md; do
            [ -f "$f" ] || continue
            merge_move "$f" "$BRAIN_DIR/skills/$(basename "$f")"
        done
        merge_dir_contents "$BRAIN_DIR/shared" "$BRAIN_DIR/_deprecated/old-domains/shared-leftover"
        if [ -n "$(ls -A "$BRAIN_DIR/shared" 2>/dev/null)" ]; then
            add_warning "leftover files kept in place for manual review: $BRAIN_DIR/shared/"
        else
            rmdir "$BRAIN_DIR/shared" 2>/dev/null || true
        fi
    fi

    # backend / frontend / devops rules → rules/<purpose>/ (tagged)
    move_rule "backend/rules/API_DESIGN.md" "api/design.md" "backend"
    move_rule "backend/rules/DATABASE.md" "database/database.md" "backend"
    move_rule "backend/rules/SECURITY.md" "security/backend.md" "backend"
    move_rule "backend/rules/TESTING_RULES.md" "testing/testing.md" "backend"
    move_rule "backend/rules/ERROR_HANDLING.md" "coding/error-handling.md" "backend"
    move_rule "backend/rules/NAMING_CONVENTIONS.md" "coding/naming.md" "backend"
    move_rule "backend/rules/COMMIT_MESSAGES.md" "git/commit-messages.md" "backend"
    move_rule "backend/rules/GIT_SAFETY.md" "git/safety.md" "backend"
    move_rule "backend/rules/orchestration-rules.md" "architecture/orchestration.md" "backend"
    [ -f "$BRAIN_DIR/backend/rules/project-rules.md" ] && merge_move "$BRAIN_DIR/backend/rules/project-rules.md" "$BRAIN_DIR/_deprecated/old-domains/backend-project-rules.md"
    move_rule "frontend/rules/COMPONENT_ARCHITECTURE.md" "architecture/components.md" "frontend"
    move_rule "frontend/rules/STATE_MANAGEMENT.md" "coding/state-management.md" "frontend"
    move_rule "frontend/rules/PERFORMANCE.md" "performance/frontend.md" "frontend"
    move_rule "frontend/rules/ACCESSIBILITY.md" "coding/accessibility.md" "frontend"
    move_rule "frontend/rules/STYLING.md" "coding/styling.md" "frontend"
    move_rule "frontend/rules/ERROR_LOADING_UX.md" "coding/error-ux.md" "frontend"
    move_rule "frontend/rules/API_INTEGRATION.md" "api/frontend-integration.md" "frontend"
    move_rule "frontend/rules/TESTING.md" "testing/frontend.md" "frontend"
    move_rule "frontend/rules/SECURITY.md" "security/frontend.md" "frontend"
    move_rule "frontend/rules/FORMS_AND_INPUT.md" "coding/forms.md" "frontend"
    move_rule "frontend/rules/BUILD_TOOLING.md" "infrastructure/build-tooling.md" "frontend"
    move_rule "devops/rules/AUTOMATION_SCRIPTING.md" "infrastructure/automation-scripting.md" "devops"
    move_rule "devops/rules/BACKUP_DR_INCIDENT.md" "infrastructure/backup-dr-incident.md" "devops"
    move_rule "devops/rules/CI_CD.md" "infrastructure/ci-cd.md" "devops"
    move_rule "devops/rules/CLOUD_SERVICES.md" "infrastructure/cloud-services.md" "devops"
    move_rule "devops/rules/CONTAINERS.md" "infrastructure/containers.md" "devops"
    move_rule "devops/rules/COST_OPTIMIZATION.md" "infrastructure/cost-optimization.md" "devops"
    move_rule "devops/rules/DATABASE_OPS.md" "database/ops.md" "devops"
    move_rule "devops/rules/DEVOPS_SECURITY.md" "security/devops.md" "devops"
    move_rule "devops/rules/INFRASTRUCTURE_AS_CODE.md" "infrastructure/infra-as-code.md" "devops"
    move_rule "devops/rules/KUBERNETES.md" "infrastructure/kubernetes.md" "devops"
    move_rule "devops/rules/MONITORING_OBSERVABILITY.md" "infrastructure/monitoring.md" "devops"
    move_rule "devops/rules/NETWORKING_DNS.md" "infrastructure/networking-dns.md" "devops"
    move_rule "devops/rules/RELEASE_MANAGEMENT.md" "infrastructure/release-management.md" "devops"
    # Unknown rule files are user rules until proven otherwise → merge into rules/_imported/.
    for d in backend frontend devops mobile-ios mobile-android; do
        if [ -d "$BRAIN_DIR/$d/rules" ]; then
            for f in "$BRAIN_DIR"/$d/rules/*.md; do
                [ -f "$f" ] || continue
                merge_move "$f" "$BRAIN_DIR/rules/_imported/$d-$(basename "$f")"
            done
        fi
    done

    # domain skills → skills/<domain>-* (tagged)
    for f in "$BRAIN_DIR"/backend/skills/*.md; do
        [ -f "$f" ] || continue
        import_skill "$f" "backend" "backend-$(basename "$f")"
    done
    for f in "$BRAIN_DIR"/frontend/skills/*.md; do
        [ -f "$f" ] || continue
        import_skill "$f" "frontend" "frontend-$(basename "$f")"
    done
    for f in "$BRAIN_DIR"/devops/skills/*.md; do
        [ -f "$f" ] || continue
        import_skill "$f" "devops" "devops-$(basename "$f")"
    done

    # memory → memory/ + summaries/archived/ (pre-lifecycle task records)
    for f in "$BRAIN_DIR"/backend/memory/decisions/*.md "$BRAIN_DIR"/frontend/memory/decisions/*.md; do
        [ -f "$f" ] || continue
        merge_move "$f" "$BRAIN_DIR/memory/decisions/$(basename "$f")"
    done
    for f in "$BRAIN_DIR"/backend/memory/lessons/*.md "$BRAIN_DIR"/frontend/memory/lessons/*.md; do
        [ -f "$f" ] || continue
        merge_move "$f" "$BRAIN_DIR/memory/lessons/$(basename "$f")"
    done
    for f in "$BRAIN_DIR"/backend/memory/tasks/*.md "$BRAIN_DIR"/frontend/memory/tasks/*.md; do
        [ -f "$f" ] || continue
        merge_move "$f" "$BRAIN_DIR/summaries/archived/$(basename "$f")"
    done
    for d in backend frontend devops mobile-ios mobile-android; do
        for sub in architecture sessions business discoveries incidents; do
            [ -d "$BRAIN_DIR/$d/memory/$sub" ] || continue
            for f in "$BRAIN_DIR"/$d/memory/$sub/*.md; do
                [ -f "$f" ] || continue
                merge_move "$f" "$BRAIN_DIR/memory/$sub/$(basename "$f")"
            done
        done
    done
    if [ -f "$BRAIN_DIR/backend/memory/guidelines.md" ]; then
        if [ ! -f "$BRAIN_DIR/knowledge/patterns/backend-service-layer-guidelines.md" ]; then
            mv "$BRAIN_DIR/backend/memory/guidelines.md" "$BRAIN_DIR/knowledge/patterns/backend-service-layer-guidelines.md"
            tag_domains "backend" "$BRAIN_DIR/knowledge/patterns/backend-service-layer-guidelines.md"
        else
            add_warning "guidelines already migrated, kept original for review: backend/memory/guidelines.md"
        fi
    fi

    # knowledge docs + reference
    [ -f "$BRAIN_DIR/frontend/FRONTEND_BEST_PRACTICES.md" ] && merge_move "$BRAIN_DIR/frontend/FRONTEND_BEST_PRACTICES.md" "$BRAIN_DIR/knowledge/patterns/frontend-best-practices.md"
    [ -f "$BRAIN_DIR/devops/DEVOPS_BEST_PRACTICES.md" ] && merge_move "$BRAIN_DIR/devops/DEVOPS_BEST_PRACTICES.md" "$BRAIN_DIR/knowledge/infrastructure/devops-practices.md"
    [ -f "$BRAIN_DIR/frontend/reference/mantine.md" ] && merge_move "$BRAIN_DIR/frontend/reference/mantine.md" "$BRAIN_DIR/reference/mantine.md"

    # plans → plans/archived/<date>-<slug>/ (pre-lifecycle, honest provenance)
    for f in "$BRAIN_DIR"/backend/plans/*.md "$BRAIN_DIR"/frontend/plans/*.md "$BRAIN_DIR"/devops/plans/*.md; do
        [ -f "$f" ] || continue
        plan_id_for "$f" "$BRAIN_DIR/plans/archived"
        id="$PLAN_NEW_ID"
        mkdir -p "$BRAIN_DIR/plans/archived/$id"
        mv "$f" "$BRAIN_DIR/plans/archived/$id/PLAN.md"
        printf '# Status %s\n\n**Status:** archived (pre-lifecycle)\n' "$id" > "$BRAIN_DIR/plans/archived/$id/STATUS.md"
        echo "moved:$f->plans/archived/$id/PLAN.md" >> "$MERGE_REPORT"
    done

    # connections/ → context/connections/ (still gitignored)
    for d in backend frontend mobile-ios mobile-android devops; do
        [ -d "$BRAIN_DIR/$d/connections" ] || continue
        for f in "$BRAIN_DIR"/$d/connections/*; do
            [ -f "$f" ] || continue
            merge_move "$f" "$BRAIN_DIR/context/connections/$(basename "$f")"
        done
        rmdir "$BRAIN_DIR/$d/connections" 2>/dev/null || true
    done

    # leftover domain stubs → _deprecated, remove domain dirs only when empty
    for d in backend frontend devops mobile-ios mobile-android; do
        [ -d "$BRAIN_DIR/$d" ] || continue
        [ -f "$BRAIN_DIR/$d/README.md" ] && merge_move "$BRAIN_DIR/$d/README.md" "$BRAIN_DIR/_deprecated/old-domains/$d-README.md"
        [ -f "$BRAIN_DIR/$d/INDEX.md" ] && merge_move "$BRAIN_DIR/$d/INDEX.md" "$BRAIN_DIR/_deprecated/old-domains/$d-INDEX.md"
        # Anything still left is unknown user content → preserve for review, do NOT delete.
        find "$BRAIN_DIR/$d" -depth -type d -empty -delete 2>/dev/null || true
        if [ -n "$(find "$BRAIN_DIR/$d" -type f 2>/dev/null)" ]; then
            mkdir -p "$BRAIN_DIR/_deprecated/old-domains/$d-leftover"
            merge_dir_contents "$BRAIN_DIR/$d" "$BRAIN_DIR/_deprecated/old-domains/$d-leftover"
            if [ -n "$(find "$BRAIN_DIR/$d" -type f 2>/dev/null)" ]; then
                add_warning "unmigrated content kept in place for manual review: $BRAIN_DIR/$d/"
            else
                find "$BRAIN_DIR/$d" -depth -type d -empty -delete 2>/dev/null || true
                rmdir "$BRAIN_DIR/$d" 2>/dev/null || true
            fi
        else
            rmdir "$BRAIN_DIR/$d" 2>/dev/null || true
        fi
    done

    local moved kept
    moved="$(grep -c "^moved:" "$MERGE_REPORT" 2>/dev/null || true)"
    kept="$(grep -c "^kept:" "$MERGE_REPORT" 2>/dev/null || true)"
    migrate_log "migrate-v1-to-v2" "moved=$moved kept-for-review=$kept"
    ok "structure migrated v1 → v2 (moved: $moved, kept for review: $kept)"
    rm -f "$MERGE_REPORT"
    unset MERGE_REPORT
}

# ── Legacy user-data dirs at .brain root (tests/tasks/decisions/notes/...) ─
migrate_legacy_user_dirs() {
    # old planning/ → plans/ (merge, never overwrite)
    if [ -d "$BRAIN_DIR/planning" ]; then
        for sub in active completed blocked archived; do
            [ -d "$BRAIN_DIR/planning/$sub" ] || continue
            mkdir -p "$BRAIN_DIR/plans/$sub"
            for entry in "$BRAIN_DIR"/planning/$sub/*; do
                [ -e "$entry" ] || continue
                base="$(basename "$entry")"
                if [ ! -e "$BRAIN_DIR/plans/$sub/$base" ]; then
                    mv "$entry" "$BRAIN_DIR/plans/$sub/$base"
                else
                    add_warning "plan entry exists in both layouts, kept legacy for review: $entry"
                fi
            done
            rmdir "$BRAIN_DIR/planning/$sub" 2>/dev/null || true
        done
        rmdir "$BRAIN_DIR/planning" 2>/dev/null || add_warning "leftover files kept for review: $BRAIN_DIR/planning/"
    fi
    [ -d "$BRAIN_DIR/tests" ] && merge_dir_contents "$BRAIN_DIR/tests" "$BRAIN_DIR/test-cases/_imported" && rmdir "$BRAIN_DIR/tests" 2>/dev/null || true
    [ -d "$BRAIN_DIR/tasks" ] && merge_dir_contents "$BRAIN_DIR/tasks" "$BRAIN_DIR/summaries/_imported" && rmdir "$BRAIN_DIR/tasks" 2>/dev/null || true
    [ -d "$BRAIN_DIR/decisions" ] && merge_dir_contents "$BRAIN_DIR/decisions" "$BRAIN_DIR/memory/decisions" && rmdir "$BRAIN_DIR/decisions" 2>/dev/null || true
    [ -d "$BRAIN_DIR/notes" ] && merge_dir_contents "$BRAIN_DIR/notes" "$BRAIN_DIR/memory/discoveries" && rmdir "$BRAIN_DIR/notes" 2>/dev/null || true
    # legacy sessions/ holds session logs → memory/sessions (registry files stay)
    if [ -d "$BRAIN_DIR/sessions" ]; then
        for f in "$BRAIN_DIR"/sessions/*.md; do
            [ -f "$f" ] || continue
            merge_move "$f" "$BRAIN_DIR/memory/sessions/$(basename "$f")"
        done
    fi
}

# ── v2 → v3 plan naming (PLAN-XXXX → <date>-<slug>) ─────────────────────
slugify() {
    # $1 = text → lowercase hyphenated slug (max 60 chars).
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9][^a-z0-9]*/-/g; s/^-\+//; s/-\+$//' | cut -c1-60
}

plan_id_for() {
    # $1 = PLAN.md path (or plan file), $2 = parent dir for collision check.
    # Sets global PLAN_NEW_ID to <mtime-date>-<slug> (-2 on collision).
    local head slug fdate base cand i
    head="$(grep -m1 '^# ' "$1" 2>/dev/null | sed 's/^# //')"
    head="$(printf '%s' "$head" | sed -E 's/^PLAN-[0-9]+( — | - |: )//; s/^[Pp]lan: //')"
    if [ -z "$head" ]; then
        head="$(basename "$1" .md)"
        if [ "$head" = "PLAN" ]; then
            head="$(basename "$(dirname "$1")")"
        fi
    fi
    slug="$(slugify "$head")"
    [ -z "$slug" ] && slug="plan"
    fdate="$(stat -c %y "$1" 2>/dev/null | cut -d' ' -f1)"
    case "$fdate" in
        ????-??-??) ;;
        *) fdate="$(date -u +%F)" ;;
    esac
    base="$fdate-$slug"
    cand="$base"; i=2
    while [ -e "$2/$cand" ]; do cand="$base-$i"; i=$((i + 1)); done
    PLAN_NEW_ID="$cand"
}

migrate_v2_to_v3() {
    log "migrating plan naming v2 → v3 (PLAN-XXXX → date-slug, merge, never delete)..."
    local map renamed statedir dir old new f otc ntc n sedf
    map="$(mktemp)"
    renamed=0
    # Phase 1: plans/*/<PLAN-NNNN>/ → <date>-<slug>/
    for statedir in active completed blocked archived; do
        [ -d "$BRAIN_DIR/plans/$statedir" ] || continue
        for dir in "$BRAIN_DIR"/plans/$statedir/PLAN-[0-9]*; do
            [ -d "$dir" ] || continue
            old="$(basename "$dir")"
            if [ -f "$dir/PLAN.md" ]; then
                plan_id_for "$dir/PLAN.md" "$BRAIN_DIR/plans/$statedir"
            else
                PLAN_NEW_ID="$(slugify "$old")"
            fi
            new="$PLAN_NEW_ID"
            mv "$dir" "$BRAIN_DIR/plans/$statedir/$new"
            printf '%s|%s\n' "$old" "$new" >> "$map"
            renamed=$((renamed + 1))
        done
    done
    # Phase 2: test-cases/*/<old>/ → <new>/ + TC-NNNN → TC-NN + Plan field
    for statedir in active completed failed archived; do
        [ -d "$BRAIN_DIR/test-cases/$statedir" ] || continue
        while IFS='|' read -r old new; do
            [ -z "$old" ] && continue
            dir="$BRAIN_DIR/test-cases/$statedir/$old"
            [ -d "$dir" ] || continue
            mv "$dir" "$BRAIN_DIR/test-cases/$statedir/$new"
            dir="$BRAIN_DIR/test-cases/$statedir/$new"
            n=0
            for f in "$dir"/TC-[0-9]*.md; do
                [ -f "$f" ] || continue
                n=$((n + 1))
                ntc="$(printf 'TC-%02d' "$n")"
                mv "$f" "$dir/$ntc.tmp"
                printf 's|\\b%s\\b|%s|g\n' "$(basename "$f" .md)" "$ntc" >> "$dir/.tcsed"
            done
            for f in "$dir"/TC-*.tmp; do
                [ -f "$f" ] || continue
                mv "$f" "${f%.tmp}.md"
            done
            if [ -f "$dir/.tcsed" ]; then
                for f in "$dir"/*.md; do
                    [ -f "$f" ] || continue
                    sed -i -f "$dir/.tcsed" "$f"
                done
                rm -f "$dir/.tcsed"
            fi
            sed -i "s|^\(\*\*Plan:\*\*\) $old\$|\1 $new|" "$dir"/*.md 2>/dev/null || true
            renamed=$((renamed + 1))
        done < "$map"
    done
    # Phase 3: summaries <old>.md / <old>-*.md → <new> prefix
    for statedir in active completed archived; do
        [ -d "$BRAIN_DIR/summaries/$statedir" ] || continue
        while IFS='|' read -r old new; do
            [ -z "$old" ] && continue
            for f in "$BRAIN_DIR"/summaries/$statedir/"$old".md "$BRAIN_DIR"/summaries/$statedir/"$old"-*.md; do
                [ -f "$f" ] || continue
                mv "$f" "$BRAIN_DIR/summaries/$statedir/$new${f#$BRAIN_DIR/summaries/$statedir/$old}"
                renamed=$((renamed + 1))
            done
        done < "$map"
    done
    # Phase 4: state pointers — mapped plan IDs; drop retired counter
    for f in "$BRAIN_DIR"/state/plans.yaml "$BRAIN_DIR"/state/tasks.yaml \
             "$BRAIN_DIR"/state/tests.yaml "$BRAIN_DIR"/state/current.yaml \
             "$BRAIN_DIR"/state/agents.yaml; do
        [ -f "$f" ] || continue
        while IFS='|' read -r old new; do
            [ -z "$old" ] && continue
            sed -i "s|\b$old\b|$new|g" "$f"
        done < "$map"
    done
    if [ -f "$BRAIN_DIR/state/plans.yaml" ]; then
        sed -i '/^next_plan_id:/d' "$BRAIN_DIR/state/plans.yaml"
    fi
    if grep -qE "TC-[0-9]{4}" "$BRAIN_DIR/state/tests.yaml" 2>/dev/null; then
        add_warning "bare TC-XXXX refs kept verbatim in state/tests.yaml (pre-slug era)"
    fi
    rm -f "$map"
    migrate_log "migrate-v2-to-v3" "renamed=$renamed"
    ok "plan naming migrated v2 → v3 (renamed: $renamed)"
}

# ── Loose plan recovery (runs every update) ────────────────────────────
recover_loose_plans() {
    # Loose *.md files sitting directly in plans/ (old convention) → wrap each
    # into plans/completed/<id>/PLAN.md + STATUS.md (completed). Filenames
    # already shaped <date>-<slug> keep their name; others derive via plan_id_for.
    # No-op when clean. State pointers appended (deduped).
    local f base id stem n
    for f in "$BRAIN_DIR"/plans/*.md; do
        [ -f "$f" ] || continue
        base="$(basename "$f" .md)"
        case "$base" in
            ????-??-??-*) id="$base" ;;
            *) plan_id_for "$f" "$BRAIN_DIR/plans/completed"; id="$PLAN_NEW_ID" ;;
        esac
        stem="$id"; n=2
        while [ -e "$BRAIN_DIR/plans/completed/$id" ]; do
            id="$stem-$n"; n=$((n + 1))
        done
        mkdir -p "$BRAIN_DIR/plans/completed/$id"
        mv "$f" "$BRAIN_DIR/plans/completed/$id/PLAN.md"
        printf '# Status %s\n\n**Status:** completed (recovered loose file from plans/)\n' "$id" \
            > "$BRAIN_DIR/plans/completed/$id/STATUS.md"
        if [ -f "$BRAIN_DIR/state/plans.yaml" ] \
            && ! grep -qF "  - $id" "$BRAIN_DIR/state/plans.yaml" 2>/dev/null; then
            printf '  - %s\n' "$id" >> "$BRAIN_DIR/state/plans.yaml"
        fi
        migrate_log "recover-loose-plan" "wrapped $base → plans/completed/$id/"
        ok "loose plan recovered: plans/$base.md → plans/completed/$id/"
    done
}

# ── System file refresh ────────────────────────────────────────────────
refresh_system_files() {
    local installed=0 updated=0 skipped=0 conflicts=0 errors=0
    while IFS='|' read -r src dest; do
        [ -z "$src" ] && continue
        install_file "$src" "$dest"
        case "${INSTALL_RESULT:-error}" in
            installed) installed=$((installed + 1)) ;;
            updated) updated=$((updated + 1)) ;;
            skipped) skipped=$((skipped + 1)) ;;
            conflict) conflicts=$((conflicts + 1)) ;;
            *) errors=$((errors + 1)) ;;
        esac
    done <<< "$SYSTEM_FILES"$'\n'"$AI_FILES"
    migrate_log "refresh-system-files" "installed=$installed updated=$updated skipped=$skipped conflicts=$conflicts errors=$errors"
    log "system files: installed=$installed updated=$updated skipped=$skipped conflicts=$conflicts errors=$errors"
}

# ── AI tool adapters (thin, never overwrite user files) ────────────────
ensure_adapters() {
    for tool in claude opencode codex; do
        if command -v "$tool" >/dev/null 2>&1; then
            log "detected AI tool: $tool"
        fi
    done
    # CLAUDE.md at root: recreate symlink only if missing (never overwrite).
    if [ ! -e "CLAUDE.md" ]; then
        if [ -f "$AI_DIR/CLAUDE.md" ]; then
            ln -sf "$AI_DIR/CLAUDE.md" "./CLAUDE.md"
            ok "CLAUDE.md symlink restored"
        elif [ "$LOCAL_SRC" = true ] && [ -f "${RAI_SOURCE_DIR:-$SCRIPT_DIR}/CLAUDE.install.md" ]; then
            cp "${RAI_SOURCE_DIR:-$SCRIPT_DIR}/CLAUDE.install.md" "$AI_DIR/CLAUDE.md"
            ln -sf "$AI_DIR/CLAUDE.md" "./CLAUDE.md"
            ok "CLAUDE.md installed (local)"
        else
            add_warning "CLAUDE.md missing and could not be restored (no .ai/CLAUDE.md)"
        fi
    fi
    # AGENTS.md: Opencode reads this (CLAUDE.md ignored when AGENTS.md exists),
    # so brain bootstrap must be enforced non-destructively — never overwrite user content.
    AGENTS_BOOTSTRAP='RAI-Engineering installed. `.brain/` exists → mandatory OS: read `.brain/INSTRUCTIONS.md`, then `.brain/ARCHITECTURE.md`, follow workflow. Plans → `plans/`. Tests → `test-cases/`. Summaries → `summaries/`. Done = Implemented + Verified + Tested + Documented + Summarized + Brain Updated.'
    if [ ! -f "AGENTS.md" ]; then
        if [ "$LOCAL_SRC" = true ] && [ -f "${RAI_SOURCE_DIR:-$SCRIPT_DIR}/AGENTS.md" ]; then
            cp "${RAI_SOURCE_DIR:-$SCRIPT_DIR}/AGENTS.md" "AGENTS.md"
            ok "AGENTS.md installed (OpenCode + agents read this)"
        elif fetch_source "AGENTS.md" > "AGENTS.md.tmp" 2>/dev/null; then
            mv "AGENTS.md.tmp" "AGENTS.md"
            ok "AGENTS.md installed (fetched)"
        else
            rm -f "AGENTS.md.tmp"
            printf '%s\n' "$AGENTS_BOOTSTRAP" > "AGENTS.md"
            ok "AGENTS.md bootstrap created"
        fi
    elif ! grep -qF ".brain/INSTRUCTIONS.md" "AGENTS.md" 2>/dev/null; then
        tmp_agents="$(mktemp)"
        { printf '%s\n\n' "$AGENTS_BOOTSTRAP"; cat "AGENTS.md"; } > "$tmp_agents"
        cat "$tmp_agents" > "AGENTS.md"
        rm -f "$tmp_agents"
        ok "AGENTS.md brain bootstrap enforced (user content preserved)"
        migrate_log "agents-bootstrap" "prepended brain bootstrap to existing AGENTS.md"
    fi
    # opencode.json: only ensure an instructions pointer when opencode is in use
    # and the file already exists — never create vendor config uninvited.
    if [ -f "opencode.json" ]; then
        log "opencode.json present — AGENTS.md already serves as its instruction entrypoint"
    fi
}

# ── Updater self-refresh (installed .ai/update.sh copies) ──────────────
refresh_self() {
    # Installed projects run <proj>/.ai/update.sh — a stale copy that never
    # refreshes itself (it is not in SYSTEM_FILES/AI_FILES). Without this,
    # updater fixes never reach existing installs. The updater is RAI-owned,
    # so overwrite is safe; one .bak is kept and fetch failures never fail the run.
    # Guard: only act when running as an installed copy (parent dir .ai) or
    # in --local mode. Never write into a bare cwd (curl-pipe runs) or clobber
    # a repo workspace from remote.
    if [ "$(basename "$SCRIPT_DIR")" != ".ai" ] && [ "$LOCAL_SRC" != true ]; then
        return 0
    fi
    local dest="$SCRIPT_DIR/update.sh"
    local tmp
    tmp="$(mktemp)"
    if ! fetch_source "update.sh" > "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        add_warning "self-update skipped: fetch failed"
        return 0
    fi
    if [ -f "$dest" ] && cmp -s "$tmp" "$dest"; then
        rm -f "$tmp"
        return 0
    fi
    if [ -f "$dest" ] && [ ! -f "$dest.bak" ]; then
        cp "$dest" "$dest.bak"
    fi
    mkdir -p "$(dirname "$dest")"
    cat "$tmp" > "$dest"
    chmod +x "$dest"
    rm -f "$tmp"
    ok "updater self-refresh (.ai/update.sh)"
    migrate_log "self-update" "refreshed running updater copy"
}

# ── Main dispatch ──────────────────────────────────────────────────────
case "$STATE" in
    fresh)
        log "fresh installation → creating purpose-organized brain..."
        ensure_tree
        ensure_gitignore
        refresh_system_files
        write_version
        record_manifest
        migrate_log "fresh-install" "created v$TARGET_BRAIN_VERSION tree"
        ensure_adapters
        ;;
    current)
        log "already at v$TARGET_BRAIN_VERSION → verifying + refreshing missing files..."
        ensure_tree
        ensure_gitignore
        if legacy_structures_present; then
            echo ""
            echo -e "   ${YELLOW}Legacy structures detected — backup + merge migration.${NC}"
            if ! confirm "Proceed with backup + migration"; then
                fail "migration skipped by user — refreshing system files only."
            else
                do_backup "$CURRENT_VERSION" "$TARGET_BRAIN_VERSION"
                if has_domain_layout; then
                    migrate_v1_to_v2
                fi
                migrate_legacy_user_dirs
            fi
            echo ""
        fi
        refresh_system_files
        record_manifest
        migrate_log "re-run" "idempotent refresh at v$TARGET_BRAIN_VERSION"
        ensure_adapters
        ;;
    upgrade | migrate-domains)
        echo ""
        echo -e "   ${YELLOW}Brain upgrade: v$CURRENT_VERSION → v$TARGET_BRAIN_VERSION${NC}"
        echo -e "   User data is preserved (merge, never delete). A backup is created first."
        echo ""
        if ! confirm "Proceed with backup + migration"; then
            fail "migration cancelled by user — nothing changed."
            exit 0
        fi
        ensure_tree
        do_backup "$CURRENT_VERSION" "$TARGET_BRAIN_VERSION"
        if [ "$STATE" = "migrate-domains" ] || [ "$CURRENT_VERSION" = "1" ]; then
            migrate_v1_to_v2
        fi
        migrate_legacy_user_dirs
        migrate_v2_to_v3
        ensure_gitignore
        refresh_system_files
        write_version
        record_manifest
        migrate_log "upgrade" "v$CURRENT_VERSION → v$TARGET_BRAIN_VERSION"
        ensure_adapters
        ;;
esac

refresh_self

recover_loose_plans

# ── Entrypoint sanity ──────────────────────────────────────────────────
if [ ! -f "$BRAIN_DIR/INSTRUCTIONS.md" ] || [ ! -f "$BRAIN_DIR/ARCHITECTURE.md" ]; then
    fail "entrypoint files missing after update — installation incomplete."
    exit 1
fi

# ── Caveman token compression (config only; plugin install best-effort) ──
if [ ! -f ".caveman.json" ]; then
    echo '{"defaultMode":"ultra"}' > ".caveman.json"
    ok ".caveman.json created"
fi

# ── Report ─────────────────────────────────────────────────────────────
echo ""
if [ "${#WARNINGS[@]}" -gt 0 ]; then
    echo -e "${YELLOW}   Review needed (${#WARNINGS[@]} warning(s)):${NC}"
    for w in "${WARNINGS[@]}"; do
        echo -e "   ${YELLOW}-${NC} $w"
    done
    echo ""
fi
echo -e "${GREEN}✅  RAI-Engineering brain v$TARGET_BRAIN_VERSION ready.${NC}"
echo -e "   State: $STATE | version file: $VERSION_FILE | log: $MIG_LOG"
echo ""
