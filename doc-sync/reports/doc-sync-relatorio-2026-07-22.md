# doc-sync — Relatório 22/Jul/2026

**Snapshot anterior:** 06/Jul/2026 (348.363 bytes) — sem relatório correspondente (o último relatório registrado era de 02-03/Jul/2026; o gap entre 02/Jul e 06/Jul não tem doc-sync associado).
**Snapshot atual:** 22/Jul/2026 (425.661 bytes — `doc-sync/_snapshot_index.html`).

Escopo acordado com o usuário: cobrir **tudo** desde 06/Jul/2026 — 14 commits já publicados (`d479e78`...`be6ce5d`) mais as mudanças desta sessão (Kanban por Área + reescrita do export PDF), tratadas como "já commitadas" a pedido do usuário.

---

## Mudanças documentadas

### 1. Aba Áreas: Gantt → Kanban (14/Jul e sessão de hoje)
A aba passou de um Gantt de barras para um **Kanban semanal** com cards coloridos por fornecedor (coloração gulosa por co-ocorrência — nunca duas cores iguais na mesma área). Documentado pela primeira vez o fato técnico não óbvio de que a aba considera **apenas** o eixo `AREAS_EIXO_NOME` ('MONTAGEM DE EXPO DE LONGA') — tarefas de outros eixos nunca aparecem ali, mesmo com colunas de área marcadas na planilha.

- **Manual de Uso** — novas §3.6 (Busca no Gantt), §3.7 (Aba Áreas — Visualização Kanban), §3.8 renomeada (Exportar Kanban por Área em PDF, era "Exportar Gantt...")
- **Guia Técnico Unificado** — seção "Aba Áreas" reescrita: `_buildKanbanSVGForExport`, `_fornColor`/`_FORN_PALETTE`, `_buildAreasData` (campo fornecedor), restrição `AREAS_EIXO_NOME`
- **ONBOARDING.md** — mesma seção reescrita com o aviso de escopo em destaque
- **DEV_GUIDE.html** — novo "Grupo 7 — Aba Áreas (Kanban)": RN-16 (restrição de eixo) e RN-17 (paginação + quebra de texto no export)

### 2. Export PDF da aba Áreas: grade cronológica + 1 área por página (sessão de hoje)
`_buildGanttSVGForExport` → `_buildKanbanSVGForExport`. Cards em ordem de data preenchendo a página (sem repetir por semana como na tela). Cada área força nova página — nunca duas dividem a mesma folha. Arquivo passou de `Gantt_*.pdf` para `Kanban_*.pdf`.

- Documentado nos 4 arquivos (Manual, Guia Técnico, ONBOARDING, DEV_GUIDE).

### 3. Armadilha nova: quebra de texto em SVG/PDF (sessão de hoje)
Estimar caracteres por linha subestima maiúsculas em negrito e o texto vaza a caixa no PDF. Corrigido com `canvas.measureText()` (helpers `_mw`/`_fitOne`/`_wrapW`).

- **Guia Técnico Unificado** e **ONBOARDING.md** — linha antiga e obsoleta "`exportN2PPT()` sem pptxgenjs" (pptxgenjs não existe mais desde 13/Jul) foi **reaproveitada** para esta armadilha nova, em vez de deixar as duas.
- **DEV_GUIDE.html** — RN-17 (junto com a paginação).

### 4. N2 — "Resumo Executivo" editável no export (14–21/Jul)
O export da Pauta N2 (`exportN2PPT()`, nome mantido por compatibilidade — segue gerando `.html`, nunca gerou pptx desde meados de 2026) ganhou um resumo executivo editável, com salvar versionado (v2, v3...), regenerar, e "copiar prompt p/ IA".

- **Manual de Uso** — §4.5 reescrita (o texto antigo ainda dizia ".pptx", que já estava desatualizado antes desta sessão)
- **Guia Técnico Unificado** e **ONBOARDING.md** — novas linhas/seção com `_buildN2HTMLDoc()` e as funções `_exp*` (`_expEditarResumo`, `_expSalvarResumo`, `_expRegerarResumo`, `_expCopiarPrompt`)

### 5. Botão "Limpar N2" ganhou confirmação (16/Jul)
Antes limpava direto; agora abre modal ("Sim, limpar" / cancelar) via `n2ConfirmClear`/`n2ConfirmDo`.

- **Manual de Uso** e **ONBOARDING.md** atualizados.

