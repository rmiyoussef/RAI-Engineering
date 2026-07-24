# Backup, Disaster Recovery & Incident Response Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent, SECURITY agent
> **Domain:** DevOps — business continuity
> **Purpose:** Survive anything — from accidental delete to region outage.

---

## R1 — Backup Classification

| Tier | RPO | RTO | Examples |
|------|-----|-----|----------|
| **Critical** | ≤ 15 min | ≤ 1 hour | User data, orders, payment records |
| **Important** | ≤ 1 hour | ≤ 4 hours | Audit logs, configurations, reports |
| **Normal** | ≤ 24 hours | ≤ 24 hours | Build artifacts, old logs, cached data |
| **Archive** | ≤ 7 days | ≤ 7 days | Deleted data retention, compliance archives |

## R2 — Backup Strategy Matrix

| Resource | Method | Frequency | Retention | Location |
|----------|--------|-----------|-----------|----------|
| **Database** | Snapshots + WAL/PITR | Daily snapshot + continuous WAL | 30 days + yearly | Cross-region |
| **Object storage (S3)** | Cross-region replication | Continuous | 90 days + Glacier | Secondary region |
| **State files (Terraform)** | Versioned state backend | Every plan/apply | 1 year | Same region, versioned |
| **Kubernetes manifests** | Git (source of truth) | Every commit | Forever | Git remote |
| **Secrets** | Vault snapshots + backup | Daily | 1 year | Separate region |
| **Container images** | Registry replication | Every build | 90 days | Secondary registry |

## R3 — Disaster Recovery Tiers

```yaml
# Tier 1 — Multi-AZ (AZ failure)
RPO: < 1s (synchronous replication)
RTO: < 1 min (auto-failover)
Cost: $$
Architecture: Active-active across 3 AZs

# Tier 2 — Warm Standby (Region failure)
RPO: < 1 min (asynchronous replication)
RTO: < 15 min (DNS switch + DB promote)
Cost: $$$
Architecture: Active in primary, scaled-down standby in secondary

# Tier 3 — Backup & Restore (Catastrophic failure)
RPO: < 1 hour (last backup)
RTO: < 4 hours (full infrastructure rebuild)
Cost: $
Architecture: IaC + automated provisioning in new region
```

## R4 — Disaster Recovery Plan Template

```markdown
## DR Plan: [Service Name]

### Assumptions
- Primary region: us-east-1
- DR region: us-west-2
- RPO: 15 min, RTO: 1 hour

### Trigger Conditions
- [ ] ALB health checks failing in all AZs
- [ ] RDS primary unreachable for 5 min
- [ ] 500 errors > 10% for 10 min

### Steps
1. Promote read replica to primary in DR region
2. Update DNS (Route53 failover record)
3. Verify ALB health in DR region
4. Scale up DR compute to match production
5. Verify all services operational
6. Declare incident resolved

### Rollback
1. Switch DNS back to primary (if recovered)
2. Replicate DR data back to primary
3. Verify primary health
```

## R5 — Incident Severity Levels

| Level | Description | Response | Reporting |
|-------|-------------|----------|-----------|
| **SEV1** | Critical outage, users impacted, revenue affected | < 15 min | Phone + PagerDuty + Slack |
| **SEV2** | Partial outage, degraded experience | < 30 min | PagerDuty + Slack |
| **SEV3** | Minor issue, no user impact | < 4 hours | Slack |
| **SEV4** | Cosmetic, non-critical | < 1 week | Ticket |

### Incident Command Structure

```
Incident Commander (IC)     ← One person coordinating
├── Communication Lead      ← Status updates, stakeholder comms
├── Technical Lead          ← Root cause investigation
├── Operations Lead         ← Mitigation and recovery
└── Scribe                 ← Timeline and documentation
```

## R6 — Postmortem Template

```markdown
## Postmortem: [Title]

### Summary
- Date: YYYY-MM-DD
- Duration: X hours Y minutes
- Severity: SEV1/SEV2/SEV3
- Services affected: [list]

### Timeline
| Time (UTC) | Event |
|------------|-------|
| 10:00 | Alert fired: error rate > 5% |
| 10:02 | On-call acknowledged |
| 10:05 | Declared SEV1 |
| 10:10 | Rolled back deployment |
| 10:25 | Service recovered |
| 11:00 | All clear declared |

### Root Cause
Brief technical explanation.

### Impact
- X users affected
- Y errors served
- $Z revenue impact

### Action Items
| Action | Owner | Due date |
|--------|-------|----------|
| Add monitoring for X metric | @team | YYYY-MM-DD |
| Fix Y root cause | @team | YYYY-MM-DD |
| Update runbook for Z | @team | YYYY-MM-DD |

### What went well
- [ ] Fast detection via monitoring
- [ ] Quick rollback
- [ ] Good communication

### What went wrong
- [ ] Missing monitoring on X metric
- [ ] No runbook for this scenario
- [ ] Incomplete rollback plan
```

## R7 — Runbook Requirements

Every critical service must have a runbook containing:

| Section | Content |
|---------|---------|
| **Overview** | Service purpose, dependencies, criticality |
| **Health check** | How to check if service is healthy |
| **Common issues** | Top 5 failure modes and their fixes |
| **Restart procedure** | Safe restart steps for each component |
| **Rollback procedure** | How to roll back a bad deployment |
| **Scale procedure** | How to scale up/down manually |
| **DR steps** | Failover, recovery, restoration |
| **Contacts** | Team, on-call, escalation paths |

## R8 — Testing the DR Plan

| Test type | Frequency | What to verify |
|-----------|-----------|----------------|
| **Tabletop exercise** | Quarterly | Team knows the plan, no gaps |
| **Failover test (read-only)** | Quarterly | Read replicas can be promoted |
| **Full DR drill** | Bi-annual | Complete region failover and recovery |
| **Restore test** | Monthly | Can restore a database from backup |
| **Chaos engineering** | Per feature | Survival of random failures (Chaos Monkey) |

## R9 — DR Anti-Patterns

| Anti-pattern | Fix |
|-------------|-----|
| DR plan exists but never tested | Schedule quarterly tabletop + bi-annual full drill |
| Backups stored in same region as production | Cross-region backup replication |
| Runbook is outdated | Auto-generate from IaC, review quarterly |
| Only one person knows the DR procedure | Document + rotate incident commander role |
| DR environment not representative | Use IaC — DR environment is identical to prod |
| No cost budgeted for DR | Budget for DR infrastructure + testing personnel |
