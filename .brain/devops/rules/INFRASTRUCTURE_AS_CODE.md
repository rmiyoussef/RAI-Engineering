# Infrastructure as Code (Terraform) Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent, SECURITY agent
> **Domain:** DevOps — IaC with Terraform / OpenTofu
> **Purpose:** Reproducible, reviewable, versioned infrastructure.

---

## R1 — State Management

```hcl
# ✅ Remote state with locking
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "production/network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

| State rule | Why |
|------------|-----|
| Never commit `terraform.tfstate` | Contains secrets, resource IDs, sensitive values |
| Use remote state with locking | Prevents concurrent operations corruption |
| Encrypt state at rest (S3 SSE, GCS encryption) | Protect sensitive infrastructure details |
| Separate state per environment | Isolate production from staging changes |
| State bucket has versioning enabled | Recover from accidental state deletion/corruption |

## R2 — Module Structure

```
terraform/
├── environments/
│   ├── production/
│   │   ├── main.tf          ← resources
│   │   ├── variables.tf     ← input variables
│   │   ├── outputs.tf       ← output values
│   │   └── terraform.tfvars ← environment-specific values (gitignored)
│   └── staging/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── versions.tf             ← provider versions pinned
```

## R3 — Module Rules

| Rule | Why |
|------|-----|
| Pin provider versions in every module | `required_version = "~> 1.6"` prevents accidental upgrades |
| Modules are reusable and composable | Each module does one thing (network, compute, database) |
| Modules don't hardcode environment-specific values | Accept `environment` variable, apply via `terraform.tfvars` |
| Every module has `variables.tf` and `outputs.tf` | Clear contract, documented interface |
| Never use `count` for conditional resources | Use `for_each` with `toset()` for deterministic ordering |

```hcl
# ✅ Module composition
module "networking" {
  source      = "../modules/networking"
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "compute" {
  source          = "../modules/compute"
  environment     = var.environment
  subnet_ids      = module.networking.private_subnet_ids
  instance_type   = var.instance_type
  instance_count  = var.instance_count
}
```

## R4 — Security in IaC

| Rule | Tool check |
|------|------------|
| No hardcoded secrets | `checkov` / `tfsec` — fail CI if detected |
| S3 buckets not publicly accessible | `checkov` rule CKV_AWS_53 |
| Security groups restrict ingress | `tfsec` — limit 0.0.0.0/0 to specific ports |
| Encryption enabled everywhere | KMS for EBS/RDS/S3, TLS for load balancers |
| IAM least privilege | No `"*:*"` policies for service roles |

```hcl
# ✅ Security group baseline
resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Application security group"
  vpc_id      = module.networking.vpc_id

  ingress {
    description = "HTTP from ALB"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [module.networking.alb_sg_id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-app-sg", Environment = var.environment }
}
```

## R5 — CI for IaC

```yaml
# ✅ Terraform CI pipeline
jobs:
  terraform:
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.0

      - name: Format check
        run: terraform fmt -check -recursive

      - name: Validate
        run: terraform validate

      - name: Security scan
        uses: bridgecrewio/checkov-action@master
        with:
          directory: terraform/
          framework: terraform
          soft_fail: false

      - name: Plan
        run: terraform plan -no-color

      - name: Apply (main branch only)
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

## R6 — Workspace and Environment Strategy

| Approach | When to use |
|----------|-------------|
| **Separate directories** (recommended) | Different state backends, different root modules |
| **Workspaces** | Environment-specific variables with same root module |
| **Terragrunt** | Multiple projects, DRY configurations, complex dependencies |

## R7 — Importing Existing Resources

```hcl
# ✅ Import existing resource before managing it
# 1. Write resource block in config
resource "aws_s3_bucket" "legacy" {
  bucket = "existing-bucket-name"
}

# 2. Import: terraform import aws_s3_bucket.legacy existing-bucket-name
# 3. Plan: terraform plan — verify only desired changes
# 4. Apply only after reviewing diff carefully
```

## R8 — Resource Naming Convention

```hcl
# ✅ Pattern: {environment}-{module}-{resource-type}
resource "aws_s3_bucket" "this" {
  bucket = "${var.environment}-app-logs"
  # production-app-logs, staging-app-logs
}

# Tags on every resource
tags = {
  Name        = "${var.environment}-app-sg"
  Environment = var.environment
  ManagedBy   = "terraform"
  Project     = var.project_name
}
```

## R9 — Anti-Patterns

| Anti-pattern | Fix |
|-------------|-----|
| State in Git | Remote state with locking |
| Hardcoded secrets in `.tfvars` | Use vault, SSM Parameter Store, or Secrets Manager |
| `latest` provider version | Pin to major.minor |
| Manual changes outside Terraform | Always codify. Use drift detection |
| Monolithic state file | Separate state per service or environment |
| Large un-reviewed plans | Use `terraform plan` output in PR comments |
| Using `terraform apply` without plan review | Always review `plan` output first |
