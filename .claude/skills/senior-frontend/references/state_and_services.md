# State Management & Service Layer — contratos-web

## Table of Contents
1. [Context API — reading and writing](#1-context-api--reading-and-writing)
2. [React Query (@tanstack v5)](#2-react-query-tanstack-v5)
3. [SWR pattern](#3-swr-pattern)
4. [Service Classes](#4-service-classes)
5. [Axios Interceptors (don't touch)](#5-axios-interceptors-dont-touch)
6. [Yup Validation Utilities](#6-yup-validation-utilities)
7. [Utility Classes](#7-utility-classes)

---

## 1. Context API — reading and writing

### Available Contexts

| Context | Hook | What it exposes |
|---|---|---|
| `AuthContext` | `useContext(AuthContext)` | `data` (user), `dataToken`, `setData`, `logout`, `dataUser` |
| `ToastContext` | `useToast()` | `addToast({ title, description?, type })` |
| `AlertContext` | `useAlert()` | `showAlert({ title, message, onConfirm })` |
| `AplicationContext` | `useAplication()` | `loading`, `setLoading`, `sidebarOpen` |

### Reading auth data

```tsx
import { useContext } from 'react'
import { AuthContext } from 'context/auth/AuthContext'

const { dataUser, dataToken } = useContext(AuthContext)
// dataUser: { nome, cpf, perfis, contratanteId, ... }
// dataToken: raw JWT string
```

### Showing toast notifications

```tsx
import { useToast } from 'hooks/useToast'

const { addToast } = useToast()

// Success
addToast({ title: 'Operação realizada com sucesso', type: 'success' })

// Error
addToast({ title: 'Erro ao carregar dados', description: 'Tente novamente', type: 'error' })

// Warning
addToast({ title: 'Atenção', description: 'Dados incompletos', type: 'warning' })
```

### Confirmation dialog

```tsx
import { useAlert } from 'hooks/useAlert'

const { showAlert } = useAlert()

const handleDelete = (id: string) => {
  showAlert({
    title: 'Confirmar exclusão',
    message: 'Deseja realmente excluir este registro?',
    onConfirm: async () => {
      await SomeService.delete(id)
      addToast({ title: 'Excluído com sucesso', type: 'success' })
      refetch()
    }
  })
}
```

---

## 2. React Query (@tanstack v5)

Use for data that benefits from caching, background refetch, and deduplication.

### Basic query

```tsx
import { useQuery } from '@tanstack/react-query'
import { ContratoServices } from 'services/contratoApi/contratoServices'

function useContrato(id: string) {
  return useQuery({
    queryKey: ['contrato', id],
    queryFn: () => ContratoServices.getByID(id).then(r => r.data),
    enabled: !!id,
    staleTime: 5 * 60 * 1000,  // 5 minutes
  })
}

// In component:
const { data: contrato, isLoading, error } = useContrato(id)
```

### Mutation

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query'

function useAtualizarContrato() {
  const queryClient = useQueryClient()
  const { addToast } = useToast()

  return useMutation({
    mutationFn: (data: IContratoCommand) => ContratoServices.put(data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['contrato', variables.id] })
      addToast({ title: 'Contrato atualizado', type: 'success' })
    },
    onError: () => {
      addToast({ title: 'Erro ao atualizar contrato', type: 'error' })
    }
  })
}
```

### Query key conventions

```
['contrato', id]                  ← single entity by ID
['contratos', filterObject]       ← list with filter
['contrato', id, 'beneficiarios'] ← nested resource
['beneficiario', cpf]             ← entity by alternate key
```

---

## 3. SWR Pattern

Used in some listing pages. Prefer React Query for new code; use SWR only when extending existing SWR pages.

```tsx
import useSWR from 'swr'
import { contractFetcher } from 'services/apis/apiContrato'

// contractFetcher = (url) => axiosApi.get(url).then(r => r.data)
const { data, error, mutate } = useSWR<IPageContrato>(
  `/contratos?page=0&size=10&status=ATIVO`,
  contractFetcher
)

// Refresh after mutation:
await ContratoServices.post(newContrato)
mutate()  // re-fetches the SWR key
```

---

## 4. Service Classes

All API calls go through static service classes. One class per domain entity.

### File location
```
services/
├── apis/
│   ├── apiContrato.ts        ← axios instance + fetcher
│   ├── apiPessoa.ts
│   └── ...
└── contratoApi/
    ├── contratoServices.ts
    ├── beneficiarioServices.ts
    ├── anotacaoServices.ts
    └── ...
```

### Standard service class pattern

```ts
// services/contratoApi/anotacaoServices.ts
import { AxiosResponse } from 'axios'
import { axiosApi } from 'services/apis/apiContrato'
import { ObjectUtils } from 'utils/ObjectUtils'
import { IAnotacaoQuery, INovaAnotacaoCommand, IGetAnotacaoProps } from 'types/anotacao'
import { IPageResponse } from 'types/common/pagination'

const baseUrl = '/anotacoes'

export class AnotacaoServices {
  static async get(props?: IGetAnotacaoProps): Promise<AxiosResponse<IPageResponse<IAnotacaoQuery>>> {
    const params = ObjectUtils.propsToParams(props)
    return axiosApi.get(params ? `${baseUrl}?${params}` : baseUrl)
  }

  static async getByID(id: string): Promise<AxiosResponse<IAnotacaoQuery>> {
    return axiosApi.get(`${baseUrl}/${id}`)
  }

  static async post(data: INovaAnotacaoCommand): Promise<AxiosResponse<IAnotacaoQuery>> {
    return axiosApi.post(baseUrl, data)
  }

  static async put(id: string, data: Partial<IAnotacaoQuery>): Promise<AxiosResponse<IAnotacaoQuery>> {
    return axiosApi.put(`${baseUrl}/${id}`, data)
  }

  static async delete(id: string): Promise<AxiosResponse<void>> {
    return axiosApi.delete(`${baseUrl}/${id}`)
  }
}
```

### Service with FormData (file upload)

```ts
static async postWithFile(data: ICommand, file?: File): Promise<AxiosResponse<IQuery>> {
  const formData = new FormData()
  formData.append('form', new Blob([JSON.stringify(data)], { type: 'application/json' }))
  if (file) formData.append('file', file, file.name)
  return axiosApi.post(baseUrl, formData, { headers: { 'Content-Type': 'multipart/form-data' } })
}
```

### Choosing the right axios instance

| Data domain | Import from |
|---|---|
| Contratos, anotações, simulados | `services/apis/apiContrato` |
| Produtos e tabelas de produto | `services/apis/apiProduto` |
| Tabelas auxiliares (gênero, estado civil, CID) | `services/apis/apiTabelaAuxiliares` |
| Dados de pessoa (CPF lookup, endereço) | `services/apis/apiPessoa` |
| Gestão de usuários e perfis | `services/apis/apiManagement` |

---

## 5. Axios Interceptors (don't touch)

Each axios instance in `services/apis/` has this request interceptor already configured:

```ts
axiosApi.interceptors.request.use((config) => {
  if (typeof window !== 'undefined') {
    const localToken = localStorage.getItem(localStorageToken)
    if (localToken) {
      const token = localToken.replaceAll('"', '')
      if (token && config.headers !== undefined) {
        config.headers.Authorization = `Bearer ${token}`
      }
    }
  }
  return config
})
```

**Do not add auth logic to service classes** — the interceptor handles it globally. Do not add response interceptors without discussing with the team (they affect all requests).

---

## 6. Yup Validation Utilities

### parseValidateError

Located at `utils/parseValidateError.ts`. Returns a flat error map.

```ts
import { parseValidateError } from 'utils/parseValidateError'
import * as yup from 'yup'

interface IForm { nome: string; cpf: string }

const schema: yup.SchemaOf<IForm> = yup.object().shape({
  nome: yup.string().required('Nome é obrigatório'),
  cpf: yup
    .string()
    .test('cpf-valid', 'CPF inválido', (v) => NumberUtils.validateCPF(v ?? ''))
    .required('CPF é obrigatório'),
})

// Returns: { nome: { message: '...', type: '...' }, cpf: { message: '...' } }
const errors = await parseValidateError(formValues, schema)

if (Object.keys(errors).length > 0) {
  setErros(errors)
  return
}
```

### Nested object schemas

```ts
const schema = yup.object().shape({
  contato: yup.object().shape({
    email: yup.string().email('E-mail inválido').required('E-mail obrigatório'),
    telefone: yup.string()
      .test('len', 'Telefone deve ter 11 dígitos', v => v?.replace(/\D/g, '').length === 11)
      .required(),
  }),
  dadosBasicos: yup.object().shape({
    cpf: yup.string().required(),
    dataNascimento: yup.string().required(),
  })
})
```

Nested paths in the error map use dot notation: `errors['contato.email']`.

### Async validation (API check)

```ts
cpf: yup.string()
  .test('cpf-unique', 'CPF já cadastrado', async (cpf) => {
    if (!cpf) return true
    const { data } = await PessoaServices.checkCpfExists(removeMask(cpf))
    return !data.exists  // return true = valid, false = error
  })
```

---

## 7. Utility Classes

### StringUtils (`utils/StringUtils.ts`)

```ts
StringUtils.maskCpf('12345678901')    // '123.456.789-01'
StringUtils.maskCnpj('12345678000195') // '12.345.678/0001-95'
StringUtils.maskCep('01310100')        // '01310-100'
StringUtils.maskPhone('11987654321')   // '(11) 98765-4321'
StringUtils.capitalize('joao silva')   // 'Joao Silva'
StringUtils.onlyNumber('R$ 1.234,56')  // '123456'
StringUtils.onlyNumber('R$ 1.234,56', true)  // 123456 (number type)
```

### NumberUtils (`utils/NumberUtils.ts`)

```ts
NumberUtils.maskMoney('1234.56')      // 'R$ 1.234,56'
NumberUtils.maskNumeric('abc123def')  // '123'
NumberUtils.maskFloat('12345', 5, 2)  // '123,45'
NumberUtils.validateCPF('12345678901') // true/false
NumberUtils.maskNumberInt('1abc2')    // '12'
```

### ObjectUtils (`utils/ObjectUtils.ts`)

```ts
// Converts object to query string, skipping null/undefined
ObjectUtils.propsToParams({ page: 0, size: 10, nome: 'joao', status: undefined })
// → 'page=0&size=10&nome=joao'

ObjectUtils.isEmpty({})         // true
ObjectUtils.isEmpty({ a: 1 })   // false
ObjectUtils.isEmpty(null)        // true
```

### SelectMapper (`utils/SelectMapper.ts`)

```ts
import { SelectMapper } from 'utils/SelectMapper'
import { SexoEnum } from 'types/common/enums'

// Convert enum to select options
const sexoOptions = SelectMapper.getEnumOptions(SexoEnum)
// → [{ label: 'MASCULINO', value: 'MASCULINO' }, ...]

// Domain-specific option lists
const responsavelOptions = SelectMapper.getResponsavelFinanceiroContratoOptions('Selecione')
```

### removeMaskCustom

Utility available in scope for stripping any mask before sending to API:
```ts
import { removeMaskCustom } from 'utils/masks'
const cpfClean = removeMaskCustom(cpfWithMask) // '123.456.789-01' → '12345678901'
```
