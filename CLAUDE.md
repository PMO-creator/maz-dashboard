# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Ambiente de trabalho

Esta é a pasta de **teste e desenvolvimento**. Os arquivos editados aqui são copiados para `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard` para commit e push no GitHub.

**Fluxo:**
```
maz-dashboard (git pull) → copiar para cá → editar → testar → copiar de volta → commit/push
```

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

## Estrutura WBS (hierarquia de dados)

```
EIXO → GRUPO → MARCO → TAREFA
```

> ⚠️ **Deduplicação PER EIXO** — mesmo nome de grupo em eixos diferentes = entradas separadas. NUNCA deduplicar globalmente.  
> ⚠️ **Linha-resumo do grupo** — linha onde `Tarefa == Grupo` é o summary row; não é uma tarefa normal.  
> ⚠️ **Comentários da planilha** — NUNCA resumir ou parafrasear; sempre exibir texto bruto.

## Mapeamento CSS → Hierarquia (CRÍTICO)

| Nome | Classe CSS |
|---|---|
| EIXO | `.eixo-name` |
| GRUPO | `.grupo-name` |
| MARCO | `.marco-name` |
| TAREFA | `.tarefa-name` |

## Status válidos e cores CSS

| Status | CSS var | Hex | Nota |
|---|---|---|---|
| Atrasado | `--atraso` | `#FF2525` | |
| Risco de atraso | `--risco` | `#FF6B00` | |
| Em andamento | `--andam` | `#1A56FF` | |
| A iniciar | `--iniciar` | `#5A6E85` | |
| Definir datas | `--definir` | `#92400E` | ⚠️ MARROM — não roxo |
| Feito | `--feito` | `#05C46B` | |
| Cancelado/Congelado | `--cancel` | `#374151` | |

**Paleta de destaque:** `--accent:#8AC43A` (verde) · `--accentD:#6BA030` (hover) · `--bg:#1E2E0D` (header escuro)

**Rollup (pior ganha):** Atrasado(0) > Risco(1) > Em andamento(2) > A iniciar(3) > Definir datas(4) > Feito(5) > Cancelado(6)

## Google Sheets

| Planilha | ID | Aba |
|---|---|---|
| Cronograma | `17nttJ_ShqWztvDWH3l59iNqboLqkviZs3_PM5J3ihdA` | `master data` |
| Requisições | `1azrdS4OGO-CWD1ods69i8iZJcwq4oyISdT2n_tu1uJM` | `Planilha de Status de Compras Prod` |

## API Key

- Restrita a `pmo-creator.github.io/*`
- Localhost retorna 403 propositalmente — comportamento esperado

## ⚠️ Armadilhas críticas

1. **Dashboard branco sem erro** → checar: null bytes, `function` ausente, JS truncado, template literals aninhados
2. **Template literals aninhados** → nunca backtick dentro de `${}` dentro de outro backtick
3. **Prioridade REQS** → APENAS col E (índice 4) — col B gera falsos positivos
4. **`node --check` Node v22** → não aceita `.html` — extrair para `.js` temporário
5. **Edit tool com backticks** → falha ao fazer match — usar PowerShell `[System.IO.File]` para substituições
6. **CRLF** → normalizar com `.Replace("\`r\`n", "\`n")` antes de substituições PowerShell
7. **Dado estático vs. dinâmico** → editar o WBS hardcoded no HTML só para testes rápidos; o dado real vem do Sheet e sobrescreve tudo no load
8. **Gantt é lazy** → `renderGanttSection()` não gera SVG; só `renderGanttForEixo(gi)` gera — chamado ao expandir o eixo

## Comandos de Desenvolvimento

**Servidor local:**
```
SERVE_DASHBOARD.bat
```
Ou manualmente: `python -m http.server 8765` → abrir `http://localhost:8765/index.html`

**Validar JS extraído de HTML:**
```powershell
$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)
$matches = [regex]::Matches($html, '(?s)<script>(.*?)</script>')
$main = $matches | Sort-Object { $_.Groups[1].Value.Length } | Select-Object -Last 1
[System.IO.File]::WriteAllText("$env:TEMP\check.js", $main.Groups[1].Value, [System.Text.Encoding]::UTF8)
node --check "$env:TEMP\check.js"
```

**Copiar para o repo e publicar:**
```powershell
copy index.html  "..\maz-dashboard\index.html"
copy mobile.html "..\maz-dashboard\mobile.html"
# Depois: cd ..\maz-dashboard → git add → git commit → git push
```

9. **Arquivos temporários** → permitido criar `_fix_*.py`, `_tmp_*.py` ou qualquer script auxiliar durante a sessão. **Obrigatório deletar com `Remove-Item` imediatamente após uso.** A pasta deve conter apenas: `index.html`, `mobile.html`, `SERVE_DASHBOARD.bat`, `CLAUDE.md`, `ONBOARDING.md`, `01. Manuais\`.
10. **`_forceCollapseEAP`** → além de resetar state, deve fechar no DOM: `.subtask-container` com `maxHeight='0'` e `[id^="mchev-"]` com `transform='rotate(-90deg)'`. Sem isso, trocar de visualização não fecha subtasks abertas.
11. **Header z-index** → manter `z-index:1000`. Se baixar, search-zone (`z-index:100`) fica por cima dos dropdowns do header.

---

## Skill doc-sync (sincronização automática de documentação)

Os arquivos da skill vivem em `.claude\doc_sync\` neste repo.

- **Invocar manualmente:** Abrir Claude Cowork e digitar `"doc-sync"` ou `"atualizar docs"`
- **Scheduled task:** Configurado para rodar automaticamente às 08:00 todos os dias
- **O que faz:** Compara `index.html` com o snapshot anterior (`.claude\doc_sync\_snapshot_index.html`), classifica mudanças como RELEVANTE ou IGNORAR, apresenta em linguagem de leigo, e atualiza os manuais após aprovação

**Para configurar o scheduled task em nova instalação:**
1. Abrir Claude Cowork
2. Digitar: `"Configurar doc-sync para rodar todo dia às 08:00"`

**Documentação completa:** `Guia de Onboarding_Manutençao Dashboard_MAZ_2026_v10.docx §10`

**Documentos mantidos pela skill:**

| Documento | Versão | Público-alvo |
|---|---|---|
| Manual de Uso e Manutenção Dashboard | v6 | Gestores, equipe IDG (não-técnico) |
| Guia de Onboarding — Manutenção | v10 | Dev que vai manter o código |
| Ficha Técnica Dashboard | v3 | Stakeholders, TI |
| Guia do Usuário Final | v2 | Equipe da exposição (leigo total) |

Pasta dos documentos: `C:\Users\gagui\OneDrive\Documentos\Claude\Projects\IDG - Relatórios de Análise\Manual\`