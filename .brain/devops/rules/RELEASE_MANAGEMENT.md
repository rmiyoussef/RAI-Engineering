# Release & Change Management Rules

> **Loaded by:** EXECUTOR agent, GITHUB agent, REVIEWER agent
> **Domain:** DevOps — software delivery lifecycle
> **Purpose:** Safe, auditable, repeatable releases.

---

## R1 — Release Strategy

| Approach | When | Risk |
|----------|------|------|
| **Feature flags** | New features, gradual rollout | Low — toggle off instantly |
| **Canary releases** | Service changes, algorithm changes | Low — 10% → 50% → 100% |
| **Blue/Green** | Infrastructure, major changes | Low — instant switch back |
| **Rolling update** | Stateless app deploys | Low — gradual pod replacement |
| **Shadow (dark launch)** | Performance-critical changes | Very low — mirror traffic, discard results |

## R2 — Deployment Process

```yaml
# ✅ Deployment workflow
name: Deploy

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to deploy (git tag)'
        required: true

jobs:
  deploy-staging:
    environment: staging
    steps:
      - run: ./deploy.sh staging ${{ inputs.version }}
      - run: ./smoke-test.sh staging

  smoke-tests:
    needs: deploy-staging
    steps:
      - run: ./verify.sh staging

  deploy-production:
    needs: smoke-tests
    environment: production
    steps:
      - run: ./deploy.sh production ${{ inputs.version }}
      - run: ./smoke-test.sh production

  post-deploy:
    needs: deploy-production
    steps:
      - run: ./verify-metrics.sh production
```

### Deployment Checklist

- [ ] Image built, scanned, signed, and pushed to registry
- [ ] Deploy to staging first (always)
- [ ] Smoke tests pass in staging (critical path + data integrity)
- [ ] Manual approval for production deploy
- [ ] Canary release (10% traffic for 5 min) or full deploy
- [ ] Monitor metrics for 15 min post-deploy
- [ ] Rollback plan ready (or auto-rollback if error rate spikes > 1%)
- [ ] Notify team on Slack

## R3 — Rollback Rules

| Rollback type | Trigger | Method | Time |
|---------------|---------|--------|------|
| **Image rollback** | Error rate > 1% | Deploy previous image tag | < 5 min |
| **Git revert** | Wrong config, bug in code | `git revert` + re-deploy | < 10 min |
| **K8s rollout undo** | Bad deployment | `kubectl rollout undo` | < 2 min |
| **Feature flag toggle** | Feature-level bug | Toggle flag off | < 1 min |
| **Database migration revert** | Schema migration issue | Deploy code that works with old schema | < 10 min |

```bash
# ✅ Kubernetes rollback
kubectl rollout undo deployment/myapp

# ✅ Rollback to specific revision
kubectl rollout undo deployment/myapp --to-revision=3

# ✅ Check rollout status
kubectl rollout status deployment/myapp --timeout=5m
```

## R4 — Versioning Convention

| Artifact | Convention | Example |
|----------|-----------|---------|
| **Git tag** | `v{major}.{minor}.{patch}` | `v2.3.1` |
| **Docker image** | `{name}:{semver}` | `myapp:2.3.1` |
| **Git commit** | Conventional commits | `feat(auth): add OIDC support` |
| **Config** | Versioned with app | Same git tag |

### Semver Rules

| Change | Version bump | Example |
|--------|-------------|---------|
| Breaking API change | Major | `v2.0.0` |
| New feature, backward-compatible | Minor | `v2.3.0` |
| Bug fix, backward-compatible | Patch | `v2.3.1` |
| Emergency hotfix | Patch (tag from hotfix branch) | `v2.3.2` |

## R5 — Change Management Process

```
1. Feature request / bug report
2. Code changes on feature branch
3. PR → automated CI (lint, test, build, scan)
4. Code review (at least 1 approval)
5. Merge to main
6. Auto-deploy to staging
7. Smoke tests on staging
8. Manual approval for production
9. Canary deploy to production (10%)
10. Monitor (15 min)
11. Full rollout
12. Post-deploy monitoring (1 hour)
```

## R6 — Release Notes Template

```markdown
## Release v2.3.1 — 2026-07-23

### Changes
- [feat] Add OAuth 2.0 authentication support (PR #412)
- [fix] Resolve payment timeout on high-traffic orders (PR #415)
- [perf] Reduce API response time by 35% (PR #418)

### Breaking Changes
- None

### Migration Guide
- No migration required

### Deployment Steps
1. Deploy API service (rolling update)
2. Run database migration (10s, no downtime)
3. Deploy worker service
4. Verify metrics (15 min monitoring)

### Rollback Plan
- `git revert v2.3.1 && git push`
- `helm rollback api 3`
- Verify rollback health
```

## R7 — Feature Flags

```typescript
// ✅ Feature flag pattern
const features = {
  newCheckout: process.env.FLAG_NEW_CHECKOUT === 'true',
  darkMode: process.env.FLAG_DARK_MODE === 'true',
  aiRecommendations: process.env.FLAG_AI_RECS === 'true',
};

// Remove old code once flag is permanent (clean up within 2 releases)
```

| Flag lifecycle | State | Action |
|---------------|-------|--------|
| Development | `false` | Feature in progress, hidden |
| Testing | `true` on staging only | QA can test |
| Canary | `true` for 10% users | Gradual rollout |
| GA | `true` for 100% | Released to all |
| Cleanup | Removed | Flag + old code deleted |

## R8 — Zero-Downtime Deployments

```yaml
# ✅ Kubernetes zero-downtime deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0        # Never take down all pods
      maxSurge: 1               # Add one new pod before removing old one
  minReadySeconds: 10          # Wait 10s before pod is considered ready
```

| Requirement | Implementation |
|-------------|---------------|
| Multiple replicas | ≥ 2 |
| Graceful shutdown | `preStop` hook + `terminationGracePeriodSeconds: 30` |
| Readiness probe | Returns 200 only when pod can serve traffic |
| Connection draining | ALB deregistration delay: 30s |
| No sticky sessions (or drain them) | Session replication or database-backed sessions |

## R9 — Release Anti-Patterns

| Anti-pattern | Fix |
|-------------|-----|
| Deploying on Friday afternoon | No deploys after 2 PM Thursday |
| Deploying without monitoring | Check metrics before/after every deploy |
| Deploying database changes at the same time as code | Deploy code first, then schema |
| Skipping staging for "urgent" fixes | Always deploy to staging first |
| No rollback plan for risky changes | Always have a rollback tested and ready |
| Large infrequent releases | Small, frequent releases (daily if possible) |
| Manual deployment steps | Automate everything — one command deploy |
