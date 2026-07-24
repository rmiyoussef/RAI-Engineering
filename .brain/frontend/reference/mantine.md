# Mantine UI — Reference & LLM Integration

> React component library with 100+ components, hooks, theming engine.
> Source: https://mantine.dev/
> Official LLM guide: https://mantine.dev/guides/llms/

---

## Three Ways for AI to Learn Mantine

Mantine provides three distinct integration methods for AI tools:

| # | Method | Best for |
|---|--------|----------|
| 1 | **LLMs.txt** (static docs) | Any AI tool — fetch docs inline |
| 2 | **Skills Repository** | Structured prompts for specific patterns |
| 3 | **MCP Server** | Real-time doc queries during a session |

---

## 1. LLMs.txt Documentation (Static Files)

Two files regenerated with every release:

| File | URL | Size | Contents |
|------|-----|------|----------|
| **Compact index** | `https://mantine.dev/llms.txt` | Small | Index linking to per-page `.md` files under `/llms` |
| **Full dump** | `https://mantine.dev/llms-full.txt` | ~4 MB | Complete docs: Getting Started, Components (props/examples/usage), Hooks, Theming, Styles API, FAQ |

Both include: component documentation from MDX files, props tables and types, code examples and demos, Styles API documentation.

### Tool-by-Tool Integration

| Tool | How to use |
|------|------------|
| **Cursor** | `@Docs` + `https://mantine.dev/llms.txt` or MCP config |
| **Windsurf** | `@https://mantine.dev/llms.txt` or add to `.windsurfrules` |
| **ChatGPT / Claude (web)** | Mention "using Mantine v8" + reference `llms.txt` URL |
| **GitHub Copilot** | Include relevant doc snippets in comments (no external doc support) |
| **Claude Desktop** | MCP server config (recommended) |

---

## 2. Skills Repository

> Repo: https://github.com/mantinedev/skills

Three installable skills — use via `$skill-name` in prompts:

```bash
npx skills add https://github.com/mantinedev/skills --skill mantine-combobox
npx skills add https://github.com/mantinedev/skills --skill mantine-form
npx skills add https://github.com/mantinedev/skills --skill mantine-custom-components
```

| Skill | Prompt pattern | Purpose |
|-------|---------------|---------|
| `mantine-combobox` | `$mantine-combobox` | Build custom select/autocomplete/multiselect with `Combobox` |
| `mantine-form` | `$mantine-form` | Build forms with `@mantine/form`, validation, nested fields, form context |
| `mantine-custom-components` | `$mantine-custom-components` | Create custom components with factory APIs and Styles API |

---

## 3. MCP Server (`@mantine/mcp-server`)

> Experimental — real-time Mantine documentation queries via Model Context Protocol.

### Setup

```json
{
  "mcpServers": {
    "mantine": {
      "command": "npx",
      "args": ["-y", "@mantine/mcp-server"]
    }
  }
}
```

With custom data source (optional):
```json
{
  "mcpServers": {
    "mantine": {
      "command": "npx",
      "args": ["-y", "@mantine/mcp-server"],
      "env": {
        "MANTINE_MCP_DATA_URL": "https://mantine.dev/mcp"
      }
    }
  }
}
```

### Exposed Tools

| Tool | Description | Example prompt |
|------|-------------|----------------|
| `list_items` | List items from Mantine's static MCP data | "List Mantine items related to input fields" |
| `get_item_doc` | Get full documentation for an item | "Get full docs for Button" |
| `get_item_props` | Get props for an item | "Get props for Modal" |
| `search_docs` | Search all documentation | "Search Mantine docs for color scheme and dark mode" |

### Compatible Clients

- **Claude Desktop** — Add JSON config in MCP settings
- **Cursor** — Add in Cursor MCP/server settings (auto-calls tools in agent mode)
- **Windsurf** — Register in Windsurf MCP/server settings
- **VS Code / Cline / others** — If client supports custom MCP servers, same `npx` command applies

---

## Key Concepts

### Core Package (`@mantine/core`)
100+ components — buttons, modals, tables, forms, navigation, overlays, data display, inputs, layout.

### Hooks Package (`@mantine/hooks`)
80+ hooks — `useDisclosure`, `useLocalStorage`, `useDebouncedValue`, `useMediaQuery`, `useIntersection`, `useClipboard`, `useForm`, etc.

### Form Package (`@mantine/form`)
Form validation with resolver support (Zod, Yup, custom). Handles field arrays, dirty tracking, form submission, error messages.

### Theming
- CSS variables based token system
- Light/dark color scheme with `useMantineColorScheme`
- `createTheme()` for custom themes with colors, fonts, shadows, radii, spacing
- `MantineProvider` wraps the app
- `Compound` and `CSS Module` styling approaches

### Notifications (`@mantine/notifications`)
- `notifications.show()`, `notifications.update()`, `notifications.hide()`
- Built-in hooks: `showNotification`, `updateNotification`, `hideNotification`

---

## Best Practices

1. **Use MantineProvider** at the root with `defaultColorScheme="auto"` for dark mode
2. **Prefer `@mantine/core` components** over hand-rolled HTML — they're accessible and theme-aware
3. **Use `useForm`** with Zod resolver for complex forms — validation, dirty state, field arrays
4. **Use `useDisclosure`** for modals, drawers, and popovers — handles open/close lifecycle
5. **AppShell** for dashboard layouts with responsive breakpoints
6. **Server Components** — Mantine v7+ supports RSC; wrap client components with `'use client'`
7. **Mention Mantine version** in AI prompts (e.g. "using Mantine v8") for accurate API references

---

## Quick Resource Links

- 📖 Docs: https://mantine.dev/
- 🐙 GitHub: https://github.com/mantinedev/mantine
- 🎨 Themes: https://mantine.dev/themes/
- 📦 NPM: `@mantine/core`, `@mantine/hooks`, `@mantine/form`, `@mantine/notifications`
- 🛠️ MCP Server: `@mantine/mcp-server` (npm)
- 🧩 Skills Repo: https://github.com/mantinedev/skills
- 💬 Discord: https://discord.gg/wbH82zuWMN
