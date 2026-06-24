# AGENTS.md — maz-dashboard

Instruções para o Codex ao trabalhar nesta pasta.

## O que é este projeto

Dashboard HTML interativo do projeto **Museu das Amazônias 2026**, publicado via GitHub Pages.
Usado pelo time de PMO para acompanhar cronograma e requisições do projeto.

**URL pública:** https://pmo-creator.github.io/maz-dashboard/

## Estrutura da pasta

```
maz-dashboard/                  ← PASTA ÚNICA (git repo + tudo)
  index.html                    → Dashboard desktop (~330KB)
  mobile.html                   → Dashboard mobile (~43KB)
  Consulte ONBOARDING.md seção 7 ou 10 apenas se a tarefa envolver filtros específicos ou feature N2
  SERVE_DASHBOARD.bat           → Servidor local para preview (duplo-clique)
  AGENTS.md                     → Este arquivo
  doc-sync/                     → Skill de sincronização de documentação
    SKILL.md                    → Lógica da skill doc-sync (fonte de verdade)
    context.md                  → Contexto técnico do dashboard
    _snapshot_index.html        → Snapshot do último doc-sync (autoritativo)
    doc-sync.skill              → Bundle instalável para Cowork
    reports/                    → Relatórios de cada execução
  Manual/                       → Documentação (versionada no git)
    DEV_GUIDE.html              → Guia técnico do desenvolvedor
    Manual de Uso e Manutenção Dashboard_v7.docx + .pdf
    Guia de Onboarding_Manutençao Dashboard_MAZ_2026_v12.docx + .pdf
    Ficha_Tecnica_Dashboard_MAZ_2026_v3.docx + .pdf
    old_versions/               → Versões anteriores arquivadas
  00. Apoio/                    → Logos e banners
```

## Ambiente local

- **Caminho local do repo:** `C:\Users\gagui\GitHub\maz-dashboard`
- **⚠️ Não usar OneDrive** — o OneDrive corrompe a pasta `.git` ao sincronizar arquivos internos do git
- **Branches:**
  - `main` → produção (GitHub Pages) — protegido, exige PR para merge
  - `dev` → branch de trabalho padrão — todas as edições vão aqui

## Regras de trabalho

1. **Consultar ONBOARDING.md apenas se a tarefa envolver filtros, WBS ou feature N2** — e somente a seção relevante, nunca o arquivo completo.

2. **NUNCA rodar `git add`, `git commit` ou `git push` sem instrução explícita
   do usuário.** Esta é a regra mais importante — violar causa publicação acidental
   em produção.

3. **Editar index.html/mobile.html via Python str.replace() no bash**, nunca com
   o Edit tool — arquivos grandes truncam.

4. **Novos relatórios doc-sync** → salvar sempre em `doc-sync/reports/`.

5. **Versões antigas de documentos** → mover para `Manual/old_versions/` ao criar nova versão.

6. **PDF obrigatório** → toda geração de `.docx` deve produzir um `.pdf`
   correspondente na mesma pasta, no mesmo ato.

7. **Servidor local** → rodar `SERVE_DASHBOARD.bat` (duplo-clique) para preview antes
   de commitar. Ele abre http://localhost:8000 e não interfere com git.

8. **Scripts temporários** → deletar imediatamente após uso.

9. **Lógica crítica exige revisão manual antes de aceitar** — especialmente:
    `_parseWBS`, `_worstStatus`, `preprocessStatuses`, `matchesFilter`.
    "Parece certo" não é critério de aceite.

## Como rodar o doc-sync

Invocar a skill `doc-sync` diretamente no chat Cowork com maz-dashboard montado.

## Índice de Funções — index.html

### 🔧 Utilitários (734–861)
fmtBR, fmtBRshort, escH, escSVG, getISOWeek, hl, abrevNome

### ⏳ Loading / Estado UI (822–826)
showLoading, hideLoading, showConnErr, hideConnErr, retrySheets

### 🗂️ Navegação (835)
switchTab

