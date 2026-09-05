# Improve Codebase Architecture

> **Source:** Adapted from mattpocock/skills (improve-codebase-architecture)
> **Domain:** Shared — Cross-Domain
> **Use when:** Surface architectural friction and propose deepening opportunities — refactors that turn shallow modules into deep ones.

---

## Overview

Surface architectural friction and propose deepening opportunities — refactors that turn shallow modules into deep ones. Uses the codebase-design vocabulary (module, interface, depth, seam, adapter, leverage, locality).

## Process

### 1. Explore

**Scope before you scan — YAGNI.** Put extra weight on parts of the codebase that have recently changed.

- If the user named a direction (module, subsystem, pain point), take it
- Otherwise, walk back commit history to find hot spots

Explore organically using the codebase-design vocabulary:
- Where does understanding one concept require bouncing between many small modules?
- Where are modules shallow — interface nearly as complex as implementation?
- Where do tightly-coupled modules leak across their seams?
- Apply the **deletion test**: would deleting it concentrate complexity, or just move it?

### 2. Present Candidates

For each candidate, document:
- **Files** — which files/modules are involved
- **Problem** — why the current architecture causes friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage
- **Recommendation strength** — Strong / Worth exploring / Speculative

End with a **top recommendation**: which candidate to tackle first and why.

### 3. Grilling Loop (per candidate)

Walk through the decision tree with the user:
- Constraints and dependencies
- The shape of the deepened module
- What sits behind the seam
- What tests survive

**Side effects:** Update the domain model (`CONTEXT.md`) as decisions crystallize. If the user rejects a candidate with a load-bearing reason, offer to write an ADR.

## Vocabulary

Use the codebase-design vocabulary exactly:
- **Module** — not "component," "service," "API," or "boundary"
- **Interface** — everything a caller must know
- **Depth** — behavior per unit of interface
- **Seam** — where you can alter behavior without editing in that place
- **Adapter** — concrete thing satisfying an interface at a seam

## Key Rules

- Never propose interfaces yet during exploration
- Only surface ADR conflicts when the friction is real enough to warrant revisiting
- Don't list every theoretical refactor an ADR forbids
- Each candidate must have a clear before/after picture
