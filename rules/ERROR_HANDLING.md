# Error Handling Rules

> Consistent error handling across all projects. No silent failures. No swallowed exceptions.

---

## R1 — Throw Specific Exceptions

Use domain-specific exception classes, not generic `\Exception`:

```
❌ throw new \Exception('User not found');
✅ throw new UserNotFoundException($userId);
```

Create one exception per meaningful failure:

```
App\Exceptions\
├── AuthenticationException.php
├── AuthorizationException.php
├── ValidationException.php
├── NotFoundException.php
├── BusinessRuleException.php
└── ExternalServiceException.php
```

## R2 — Never Return Error Values

Errors are thrown, not returned. Never return error arrays or status flags:

```
❌ return ['error' => 'User not found', 'code' => 404];
❌ return false;  // what does false mean?
✅ throw new UserNotFoundException($userId);
```

## R3 — Catch at the Boundary Only

Catch exceptions at the outermost layer (controller, middleware, handler). Don't catch everywhere:

```
❌ // Caught in service layer — hides failure from caller
class UserService {
    public function find($id) {
        try { return User::findOrFail($id); }
        catch (ModelNotFoundException $e) { return null; }
    }
}

✅ // Let it propagate — let the controller decide
class UserService {
    public function find($id): User {
        return User::findOrFail($id);
    }
}
```

## R4 — Log at the Right Level

| Level | When |
|-------|------|
| `debug` | Development-only verbose info |
| `info` | Normal operations: user registered, email sent |
| `warning` | Something unexpected but handled: rate limit hit, retry succeeded |
| `error` | Operation failed but system continues: payment failed, external API down |
| `critical` | System degraded or stopping: database unreachable, out of memory |

## R5 — Never Log Secrets

- No passwords, tokens, API keys in logs
- No credit card numbers, SSNs, PII
- Mask sensitive data: `Log::info('Payment processed', ['user' => $user->id])`
- NEVER `Log::info('User: ' . json_encode($user))` (exposes everything)

## R6 — Fail Fast

- Validate inputs at the boundary (form request, middleware)
- Fail before you touch the database, not after
- Check preconditions early with guard clauses

```
❌ public function update($id, $data) {
       $user = User::find($id);  // waste if data is invalid
       // ... validate data here ...
   }

✅ public function update($id, $data) {
       $validated = $this->validate($data);  // fail fast
       $user = User::findOrFail($id);
   }
```

## R7 — HTTP Status Code Consistency

| Code | When |
|------|------|
| 200 | Success (GET, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Malformed payload |
| 401 | Unauthenticated |
| 403 | Forbidden |
| 404 | Not found |
| 409 | Conflict (duplicate, stale data) |
| 422 | Validation error |
| 429 | Rate limited |
| 500 | Unexpected server error |

## R8 — Global Exception Handler

One handler at the application boundary that:

1. Logs the exception with context
2. Returns consistent JSON error response
3. Never exposes internals in production (no stack traces)

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

## R9 — Distinguish Recoverable vs Unrecoverable

- **Recoverable:** Retry (external API timeout), fallback (cache miss → query DB)
- **Unrecoverable:** Invalid state, missing required data — fail and log

Recoverable errors get a retry mechanism. Unrecoverable errors propagate.

## R10 — Unhandled Exceptions Are Bugs

If an exception isn't caught anywhere, it's a bug. Every exception type should be handled at some boundary. Use a catch-all only as a last resort.
