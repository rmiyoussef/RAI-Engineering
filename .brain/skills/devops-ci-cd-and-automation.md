---
domains: [devops]
---

# CI/CD and Automation

> **Source:** Adapted from addyosmani (ci-cd-and-automation)
> **Domain:** DevOps / System Management
> **Use when:** Setting up or modifying CI/CD pipelines, build automation, or deployment scripts.

---

## Overview

CI/CD automation ensures that every change is built, tested, and deployed consistently. The goal is fast feedback loops and repeatable deployments.

## CI Pipeline Structure

```
Commit → Lint → Type Check → Test → Build → (Deploy)
```

### Stages

| Stage | What It Catches | Typical Tool |
|-------|----------------|--------------|
| **Lint** | Style issues, formatting | ESLint, Prettier, phpcs |
| **Type check** | Type errors | TypeScript, PHPStan, mypy |
| **Unit tests** | Logic errors | Jest, PHPUnit, pytest |
| **Integration tests** | Component interaction | Supertest, Testbench |
| **Build** | Compilation errors | Vite, Webpack, tsc |
| **Deploy** | Environment issues | Deployer, Vercel, Actions |

## Pipeline Rules

### Speed Matters
- A CI pipeline should complete in under 10 minutes for standard changes
- Cache dependencies between runs (npm cache, composer cache, pip cache)
- Parallelize independent stages (lint can run in parallel with type check)
- Run the fastest tests first, fail fast

### Deterministic Builds
- Lockfiles are mandatory (package-lock.json, composer.lock, poetry.lock)
- Pin CI runner versions (not "latest")
- Use exact tool versions in CI config (not system defaults)
- A build that passes today should pass next month

### Security in CI

| Rule | Why |
|------|-----|
| Secrets stored in CI secrets vault, not in code | Prevents exposure |
| No `npm audit` suppression | Real dependency risks |
| Scan dependencies on every build | Catch CVEs early |
| Separate deploy credentials by environment | Limit blast radius |

## Automation Patterns

### Commit Hooks (pre-commit)
- Lint staged files (not all files)
- Run type check on changed files
- Check for secrets in diff
- Format staged files

### Automated Tests on PR
- Run on every push to the PR branch
- Comment test results on the PR
- Block merge on test failures
- Flag flaky tests (don't silently ignore them)

### Automated Deployments

| Environment | Trigger | Verification |
|-------------|---------|--------------|
| Staging | Every merge to main | Full CI suite + smoke tests |
| Production | Manual approval (via PR or button) | Canary + metrics comparison |

## CD Patterns

### Staging Deploys (Automatic)
```yaml
on:
  push:
    branches: [main]
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./deploy.sh staging
```

### Production Deploys (Manual Gate)
```yaml
deploy-production:
  environment: production
  steps:
    - run: ./deploy.sh production
```

## GitHub Actions / CI Config Structure

```
.github/
├── workflows/
│   ├── ci.yml              ← Run tests, lint, type check
│   ├── deploy-staging.yml  ← Auto-deploy to staging
│   └── deploy-production.yml ← Manual-gate production deploy
```

## Common Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Skipping CI with `[skip ci]` | Only for docs-only or configuration-only changes |
| Flaky tests in critical paths | Fix or quarantine them |
| Massive CI pipeline (30+ min) | Split into focused workflows |
| Secrets in CI logs | Use secret masking; never echo env vars |
| Building on every push without caching | Cache dependencies between runs |

## Verification Checklist

- [ ] Pipeline runs in under 10 minutes
- [ ] Lint, type check, tests, and build stages all green
- [ ] Dependencies cached between runs
- [ ] No secrets exposed in logs or config
- [ ] Lockfile is committed and up to date
- [ ] Staging deploys are automatic
- [ ] Production deploys require manual approval
- [ ] Rollback plan exists (revert button or `git revert` strategy)
