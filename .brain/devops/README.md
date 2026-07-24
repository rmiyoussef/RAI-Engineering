# DevOps / System Management Domain

> Domain-isolated knowledge base for DevOps and system management projects.
> Plans, rules, skills, and memory live directly in `.brain/devops/` — no nesting.
> Rules: 13 (containers, K8s, CI/CD, Terraform, cloud, monitoring, security, networking, DB ops, DR, cost, release, automation)
> Skills: 1 (CI/CD automation)

## Structure

```
devops/
├── plans/       ← Project plans (coming soon)
├── rules/       ← 13 engineering rules (containers → automation)
├── skills/      ← Code templates & patterns (CI/CD automation)
├── reference/   ← External docs (coming soon)
├── DEVOPS_BEST_PRACTICES.md ← Team-readable guide
└── memory/      ← Project knowledge (coming soon)
```

## Current Contents

- `skills/ci-cd-and-automation.md` — CI/CD pipeline setup and automation patterns

### Rules (13 files — loaded automatically per task)

| Rule file | Loaded when | Key topics |
|-----------|-------------|------------|
| `CONTAINERS.md` | Building or reviewing containers | Multi-stage builds, layer ordering, image scanning, resource limits |
| `KUBERNETES.md` | K8s manifests, deployments | Pod spec, probes, network policies, HPA, PDB, cluster security |
| `CI_CD.md` | Setting up or modifying pipelines | Pipeline perf, caching, secrets, branch protection, reusable workflows |
| `INFRASTRUCTURE_AS_CODE.md` | Terraform modules, IaC | State management, module structure, CI for IaC, resource naming |
| `CLOUD_SERVICES.md` | Cloud architecture | Multi-AZ, VPC, IAM, storage lifecycles, cost optimization, DR |
| `MONITORING_OBSERVABILITY.md` | Metrics, logs, traces | USE/RED methods, structured logging, alerting, SLO/SLI |
| `DEVOPS_SECURITY.md` | Pipeline and infra security | Supply chain, secrets management, runtime security, compliance scanning |
| `NETWORKING_DNS.md` | Network infrastructure | VPC design, DNS, TLS, load balancers, CDN, WAF |
| `DATABASE_OPS.md` | Database operations | Provisioning, connection pooling, zero-downtime migrations, backup |
| `BACKUP_DR_INCIDENT.md` | Business continuity | DR tiers, incident severity, postmortem template, runbook requirements |
| `COST_OPTIMIZATION.md` | Cloud cost management | Right-sizing, pricing models, storage lifecycle, tagging, budget alerts |
| `RELEASE_MANAGEMENT.md` | Software delivery | Deploy process, rollback, feature flags, zero-downtime, semver |
| `AUTOMATION_SCRIPTING.md` | Scripts and automation | Shell script standards, idempotency, CI scripts, Makefiles |

## Isolation Rule

DevOps plans, rules, skills, and memory must never be stored in or read from another domain's subtree. Each domain is self-contained.
