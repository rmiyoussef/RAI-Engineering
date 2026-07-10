# Security Rules

> Non-negotiable security rules for every project. These prevent the most common vulnerabilities.

---

## R1 — Never Trust User Input

Every input from the user is potentially malicious. Validate everything:

- **Type:** string, integer, boolean, array — match exactly
- **Format:** email, URL, date, UUID — validate pattern
- **Length:** minimum and maximum
- **Range:** allowed values, enum members
- **Sanitize:** strip unexpected characters

Use whitelist validation, not blacklist:

```
❌ $sort = str_replace(['drop', 'delete', 'union'], '', $request->sort);
✅ $allowedSorts = ['name', 'email', 'created_at'];
✅ $sort = in_array($request->sort, $allowedSorts) ? $request->sort : 'name';
```

## R2 — Parameterize All Queries

Never concatenate user input into SQL queries:

```
❌ $sql = "SELECT * FROM users WHERE email = '" . $email . "'";
✅ DB::select('SELECT * FROM users WHERE email = ?', [$email]);

❌ User::whereRaw("email = '" . $email . "'")->get();
✅ User::where('email', $email)->get();
```

Raw queries must use bound parameters. Always.

## R3 — Prevent Mass Assignment

Use `$fillable` or `$guarded` on all models:

```
❌ class User extends Model { }  // all fields mass-assignable

✅ class User extends Model {
✅     protected $fillable = ['name', 'email', 'password'];
✅ }
```

Never trust user input for role/flag fields:

```
❌ User::create($request->all());  // user could set 'is_admin' => true

✅ User::create($request->validated());  // validated only allows specific fields
```

## R4 — Authenticate Every Protected Route

Every route that requires authentication must have auth middleware:

```
❌ Route::get('/api/orders', [OrderController::class, 'index']);

✅ Route::get('/api/orders', [OrderController::class, 'index'])->middleware('auth');
```

Group protected routes:

```
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('orders', OrderController::class);
});
```

## R5 — Authorize Every Action

Authentication proves who you are. Authorization proves what you can do.

Check ownership, not just role:

```
❌ if ($user->role === 'admin') { $post->delete(); }

✅ // PostPolicy
✅ public function delete(User $user, Post $post): bool {
✅     return $user->id === $post->user_id || $user->isAdmin();
✅ }
```

## R6 — Never Expose Secrets

- No API keys, tokens, or passwords in code
- No secrets in logs, error messages, or debug output
- No secrets in client-side code (JS, HTML comments)
- Use environment variables for all secrets
- .env.example must not contain real values

## R7 — Protect Against XSS

- Escape all user-supplied data in HTML output
- Use `{{ }}` not `{!! !!}` in Blade templates (or equivalent in other frameworks)
- Set Content-Security-Policy headers
- Sanitize HTML input if users can post formatted content

## R8 — CSRF Protection

- Every state-changing request (POST, PUT, PATCH, DELETE) must include a CSRF token
- API routes using tokens/Sanctum are exempt (token itself is the CSRF protection)
- Never disable CSRF middleware globally

## R9 — Rate Limit Public Endpoints

Every public API endpoint must have rate limiting:

| Endpoint | Rate Limit |
|----------|------------|
| Login | 5 per minute per IP+email |
| Registration | 3 per hour per IP |
| Password reset | 3 per hour per email |
| General API | 100 per minute per token |
| File upload | 10 per hour per user |

## R10 — Secure File Uploads

- Validate file type by content (not just extension)
- Limit file size
- Store uploads outside the web root (public disk is acceptable for avatars only)
- Serve uploaded files through a controller (not direct URL)
- Scan all uploads for malicious content
- Rename uploaded files (don't use user-provided names)

## R11 — Enable HTTPS

- All traffic must use HTTPS
- Redirect HTTP to HTTPS
- Set HSTS headers
- Use secure cookies: `Set-Cookie: ...; Secure; HttpOnly; SameSite=Lax`

## R12 — Handle Data Exposure

- Never return models directly from API endpoints (use resources/transformers)
- Hide sensitive fields: `$hidden = ['password', 'remember_token']`
- Don't include unnecessary data in responses
- Use `->makeHidden()` when a specific response should omit fields

```json
// ❌ Exposes internal fields
{
    "user": {
        "id": 1,
        "email": "user@example.com",
        "password_hash": "$2y$10$...",
        "remember_token": "abc123",
        "stripe_customer_id": "cus_xxx"
    }
}

// ✅ Only exposes intended fields
{
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "user@example.com",
        "role": "admin"
    }
}
```
