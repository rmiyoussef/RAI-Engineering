# Performance Optimization

> **Source:** Adapted from addyosmani (performance-optimization)
> **Domain:** Shared — Cross-Domain
> **Use when:** Optimizing application performance — always start with measurement.

---

## Overview

Performance work without measurement is guessing — and guessing leads to premature optimization.

## Core Web Vitals Targets

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| LCP (Largest Contentful Paint) | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| INP (Interaction to Next Paint) | ≤ 200ms | ≤ 500ms | > 500ms |
| CLS (Cumulative Layout Shift) | ≤ 0.1 | ≤ 0.25 | > 0.25 |

## Workflow

```
Measure → Identify → Fix → Verify → Guard
```

### 1. Measure
- **Synthetic:** Lighthouse, DevTools Performance panel, WebPageTest
- **Real User Monitoring (RUM):** web-vitals library, Chrome User Experience Report (CrUX)

### 2. Identify
Map symptoms to likely causes:

| Symptom | Likely Cause | Measure |
|---------|-------------|---------|
| Slow first load | Large bundles, unoptimized images, blocking JS | Lighthouse, bundle analysis |
| Sluggish interaction | Long tasks, unnecessary re-renders, layout thrashing | DevTools Performance |
| Slow backend | N+1 queries, missing indexes, no caching | DB query log, API profiling |

### 3. Fix — Common Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| N+1 queries | Eager loading (`includes`, `JOIN`, `with()`) |
| Unbounded data fetching | Pagination (cursor-based for large sets) |
| Unoptimized images | `<picture>`, `srcset`, `loading="lazy"`, WebP/AVIF |
| Unnecessary re-renders | Stable references, `React.memo`, `useMemo` (only when measured) |
| Large JavaScript bundles | Dynamic imports, route-based code splitting |
| Missing backend caching | In-memory cache, HTTP cache headers, CDN |

### 4. Verify
- Before/after measurements with the same tool and conditions
- Confirm the fix moved the metric, not just the noise

### 5. Guard
- Performance budgets in CI
- Lighthouse CI or similar for regression detection
- Alert on sustained regressions in RUM data

## Performance Budgets

| Asset | Budget |
|-------|--------|
| JS bundle (gzipped) | < 200KB |
| API response (p95) | < 200ms |
| Lighthouse score | ≥ 90 |

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "It's fast on my machine" | Your machine is not your users' machines. Measure. |
| "Users won't notice 100ms" | Research shows 100ms delays impact conversion rates. |
| "We'll optimize later" | Performance retrofits are harder than building it right. |
| "Premature optimization is evil" | So is shipping a slow app. Measure first, then optimize. |

## Verification Checklist

- [ ] Before measurement taken
- [ ] After measurement taken (same tool, same conditions)
- [ ] Identified bottleneck matches the fix
- [ ] Core Web Vitals pass (Green zone)
- [ ] No N+1 queries in the optimized path
- [ ] CI performance budgets pass
- [ ] All existing tests still pass
