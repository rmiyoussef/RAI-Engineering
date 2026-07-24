# Cloud Service Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent, SECURITY agent
> **Domain:** DevOps — cloud architecture (AWS, GCP, Azure)
> **Purpose:** Cost-effective, secure, resilient cloud infrastructure.

---

## R1 — Multi-AZ Architecture

| Component | Minimum AZs | Why |
|-----------|-------------|-----|
| Compute (ECS/EKS/VM) | 3 | Survive single AZ failure |
| Database (RDS, Aurora) | 3 (multi-AZ) | Automatic failover |
| Cache (ElastiCache, Memorystore) | 2 (replica) | HA caching layer |
| Load balancer | 2+ | Cross-AZ traffic distribution |
| Message queue (SQS, Pub/Sub) | Regional | Managed HA by provider |

```
Region: us-east-1
├── AZ a ── app instance, DB replica, cache node
├── AZ b ── app instance, DB primary, cache node
└── AZ c ── app instance, DB replica, cache replica
```

## R2 — Networking Rules

| Resource | Setting | Reason |
|----------|---------|--------|
| VPC | /16 (65536 IPs) | Room for growth |
| Public subnets | /24 per AZ | Load balancers, NAT gateways |
| Private subnets | /20 per AZ | App and DB workloads |
| NAT Gateway | 1 per AZ | HA outbound connectivity |
| VPC Peering / Transit Gateway | Centralized connectivity | Avoid mesh complexity |

```hcl
# ✅ Network ACL: deny known bad traffic at subnet level
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  ingress {
    rule_no = 100
    protocol = "tcp"
    from_port = 0
    to_port = 65535
    action = "allow"
    cidr_block = aws_vpc.main.cidr_block
  }

  egress {
    rule_no = 100
    protocol = "-1"
    from_port = 0
    to_port = 0
    action = "allow"
    cidr_block = "0.0.0.0/0"
  }
}
```

## R3 — Database Rules

| Requirement | Setting |
|-------------|---------|
| Automated backups | Daily with 30-day retention |
| Point-in-time recovery | Enabled (7-35 day window) |
| Encryption at rest | KMS/CMK (not AWS managed) |
| Encryption in transit | TLS 1.2+ enforced |
| Maintenance window | Off-peak hours, predictable schedule |
| Deletion protection | Enabled for production |
| Parameter groups | Custom (not default) — tuned for workload |

```hcl
# ✅ Production database baseline
resource "aws_rds_cluster" "production" {
  engine            = "aurora-postgresql"
  engine_mode       = "provisioned"
  engine_version    = "16.3"
  cluster_identifier = "production-aurora"

  backup_retention_period   = 30
  preferred_backup_window   = "03:00-04:00"
  preferred_maintenance_window = "sun:05:00-sun:06:00"
  deletion_protection       = true
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.rds.arn

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 8
  }
}
```

## R4 — Storage Rules

| Service | Encryption | Backup | Lifecycle |
|---------|------------|--------|-----------|
| S3 / GCS / Blob | SSE-S3 or KMS | Versioning + Cross-region replication | Intelligent tiering or lifecycle rules |
| EBS / PD / Disks | KMS encryption by default | Snapshots (daily, 7-day retention) | Delete unassociated volumes |
| EFS / Filestore | KMS encryption | Backup service | — |

```hcl
# ✅ S3 lifecycle policy
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
```

## R5 — IAM & Access Control

| Principle | Implementation |
|-----------|---------------|
| Least privilege | Grant only the permissions needed for the role |
| No human users in cloud console | Federate via SSO/SAML/OIDC |
| Roles for services, users for emergencies | EC2 → Instance Profile, Lambda → Execution Role |
| Separate roles per service | API service can't touch database resources |
| Access keys rotated every 90 days | Automate via Secrets Manager rotation |
| No root account usage | Enable MFA, store credentials securely |

```hcl
# ✅ Service role with minimal permissions
resource "aws_iam_role" "app_service" {
  name = "app-service-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_policy" "app_policy" {
  name = "app-service-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = "${aws_s3_bucket.app_data.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = aws_sqs_queue.app_queue.arn
      }
    ]
  })
}
```

## R6 — Load Balancing & DNS

```yaml
# ✅ ALB routing rules
- Path-based routing:
    /api/*      → backend service (target group)
    /*           → frontend service (target group)
- Host-based routing:
    api.example.com   → backend service
    app.example.com   → frontend service
- SSL termination at ALB (not at app)
- HTTP → HTTPS redirect at ALB listener level
```

| LB type | When | Stickiness | WAF |
|---------|------|------------|-----|
| ALB | HTTP/HTTPS traffic | Cookie-based (if needed) | Yes |
| NLB | TCP/UDP, ultra-low latency | Source IP | No |
| GLB | Gateway Load Balancer (security appliances) | — | — |

## R7 — Monitoring and Alarming

| Metric | Threshold | Action |
|--------|-----------|--------|
| CPU > 80% | 5 min | Scale up or investigate |
| Memory > 80% | 5 min | Scale up or investigate |
| 5xx errors > 1% | 5 min | PagerDuty alert |
| Latency (p99) > 2s | 5 min | PagerDuty alert |
| Disk space > 80% | 10 min | Auto-cleanup or alert |
| Database connections > 80% | 5 min | Scale connections or alert |
| Cost anomaly > 20% weekly | Daily | Investigate budget alert |
| Backup failure | Immediate | PagerDuty alert |

## R8 — Cost Optimization

| Strategy | Savings | Implementation |
|----------|---------|----------------|
| Reserved Instances / Savings Plans | 30-60% | 1-3 year commitment for baseline |
| Spot instances | 60-90% | Stateless, fault-tolerant workloads |
| Auto-scaling | Variable | Match capacity to demand |
| Delete unused resources | Variable | EBS snapshots, old load balancers, untagged resources |
| Right-sizing | 10-30% | Match instance type to actual utilization |
| Data lifecycle policies | Variable | S3 Intelligent-Tiering, Glacier for archives |

## R9 — Backup and Disaster Recovery

| RPO | RTO | Strategy | Cost |
|-----|-----|----------|------|
| 1 hour | 15 min | Multi-AZ active-active | $$$ |
| 1 hour | 4 hours | Active-standby in second region | $$ |
| 24 hours | 8 hours | Backup and restore in second region | $ |

```hcl
# ✅ Cross-region backup (S3 replication)
resource "aws_s3_bucket_replication_configuration" "backup" {
  bucket = aws_s3_bucket.primary.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "cross-region-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.dr.arn
      storage_class = "STANDARD_IA"
    }
  }
}
```

## R10 — Security Group Rules of Thumb

| Rule | Detail |
|------|--------|
| Default deny all inbound | Explicitly allow only needed traffic |
| Always specific source | `0.0.0.0/0` only for public ALB on ports 80/443 |
| Never use `0.0.0.0/0` for SSH/RDP | Use VPN, Bastion, or SSM Session Manager |
| Egress defaults to all | Restrict only if compliance requires it |
| Use security group IDs, not CIDRs | SG: `sg-xxxx` auto-updates when group changes |
| Document each rule with description | `description = "HTTP from ALB in vpc-xxx"` |
