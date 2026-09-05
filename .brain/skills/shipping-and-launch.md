# Shipping and Launch

> **Source:** Adapted from addyosmani (shipping-and-launch)
> **Domain:** Shared — Cross-Domain
> **Use when:** Preparing production launches — pre-launch checklists, monitoring setup, staged rollouts, and rollback strategies.

---

## Overview

Ship with confidence. The goal is not just to deploy — it's to deploy safely, with monitoring, a rollback plan, and clear success criteria. Every launch should be reversible, observable, and incremental.

## Pre-Launch Checklist

### Code Quality
- [ ] Tests pass
- [ ] Build clean (no errors, no warnings)
- [ ] Lint/type checks pass
- [ ] Code review approved
- [ ] No stray TODOs or console.log statements
- [ ] Error handling complete (no uncaught exceptions)

### Security
- [ ] No secrets in version control
- [ ] `npm audit` clear of critical/high vulns
- [ ] Input validation at all boundaries
- [ ] Auth checks on all protected routes
- [ ] Security headers set (CSP, HSTS, X-Frame-Options)
- [ ] Rate limiting on auth endpoints
- [ ] CORS set to specific origins (not `*`)

### Performance
- [ ] Core Web Vitals within "Good" thresholds
- [ ] No N+1 queries
- [ ] Images optimized
- [ ] Bundle size within budget
- [ ] Proper DB indexes in place
- [ ] Caching configured

### Accessibility
- [ ] Keyboard navigation works
- [ ] Screen reader compatibility verified
- [ ] Color contrast meets WCAG 2.1 AA (4.5:1 for text)
- [ ] Focus management correct
- [ ] Descriptive error messages
- [ ] No axe-core/Lighthouse a11y warnings

### Infrastructure
- [ ] Production env vars set
- [ ] DB migrations ready (and reversible)
- [ ] DNS/SSL configured
- [ ] CDN for static assets
- [ ] Logging and error reporting set up
- [ ] Health check endpoint exists (200 on `/health`)

## Feature Flag Strategy

Decouple deployment from release: deploy with flag OFF → enable gradually.

**Lifecycle:** Deploy (flag OFF) → Team/Beta → 5% → 25% → 50% → 100% → Clean up flag

**Rules:**
- Every flag has an owner and expiration date
- Clean up within 2 weeks of full rollout
- Don't nest flags
- Test both states in CI

## Staged Rollout Sequence

| Stage | Duration | Verification |
|-------|----------|--------------|
| Staging deploy | — | Full test suite + manual smoke tests |
| Production deploy (flag OFF) | — | Health check 200, error monitoring green |
| Internal team | 24 hours | Watch errors and latency |
| 5% canary | 24-48 hours | Compare canary vs baseline |
| 25% → 50% → 100% | ~1 hour per step | Same monitoring at each threshold |
| Full rollout | 1 week monitor | Clean up feature flag |

## Rollout Decision Thresholds

| Metric | Green (Advance) | Yellow (Hold) | Red (Roll back) |
|--------|-----------------|---------------|-----------------|
| Error rate | Within 10% of baseline | 10-100% above | >2x baseline |
| P95 latency | Within 20% of baseline | 20-50% above | >50% above |
| Client JS errors | No new types | <0.1% of sessions | >0.1% of sessions |
| Business metrics | Neutral or positive | Decline <5% | Decline >5% |

**Roll back immediately if:** error rate >2x baseline, P95 >50% above baseline, user-reported issues spike, data integrity issues, or security vulnerabilities.

## Post-Launch Verification (First Hour)

- [ ] Health endpoint returns 200
- [ ] No new error types in monitoring
- [ ] No latency regression
- [ ] Manual critical-flow test passes
- [ ] Logs flowing and readable
- [ ] Rollback mechanism verified (you know it works because you just tested it)

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "It works in staging, it'll work in production" | Staging and production are never identical |
| "We don't need feature flags for this" | You need them for any feature that might need rollback |
| "We'll add monitoring later" | Monitoring after launch is too late for launch-day issues |
| "Rolling back is admitting failure" | Rolling back is the safe choice. Staying broken is failure. |

## Verification Checklist

### Pre-Deploy
- [ ] Pre-launch checklist complete (all sections)
- [ ] Feature flag configured (OFF by default)
- [ ] Rollback plan documented
- [ ] Monitoring dashboards set up
- [ ] Team notified

### Post-Deploy
- [ ] Health check returns 200
- [ ] Error rate normal (within 10% of baseline)
- [ ] Latency normal (within 20% of baseline)
- [ ] Critical flow works
- [ ] Logs flowing
- [ ] Rollback mechanism verified
