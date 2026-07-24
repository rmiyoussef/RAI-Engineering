# Container & Docker Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent, SECURITY agent
> **Domain:** DevOps — container-first architecture
> **Purpose:** Secure, minimal, reproducible container images and runtimes.

---

## R1 — Image Size Rules

| Rule | Target | Why |
|------|--------|-----|
| Use distroless or Alpine base images | < 50 MB for compiled apps, < 200 MB for interpreted | Smaller attack surface, faster pulls |
| Multi-stage builds for compiled languages | Final image contains only runtime (no build tools) | Reduces size, eliminates build-time CVEs |
| Never pin `latest` | Exact tags only: `node:22-alpine@sha256:...` | Reproducible builds |
| One service per container | Don't run multiple processes | Simpler scaling, health checks, logging |

```dockerfile
# ✅ Multi-stage build
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:22-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY dist ./dist
USER node
CMD ["node", "dist/index.js"]
```

## R2 — Dockerfile Best Practices

```dockerfile
# ✅ Order layers by change frequency (least → most frequent)
FROM node:22-alpine
WORKDIR /app

# 1. System dependencies (rarely change)
RUN apk add --no-cache curl ca-certificates

# 2. Package manifest (changes on dependency update)
COPY package*.json ./
RUN npm ci --only=production

# 3. Application code (changes on every commit)
COPY dist ./dist

# 4. Don't run as root
USER node

# 5. Use exec form (receives signals correctly)
CMD ["node", "dist/index.js"]

# 6. Read-only root filesystem
# (in k8s pod spec, not dockerfile)
```

### Layer Ordering

| Layer position | Content | Cache hit rate |
|----------------|---------|----------------|
| 1 | Base image | ~100% |
| 2 | System deps | ~99% |
| 3 | Lockfile + install | ~90% |
| 4 | App config | ~80% |
| 5 | Compiled/bundled code | ~10% |

## R3 — Security Scanning

| Stage | Tool | Action |
|-------|------|--------|
| Build | Docker Scout, Trivy, Grype | Scan image before push. Fail on critical/high CVEs |
| CI | Trivy, Snyk | Scan every build. Block PRs with new critical vulns |
| Registry | Docker Scout, Harbor | Continuously scan stored images, alert on new CVEs |
| Runtime | Falco, Tracee | Detect anomalous container behavior |

```yaml
# CI image scan step
- name: Scan image for vulnerabilities
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:${{ github.sha }}
    exit-code: '1'
    severity: 'CRITICAL,HIGH'
```

## R4 — Container Resource Limits

```yaml
# ✅ Always set CPU and memory limits
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

| Resource | Ratio (limits/requests) | Max |
|----------|------------------------|-----|
| Memory | 2x | 8 Gi per container |
| CPU | 2-4x | 4 cores per container |

## R5 — Container Anti-Patterns

| Anti-pattern | Fix |
|-------------|-----|
| Using `:latest` tag | Pin exact version + digest |
| Running as root in container | Use `USER` directive + non-root k8s `securityContext` |
| Storing secrets in image layers | Use secrets manager, mount at runtime |
| Large single-layer images | Multi-stage builds |
| No health check | Add `HEALTHCHECK` instruction |
| SSH daemon in container | Remove — use `kubectl exec` or `kubectl debug` |
| Installing build tools in production image | Multi-stage — build in builder, copy artifacts |
| Unnecessary packages | Minimal base, only install what the app needs |

## R6 — Docker Compose Rules

```yaml
# ✅ Production-quality docker-compose
version: "3.9"
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:3000:3000"   # bind to localhost only in dev
    environment:
      - DB_HOST=db
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

volumes:
  pgdata:

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## R7 — Container Logging

- Log to stdout/stderr (not files). Container runtime handles collection.
- Use structured logging (JSON format — one object per line)
- Never log tokens, passwords, PII, or secrets
- Include: timestamp, level, service name, request ID, message

```typescript
// ✅ Structured log output (stdout)
{ "ts": "2026-07-23T10:00:00Z", "level": "info", "service": "api", "trace": "abc123", "msg": "request completed", "duration_ms": 42 }
```
