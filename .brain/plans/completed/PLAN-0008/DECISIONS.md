# Decisions PLAN-0008

- D1 Prepend not append. Bootstrap first ensures Opencode context priority. User content preserved verbatim after blank line.
- D2 Marker `.brain/INSTRUCTIONS.md` substring. Stable across caveman variants, avoids brittle full-line match.
- D3 No CLAUDE.md chaining. Parallel thin adapters per ARCHITECTURE.md §14. AGENTS.md points direct at .brain/.
- D4 Missing-file fallback chain local copy, fetched, minimal bootstrap. Remote fresh installs covered without inventing vendor config.
