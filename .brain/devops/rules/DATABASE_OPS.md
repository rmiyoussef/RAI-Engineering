# Database Administration Rules

> **Loaded by:** EXECUTOR agent, DATABASE agent, REVIEWER agent
> **Domain:** DevOps — database operations
> **Purpose:** Reliable, performant, secured database infrastructure.

---

## R1 — Database Selection

| Type | When | Cloud options |
|------|------|---------------|
| **PostgreSQL** | General purpose, complex queries, JSON, geo | RDS, Aurora, Cloud SQL, AlloyDB |
| **MySQL** | Simpler workloads, read-heavy | RDS, Cloud SQL |
| **Redis** | Caching, sessions, pub/sub | ElastiCache, Memorystore |
| **DynamoDB / Bigtable** | High-scale key-value, low-latency at any scale | Managed NoSQL |
| **MongoDB / Firestore** | Document store, flexible schema | Atlas, DocumentDB, Firestore |
| **Elasticsearch** | Full-text search, log analytics | OpenSearch, Elastic Cloud |

## R2 — Provisioning Rules

```hcl
# ✅ Production database baseline
resource "aws_rds_cluster" "production" {
  engine            = "aurora-postgresql"
  engine_version    = "16.3"
  instance_class    = "db.serverless"  # or db.r6g.large (fixed)

  # Availability
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  multi_az          = true

  # Backups
  backup_retention_period   = 30
  preferred_backup_window   = "03:00-04:00"
  copy_tags_to_snapshot     = true

  # Security
  storage_encrypted   = true
  kms_key_id          = aws_kms_key.rds.arn
  deletion_protection = true

  # Maintenance
  preferred_maintenance_window = "sun:05:00-sun:06:00"
  auto_minor_version_upgrade  = true
}
```

## R3 — Connection Pooling

| Tool | Purpose | Sidecar or sidecar? |
|------|---------|---------------------|
| PgBouncer / Pgpool | PostgreSQL connection pooling | Sidecar in K8s |
| ProxySQL | MySQL connection pooling | Sidecar |
| RDS Proxy | AWS-managed connection pool | Managed (no sidecar) |
| Cloud SQL Connector | GCP IAM-auth proxy | Sidecar |

```yaml
# ✅ PgBouncer sidecar in Kubernetes
containers:
  - name: app
    env:
      - name: DATABASE_URL
        value: postgres://app:pass@localhost:5432/app
  - name: pgbouncer
    image: edoburu/pgbouncer:1.23
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: db-secret
            key: url
      - name: MAX_CLIENT_CONN
        value: "200"
      - name: DEFAULT_POOL_SIZE
        value: "25"
```

## R4 — Migration Rules

| Rule | Detail |
|------|--------|
| Forward-only migrations | Never edit a committed migration. Create a new one to reverse changes |
| Zero-downtime migrations | Add columns (nullable), then backfill, then make NOT NULL |
| Deploy code before schema changes | Code reads old + new fields safely |
| Large tables: use `pt-online-schema-change` | Avoid table locks on tables > 10M rows |

```sql
-- ✅ Zero-downtime column addition
-- Step 1: Add column (nullable)
ALTER TABLE users ADD COLUMN email_verified BOOLEAN;
-- Step 2: Deploy code that reads AND writes email_verified
-- Step 3: Backfill existing rows (batch, 1000 at a time)
UPDATE users SET email_verified = FALSE WHERE email_verified IS NULL;
-- Step 4: Make NOT NULL
ALTER TABLE users ALTER COLUMN email_verified SET NOT NULL;
```

## R5 — Backup and Recovery

| Database | Backup tool | Recovery test |
|----------|------------|---------------|
| PostgreSQL | `pg_dump` + WAL archiving, or snapshot | Monthly |
| MySQL | `mysqldump` + binary logs, or snapshot | Monthly |
| Redis | RDB snapshots + AOF | Monthly |
| DynamoDB | On-demand backup (PITR) | Quarterly |

### RPO and RTO Targets

| Tier | RPO | RTO | Strategy |
|------|-----|-----|----------|
| Platinum | 5 min | 15 min | Multi-AZ + PITR + Read replica promotion |
| Gold | 1 hour | 1 hour | Daily snapshots + WAL archiving |
| Silver | 24 hours | 4 hours | Daily snapshots |

## R6 — Performance Monitoring

```sql
-- Slow query detection (PostgreSQL)
SELECT query, calls, total_exec_time / calls AS avg_time_ms,
       rows, shared_blks_hit, shared_blks_read
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- Missing indexes
SELECT schemaname, tablename, seq_scan, seq_tup_read,
       idx_scan, idx_tup_fetch
FROM pg_stat_user_tables
WHERE seq_scan > 1000 AND idx_scan = 0;
```

| Metric | Warning | Critical |
|--------|---------|----------|
| Connections | > 80% of max | > 95% of max |
| Replication lag | > 10s | > 60s |
| Slow queries (>1s) | > 10/min | > 50/min |
| Disk space | > 75% | > 90% |
| Deadlocks | Any | Escalate |

## R7 — Scaling Strategy

| Strategy | When | How |
|----------|------|-----|
| **Vertical** (scale up) | Single-instance limits | Larger instance class |
| **Read replicas** | Read-heavy workloads | Add up to 5 read replicas |
| **Sharding** | Write throughput limits | Application-layer sharding |
| **Caching** | Hot data, repeated queries | Redis / Memcached in front |
| **Archival** | Old data not frequently accessed | Partition and move to cold storage |

## R8 — Database User Management

```sql
-- ✅ Least privilege per service
CREATE USER app_service WITH PASSWORD '...';
GRANT CONNECT ON DATABASE app_db TO app_service;
GRANT USAGE ON SCHEMA public TO app_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_service;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_service;

-- ✅ Read-only user for analytics
CREATE USER read_only WITH PASSWORD '...';
GRANT CONNECT ON DATABASE app_db TO read_only;
GRANT USAGE ON SCHEMA public TO read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

-- ✅ Migration user (DDL access)
CREATE USER migrator WITH PASSWORD '...';
GRANT ALL PRIVILEGES ON DATABASE app_db TO migrator;
```

## R9 — SSL/TLS for Database Connections

```yaml
# ✅ Enforce TLS for all database connections
- PostgreSQL: sslmode=require or sslmode=verify-full
- MySQL: ssl-mode=VERIFY_IDENTITY
- Redis: redis-cli --tls
```

## R10 — Database Anti-Patterns

| Anti-pattern | Fix |
|-------------|-----|
| SELECT * in production | Specify columns explicitly |
| No connection pooling | Use PgBouncer, ProxySQL, sidecar |
| Sequential scans on large tables | Add appropriate indexes |
| Missing foreign keys | Enforce referential integrity at DB level |
| Storing JSON instead of columns | Normalize or use JSONB with GIN index |
| Manual failover testing | Automate failover tests quarterly |
| Backups on same storage as DB | Store backups in different bucket/region |
| Shared database across services | Each service gets its own database/schema |
