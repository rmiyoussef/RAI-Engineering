# API Integration & Data Fetching Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Reliable, predictable server communication patterns.

---

## R1 — Use a Dedicated Data Fetching Layer

Do not use raw `fetch()` or `axios` calls inside components. Use a caching/query library:

| Library | Best for |
|---------|----------|
| **TanStack Query** (react-query) | REST APIs, complex caching, mutations |
| **SWR** | Simple REST, light caching |
| **RTK Query** | Redux projects, codegen from OpenAPI |
| **tRPC** | Full-stack TypeScript, no API client code |
| **urql** | GraphQL |

```typescript
// ❌ Raw fetch in component
function UserProfile() {
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser);
  }, []);
}

// ✅ Query library
function UserProfile() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user'],
    queryFn: () => fetch('/api/user').then(r => r.json()),
  });
}
```

## R2 — API Client Pattern

```typescript
// api/client.ts
const API_BASE = import.meta.env.VITE_API_URL || '/api';

export class ApiError extends Error {
  constructor(
    public status: number,
    public code: string,
    message: string,
    public details?: unknown
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  });

  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new ApiError(
      response.status,
      body.code || 'UNKNOWN',
      body.message || response.statusText,
      body.details
    );
  }

  // Handle 204 No Content
  if (response.status === 204) return undefined as T;
  return response.json();
}
```

## R3 — Error Handling Strategy

| Status range | Action |
|-------------|--------|
| 2xx | Success — return data |
| 4xx | Client error — show message, don't retry automatically |
| 401 | Redirect to login, clear auth state |
| 403 | Show "Not authorized" message |
| 404 | Show "Not found" state |
| 422 | Show validation errors on form fields |
| 429 | Retry with exponential backoff |
| 5xx | Retry (max 3), then show error state |

```typescript
// Retry with exponential backoff
const { data, error } = useQuery({
  queryKey: ['user', id],
  queryFn: () => fetchUser(id),
  retry: (failureCount, error) => {
    if (error instanceof ApiError && error.status < 500) return false; // don't retry 4xx
    return failureCount < 3; // retry server errors up to 3 times
  },
  retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 10000), // 1s, 2s, 4s, 10s cap
});
```

## R4 — Mutation Patterns

```typescript
// ✅ Optimistic update (instant UI feedback)
const mutation = useMutation({
  mutationFn: (newName: string) => apiClient.patch(`/users/${id}`, { name: newName }),
  onMutate: async (newName) => {
    await queryClient.cancelQueries({ queryKey: ['user', id] });
    const previous = queryClient.getQueryData(['user', id]);
    queryClient.setQueryData(['user', id], (old: User) => ({ ...old, name: newName }));
    return { previous }; // rollback context
  },
  onError: (err, newName, context) => {
    queryClient.setQueryData(['user', id], context?.previous); // rollback
    showToast('Failed to update name');
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['user', id] }); // refetch from server
  },
});
```

## R5 — Request Deduplication

The data fetching layer must deduplicate identical concurrent requests. Two components on the same page requesting the same endpoint should fire one request.

```typescript
// ⚠️ If not using a cache library:
// Create a simple deduplication layer
const inFlight = new Map<string, Promise<unknown>>();

export async function dedupedFetch<T>(key: string, fetcher: () => Promise<T>): Promise<T> {
  if (inFlight.has(key)) return inFlight.get(key) as Promise<T>;
  const promise = fetcher().finally(() => inFlight.delete(key));
  inFlight.set(key, promise);
  return promise;
}
```

## R6 — Loading and Error Per Endpoint

Each data-fetching component gets its own loading, error, and empty state. Never use a single global loading spinner.

```typescript
function DashboardPage() {
  return (
    <div>
      <ProfileSection />    {/* independent loading */}
      <OrdersSection />     {/* independent loading */}
      <AnalyticsSection />  {/* independent loading */}
    </div>
  );
}
```

## R7 — API Response Contract

Backend API responses should follow a consistent structure:

```typescript
// Success
{
  "data": T,                          // actual payload
  "meta": {                           // optional: pagination, timestamps
    "page": 1,
    "perPage": 20,
    "total": 150
  }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The email field is required.",
    "details": {                      // optional: field-level errors
      "fields": {
        "email": ["is required", "must be a valid email"]
      }
    }
  }
}

// List
{
  "data": T[],
  "meta": { "page": 1, "perPage": 20, "total": 150 }
}
```

## R8 — Type Safety

Always type your API responses:

```typescript
// ✅ Define response types
interface UserResponse {
  data: User;
}

interface PaginatedResponse<T> {
  data: T[];
  meta: { page: number; perPage: number; total: number };
}

// ✅ Typed queries
function useUsers(page: number) {
  return useQuery<PaginatedResponse<User>>({
    queryKey: ['users', page],
    queryFn: () => apiClient(`/users?page=${page}`),
  });
}
```
