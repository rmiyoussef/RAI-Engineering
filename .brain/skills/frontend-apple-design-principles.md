---
domains: [frontend]
---

# Apple Design Principles

> **Source:** Adapted from emilkowalski/skills (apple-design)
> **Domain:** Frontend
> **Use when:** Applying Apple's UI and motion principles to web interfaces, distilled from WWDC design talks.

---

## Overview

Apple's design philosophy translated for web engineers. The focus is on clarity, deference, and depth.

## Core Principles

### Clarity
- Content is king. UI should get out of the way.
- Use typography, not visual chrome, to establish hierarchy
- Precise, purposeful language
- Negative space is a feature, not empty space

### Deference
- UI elements recede to let content shine
- Motion and visual effects serve a purpose — they're never decorative
- Transitions guide attention to what changed

### Depth
- Layers communicate hierarchy and relation
- Use translucency, shadows, and motion to create spatial awareness
- Content lives on distinct planes (modal, sheet, navigation, content)

## Animation Philosophy

### Purposeful Motion
Every animation answers a question: "Where did this come from? Where did it go? What just happened?"

- **Source anchoring:** UI elements should animate from their origin point
- **Spatial continuity:** Maintain consistent spatial relationships during transitions
- **Interruptibility:** Users can interact with animations in progress (tap to stop, reverse on hover-out)

### Physics-Based Motion

Apple favors spring-based animations over easing curves:
- Natural acceleration and deceleration
- Automatic interruptibility
- Consistent feel across different distances

### Timing

| Interaction | Duration | Notes |
|-------------|----------|-------|
| Tap feedback | ~100ms | Instant confirmation |
| List item selection | ~200ms | Quick state change |
| Sheet/modal presentation | ~300-400ms | Slower for larger transitions |
| Page transitions | ~400-500ms | Content-driven timing |

## Visual Design Patterns

### Layering (Z-Order)
```
Content (base) → Controls → Sheets/Modals → Alerts → System UI
```

Each layer has distinct visual treatment:
- **Content layer:** Clean, flat, content-focused
- **Controls:** Subtle backgrounds, distinct on hover
- **Sheets/Modals:** Rounded corners, shadow, blur behind
- **Alerts:** Center screen, strong visual weight

### Typography
- Dynamic type scales (responsive to user preferences)
- Hierarchy through weight and size, not color
- Generous line-height for readability (1.4-1.6 for body text)

### Color
- Use color sparingly and with purpose
- Semantic colors (tint, accent, destructive)
- Support both light and dark modes natively

## Web Implementation

```css
/* Source-anchored animation example */
@keyframes source-reveal {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
```

**Key web rules:**
- `transform-origin` controls the anchor point — set it to the element's origin
- `prefers-reduced-motion` must be respected
- Spring vs. bezier: use springs for interactive elements, beziers for passive transitions
