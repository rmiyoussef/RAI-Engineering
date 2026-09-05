---
domains: [frontend]
---

# Frontend UI Engineering

> **Source:** Adapted from addyosmani (frontend-ui-engineering)
> **Domain:** Frontend
> **Use when:** Building new components, modifying interfaces, responsive layouts, interactivity, or fixing UX issues.

---

## Overview

Build production-quality, accessible, responsive user-facing UIs. The goal is a UI that appears crafted by a design-aware engineer at a top company — not AI-generated.

## Component Architecture

### File Structure (Colocated)
```
Component/
├── Component.tsx
├── Component.test.tsx
├── Component.stories.tsx
├── hooks/useComponentLogic.ts
└── types.ts
```

### Patterns

| Pattern | Description |
|---------|-------------|
| **Composition over configuration** | Compose small components, don't add boolean props |
| **Focused components** | One responsibility per component |
| **Separate data from presentation** | Containers fetch data, presenters render UI |

## State Management Hierarchy

1. `useState` — component-local state
2. Lifting state up — shared between siblings
3. Context — deep tree sharing (use sparingly)
4. URL state — search params, route params
5. Server state (React Query / SWR) — API data with caching
6. Global store (Redux, Zustand) — last resort

**Rule:** No prop drilling deeper than 3 levels. Time to reach for Context or composition.

## Design System Adherence

| Element | AI Default (Avoid) | Production Quality |
|---------|-------------------|-------------------|
| Color | Purple/indigo, excessive gradients | Semantic color tokens, restrained palette |
| Rounding | Everything rounded-xl | Purposeful radii based on hierarchy |
| Shadows | Generic "card" shadows | Semi-transparent, context-aware |
| Spacing | Inconsistent, arbitrary values | 4px/8px grid scale |
| Typography | System font stack | Defined type scale + hierarchy |
| Hero sections | Generic gradient + floating elements | Purposeful layout with content priority |

## Accessibility

- **Keyboard navigation** — Tab order follows visual order, all interactive elements reachable
- **ARIA labels** — meaningful labels on non-text elements
- **Focus management** — visible focus rings, focus trap in modals, restore focus on close
- **Empty/error states** — meaningful messaging, recovery actions
- **Motion** — respect `prefers-reduced-motion`

## Responsive Design

**Mobile-first approach:**
| Breakpoint | Target |
|------------|--------|
| 320px | Small mobile |
| 768px | Tablet |
| 1024px | Desktop |
| 1440px | Wide desktop |

## Loading & Transitions

| Pattern | Use |
|---------|-----|
| **Skeleton loading** | Content areas (not spinners) |
| **Optimistic updates** | Update UI before server confirms (with React Query) |
| **Transitions** | Only animate `transform` and `opacity` for performance |

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "Accessibility is a nice-to-have" | It's a requirement. 15% of users rely on assistive tech. |
| "This is just a prototype" | Prototypes become production. Build it right. |
| "The design system doesn't cover this" | Extend it consistently instead of ad-hoc styling. |

## Red Flags

- Components over 200 lines
- Inline styles (everywhere)
- Missing loading/error/empty states
- Generic "AI look" (purple/indigo, excessive gradients, everything rounded)
- Prop drilling deeper than 3 levels

## Verification Checklist

- [ ] No console errors or warnings
- [ ] Keyboard navigation works (Tab, Enter, Escape)
- [ ] Screen reader tested (labels, roles, live regions)
- [ ] Responsive at all 4 breakpoints
- [ ] Loading, empty, error, and edge states handled
- [ ] Uses design system tokens (colors, spacing, type)
- [ ] No a11y violations (axe-core / Lighthouse)
