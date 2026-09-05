#!/usr/bin/env bash
#
# RAI-Engineering — update.sh test suite (§35: migration safety validation)
#
# Usage: bash tests/test-update.sh
# All scenarios run in temp dirs against the local repo copy (--local).
# No network. No writes outside temp dirs.
#
# Covers: fresh install, existing brain, plans/memory/summaries/test-cases
# preserved, domain migration, modified-system-file conflict, idempotent
# re-runs, legacy user-dir merge, --check mode.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPDATE="$ROOT/update.sh"
PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL: $1" >&2; }

assert_file() { # $1 path, $2 label
    if [ -f "$1" ]; then pass "$2"; else fail "$2 (missing: $1)"; fi
}
assert_absent() {
    if [ ! -e "$1" ]; then pass "$2"; else fail "$2 (should be absent: $1)"; fi
}
assert_contains() {
    if grep -qF "$2" "$1" 2>/dev/null; then pass "$3"; else fail "$3 (no '$2' in $1)"; fi
}
assert_version() {
    if [ -f "$1/.brain/state/version" ] && grep -q "^RAI_BRAIN_VERSION=$2$" "$1/.brain/state/version"; then
        pass "$3"
    else
        fail "$3 (version != $2)"
    fi
}

new_tmp() { mktemp -d /tmp/rai-test-XXXXXX; }

run_update() { # $1 dir, $2... extra flags
    local dir="$1"; shift
    (cd "$dir" && RAI_SOURCE_DIR="$ROOT" bash "$UPDATE" --yes --local "$@")
}

# ── Fixture: old domain-first brain (v1 era) with user data ─────────────
make_domain_fixture() { # $1 dir
    local d="$1"
    mkdir -p "$d/.brain/backend"/{memory/{decisions,lessons,tasks},rules,skills,plans,connections}
    mkdir -p "$d/.brain/frontend"/{rules,skills}
    mkdir -p "$d/.brain/devops"/rules
    echo "# User ADR: why postgres" > "$d/.brain/backend/memory/decisions/2024-01-01-postgres.md"
    echo "# User lesson" > "$d/.brain/backend/memory/lessons/2024-02-02-lesson.md"
    echo "# User task record" > "$d/.brain/backend/memory/tasks/2024-03-03-task.md"
    echo "# backend api rule" > "$d/.brain/backend/rules/API_DESIGN.md"
    echo "# user custom rule — must survive" > "$d/.brain/backend/rules/MY_CUSTOM.md"
    echo "# backend service skill" > "$d/.brain/backend/skills/service.md"
    echo "# old plan" > "$d/.brain/backend/plans/legacy-plan.md"
    echo "host=db user=u" > "$d/.brain/backend/connections/database.md"
    echo "# frontend rule" > "$d/.brain/frontend/rules/STYLING.md"
    echo "# user iac rule" > "$d/.brain/devops/rules/TERRAFORM_CUSTOM.md"
}

echo "== 1. fresh installation =="
T="$(new_tmp)"
run_update "$T" >/dev/null 2>&1
assert_file "$T/.brain/ARCHITECTURE.md" "fresh: ARCHITECTURE.md installed"
assert_file "$T/.brain/INSTRUCTIONS.md" "fresh: INSTRUCTIONS.md installed"
assert_file "$T/.brain/state/version" "fresh: version file created"
assert_version "$T" "2" "fresh: brain version = 2"
assert_file "$T/.brain/plans/active/.gitkeep" "fresh: plans/ tree (active kept)"
[ -d "$T/.brain/backend" ] && fail "fresh: no domain dirs" || pass "fresh: no domain dirs"
assert_file "$T/.brain/state/system-manifest.sha256" "fresh: manifest recorded"
assert_file "$T/.brain/state/migrations.log" "fresh: migration log started"
assert_file "$T/.ai/CLAUDE.md" "fresh: .ai mirror installed"
[ -L "$T/CLAUDE.md" ] && pass "fresh: CLAUDE.md symlink" || fail "fresh: CLAUDE.md symlink"
grep -q "context/connections" "$T/.gitignore" && pass "fresh: .gitignore secrets" || fail "fresh: .gitignore secrets"

echo "== 2. idempotent re-runs (3x) =="
run_update "$T" >/dev/null 2>&1
run_update "$T" >/dev/null 2>&1
BEFORE="$(find "$T/.brain" -type f | sort | sha256sum)"
run_update "$T" >/dev/null 2>&1
AFTER="$(find "$T/.brain" -type f | sort | sha256sum)"
[ "$BEFORE" = "$AFTER" ] && pass "repeat runs: file list stable" || fail "repeat runs: file list changed"
[ "$(find "$T/.brain" -name '*.new' | wc -l)" = "0" ] && pass "repeat runs: no .new conflicts" || fail "repeat runs: spurious .new files"
[ "$(find "$T/.brain/.migration" -name '*.tgz' 2>/dev/null | wc -l)" = "0" ] && pass "repeat runs: no backup spam" || fail "repeat runs: unexpected backups"
assert_version "$T" "2" "repeat runs: version stays 2"

