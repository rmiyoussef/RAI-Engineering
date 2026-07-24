# Mantine UI Skill

> Load when: Task involves Mantine components, theming, or React UI with Mantine.
> Source reference: `.brain/frontend/reference/mantine.md`
> LLM integration: 3 methods — llms.txt, MCP server (`@mantine/mcp-server`), skills repo (`mantinedev/skills`)

---

## Component Selection

| Need | Mantine Component |
|------|-------------------|
| Collapsible sections | `Accordion` |
| Icon button | `ActionIcon` with `variant` and `size` |
| Fixed position element | `Affix` |
| Alert/notification | `Alert` (static) or `@mantine/notifications` (toast) |
| Color picker | `ColorPicker` with `AlphaSlider`, `Swatches` |
| Link styled as text | `Anchor` with `underline="hover"` |
| Angle/polar picker | `AngleSlider` with `formatLabel` |
| App layout shell | `AppShell` with `Header`, `Navbar`, `Aside`, `Footer`, `Main` |
| Aspect ratio container | `AspectRatio` |
| Autocomplete input | `Autocomplete` with `data` array, `renderOption`, `clearable` |
| Avatar with fallback | `Avatar` with `name`, `src`, `color`, `AutoContrast` |
| Background gradient | `BackgroundImage` |
| Full badge | `Badge` with `leftSection`, `rightSection`, `fullWidth` |
| Blockquote | `Blockquote` with `cite` and `icon` |
| Breadcrumbs | `Breadcrumbs` with auto-slash separator |
| Button | `Button` with `leftSection`, `rightSection`, `loading` |
| Card | `Card` with `Card.Section` |
| Carousel | `@mantine/carousel` — `Carousel` with `slideSize`, `align` |
| Checkbox | `Checkbox` with `indeterminate`, `Checkbox.Group` |
| Chips | `Chip` with `Chip.Group` (prefer `Pill` in v7) |
| Code inline/block | `Code` and `CodeHighlight`/`CodeHighlightTabs` |
| Color swatches | `ColorSwatch` with `withShadow` |
| Combobox/Dropdown | `Combobox` with `Combobox.Dropdown`, `Combobox.Options`, `Combobox.Option` |
| Container | `Container` with `fluid` or `size` |
| Copy to clipboard | `CopyButton` with timeout |
| DataTable | `Table` with `Table.Thead`, `Table.Tbody`, `Table.Tr`, `Table.Td`, `Table.Th` |
| Date picker | `@mantine/dates` — `DatePicker`, `MonthPicker`, `YearPicker` |
| Description list | `DescriptionList` |
| Dialog / Modal | `Modal` with `useDisclosure` |
| Divider | `Divider` with `label` and `labelPosition` |
| Drawer | `Drawer` with `useDisclosure`, responsive `size` |
| Dropzone | `@mantine/dropzone` — `Dropzone` with accept/maxSize/onDrop |
| Fieldset | `Fieldset` with `legend` |
| File input | `FileInput` with `accept` and `clearable` |
| Flex layout | `Flex` with `gap`, `direction`, `wrap`, `justify`, `align` |
| Float above | `FloatingIndicator` |
| Focus trap | `FocusTrap` |
| Grid | `Grid` with `Grid.Col` (12-column, responsive `span`) |
| Group | `Group` for horizontal layout with `gap` |
| Highlight text | `Highlight` — highlight substrings in text |
| Hover card | `HoverCard` with `HoverCard.Dropdown` |
| Image | `Image` with `fallbackSrc`, `fit` |
| Input wrapper | `Input` and `Input.Wrapper` with `label`, `description`, `error` |
| JSON display | `JsonInput` with validation |
| Keyboard shortcut | `Kbd` |
| Like button | `Like` with `Like.Group` |
| List | `List` with `List.Item`, `icon`, `type` |
| Loading/Spinner | `Loader` with `type` (bars, dots, oval, etc.) |
| Login form | `PasswordInput` + `TextInput` with `withPasswordToggle` |
| Markdown render | `Markdown` |
| Menu | `Menu` with `Menu.Dropdown`, `Menu.Item`, `Menu.Divider`, `Menu.Label` |
| Multi select | `MultiSelect` with `data`, `searchable`, `clearable` |
| Native select | `NativeSelect` with optgroup support |
| Navigation link | `NavLink` for sidebar navigation trees |
| Notification toast | `@mantine/notifications` — `notifications.show()` |
| Number input | `NumberInput` with `min`, `max`, `decimalScale`, `prefix` |
| Pagination | `Pagination` with `total`, `value`, `onChange` |
| Password input | `PasswordInput` with visibility toggle |
| Pill / Tag | `Pill` with `Pill.Group` |
| Pin input | `PinInput` with `length`, `type`, `mask` |
| Popover | `Popover` with `Popover.Dropdown`, `Popover.Target` |
| Portal | `Portal` to render outside DOM hierarchy |
| Progress bar | `Progress` with `Progress.Section` |
| Radio button | `Radio` with `Radio.Group` |
| Rating | `Rating` with `count`, `size`, `fractions` |
| Ring progress | `RingProgress` with sections |
| Scroll area | `ScrollArea` with `scrollbarSize`, `type` |
| Segmented control | `SegmentedControl` with `data`, `fullWidth`, `color` |
| Select | `Select` with `data`, `searchable`, `clearable`, `nothingFoundMessage` |
| Simple grid | `SimpleGrid` with `cols`, `spacing`, responsive breakpoints |
| Skeleton | `Skeleton` loading placeholder |
| Slider | `Slider` with `marks`, `marks`, `restrictToMarks` |
| Space/Spacer | `Space` with `h`/`w` |
| Spoiler | `Spoiler` with show/hide toggle |
| Spotlight search | `@mantine/spotlight` — `Spotlight` command palette |
| Stack | `Stack` for vertical layout with `gap` |
| Stepper | `Stepper` with `Stepper.Step`, `active`, `orientation` |
| Switch/Toggle | `Switch` with `label`, `thumbIcon`, `onLabel`/`offLabel` |
| Table | `Table` with sticky header, row selection |
| Tabs | `Tabs` with `Tabs.List`, `Tabs.Tab`, `Tabs.Panel` |
| Tag input | `TagsInput` — freeform tag entry |
| Text | `Text` with `size`, `fw`, `c`, `ta`, `lineClamp`, `gradient` |
| Textarea | `Textarea` with `autosize`, `minRows`, `maxRows` |
| Text input | `TextInput` with `leftSection`, `rightSection`, `withAsterisk` |
| Theme icon | `ThemeIcon` with `variant`, `color`, `size`, `autoContrast` |
| Timeline | `Timeline` with `Timeline.Item`, `active`, `bulletSize` |
| Title | `Title` with `order` (h1-h6) |
| Tooltip | `Tooltip` with `label`, `position`, `withArrow`, `multiline` |
| Transition | `Transition` for mount/unmount animations |
| Tree view | `Tree` with `data`, `renderNode`, `expandOnClick` |
| Typography styles | `TypographyStylesProvider` for rendered HTML content |
| Unstyled button | `UnstyledButton` |
| Visually hidden | `VisuallyHidden` for accessible screen-reader-only content |

