# Brainstorming

> **Source:** Adapted from obra/superpowers (brainstorming) + addyosmani (idea-refine)
> **Domain:** Shared — Cross-Domain
> **Use when:** Turning vague ideas into actionable designs and specs, before writing any code.

---

## Overview

Turn vague ideas into sharp, actionable concepts through structured divergent and convergent thinking.

## Hard Gate

**Do not invoke any implementation skill, write any code, scaffold any project, or take any implementation action until a design is presented and approved.**

## Process (3 Phases)

### Phase 1: Diverge

1. **Explore project context** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, not overwhelming
3. **Restate as "How Might We"** — frame the core problem
4. **Generate 5-8 variations** using lenses:
   - Inversion — what if we did the opposite?
   - Constraint removal — what if X constraint didn't exist?
   - Audience shift — for a different user?
   - Combination — merge with an adjacent concept
   - Simplification — what's the minimum version?
   - 10x version — what if it were 10x better?
   - Expert lens — how would [known expert] approach this?

### Phase 2: Converge

1. **Cluster** ideas into 2-3 directions
2. **Stress-test** each on: user value, feasibility, differentiation
3. **Surface assumptions** — "what you're betting is true," what could kill the idea, what's being intentionally ignored
4. **Propose 2-3 approaches** with trade-offs and a recommendation

### Phase 3: Write Spec

1. **Present design** section by section, getting approval after each
2. **Write design doc** — saved to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
3. **Self-review** — check for placeholders, contradictions, ambiguity, scope
4. **User reviews** the written spec
5. **Transition to implementation** — invoke the writing-plans skill

## Anti-Patterns

- Generating 20+ shallow ideas (go deep on fewer)
- Skipping audience definition
- Yes-machining weak ideas
- Omitting a "Not Doing" list (arguably most valuable part)
- Jumping straight to implementation without running all three phases

## Design Principles

| Principle | Description |
|-----------|-------------|
| One question at a time | Don't overwhelm with multiple simultaneous questions |
| Multiple choice preferred | Offer options, not open-ended prompts |
| YAGNI | Remove unnecessary features from all designs |
| Incremental validation | User approval gates between each phase |
| Design for isolation | Each unit: one clear purpose, defined interfaces |

## Verification Checklist

- [ ] Clear "How Might We" problem statement
- [ ] Defined users and success criteria
- [ ] Multiple directions explored (not just one)
- [ ] Explicit assumptions with validation strategies
- [ ] "Not Doing" list with reasons
- [ ] Concrete markdown artifact saved to repo
- [ ] User confirmed before implementation begins
