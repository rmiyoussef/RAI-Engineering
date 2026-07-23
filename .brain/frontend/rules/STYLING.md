# Styling & CSS Architecture Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic (CSS Modules, Tailwind, styled-components, vanilla)
> **Purpose:** Maintainable, scalable, consistent styling at any team size.

---

## R1 — Design as a Token System

Never use raw values. Always reference a design token.

```css
/* ❌ Raw values everywhere */
.button {
  color: #1a73e8;
  font-size: 14px;
  border-radius: 8px;
  padding: 8px 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

/* ✅ Token references */
.button {
  color: var(--color-primary);
  font-size: var(--font-size-sm);
  border-radius: var(--radius-md);
  padding: var(--spacing-sm) var(--spacing-md);
  box-shadow: var(--shadow-sm);
}
```

### Required Token Categories

| Category | Examples |
|----------|---------|
| **Color** | `--color-primary`, `--color-bg`, `--color-text`, `--color-border`, `--color-error` |
| **Typography** | `--font-family`, `--font-size-xs` through `--font-size-3xl`, `--line-height` |
| **Spacing** | `--spacing-2xs` through `--spacing-3xl` (4px scale: 2, 4, 8, 12, 16, 24, 32, 48, 64) |
| **Radius** | `--radius-sm` (4px), `--radius-md` (8px), `--radius-lg` (12px), `--radius-full` (9999px) |
| **Shadow** | `--shadow-sm`, `--shadow-md`, `--shadow-lg` |
| **Z-index** | `--z-dropdown`, `--z-sticky`, `--z-modal`, `--z-tooltip` |
| **Breakpoint** | `--bp-sm` (640px), `--bp-md` (768px), `--bp-lg` (1024px), `--bp-xl` (1280px) |

## R2 — Responsive Design: Mobile-First

Write base styles for the smallest screen, then add larger breakpoints with `min-width`.

```css
/* ✅ Mobile-first */
.grid {
  display: grid;
  grid-template-columns: 1fr;          /* mobile: single column */
  gap: var(--spacing-sm);
}

@media (min-width: 640px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);  /* tablet: 2 columns */
  }
}

@media (min-width: 1024px) {
  .grid {
    grid-template-columns: repeat(3, 1fr);  /* desktop: 3 columns */
  }
}
```

### Breakpoint Strategy

| Name | Width | Target |
|------|-------|--------|
| Base | 0+ | Mobile portrait |
| `sm` | 640px | Mobile landscape / small tablet |
| `md` | 768px | Tablet portrait |
| `lg` | 1024px | Tablet landscape / small desktop |
| `xl` | 1280px | Desktop |
| `2xl` | 1536px | Large desktop |

## R3 — Class Naming Convention

Pick one convention and apply it everywhere. Options by framework:

| Approach | Pattern | Example |
|----------|---------|---------|
| **CSS Modules** | `.camelCase` | `.submitButton { }` → `styles.submitButton` |
| **Tailwind** | Utility classes | `className="flex items-center gap-2"` |
| **BEM** | `.block__element--modifier` | `.card__title--large` |
| **CSS-in-JS** | Auto-generated | Library handles it |

### Rules That Apply To All Approaches

- Names describe **what** the element is, not **how** it looks
- No `blue-box`, `left-column`, `big-font` — these break when the design changes
- Prefer `sidebar`, `main-content`, `error-message`, `primary-action`

```css
/* ❌ Visual-based names */
.red-alert { background: blue; }   /* Wait, what? */
.big-text { font-size: 14px; }     /* That's not big */

/* ✅ Purpose-based names */
.error-banner { background: blue; }          {/* "We decided blue for errors" — design choice, clear */}
.body-text { font-size: 14px; }              {/* "Body text is 14px" — semantic */}
```

## R4 — Layout Strategy

| Pattern | When | CSS |
|---------|------|-----|
| Single column | Simple pages | Block layout (default) |
| 2D grid | Dashboards, card grids, complex pages | `display: grid` + `grid-template-areas` |
| 1D row | Navigation bars, toolbars, button groups | `display: flex` |
| 1D column | Sidebars, stacked sections | `display: flex` + `flex-direction: column` |
| Centered content | Page-level container | `max-width` + `margin-inline: auto` |
| Responsive grid | Cards, lists | `grid-template-columns: repeat(auto-fill, minmax(300px, 1fr))` |

## R5 — CSS Custom Properties Patterns

```css
/* ✅ Scoped overrides (component-level tokens) */
.card {
  --card-padding: var(--spacing-md);
  --card-bg: var(--color-surface);

  padding: var(--card-padding);
  background: var(--card-bg);
}

/* ✅ Dark theme via cascade */
:root { --color-bg: white; --color-text: #1a1a1a; }
[data-theme="dark"] { --color-bg: #1a1a1a; --color-text: #f0f0f0; }

/* ✅ Don't create impossible toggles */
/* ❌ Never: */
.light-colors { --color-bg: white; }
.dark-colors { --color-bg: black; }
/* Use data-theme on <html>, not class overrides everywhere */
```

## R6 — CSS Specificity Management

| Rule | Why |
|------|-----|
| No `!important` except for utility overrides (`.sr-only`, error states) | Creates hard-to-debug specificity battles |
| No ID selectors in CSS | Mixing IDs and classes creates confusing specificity |
| Keep specificity flat | One class per element — avoid `.nav .list .item a` |
| Use `:where()` to zero-out specificity for resets | `:where(.btn) { }` has 0 specificity |

```css
/* ❌ Deep nesting with BEM — unnecessary specificity */
.card { }
.card .card__header { }
.card .card__header .card__title { }

/* ✅ Flat, same specificity */
.card { }
.card__header { }
.card__title { }
```

## R7 — Dark Mode Strategy

```css
:root {
  --color-bg: #ffffff;
  --color-text: #1a1a1a;
  --color-surface: #f5f5f5;
  --color-border: #e0e0e0;
}

[data-theme="dark"] {
  --color-bg: #1a1a1a;
  --color-text: #e0e0e0;
  --color-surface: #2a2a2a;
  --color-border: #404040;
}

/* Semantic color usage */
body {
  background: var(--color-bg);
  color: var(--color-text);
}
```

## R8 — File Organization

```
styles/
├── tokens.css                 ← Design tokens (CSS custom properties)
├── reset.css                  ← CSS reset / normalize
├── global.css                 ← Base styles (body, headings, links)
├── utilities.css              ← Utility classes (.sr-only, .scrollbar-hide)
├── components/                ← One file per component
│   ├── button.css
│   ├── card.css
│   └── modal.css
└── pages/                     ← Page-specific styles (rare — prefer component styles)
    └── dashboard.css
```

**Exceptions:** Colocated styles (CSS Modules, styled-components, Tailwind inline) are preferred. The above is for frameworks that still use separate CSS files.
