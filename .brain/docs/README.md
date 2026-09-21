# Feature Docs (`docs/`)

> Living documentation, one file per feature. The brain reads the relevant file before touching its feature and updates it when the feature changes.

## Rule

- One feature = one file: `docs/<feature>.md` (lowercase, hyphenated: `onboarding.md`, `billing-checkout.md`).
- New work on feature `X` ⇒ read `docs/X.md` first (mandatory, per `INSTRUCTIONS.md` §1). No matching file ⇒ proceed from code, then create it via `skills/writing-docs.md` when the user asks for a document.
- New behavior on feature `X` ⇒ append/update `docs/X.md` in the same change. Docs rot is a defect.
- Never duplicate: one fact lives in exactly one feature file. Cross-feature facts link (`See docs/billing.md § Refunds`), never copy.
- Never create parallel doc systems (`notes/`, `feature-docs/`, plan-side docs). Everything feature-doc lives here.

## Lifecycle

```
request about feature X → read docs/X.md (+ code/knowledge/memory)
  → work → update docs/X.md (new section or § Changelog entry)
  → future work re-reads the updated file
```

## File anatomy

Every `docs/<feature>.md` follows `docs/_TEMPLATE.md`: Overview, Status, Flows, API & Data, UI, Edge cases & Gotchas, Links (plans, TCs, decisions, knowledge), Changelog. Sections stay in template order; omit only with reason noted in Changelog.

## Naming collisions

Two names for one feature ⇒ keep the older file, merge the newer in, delete the duplicate, note it in Changelog. Never keep both.

## Ownership

- `docs/README.md` + `docs/_TEMPLATE.md`: system-managed (update.sh may refresh).
- `docs/<feature>.md`: user-owned. update.sh never touches these files.
