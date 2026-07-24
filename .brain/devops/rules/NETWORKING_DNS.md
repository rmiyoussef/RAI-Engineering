# Networking & DNS Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** DevOps — Network infrastructure
> **Purpose:** Reliable, secure, performant network architecture.

---

## R1 — VPC / Network Design

| Scale | CIDR | Subnets | NAT strategy |
|-------|------|---------|-------------|
| Small (1-5 services) | /16 | /24 public, /20 private | 1 NAT Gateway in AZ a |
| Medium (5-20 services) | /16 | /24 public, /18 private | 1 NAT GW per AZ |
| Large (20+ services) | /16 | /24 public, /17 private | 1 NAT GW per AZ |

### Subnet Distribution

```
VPC: 10.0.0.0/16
├── Public subnets (for ALB, NAT, bastion)
│   ├── 10.0.0.0/24  (us-east-1a)
│   ├── 10.0.1.0/24  (us-east-1b)
│   └── 10.0.2.0/24  (us-east-1c)
├── Private subnets (for app tier)
│   ├── 10.0.16.0/20 (us-east-1a)
│   ├── 10.0.32.0/20 (us-east-1b)
│   └── 10.0.48.0/20 (us-east-1c)
└── Data subnets (for databases, caches)
    ├── 10.0.64.0/20 (us-east-1a)
    ├── 10.0.80.0/20 (us-east-1b)
    └── 10.0.96.0/20 (us-east-1c)
```

## R2 — DNS Strategy

| Record type | When | TTL |
|-------------|------|-----|
| A / AAAA | ALB, NLB, CloudFront | 60s for active changes, 300s for stable |
| CNAME | Aliasing services | 300s |
| Alias (Route53) | ALB, CloudFront, S3 (free) | Auto — use instead of A record |
| TXT | Domain verification, SPF, DKIM, DMARC | 3600s |
| MX | Email services | 3600s |

### DNS Hygiene

- TTL of 60 seconds during migrations, 300s otherwise
- Use Alias records (Route53) instead of A records where possible (free, auto-updates)
- Set up health checks for failover routing
- Monitor DNS query volume for anomalies
- Enable DNSSEC for production domains
- Use CNAME flattening (ALIAS/ANAME) for apex domains

## R3 — TLS / SSL

| Requirement | Setting |
|-------------|---------|
| Minimum TLS version | 1.2 (1.3 preferred) |
| Certificate management | ACM (AWS), cert-manager (K8s), Let's Encrypt |
| Certificate renewal | Automatic (ACM), 30-day alert for manual |
| Cipher suites (TLS 1.2) | ECDHE + AES-GCM only — no CBC, no RC4 |
| HSTS | `max-age=63072000; includeSubDomains; preload` |
| OCSP Stapling | Enabled for performance |

```nginx
# ✅ TLS configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
ssl_prefer_server_ciphers off;
ssl_stapling on;
ssl_stapling_verify on;
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
```

## R4 — Load Balancer Rules

| Setting | ALB | NLB |
|---------|-----|-----|
| Cross-zone load balancing | On (default) | On |
| Idle timeout | 60s (adjustable for long-lived connections) | 350s |
| Deletion protection | On | On |
| Access logs | S3 bucket (90 day retention) | S3 bucket |
| Dropped headers | Enable if needed (X-Forwarded-For, etc.) | N/A |
| HTTP/2 | On | N/A |
| WAF association | On for production | N/A |

## R5 — CDN and Edge (CloudFront / Cloudflare)

| Rule | Reason |
|------|--------|
| Cache static assets at edge (JS, CSS, images, fonts) | Reduce origin load, faster for users |
| Dynamic content: cache if TTL > 0 (even 1s helps) | Reduces origin requests during bursts |
| Enable compression (Brotli, gzip) | Smaller payloads, faster loads |
| Geo-restrict if needed | Block traffic from unexpected regions |
| WAF at edge | Block attacks before they reach origin |
| Shield / Advanced features | DDoS protection for critical endpoints |

## R6 — Firewall Rules (WAF)

```yaml
# ✅ WAF rule priority
rules:
  - name: IP-rate-limit
    priority: 1
    action: block
    limit: 2000 per 5 minutes
  - name: SQL-injection
    priority: 5
    action: block
    statement: sqli_match_set
  - name: XSS
    priority: 10
    action: block
    statement: xss_match_set
  - name: Scanner-block
    priority: 15
    action: block
    statement: contains(header:user-agent, "badbot")
  - name: Country-block
    priority: 20
    action: block
    statement: not_country(US, CA, GB, DE, FR)
```

## R7 — Network Troubleshooting Checklist

| Symptom | Check |
|---------|-------|
| Service unreachable | Security groups allow ingress? |
| Pod can't connect to DB | NetworkPolicy allows egress to DB pod? |
| High latency | Cross-AZ traffic? Check Wireshark / tcpdump |
| DNS not resolving | Correct nameserver? TTL expired? |
| Certificate error | Expired? Wrong domain? Using correct cert? |
| Rate limiting | WAF throttling? ALB connection limit? |
| Packet loss | Network ACL? Security group? MTU issues? |
