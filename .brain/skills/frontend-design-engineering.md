---
domains: [frontend]
---

# Design Engineering (Animation-Focused)

> **Source:** Adapted from emilkowalski/skills (emil-design-eng)
> **Domain:** Frontend
> **Use when:** Building UI animations, reviewing animation quality, or improving motion in a codebase.

---

## Overview

Design engineering principles focused on building great interfaces. The core philosophy: taste is trained (not innate), unseen details compound into quality, and beauty is leverage in software.

## Animation Decision Framework

Before animating anything, ask four questions:

### 1. Should this animate?
Only animate elements that change meaningfully. Animate based on frequency: if it appears/disappears often, a transition helps; if it's a one-time appearance, a fade-in is fine.

### 2. What's the purpose?
- Guide attention (new element appearing)
- Show state change (open/close, active/inactive)
- Add polish (hover states, micro-interactions)

### 3. What easing?
- **UI elements:** Custom bezier curves (not CSS defaults)
- **Enter:** Ease-out (decelerate into position)
- **Exit:** Ease-in (accelerate out)
- **Moving between states:** Ease-in-out

### 4. How fast?
- Most UI animations: 200-300ms
- Micro-interactions: 150-200ms
- Enter animations: 300-400ms
- Exit animations: 150-200ms (faster than enter)

## Spring Animations

Use spring physics (not duration-based) when:
- Natural-feeling motion is important
- The animation needs to feel physically responsive
- Interruptibility matters (user interaction should stop/redirect the animation)

**Advantages:** Interruptible by default, natural overshoot, no timing calc needed.

## Component Building Principles

| Principle | Description |
|-----------|-------------|
| Responsive scales | Button sizes respond to container, not fixed px |
| Avoid `scale(0)` | Use opacity + transform tricks instead |
| Popover positioning | Origin-aware (opens from where it's triggered) |
| Tooltip delay | Skip delay on hover (instant), keep on unhover |
| CSS transitions over keyframes | More control, better performance |
| Use `@starting-style` | For entry animations of `display: none` elements |

## CSS Transform Mastery

- `translateY(%)` — percentage is of element's own size, not container
- Child scaling — combine with `transform-origin` for natural growth
- 3D transforms — use `transform: translateZ(0)` for hardware acceleration (only when needed)
- `transform-origin` — controls the pivot point of transforms

## Performance Rules

1. Only animate `transform` and `opacity` — anything else triggers layout/paint
2. Avoid CSS variable inheritance for swipe amounts in heavy animations
3. Hardware acceleration: test without `translateZ(0)` first — it uses GPU memory
4. WAAPI (Web Animations API) over JS-driven animation for simple cases

## Accessibility

- Always respect `prefers-reduced-motion`
- Gate hover animations behind `hover: hover` media query (avoid sticky-hover on touch devices)
- Don't animate content that conveys meaning (users may miss it)

## Review Checklist

| Check | Guideline |
|-------|-----------|
| Duration | 200-300ms for UI | 
| Easing | Custom bezier, not CSS defaults |
| Interruptible | Current animation stops when user interacts |
| Performance | Only transform + opacity |
| Reduced motion | `prefers-reduced-motion` respected |
| Hover | Gated behind `hover: hover` |