---

## Form Patterns

```tsx
import { useForm, zodResolver } from '@mantine/form';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  name: z.string().min(2, 'Name must have at least 2 characters'),
});

const form = useForm({
  mode: 'uncontrolled', // or 'controlled'
  initialValues: { email: '', name: '' },
  validate: zodResolver(schema),
});

<form onSubmit={form.onSubmit((values) => handleSubmit(values))}>
  <TextInput
    label="Email"
    placeholder="your@email.com"
    key={form.key('email')}
    {...form.getInputProps('email')}
  />
  <Button type="submit">Submit</Button>
</form>
```

---

## Theming Example

```tsx
import { createTheme, MantineProvider } from '@mantine/core';

const theme = createTheme({
  primaryColor: 'blue',
  defaultRadius: 'md',
  fontFamily: 'Inter, sans-serif',
  colors: {
    brand: ['#f0f9ff', '#e0f2fe', ..., '#172554'],
  },
  components: {
    Button: {
      defaultProps: { size: 'md', variant: 'filled' },
    },
  },
});

function App() {
  return (
    <MantineProvider theme={theme} defaultColorScheme="auto">
      <YourApp />
    </MantineProvider>
  );
}
```

---

## Key Rules

1. **Always import styles** — add `import '@mantine/core/styles.css'` at app entry
2. **Wrap in MantineProvider** — needed for theming, color scheme, and all components
3. **Use `useDisclosure`** for modals/drawers — not manual `useState`
4. **Dark mode** — `useMantineColorScheme().toggleColorScheme()` with `defaultColorScheme="auto"`
5. **Form validation** — prefer `zodResolver` with Zod schemas
6. **Controlled vs uncontrolled** — use `mode: 'uncontrolled'` for performance (default in v7)
7. **Responsive props** — pass object `{ base: value, sm: value, md: value }` to responsive props
8. **Accessibility** — Mantine components are ARIA-compliant by default
9. **Server components** — Mantine v7+ supports RSC; wrap interactive components with `'use client'`
10. **Mention Mantine version in prompts** — "using Mantine v8" helps AI use correct APIs
11. **Use MCP server for real-time queries** — `npx -y @mantine/mcp-server` with 4 tools: `list_items`, `get_item_doc`, `get_item_props`, `search_docs`
12. **Fetch full docs for context** — `https://mantine.dev/llms-full.txt` (~4MB) has complete component reference if MCP is unavailable
