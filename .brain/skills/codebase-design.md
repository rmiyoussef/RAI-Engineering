# Codebase Design

> **Source:** Adapted from mattpocock/skills (codebase-design)
> **Domain:** Shared — Cross-Domain
> **Use when:** Designing new modules, evaluating existing architecture, planning refactors.

---

## Shared Vocabulary

| Term | Definition |
|------|------------|
| **Module** | Anything with an interface and implementation (scale-agnostic — from a function to a service) |
| **Interface** | Everything a caller must know to use the module correctly (signatures + invariants + ordering + errors + config + performance) |
| **Implementation** | What's inside the module |
| **Depth** | Leverage at the interface — behavior per unit of interface a caller must learn |
| **Seam** | (per Michael Feathers) A place where you can alter behavior without editing in that place |
| **Adapter** | A concrete thing satisfying an interface at a seam |
| **Leverage** | What callers get from depth — more capability per interface unit learned |
| **Locality** | What maintainers get — change, bugs, and knowledge concentrate in one place |

## Deep vs Shallow

| Property | Deep | Shallow |
|----------|------|---------|
| Interface | Small | Large |
| Implementation | Significant | Thin |
| Caller learns | Little | Much |
| Test surface | Small | Large (fragmented across seams) |

**Deep** = a lot of behavior behind a small interface, placed at a clean seam, testable through that interface.
**Shallow** = interface nearly as complex as the implementation — the caller learns almost as much as they'd need to write it themselves.

## Principles

### 1. Depth is a property of the interface, not the implementation

A deep module has leverage at its seam. The implementation can be complex — that's fine. The interface should be simple.

### 2. The Deletion Test

If deleting the module and inlining its behavior makes the codebase complexity vanish, it was a pass-through (not a real module). Real modules concentrate complexity so the rest of the code doesn't have to.

### 3. The Interface is the Test Surface

Callers and tests cross the same seam. If your tests aren't testing through the interface, they're testing implementation details.

### 4. One Adapter = Hypothetical Seam; Two Adapters = Real Seam

Don't add a port/interface unless at least two adapters are justified (typically: production + test). A single-adapter seam is just indirection.

## Dependency Categories

When assessing deepening candidates, dependencies fall into four types:

| Type | Example | Deepenable? | Seam |
|------|---------|-------------|------|
| **In-process** | Pure computation, in-memory state | Always | No adapter needed |
| **Local-substitutable** | PGLite for Postgres, in-memory FS | Yes, if stand-in exists | Internal seam |
| **Remote but owned** | Your own service across network | Yes | Ports & Adapters |
| **True external** | Stripe, Twilio | Injectable as port | Mock adapter |

## Testability Design Patterns

1. **Accept dependencies, don't create them** — inject what you need
2. **Return results, don't produce side effects** — makes testing deterministic
3. **Small surface area** — fewer methods and parameters to test

## Verification Checklist

- [ ] Each module has one clear responsibility
- [ ] Interface is smaller than implementation (depth check)
- [ ] Deletion test passes (removing it concentrates, not just moves, complexity)
- [ ] Tests exercise the public interface, not internals
- [ ] External dependencies are injected (no hard-coded `new Stripe()`)
- [ ] At least two adapters for every port (production + test)
