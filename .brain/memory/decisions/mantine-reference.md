---
name: mantine-frontend-reference
description: Mantine UI reference added to frontend domain for LLM-assisted development
metadata:
  type: project
  domain: frontend
---

Mantine UI reference files were added to `.brain/frontend/` so the AI can answer Mantine component questions accurately.

**What was added:**
- `.brain/frontend/reference/mantine.md` — Integration guide, MCP server setup, key concepts, best practices
- `.brain/frontend/skills/mantine.md` — Full component selection table (100+ components), form patterns, theming, rules
- `.brain/frontend/INDEX.md` — Index pointing to all frontend skills + reference
- Updated `.brain/frontend/README.md` — Skill count from 6 → 7
- Updated `.brain/INDEX.md` — Added reference/ directory, Mantine skill, Mantine reference quick link
- Updated `CLAUDE.md` skill trigger table — Mantine tasks trigger `mantine.md` skill

**Sources:**
- Mantine LLM docs: `https://mantine.dev/llms-full.txt` (~4MB)
- MCP Server: `@mantine/mcp-server` (npm) — tools for `list_items`, `get_item_doc`, `get_item_props`, `search_docs`
- AI Skills: `github.com/mantinedev/skills` — combobox, forms, custom components

**Why:** Frontend needs authoritative Mantine knowledge for React UI tasks, avoiding hallucinated component APIs.

**How to apply:** When a task involves Mantine (detected by imports, config, or `@mantine/` references), load `.brain/frontend/skills/mantine.md` and check `.brain/frontend/reference/mantine.md` for integration setup. For real-time doc queries during a session, suggest setting up the MCP server.
