# Verification Before Completion

> **Source:** Adapted from obra/superpowers (verification-before-completion)
> **Domain:** Shared — Cross-Domain
> **Use when:** Before claiming any task, fix, or feature is complete. Always.

---

## The Iron Law

**No completion claims without fresh verification evidence.**

Before you say "done," "fixed," "passes," "works," or any synonym — you must have run the verification command and read the output yourself.

## The Gate Function

Before every completion claim:

1. **Identify** the proving command (test, build, lint, curl, etc.)
2. **Run** it fully (fresh execution, not a cached result)
3. **Read** the output and exit code
4. **Confirm** the output supports the claim
5. **Then** make the statement

## Claim-to-Evidence Mapping

| Claim | Required Evidence | Insufficient Evidence |
|-------|-------------------|----------------------|
| "Tests pass" | Test command output: 0 failures | "They should pass," previous run |
| "Linter is clean" | Lint command output: 0 warnings | "I fixed the issues" |
| "Build succeeds" | Build command output: exit 0 | "I think it compiles" |
| "Bug is fixed" | Test reproducing the bug now passes | "I changed the code to fix it" |
| "Feature works" | Manual verification or passing E2E test | "The code looks right" |

## Red Flags (Stop and Verify)

- Using "should," "probably," or "seems to" about completion
- Expressing satisfaction without evidence ("Great!", "Perfect!", "Done!")
- Trusting an agent's success report without running verification yourself
- ANY wording implying success without having run verification

## Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "Should work now" | Confidence ≠ evidence. Run the command. |
| "I'm confident" | Show me the green output. |
| "Just this once" | The one time you skip is where it fails. |
| "Partial check is enough" | Partial checks miss the failure case. |
| "It compiled in my head" | Compilers disagree. Run it. |

## Why This Matters

Without verification, you ship:
- Undefined functions
- Missing requirements
- Broken features
- Wasted time on false completion claims

The human partner loses trust. One verification run rebuilds it.
