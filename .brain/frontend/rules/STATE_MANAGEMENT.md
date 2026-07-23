# State Management Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Predictable, debuggable, performant state architecture.

---

## R1 — State Ownership Ladder

State should live at the lowest common ancestor that needs it. The further up state lives, the harder it is to reason about.

```
Component-local state   → useState (single component, no children)
Parent-to-child state    → props drilling (1-2 levels)
Shared sibling state    → lift state up OR context (3+ levels, infrequent updates)
App-wide global state   → dedicated store (auth, theme, notifications)
Server state            → caching layer (react-query, SWR, RTK Query)
URL state               → URL params (filtering, pagination, search)
```

## R2 — Distinguish State Types

| Type | Storage | Example |
|------|---------|---------|
| **Local UI** | `useState` | Dropdown open/closed, accordion expanded, tab selected |
| **Shared UI** | Context or lifted state | Theme, sidebar collapsed, toasts |
| **Server** | Cache layer | User list, product data, search results |
| **URL** | URL params | `?page=2&sort=name`, `?tab=settings` |
| **Form** | Form library | Draft edits, validation errors, dirty fields |
| **Derived** | `useMemo` | Filtered list, computed total, grouped data |

**Never store derived state.** If it can be computed from other state, compute it.

```typescript
// ❌ Wrong: storing derived state
const [filteredItems, setFilteredItems] = useState(items);
useEffect(() => {
  setFilteredItems(items.filter(i => i.active));
}, [items]);

// ✅ Right: compute it
const filteredItems = useMemo(
  () => items.filter(i => i.active),
  [items]
);
```

## R3 — URL First for Persistent State

If a user should be able to bookmark, share, or refresh and preserve the view — it belongs in the URL.

```typescript
// ✅ URL params for: search, filters, pagination, tab selection
// ❌ Bad: useState for these
const [search, setSearch] = useState('');
const [page, setPage] = useState(1);
// User loses their place on refresh
```

## R4 — Context Optimization

Context re-renders every consumer when ANY value changes. Optimize:

```typescript
// ❌ Single context with unrelated values
const AppContext = createContext({ theme, user, notifications, locale });
// Changing locale re-renders user-dependent components

// ✅ Split by concern
const ThemeContext = createContext(theme);
const UserContext = createContext(user);
const NotificationContext = createContext(notifications);
```

For high-frequency updates (animations, mouse position, real-time data), use:
- Separate small contexts
- External store (Zustand, Jotai, Valtio)
- `useSyncExternalStore`

## R5 — Side Effects Rules

| Tool | When |
|------|------|
| `useEffect` | Synchronizing with external systems (Browser API, analytics, WebSocket) |
| Event handlers | User-initiated state changes (button clicks, form submissions) |
| Query cache library | Server data fetching, polling, caching |
| Form library | Form validation, submission, dirty tracking |

### `useEffect` Hygiene

- Every `useEffect` must have a cleanup function if it sets up subscriptions, timers, or listeners
- No `useEffect` for derived state (compute it)
- No `useEffect` for user-initiated actions (handle in the event)
- Dependencies: include everything the effect reads. Lint rule `react-hooks/exhaustive-deps` is mandatory.

```typescript
// ✅ Subscribe with cleanup
useEffect(() => {
  const sub = websocket.subscribe(channel, handler);
  return () => sub.unsubscribe();
}, [channel]);

// ❌ User action in useEffect
useEffect(() => { if (submitted) saveData(); }, [submitted]);
// ✅ Handle in the submit handler
function handleSubmit() {
  saveData();
  setSubmitted(true);
}
```

## R6 — Server State Rules

| Rule | Why |
|------|-----|
| Cache server data separately from UI state | Server data has different lifecycle (stale-while-revalidate, refetch on focus, pagination) |
| Keep server cache normalized | Avoid duplicate requests, stale data across views |
| Optimistic updates for user-initiated mutations | Instant UI feedback, rollback on error |
| Deduplicate concurrent requests | Two components requesting the same data should fire one request |
| Refetch on window focus | Users expect fresh data when returning to tab |

## R7 — Reduce Re-renders

- Extract expensive sub-trees into memoized or context-split components
- `useCallback` + `useMemo` are LAST RESORT, not default. Measure first.
- Move STATE DOWN to the component that renders it. Components farther up the tree don't need it.
- Move STATE UP only when siblings/children need to share it.

```typescript
// ✅ State lives as close to the consumer as possible
function Page() {
  return (
    <div>
      <ExpensiveHeader />    {/* won't re-render */}
      <SearchableList />     {/* search state lives here */}
    </div>
  );
}

function SearchableList() {
  const [query, setQuery] = useState(''); // state lives here
  return <div>...</div>;
}
```
