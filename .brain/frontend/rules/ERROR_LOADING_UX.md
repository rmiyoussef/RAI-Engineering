# Error, Loading & Empty State Rules (UX)

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Every component must handle every state — loading, error, empty, and success.

---

## R1 — The Four States Contract

Every data-driven component must handle exactly four states:

```typescript
type ComponentState<T> =
  | { status: 'loading' }
  | { status: 'error'; error: Error; retry: () => void }
  | { status: 'empty' }
  | { status: 'success'; data: T };
```

```typescript
function DataSection() {
  const { data, isLoading, error, isEmpty } = useData();

  if (isLoading)      return <SkeletonSection />;
  if (error)           return <ErrorState error={error} onRetry={refetch} />;
  if (isEmpty)         return <EmptyState />;
  return <Content data={data} />;
}
```

**Don't forget these:**
- Loading → Skeleton/spinner (never "Loading...")
- Error → Actionable error UI with retry
- Empty → Helpful empty state with guidance
- Success → The actual content

## R2 — Skeleton Loading Patterns

| Content type | Skeleton |
|-------------|----------|
| Text block | 3-4 gray bars of varying widths |
| Card grid | Card-shaped placeholder with pulse animation |
| Table | Row after row of column-matching bars |
| Avatar + text | Circle avatar + 2 text bar lines |
| Image | Aspect-ratio-matched gray rectangle |

```typescript
function CardSkeleton() {
  return (
    <div className="card" aria-busy="true" aria-label="Loading content">
      <div className="skeleton skeleton-image" />
      <div className="skeleton skeleton-title" />
      <div className="skeleton skeleton-text" />
      <div className="skeleton skeleton-text-short" />
    </div>
  );
}
```

### Skeleton Animation Rules
- Use CSS `@keyframes pulse` (opacity fade) — it's GPU-composited and cheap
- Never animate every skeleton independently (staggering is fine, but within reason)
- Match the dimensions of the real content as closely as possible (prevents CLS)

```css
.skeleton {
  background: var(--color-skeleton);
  border-radius: var(--radius-sm);
  animation: skeleton-pulse 1.5s ease-in-out infinite;
}

@keyframes skeleton-pulse {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 0.8; }
}
```

## R3 — Error State Requirements

Every error UI must include:

| Element | Purpose |
|---------|---------|
| Clear message | What went wrong, in plain language |
| Recovery action | "Try again" button that retries the operation |
| Don't break the page | Error in one section doesn't crash others (Error Boundary) |
| Log the error | Console, logging service, or reporting API |

```typescript
function ErrorState({ error, onRetry }: { error: Error; onRetry: () => void }) {
  // Log for debugging
  useEffect(() => {
    console.error('Component error:', error);
    reportErrorToService(error);
  }, [error]);

  return (
    <div role="alert" className="error-state">
      <ErrorIcon />
      <h3>Something went wrong</h3>
      <p>{getUserFriendlyMessage(error)}</p>
      <button onClick={onRetry}>Try again</button>
    </div>
  );
}

function getUserFriendlyMessage(error: Error): string {
  if (error.message.includes('401')) return 'Please sign in to continue.';
  if (error.message.includes('429')) return 'Too many requests. Please wait a moment.';
  if (error.message.includes('network')) return 'Check your internet connection.';
  return 'An unexpected error occurred. Please try again.';
}
```

## R4 — Empty State Rules

| Situation | Empty state content |
|-----------|-------------------|
| No search results | "No results for [query]. Try different keywords." |
| Empty list | "Nothing here yet." + CTA to add first item |
| Empty inbox | "All caught up!" with cheerful illustration |
| No permissions | "You don't have access to this section." + contact admin link |
| First visit | Onboarding message + "Get started" button |

```typescript
function EmptyState({
  title,
  description,
  action,
  icon
}: {
  title: string;
  description: string;
  action?: { label: string; onClick: () => void };
  icon?: ReactNode;
}) {
  return (
    <div className="empty-state">
      {icon || <InboxIcon />}
      <h3>{title}</h3>
      <p>{description}</p>
      {action && <button onClick={action.onClick}>{action.label}</button>}
    </div>
  );
}
```

## R5 — Loading UX Beyond Initial Load

| Situation | UX Pattern |
|-----------|------------|
| Initial page load | Full skeleton matching page layout |
| Refreshing data in background | Keep showing stale data + subtle indicator |
| Form submission | Button shows loading spinner + disabled |
| Pagination | Keep existing items + shimmer at bottom |
| Filter results | Keep showing previous results + overlay with spinner |
| File upload | Progress bar with filename, cancel option |

```typescript
// ✅ Refreshing in background: show stale data
function Dashboard() {
  const { data, isRefetching } = useQuery({
    queryKey: ['dashboard'],
    queryFn: fetchDashboard,
  });

  return (
    <div>
      {isRefetching && <RefreshIndicator />}
      {data && <DashboardContent data={data} />} {/* still shows during refetch */}
    </div>
  );
}
```

## R6 — Error Boundary Placement

```
<App>
  <ErrorBoundary fallback={<AppCrashScreen />}>       ← catastrophic
    <Header />                                         ← no boundary needed (static)
    <main>
      <ErrorBoundary fallback={<SectionError />}>      ← section-level
        <DashboardWidgets />                           ← each widget can fail independently
      </ErrorBoundary>
      <ErrorBoundary fallback={<SectionError />}>
        <DataTable />
      </ErrorBoundary>
    </main>
  </ErrorBoundary>
</App>
```

| Level | Coverage | Fallback |
|-------|----------|---------|
| App root | Everything | Full-page crash screen with refresh button |
| Feature section | Route/layout area | Section-sized error with retry |
| Individual widget | One component | Small inline error |

## R7 — Transitions Between States

```css
/* Smooth transitions between states prevent jarring UX */
.content-enter {
  animation: fadeIn 200ms ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(4px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Never flash loading state if data is cached */
/* Use stale-while-revalidate pattern — show stale data immediately, refetch in background */
```
