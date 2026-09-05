# Research

> **Source:** Adapted from mattpocock/skills (research)
> **Domain:** Shared — Cross-Domain
> **Use when:** Investigating a question against high-trust primary sources, gathering docs/API facts, or delegating reading legwork.

---

## Overview

When you want a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent — use this skill.

## Process

1. **Spin up a background agent** dedicated to the research task
2. **Investigate using primary sources** — not a secondary write-up of them
3. **Trace each claim** back to its owning source
4. **Write findings** to a single Markdown file, citing each claim's source
5. **Save the file** following the repo's existing notes convention

## Citation Rules

- Every claim must have a source
- Prefer official documentation (see source-driven-development skill)
- Include full URLs with anchors
- Version-specific docs preferred over "latest"
- Distinguish between "confirmed by docs" and "inferred from behavior"

## What Not To Do

- Don't rely on outdated training data for current API information
- Don't cite blog posts or Stack Overflow as primary sources
- Don't mix verified and unverified claims without labeling them
- Don't deliver raw research — synthesize into actionable findings

## Output Format

```markdown
# Research: [Topic]

## Summary
[2-3 sentence overview of findings]

## Findings
### Finding 1: [Claim]
- **Source:** [URL with anchor]
- **Evidence:** [Relevant quote or data]
- **Confidence:** High / Medium / Low

### Finding 2: [Claim]
...

## Open Questions
- [Any unresolved aspects]

## Sources
- [Full URL list]
```
