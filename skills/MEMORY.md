# Memory Skill

> How to manage project memory effectively.
> Loaded by the MEMORY SCRIBE agent and the Brain.

---

## When to Use

After any significant work phase, before ending a session, or when making an architecture decision.

## What Is Memory?

Memory is the project's persistent knowledge base. It is not a log — it is indexed, structured, queryable, and lives in the project's `.brain/memory/` + `.brain/knowledge/` directories.

## Memory Stores

### Decisions (`memory/decisions/`)

Every architecture decision gets its own file. This is the most important memory store — it answers "why did we do it this way?"

```
memory/decisions/2026-07-10-use-service-layer.md
```

**Write when:** You make any choice with alternatives.
**Schema:** `{ decision, context, options, chosen, rationale, date }`

### Lessons (`memory/lessons/`)

Things the system learned while working — pitfalls, patterns, surprises.

```
memory/lessons/2026-07-10-query-builder-n-plus-one.md
```

**Write when:** You discover something that will be useful next time.
**Schema:** `{ what, why, impact, files, related }`

### Architecture (`knowledge/` + `context/`)

Current system architecture. This is updated, not appended — it reflects the *current* state.
Filed by purpose under `.brain/knowledge/<purpose>/` (+ current facts in `.brain/context/`).

```
knowledge/architecture/component-name.md
```

**Write when:** A component is created, renamed, removed, or its responsibilities change.
**Schema:** `{ component, responsibility, dependsOn, interfaces, notes }`

### Sessions (`memory/sessions/`)

What happened in each work session. Useful for resuming interrupted work.

```
memory/sessions/2026-07-10-implement-user-auth.md
```

**Write when:** Any session ends or pauses.
**Schema:** `{ goal, outcome, filesChanged, openQuestions, nextSteps }`

### Business (`memory/business/`)

Domain knowledge — business rules, glossary terms, processes.

```
memory/business/two-factor-authentication.md
```

**Write when:** You learn a business rule or domain concept.
**Schema:** `{ term, definition, source, related }`

## Memory Rules

1. **Read before write.** Always check existing memory before writing. You might find you already made this decision.
2. **Link related memories.** Cross-reference between stores. "See also: memory/decisions/2026-07-01-auth-system.md"
3. **One file per unit.** A decision gets one file. A component gets one file. A lesson gets one file.
4. **Date-prefix everything.** Files start with ISO date for natural sorting.
5. **Write immediately.** Don't batch memory writes. Write as soon as the work phase completes.
6. **Be concise.** A decision doesn't need paragraphs. It needs: what was chosen, why, and what was rejected.
7. **Update, don't duplicate.** If a component changes, update its architecture file — don't create a new one.
