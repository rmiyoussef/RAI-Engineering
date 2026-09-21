# Writing Feature Docs

> **Domain:** Shared — Cross-Domain
> **Use when:** User asks to document a feature ("write a doc about X", "document onboarding", "update the docs for X"), or a feature changed and its `docs/<feature>.md` needs updating.

---

## Triggers

Load this skill when the request matches any of:

- Explicit: "write a document", "document the feature", "add to docs", "update docs/X"
- Implicit: feature work just shipped and `docs/X.md` exists but lacks the new behavior
- Never for: ADRs (`memory/decisions/`), timeless how-things-work (`knowledge/`), one-off plans (`plans/`)

## Decide First: Create, Update, or Read

| Situation | Action |
|-----------|--------|
| No `docs/X.md`, user wants a document | CREATE from `_TEMPLATE.md` |
| `docs/X.md` exists, feature gained behavior | UPDATE in place (merge, never rewrite) |
| `docs/X.md` exists, feature work starting | READ only — no doc edit until behavior actually changes |
| Two files cover one feature | MERGE into the older file, delete the duplicate, log in § Changelog |

## Workflow

### 1. Locate

- Target file is always `docs/<feature>.md` (lowercase, hyphenated). `onboarding` ⇒ `docs/onboarding.md`.
- Read `docs/README.md` rules + `docs/_TEMPLATE.md` section order first.
- Read the existing file fully when updating. Never edit blind.

### 2. Gather (evidence, not memory)

Pull facts from primary sources, newest wins on conflict:

1. Code: routes, controllers/services, models, UI components actually touched
2. Active plan + its TCs: scope, acceptance criteria, verified behavior
3. `memory/decisions|lessons`: why it was built this way, what broke before
4. `knowledge/`: only link it, never paste it

No source ⇒ write nothing. Mark unknowns `_(unverified)_` rather than inventing.

### 3. Write / Merge

- CREATE: copy `_TEMPLATE.md`, fill every section, drop only with a Changelog note saying why.
- UPDATE: surgical edits — append flows, extend tables, add gotchas, prepend Changelog entry. Preserve existing prose that still holds; fix prose that code disproves.
- Keep template section order always. One fact in exactly one place; cross-feature facts become links (`See docs/billing.md § Refunds`).
- Voice: fragments OK, 3–5 sentence Overview cap, tables for API/data, numbered steps for flows.
- Every behavior claim names its source: file path, plan ID, or TC ref.

### 4. Organize check

Before finishing, verify the file still reads as one coherent doc:

- [ ] Sections in template order, no duplicates, no stale claims
- [ ] § Links lists plan IDs, TC refs, decisions, related `docs/` files
- [ ] § Changelog prepended newest-first (date, change, why + ref)
- [ ] `**Last verified**` date + ref refreshed
- [ ] No content pasted from `knowledge/` or `memory/` — links only

## Anti-patterns (rejected)

| Excuse | Counter |
|--------|---------|
| "Rewrite the whole file, cleaner" | Rewrites destroy history. Merge surgically. |
| "Copy the knowledge page in for context" | Link it. Duplicates rot. |
| "Docs after release, later" | Doc update ships in the same change or the behavior is unverified. |
| "New folder per feature" | One file per feature. Folders never. |

## Done means

File exists at `docs/<feature>.md`, follows template order, claims sourced, links + changelog current, checklist above all green.
