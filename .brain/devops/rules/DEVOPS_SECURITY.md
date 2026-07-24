# DevOps Security Rules

> **Loaded by:** SECURITY agent, EXECUTOR agent, REVIEWER agent
> **Domain:** DevOps — infrastructure and pipeline security
> **Purpose:** Secure the entire delivery chain — from commit to production.

---

## R1 — Supply Chain Security

| Layer | Control | Tool |
|-------|---------|------|
| **Code** | Signed commits, branch protection | GPG, GitHub rules |
| **Dependencies** | Lockfile, vulnerability scan, SBOM | Trivy, npm audit, CycloneDX |
| **Build** | Reproducible builds, attestation | SLSA, in-toto attestations |
| **Artifact** | Signed images, trusted registry | Cosign, Notation, Harbor |
| **Deploy** | GitOps, approval gates | ArgoCD, Flux, GitHub Environments |

```bash
# ✅ Sign container images
cosign sign --key cosign.key ghcr.io/myorg/myapp:1.0.0

# ✅ Verify before deploy
cosign verify --key cosign.pub ghcr.io/myorg/myapp:1.0.0

# ✅ Generate SBOM
trivy image --format cyclonedx --output sbom.cdx.json ghcr.io/myorg/myapp:1.0.0
```

## R2 — Secrets Management

| Situation | Method |
|-----------|--------|
| Secrets in Kubernetes | External Secrets Operator → Vault / AWS Secrets Manager |
| Secrets in CI | CI secrets vault — never in config files |
| Secrets in code | Use secret scanning (truffleHog, Gitleaks) in CI |
| Database credentials | Auto-rotation with sidecar (Vault Agent) |
| API keys | Scoped per service, rotated every 90 days |

```yaml
# ✅ Gitleaks pre-commit hook
- repo: https://github.com/gitleaks/gitleaks
  rev: v8.18.0
  hooks:
    - id: gitleaks
```

## R3 — Network Security

| Layer | Control |
|-------|---------|
| **Edge** | WAF, DDoS protection (CloudFront, Cloudflare, AWS WAF) |
| **Ingress** | TLS 1.2+ only, HTTP→HTTPS redirect |
| **Internal** | mTLS between services (service mesh) |
| **Pod** | NetworkPolicies — default deny, allow only needed |
| **Node** | Security groups — least access |
| **Data** | Encryption in transit (TLS) + at rest (KMS) |

## R4 — Compliance Scanning

```yaml
# ✅ CI compliance scan stage
- name: Infrastructure compliance
  uses: bridgecrewio/checkov-action@master
  with:
    directory: terraform/
    framework: terraform
    soft_fail: false

- name: Container compliance
  run: |
    docker scout cves myapp:latest
    trivy image --severity CRITICAL,HIGH myapp:latest

- name: Kubernetes compliance
  uses: instrumenta/kubeval@master
  with:
    manifests: k8s/
```

| Scan type | Frequency | Fail CI? |
|-----------|-----------|----------|
| IaC security (Terraform, K8s) | Every PR | Yes — critical/high |
| Container vulnerability | Every build | Yes — critical |
| Dependency audit | Every PR | Yes — critical |
| Secret leak | Every push | Yes — any detected |
| SBOM generation | Every release | N/A |
| License compliance | Weekly | Warning |

## R5 — Image Security Requirements

```dockerfile
# ✅ Security-hardened Dockerfile
FROM node:22-alpine@sha256:abc123...
RUN apk add --no-cache tini   # proper init for signals
COPY --chown=node:node dist ./dist
USER node
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/index.js"]
```

| Requirement | Check |
|-------------|-------|
| No `latest` tag | `grep -r ':latest' Dockerfile*` |
| Non-root user | `USER` directive exists |
| No known critical CVEs | Trivy scan passes |
| Minimal base image | Distroless or Alpine |
| Image signed | Cosign signature exists |
| No secrets in layers | Docker history shows no secrets |

## R6 — Runtime Security

```yaml
# ✅ Falco security rules
- rule: Terminal shell in container
  desc: Detect interactive shells in production containers
  condition: container.id != host and proc.name = bash
  output: "Shell opened (user=%user.name container=%container.name)"
  priority: WARNING

- rule: Unexpected outbound connection
  desc: Detect unexpected egress traffic
  condition: outbound and not allowed_destination
  priority: CRITICAL
```

| Runtime tool | Purpose |
|-------------|---------|
| Falco | Behavioral monitoring (container security) |
| OPA/Gatekeeper | Admission control (policy enforcement) |
| Kyverno | Kubernetes policy engine (generate, mutate, validate) |
| Kubernetes audit | API server audit logs |

## R7 — Backup Security

| Data | Encrypted? | Offsite? | Tested? |
|------|-----------|----------|---------|
| Database | ✅ KMS | ✅ Cross-region | ✅ Monthly restore test |
| Object storage (S3) | ✅ SSE | ✅ CRR | ✅ Quarterly |
| State files | ✅ KMS | ✅ Cross-region | N/A (rebuild) |
| Certificates | ✅ KMS | ✅ Cross-region | ✅ Before expiry |
| CI/CD config | ✅ Git | ✅ Remote | ✅ On clone |

## R8 — Incident Response

| Phase | Actions | Timeline |
|-------|---------|----------|
| **Detection** | Alert fires, on-call notified | < 5 min |
| **Triage** | Severity assessment, declare incident | < 10 min |
| **Containment** | Stop bleeding (rollback, block traffic) | < 15 min |
| **Resolution** | Fix root cause, deploy fix | < 1 hour |
| **Recovery** | Verify fix, restore full service | < 1 hour |
| **Postmortem** | Document timeline, root cause, action items | < 1 week |

## R9 — Least Privilege Checklist

- [ ] Service accounts scoped to namespace only
- [ ] No `cluster-admin` for application workloads
- [ ] IAM roles scoped to specific resource ARNs
- [ ] CI tokens scoped to one repository
- [ ] No access keys for humans (SSO/OIDC only)
- [ ] Secrets can only be read by the service that needs them
- [ ] Network policies restrict pod-to-pod communication
- [ ] Read-only root filesystem for containers
- [ ] No privileged containers
- [ ] Pod Security Standards set to `restricted`
