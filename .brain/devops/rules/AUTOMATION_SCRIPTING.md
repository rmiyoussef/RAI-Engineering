# Automation & Scripting Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** DevOps — scripts and automation
> **Purpose:** Reliable, repeatable, readable automation.

---

## R1 — Shell Script Standards

```bash
#!/usr/bin/env bash
set -euo pipefail          # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'                # Safer word splitting

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# logging
info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }
```

| Rule | Why |
|------|-----|
| Always use `set -euo pipefail` | Prevents silent failures |
| Always quote variables | Prevents word splitting on spaces/special chars |
| Use `[[ ]]` over `[ ]` for conditionals | Fewer gotchas, pattern matching support |
| Use `trap` for cleanup | Ensure temp files are removed |
| Validate arguments upfront | Fail fast with clear usage message |

## R2 — Script Architecture

```bash
#!/usr/bin/env bash
# deploy.sh — Multi-environment deployment script

set -euo pipefail

# ── Config ──────────────────────────────────────────────
ENVIRONMENTS=(staging production)
SUPPORTED_CLOUDS=(aws gcp)

# ── Help ────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $0 <environment> [options]

Environments: ${ENVIRONMENTS[*]}
Options:
  -v, --version VERSION    Image tag to deploy (required)
  -r, --rollback           Rollback to previous version
  -d, --dry-run            Show what would happen

Example:
  $0 staging --version 2.3.1
EOF
    exit 1
}

# ── Argument parsing ────────────────────────────────────
ENVIRONMENT="${1:-}"
shift 2>/dev/null || usage

# ── Validation ───────────────────────────────────────────
if [[ ! " ${ENVIRONMENTS[*]} " =~ " ${ENVIRONMENT} " ]]; then
    error "Invalid environment: $ENVIRONMENT"
fi

# ── Main ─────────────────────────────────────────────────
main() {
    info "Deploying version ${VERSION} to ${ENVIRONMENT}"
    # ... actual deploy logic
}

main
```

## R3 — Idempotent Scripts

Every automation script must be **idempotent** — running it twice produces the same result.

```bash
# ✅ Idempotent: check before creating
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    kubectl create namespace "$NAMESPACE"
fi

# ✅ Idempotent: apply (not create)
kubectl apply -f deployment.yaml

# ✅ Idempotent: patch if exists, create if not
kubectl patch configmap app-config -n "$NS" --patch "$PATCH" || \
    kubectl create configmap app-config -n "$NS" --from-file=config.yaml
```

## R4 — CI Script Rules

```yaml
# ✅ CI script structure
jobs:
  test:
    steps:
      - name: Run tests with timeout
        run: |
          timeout 10m npm test
        shell: bash
        env:
          CI: true
      - name: Upload test results on failure
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: test-results/
```

| Rule | Why |
|------|-----|
| Add timeouts to all steps | Prevent hung jobs wasting CI minutes |
| Upload artifacts on failure | Debug without re-running |
| Use `if: failure()` for cleanup | Always clean up even on error |
| Never `npm install` without cache | Slows CI by 2-5 minutes |

## R5 — Makefile Standards

```makefile
.PHONY: help build test lint clean docker-build deploy

help:              ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build:             ## Build the application
	docker build -t myapp:$$(git rev-parse --short HEAD) .

test:              ## Run tests
	npm test

lint:              ## Run linter
	npm run lint

docker-build: build ## Build Docker image
	docker tag myapp:$$(git rev-parse --short HEAD) registry.example.com/myapp:latest

deploy:            ## Deploy to staging
	./deploy.sh staging --version $$(git rev-parse --short HEAD)

clean:             ## Clean build artifacts
	rm -rf dist/ node_modules/
```

## R6 — Error Handling and Logging

```bash
# ✅ Structured logging in automation
log_json() {
    local level="$1"
    local message="$2"
    echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"$level\",\"script\":\"$(basename $0)\",\"message\":\"$message\"}"
}

log_json "info" "Starting deployment"
log_json "error" "Failed to connect to database"

# ✅ Retry with backoff
retry() {
    local n=1
    local max=5
    local delay=1
    while true; do
        if "$@"; then break
        elif [[ $n -lt $max ]]; then
            warn "Attempt $n/$max failed. Retrying in $delay seconds..."
            sleep "$delay"
            n=$((n+1))
            delay=$((delay * 2))
        else
            error "Command failed after $n attempts: $*"
        fi
    done
}

retry curl -sSf https://api.example.com/health
```

## R7 — Configuration Management

```bash
# ✅ Environment-agnostic scripts
# Instead of hardcoding per environment:

# config.sh
load_config() {
    local env="${1:-development}"
    local config_file="config/$env.yaml"

    if [[ ! -f "$config_file" ]]; then
        error "Config file not found: $config_file"
    fi

    export DB_HOST="$(yq '.database.host' "$config_file")"
    export DB_PORT="$(yq '.database.port' "$config_file")"
    export LOG_LEVEL="$(yq '.logging.level' "$config_file")"
}
```

## R8 — Script Anti-Patterns

| Anti-pattern | Fix |
|-------------|-----|
| Hardcoded paths | Use `SCRIPT_DIR` based on `BASH_SOURCE` |
| No input validation | Validate all arguments at script start |
| Running as root unnecessarily | Use `sudo` only where needed |
| Using `rm -rf` without confirmation | Add safety checks or use trash |
| Ignoring stderr | Capture and log stderr |
| No cleanup on exit | Use `trap cleanup EXIT` |
| Assuming tools are installed | Check prerequisites at start |
| Hardcoded secrets in scripts | Use environment variables from vault |
