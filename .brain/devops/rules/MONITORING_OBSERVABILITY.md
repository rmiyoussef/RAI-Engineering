# Monitoring & Observability Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** DevOps — observability and monitoring
> **Purpose:** Know what's happening in production at all times.

---

## R1 — The Three Pillars

| Pillar | What it answers | Tool examples |
|--------|-----------------|---------------|
| **Metrics** | What's happening? (numbers) | Prometheus, CloudWatch, Datadog |
| **Logs** | Why is it happening? (events) | ELK, Loki, CloudWatch Logs |
| **Traces** | Where is it happening? (request flow) | OpenTelemetry, Jaeger, X-Ray |

All three are required for production observability.

## R2 — Golden Signals (USE + RED)

### USE Method (Infrastructure)
| Signal | Measures | Follow |
|--------|----------|--------|
| **Utilization** | % of resource busy | CPU, Memory, Disk, Network |
| **Saturation** | Queued/dropped work | Load average, queue depth |
| **Errors** | Failed operations | 5xx, OOM, crash loops |

### RED Method (Services)
| Signal | Measures | Follow |
|--------|----------|--------|
| **Rate** | Requests per second | Throughput |
| **Errors** | Failed requests | 5xx, 4xx > threshold |
| **Duration** | Response time | p50, p95, p99 |

```yaml
# ✅ Prometheus recording rules for RED
groups:
  - name: service_red
    rules:
      - record: service:request_rate:1m
        expr: rate(http_requests_total[1m])
      - record: service:error_rate:1m
        expr: rate(http_requests_total{status=~"5.."}[1m])
      - record: service:latency_p99:1m
        expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[1m]))
```

## R3 — Structured Logging

```json
// ✅ Every log line is valid JSON — one object per line
{
  "ts":        "2026-07-23T10:00:00.123Z",
  "level":     "info",
  "service":   "api-gateway",
  "trace_id":  "abc123def456",
  "span_id":   "span789",
  "message":   "request completed",
  "method":    "POST",
  "path":      "/api/v1/orders",
  "status":    201,
  "duration":  42,
  "user_id":   "user_789",
  "error":     null
}
```

### Log Levels

| Level | When | Action |
|-------|------|--------|
| `DEBUG` | Development, troubleshooting | Filtered in production |
| `INFO` | State changes, request lifecycle | Normal operations |
| `WARN` | Degraded but handled (retry, fallback) | Investigate if persistent |
| `ERROR` | Operation failed, user impacted | PagerDuty alert |
| `FATAL` | Service cannot continue | Immediate incident |

## R4 — Metrics Every Service Must Export

```prometheus
# REQUIRED metrics for every service
http_requests_total{method, path, status}       # Request count
http_request_duration_seconds_bucket{method, path} # Latency histogram
http_requests_in_flight{method}                  # Concurrent requests
app_health_status{component}                     # Health check (1=healthy, 0=unhealthy)
app_info{version, commit}                        # Version info
```

### Custom Business Metrics

| Metric | Example | Why |
|--------|---------|-----|
| Business transactions | `orders_created_total` | Track business health |
| Queue depth | `queue_messages_ready` | Consumer lag |
| Cache hit ratio | `cache_hits_total / cache_requests_total` | Cache effectiveness |
| Background job duration | `job_duration_seconds` | Worker health |

## R5 — Alerting Rules

### Alert Severity

| Severity | Response time | Channel |
|----------|--------------|---------|
| **Critical (P0)** | < 15 min | Phone + Slack + PagerDuty |
| **High (P1)** | < 30 min | Slack + PagerDuty |
| **Medium (P2)** | < 4 hours | Slack |
| **Low (P3)** | < 24 hours | Slack (optional) |

### When to Alert

| Alert condition | Example |
|-----------------|---------|
| Service is down | `up{job="api"} == 0` |
| High error rate | `error_rate > 5%` for 5 min |
| High latency | `p99 > 2s` for 10 min |
| Certificate expiring | `cert_expiry < 30 days` |
| Queue growing | `queue_depth > 1000` for 5 min |
| Disk filling | `disk_free < 10%` |
| Cost anomaly | Daily cost > 120% of budget |

### When NOT to Alert

- Single pod restart (auto-recovered)
- Slight latency increase during deploy (expected)
- Transient 4xx errors (user input errors)
- Low traffic period (metric noise)

## R6 — Distributed Tracing

```typescript
// ✅ OpenTelemetry instrumentation
import { trace, context } from '@opentelemetry/api';

const tracer = trace.getTracer('order-service');

async function createOrder(req: Request, res: Response) {
  const span = tracer.startSpan('createOrder', {
    attributes: {
      'order.type': req.body.type,
      'user.id': req.user.id,
    }
  });

  return await context.with(trace.setSpan(context.active(), span), async () => {
    try {
      const result = await orderService.create(req.body);
      span.setStatus({ code: SpanStatusCode.OK });
      return result;
    } catch (error) {
      span.recordException(error);
      span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  });
}
```

| Trace context | Propagated via |
|---------------|---------------|
| `trace_id` | HTTP headers: `traceparent`, `x-request-id` |
| `span_id` | Same header, or W3C Trace Context |
| `baggage` | `baggage` header — key/value context propagation |

## R7 — Dashboard Rules

| Dashboard | Audience | Refresh |
|-----------|----------|---------|
| **Executive** | Stakeholders | Daily |
| **Service** (RED) | Engineering team | Real-time |
| **Infrastructure** | DevOps | Real-time |
| **Cost** | Finance/engineering | Weekly |
| **SLA/SLO** | All | Real-time |

### Dashboard Best Practices

- One panel per metric type (don't mix units)
- Every panel has a clear title and Y-axis label
- Use log scales for wide-range metrics (latency)
- Set reasonable time ranges (default 1h, 6h, 24h)
- Annotate deployments on dashboards

## R8 — SLO and SLI Framework

```yaml
# ✅ SLO example: API request latency
service: api-gateway
sli:
  good_events: count of requests with latency < 200ms
  total_events: count of all requests
  measurement_window: 30 days
slo:
  target: 99.9%
  burn_rate_alerts:
    - 10x burn rate for 10 min (critical)
    - 2x burn rate for 1 hour (warning)
error_budget: 100% - SLO target (0.1%)
```

| SLO target | Nines | Downtime/month |
|------------|-------|----------------|
| 99% | 2 nines | 7.2 hours |
| 99.9% | 3 nines | 43 minutes |
| 99.95% | 3.5 nines | 21 minutes |
| 99.99% | 4 nines | 4.3 minutes |

## R9 — Centralized Logging Pipeline

```
App (stdout JSON)
  ↓
Log shipper (Fluentd, Vector, Fluent Bit)
  ↓
Central store (Elasticsearch, Loki, CloudWatch)
  ↓
Search + Visualization (Kibana, Grafana)
  ↓
Alerting (ElastAlert, Grafana Alerts)
```

### Log Retention

| Environment | Retention | Storage class |
|-------------|-----------|---------------|
| Development | 7 days | Hot |
| Staging | 30 days | Hot |
| Production | 90 days hot + 1 year cold | Hot + Cold/Glacier |
| Audit/compliance | 7 years | Glacier/S3 Glacier Deep Archive |
