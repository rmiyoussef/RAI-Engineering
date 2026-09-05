# Domain Modeling

> **Source:** Adapted from mattpocock/skills (domain-modeling)
> **Domain:** Shared — Cross-Domain
> **Use when:** Building and sharpening a project's domain model — challenging terms, inventing edge cases, documenting vocabulary.

---

## Overview

Domain modeling is the active discipline of building and sharpening the shared vocabulary of a project. The domain model captures what things are called, how they relate, and what rules govern them — completely devoid of implementation details.

## File Structure

- Most repos: a single `CONTEXT.md` at the project root
- Multi-context repos: a `CONTEXT-MAP.md` pointing to sub-contextual files
- Files are created lazily (only when a concept needs documenting)

## During a Session

### Challenge Terms
- When a term conflicts with the existing glossary, surface it
- Push for precision: "What exactly do we mean by 'order' — is it the cart state, the confirmed state, or the shipped state?"

### Sharpen Fuzzy Language
- When the user or spec uses vague terms, propose precise canonical terms
- Example: "You said 'process the payment' — do you mean authorize, capture, or refund?"

### Probe Edge Cases
- Discuss concrete scenarios that force precision
- "What happens when the user tries to cancel an order that's already shipped?"
- "What's the difference between 'deleted' and 'archived'?"

### Cross-Reference with Code
- Surface contradictions between the domain model and the implementation
- "The code calls this 'Subscription' but the domain model says 'Plan' — which one wins?"

### Update CONTEXT.md Right There
- When terms are resolved, update `CONTEXT.md` immediately
- The file should be totally devoid of implementation details — it describes the problem space, not the solution space

## Relationship to ADRs

ADRs capture **technical** decisions and their trade-offs. The domain model captures **domain** vocabulary and business rules. An ADR might say "we chose PostgreSQL for geographic queries." The domain model says "a Customer has a ShippingAddress with street/city/postalCode."

Offer an ADR only when all three conditions are met:
1. The decision is **hard to reverse**
2. The decision would be **surprising** to a future reader
3. The decision is the **result of a real trade-off**

## Verification Checklist

- [ ] Domain terms are defined in `CONTEXT.md` (or equivalent)
- [ ] Terms are precise and unambiguous
- [ ] Edge cases are documented
- [ ] Domain model is free of implementation details
- [ ] Code and domain model are consistent (contradictions surfaced)
