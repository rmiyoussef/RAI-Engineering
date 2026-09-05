# Prototype

> **Source:** Adapted from mattpocock/skills (prototype)
> **Domain:** Shared — Cross-Domain
> **Use when:** Building throwaway code that answers a question before committing to real implementation.

---

## Overview

A prototype is throwaway code that answers a question. Pick the approach based on the question:

| Question Type | Approach |
|--------------|----------|
| Logic / state model | Terminal-based (CLI app, script) |
| UI / interaction | Multiple UI variations switchable via URL param |

## Shared Rules (Both Branches)

1. **Code is throwaway** — clearly marked, located alongside real code but distinguishable
2. **A single command runs it** — no complex setup
3. **No persistence** by default — state lives in memory
4. **Skip the polish** — no tests, no abstractions, no error handling
5. **Surface state** — after every action or variant switch, show the full state
6. **Capture decisions** — validated findings become real code; commit the prototype to a throwaway branch
7. **Leave a pointer** — on the implementation issue, note the prototype branch for reference

## Process

1. **Ask the question** — "What are we trying to learn?"
2. **Pick the approach** — terminal or UI?
3. **Build the minimum** to answer the question
4. **Run it, observe, iterate** until the question is answered
5. **Decide** — was the answer "yes" (validate into real code) or "no" (discard the branch)?
6. **Clean up** — commit to throwaway branch, leave pointer, delete when no longer needed

## What a Prototype Is NOT

| NOT | It IS |
|-----|-------|
| Production code | Throwaway code |
| Tested code | Untested (intentionally) |
| Polished UI | Bare-minimum interaction |
| Production-ready data | In-memory state |
| A commit to main | A throwaway branch |
