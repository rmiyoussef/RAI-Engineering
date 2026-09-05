# Source-Driven Development

> **Source:** Adapted from addyosmani (source-driven-development)
> **Domain:** Shared — Cross-Domain
> **Use when:** Following official documentation instead of relying on training data or outdated patterns.

---

## Overview

Ground implementation decisions in official documentation. Training data goes stale, APIs get deprecated. Source-driven development avoids this by always citing authoritative sources.

## When to Use

| Use | Don't Use |
|-----|-----------|
| Building boilerplate from framework docs | Simple logic (variable renaming) |
| Following current best practices | When speed is prioritized over correctness |
| Reviewing framework code you're unsure about | |
| Any task where correctness matters | |

## The Process (4 Steps)

### 1. Detect the Stack
Read dependency files (package.json, composer.json, go.mod, etc.) to determine exact versions.

### 2. Fetch Official Docs
Priority hierarchy:
1. **Official docs** (react.dev, docs.djangoproject.com, laravel.com/docs) ← Always prefer
2. **MDN** (for web platform APIs)
3. **caniuse.com** (for browser compatibility)
4. **Never** Stack Overflow or blog posts without verifying against official docs

### 3. Implement Following Documented Patterns
- Follow the official patterns exactly
- Surface conflicts between docs and existing code
- Don't mix patterns from different major versions

### 4. Cite Sources
- Include full URLs with anchors
- Reference the relevant passages
- Link to version-specific docs (not latest)

## Common Rationalizations (Rejected)

| Excuse | Counter |
|--------|---------|
| "I know this API" | Confidence is not evidence. Check the docs. |
| "Fetching docs takes too long" | Hallucinating an API wastes more time than fetching docs. |
| "The blog post looks authoritative" | Verify against official docs. |

## Verification Checklist

- [ ] Version-appropriate docs checked
- [ ] Official documentation cited (not blog posts)
- [ ] No deprecated APIs used
- [ ] Conflicts between docs and existing code surfaced
