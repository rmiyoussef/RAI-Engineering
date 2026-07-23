# Frontend Engineering Best Practices

> **Domain:** Frontend — framework-agnostic (React, Vue, Angular, Svelte)
> **Purpose:** A living reference for building production-quality frontend applications.
> **AI rules:** `./rules/` — loaded automatically by the AI per task.

---

## Table of Contents

1. [Component Architecture](#1-component-architecture)
2. [State Management](#2-state-management)
3. [Performance & Core Web Vitals](#3-performance--core-web-vitals)
4. [Accessibility (a11y)](#4-accessibility-a11y)
5. [Styling & CSS Architecture](#5-styling--css-architecture)
6. [Error, Loading & Empty States](#6-error-loading--empty-states)
7. [API Integration & Data Fetching](#7-api-integration--data-fetching)
8. [Testing Strategy](#8-testing-strategy)
9. [Frontend Security](#9-frontend-security)
10. [Forms & Input UX](#10-forms--input-ux)
11. [Build Tooling & Project Config](#11-build-tooling--project-config)

---

## 1. Component Architecture

### One Responsibility Per Component

A component should do one thing. If you can't describe it in one sentence, split it.

```
UserProfilePage              ← orchestrates (composition of things below)
├── useUserProfile           ← custom hook: data fetching + state
├── ProfileForm              ← form only — receives callbacks
├── NotificationBanner       ← notification only
└── PageLayout               ← layout only (header, sidebar, main)
```

### Smart vs Presentational

| Layer | Responsibilities |
|-------|-----------------|
| **Smart** (container) | State management, data fetching, side effects. Delegates rendering. |
| **Presentational** | Receives data via props. Pure render. No side effects. |

```typescript
// Smart
function UserProfilePage() {
  const { data, isLoading, error } = useUserProfile(userId);
  if (isLoading) return <SkeletonProfile />;
  if (error) return <ErrorState message={error.message} onRetry={refetch} />;
  return <ProfileDisplay user={data} />;
}

// Presentational
function ProfileDisplay({ user }: { user: User }) {
  return <Card>{user.name}</Card>;
}
```

### Props Design

- **Minimal** — only pass what the component needs
- **Predictable** — boolean defaults to `false`, prefix with `is`/`has`/`show`
- **Explicit** — no `any` or `object`. Prefer union types and interfaces
- **Composed** — use `children` for flexible slots, not 15 optional render props

```typescript
// ✅ Good prop naming
interface ButtonProps {
  isLoading: boolean;
  isDisabled: boolean;
  hasError: boolean;
  showIcon: boolean;
  children: ReactNode;
}
```

### File Organization

```
Component/
├── Component.tsx              ← Main component (default export)
├── Component.test.tsx         ← Tests
├── Component.types.ts         ← Types (colocate if small)
├── sub-components/            ← Internal sub-components (only if 3+)
├── hooks.ts                   ← Component-specific hooks
└── utils.ts                   ← Utilities (only if 2+ functions)
```

For simple components, a single file is fine:
```
Button.tsx
Button.test.tsx
```

### When to Memoize

| Technique | When to use |
|-----------|-------------|
| `React.memo` | Component re-renders often AND render is expensive |
| `useMemo` | Expensive computations only (derived data from large arrays) |
| `useCallback` | Stable function references passed to memoized children |
| **Default** | No memoization — measure first, optimize second |

---

## 2. State Management

### State Ownership Ladder

```
Component-local state   → useState
Parent-to-child         → props drilling (1-2 levels)
Shared sibling          → lift state up or context
App-wide global         → dedicated store (auth, theme)
Server state            → caching layer (TanStack Query, SWR, RTK Query)
URL state               → URL params (search, filters, pagination)
```

### State Types

| Type | Example | Storage |
|------|---------|---------|
| Local UI | Dropdown open/closed | `useState` |
| Shared UI | Theme, sidebar, toasts | Context |
| Server | Users, products, search results | Cache library |
| URL | `?page=2&sort=name` | URL params |
| Form | Draft edits, validation | Form library |
| Derived | Filtered list, computed total | `useMemo` |

**Never store derived state.** If it can be computed from other state, compute it.

### URL-First for Persistent State

If refreshing the page should preserve the view — it goes in the URL:

```typescript
// ✅ URL params for: search, filters, pagination, tabs
// useSearchParams or router query params

// ❌ useState for these means losing user's place on refresh
```

### Context Optimization

Split contexts by concern. Changing theme shouldn't re-render notification consumers:

```typescript
// ❌ Single context
const AppContext = createContext({ theme, user, notifications });

// ✅ Split
const ThemeContext = createContext(theme);
const UserContext = createContext(user);
const NotificationContext = createContext(notifications);
```

### Side Effects (`useEffect`)

- Every effect with subscriptions/timers needs a cleanup function
- No effects for derived state (compute it)
- No effects for user actions (handle in event handler)
- The `exhaustive-deps` lint rule is mandatory

```typescript
// ✅ Subscribe with cleanup
useEffect(() => {
  const sub = websocket.subscribe(channel, handler);
  return () => sub.unsubscribe();
}, [channel]);
```

---

## 3. Performance & Core Web Vitals

### Targets

| Metric | Target | What it measures |
|--------|--------|-----------------|
| **LCP** | ≤ 2.5s | Perceived load speed |
| **INP** | ≤ 200ms | Responsiveness |
| **CLS** | ≤ 0.1 | Visual stability |
| **TBT** | ≤ 200ms | Main thread availability |
| **FCP** | ≤ 1.8s | First content shown |

### Bundle Budgets

| Asset | Max (gzip) |
|-------|------------|
| Initial JS | 100 KB |
| Initial CSS | 30 KB |
| Route chunk | 50 KB |
| Hero image (LCP) | 100 KB |
| Font (WOFF2) | 30 KB |

### Image Rules

Every `<img>` needs:
- `loading="lazy"` (below-fold images)
- `width` + `height` (prevents CLS)
- `alt` text
- `srcset` + `sizes` (responsive)
- WebP or AVIF format

```html
<img
  src="/photo.jpg"
  srcset="/photo-400.webp 400w, /photo-800.webp 800w"
  sizes="(max-width: 600px) 100vw, 50vw"
  width="800"
  height="600"
  loading="lazy"
  alt="Description"
/>
```

### Lazy Loading Strategy

| Pattern | Technique |
|---------|-----------|
| Routes | Dynamic imports per route |
| Heavy components | `React.lazy()` + `<Suspense>` |
| Offscreen | Intersection Observer |
| On interaction | Preload on `pointerenter` |

### Animation Performance

Animate only `transform` and `opacity` — they run on the compositor thread (GPU).

```css
/* ✅ GPU-composited */
.panel { transition: transform 200ms ease; }

/* ❌ Triggers layout — expensive */
.panel { transition: width 200ms ease; }
```

---

## 4. Accessibility (a11y)

### Semantic HTML First

| Pattern | ✅ Use | ❌ Don't use |
|---------|--------|-------------|
| Action | `<button>` | `<div onclick>` with `role="button"` |
| Navigation | `<a href="...">` | `<span onclick="navigate()">` |
| Heading | `<h1>`-`<h6>` | `<div class="heading-1">` |
| List | `<ul>` + `<li>` | `<div>` with manual bullets |

### Keyboard Navigation

Every interactive element must work via keyboard:

| Key | Action |
|-----|--------|
| Tab | Focus next |
| Shift+Tab | Focus previous |
| Enter/Space | Activate |
| Escape | Close modal/drawer/menu |
| Arrow keys | Navigate lists, tabs, selects |

### Screen Reader Checklist

- Icon buttons need `aria-label="Description"`
- Live regions use `aria-live="polite"` (or `"assertive"` for errors)
- Error messages use `role="alert"` linked via `aria-describedby`
- Forms use `fieldset` + `legend` for grouped inputs
- Every `input` has a `<label>`
- Dynamic content updates announce with `aria-live` regions

### Color Contrast

| Requirement | Ratio |
|-------------|-------|
| Normal text AA | 4.5:1 |
| Large text (18px+ or 14px bold) | 3:1 |
| UI components (borders, focus, icons) | 3:1 |

**Never use color as the only way to convey information.**

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Test for Accessibility

```bash
# Every PR
- axe-core / Lighthouse (automated)
- Keyboard nav (manual)
- Screen reader (VoiceOver or NVDA)
- 200% zoom
- Reduced motion
```

---

## 5. Styling & CSS Architecture

### Token System First

Never use raw values. Always reference design tokens:

```css
/* ❌ Raw */
.button { color: #1a73e8; font-size: 14px; border-radius: 8px; }

/* ✅ Tokens */
.button { color: var(--color-primary); font-size: var(--font-size-sm); border-radius: var(--radius-md); }
```

### Required Token Categories

| Category | Pattern |
|----------|---------|
| Colors | `--color-primary`, `--color-bg`, `--color-text`, `--color-border` |
| Typography | `--font-family`, `--font-size-sm`, `--line-height` |
| Spacing | 4px scale: `--spacing-xs` (4px) → `--spacing-3xl` (64px) |
| Radii | `--radius-sm` (4px), `--radius-md` (8px), `--radius-lg` (12px) |
| Shadows | `--shadow-sm`, `--shadow-md`, `--shadow-lg` |
| Z-index | `--z-dropdown`, `--z-modal`, `--z-tooltip` |

### Mobile-First Responsive

```css
.grid {
  display: grid;
  grid-template-columns: 1fr;          /* mobile */
}

@media (min-width: 640px) {
  .grid { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 1024px) {
  .grid { grid-template-columns: repeat(3, 1fr); }
}
```

### Class Naming

Describe **what** the element is, not **how** it looks:
- ✅ `sidebar`, `error-message`, `primary-action`
- ❌ `blue-box`, `left-column`, `big-font`

### Dark Mode Strategy

```css
:root { --color-bg: #fff; --color-text: #1a1a1a; }
[data-theme="dark"] { --color-bg: #1a1a1a; --color-text: #e0e0e0; }

body { background: var(--color-bg); color: var(--color-text); }
```

---

## 6. Error, Loading & Empty States

### The Four States Contract

Every data-driven component handles exactly four states:

1. **Loading** — Skeleton matching content shape (never just "Loading...")
2. **Error** — Clear message + retry button + logged error
3. **Empty** — Helpful message + CTA (not an error!)
4. **Success** — The actual content

```typescript
function DataSection() {
  const { data, isLoading, error, isEmpty } = useData();

  if (isLoading) return <SkeletonSection />;
  if (error) return <ErrorState error={error} onRetry={refetch} />;
  if (isEmpty) return <EmptyState />;
  return <Content data={data} />;
}
```

### Loading Patterns

| Content | Skeleton |
|---------|----------|
| Text block | 3-4 gray bars of varying widths |
| Card grid | Card-shaped placeholders with pulse animation |
| Table | Row-after-row of column-matching bars |
| Avatar + text | Circle + 2 text lines |

### Error State Requirements

- Clear message in plain language (not "Error 500")
- "Try again" button
- Error doesn't crash other sections (Error Boundary)
- Error is logged

### Empty State Examples

| Situation | Content |
|-----------|---------|
| No search results | "No results for [query]. Try different keywords." |
| Empty list | "Nothing here yet." + CTA |
| New user | Onboarding + "Get started" |

### Error Boundary Placement

```
<App>                            ← catastrophic (full-page crash screen)
  <main>
    <ErrorBoundary>              ← section-level (each widget fails independently)
      <DashboardWidgets />
    </ErrorBoundary>
    <ErrorBoundary>
      <DataTable />
    </ErrorBoundary>
  </main>
</App>
```

---

## 7. API Integration & Data Fetching

### Use a Cache Layer

No raw `fetch()` or `axios` in components. Use TanStack Query, SWR, or RTK Query.

```typescript
// ✅ Use a cache library
function UserProfile() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user', id],
    queryFn: () => apiClient(`/users/${id}`),
  });
}
```

### API Client Pattern

```typescript
const API_BASE = import.meta.env.VITE_API_URL || '/api';

export async function apiClient<T>(endpoint: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    ...options,
  });

  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new ApiError(response.status, body.code || 'UNKNOWN', body.message || response.statusText);
  }

  return response.json();
}
```

### Error Handling Per Status

| Status | Action |
|--------|--------|
| 4xx | Show message, don't retry automatically |
| 401 | Redirect to login |
| 429 | Retry with exponential backoff |
| 5xx | Retry (max 3), then show error |

### Optimistic Updates

For mutations, update the UI immediately and roll back on error:

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onMutate: async (data) => {
    await queryClient.cancelQueries({ queryKey: ['user'] });
    const previous = queryClient.getQueryData(['user']);
    queryClient.setQueryData(['user'], (old) => ({ ...old, ...data }));
    return { previous };
  },
  onError: (err, data, context) => {
    queryClient.setQueryData(['user'], context?.previous); // rollback
  },
});
```

---

## 8. Testing Strategy

### The Testing Trophy

```
         ╱  E2E (Playwright/Cypress) ╲        ← Few: critical user journeys
        ╱  Integration (RTL) ╲                ← Most: user interactions + mocked API
       ╱  Component (RTL) ╲                   ← Many: rendering, props, edge cases
      ╱  Unit (Vitest) ╲                     ← Some: pure functions, utils, hooks
     ╱  Static (TypeScript, ESLint) ╲        ← All: type-checking catches most bugs
```

### Query Elements Like a User

```typescript
// ✅ Priority order:
screen.getByRole('button', { name: /submit/i });    // best — acc name
screen.getByLabelText('Email');                       // form fields
screen.getByPlaceholderText('Search...');              // last resort
screen.getByTestId('submit');                          // only for E2E

// ❌ Never:
screen.getByClassName('btn-primary');
find('button');  // BEM or DOM structure
```

### Mocking

- **API calls** → MSW (Mock Service Worker) — intercepts at network level, works in Node and browser
- **Browser APIs** → `vi.spyOn()`
- **Third-party components** → `vi.mock('module')`

### What to Test vs What Not to Test

| Test | Don't test |
|------|-----------|
| User flows (login, checkout, search) | Implementation (state setters, class names) |
| Component rendering with different props | Snapshots (brittle, low value) |
| Edge cases (empty, error, loading) | Internal component state |
| Accessibility (axe-core) | CSS styles |

### Critical Coverage Thresholds

| Metric | Target |
|--------|--------|
| Line coverage | 80% |
| Branch coverage | 75% |
| Critical paths (auth, checkout) | 100% |

---

## 9. Frontend Security

### XSS Prevention

- Never use `dangerouslySetInnerHTML` (or `v-html`) without DOMPurify
- Never interpolate user input into URLs — validate protocol first
- User content always goes in text nodes, never raw HTML

### Content Security Policy

```html
Content-Security-Policy:
  default-src 'self';
  script-src 'self';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  connect-src 'self' https://api.yourdomain.com;
  frame-ancestors 'none';
```

### Token Storage

- **Best:** httpOnly cookie (set by the backend)
- **SPA fallback:** In-memory variable (refreshed via httpOnly refresh cookie)
- **Never:** localStorage, sessionStorage, `document.cookie` (all readable by JS)

### Other Must-Knows

- Pin dependency versions. Commit lockfile. Run `npm audit`.
- CDN scripts need `integrity` (SRI) attribute
- Validate all redirect URLs against an allowlist
- Don't expose API keys in client code (every env var starting with `VITE_` or `NEXT_PUBLIC_` is public)

---

## 10. Forms & Input UX

### Form UX Standards

- Every input has a visible `<label>`
- Required fields show `*` + `aria-required="true"`
- Error messages appear **below** the field, not in a tooltip
- Validate on blur (not keystroke), except async validation (username, email)

### Input Types and Autocomplete

```html
<input type="email" autoComplete="email" />
<input type="password" autoComplete="current-password" />
<input type="tel" autoComplete="tel" />
<input type="text" inputMode="numeric" />  <!-- for numbers, not <input type="number"> -->
```

### Confirmation Patterns

- **Delete:** Modal + "This cannot be undone" + confirm button
- **Discard:** "Unsaved changes" modal
- **Payment:** Button shows the amount: "Pay $49.99" (never just "Submit")

### Keyboard Support

Enter submits. Tab advances. Escape closes dropdowns/modals.

---

## 11. Build Tooling & Project Config

### CI Pipeline Order

```bash
tsc --noEmit          # Type check
eslint .              # Lint
prettier --check .    # Format
vitest run            # Unit + integration tests
vite build            # Build
bundle-visualizer     # Bundle size check
npx playwright test   # E2E (few, critical)
```

### TypeScript Strict Mode

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true
  }
}
```

### Import Rules

- Prefer absolute imports (`@/components/Button`) over deep relatives (`../../../Button`)
- Barrel files only for public API surfaces — not as re-export dumping grounds

### Pre-commit Hooks

```json
{
  "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{css,scss}": ["prettier --write"],
  "*.{json,md}": ["prettier --write"]
}
```

---

## AI Rule Files

These rules are stored in `.brain/frontend/rules/` and loaded automatically by the AI per task:

| Rule file | Loaded when |
|-----------|-------------|
| `COMPONENT_ARCHITECTURE.md` | Building or reviewing components |
| `STATE_MANAGEMENT.md` | Managing state, contexts, side effects |
| `PERFORMANCE.md` | Performance optimization, bundle analysis |
| `ACCESSIBILITY.md` | Building accessible UI, reviewing a11y |
| `STYLING.md` | CSS, theming, responsive design |
| `ERROR_LOADING_UX.md` | Data-driven components, loading states |
| `API_INTEGRATION.md` | API calls, data fetching, caching |
| `TESTING.md` | Writing or reviewing tests |
| `SECURITY.md` | Security review, auth, XSS prevention |
| `FORMS_AND_INPUT.md` | Form building, validation, input UX |
| `BUILD_TOOLING.md` | Build config, CI, linting, TypeScript |

---

*Last updated: 2026-07-23*
*Maintained by: RAI-Engineering brain*
