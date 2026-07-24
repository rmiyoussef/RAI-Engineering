# Kubernetes Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent, SECURITY agent
> **Domain:** DevOps — Kubernetes orchestration
> **Purpose:** Production-grade, secure, cost-efficient Kubernetes workloads.

---

## R1 — Pod Design

```yaml
# ✅ Production-ready pod spec
apiVersion: v1
kind: Pod
metadata:
  name: app
  labels:
    app: myapp
spec:
  serviceAccountName: myapp       # not default
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      image: myapp:1.0.0
      ports:
        - containerPort: 3000
          protocol: TCP
      resources:                  # REQUIRED
        requests:
          memory: "256Mi"
          cpu: "250m"
        limits:
          memory: "512Mi"
          cpu: "500m"
      livenessProbe:              # restarts if app is stuck
        httpGet:
          path: /healthz
          port: 3000
        initialDelaySeconds: 10
        periodSeconds: 10
      readinessProbe:             # removes from service if unhealthy
        httpGet:
          path: /readyz
          port: 3000
        initialDelaySeconds: 5
        periodSeconds: 5
      startupProbe:               # gives slow-starting apps time
        httpGet:
          path: /startupz
          port: 3000
        failureThreshold: 30
        periodSeconds: 10
      envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secrets
```

## R2 — Probe Rules

| Probe | Purpose | When it fires | Action |
|-------|---------|---------------|--------|
| `livenessProbe` | Is the app running? | App deadlocked, stuck | Kill and restart pod |
| `readinessProbe` | Can it serve traffic? | App starting, overloaded | Remove from Service |
| `startupProbe` | Has it finished initializing? | Slow startup, warmup | Delay liveness checks |

```yaml
# ✅ Rule of thumb: startupProbe for slow apps (>30s startup)
# ✅ Rule of thumb: readinessProbe should be more conservative than liveness
# ❌ Don't use the same endpoint for liveness and readiness
```

## R3 — Deployment Strategy

| Strategy | Use case | Max unavailable | Max surge |
|----------|----------|-----------------|-----------|
| `RollingUpdate` (default) | Stateless apps | 25% | 25% |
| `Recreate` | Stateful apps, DB migrations | N/A | N/A |
| `Blue/Green` | Critical traffic, canary | Manual | 100% (separate svc) |
| `Canary` | Gradual rollout | Controlled via Service Mesh | 10%-50% |

```yaml
# ✅ Rolling update (default for stateless)
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1

# ✅ Blue/Green via separate services
# svc-blue: points to old deployment
# svc-green: points to new deployment
# Switch traffic by updating ingress/service selector
```

## R4 — Pod Disruption Budgets

```yaml
# ✅ Ensure availability during node maintenance
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2        # or maxUnavailable: 1
  selector:
    matchLabels:
      app: myapp
```

| Replicas | PDB rule |
|----------|----------|
| 1 | No PDB (can't drain anyway) |
| 2-3 | `maxUnavailable: 1` |
| 4-10 | `minAvailable: 2-3` |
| 10+ | `maxUnavailable: 25%` |

## R5 — Network Policies

```yaml
# ✅ Default deny ingress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
    - Ingress

# ✅ Allow only from specific services
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-network-policy
spec:
  podSelector:
    matchLabels:
      app: myapp
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: ingress-gateway
      ports:
        - port: 3000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: database
      ports:
        - port: 5432
```

## R6 — Resource Quotas and Limits

```yaml
# ✅ Namespace-level resource quotas
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "8Gi"
    limits.cpu: "8"
    limits.memory: "16Gi"
    persistentvolumeclaims: "5"
    services: "20"

# ✅ LimitRange for pods without explicit requests
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
spec:
  limits:
    - default:
        memory: "512Mi"
        cpu: "500m"
      defaultRequest:
        memory: "256Mi"
        cpu: "250m"
      type: Container
```

## R7 — ConfigMaps and Secrets

| Data type | Store in |
|-----------|----------|
| Non-sensitive config | `ConfigMap` (env vars or mounted files) |
| Sensitive data | `Secret` (base64 is encoding, not encryption) |
| Large config (>1MB) | Mount from volume or external store |
| Auto-rotating secrets | External Secrets Operator, Vault, SealedSecrets |

```yaml
# ✅ External Secrets Operator pattern
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  refreshInterval: "1h"
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: app-secrets
  data:
    - secretKey: db_password
      remoteRef:
        key: /production/app/db_password
```

## R8 — Horizontal Pod Autoscaling

```yaml
# ✅ HPA with custom metrics
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

## R9 — Cluster Security

| Control | Implementation |
|---------|---------------|
| RBAC | Least privilege per service account. No cluster-admin for apps |
| Pod Security Standards | `enforce: restricted` in namespace labels |
| Network segmentation | NetworkPolicies per namespace |
| Secrets encryption | Enable KMS encryption for etcd |
| Audit logging | Enable Kubernetes audit logs to SIEM |
| Admission control | OPA/Gatekeeper or Kyverno for policy enforcement |
| Node security | Regular node updates, CIS benchmark compliance |

```yaml
# ✅ Pod Security Standards enforcement
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## R10 — Anti-Patterns

| Anti-pattern | Fix |
|-------------|-----|
| Using `:latest` image tag | Pin exact version + digest |
| No resource limits | Always set requests and limits |
| Running as root | `securityContext.runAsNonRoot: true` |
| Single replica for critical workloads | `replicas: 2+` with PDB |
| No probes | Add startup, liveness, readiness probes |
| Secrets in ConfigMaps | Use Secrets or external secrets operator |
| Privileged containers | Only when absolutely required, with justification |
| Mounting docker socket | Never — breaks isolation |
| NodePort for production | Use Ingress with LoadBalancer or ClusterIP |
| Skipping PodDisruptionBudget | Always set PDB for production workloads |
