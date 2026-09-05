# Observability and Instrumentation

> **Source:** Adapted from addyosmani (observability-and-instrumentation)
> **Domain:** Shared — Cross-Domain
> **Use when:** Building production features, adding services/integrations, setting up monitoring.

---

## Overview

Unobservable code is inoperable. Instrumentation is not a post-launch add-on — it's written alongside the feature, the same way tests are.

## Process (7 Steps)

### 1. Define "Working" Before Instrumenting

Write down 2-4 questions an on-call engineer will ask about the feature. If you can't name the questions, you're not ready to instrument.

### 2. Pick the Right Signal

| Signal | What It Answers | Tool |
|--------|----------------|------|
| **Structured logs** | What happened per-request | JSON logging, structured format |
| **Metrics** | How often / how fast aggregated | RED, USE frameworks |
| **Traces** | Where time went across services | OpenTelemetry |

**Rule of thumb:** Metrics tell you that something is wrong; traces tell you where; logs tell you why.

### 3. Structured Logging

- Log JSON objects with stable event names
- Consistent levels: error (investigate now), warn (watch trends), info (significant event), debug (off in production)
- **Correlation IDs on every line and every outbound call** (mandatory)
- Never log secrets, tokens, passwords, or full PII

### 4. Metrics

- **RED** (Rate, Errors, Duration) for request-driven services
- **USE** (Utilization, Saturation, Errors) for resources
- **Cardinality is the failure mode** — labels must come from small, fixed sets
- Track **percentiles always, averages never**

### 5. Distributed Tracing

- Use OpenTelemetry with auto-instrumentation
- Add manual spans around meaningful internal work
- Propagate context across async boundaries
- Sample head-based at low rate; keep 100% of errors if supported

### 6. Alerting

- **Alert on symptoms users feel, not on causes**
- Every alert must be actionable, link to a runbook, have justified thresholds
- Two severities only: **page** (wake someone up) and **ticket** (fix in business hours)

### 7. Verify the Telemetry

- Force errors in staging and confirm logs/metrics/traces fire
- Test-fire each alert

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "I'll add logging after it works" | Debugging without logs wastes more time than adding logs |
| "console.log is fine" | Not in production. Use structured logging. |
| "High-cardinality labels are fine" | Not at scale. They break your metrics system. |
| "Averages are good enough" | Averages hide p99. Use percentiles. |

## Red Flags

- PRs with retry logic but no telemetry
- String-interpolated log messages (should be structured)
- No correlation ID on error lines
- Cardinality bombs (user_id, email, session_id as metric labels)
- Alerting on causes (not symptoms)
- Secrets in log output

## Verification Checklist

- [ ] On-call questions documented for this feature
- [ ] Logs are structured JSON with stable event names
- [ ] No secrets leak to logs (verified by scanning)
- [ ] RED metrics exist for every request-driven service
- [ ] Latency tracked with histograms/percentiles, not averages
- [ ] Distributed traces flow end-to-end
- [ ] Alerts are symptom-based with runbooks
- [ ] Induced failure was found via telemetry alone
