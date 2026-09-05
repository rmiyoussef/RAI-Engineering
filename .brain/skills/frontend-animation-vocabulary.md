---
domains: [frontend]
---

# Animation Vocabulary

> **Source:** Adapted from emilkowalski/skills (animation-vocabulary)
> **Domain:** Frontend
> **Use when:** Communicating animation intent to AI agents using precise terminology.

---

## Overview

A shared vocabulary for describing animations to AI agents. Precise language produces accurate animation code. Vague language produces generic results.

## Easing Vocabulary

| Term | CSS Equivalent | When to Use |
|------|---------------|-------------|
| **Ease-out** | `cubic-bezier(0, 0, 0.2, 1)` | Elements entering the screen (decelerate into position) |
| **Ease-in** | `cubic-bezier(0.4, 0, 1, 1)` | Elements leaving the screen (accelerate out) |
| **Ease-in-out** | `cubic-bezier(0.4, 0, 0.2, 1)` | Elements moving between states |
| **Linear** | `cubic-bezier(0, 0, 1, 1)` | Progress bars, color transitions |
| **Spring** | Framer Motion `spring()` | Natural-feeling, interruptible motion |
| **Anticipate** | Framer Motion `backIn` | Element overshoots slightly before settling |

## Timing Vocabulary

| Term | Duration | Use Case |
|------|----------|----------|
| **Instant** | 0-50ms | Hover effects, tap feedback |
| **Fast** | 150-200ms | Micro-interactions, state changes |
| **Normal** | 200-300ms | Standard UI transitions |
| **Slow** | 300-500ms | Page transitions, modal presentations |
| **Deliberate** | 500-800ms | Hero animations, onboarding sequences |

## Behavior Vocabulary

| Term | Definition |
|------|------------|
| **Stagger** | Multiple elements animate one after another with a delay between each |
| **Orchestrate** | Coordinate multiple animations to happen in sequence or in parallel |
| **Interruptible** | Current animation stops/redirects when user interacts |
| **Source-anchored** | Element animates from its origin point |
| **Mounted/unmounted** | Element enters/leaves the DOM (requires `@starting-style` or Framer AnimatePresence) |
| **Layout animation** | Element's position/size changes and other elements smoothly adjust |
| **Exit animation** | Animation that plays when an element is removed |
| **Entrance animation** | Animation that plays when an element appears |

## Property Vocabulary

| Animate This | Don't Animate This |
|-------------|-------------------|
| `transform` (translate, scale, rotate) | `width`, `height` (triggers layout) |
| `opacity` | `top`, `left`, `right`, `bottom` (triggers layout) |
| `filter` (if hardware-accelerated) | `margin`, `padding` (triggers layout) |
| `clip-path` (simple shapes) | `box-shadow` (expensive to paint) |

## Example: Precise vs Vague

**Vague:** "Make the button animate smoothly on hover"

**Precise:** "On hover, scale the button to 1.05 over 200ms with ease-out, and change background from gray-100 to gray-200. On hover-out, return to original scale over 150ms."

**Vague:** "Nice transition on the modal"

**Precise:** "Modal enters with opacity 0 → 1 and translateY(20px) → translateY(0) over 300ms with ease-out. Background overlay fades in over 200ms. On close, modal exits over 200ms with ease-in, overlay fades over 150ms."
