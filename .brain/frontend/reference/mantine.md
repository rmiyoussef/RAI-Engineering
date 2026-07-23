# Mantine UI — Reference & LLM Integration

> React component library with 100+ components, hooks, theming engine.
> Source: https://mantine.dev/

---

## AI Integration Points

| Resource | URL | Use |
|----------|-----|-----|
| **llms.txt** (compact index) | `https://mantine.dev/llms.txt` | Quick component lookup — headings and links |
| **llms-full.txt** (full docs, ~4MB) | `https://mantine.dev/llms-full.txt` | Complete component props, hooks, theming, styling, FAQ |
| **MCP Server** | `@mantine/mcp-server` (npm) | Real-time doc queries via Model Context Protocol |
| **AI Skills Repo** | `https://github.com/mantinedev/skills` | Pre-built prompts for combobox, forms, custom components |

---

## MCP Server Setup

The recommended way for AI to answer Mantine questions:

```bash
npm install @mantine/mcp-server
```

Configure in MCP config:
```json
{
  "mcpServers": {
    "mantine": {
      "command": "npx",
      "args": ["@mantine/mcp-server"]
    }
  }
}
```

Available tools: `list_items`, `get_item_doc`, `get_item_props`, `search_docs`

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

---

## Quick Resource Links

- 📖 Docs: https://mantine.dev/
- 🐙 GitHub: https://github.com/mantinedev/mantine
- 🎨 Themes: https://mantine.dev/themes/
- 📦 NPM: `@mantine/core`, `@mantine/hooks`, `@mantine/form`, `@mantine/notifications`
