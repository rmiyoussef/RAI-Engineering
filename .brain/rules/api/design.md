---
domains: [backend]
---

# API Design Rules

> **Merged v2.0** — Original 12 REST rules + Hyrum's Law, contract-first design, TypeScript interface patterns, consistent error semantics.
> **Loaded by:** PLANNER agent, EXECUTOR agent, REVIEWER agent, BACKEND QA agent.

---

## R0 — Design Principles

**Hyrum's Law:** "With a sufficient number of users of an API, all observable behaviors of your system will be depended on by somebody." — Design interfaces that hide implementation details. Every leaky behavior (timing, ordering, error text) becomes a contract.

**Contract First:** Define the interface contract (schema, types, error shapes) before writing implementation. The contract is the source of truth.

**Consistent Error Semantics:** Every error follows the same shape, same codes, same patterns. Clients shouldn't need to parse error messages.

**Validate at Boundaries:** Every entry point validates its input against the contract. Invalid input is rejected before reaching business logic.

**Prefer Addition Over Modification:** Adding fields is safe. Changing or removing fields breaks clients. Deprecate before removing.

## R1 — RESTful URL Conventions

Resources are plural nouns. Actions are HTTP methods:

```
GET    /resources          → list resources
POST   /resources          → create a resource
GET    /resources/{id}     → get a resource
PUT    /resources/{id}     → replace a resource
PATCH  /resources/{id}     → partially update a resource
DELETE /resources/{id}     → delete a resource
```

Nested resources:

```
GET    /resources/{id}/sub-resources
POST   /resources/{id}/sub-resources
```

## R2 — Use Actions, Not Verbs in URLs

Actions on resources use sub-resources or custom routes, not verbs:

```
❌ POST /api/create-user
❌ POST /api/users/create
❌ GET  /api/get-users
✅ POST /api/users

❌ POST /api/activate-user/123
✅ POST /api/users/123/activate
```

## R3 — Consistent Response Format

Every response follows the same structure:

**Success (single):**
```json
{
    "data": { ... }
}
```

**Success (collection):**
```json
{
    "data": [ ... ],
    "meta": {
        "current_page": 1,
        "per_page": 20,
        "total": 150,
        "last_page": 8
    }
}
```

**Error:**
```json
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "The given data was invalid.",
        "details": {
            "email": ["The email field is required."]
        }
    }
}
```

## R4 — Correct HTTP Status Codes

| Code | When |
|------|------|
| 200 | Resource retrieved or updated |
| 201 | Resource created |
| 204 | Resource deleted (no content) |
| 400 | Bad request (malformed payload) |
| 401 | Unauthenticated (no valid credentials) |
| 403 | Forbidden (authenticated but not allowed) |
| 404 | Resource not found |
| 409 | Conflict (duplicate, stale version) |
| 422 | Validation error |
| 429 | Rate limit exceeded |
| 500 | Internal server error |

Never return 200 with an error in the body. Use the correct status code.

## R5 — Version Your API

Use URL prefixing for API versioning:

```
/api/v1/users
/api/v2/users
```

When breaking changes are needed, increment the version. Maintain backward compatibility for at least one release cycle.

## R6 — Use Sparse Fieldsets

Allow clients to request only the fields they need:

```
GET /api/users?fields=id,name,email
```

Response:
```json
{
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
    }
}
```

## R7 — Use Pagination for Lists

Every list endpoint must be paginated:

```
GET /api/users?page=2&per_page=20
```

```json
{
    "data": [...],
    "meta": {
        "current_page": 2,
        "per_page": 20,
        "total": 150,
        "last_page": 8,
        "next_page_url": "/api/users?page=3",
        "prev_page_url": "/api/users?page=1"
    }
}
```

## R8 — Consistent Error Codes

Every error has a machine-readable code:

```json
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "The given data was invalid."
    }
}
```

Common codes: `VALIDATION_ERROR`, `NOT_FOUND`, `UNAUTHENTICATED`, `FORBIDDEN`, `RATE_LIMITED`, `CONFLICT`, `INTERNAL_ERROR`, `SERVICE_UNAVAILABLE`.

## R9 — Use ETags for Caching (Optional)

```
Response: ETag: "abc123"
Request:  If-None-Match: "abc123"
Response: 304 Not Modified (empty body)
```

## R10 — Never Include Sensitive Data

API responses must never include:
- Passwords or password hashes
- API keys or tokens
- Internal IDs (use UUIDs for public references)
- Personal data beyond what the client needs
- Internal implementation details

Use API resources/transformers to control output.

## R11 — Idempotency for Mutations (Optional)

Allow clients to retry mutations without side effects:

```
POST /api/orders
Idempotency-Key: unique-key-123
```

If the same key is received within 24 hours, return the previous response instead of creating a duplicate.

## R12 — Document Breaking Changes

| Type | Examples | Requires Version Bump? |
|------|----------|----------------------|
| Non-breaking | Adding a field, adding an endpoint | No |
| Breaking | Removing a field, changing a field type, changing status codes | Yes |
| Deprecation | Marking a field as deprecated | No, but document the replacement |

## R13 — TypeScript Interface Patterns (for SDK/API types)

When defining TypeScript interfaces for your API:

**Use discriminated unions for variant responses:**
```typescript
type ApiResponse<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; code: string; message: string }
```

**Separate input and output types:**
```typescript
// Input — what the client sends (all fields optional for PATCH)
interface UpdateUserInput {
  name?: string;
  email?: string;
}

// Output — what the server returns (all fields present)
interface UserResponse {
  id: string;
  name: string;
  email: string;
  created_at: string;
}
```

**Branded types for IDs (prevent type confusion):**
```typescript
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };
```

## R14 — Verification Checklist

- [ ] Consistent response format across all endpoints
- [ ] Correct HTTP status codes (no 200-with-error-in-body)
- [ ] Pagination on all list endpoints
- [ ] Error responses have machine-readable codes
- [ ] No sensitive data in responses
- [ ] Input/output types are separated (TypeScript SDKs)
- [ ] Deprecation notice + replacement documented before breaking changes
- [ ] Rate limiting on auth endpoints
- [ ] Validation at every entry point boundary