echo "== 3. user plans/memory/summaries/test-cases preserved =="
T="$(new_tmp)"
run_update "$T" >/dev/null 2>&1
mkdir -p "$T/.brain/plans/active/PLAN-0009" "$T/.brain/memory/decisions" "$T/.brain/summaries/completed" "$T/.brain/test-cases/active/PLAN-0009"
echo "# user plan" > "$T/.brain/plans/active/PLAN-0009/PLAN.md"
echo "# user decision" > "$T/.brain/memory/decisions/2025-05-05-x.md"
echo "# user summary" > "$T/.brain/summaries/completed/PLAN-0008.md"
echo "# user tc" > "$T/.brain/test-cases/active/PLAN-0009/TC-0001.md"
run_update "$T" >/dev/null 2>&1
run_update "$T" >/dev/null 2>&1
assert_file "$T/.brain/plans/active/PLAN-0009/PLAN.md" "user plan preserved across updates"
assert_file "$T/.brain/memory/decisions/2025-05-05-x.md" "user decision preserved"
assert_file "$T/.brain/summaries/completed/PLAN-0008.md" "user summary preserved"
assert_file "$T/.brain/test-cases/active/PLAN-0009/TC-0001.md" "user test case preserved"

echo "== 4. domain migration (v1 → v2) =="
T="$(new_tmp)"
make_domain_fixture "$T"
run_update "$T" >/dev/null 2>&1
assert_file "$T/.brain/memory/decisions/2024-01-01-postgres.md" "migrated: user decision"
assert_file "$T/.brain/memory/lessons/2024-02-02-lesson.md" "migrated: user lesson"
assert_file "$T/.brain/summaries/archived/2024-03-03-task.md" "migrated: task → summaries/archived"
assert_file "$T/.brain/rules/api/design.md" "migrated: API_DESIGN → rules/api"
assert_file "$T/.brain/rules/_imported/backend-MY_CUSTOM.md" "migrated: unknown user rule → rules/_imported (preserved)"
assert_file "$T/.brain/skills/backend-service.md" "migrated: service skill"
assert_file "$T/.brain/rules/infrastructure/build-tooling.md" "frontend rule migrated"
assert_file "$T/.brain/rules/_imported/devops-TERRAFORM_CUSTOM.md" "devops custom rule preserved"
assert_file "$T/.brain/context/connections/database.md" "connections → context/connections"
[ -d "$T/.brain/backend" ] && fail "migrated: backend dir removed" || pass "migrated: backend dir removed"
[ -d "$T/.brain/frontend" ] && fail "migrated: frontend dir removed" || pass "migrated: frontend dir removed"
[ "$(ls "$T/.brain/plans/archived" | grep -c '^PLAN-')" = "1" ] && pass "migrated: legacy plan archived" || fail "migrated: legacy plan archived"
assert_version "$T" "2" "migrated: version stamped 2"
[ "$(ls "$T/.brain/.migration"/backup-*.tgz 2>/dev/null | wc -l)" = "1" ] && pass "migrated: backup snapshot created" || fail "migrated: backup snapshot created"
assert_contains "$T/.brain/state/migrations.log" "migrate-v1-to-v2" "migrated: log records migration"
# backup contains the original user data
tar -tzf "$T"/.brain/.migration/backup-*.tgz 2>/dev/null | grep -q "backend/memory/decisions/2024-01-01-postgres.md" \
    && pass "backup holds user data" || fail "backup holds user data"

echo "== 5. modified system file → conflict, never overwrite =="
T="$(new_tmp)"
run_update "$T" >/dev/null 2>&1
echo "# MY CUSTOM INSTRUCTIONS — do not lose" >> "$T/.brain/INSTRUCTIONS.md"
BEFORE_HASH="$(sha256sum "$T/.brain/INSTRUCTIONS.md" | awk '{print $1}')"
run_update "$T" >/dev/null 2>&1
[ "$(sha256sum "$T/.brain/INSTRUCTIONS.md" | awk '{print $1}')" = "$BEFORE_HASH" ] \
    && pass "customized system file preserved" || fail "customized system file preserved"
assert_file "$T/.brain/INSTRUCTIONS.md.new" "incoming version saved as .new"
assert_contains "$T/.brain/INSTRUCTIONS.md.new" "Operational authority" "incoming .new has new content"
# untouched system file still updates cleanly
run_update "$T" >/dev/null 2>&1
[ ! -f "$T/.brain/ARCHITECTURE.md.new" ] && pass "untouched system file: no spurious .new" || fail "untouched system file: no spurious .new"

