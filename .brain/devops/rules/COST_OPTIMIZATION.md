# Cost Optimization Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** DevOps — cloud cost management
> **Purpose:** Maximize value per dollar spent on cloud infrastructure.

---

## R1 — Right-Sizing Strategy

| Signal | Action |
|--------|--------|
| CPU < 20% for 7 days | Downsize instance type |
| CPU > 80% for 7 days | Upsize or scale out |
| Memory < 40% for 7 days | Downsize or switch to burstable |
| Network < 10% of instance limit | Downsize |
| Burstable (T-family) credits at 0 | Switch to standard instance |

```bash
# ✅ Identify under-utilized resources
# Use AWS Compute Optimizer, GCP Rightsizing Recommendations, Azure Advisor
# or custom Prometheus queries:
avg by (instance_id) (rate(node_cpu_seconds_total[5m])) < 0.2
```

## R2 — Compute Pricing Models

| Model | Discount | When to use |
|-------|----------|-------------|
| **On-Demand** | 0% | Short-term, variable, unknown patterns |
| **Reserved Instances** (1yr) | 30-40% | Steady-state baseline (3-6 month commitment) |
| **Reserved Instances** (3yr) | 50-60% | Stable workloads (12+ month commitment) |
| **Savings Plans** | 30-60% | Flexible across instance families (compute spend commitment) |
| **Spot Instances** | 60-90% | Stateless, fault-tolerant, batch, CI/CD runners |
| **Preemptible VMs** (GCP) | 60-91% | Batch, non-critical, can handle preemption |

### Recommended Mix

| Workload type | On-Demand | Reserved | Spot |
|---------------|-----------|----------|------|
| Production baseline | 0% | 80% | 20% |
| Auto-scaled web tier | 20% | 50% | 30% |
| Batch processing | 0% | 0% | 100% |
| Development/Staging | 10% | 0% | 90% |

## R3 — Storage Cost Rules

| Data type | Hot (frequent access) | Warm (monthly) | Cold (quarterly) | Archive (yearly+) |
|-----------|----------------------|----------------|------------------|-------------------|
| App data | SSD (gp3) | — | — | — |
| Logs | — | S3 Standard-IA | S3 Glacier | S3 Glacier Deep Archive |
| Backups | — | — | S3 Glacier | S3 Glacier Deep Archive |
| Images | S3 Standard | S3 Standard-IA | — | — |
| Old versions | — | — | S3 Glacier | Glacier Deep Archive |

```hcl
# ✅ Lifecycle policy for automatic cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "optimize" {
  bucket = aws_s3_bucket.data.id

  rule {
    id     = "tier-to-ia"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
  rule {
    id     = "tier-to-glacier"
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
  rule {
    id     = "expire-old"
    status = "Enabled"
    expiration { days = 365 }
  }
}
```

## R4 — Data Transfer Costs

| Direction | Cost | Optimization |
|-----------|------|-------------|
| Internet → Cloud (ingress) | Free | — |
| Cloud → Internet (egress) | $$ | Use CDN (CloudFront, Cloudflare) for static assets |
| Same AZ (intra-region) | Free | Co-locate services that communicate heavily |
| Cross-AZ | $ | Minimize cross-AZ traffic (co-locate in same AZ when possible) |
| Cross-region | $$$ | Use VPC Peering or Transit Gateway. Cache at edge. |

### Network Cost Rules

- Place services that communicate heavily in the same AZ
- Use CloudFront / CDN for all static and image assets
- Use PrivateLink / VPC Endpoints instead of NAT + Internet Gateway
- Compress data before transfer (Brotli, gzip)
- Deduplicate API responses with caching

## R5 — Kubernetes Cost Optimization

```yaml
# ✅ Cluster rightsizing
# Node pool 1: On-Demand (3x r6a.xlarge) — baseline
# Node pool 2: Spot (5x r6a.xlarge) — burstable workloads

# ✅ Pod resource efficiency
resources:
  requests:
    memory: "256Mi"     # Set based on actual usage, not guesses
    cpu: "250m"
  limits:
    memory: "512Mi"     # No CPU limits (allows bursting, reduces throttling)
    # cpu: no limit set — avoids CPU throttling issues
```

| Technique | Savings | Effort |
|-----------|---------|--------|
| Cluster autoscaler | 30-50% | Low |
| Spot instances for stateless | 60-90% | Low |
| Vertical Pod Autoscaler | 20-40% | Medium |
| Horizontal Pod Autoscaler | 20-40% | Low |
| Remove unused resources | 5-15% | Medium |
| Rightsize resource requests | 10-30% | Medium |

## R6 — Unused Resource Detection

```bash
# Resources to check weekly
- Unattached EBS volumes
- Idle load balancers (no traffic for 7 days)
- Unassociated Elastic IPs
- Orphaned snapshots (older than AMI)
- Untagged resources
- Stale CloudWatch log groups
- Unused reserved instances
- Idle RDS instances
```

## R7 — Budget and Alerting

```yaml
# ✅ Budget structure
Monthly cloud budget: $50,000
├── Production: $40,000
├── Staging: $5,000
├── Development: $3,000
└── Shared services: $2,000

Alert thresholds:
  - 50% of budget → Slack notification (team)
  - 80% of budget → Slack alert (engineering manager)
  - 100% of budget → PagerDuty + email (CTO)
  - 120% of budget → Auto-pause non-production resources
```

## R8 — Tagging Strategy

| Tag | Values | Purpose |
|-----|--------|---------|
| `Environment` | production, staging, dev, test | Cost allocation |
| `Service` | api, web, worker, database | Per-service cost tracking |
| `Team` | backend, frontend, data, infra | Team-level chargeback |
| `Project` | project-name | Project-based tracking |
| `CostCenter` | cost-center-id | Accounting integration |
| `AutoShutdown` | true/false | Schedule off-hours shutdown |

```hcl
# ✅ Tag enforcement via Terraform
resource "aws_organizations_policy" "tag_policy" {
  name = "required-tags"
  content = jsonencode({
    tags = {
      Environment = { tag_key = "Environment" }
      Service     = { tag_key = "Service" }
      Team        = { tag_key = "Team" }
    }
  })
}
```

## R9 — Free Tier Abuse Prevention

| Risk | Prevention |
|------|-----------|
| Accidental large instance launch | Use Service Control Policies (SCPs) to limit instance size |
| Unused storage accumulates | Automated cleanup of unattached volumes and old snapshots |
| Data transfer egress spikes | Set CloudWatch billing alarms for > $X in 24 hours |
| Development resources left on | Auto-stop non-production resources during off-hours |
| Multiple environments running 24/7 | Schedule stop/start for dev/staging |