### 🔍 Filtros (870–1629)
buildRespFilter, getFilters, dateInRange, matchesFilter,
resetAllFilters, clearDates, applyFilter, updateFilterChip,
setFilterLevel, toggleModoEstrito, updatePeriodoBtn

### 📊 KPIs e Charts (914–1052)
renderKPIs, renderCharts, preprocessStatuses

### 🌳 Árvore WBS / EAP (1367–1539)
renderTree, toggleRoot, toggleGroup, toggleComment,
toggleMarco, expandAll, collapseAll, buildCommentPanel,
expandAllEixosEAP, expandAllMarcosEAP, expandAllTarefasEAP

### 📋 N2 Pauta (1114–1247)
loadN2, saveN2, toggleN2Marco, updateN2Fab,
clearN2Selection, applyN2Filter, publishN2Pauta, unlockN2Edit

### 🛒 Requisições (1702–1953)
buildReqStatusDropdown, buildReqFornDropdown,
renderReqKPIs, renderReqs, toggleReqs, clearReqFilters

### 📅 Gantt (1960–2480)
renderGanttSection, toggleGantt, toggleGanttGroup,
expandAllGantt, renderGanttForEixo, setGanttMode,
expandAllTarefasGantt, expandLevel

### 🗺️ Áreas (2736–2963)
buildAreasFilter, renderAreasTab, renderAreaGantt,
toggleAreaSection, toggleAreaMarco, setAreasGanttMode

### ☁️ Google Sheets / Dados (2509–2654)
fetchSheet, fetchSheetColors, loadSheetsData,
_parseWBS, _parseREQS, _sg, _fmtDate, _worstStatus

### 📄 Export PDF (3145–3311)
openExportPDFWizard, pdfWizNext, pdfWizBack,
_runExportPDF, _buildGanttSVGForExport


## Fontes de dados do dashboard

- Cronograma: Google Sheets `17nttJ_ShqWztvDWH3l59iNqboLqkviZs3_PM5J3ihdA` — aba `master data`
- Requisições: Google Sheets `1azrdS4OGO-CWD1ods69i8iZJcwq4oyISdT2n_tm1uJM` — aba `Planilha de Status de Compras Prod`


## ⚡ Riscos de Token — maz-dashboard

Arquivos pesados conhecidos — nunca ler inteiro sem autorização:
- `index.html` (~330KB / ~3.462 linhas) → usar `grep`, `sed` ou busca por âncora
- `mobile.html` (~43KB) → idem
- `ONBOARDING.md` → ler só a seção relevante, não o arquivo completo
- `Manual/*.docx` → nunca abrir direto — usar PDF ou extração pontual

Antes de qualquer operação nesses arquivos, aplicar regra do Token Management global:
perguntar + listar alternativas leves.

## Roteamento de Edições — index.html / mobile.html

Antes de editar, classificar a mudança:

- **Visual** (cor, fonte, espaçamento, ícone)
  → `grep -n "nome-da-classe" index.html` → editar só esse trecho do `<style>`

- **Lógica** (cálculo, filtro, status, regra de negócio)
  → `grep -n "nomeDaFuncao" index.html` → editar só esse trecho do `<script>`

- **Estrutura HTML** (nova coluna, novo card, novo bloco)
  → Python str.replace() com âncora mínima (~10 linhas únicas ao redor)
  → NUNCA ler o arquivo inteiro para mudança pontual

Regra universal: grep primeiro, editar depois. Nunca abrir o arquivo completo.

## Armadilhas Técnicas — index.html
| Armadilha | Como evitar |
|---|---|
| Dashboard branco sem erro | null bytes, `function` ausente, JS truncado, template literals aninhados |
| Template literals aninhados | Nunca crase dentro de `${}` dentro de outro crase |
| JS truncado | Verificar `</script>` no final antes de editar |
| Prioridade REQS | Usar coluna D (índice 3) — nunca coluna B |
| `node --check` | Extrair bloco `<script>` para `.js` temporário |
| Edit tool falha | Usar PowerShell `ReadAllBytes` em vez do Edit tool |
| String não encontrada | Normalizar CRLF: `.Replace("\`r\`n", "\`n")` antes de substituir |
