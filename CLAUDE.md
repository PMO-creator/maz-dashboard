# CLAUDE.md

This file provides guidance to Claude when working with this repository.

## O que é esta pasta

Este é o **repositório git** do Dashboard MAZ 2026 — fonte de produção publicada via GitHub Pages.

**Edições de código NÃO acontecem aqui.** O fluxo é:
```
Ambiente de Teste_Dashboard/ → editar → testar → copiar para cá → git commit → git push
```

## Para novos desenvolvedores

**Comece pelo `ONBOARDING.md`** nesta pasta — cobre arquitetura, fluxo de trabalho completo e armadilhas conhecidas.

Os manuais de uso (PDF) ficam em `Ambiente de Teste_Dashboard\01. Manuais\`.

## Estrutura do repo

```
index.html          → dashboard desktop (single-file, ~332KB)
mobile.html         → dashboard mobile (~43KB)
DEV_GUIDE.html      → guia técnico (publicado no GitHub Pages)
ONBOARDING.md       → onboarding para novos devs — leia primeiro
.claude/
  doc_sync/         → skill doc-sync + _snapshot_index.html + context.md
  code_audit/       → skill de auditoria de código (ver abaixo)
```

**Não devem estar nesta pasta:** scripts de dev (SERVE_DASHBOARD.bat), PDFs de manuais.
Esses ficam em `Ambiente de Teste_Dashboard\`.

### Skill code_audit

Auditor educativo de código para **Claude Code** (não Cowork). Analisa o `git diff` antes de cada push e reporta problemas de segurança, arquitetura, qualidade e boas práticas git — com severidade 🔴🟡🟢 e explicação educativa (o que é, por que é problema, como corrigir).

**Quando é sugerida automaticamente:** antes de commit/push, ao adicionar dependência externa (CDN, biblioteca), ao mexer em API key, após mudanças grandes (3+ funções).

**Como acionar manualmente (linguagem natural no Claude Code):**
- `"audita o que mudou"` → analisa só o git diff atual (leve)
- `"resumo do projeto"` → lê só o CLAUDE.md, resume o estado (leve)
- `"auditoria completa"` → lê todos os arquivos (pesado — usar com moderação)

**Referências:** `.claude/code_audit/references/` — segurança, arquitetura, código, fluxo git, dependências.

## Publicar no GitHub Pages

```powershell
cd C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard
git add index.html mobile.html   # adicionar outros arquivos se necessário
git commit -m "descrição da mudança"
git push
```
GitHub Pages atualiza automaticamente em ~1 minuto.

## Arquitetura

Dois arquivos HTML self-contained: `index.html` (desktop) e `mobile.html` (mobile). Cada um contém todo o HTML, CSS e JS inline — sem módulos, sem build step, sem dependências locais.

- Dados via Google Sheets API diretamente no browser — sem backend
- Chart.js carregado via CDN para gráficos
- Gantt renderizado em SVG gerado dinamicamente
- Publicado em GitHub Pages: `pmo-creator.github.io/maz-dashboard`
- Auto-redirect: `index.html` → `mobile.html` se `userAgent` mobile OU `innerWidth ≤ 768`; inverso no `mobile.html`

## Abas

**Desktop (`index.html`):** `gantt` · `eap` (Status Report) · `reqs` (Requisições)
**Mobile (`mobile.html`):** `gantt` · `report` (Status Report) · `reqs` (Requisições)

A aba `reqs` esconde a filter-bar de status/responsável (só aparece nas abas de cronograma).

## Fluxo de dados e renderização

**Dado estático embutido** — `const WBS = [...]` está hardcoded no HTML (~linha 755 do `index.html`). É exibido imediatamente no `window.onload` enquanto a API ainda não respondeu.

**Dado dinâmico** — `loadSheetsData()` faz fetch das duas planilhas, substitui o conteúdo de `WBS` e `REQS` in-place (`.length=0` + push), depois re-renderiza tudo.

**Ordem de chamada no `window.onload`:**
```
preprocessStatuses() → buildGroupFilter() → buildRespFilter() → renderKPIs() →
renderTree() → buildReqFilters() → renderReqKPIs() → renderReqs() →
renderGanttSection() → switchTab('gantt') → loadSheetsData()
```

Após `loadSheetsData()` bem-sucedido, a mesma sequência de render é repetida com dados frescos. Um `setInterval` de 15 min reinicia o ciclo automaticamente.

## Funções-chave

| Função | Responsabilidade |
|---|---|
| `preprocessStatuses()` | Auto-corrige status por data: vencido → `Atrasado`; vence em ≤7 dias → `Risco de atraso`; propaga worst-status de subtasks para marcos e grupos |
| `_parseWBS(rows)` | Transforma linhas brutas do Sheet em árvore `EIXO → GRUPO → MARCO → TAREFA` |
| `_findWeekCols(rows)` | Detecta dinamicamente as colunas da semana atual buscando "ATUALIZA" no header row 0; retorna `{pC, eC, weekLabel}` |
| `_parseREQS(rows)` | Transforma linhas do sheet de Requisições em array de objetos |
| `renderTree()` | Renderiza a aba Status Report (EAP) com accordion de eixos/grupos/marcos |
| `renderGanttSection()` | Cria os headers colapsáveis do Gantt (lazy: não renderiza o SVG ainda) |
| `renderGanttForEixo(gi)` | Renderiza o SVG do Gantt de um eixo específico — chamado só quando o usuário expande |
| `renderKPIs()` | KPI cards da aba de cronograma |
| `renderReqs()` | Lista de requisições com filtros |
| `buildCommentPanel()` | Painel lateral de progresso/encaminhamento de um marco |
| `setFilterLevel(level)` | Alterna `filterLevel` entre `'marco'` e `'tarefa'`; chama `applyFilter()` |

## Variáveis globais relevantes (index.html)

| Variável | Valores | Efeito |
|---|---|---|
| `ganttMode` | `'monthly'` · `'weekly'` | Escala de tempo do Gantt |
| `filterLevel` | `'marco'` · `'tarefa'` | Nível de filtragem: marco filtra pelo status do marco; tarefa filtra pelas tarefas dentro do marco expandido |

## Mapeamento de colunas do Google Sheet (cronograma)

Linhas 0 e 1 = cabeçalhos; dados a partir da linha 2.

| Índice | Conteúdo |
|---|---|
| 1 (CE) | Eixo |
| 2 (CG) | Grupo |
| 3 (CM) | Marco |
| 4 (CT) | Tarefa |
| 6 (CR) | Responsável |
| 7 (CS) | Status |
| 8 (CST) | Data início |
| 9 (CEN) | Data fim |
| pC (dinâmico) | Progresso da semana atual |
| eC (dinâmico) | Encaminhamento da semana atual |

## Mapeamento de colunas do Google Sheet (requisições)

| Índice | Conteúdo |
|---|---|
| 0 | N. Requisição |
| 1 | Comprador |
| 3 | Prioridade ← USAR APENAS ESTA (col B gera falsos positivos) |
| 4 | Descrição |
| 5 | Status |
| 6 | Fornecedor |
| 12 | Data prevista |

## Estrutura WBS (hierarquia de dados)

```
EIXO → GRUPO → MARCO → TAREFA
```

## Mapeamento CSS → Hierarquia (CRÍTICO)

| Nome | Classe CSS |
|---|---|
| EIXO | `.eixo-name` |
| GRUPO | `.grupo-name` |
| MARCO | `.marco-name` |
| TAREFA | `.tarefa-name` |

## Status válidos e ranking (pior→melhor)

`Atrasado` · `Risco de atraso` · `Em andamento` · `Definir datas` · `A iniciar` · `Feito` · `Cancelado/Congelado`

> Ranking para rollup: Atrasado(0) > Risco(1) > Em andamento(2) > Definir datas(3) > A iniciar(4) > Feito(5) > Cancelado(6)

## Google Sheets

| Planilha | ID | Aba |
|---|---|---|
| Cronograma | `17nttJ_