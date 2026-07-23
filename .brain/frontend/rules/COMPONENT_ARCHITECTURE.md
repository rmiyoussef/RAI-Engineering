# Component Architecture Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent, PLANNER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Build composable, maintainable, predictable UI components.

---

## R1 — One Responsibility Per Component

A component should do one thing and do it well. If a component handles multiple concerns, extract them.

**Bad:** A `UserProfile` component that fetches data, renders a form, manages routing, and shows notifications.

**Good:**
```
UserProfilePage         ← orchestrates (composition)
├── useUserProfile      ← data fetching hook
├── ProfileForm         ← form only
├── NotificationBanner  ← notification only
└── PageLayout          ← layout only
```

## R2 — Props Design Principles

| Principle | Rule |
|-----------|------|
| **Minimal** | Only pass what the component needs. No `{...rest}` splats that bypass explicit prop contracts |
| **Predictable** | Boolean props should default to `false`. Use `is`/`has`/`show` prefixes for booleans |
| **Explicit** | Avoid `any` or `object` prop types. Prefer union types, interfaces, or discriminated unions |
| **Composed** | Use `children` or render props for flexible content slots. Don't accept generic `ReactNode` unless the slot truly accepts anything |
| **Colocation** | Props interface lives with the component, not in a shared types file |

### Boolean Naming Convention

```typescript
// ✅ Good
interface Props {
  isLoading: boolean;
  isDisabled: boolean;
  hasError: boolean;
  showTooltip: boolean;
  canExpand: boolean;
}

// ❌ Avoid
interface Props {
  loading: boolean;    // unclear — what kind of loading?
  disabled: boolean;   // ambiguous
  error: boolean;      // is it showing an error or does it have one?
  tooltip: boolean;    // is it a tooltip or does it show one?
  expand: boolean;     // is it expanding or can it expand?
}
```

## R3 — Composition Over Configuration

Avoid mega-components with 30+ props that toggle features on/off. Prefer composition:

```typescript
// ❌ Prop-driven
<Table data={items} sortable filterable paginated selectable editable={false} />

// ✅ Composition (Slot pattern)
<Table data={items}>
  <Table.SortHeader />
  <Table.FilterBar />
  <Table.Pagination />
  <Table.RowSelection />
</Table>
```

## R4 — Component Surface Area

| Component type | Max props | Max lines |
|---------------|-----------|-----------|
| Presentational (leaf) | 8 | 80 |
| Composable (compound) | 12 | 150 |
| Page/Route | 5 | 200 |
| Layout | 6 | 100 |

When a component exceeds these, refactor or extract sub-components.

## R5 — Smart vs Presentational Separation

- **Presentational (Dumb):** Receives data via props. No side effects. No API calls. Pure rendered output.
- **Container (Smart):** Manages state, side effects, data fetching. Delegates rendering to presentational components.

```typescript
// Smart — manages state
function UserProfilePage() {
  const { data, isLoading, error } = useUserProfile(userId);
  if (isLoading) return <SkeletonProfile />;
  if (error) return <ErrorState message={error.message} />;
  return <ProfileDisplay user={data} />;
}

// Presentational — pure render
function ProfileDisplay({ user }: { user: User }) {
  return <Card>{user.name}</Card>;
}
```

## R6 — Component Export Convention

Default export for the main component. Named exports for sub-components, types, helpers.

```typescript
// Component.tsx
export default function Button() { ... }
export type { ButtonProps };
export { ButtonGroup }; // sub-component, named export
```

## R7 — File Organization Per Component

```
Component/
├── Component.tsx        ← Main component (default export)
├── Component.test.tsx   ← Component tests
├── Component.types.ts   ← TypeScript interfaces (optional — colocate if small)
├── sub-components/      ← Extracted internal components (only if 3+)
├── hooks.ts             ← Component-specific hooks
└── utils.ts             ← Component-specific utilities (only if 2+ pure functions)
```

For small/simple components, a single file is fine:
```
Component.tsx   ← component + props type + small helpers in same file
Component.test.tsx
```

## R8 — Error Boundaries

Every feature section (anything that fetches data or has complex interaction) should be wrapped in an error boundary:

```typescript
<ErrorBoundary fallback={<ErrorFallback />}>
  <ProfileSection userId={id} />
</ErrorBoundary>
```

Error boundaries catch rendering errors in children. They do NOT catch:
- Event handler errors (use try-catch)
- Async errors (handle in the data layer)
- SSR errors

## R9 — Conditional Rendering Patterns

```typescript
// ✅ Short-circuit (safe with primitives)
{isLoading && <Spinner />}

// ✅ Ternary (both branches)
{hasError ? <ErrorState /> : <Content />}

// ❌ Never render 0 or NaN
{items.length && <List />}   // renders "0" when empty
// ✅ Fix:
{items.length > 0 && <List />}

// ✅ Guard clause at top of component
if (!user) return <Redirect to="/login" />;
```

## R10 — Re-render Prevention

- `React.memo` only when: component re-renders often AND the render is expensive (large lists, charts, heavy DOM)
- `useMemo` only for: expensive computations (derived data from large arrays)
- `useCallback` only for: stable function references passed to memoized children
- **Default to no memoization** — measure first, optimize second
