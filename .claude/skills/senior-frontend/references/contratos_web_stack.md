# contratos-web — Stack & Configuration Reference

## Runtime & Framework

| Layer | Tech | Version |
|---|---|---|
| Framework | Next.js | 12.1.5 |
| UI | React | 18.1.0 |
| Language | TypeScript | 4.6.3 (strict: false) |
| Base path | `/contratos` | configured in `next.config.js` |

Next.js basePath `/contratos` means all `router.push()` calls and `<Link href>` are relative to that — never include `/contratos` prefix in code.

## Dependency Map

### State & Data Fetching
```
React Context API          — Auth, Toast, Application, Alert
react-query 3.39.3         — legacy usage (some modules)
@tanstack/react-query 5.40 — newer modules
swr                        — some listing pages
immer 9.0.16               — immutable state updates where complex nesting
```
Both react-query versions coexist. New code should use `@tanstack/react-query` (v5 API).

### HTTP
```
axios 0.27.2               — primary HTTP client
```
Multiple axios instances, one per API:
- `apiContrato` → `NEXT_PUBLIC_API_CONTRACT`
- `apiProduto` → `NEXT_PUBLIC_API_PRODUTO`
- `apiTabelaAuxiliares` → `NEXT_PUBLIC_API_TABELA_AUXILIARES`
- `apiTabelaAssistencial` → `NEXT_PUBLIC_API_TABELA_ASSISTENCIAL`
- `apiCredenciamento` → `NEXT_PUBLIC_API_CREDENCIAMENTO`
- `apiPessoa` → `NEXT_PUBLIC_API_PESSOA`
- `apiManagement` → `NEXT_PUBLIC_MANAGEMENT`
- `apiSso` → `NEXT_PUBLIC_SSO`

Each instance has request interceptor that injects `Authorization: Bearer <token>` from `localStorage`.

### Styling
```
styled-components 5.3.11   — CSS-in-JS
polished 4.2.2             — shade(), transparentize(), etc.
```

### UI Primitives
```
react-icons 4.4.0          — icon sets
react-svg (react-inlinesvg) — SVG as component
lottie-web 5.9.4           — Lottie animations
react-spring 9.4.5         — complex animations
react-loading-skeleton 3.1.0 — skeleton screens
react-tooltip 5.27.1       — tooltips
```

### Forms & Validation
```
yup 0.32.11                — schema validation
react-number-format 5.4.2  — numeric input masks (monetary, etc.)
validations-br 1.3.0       — CPF, CNPJ, CEP validators
react-select 5.8.0         — enhanced selects
react-select/async-paginate — paginated async selects
```

### Utilities
```
moment 2.29.4 (pt-BR locale) — date parsing and formatting
js-cookie 3.0.1            — cookie management
uuid / uuidv4              — ID generation
use-debounce 8.0.4         — debounced values/callbacks
use-file-picker 1.5.1      — file input
react-drag-drop-files 2.3.7 — drag-and-drop file upload
react-responsive 9.0.0     — responsive breakpoints in JS
```

---

## TypeScript Configuration

```json
{
  "strict": false,
  "baseUrl": ".",
  "paths": {
    "styles/*":    ["src/styles/*"],
    "components/*":["src/components/*"],
    "templates/*": ["src/templates/*"],
    "utils/*":     ["src/utils/*"],
    "hooks/*":     ["src/hooks/*"],
    "context/*":   ["src/context/*"],
    "types/*":     ["src/types/*"]
  }
}
```

`strict: false` means `any` is allowed but should still be avoided in new code. Prefer explicit interfaces.

---

## Environment Variables

All env vars are prefixed `NEXT_PUBLIC_` (browser-accessible). Clients have separate env sets:

```bash
# API endpoints (per-client, set per deploy)
NEXT_PUBLIC_API_CONTRACT
NEXT_PUBLIC_API_PRODUTO
NEXT_PUBLIC_API_TABELA_AUXILIARES
NEXT_PUBLIC_API_TABELA_ASSISTENCIAL
NEXT_PUBLIC_API_CREDENCIAMENTO
NEXT_PUBLIC_API_PESSOA
NEXT_PUBLIC_MANAGEMENT
NEXT_PUBLIC_SSO

# Client branding assets base URL
NEXT_PUBLIC_ASSETS_URL   # e.g., https://cdn.../planserv or .../gdf
```

---

## Theme Tokens (`src/styles/theme.ts`)

### Colors (use via `${({ theme }) => theme.colors.X}`)

