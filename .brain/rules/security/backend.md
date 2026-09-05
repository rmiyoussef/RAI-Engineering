---
domains: [backend]
---

# Security Rules

> **Merged v2.0** — Original 12 rules + STRIDE threat modeling, OWASP LLM Top 10, SSRF with DNS rebinding awareness, dependency audit triage, secrets management protocol.
> **Loaded by:** SECURITY agent, REVIEWER agent, BACKEND QA agent, EXECUTOR agent.

---

## R0 — Threat Model First

Before hardening any system, map trust boundaries, name assets, and run **STRIDE** over each boundary:

| Threat | What it targets | Example |
|--------|----------------|---------|
| **S**poofing | Authentication | Attacker impersonates another user |
| **T**ampering | Integrity | Attacker modifies data in transit |
| **R**epudiation | Non-repudiation | User denies performing an action |
| **I**nformation disclosure | Confidentiality | Data leak via error messages |
| **D**enial of service | Availability | Resource exhaustion |
| **E**levation of privilege | Authorization | Normal user gains admin access |

Write **abuse cases** alongside use cases. For each security control, ask: "What happens when this control is missing or bypassed?"

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
{
    "user": { "id": 1, "name": "John Doe", "email": "user@example.com", "role": "admin" }
}
```

## R13 — SSRF Protection

When your application fetches remote URLs based on user input:

1. **Validate URL scheme** — allow only `https://` (not `file://`, `gopher://`, `ftp://`)
2. **Resolve + validate IP** — resolve hostname to IP, reject private/ranged IPs (127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, ::1)
3. **Whitelist allowed domains** — if possible, restrict to a known set
4. **Timeout + size limits** — bound both connection time and response size

⚠️ **DNS rebinding note:** The DNS resolution + IP check approach has a TOCTOU gap — an attacker can switch DNS responses between resolution and connection. Where practical, deny private IP ranges at the network layer (e.g., k8s NetworkPolicy, iptables).

## R14 — Dependency Audit Triage

Before every release, run `npm audit` (or equivalent) and triage by severity:

| Severity | Action |
|----------|--------|
| **Critical/High** | Fix immediately if reachable. If not reachable, document why and plan fix in next sprint. |
| **Moderate** | Fix if reachable and exploitable. Otherwise monitor. |
| **Low** | Note and check next release. |

**Supply-chain hygiene:**
- Find the installation boundary — block dependency scripts from running before execution
- Never blindly apply `npm audit fix --force` — it can break your app
- Review lockfile diffs including transitive dependency changes
- Pin exact versions for critical dependencies

## R15 — AI/LLM Security (OWASP LLM Top 10)

When integrating LLMs into your application:

| Risk | Mitigation |
|------|------------|
| Prompt injection | Treat model output as untrusted. Assume injection is possible. Never put secrets in prompts. |
| Insecure output handling | Never pass model output directly to a shell, eval(), or database query without validation |
| Training data poisoning | Use trusted, controlled data sources for fine-tuning |
| Model denial of service | Bound token consumption per request and per session |
| Supply chain | Vet models and providers. Pin model versions. |
| Sensitive information disclosure | Strip PII from prompts. Never log raw prompts. |
| Over-reliance | Always validate model-generated code/logic before execution |
| Excessive agency | Constrain tool permissions. Never give LLM direct write access to production. |
| Vector store injection | Isolate retrieval data in RAG. Validate retrieved chunks before passing to model. |

## R16 — Secrets Management Protocol

If a secret is ever committed to Git:

1. **Do NOT** just delete it — it's still in Git history
2. **Rotate** the exposed credential immediately
3. Use `git filter-branch` or `bfg repo-cleaner` to purge from history
4. Force push after cleaning

**Prevention:**
- `.env` files are gitignored by default — verify this in every project
- Install a pre-commit hook for secret scanning (e.g., `talisman`, `git-secrets`)
- Never hardcode secrets even in tests or CI configs

## R17 — Common Rationalizations (Rejected)

| Excuse | Reality |
|--------|---------|
| "Frameworks handle security" | Frameworks handle common cases. Business logic vulnerabilities are your responsibility. |
| "It's just a prototype" | Prototypes become production. Secure from day one. |
| "The audit passed, so safe" | Audits are a snapshot. Dependencies change, new vulnerabilities emerge. |
| "We'll add auth later" | Retrofitting auth is harder than building it in. |
| "It's internal, no one will find it" | Internal tools are the most commonly attacked after initial foothold. |

## R18 — Verification Checklist

- [ ] Threat model exists for all trust boundaries
- [ ] All user input validated (type, format, length, range)
- [ ] All queries parameterized (no string concatenation)
- [ ] Auth middleware on every protected route
- [ ] Authorization checks at every action level
- [ ] No secrets in code, logs, or error responses
- [ ] CSP and HSTS headers set
- [ ] Rate limiting on auth endpoints
- [ ] File uploads validated by content, not extension
- [ ] Dependency audit clean of critical/high vulnerabilities
- [ ] SSRF protections in place for URL-fetching features
- [ ] LLM output treated as untrusted data
