# Testing Rules

> **Loaded by:** TESTER agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Reliable, fast, meaningful frontend tests.

---

## R1 — Testing Trophy (Not the Pyramid)

```
         ╱  E2E (Cypress/Playwright) ╲        ← Few: critical user flows
        ╱  Integration (Testing Library) ╲    ← Most: user interactions + API
       ╱  Component (RTL/Vitest) ╲           ← Many: component rendering, props
      ╱  Unit (Vitest/Jest) ╲               ← Some: pure functions, utils, hooks
     ╱  Static (TypeScript, ESLint) ╲       ← All: type-checking catches most bugs
```

Write MOST tests at the integration level — test components as users use them.

## R2 — What to Test

| Test | Coverage | Priority |
|------|----------|----------|
| User flows | Critical paths (login, checkout, search) | 🔴 Critical |
| Component rendering | Props → correct output | 🟡 High |
| Edge cases | Empty, error, loading states | 🟡 High |
| Accessibility | aXe audit in CI | 🟡 High |
| Pure functions | Utils, formatters, validators | 🟢 Medium |
| Event handlers | Click, submit, focus, blur | 🟢 Medium |
| Animation | Visual regression only (critical) | ⚪ Low |
| CSS styles | Snapshot tests are discouraged | ⚪ Low |
| Internal implementation | Never test — test behavior | ⛔ Not needed |

## R3 — Testing Library Principles

```typescript
// ✅ Query elements the way users find them
screen.getByRole('button', { name: /submit/i });
screen.getByLabelText('Email address');
screen.getByPlaceholderText('Enter your name');
screen.getByText(/no results found/i);

// ❌ Query by implementation details
screen.getByTestId('submit-button');  // last resort
screen.getByClassName('btn-primary');  // ❌ breaks on CSS change
wrapper.find('button');  // ❌ breaks on structure change
```

**Priority order:** `getByRole` → `getByLabelText` → `getByPlaceholderText` → `getByText` → `getByTestId` (last resort)

## R4 — Async Test Patterns

```typescript
// ✅ Wait for elements to appear
test('loads and displays user', async () => {
  render(<UserProfile userId="1" />);

  // Initially shows loading
  expect(screen.getByLabelText('Loading user profile')).toBeInTheDocument();

  // Wait for user to appear
  const user = await screen.findByRole('heading', { name: /john doe/i });
  expect(user).toBeInTheDocument();
});

// ✅ Wait for loading to disappear
test('shows error on failure', async () => {
  render(<UserProfile userId="1" />);

  await waitForElementToBeRemoved(() =>
    screen.getByLabelText('Loading user profile')
  );

  expect(screen.getByRole('alert')).toHaveTextContent(/failed/i);
});
```

## R5 — Mocking Strategy

| What | How to mock |
|------|-------------|
| API calls | `msw` (Mock Service Worker) — intercepts at network level |
| Window APIs | Jest/Vitest spies — `vi.spyOn(window, 'fetch')` |
| Third-party components | Mock at module level: `vi.mock('recharts', ...)` |
| Browser APIs (localStorage, clipboard) | `vi.stubGlobal()` or standard polyfills |
| Router | Wrapper component with `MemoryRouter` |

```typescript
// ✅ MSW — best for API mocking
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.get('/api/users/1', () => {
    return HttpResponse.json({ data: { id: 1, name: 'John' } });
  }),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## R6 — Component Test Structure

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('SearchBox', () => {
  const defaultProps = {
    onSearch: vi.fn(),
    placeholder: 'Search items...',
  };

  it('renders input with placeholder', () => {
    render(<SearchBox {...defaultProps} />);
    expect(screen.getByPlaceholderText('Search items...')).toBeInTheDocument();
  });

  it('calls onSearch when typing', async () => {
    const user = userEvent.setup();
    render(<SearchBox {...defaultProps} />);

    await user.type(screen.getByRole('textbox'), 'hello');
    expect(defaultProps.onSearch).toHaveBeenCalledWith('hello');
  });

  it('shows clear button when input has value', async () => {
    const user = userEvent.setup();
    render(<SearchBox {...defaultProps} />);

    const input = screen.getByRole('textbox');
    await user.type(input, 'test');

    const clearButton = screen.getByRole('button', { name: /clear/i });
    await user.click(clearButton);
    expect(input).toHaveValue('');
  });
});
```

## R7 — What NOT to Test

```typescript
// ❌ Testing implementation
test('calls useState setter', () => { /* internal state setter */ });
test('renders 3 divs', () => { /* structural detail */ });
test('has class name primary', () => { /* CSS detail */ });
test('matches snapshot', () => { /* brittle, meaningless updates */ });

// ✅ Test behavior
test('shows error when email is invalid');
test('submits form when all fields are valid');
test('navigates to dashboard on successful login');
```

## R8 — Coverage Targets

| Threshold | Minimum | Files |
|-----------|---------|-------|
| Line coverage | 80% | Components, utils, hooks |
| Branch coverage | 75% | Conditionals, ternaries |
| Critical paths | 100% | Auth, checkout, data submission |

**No coverage gate on E2E tests** — they test too few paths for percentage to be meaningful.

## R9 — E2E Testing Rules

| Rule | Reason |
|------|--------|
| Test critical user journeys only (login, purchase, search) | E2E is slow and flaky |
| Make tests independent | One failing test shouldn't cascade |
| Use `data-testid` for interactive elements (last resort, but acceptable in E2E) | E2E needs selectors that survive refactoring |
| Set up test data via API, not UI | Faster setup, fewer steps to fail |
| Assert on visible UI, not network state | Test what the user sees |

```typescript
// Playwright example
test('user can search and see results', async ({ page }) => {
  await page.goto('/');
  await page.getByPlaceholder('Search...').fill('macbook');
  await page.getByRole('button', { name: 'Search' }).click();
  await expect(page.getByText('Apple MacBook Pro')).toBeVisible();
});
```
