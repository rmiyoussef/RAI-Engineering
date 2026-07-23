# Performance Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Core Web Vitals, bundle optimization, rendering performance.

---

## R1 — Core Web Vitals Targets

| Metric | Target | What it measures |
|--------|--------|-----------------|
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | Perceived load speed |
| **INP** (Interaction to Next Paint) | ≤ 200ms | Responsiveness |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | Visual stability |
| **TBT** (Total Blocking Time) | ≤ 200ms | Main thread availability |
| **FCP** (First Contentful Paint) | ≤ 1.8s | First content shown |

## R2 — Bundle Size Rules

| Asset | Max size (gzip) | Action if exceeded |
|-------|-----------------|--------------------|
| Initial JS bundle | 100 KB | Code-split, lazy load |
| Initial CSS bundle | 30 KB | Purge unused styles |
| Font file (WOFF2) | 30 KB | Subset or use system font stack |
| Hero image (LCP) | 100 KB | WebP/AVIF, responsive sizes, CDN |
| Route chunk (lazy) | 50 KB | Further split |
| Third-party script | 30 KB | Defer, load on interaction |

## R3 — Image Optimization

Every `<img>` must have:
- `loading="lazy"` for below-the-fold images
- `width` and `height` attributes (prevents CLS, even with CSS)
- `alt` text for accessibility
- Responsive `srcset` and `sizes` for responsive images
- WebP or AVIF format with fallbacks

```html
<!-- Before (CLS risk, no optimization) -->
<img src="/photo.jpg" alt="Description" />

<!-- After (no CLS, optimized, accessible) -->
<img
  src="/photo.jpg"
  srcset="/photo-400.webp 400w, /photo-800.webp 800w, /photo-1200.webp 1200w"
  sizes="(max-width: 600px) 100vw, 50vw"
  width="800"
  height="600"
  loading="lazy"
  decoding="async"
  alt="A scenic mountain landscape at sunset"
/>
```

## R4 — Font Optimization

- Use `font-display: swap` or `font-display: optional` to prevent invisible text (FOIT)
- Prefer WOFF2 format (30% smaller than WOFF)
- Subset fonts to the character ranges you need (latins + common punctuation)
- Preload the primary font with `rel="preload"` and `crossorigin`
- Self-host fonts (don't rely on Google Fonts CDN for production)
- Use the `size-adjust` descriptor to prevent layout shift during font swap

```html
<link
  rel="preload"
  href="/fonts/inter-var.woff2"
  as="font"
  type="font/woff2"
  crossorigin
/>
```

## R5 — Lazy Loading Strategy

| Pattern | When | Technique |
|---------|------|-----------|
| Route-based | Navigation boundaries | Dynamic imports per route |
| Component-based | Heavy components below the fold | `React.lazy()` + `<Suspense>` |
| Visibility-based | Modals, offscreen content | Intersection Observer |
| Interaction-based | Feature the user hasn't clicked yet | `pointerenter` event preload |

```typescript
// Route-based lazy loading
const Dashboard = lazy(() => import('./routes/Dashboard'));
const Settings = lazy(() => import('./routes/Settings'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

## R6 — Rendering Performance

| Problem | Solution |
|---------|----------|
| Large lists (1000+ items) | Virtualization (TanStack Virtual, react-window) |
| Frequent re-renders of expensive tree | `React.memo` + `useCallback` on stable references |
| Deep context updates | Split context by concern, or use external store |
| Expensive calculations | `useMemo` + Web Workers for CPU-heavy work |
| Animation jank | `transform` + `opacity` only (GPU-composited), never `width/height/top/left` |

## R7 — Third-Party Scripts

- Load with `defer` or async
- Load analytics/ads/widgets after the main app is interactive (`requestIdleCallback` or `onLoad`)
- Audit third-party scripts regularly — each one is a risk to INP and bundle size
- Prefer `rel="preconnect"` for origins the page needs early

```html
<!-- Load non-critical scripts after interaction -->
<script>
  window.addEventListener('load', () => {
    const script = document.createElement('script');
    script.src = 'https://analytics.example.com/script.js';
    script.defer = true;
    document.head.appendChild(script);
  });
</script>
```

## R8 — CSS Performance

- Avoid expensive selectors: `* {}`, `:not()` deep nesting, `[attribute^="value"]` on large lists
- Prefer CSS `contain` to isolate layout/paint/style from the document
- Use `content-visibility: auto` for offscreen sections (auto-clips paint like an automatic lazy load)
- Animations on `transform` and `opacity` only — they run on the compositor thread
- Avoid JS-driven animations when CSS animations work

```css
/* ✅ Contain expensive sections */
.long-list-section {
  contain: content;     /* isolate layout calculation */
  content-visibility: auto;  /* skip offscreen rendering */
}

/* ✅ Composited animation only */
.panel {
  transition: transform 200ms ease, opacity 200ms ease;
}
```

## R9 — Measure Before Optimizing

Do NOT optimize until you have evidence. Always measure with:
- Lighthouse (lab data)
- Web Vitals library or `web-vitals` npm package (field data)
- Browser DevTools Performance tab
- Bundle analyzer (`vite-bundle-visualizer`, `webpack-bundle-analyzer`)

If you can't measure the improvement, don't add the complexity.
