# CI/CD Pipeline Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** DevOps — CI/CD pipelines
> **Purpose:** Fast, reliable, secure automated delivery pipelines.

---

## R1 — Pipeline Performance

| Target | Standard | Critical path |
|--------|----------|---------------|
| Total pipeline time | < 10 min | < 5 min |
| Fast feedback (lint + unit) | < 3 min | < 2 min |
| Build time | < 3 min | < 1 min |
| Deployment | < 2 min | < 30s |

### Cache Strategy

```yaml
# ✅ Cache dependencies between runs
- name: Cache dependencies
  uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      node_modules
      .next/cache
    key: ${{ runner.os }}-npm-${{ hashFiles('package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
```

| Dependency type | Cache key | Retention |
|----------------|-----------|-----------|
| Language packages (npm, pip, gem) | `os-lang-lockfile-hash` | 7 days |
| Docker layers | Registry caching, inline cache | — |
| Build artifacts | `os-branch-hash` | 1 day |
| Binary downloads | `os-tool-version` | 30 days |

## R2 — Pipeline Stages (Ordered)

```
1. Lint & Format    → fast (fail fast, 1-2 min)
2. Type Check       → medium (2-3 min)
3. Unit Tests       → medium (2-5 min, parallelized)
4. Build            → medium (1-3 min, cached)
5. Integration Tests → long (3-10 min, docker compose)
6. Security Scan    → medium (1-3 min, dependency scan)
7. Image Build & Push → med (1-3 min, multi-stage)
8. Deploy Staging   → short (30s-1 min)
9. Smoke Tests      → short (30s-2 min)
   ═══════════════════════════════════════════
   (Manual Gate)
10. Deploy Production → short (30s-1 min)
11. Health Check    → short (30s-2 min)
```

```yaml
# ✅ Fail fast structure
jobs:
  lint-and-type:
    run if: always()  # run independently
  test-and-build:
    needs: [lint-and-type]
  security-scan:
    needs: [test-and-build]
  deploy-staging:
    needs: [security-scan]
  deploy-production:
    needs: [deploy-staging]
    environment: production
```

## R3 — Secrets in CI

| Rule | Why |
|------|-----|
| Store secrets in CI secrets vault (Actions secrets, GitLab CI variables) | No plaintext in config |
| Never echo or print secrets in logs | Accidental exposure |
| Use `env.SECRET` or `secrets.SECRET` — never hardcoded | Rotatable |
| Scoped permissions per environment | Production secrets not available to PR jobs |
| Audit who can access production secrets | Limit blast radius |

```yaml
# ✅ Proper secret scoping
jobs:
  deploy-production:
    environment: production
    env:
      DEPLOY_KEY: ${{ secrets.PRODUCTION_DEPLOY_KEY }}
```

## R4 — Conditional Pipeline Execution

```yaml
# ✅ Run only when relevant files change
on:
  push:
    paths:
      - 'src/**'
      - 'Dockerfile'
      - '.github/workflows/ci.yml'
    paths-ignore:
      - 'docs/**'
      - 'README.md'
      - '*.md'

# ✅ Run differently per branch
jobs:
  deploy:
    if: github.ref == 'refs/heads/main'
```

## R5 — Branch Protection & Pipeline Gates

| Gate | Enforced by | Bypass |
|------|-------------|--------|
| Linear history | GitHub branch protection | — |
| All checks pass | Status checks required | Repository admin |
| Code review approval | Required reviewers | — |
| No unresolved threads | Conversation resolution | — |
| Deployment approval | Environment protection rules | Production deployers |
| Signed commits | GPG/SSH signature verification | — |

```yaml
# ✅ Environment approval gate
environment:
  name: production
  url: https://app.example.com
  # Requires manual approval from designated reviewers
```

## R6 — Pipeline Anti-Patterns

| Anti-pattern | Fix |
|-------------|-----|
| Skipping CI for code changes | Accept `[skip ci]` only for docs, config, README |
| 30+ minute pipelines | Parallelize stages, reduce test scope, optimize builds |
| Flaky tests blocking deploys | Quarantine flaky tests immediately |
| Building on every push (no cache) | Implement dependency caching |
| Secrets in CI logs | Use secret masking, never `echo $SECRET` |
| Single CI config for all projects | Use reusable workflows, avoid copy-paste |
| Gate-less production deploys | Require manual approval for prod |
| No rollback plan | Document rollback: `git revert` + re-deploy or rollback deploy |

## R7 — Reusable Workflows

```yaml
# ✅ Reusable workflow in .github/workflows/deploy.yml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      deploy-key:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4
      - run: ./deploy.sh ${{ inputs.environment }}
        env:
          DEPLOY_KEY: ${{ secrets.deploy-key }}
```

## R8 — Verification Checklist

- [ ] Pipeline completes in under 10 minutes
- [ ] Lint, type check, tests, build, security all green
- [ ] Dependencies cached between runs
- [ ] Secrets properly scoped per environment
- [ ] Production deploys require manual approval
- [ ] Rollback plan exists and works
- [ ] Image tags are deterministic (not `latest`)
- [ ] Notifications on failure (Slack, email, PagerDuty)