```
primary:   { 500: '#2B45D4', default: '#0050E5' }
secondary: { 600: '#E59500', 500: '#FFCC00', ... }
octopus:   { primary: { light, default, dark, opacity, '40' } }
ihealth:   { primary: { default: '#2B45D4' } }
black:     { '04', '08', '16', '40', '56', '88' }  ← opacity variants
white:     { bg, '100' }
info:      { light, medium, dark }
warning:   { light, medium, dark }
success:   { light, medium, dark }
alert:     { light, medium, dark }
danger:    { light, medium, dark }
pink:      { primary: { default, ... } }
```

### Spacings
```
xxsmall: '0.8rem'   xsmall: '1.6rem'   small: '2.4rem'
medium:  '3.2rem'   large:  '4.0rem'   xlarge: '4.8rem'
xxlarge: '5.6rem'   huge:   '6.4rem'   xhuge: '12.8rem'
```

### Font Sizes
```
hxx: '5.2rem'   hx: '3.6rem'   h1: '2.4rem'   h2: '2.0rem'
h3: '1.8rem'    h4: '1.6rem'   h5: '1.4rem'   h6: '1.2rem'
```

### Font Weights
```
light: 300   normal: 400   semiBold: 600   bold: 700   extraBold: 800
```

---

## Project Structure

```
contratos-web/src/
├── pages/
│   ├── _app.tsx             ← providers stack + getLayout pattern
│   ├── _document.tsx        ← SSR styled-components setup
│   ├── index.tsx            ← redirect to /beneficiarios
│   ├── beneficiarios/
│   │   ├── index.tsx
│   │   ├── [id].tsx
│   │   └── visualizar/[id].tsx
│   └── [feature]/...
├── components/
│   ├── atoms/               ← Button, Input, Badge, Tag, Select, Checkbox...
│   ├── molecules/           ← Filter, TablePagination, AsyncPaginateSelect...
│   └── organisms/           ← FormulariosBeneficiario, ContratoHeader...
├── templates/               ← ContratoListaTemplate, VisualizarSeguradoTemplate...
├── context/
│   ├── auth/AuthContext.tsx
│   ├── toast/ToastContext.tsx
│   ├── aplication/AplicationContext.tsx
│   └── alert/AlertContext.tsx
├── hooks/
│   ├── useStorage.ts        ← localStorage with JSON parse/stringify
│   ├── useClientAssets.ts   ← multi-client asset resolution
│   └── use-debounce.ts
├── services/
│   ├── apis/                ← axios instance files (apiContrato.ts, etc.)
│   └── contratoApi/         ← service classes per domain
├── types/
│   ├── common/
│   │   └── enums.ts         ← SituacaoContrato, TipoSegurado, SexoEnum...
│   ├── contrato.d.ts
│   ├── pessoa.d.ts
│   ├── beneficiario.d.ts
│   └── ...
├── utils/
│   ├── StringUtils.ts       ← masks (CPF, CNPJ, CEP, phone), capitalize
│   ├── NumberUtils.ts       ← masks (money, float, int), validateCPF
│   ├── ObjectUtils.ts       ← propsToParams, isEmpty
│   ├── SelectMapper.ts      ← enum→options, domain-specific options
│   └── parseValidateError.ts← Yup error parser
└── styles/
    ├── theme.ts
    └── global.ts
```

---

## _app.tsx Provider Stack Order

```tsx
<ThemeProvider theme={theme}>
  <GlobalStyles />
  <AuthProvider>
    <ToastProvider>
      <AlertProvider>
        <AplicationProvider>
          {getLayout(<Component {...pageProps} />)}
        </AplicationProvider>
      </AlertProvider>
    </ToastProvider>
  </AuthProvider>
</ThemeProvider>
```

Always respect this order when adding new providers.

---

## SSR Considerations

- `_document.tsx` handles `ServerStyleSheet` from styled-components — do not remove or modify this.
- Avoid direct `localStorage` / `document` access outside `useEffect` or `typeof window !== 'undefined'` guards — pages are server-rendered.
- `getServerSideProps` should only extract `ctx.query` params; heavy data fetching happens in templates/hooks.
- The axios interceptor already guards with `typeof window !== 'undefined'` before reading localStorage.

---

## Multi-Client Asset Pattern

```ts
// hooks/useClientAssets.ts
const { logoUrl, primaryColor, faviconUrl } = useClientAssets()

// resolves to NEXT_PUBLIC_ASSETS_URL/[client]/logo.svg
// client is determined by subdomain or env variable at runtime
```

Use this hook in any component that renders client-branded assets. Never hardcode client asset URLs.
