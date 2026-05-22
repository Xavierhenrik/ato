---
name: senior-frontend
description: Senior frontend developer expert in the contratos-web project stack and patterns. Use this skill for ANY frontend task in this project — building components, pages, templates, hooks, forms, service calls, or reviewing frontend code. Knows the exact project conventions (atomic design, styled-components theme, Yup validation, service static classes, Context API, getLayout pattern, path aliases) so it never needs to explore the project from scratch. Always takes a holistic view before implementing to avoid production gaps. Trigger whenever the user mentions components, pages, templates, forms, filters, modals, tables, hooks, styles, or frontend architecture in this project.
---

# Senior Frontend — contratos-web

Expert in the contratos-web frontend codebase. Before writing a single line of code, understand the full impact surface of the change. Production gaps come from context gaps — this skill eliminates them.

## Holistic Pre-Implementation Checklist

Before implementing anything, answer these questions mentally (or explicitly when the scope is large):

1. **Atomic level** — Is this an atom, molecule, organism, or template? Does a similar component already exist?
2. **Types** — What TypeScript interfaces/enums from `types/` already model this data? Never duplicate type definitions.
3. **Theme** — Which tokens from `styles/theme.ts` apply? (`colors`, `spacings`, `font.sizes`) Never hardcode hex values or px sizes.
4. **State** — Local state (`useState`)? Derived from Context (Auth, Toast, Application, Alert)? Fetched with React Query/SWR?
5. **Service layer** — Is there a static service class in `services/` that already handles this API call?
6. **Validation** — If there is a form, does a Yup schema exist in the module? Reuse or extend it.
7. **Utils** — Does `StringUtils`, `NumberUtils`, `ObjectUtils`, or `SelectMapper` have a relevant helper?
8. **Routing** — Does this page need `getServerSideProps`? Does it need a `getLayout` declaration?
9. **Multi-client** — Does the feature use assets or colors that vary by client (planserv vs gdf)? Use `useClientAssets()`.
10. **Responsiveness** — Is `useMediaQuery` from `react-responsive` needed?

Read `references/contratos_web_stack.md` for the full stack reference.
Read `references/component_patterns.md` for canonical component/form/page patterns with code.
Read `references/state_and_services.md` for Context, React Query, SWR, and service layer patterns.

---

## Decision Framework

### Choosing the right layer

| What you're building | Where it goes |
|---|---|
| Pure UI primitive (button, input, badge, tag) | `components/atoms/ComponentName/` |
| Composed UI block (filter bar, paginated select, card) | `components/molecules/ComponentName/` |
| Business-logic block (beneficiary form, contract header) | `components/organisms/SubFeature/` |
| Full page layout wiring all pieces | `templates/FeatureNameTemplate/` |
| Next.js route entry point | `pages/feature/[id].tsx` — thin, delegates to template |
| Reusable data-fetching or event logic | `hooks/useFeatureName.ts` |
| API call to a specific backend | `services/contratoApi/featureServices.ts` |

### When to create vs reuse

Always `Glob` and `Grep` for existing atoms before creating a new one. The codebase has:
- `Button`, `Input`, `Badge`, `Tag`, `Checkbox`, `Radio`, `Select`
- `AsyncPaginateSelect` (React Select with paginated async options)
- `TablePagination` (full paginated table with column config)
- `Filter` (collapsible filter bar wrapper)
- `Modal` (base modal with confirm/cancel)
- `Loading` / `Skeleton` wrappers
- `Tooltip`, `ToastNotification`

If the existing atom can do the job with different props, use it. Only create a new component when the existing one truly can't be composed to meet the need.

---

## Naming & File Conventions (non-negotiable)

```
components/atoms/ButtonIcon/
├── index.tsx        ← logic + JSX, named export + default export
├── styles.ts        ← all styled-components, exported as S.*
└── functions.ts     ← pure helpers used only by this component (optional)
```

- **Component files**: PascalCase (`ContratoHeader.tsx`)
- **Hook files**: camelCase with `use` prefix (`useContratoFilter.ts`)
- **Service files**: camelCase (`contratoServices.ts`)
- **Type files**: camelCase with `.d.ts` (`contrato.d.ts`)
- **Enum files**: camelCase (`enums.ts`) inside `types/common/`
- **CSS class names**: use `maida-[component]--[element]` for testable selectors

Imports always use **path aliases**, never relative `../../`:
```ts
import Button from 'components/atoms/Button'
import { StringUtils } from 'utils/StringUtils'
import { SituacaoContrato } from 'types/common/enums'
```

---

## Styled-Components Rules

1. **Import theme via styled-components `DefaultTheme`** — never import `themeStyles` directly in component files.
2. **All styled components live in `styles.ts`**, imported as `import * as S from './styles'`.
3. **Use `css` helper** for conditional blocks; use `modifier` maps for variant logic:

