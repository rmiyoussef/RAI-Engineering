# Forms & Input Rules

> **Loaded by:** EXECUTOR agent, REVIEWER agent
> **Domain:** Frontend — framework-agnostic
> **Purpose:** Accessible, usable, validated form experiences.

---

## R1 — Form UX Standards

| Element | Requirement |
|---------|-------------|
| Labels | Every input has a visible `<label>` |
| Required indicators | Show `*` on required fields, include `aria-required="true"` |
| Placeholder text | Never use as a replacement for labels. Placeholders disappear on input |
| Error position | Error appears BELOW the field, not above or in a tooltip |
| Error timing | Validate when user leaves the field (blur), not on every keystroke — except async validation (username availability) |
| Success feedback | Show success indicator only after async operations (saved, uploaded) |
| Submit button | Disabled only when actively submitting (show spinner). Don't disable for validation |
| Autofocus | Focus the first input on page load. Don't autofocus on mobile modals (virtual keyboard) |

## R2 — Validation Strategy

```typescript
// Validation layers (in order)
interface ValidationLayer {
  type: 'schema' | 'business' | 'async';
  validate: (values: FormValues) => Record<string, string>;
}

// 1. Schema validation (type, format, required)
// 2. Business logic validation (password matches confirmation)
// 3. Async validation (username taken, email exists)
```

```typescript
// ✅ Validation with a schema library (Zod)
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email('Must be a valid email'),
  age: z.number().min(18, 'Must be 18 or older').max(120),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
}).refine(data => data.password === data.confirmPassword, {
  message: 'Passwords must match',
  path: ['confirmPassword'],
});
```

## R3 — Form Library Over Raw State

| Situation | Use |
|-----------|-----|
| Simple form (1-3 fields, no validation) | Raw `useState` |
| Complex form (4+ fields, validation) | Form library (React Hook Form, Formik, Mantine Form) |
| Dynamic fields (add/remove array of items) | Form library with field array support |
| Wizard/multi-step | Form library with persistent state across steps |

```typescript
// ✅ React Hook Form — minimal re-renders
const { register, handleSubmit, formState: { errors } } = useForm({
  resolver: zodResolver(schema)
});

// ✅ Mantine Form — integrated with Mantine components
const form = useForm({
  initialValues: { email: '', name: '' },
  validate: zodResolver(schema),
});
```

## R4 — Controlled vs Uncontrolled

| Approach | When | Pros |
|----------|------|------|
| **Uncontrolled** (default) | Most forms | Better performance, less re-renders, simpler |
| **Controlled** | When you need to react to value changes (preview, conditional fields) | Real-time value access |

```typescript
// ✅ Uncontrolled — performance-first
const { register } = useForm(); // default

// ✅ Controlled — real-time reactivity
const form = useForm({ mode: 'controlled' });
watch(form.values().email); // react to changes
```

## R5 — Input Types and Autocomplete

Always set the correct `type` and `autoComplete` attributes:

| Input | `type` | `autoComplete` |
|-------|--------|----------------|
| Name | `text` | `name` |
| Email | `email` | `email` |
| Password | `password` | `current-password` / `new-password` |
| Phone | `tel` | `tel` |
| URL | `url` | `url` |
| Number | `number` | (varies) |
| Date | `date` | (varies) |
| Search | `search` | (varies) |

```typescript
// ✅ Complete form with autocomplete
<input
  type="email"
  autoComplete="email"
  aria-label="Email address"
  required
/>

<input
  type="password"
  autoComplete="new-password" // "current-password" for login
  aria-label="New password"
  minLength={8}
  required
/>
```

## R6 — Form Submission

```typescript
// ✅ Handle all states
async function handleSubmit(values: FormValues) {
  try {
    setIsSubmitting(true);
    await submitToApi(values);
    showSuccess('Saved successfully');
    resetForm();
  } catch (error) {
    if (error instanceof ApiError && error.status === 422) {
      setServerErrors(error.details?.fields || {});
    } else {
      showError('Submission failed. Please try again.');
    }
  } finally {
    setIsSubmitting(false);
  }
}

// Never:
<form onSubmit={handleSubmit}> {/* missing preventDefault */}
```

## R7 — Confirmation Patterns

| Action | Confirmation |
|--------|-------------|
| Delete | Modal: "Delete [item]? This cannot be undone." + Confirm/Cancel |
| Discard changes | Modal: "You have unsaved changes. Discard?" + Keep editing/Discard |
| Submit payment | Button text: "Pay $49.99" (include amount, not just "Submit") |
| Irreversible action | Modal + checkbox: "I understand this action cannot be undone" + type the name |

## R8 — Keyboard Support

| Key | Action |
|-----|--------|
| Enter | Submit form (from any input) |
| Tab | Move to next field |
| Shift+Tab | Move to previous field |
| Escape | Close: dropdown, modal, suggestion list |

## R9 — Number and Currency Inputs

```typescript
// ❌ Native number input for IDs/codes
<input type="number" aria-label="Zip code" />
// Issues: no leading zeros, shows spinners, step arrows confusing

// ✅ Text input with inputmode
<input
  type="text"
  inputMode="numeric"     // shows numeric keyboard on mobile
  pattern="[0-9]*"        // desktop validation
  aria-label="Zip code"
/>

// ✅ Currency input
<input
  type="text"
  inputMode="decimal"
  aria-label="Amount"
  prefix="$"
  onChange={(e) => {
    const raw = e.target.value.replace(/[^0-9.]/g, '');
    // Handle currency formatting
  }}
/>
```
