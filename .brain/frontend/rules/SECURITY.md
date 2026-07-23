# Frontend Security Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent, SECURITY agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Protect users, their data, and the application from browser-based attacks.

---

## R1 — XSS Prevention

| Rule | Detail |
|------|--------|
| Never use `dangerouslySetInnerHTML` / `v-html` | If you must, sanitize with DOMPurify first |
| Never interpolate user input into URLs without validation | `javascript:` protocol is dangerous |
| Use text content, not HTML, for user-generated content | `<div>{userComment}</div>` — safe |
| Dynamic URLs: validate protocol | `new URL(url).protocol === 'https:'` |
| JSON in `<script>` tags: use `JSON.parse` not `eval` | Or use `<script type="application/json">` |

```typescript
// ✅ Safe: template literals for display (framework auto-escapes)
<div>{user.name}</div>
<div>{user.bio}</div>

// ⚠️ If dangerouslySetInnerHTML is unavoidable (rich text from CMS)
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(cmsContent) }} />

// ❌ Never: user input as HTML without sanitization
<div dangerouslySetInnerHTML={{ __html: user.bio }} />
```

## R2 — Content Security Policy (CSP)

```html
<!-- Recommended CSP header -->
Content-Security-Policy:
  default-src 'self';
  script-src 'self';
  style-src 'self' 'unsafe-inline';  <!-- if using CSS-in-JS or frameworks -->
  img-src 'self' data: https:;
  font-src 'self' https:;
  connect-src 'self' https://api.yourdomain.com;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
```

## R3 — Authentication Token Storage

```typescript
// ✅ Store tokens in httpOnly cookie (set by backend)
// ❌ Never store tokens in:
localStorage.setItem('token', jwt);        // Vulnerable to XSS
sessionStorage.setItem('token', jwt);      // Also vulnerable
document.cookie = `token=${jwt}`;          // Non-httpOnly cookie
window.__TOKEN = jwt;                      // Global variable

// ✅ Acceptable only in SPAs without httpOnly support:
// - Use short-lived tokens (15 min)
// - Store in memory (variable), not in storage API
// - Refresh token is httpOnly cookie set by backend
let accessToken: string | null = null;

export function setToken(token: string) {
  accessToken = token;
}

export function getToken(): string | null {
  return accessToken;
}
```

## R4 — CSRF Protection

| Pattern | Protection |
|---------|-----------|
| SameSite cookies | `Set-Cookie: session=...; SameSite=Lax; Secure; HttpOnly` |
| CSRF tokens | Include anti-CSRF token in request headers or forms |
| Custom headers | Check for `X-Requested-With: XMLHttpRequest` on API endpoints |
| Double-submit cookie | Send random value in cookie and header; server compares |

## R5 — Form Input Validation

```typescript
// ✅ Validate on the frontend too (never rely solely on backend)
function validateEmail(email: string): string | null {
  if (!email) return 'Email is required';
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return 'Invalid email format';
  if (email.length > 254) return 'Email is too long';
  return null;
}

function sanitizeInput(input: string): string {
  return input
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}
```

## R6 — Third-Party Scripts

| Risk | Mitigation |
|------|-----------|
| CDN compromise | Use Subresource Integrity (SRI) — `<script src="..." integrity="sha384-...">` |
| Data exfiltration | Audit what analytics/tracking scripts can access (they see the DOM) |
| Unnecessary permissions | Review each script's scope — remove unused third-party code |
| Supply chain | Pin exact versions in package.json, use lockfiles, audit with `npm audit` |

```html
<!-- ✅ Always include SRI for CDN scripts -->
<script
  src="https://cdn.example.com/lib@1.0.0/dist/lib.min.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous"
></script>
```

## R7 — Dependency Security

- Pin exact versions in `package.json` (no `^` or `~` for critical dependencies)
- Run `npm audit` or `yarn audit` in CI — fail on critical/high vulnerabilities
- Use `socket.dev` or similar for package risk scoring
- Review dependency count per feature — every dependency is a supply chain risk
- Lockfile (`package-lock.json` / `yarn.lock`) must be committed

## R8 — Clickjacking Protection

```html
<!-- Prevent your app from being iframed by other sites -->
<meta http-equiv="X-Frame-Options" content="DENY">
<!-- OR via CSP: -->
Content-Security-Policy: frame-ancestors 'none';
```

## R9 — Sensitive Data Exposure

| Rule | Example |
|------|---------|
| Don't log tokens or secrets | `console.log('Auth:', token)` |
| Don't store sensitive data in URL params | `?password=s3cret` |
| Don't expose API keys in client code | Environment variables with `VITE_` or `NEXT_PUBLIC_` are PUBLIC |
| Mask sensitive data in the UI | `showPassword ? password : '••••••••'` |
| Clear sensitive state on logout | Clear cache, storage, and app state |

## R10 — Open Redirect Prevention

```typescript
// ✅ Validate redirect URLs against an allowlist
const ALLOWED_REDIRECTS = ['/', '/dashboard', '/settings'];

function safeRedirect(url: string | null): string {
  if (!url) return '/';
  return ALLOWED_REDIRECTS.includes(url) ? url : '/';
}

// ❌ Never:
window.location.href = userInput; // Open redirect vulnerability
```