echo "== 6. legacy user dirs merged =="
T="$(new_tmp)"
run_update "$T" >/dev/null 2>&1
mkdir -p "$T/.brain/tests" "$T/.brain/tasks" "$T/.brain/decisions" "$T/.brain/notes"
echo "# old test doc" > "$T/.brain/tests/old-test.md"
echo "# old task doc" > "$T/.brain/tasks/old-task.md"
echo "# old decision" > "$T/.brain/decisions/old-dec.md"
echo "# old note" > "$T/.brain/notes/old-note.md"
run_update "$T" >/dev/null 2>&1
assert_file "$T/.brain/test-cases/_imported/old-test.md" "tests/ merged to test-cases/_imported"
assert_file "$T/.brain/summaries/_imported/old-task.md" "tasks/ merged to summaries/_imported"
assert_file "$T/.brain/memory/decisions/old-dec.md" "decisions/ merged to memory/decisions"
assert_file "$T/.brain/memory/discoveries/old-note.md" "notes/ merged to memory/discoveries"

echo "== 7. --check mode changes nothing =="
T="$(new_tmp)"
make_domain_fixture "$T"
BEFORE="$(find "$T" | sort | sha256sum)"
(cd "$T" && RAI_SOURCE_DIR="$ROOT" bash "$UPDATE" --check --local >/dev/null 2>&1)
AFTER="$(find "$T" | sort | sha256sum)"
[ "$BEFORE" = "$AFTER" ] && pass "--check: filesystem untouched" || fail "--check: filesystem untouched"

echo "== 8. merge conflict: both old and new exist =="
T="$(new_tmp)"
run_update "$T" >/dev/null 2>&1
mkdir -p "$T/.brain/backend/rules"
echo "# pre-existing new-location rule" > "$T/.brain/rules/api/design.md"
echo "# legacy rule, different content" > "$T/.brain/backend/rules/API_DESIGN.md"
run_update "$T" >/dev/null 2>&1
assert_contains "$T/.brain/rules/api/design.md" "pre-existing new-location rule" "conflict: new-location original kept"
assert_file "$T/.brain/rules/_imported/backend-rules-API_DESIGN.md" "conflict: diverged rule preserved in _imported"

echo "== 9. setup.sh end-to-end (fresh project, local, offline) =="
T="$(new_tmp)"
touch "$T/composer.json"
(cd "$T" && bash "$ROOT/setup.sh" >/dev/null 2>&1)
assert_version "$T" "2" "setup: brain version = 2"
assert_file "$T/.brain/INSTRUCTIONS.md" "setup: INSTRUCTIONS.md installed"
assert_file "$T/.brain/plans/active/.gitkeep" "setup: plans/ tree"
[ -d "$T/.brain/backend" ] && fail "setup: no domain dirs" || pass "setup: no domain dirs"
[ -L "$T/CLAUDE.md" ] && pass "setup: CLAUDE.md symlink" || fail "setup: CLAUDE.md symlink"
assert_file "$T/AGENTS.md" "setup: AGENTS.md adapter"
grep -q "INSTRUCTIONS.md" "$T/AGENTS.md" && pass "setup: AGENTS.md points to brain" || fail "setup: AGENTS.md points to brain"

echo "== 10. existing AGENTS.md without brain bootstrap gets repaired =="
T="$(new_tmp)"
run_update "$T" >/dev/null 2>&1
printf 'CAVEMAN ULTRA — max compression. Active every response. No revert.\n\nRules:\n- test custom marker\n' > "$T/AGENTS.md"
run_update "$T" >/dev/null 2>&1
assert_contains "$T/AGENTS.md" ".brain/INSTRUCTIONS.md" "existing AGENTS.md: brain bootstrap prepended"
assert_contains "$T/AGENTS.md" "test custom marker" "existing AGENTS.md: user content preserved"
[ "$(grep -cF '.brain/INSTRUCTIONS.md' "$T/AGENTS.md")" = "1" ] && pass "existing AGENTS.md: single bootstrap" || fail "existing AGENTS.md: single bootstrap"
BEFORE_HASH="$(sha256sum "$T/AGENTS.md" | awk '{print $1}')"
run_update "$T" >/dev/null 2>&1
[ "$(sha256sum "$T/AGENTS.md" | awk '{print $1}')" = "$BEFORE_HASH" ] \
    && pass "existing AGENTS.md: repair idempotent" || fail "existing AGENTS.md: repair idempotent"

echo ""
echo "─────────────────────────────────"
echo "PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" = "0" ]
