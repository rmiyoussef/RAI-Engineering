# Quality Bar

> What "good" means. Enforced by REVIEWER (score ≥ 7 to accept) and BACKEND QA. Complements canonical rules in `RULES.md`.

## Code

- One responsibility per file; methods short and named for intent (R10).
- No duplication without justification; no dead code, no TODO leftovers at handoff.
- Errors handled explicitly with user-safe messages; no silent failures, no leaked internals.

## Testing

- Every change includes or updates tests (R3). New behavior without a covering TC is incomplete.
- Critical paths (auth, payments, migrations, security boundaries) require explicit TCs, never waivers.
- Flaky or brittle tests are fixed, not skipped; skips require reason + expiry.

## Security / Performance

- SECURITY audit for auth, input handling, PII, dependencies when touched. OWASP awareness by default.
- No N+1 queries; indexes for queried columns; response-time expectations stated in plan for perf-sensitive work.

## Review

- REVIEWER scores 1-10 on correctness, performance, security, style, coverage. < 7 returns to EXECUTOR, max 3 cycles (R45), then escalate.
- Review feedback is specific (file:line, problem, fix), never vague.

## Memory / Docs

- Completed work leaves summary + decision records + state updates. Work without a trace did not happen.