```ts
// styles.ts pattern
const modifierState = {
  danger: (theme: DefaultTheme) => css`
    border-color: ${theme.colors.danger.medium};
  `,
  success: (theme: DefaultTheme) => css`
    border-color: ${theme.colors.success.medium};
  `,
}

export const Wrapper = styled.div<{ state?: 'danger' | 'success' }>`
  ${({ theme, state }) => css`
    padding: ${theme.spacings.small};
    ${state && modifierState[state](theme)}
  `}
`
```

4. **Never use inline `style={{}}` props** unless dealing with dynamic values that can't be expressed as props (e.g., runtime widths from JS calculations).

---

## Form Pattern (standard)

All forms follow the same three-part pattern. Never deviate from it:

```tsx
// 1. State
const [fields, setFields] = useState<IFormShape>(initialValues)
const [erros, setErros] = useState<Partial<Record<keyof IFormShape, IError>>>({})
const [loading, setLoading] = useState(false)

// 2. Submit handler
const handleSubmit = async () => {
  const validationErrors = await parseValidateError(fields, schemaFormShape)
  if (Object.keys(validationErrors).length > 0) {
    setErros(validationErrors)
    return
  }
  setLoading(true)
  try {
    await SomeService.post(fields)
    addToast({ title: 'Sucesso', type: 'success' })
    router.push('/feature')
  } catch {
    addToast({ title: 'Erro ao salvar', type: 'error' })
  } finally {
    setLoading(false)
  }
}

// 3. Field update helper (always spread, never mutate)
const updateField = (path: keyof IFormShape) => (value: any) =>
  setFields(prev => ({ ...prev, [path]: value }))
```

See `references/component_patterns.md` for complete form organism examples.

---

## Error Handling at the UI Layer

- Use `addToast` from `useToast()` for user-visible errors — never `console.error` alone.
- Differentiate: `type: 'error'` for failures, `type: 'success'` for confirmations, `type: 'warning'` for soft alerts.
- API errors from Axios interceptors are already logged; in `.catch()` just show the toast.
- Validation errors from Yup go into `erros` state, passed as `error={erros?.field?.message}` to `<Input>`.

---

## Performance Guardrails

- Wrap callbacks in `useCallback` when they are passed as props to child components or used inside `useEffect` deps.
- Use `useMemo` for expensive array transforms (e.g., mapping API data to table rows), not for trivial derivations.
- Prefer `useQuery` / `useSWR` for data that can be cached; avoid duplicate fetches on the same page with local `useEffect` calls.
- Never call a service directly inside JSX render — always in effects or event handlers.

---

## useEffect — Use as Last Resort

`useEffect` is the most common source of bugs in this codebase: infinite loops, stale closures, race conditions, and double-fetches in React 18 Strict Mode. Exhaust all alternatives before reaching for it.

### Prefer these alternatives first

| Intent | Instead of useEffect | Use |
|---|---|---|
| Fetch data on mount | `useEffect → service call` | `useQuery` / `useSWR` — they handle loading, caching, dedup |
| Derive value from state | `useEffect → setState` | Calculate inline or `useMemo` — derived state causes double renders |
| Sync form field to prop change | `useEffect → setFields(prop)` | Pass `defaultValue` on mount, own the state locally |
| Run something on button click | `useEffect` watching a flag | Call the function directly in the event handler |
| Paginate on filter change | `useEffect([filter])` | Call `onFilter(filter, 0)` directly in the filter submit handler |
| Load select options | `useEffect → setState(options)` | `loadOptions` callback in `AsyncPaginateSelect` |

### When useEffect is actually appropriate

- Subscribing to external events (WebSocket, `window.resize`, `document.addEventListener`)
- Syncing with non-React third-party libraries (Lottie, charting libs)
- Running cleanup on unmount (`return () => subscription.unsubscribe()`)
- Reading `localStorage` / `document` after hydration (SSR guard)

### Rules when you must use useEffect

```tsx
// WRONG — derived state antipattern (double render, stale value risk)
useEffect(() => {
  setFullName(`${firstName} ${lastName}`)
}, [firstName, lastName])

// RIGHT — compute inline
const fullName = `${firstName} ${lastName}`

// WRONG — fetch triggered by useEffect watching state that changes often
useEffect(() => {
  fetchData(filter)
}, [filter])

// RIGHT — fetch directly in the event handler that changes filter
const handleSearch = () => {
  fetchData(filter)
  setPage(0)
}

// WRONG — missing cleanup causes memory leak / state update on unmounted component
useEffect(() => {
  SomeService.get().then(({ data }) => setData(data))
}, [id])

// RIGHT — abort controller or React Query (handles this automatically)
useEffect(() => {
  const controller = new AbortController()
  SomeService.get(id, { signal: controller.signal })
    .then(({ data }) => setData(data))
    .catch(err => { if (err.name !== 'AbortError') addToast({ title: 'Erro', type: 'error' }) })
  return () => controller.abort()
}, [id])
```
