# Component Patterns — contratos-web

Canonical code patterns extracted from the real codebase. Use these as templates, not inspiration.

## Table of Contents
1. [Atom Component](#1-atom-component)
2. [Molecule — Filter Bar](#2-molecule--filter-bar)
3. [Organism — Form with Validation](#3-organism--form-with-validation)
4. [Template — List with Pagination](#4-template--list-with-pagination)
5. [Page — Next.js Route Entry Point](#5-page--nextjs-route-entry-point)
6. [Custom Hook](#6-custom-hook)
7. [Badge / Status Rendering](#7-badge--status-rendering)
8. [AsyncPaginateSelect](#8-asyncpaginateselect)

---

## 1. Atom Component

```
components/atoms/StatusTag/
├── index.tsx
└── styles.ts
```

**index.tsx**
```tsx
import * as S from './styles'

export type StatusTagTheme = 'success' | 'danger' | 'warning' | 'info'

export type StatusTagProps = {
  label: string
  theme?: StatusTagTheme
}

const StatusTag = ({ label, theme = 'info' }: StatusTagProps) => (
  <S.Wrapper theme={theme} className="maida-status-tag--wrapper">
    <span className="maida-status-tag--text">{label}</span>
  </S.Wrapper>
)

export default StatusTag
```

**styles.ts**
```ts
import styled, { css, DefaultTheme } from 'styled-components'
import { StatusTagTheme } from '.'

type WrapperProps = { theme: StatusTagTheme }

const modifiers: Record<StatusTagTheme, (theme: DefaultTheme) => ReturnType<typeof css>> = {
  success: (t) => css`background: ${t.colors.success.light}; color: ${t.colors.success.dark};`,
  danger:  (t) => css`background: ${t.colors.danger.light};  color: ${t.colors.danger.dark};`,
  warning: (t) => css`background: ${t.colors.warning.light}; color: ${t.colors.warning.dark};`,
  info:    (t) => css`background: ${t.colors.info.light};    color: ${t.colors.info.dark};`,
}

export const Wrapper = styled.span<WrapperProps>`
  ${({ theme, theme: styledTheme }) => css`
    display: inline-flex;
    align-items: center;
    padding: 0.4rem ${styledTheme.spacings.xsmall};
    border-radius: 9999px;
    font-size: ${styledTheme.font.sizes.h6};
    font-weight: ${styledTheme.font.semiBold};
    ${modifiers[theme](styledTheme)}
  `}
`
```

---

## 2. Molecule — Filter Bar

Pattern: controlled filter object, external `onSearch` callback, optional "clear" button.

```tsx
// components/molecules/ContratoFilter/index.tsx
import { useState, useCallback } from 'react'
import Input from 'components/atoms/Input'
import Button from 'components/atoms/Button'
import Grid from 'components/atoms/Grid'
import Filter from 'components/molecules/Filter'
import { ObjectUtils } from 'utils/ObjectUtils'
import { IGetContratoProps } from 'types/contrato'
import * as S from './styles'

type Props = {
  onSearch: (filter: IGetContratoProps) => void
}

const ContratoFilter = ({ onSearch }: Props) => {
  const [filter, setFilter] = useState<IGetContratoProps>({})

  const handleSearch = useCallback(() => {
    onSearch(filter)
  }, [filter, onSearch])

  const handleClear = useCallback(() => {
    setFilter({})
    onSearch({})
  }, [onSearch])

  const update = (key: keyof IGetContratoProps) => (value: any) =>
    setFilter(prev => ({ ...prev, [key]: value || undefined }))

  return (
    <Filter
      showButtonClean={!ObjectUtils.isEmpty(filter)}
      onClickSearchButton={handleSearch}
      onClickCleanButton={handleClear}
    >
      <Grid columns={3}>
        <Input
          label="Número do contrato"
          value={filter.numeroContrato || ''}
          handleOnChange={update('numeroContrato')}
        />
        <Input
          label="Nome do contrato"
          value={filter.nomeContrato || ''}
          handleOnChange={update('nomeContrato')}
        />
      </Grid>
    </Filter>
  )
}

export default ContratoFilter
```

---

## 3. Organism — Form with Validation

Full pattern: state + Yup schema + parseValidateError + service call + toast.

```tsx
// components/organisms/NovaAnotacaoForm/index.tsx
import { useState } from 'react'
import { useRouter } from 'next/router'
import * as yup from 'yup'
import Input from 'components/atoms/Input'
import Button from 'components/atoms/Button'
import { useToast } from 'hooks/useToast'
import { parseValidateError } from 'utils/parseValidateError'
import { AnotacaoServices } from 'services/contratoApi/anotacaoServices'
import { INovaAnotacaoCommand } from 'types/anotacao'
import * as S from './styles'

const schema: yup.SchemaOf<INovaAnotacaoCommand> = yup.object().shape({
  titulo: yup.string().required('Título é obrigatório'),
  conteudo: yup.string().required('Conteúdo é obrigatório').min(10, 'Mínimo 10 caracteres'),
  contratoId: yup.string().required(),
})

type Props = { contratoId: string }

const NovaAnotacaoForm = ({ contratoId }: Props) => {
  const router = useRouter()
  const { addToast } = useToast()
  const [loading, setLoading] = useState(false)
  const [fields, setFields] = useState<INovaAnotacaoCommand>({ titulo: '', conteudo: '', contratoId })
  const [erros, setErros] = useState<Partial<Record<keyof INovaAnotacaoCommand, { message: string }>>>({})

  const update = (key: keyof INovaAnotacaoCommand) => (value: string) =>
    setFields(prev => ({ ...prev, [key]: value }))

  const handleSubmit = async () => {
    const validationErrors = await parseValidateError(fields, schema)
    if (Object.keys(validationErrors).length > 0) {
      setErros(validationErrors)
      return
    }
    setLoading(true)
    try {
      await AnotacaoServices.post(fields)
      addToast({ title: 'Anotação criada com sucesso', type: 'success' })
      router.push(`/contratos/${contratoId}/anotacoes`)
    } catch {
      addToast({ title: 'Erro ao criar anotação', type: 'error' })
    } finally {
      setLoading(false)
    }
  }

  return (
    <S.Wrapper>
      <Input
        label="Título"
        value={fields.titulo}
        handleOnChange={update('titulo')}
        error={erros.titulo?.message}
      />
      <Input
        label="Conteúdo"
        value={fields.conteudo}
        handleOnChange={update('conteudo')}
        error={erros.conteudo?.message}
      />
      <Button onClick={handleSubmit} disabled={loading} isFullWidth={false}>
        {loading ? 'Salvando...' : 'Salvar'}
      </Button>
    </S.Wrapper>
  )
}

export default NovaAnotacaoForm
```

---

## 4. Template — List with Pagination

Receives data and callbacks from page. Owns display logic only.

```tsx
// templates/AnotacaoListaTemplate/index.tsx
import { useState, useEffect, useCallback } from 'react'
import TablePagination from 'components/molecules/TablePagination'
import AnotacaoFilter from 'components/molecules/AnotacaoFilter'
import { IAnotacaoQuery, IGetAnotacaoProps } from 'types/anotacao'
import { IPageResponse } from 'types/common/pagination'
import * as S from './styles'

type Props = {
  data?: IPageResponse<IAnotacaoQuery>
  loading: boolean
  onFilter: (filter: IGetAnotacaoProps, page: number) => void
}

const AnotacaoListaTemplate = ({ data, loading, onFilter }: Props) => {
  const [page, setPage] = useState(0)
  const [activeFilter, setActiveFilter] = useState<IGetAnotacaoProps>({})

  useEffect(() => {
    onFilter(activeFilter, page)
  }, [page])  // re-fetch when page changes; filter changes call handleSearch directly

  const handleSearch = useCallback((filter: IGetAnotacaoProps) => {
    setActiveFilter(filter)
    setPage(0)
    onFilter(filter, 0)
  }, [onFilter])

  const columns = [
    { key: 'titulo',     label: 'Título' },
    { key: 'criadoEm',   label: 'Data',    render: (row: IAnotacaoQuery) => formatDate(row.criadoEm) },
    { key: 'acoes',      label: 'Ações',   render: (row: IAnotacaoQuery) => <ActionButtons id={row.id} /> },
  ]

  return (
    <S.Wrapper>
      <AnotacaoFilter onSearch={handleSearch} />
      <TablePagination
        columns={columns}
        data={data?.content ?? []}
        totalPages={data?.totalPages ?? 0}
        currentPage={page}
        onChangePage={setPage}
        loading={loading}
      />
    </S.Wrapper>
  )
}

export default AnotacaoListaTemplate
```

---

## 5. Page — Next.js Route Entry Point

Pages are thin. They extract URL params and orchestrate service calls. Template owns the UI.

```tsx
// pages/anotacoes/index.tsx
import { ReactElement, useState, useCallback } from 'react'
import { GetServerSideProps } from 'next'
import Layout from 'components/organisms/Layout'
import AnotacaoListaTemplate from 'templates/AnotacaoListaTemplate'
import { AnotacaoServices } from 'services/contratoApi/anotacaoServices'
import { useToast } from 'hooks/useToast'
import { IAnotacaoQuery, IGetAnotacaoProps } from 'types/anotacao'
import { IPageResponse } from 'types/common/pagination'

const AnotacoesPage = () => {
  const { addToast } = useToast()
  const [data, setData] = useState<IPageResponse<IAnotacaoQuery>>()
  const [loading, setLoading] = useState(true)

  const handleFilter = useCallback((filter: IGetAnotacaoProps, page: number) => {
    setLoading(true)
    AnotacaoServices.get({ ...filter, page, size: 10 })
      .then(({ data }) => setData(data))
      .catch(() => addToast({ title: 'Erro ao carregar anotações', type: 'error' }))
      .finally(() => setLoading(false))
  }, [addToast])

  return <AnotacaoListaTemplate data={data} loading={loading} onFilter={handleFilter} />
}

AnotacoesPage.getLayout = (page: ReactElement) => (
  <Layout isLoggedIn={true}>{page}</Layout>
)

export default AnotacoesPage
```

**Dynamic route page:**
```tsx
// pages/anotacoes/[id].tsx
const AnotacaoDetalhe = ({ id }: { id: string }) => (
  <AnotacaoDetalheTemplate id={id} />
)

AnotacaoDetalhe.getLayout = (page: ReactElement) => (
  <Layout isLoggedIn={true}>{page}</Layout>
)

export const getServerSideProps: GetServerSideProps = async (ctx) => ({
  props: { id: ctx.query.id as string }
})

export default AnotacaoDetalhe
```

---

## 6. Custom Hook

When data-fetching or event logic is shared by 2+ components.

```ts
// hooks/useContratoVidas.ts
import { useState, useEffect } from 'react'
import { ContratoServices } from 'services/contratoApi/contratoServices'

type VidasMap = Record<string, number>

export function useContratoVidas(contratoIds: string[]) {
  const [vidasMap, setVidasMap] = useState<VidasMap>({})
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (!contratoIds.length) return
    setLoading(true)
    Promise.all(
      contratoIds.map(id =>
        ContratoServices.getNumeroVidas(id).then(({ data }) => ({ id, vidas: data.numeroVidas }))
      )
    )
      .then(results => {
        const map: VidasMap = {}
        results.forEach(({ id, vidas }) => { map[id] = vidas })
        setVidasMap(map)
      })
      .finally(() => setLoading(false))
  }, [contratoIds.join(',')])

  return { vidasMap, loading }
}
```

---

## 7. Badge / Status Rendering

Pattern for rendering status badges inline in table cells.

```tsx
import Badge from 'components/atoms/Badge'
import { SituacaoContrato } from 'types/common/enums'

const situacaoConfig: Record<SituacaoContrato, { label: string; theme: 'success' | 'danger' | 'warning' | 'info' }> = {
  [SituacaoContrato.EM_VIGENCIA]: { label: 'Em Vigência', theme: 'success' },
  [SituacaoContrato.SUSPENSO]:    { label: 'Suspenso',    theme: 'warning' },
  [SituacaoContrato.CANCELADO]:   { label: 'Cancelado',   theme: 'danger' },
  [SituacaoContrato.CADASTRADO]:  { label: 'Cadastrado',  theme: 'info' },
  [SituacaoContrato.ATIVO]:       { label: 'Ativo',       theme: 'success' },
}

export const renderBadgeSituacao = (situacao: SituacaoContrato) => {
  const config = situacaoConfig[situacao]
  return config ? <Badge theme={config.theme}>{config.label}</Badge> : situacao
}
```

---

## 8. AsyncPaginateSelect

Pattern for paginated async selects backed by API.

```tsx
import { AsyncPaginate } from 'react-select-async-paginate'
import { TabelaServices } from 'services/contratoApi/tabelaServices'

type OptionType = { value: string; label: string }

async function loadIdentidadeDeGenero(search: string, _: unknown, { page }: { page: number }) {
  const { data } = await TabelaServices.getIdentidadeDeGenero({ search, page, size: 20 })
  return {
    options: data.content.map(item => ({ value: item.id, label: item.descricao })),
    hasMore: !data.last,
    additional: { page: page + 1 },
  }
}

// Usage in component:
<AsyncPaginate<OptionType, unknown, { page: number }>
  label="Identidade de Gênero"
  loadOptions={loadIdentidadeDeGenero}
  value={selectedOption}
  onChange={(opt) => setFields(prev => ({ ...prev, identidadeDeGenero: opt?.value }))}
  additional={{ page: 0 }}
  debounceTimeout={300}
  placeholder="Selecione..."
/>
```

---

## Common Anti-Patterns to Avoid

| Anti-pattern | Correct approach |
|---|---|
| Hardcoded hex colors in styles | Use `${({ theme }) => theme.colors.primary.default}` |
| `import '../../components/atoms/Button'` | `import Button from 'components/atoms/Button'` |
| `<div style={{ marginTop: '16px' }}>` | Styled-component with `${({ theme }) => theme.spacings.xsmall}` |
| Calling service in JSX render | Call in `useEffect` or event handler |
| Duplicating enum values as strings | Import from `types/common/enums` |
| `console.log` / `console.error` in components | Remove before commit; use `addToast` for user feedback |
| Missing `getLayout` on authenticated pages | Every authenticated page needs `getLayout` with `<Layout isLoggedIn={true}>` |
| Forgetting `typeof window !== 'undefined'` check | Required for any `localStorage`/`document` access outside `useEffect` |
