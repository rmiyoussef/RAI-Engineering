# Accessibility Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** WCAG 2.2 AA compliance as the minimum bar. AAA where possible.

---

## R1 — Semantic HTML First

Use native HTML elements before custom components. Buttons for actions, links for navigation, headings for structure.

```html
<!-- ❌ Not semantic -->
<div onclick="submit()" role="button" tabindex="0">Submit</div>
<span class="heading">Page Title</span>

<!-- ✅ Semantic -->
<button type="submit">Submit</button>
<h1>Page Title</h1>
```

| Pattern | Use | Don't use |
|---------|-----|-----------|
| Action | `<button>` | `<div onclick>` with `role="button"` |
| Navigation | `<a href="...">` | `<span onclick="navigate()">` |
| Heading | `<h1>`-`<h6>` | `<div class="heading-1">` |
| List | `<ul>`/`<ol>` + `<li>` | `<div>` with bullets |
| Group | `<fieldset>` + `<legend>` | `<div>` for form sections |
| Landmark | `<nav>`, `<main>`, `<aside>` | Generic divs |

## R2 — Keyboard Navigation

Every interactive element must be reachable and operable via keyboard alone.

| Interaction | Keyboard method |
|-------------|----------------|
| Click/Activate | Enter or Space |
| Focus next | Tab |
| Focus previous | Shift+Tab |
| Close modal/drawer | Escape |
| Select in list | Arrow keys |
| Navigate tabs | Arrow keys (Left/Right) |

```typescript
// ✅ Modal keyboard handling
function Modal({ onClose, children }) {
  useEffect(() => {
    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
    }
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  // Focus trap: keep focus inside modal when Tab is pressed
  // Return focus to trigger element on close
}
```

## R3 — Focus Management

| Situation | Focus target |
|-----------|-------------|
| Page navigates | `<h1>` of new page |
| Modal opens | First focusable element inside modal |
| Modal closes | Element that opened the modal |
| Error in form | First field with error (or error summary) |
| Dynamic content added | Newly added interactive element |
| Menu closes | Trigger element |

```typescript
// Single-page transition — focus the new heading
useEffect(() => {
  headingRef.current?.focus();
}, [route]);
```

## R4 — Screen Reader Support

| Element | Requirement |
|---------|-------------|
| Icon button | `aria-label="Action description"` |
| Loading region | `aria-busy="true"` + `role="region"` and `aria-label` |
| Dynamic content | `aria-live="polite"` for non-critical updates, `aria-live="assertive"` for errors |
| Progress | `role="progressbar"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax` |
| Error message | `role="alert"` linked to input with `aria-describedby` |
| Tab panel | `role="tablist"`, `role="tab"`, `role="tabpanel"` with `aria-controls` and `aria-selected` |
| Expandable | `aria-expanded="true/false"` on toggle, `aria-controls` pointing to panel id |
| Description | `aria-describedby` linking to a visible help text element |

```html
<!-- Loading region -->
<div aria-busy="true" aria-label="Loading search results">
  <Spinner />
</div>

<!-- Error with field association -->
<label for="email">Email</label>
<input
  id="email"
  type="email"
  aria-describedby="email-error"
  aria-invalid="true"
/>
<span id="email-error" role="alert">Please enter a valid email address</span>
```

## R5 — Color and Contrast

| Requirement | Ratio | Applies to |
|-------------|-------|------------|
| Normal text AA | 4.5:1 | Body text, placeholders, disabled text |
| Large text AA (18px+ or 14px bold+) | 3:1 | Headings, large labels |
| AAA (enhanced) | 7:1 | All text where possible |
| UI components | 3:1 | Input borders, focus indicators, icons |

- Never use color as the ONLY way to convey information
- Focus indicators must be visible (minimum 2px offset or 3px solid outline)
- Test all color combinations with a contrast checker
- Support forced colors mode (`prefers-contrast: more`)

## R6 — Motion and Reduced Motion

```css
/* Respect user's system settings */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

- All animations must have a reduced-motion alternative
- No auto-playing video without a pause button
- No parallax effects that can't be disabled
- No infinite animations without user control

## R7 — Form Accessibility

```html
<form aria-labelledby="form-heading">
  <h2 id="form-heading">Contact Us</h2>

  <fieldset>
    <legend>Personal Information</legend>

    <label for="name">Full name</label>
    <input id="name" required aria-required="true" />

    <label for="email">Email address</label>
    <input id="email" type="email" />
    <span id="email-hint">We'll never share your email</span>
  </fieldset>

  <button type="submit">Submit</button>
</form>
```

| Rule | Why |
|------|-----|
| Every input has a `<label>` | Screen readers announce the label when the input is focused |
| Error messages linked via `aria-describedby` | Screen reader announces error after the input value |
| Required fields indicated visually AND via `aria-required` | Multiple modalities convey the same info |
| Form has `aria-labelledby` heading | Screen reader announces form purpose on focus |
| `fieldset` + `legend` groups related inputs | Helps users understand context of related fields |

## R8 — Testing for Accessibility

| Test | Tool | Frequency |
|------|------|-----------|
| Automatic audit | axe-core, Lighthouse | Every PR |
| Keyboard navigation | Manual | Every PR |
| Screen reader (VoiceOver/NVDA) | Manual | Every feature |
| Color contrast | Contrast checker, axe | Every PR |
| Zoom to 200% | Browser | Every feature |
| Reduced motion | System setting | Every animation |

## R9 — Don't Break the Default

- Don't remove `outline` on focus without providing an alternative focus style
- Don't override native scroll behavior (`scroll-behavior: smooth` globally) without testing for accessibility
- Don't disable zoom (`user-scalable=no` or `maximum-scale=1.0` is WCAG failure)
- Don't remove `:focus-visible` styles — they are required for keyboard navigation
