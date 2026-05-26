# CLAUDE.md — maz-dashboard

Instruções para o Claude ao trabalhar nesta pasta.

## O que é este projeto

Dashboard HTML interativo do projeto **Museu das Amazônias 2026**, publicado via GitHub Pages.
Usado pelo time de PMO para acompanhar cronograma e requisições do projeto.

**URL pública:** https://pmo-creator.github.io/maz-dashboard/

## Estrutura da pasta

```
maz-dashboard/                  ← PASTA ÚNICA (git repo + tudo)
  index.html                    → Dashboard desktop (~330KB)
  mobile.html                   → Dashboard mobile (~43KB)
  ONBOARDING.md                 → Leia primeiro — contexto técnico para Claude e devs
  SERVE_DASHBOARD.bat           → Servidor local para preview (duplo-clique)
  CLAUDE.md                     → Este arquivo
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

## Regras de trabalho

1. **Leia ONBOARDING.md antes de qualquer tarefa técnica** — ele tem mapeamento
   de colunas, regras de auto-status, armadilhas conhecidas e estrutura WBS.

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

## Como rodar o doc-sync

Invocar a skill `doc-sync` diretamente no chat Cowork com maz-dashboard montado.

## Fontes de dados do dashboard

- Cronograma: Google Sheets `17nttJ_ShqWztvDWH3l59iNqboLqkviZs3_PM5J3ihdA` — aba `master data`
- Requisições: Google Sheets `1azrdS4OGO-CWD1ods69i8iZJcwq4oyISdT2n_tm1uJM` — aba `Planilha de Status de Compras Prod`
