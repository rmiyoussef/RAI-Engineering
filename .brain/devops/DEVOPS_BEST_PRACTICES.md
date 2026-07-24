# DevOps Engineering Best Practices

> **Domain:** DevOps — cloud, containers, CI/CD, infrastructure
> **Purpose:** A living reference for building and operating production-grade infrastructure.
> **AI rules:** `./rules/` — loaded automatically by the AI per task.

---

## Table of Contents

1. [Containers & Docker](#1-containers--docker)
2. [Kubernetes](#2-kubernetes)
3. [CI/CD Pipelines](#3-cicd-pipelines)
4. [Infrastructure as Code (Terraform)](#4-infrastructure-as-code-terraform)
5. [Cloud Services](#5-cloud-services)
6. [Monitoring & Observability](#6-monitoring--observability)
7. [Security](#7-security)
8. [Networking & DNS](#8-networking--dns)
9. [Database Operations](#9-database-operations)
10. [Backup, DR & Incident Response](#10-backup-dr--incident-response)
11. [Cost Optimization](#11-cost-optimization)
12. [Release & Change Management](#12-release--change-management)
13. [Automation & Scripting](#13-automation--scripting)

---

## 1. Containers & Docker

### Dockerfile Best Practices

```
Base image (Alpine/distroless, pinned digest)
    ↓
Install system dependencies (apk add --no-cache)
    ↓
Copy package manifest + install deps
    ↓
Copy application code
    ↓
USER non-root
    ↓
HEALTHCHECK
    ↓
CMD ["executable"]
```

### Multi-Stage Builds

```dockerfile
FROM node:22-alpine AS builder
COPY package*.json ./
RUN npm ci
COPY src ./src
RUN npm run build

FROM node:22-alpine
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER node
CMD ["node", "dist/index.js"]
```

### Key Rules

- **Pin base image tags** (never `:latest`) — use digest for production
- **Order layers by change frequency** — lockfile first, code last
- **Run as non-root** — `USER node` or similar
- **Scan images** — Trivy, Docker Scout, Grype in CI
- **Set resource limits** — always define CPU/Memory requests and limits

---

## 2. Kubernetes

### Pod Spec Checklist

- [ ] Resource requests and limits
- [ ] Liveness, readiness, and startup probes
- [ ] Security context: `runAsNonRoot: true`
- [ ] Service account (not `default`)
- [ ] PodDisruptionBudget (for production)
- [ ] NetworkPolicy (ingress + egress)
- [ ] HorizontalPodAutoscaler (for stateless workloads)

### Deployment Strategy

| Strategy | Use case |
|----------|----------|
| RollingUpdate | Stateless apps (default) |
| Blue/Green | Critical traffic, canary releases |
| Recreate | Stateful apps, DB migrations |

### Probe Guide

- **livenessProbe** — Is the app alive? Kill + restart if fails
- **readinessProbe** — Can it serve traffic? Remove from Service if fails
- **startupProbe** — Has it initialized? Delays liveness checks for slow apps

---

## 3. CI/CD Pipelines

### Pipeline Stages (Ordered)

```
Lint & Format → Type Check → Unit Tests → Build → Integration Tests
    → Security Scan → Image Build → Deploy Staging → Smoke Tests
    ═══════════════════ Manual Gate ═══════════════════
    → Deploy Production → Health Check
```

### Performance Targets

| Stage | Target |
|-------|--------|
| Total pipeline | < 10 min |
| Fast feedback (lint + test) | < 3 min |
| Deployment | < 2 min |

### Branch Protection

- All checks must pass before merge
- Linear history required
- At least 1 code review approval
- Production deploys require manual approval

---

## 4. Infrastructure as Code (Terraform)

### State Management

- **Never commit** `terraform.tfstate` to Git
- Use **remote state** with locking (S3 + DynamoDB)
- **Encrypt** state at rest
- **Version** the state bucket
- **Separate state** per environment

### Module Structure

```
terraform/
├── environments/
│   ├── production/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── staging/
├── modules/
│   ├── networking/
│   └── compute/
└── versions.tf
```

### CI for IaC

```
terraform fmt -check → terraform validate → checkov/tfsec scan
    → terraform plan → (review) → terraform apply
```

---

## 5. Cloud Services

### Multi-AZ Architecture

| Component | AZs |
|-----------|-----|
| Compute (ECS/EKS) | 3 AZs |
| Database (RDS/Aurora) | Multi-AZ |
| Cache (Redis) | Replica in 2nd AZ |
| Load balancer | 2+ AZs |

### Database Baseline

| Setting | Value |
|---------|-------|
| Backups | Daily, 30-day retention |
| PITR | Enabled |
| Encryption | KMS (at rest), TLS 1.2+ (in transit) |
| Deletion protection | On |
| Maintenance | Off-peak, predictable schedule |

### IAM Principle

**Least privilege.** Every service gets its own role with only the permissions it needs. No `*:*` policies. No access keys for humans (SSO/OIDC only).

---

## 6. Monitoring & Observability

### Three Pillars

| Pillar | Measures | Tools |
|--------|----------|-------|
| **Metrics** | Numbers (rate, errors, duration) | Prometheus, CloudWatch |
| **Logs** | Events (why something happened) | Loki, ELK, CloudWatch Logs |
| **Traces** | Flow (where was the slowdown) | OpenTelemetry, Jaeger |

### Golden Signals (RED)

| Signal | Measures |
|--------|----------|
| **Rate** | Requests per second |
| **Errors** | Failed requests (5xx) |
| **Duration** | Response time (p50, p95, p99) |

### Every Service Must Export

- `http_requests_total` — request count by method, path, status
- `http_request_duration_seconds` — latency histogram
- `app_health_status` — health check (1=healthy)
- `app_info` — version and commit

### Alert Hierarchy

| Severity | Response | Channel |
|----------|----------|---------|
| Critical (P0) | < 15 min | Phone + Slack + PagerDuty |
| High (P1) | < 30 min | Slack + PagerDuty |
| Medium (P2) | < 4 hours | Slack |
| Low (P3) | < 24 hours | Slack (optional) |

---

## 7. Security

### Supply Chain Security

```
Signed commits → Lockfile + SBOM → Reproducible build
    → Signed image → GitOps deploy → Runtime monitoring
```

### Secrets Management

- **Never** in code, config, or CI logs
- Use External Secrets Operator for Kubernetes
- Rotate database credentials automatically
- Scan for secrets on every push (Gitleaks, truffleHog)

### Container Security

- Non-root user
- No `:latest` tag
- No known critical CVEs (scan every build)
- Read-only root filesystem
- Minimal base image (Alpine or distroless)

### Network Security

| Layer | Control |
|-------|---------|
| Edge | WAF, DDoS protection |
| Ingress | TLS 1.2+, HSTS |
| Internal | mTLS (service mesh) |
| Pod | NetworkPolicy — default deny |
| Data | Encrypted at rest + in transit |

---

## 8. Networking & DNS

### VPC Design

```
VPC: 10.0.0.0/16
├── Public subnets (/24 per AZ) — ALB, NAT, bastion
├── Private subnets (/20 per AZ) — application tier
└── Data subnets (/20 per AZ) — databases, caches
```

### DNS Rules

- TTL: 60s during migration, 300s for stable
- Use Route53 Alias records (free, auto-update)
- Enable DNSSEC for production domains
- HSTS: `max-age=63072000; includeSubDomains`

### TLS

- Minimum TLS 1.2 (1.3 preferred)
- ACM / cert-manager for auto-renewal
- OCSP stapling enabled
- Monitor certificate expiry (alert at 30 days)

---

## 9. Database Operations

### Connection Pooling

Always use a connection pooler — PgBouncer (PostgreSQL), ProxySQL (MySQL), or RDS Proxy.

### Zero-Downtime Migrations

```
1. Add column (nullable) — deploy schema
2. Deploy code that reads and writes the new column
3. Backfill existing rows (batch, 1000 at a time)
4. Make column NOT NULL
```

### Performance Monitoring

| Metric | Warning | Critical |
|--------|---------|----------|
| Connections | > 80% of max | > 95% |
| Replication lag | > 10s | > 60s |
| Slow queries | > 10/min | > 50/min |
| Disk | > 75% | > 90% |

---

## 10. Backup, DR & Incident Response

### DR Tiers

| Tier | RPO | RTO | Cost |
|------|-----|-----|------|
| Multi-AZ | < 1s | < 1 min | $$ |
| Warm standby | < 1 min | < 15 min | $$$ |
| Backup & restore | < 1 hour | < 4 hours | $ |

### Incident Severity

| Level | Response | Example |
|-------|----------|---------|
| SEV1 | < 15 min | Critical outage, revenue affected |
| SEV2 | < 30 min | Partial outage, degraded |
| SEV3 | < 4 hours | Minor, no user impact |

### Postmortem Must Include

- Timeline of events
- Root cause
- Impact (users affected, errors served, revenue impact)
- Action items with owners and due dates
- What went well + what went wrong

---

## 11. Cost Optimization

### Resource Rightsizing

| Signal | Action |
|--------|--------|
| CPU < 20% / 7 days | Downsize |
| CPU > 80% / 7 days | Upsize or scale out |
| Memory < 40% / 7 days | Downsize |

### Compute Pricing

| Model | Discount | Use for |
|-------|----------|---------|
| On-Demand | 0% | Short-term, variable |
| Reserved (1yr) | 30-40% | Baseline |
| Reserved (3yr) | 50-60% | Stable workloads |
| Spot | 60-90% | Stateless, batch, CI runners |

### Storage Lifecycle

```
30 days: Standard → Standard-IA
90 days: Standard-IA → Glacier
365 days: Glacier → Deep Archive or expire
```

---

## 12. Release & Change Management

### Deployment Process

```
Feature branch → CI → Code review → Merge to main
    → Deploy staging → Smoke tests → Manual approval
    → Canary (10%) → Monitor → Full rollout
```

### Release Anti-Patterns

- ❌ Deploying on Friday afternoon (no deploys after 2 PM Thursday)
- ❌ Skipping staging for "urgent" fixes
- ❌ No rollback plan
- ❌ Large infrequent releases (prefer small, daily)
- ❌ Manual deployment steps (automate everything)

### Versioning (Semver)

| Change | Example |
|--------|---------|
| Breaking | v2.0.0 |
| New feature (backward-compatible) | v2.3.0 |
| Bug fix | v2.3.1 |

---

## 13. Automation & Scripting

### Shell Script Standards

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### Every Script Should Be

- **Idempotent** — running twice produces the same result
- **Validated** — check arguments at the start
- **Logged** — structured output for debugging
- **Cleaned up** — `trap cleanup EXIT`
- **Timed out** — never hang indefinitely

### Retry with Backoff

```bash
retry() {
    local n=1 max=5 delay=1
    while true; do
        if "$@"; then break
        elif [[ $n -lt $max ]]; then
            sleep "$delay"
            n=$((n+1)); delay=$((delay * 2))
        else
            echo "Failed after $n attempts"
            return 1
        fi
    done
}
```

---

## AI Rule Files

These rules are stored in `.brain/devops/rules/` and loaded automatically by the AI per task:

| Rule file | Loaded when |
|-----------|-------------|
| `CONTAINERS.md` | Building Dockerfiles, container security, image optimization |
| `KUBERNETES.md` | K8s manifests, deployments, network policies, HPA |
| `CI_CD.md` | Setting up or modifying CI/CD pipelines |
| `INFRASTRUCTURE_AS_CODE.md` | Terraform modules, state management, IaC security |
| `CLOUD_SERVICES.md` | Cloud architecture, VPC, IAM, storage, databases |
| `MONITORING_OBSERVABILITY.md` | Metrics, logs, traces, alerting, dashboards |
| `DEVOPS_SECURITY.md` | Supply chain security, secrets, compliance scanning |
| `NETWORKING_DNS.md` | VPC design, DNS, TLS, load balancers, WAF |
| `DATABASE_OPS.md` | DB provisioning, migration, connection pooling, backup |
| `BACKUP_DR_INCIDENT.md` | DR planning, incident response, postmortems |
| `COST_OPTIMIZATION.md` | Right-sizing, pricing models, budget alerts |
| `RELEASE_MANAGEMENT.md` | Deploy process, rollback, feature flags, change management |
| `AUTOMATION_SCRIPTING.md` | Shell scripts, CI scripts, Makefiles |

---

*Last updated: 2026-07-23*