### 6. Busca adicionada nas abas Gantt e Gantt Diretoria (16/Jul)
`searchInput-gantt` / `searchInput-gantt-dir`, mesmo padrão de Status Report/Áreas.

- **Manual de Uso** (nova §3.6) e **ONBOARDING.md**.

### 7. Cores de status trocadas (09–17/Jul)
"Feito" verde→**azul**, "Em andamento" azul→**verde**, "Risco de atraso" laranja→**amarelo**.

- **Manual de Uso** — tabela de Legenda de Cores (texto + `w:fill` do swatch); usei texto escuro no swatch amarelo para legibilidade (branco sobre amarelo claro ficava ilegível, diferente do resto da tabela).
- **DEV_GUIDE.html** — CSS vars, dots da legenda, badges do ranking de prioridade, tabela de auto-correção e modais de detalhe de cada status. `--warn`/`--info` (cores genéricas reaproveitando os mesmos hex por coincidência) foram deixadas intactas — não são cor de status.
- **Guia Técnico Unificado** e **ONBOARDING.md** não têm tabela de cores (fica só no Manual/DEV_GUIDE) — nada a mudar ali.

### 8. Requisições — reagrupamento dinâmico (06/Jul)
Substituiu os 4 grupos fixos (COTAÇÃO/COMPRAS/NÃO INICIADA/CANCELADA) por 2 blocos dinâmicos (COMPRAS/COTAÇÃO) com subquadros só quando há itens naquele status.

- **Manual de Uso** (§5.4) e **ONBOARDING.md** atualizados.

---

## Sem ação necessária

- **UTC-3 fix + remoção de `fetchSheetColors('B')` morto (13/Jul)** — já autodocumentado no próprio commit (`ONBOARDING.md` e `CLAUDE.md` atualizados na hora). Não repetido aqui.
- **Favicon (18/Jul)** — cosmético, não documentado.
- **Ficha Técnica** — nenhuma mudança de URL, ID de planilha ou dependência externa nesta leva. Não tocada.
- Dois commits (`update cowork`, `update` — 15/Jul) não foram aprofundados; pelo tamanho do diff pareciam ajuste interno, não impacto de doc.

## PDFs

Não gerados — regra 6 do `CLAUDE.md` (decisão Jul/2026): doc-sync produz só `.docx`. Quem precisar do PDF exporta manualmente.

## Validação técnica dos .docx

Os dois arquivos Word foram editados via `unzip` → manipulação direta do `word/document.xml` (DOM, sem reescrever o documento) → `validate.py` (checagem XSD) antes de substituir os arquivos em `Manual/`. Sem LibreOffice/pandoc disponíveis neste ambiente para gerar um preview visual em imagem — a verificação foi por re-extração estruturada do texto (headings, tabelas, estilo de cada parágrafo) e contagem de bookmarks/cores antes/depois.

Um bug foi pego e corrigido durante a revisão antes de entregar: os parágrafos de corpo das novas seções 3.6/3.7 do Manual de Uso tinham herdado o estilo de heading (Ttulo2) por engano ao clonar o heading errado como template — corrigido clonando de um parágrafo normal antes de gravar a versão final.

---

## Documentos atualizados

| Documento | Versão | Alteração |
|---|---|---|
| Manual de Uso Dashboard | v11 → **v12** | Legenda de cores, +3.6/+3.7, 3.8 renomeada, §4.5 N2 reescrita, §5.4 nota REQS, nota header sticky |
| Guia Técnico Unificado | v1 → **v2** | Aba Áreas Kanban, N2 HTML+Resumo Executivo, 2 armadilhas (1 nova, 1 substituída), histórico de revisões |
| ONBOARDING.md | in-place | Mesmas seções técnicas do Guia Técnico, adaptadas ao formato do arquivo |
| DEV_GUIDE.html | in-place (`DEV_GUIDE_v2.html`) | Grupo 7 (RN-16/RN-17), cores de status em CSS vars/dots/badges/tabela/modais |
| Ficha Técnica | v4 (sem mudança) | — |

Versões antigas movidas para `Manual/old_versions/`. Snapshot atualizado em `doc-sync/_snapshot_index.html`.

**Não commitado** — nenhum `git add`/`commit`/`push` executado, conforme regra.

---

*Executado em 22/Jul/2026 — doc-sync (escopo estendido 06→22/Jul a pedido do usuário)*
