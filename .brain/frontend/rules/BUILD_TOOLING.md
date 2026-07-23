# Build Tooling & Project Configuration Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Consistent, maintainable, fast build pipelines.

---

## R1 — Lint Before Build

CI pipeline order:
1. TypeScript check (`tsc --noEmit`)
2. Lint (ESLint)
3. Format check (Prettier — `--check` mode)
4. Unit/Integration tests (Vitest/Jest)
5. Build (Vite/Webpack/Next)
6. Bundle analysis (warn on size regressions)
7. E2E tests (Playwright/Cypress)

```json
// package.json scripts
{
  "check": "tsc --noEmit",
  "lint": "eslint . --max-warnings 0",
  "format": "prettier --check .",
  "test": "vitest run",
  "test:coverage": "vitest run --coverage",
  "build": "vite build",
  "analyze": "vite-bundle-visualizer",
  "ci": "npm run check && npm run lint && npm run format && npm run test && npm run build"
}
```

## R2 — TypeScript Configuration

```json
// tsconfig.json — Recommended strict settings
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true
  }
}
```

## R3 — Environment Variables Convention

```typescript
// ✅ Expose env vars through a single source of truth
// src/config/env.ts
export const env = {
  apiUrl: import.meta.env.VITE_API_URL as string,
  appName: import.meta.env.VITE_APP_NAME as string,
  isDev: import.meta.env.DEV,
  isProd: import.meta.env.PROD,
} as const;

// Validate on startup
if (!env.apiUrl) throw new Error('VITE_API_URL is required');
```

## R4 — Code Splitting Points

| Boundary | Strategy | Example |
|----------|----------|---------|
| Routes | Dynamic import per route | `const Dashboard = lazy(() => import('./Dashboard'))` |
| Heavy libraries | Dynamic import on interaction | `const pdfExport = await import('pdf-lib')` |
| Modals/Drawers | Lazy load content | `const UserForm = lazy(() => import('./UserForm'))` |
| Feature flags | Conditionally import unused features | Not needed if tree-shakeable |

## R5 — File Naming Conventions

| File type | Convention | Example |
|-----------|-----------|---------|
| Component | PascalCase | `UserProfile.tsx` |
| Hook | camelCase with `use` prefix | `useUserProfile.ts` |
| Utility | camelCase | `formatDate.ts` |
| Service | camelCase | `apiClient.ts` |
| Context | PascalCase with `Provider` suffix | `AuthProvider.tsx` |
| Test | `*.test.tsx` | `UserProfile.test.tsx` |
| Type definitions | `.types.ts` | `UserProfile.types.ts` |
| CSS Module | `.module.css` | `UserProfile.module.css` |
| Story | `.stories.tsx` | `Button.stories.tsx` |

## R6 — Import Rules

```typescript
// ✅ Absolute imports preferred
import { Button } from '@/components/ui/Button';
import { useUser } from '@/hooks/useUser';
import { formatDate } from '@/utils/date';

// ❌ Deep relative imports
import { Button } from '../../../components/ui/Button';

// ✅ Barrel files: only for public API surface
// components/ui/index.ts
export { Button } from './Button';
export { Card } from './Card';
export { Modal } from './Modal';

// ❌ Barrel files that re-export everything
// components/index.ts — don't do this (causes import cycles, slows tree-shaking)
```

## R7 — Bundle Analysis

| Tool | Purpose |
|------|---------|
| `vite-bundle-visualizer` | Vite project bundle size visualization |
| `webpack-bundle-analyzer` | Webpack project bundle size visualization |
| `lighthouse-ci` | Performance budget enforcement in CI |
| `size-limit` | Prevent bundle size regressions in PRs |

```json
// Example size-limit config
{
  "size-limit": [
    {
      "name": "Main JS bundle",
      "path": "dist/assets/main-*.js",
      "limit": "100 KB"
    },
    {
      "name": "Vendor JS bundle",
      "path": "dist/assets/vendor-*.js",
      "limit": "50 KB"
    }
  ]
}
```

## R8 — Dead Code Elimination

- Use TypeScript `verbatimModuleSyntax` to eliminate unused imports at build time
- Remove commented-out code immediately (that's what git history is for)
- Run `knip` or `depcheck` regularly to find unused files, exports, and dependencies
- Feature flags should be compile-time constants, not runtime checks

```typescript
// ✅ Compile-time feature flags (tree-shaken)
const ENABLE_BETA = import.meta.env.VITE_ENABLE_BETA === 'true';
if (ENABLE_BETA) { /* dead code if false */ }
```

## R9 — Pre-commit Hooks

Use lint-staged at minimum. Only run checks on staged files.

```json
// lint-staged.config.js
{
  "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{css,scss}": ["prettier --write"],
  "*.{json,md}": ["prettier --write"]
}
```
