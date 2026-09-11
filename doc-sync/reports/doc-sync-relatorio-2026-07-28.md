# Relatório doc-sync — 28/07/2026

## Observação inicial
O `_snapshot_index.html` tinha data de arquivo 15/07, mas seu conteúdo batia com o
commit `2329b9b` (03/07/2026) + o patch do cadeado de senha da aba EAP. O período
efetivamente coberto por este ciclo foi **03/07 a 22/07** (24 commits no index.html).

## Mudanças no dashboard identificadas (index.html)
1. Cor do status "Risco de atraso": laranja → amarelo
2. Cores dos mini-cards de KPI "Feito"/"Em andamento" trocadas — **confirmado com o
   usuário que foi intencional**, não é bug
3. Cor do Eixo fixa em cinza (`EIXO_FIXED_COLOR = '#949494'`), não vem mais da coluna B da planilha
4. Correção de fuso horário (UTC-3) no Gantt/PDF via `_pLocal()`
5. Export N2 da Diretoria: parou de gerar `.pptx` (pptxgenjs removido), usa o mesmo export HTML navegável da N2 comum
6. Novo "Resumo Executivo" no export N2 (texto automático/editável, versionamento, prompt IA, filtros e busca no arquivo exportado)
7. Nova barra de busca nas abas Gantt, Gantt Diretoria e Áreas
8. Aba Áreas (Kanban): cartões coloridos por Fornecedor
9. Botão "Exportar PDF" nas abas Gantt/Gantt Diretoria com wizard de seleção de grupos
10. Pauta N2: checkbox para marcar/desmarcar de uma vez todos os marcos de um grupo (`toggleN2Group`)
11. Botão "Limpar N2" com modal de confirmação antes de apagar

## O que já estava documentado (verificado antes de editar)
Ao conferir os `.docx` atuais, a maior parte das mudanças **já tinha sido
documentada** no commit `c5d8066` ("Atualização de documentos 22.07"), feito horas
depois do último commit do dashboard no mesmo dia. Já cobertos: itens 1, 2, 5, 6, 7
(Gantt/Diretoria — Áreas também, verificado depois), 8, 9, 11.

## Edições aplicadas neste ciclo (gaps reais)
Apenas 3 documentos, 4 edições cirúrgicas:

- **Ficha Técnica** (`v4` → `v5`): linha "N2 PPT" renomeada para "N2 HTML" e
  descrição atualizada (não gera mais `.pptx`)
- **Guia Técnico Unificado** (`v2` → `v3`): 2 novas linhas na tabela de Armadilhas
  Técnicas Conhecidas — cor do Eixo fixa (não vem mais da coluna B) e correção de
  fuso horário `_pLocal()`/UTC-3
- **Manual de Uso Dashboard** (`v12` → `v13`): passo 1 da Pauta N2 atualizado para
  mencionar o checkbox de marcar todos os marcos de um grupo de uma vez

`ONBOARDING.md` e `DEV_GUIDE_v2.html` não precisaram de alteração — já cobrem os
pontos técnicos relevantes deste ciclo (ou nunca tiveram informação desatualizada
sobre eles).

## PDFs
Não gerados — decisão do projeto (Jul/2026, CLAUDE.md): doc-sync produz só `.docx`;
PDF é exportado manualmente por quem for consumir o documento.

## Snapshot
Atualizado para o `index.html` atual (commit `be6ce5d`, 22/07/2026).

## Versões antigas arquivadas
`Manual/old_versions/`: `Ficha_Tecnica_Dashboard_MAZ_2026_v4.docx`,
`Guia Tecnico Unificado_MAZ_2026_v2.docx`, `Manual de Uso Dashboard_v12.docx`
