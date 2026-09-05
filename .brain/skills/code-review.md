# Code Review and Quality

> **Source:** Adapted from addyosmani (code-review-and-quality) + mattpocock (code-review)
> **Domain:** Shared — Cross-Domain
> **Use when:** Reviewing code changes before merge.

---

## Philosophy

Approve a change when it definitely improves overall code health, even if it isn't perfect. Continuous improvement, not perfection.

## Review Axes

### 1. Correctness
- Does code match the spec/requirements?
- Are edge cases, error paths, and race conditions handled?
- Do tests verify the right things?

### 2. Readability & Simplicity
- Clear names, straightforward control flow
- No "clever" tricks
- Dead code artifacts? Conditionals bolted onto unrelated flows?
- Repeated conditionals on the same shape (signals a missing model or dispatcher)

### 3. Architecture
- Follows existing patterns, clean module boundaries
- Correct dependency direction (no feature logic leaking into shared modules)
- Count concepts a reader must hold — if unchanged, restructuring isn't an improvement
- No over-engineering

### 4. Security
- Input validation at all boundaries
- No secrets in code or logs
- SQL injection protection (parameterized queries)
- XSS protection (output encoding)
- Treat all external data as untrusted

### 5. Performance
- N+1 queries detected?
- Unbounded loops or data fetching?
- Sync operations that should be async?
- Missing pagination on list endpoints?

## Finding Classification

| Prefix | Meaning |
|--------|---------|
| *(no prefix)* | Required change |
| **Critical:** | Blocks merge (security, data loss, broken functionality) |
| **Nit:** | Minor, optional (style/formatting) |
| **Optional:** / **Consider:** | Suggestion |
| **FYI** | Informational |

## Change Sizing

| Size | Lines Changed | Action |
|------|---------------|--------|
| Good | ~100 | Ready for review |
| Acceptable | ~300 | One logical change |
| Too large | 1000+ | Split it |

**File size signal:** ~1000 total lines in one file → decompose before adding more.

## Review Process (5 Steps)

1. **Understand context** — what's the intent? Read the spec/issue/requirements.
2. **Review tests first** — do they test behavior, not implementation details?
3. **Review implementation** — across all five axes
4. **Categorize findings** — with severity prefixes
5. **Verify the verification** — tests pass, build succeeds, manual checks done

## Structural Remedies

Rather than just flagging problems, propose specific moves:
- Replace conditionals with typed models/dispatchers
- Collapse duplicate branches
- Separate orchestration from business logic
- Move feature logic to its owning package
- Reuse canonical helpers
- Delete pass-through wrappers
- Extract helpers or split large files

## Handling Disagreements

Apply this hierarchy:
1. Technical facts / data
2. Style guides
3. Software design principles
4. Codebase consistency

Don't accept "I'll clean it up later." Require cleanup before submission or file a bug with self-assignment.

## Dependency Discipline

Before adding any dependency:
- Does the existing stack already solve this?
- Check bundle size, maintenance status, known vulnerabilities, license compatibility
- Prefer standard library and existing utilities
- Upgrade one dependency per change
- Review lockfile diffs including transitive deps
- Never hand-edit the lockfile

## Verification Checklist

- [ ] All Critical and Required issues resolved
- [ ] Tests pass
- [ ] Build succeeds
- [ ] Verification story documented
- [ ] Dependency upgrades reviewed per changelog, isolated per package
