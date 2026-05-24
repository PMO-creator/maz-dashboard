# context.md — Dashboard MAZ 2026
> Fundação da skill `doc-sync`. Leia este arquivo antes de qualquer operação de atualização de documentação.
> Última atualização: Mai/2026

---

## 1. O que é este projeto

**Museu das Amazônias (MAZ) 2026** é uma exposição de longa duração gerenciada pelo IDG (Instituto de Desenvolvimento e Gestão). O dashboard é uma ferramenta interna de gestão de projetos que exibe o cronograma, status, requisições e indicadores da exposição em tempo real.

- **URL pública (desktop):** https://pmo-creator.github.io/maz-dashboard/
- **URL pública (mobile):** https://pmo-creator.github.io/maz-dashboard/mobile.html
- **Repositório GitHub:** https://github.com/PMO-creator/maz-dashboard
- **Conta GitHub:** pmo-creator (exposicoeseprojetos@gmail.com)

---

## 2. Arquitetura técnica

| Componente | Detalhe |
|---|---|
| Hospedagem | GitHub Pages — branch `main` |
| Arquivo desktop | `index.html` (single-file, ~332KB) |
| Arquivo mobile | `mobile.html` (~43KB) |
| Dados WBS | Google Sheets API v4 — leitura ao vivo pelo browser |
| Dados REQS | Google Sheets API v4 — leitura ao vivo pelo browser |
| Auto-refresh | 15 minutos (`AUTO_REFRESH_MS = 15 * 60 * 1000`) |
| Biblioteca de gráficos | Chart.js 4.5.1 via CDN |
| Sem build, sem framework | HTML + CSS + JS vanilla, tudo em arquivo único |

### Planilhas Google Sheets

| Dado | ID da Planilha | Aba |
|---|---|---|
| Cronograma (WBS) | `17nttJ_ShqWztvDWH3l59iNqboLqkviZs3_PM5J3ihdA` | `master data` |
| Requisições (REQS) | `1azrdS4OGO-CWD1ods69i8iZJcwq4oyISdT2n_tu1uJM` | `Planilha de Status de Compras Prod` |

### Colunas do Cronograma (índices 0-based)

| Coluna | Índice | Campo |
|---|---|---|
| B | 1 | Eixo |
| C | 2 | Grupo |
| D | 3 | Marco |
| E | 4 | Tarefa |
| G | 6 | Responsável |
| H | 7 | Status |
| I | 8 | Data início |
| J | 9 | Data fim |
| AL | 36 | Progresso (coluna dinâmica — detectada por `_findWeekCols`) |
| AM | 37 | Impacto (coluna dinâmica) |
| AN | 38 | Encaminhamento (coluna dinâmica) |

### Colunas das Requisições (índices 0-based)

| Coluna | Índice | Campo |
|---|---|---|
| A | 0 | N. Requisição |
| C | 2 | Comprador |
| E | 4 | Prioridade ← USAR APENAS ESTA |
| F | 5 | Descrição |
| G | 6 | Status |
| H | 7 | Fornecedor |
| M | 12 | Data prevista |

> ⚠️ Prioridade: usar APENAS coluna E (índice 4). Coluna B gera falsos positivos.

---

## 3. Estrutura do WBS (hierarquia de dados)

```
Projeto MAZ 2026
└── Eixo (9 eixos)
    └── Grupo (48 grupos no total — deduplicação PER EIXO)
        └── Marco
            └── Tarefa (subtask)
```

### Regras críticas de parsing

- **Deduplicação per eixo:** mesmo nome de grupo em eixos diferentes = entradas separadas (nunca deduplicar globalmente)
- **Linha-resumo do grupo:** linha onde `Tarefa == Grupo` é o summary row do grupo
- **Marco vs Tarefa:** linha onde `Tarefa == Marco` é o marco; linhas seguintes com o mesmo marco são subtasks
- **NUNCA resumir comentários:** exibir texto bruto exatamente como está na planilha

### Status e cores CSS

| Status | CSS var | Cor | Hex |
|---|---|---|---|
| Feito | `--feito` | Verde | `#05C46B` |
| Em andamento | `--andam` | Azul | `#1A56FF` |
| Risco de atraso | `--risco` | Laranja | `#FF6B00` |
| Atrasado | `--atraso` | Vermelho | `#FF2525` |
| A iniciar | `--iniciar` | Cinza azulado | `#5A6E85` |
| Definir datas | `--definir` | Marrom | `#92400E` |
| Cancelado/Congelado | `--cancel` | Cinza escuro | `#374151` |

### Paleta de destaque

| Variável | Hex | Uso |
|---|---|---|
| `--accent` | `#8AC43A` | Verde primário — botões, bordas, chips |
| `--accentD` | `#6BA030` | Verde escuro — hover states |
| `--bg` | `#1E2E0D` | Fundo do header e painéis escuros |
| `--bg2` | `#2F4A18` | Fundo secundário |

### Regra do pior status (rollup)

```
Rank: Atrasado(0) > Risco de atraso(1) > Em andamento(2) > A iniciar(3) > Definir datas(4) > Feito(5) > Cancelado/Congelado(6)
Marco = pior status das suas tarefas
Grupo = pior status dos seus marcos
Eixo  = pior status dos seus grupos
```

---

## 4. Inventário de documentos

### 4.1 Manual de Uso e Manutenção Dashboard

- **Arquivo atual:** `Manual de Uso e Manutenção Dashboard_v6.docx` + `_v6.pdf`
- **Público-alvo:** Gestores do projeto, equipe IDG — usuários do dashboard no dia a dia. Nível: não-técnico.
- **Tom:** Orientado a tarefa, direto, linguagem acessível. Sem jargão de código.
- **O que cobre:** Como usar o dashboard (filtros, abas, visualizações, Gantt, Requisições), legenda de cores, fluxo de atualização de dados.
- **Seções críticas:**
  - §3.5 Legenda de Cores — tabela Status/Cor/Significado
  - §3.3 Barra de filtros — Status, Eixo, Data, Responsável
  - §3.4 VISUALIZAÇÃO dropdown — Eixos/Grupo/Marco/Tarefas
  - §4 Aba Status Report (EAP)
  - §5 Aba Gantt
  - §6 Aba Requisições
- **Versionar quando:** Qualquer mudança na UX, novos filtros, novas abas, comportamento alterado de feature existente, nova legenda de status.

### 4.2 Guia de Onboarding — Manutenção Dashboard

- **Arquivo atual:** `Guia de Onboarding_Manutençao Dashboard_MAZ_2026_v10.docx` + `_v10.pdf`
- **Público-alvo:** Desenvolvedor que vai manter o código. Nível: técnico, mas pode ser iniciante em JS.
- **Tom:** Técnico, preciso. Comandos git literais. Sem abstrações.
- **O que cobre:** Arquitetura, boas práticas, configuração, fluxo de trabalho (teste → push → produção), reverter versões, referências técnicas (URLs, Sheets IDs, colunas, funções JS), armadilhas conhecidas.
- **Seções críticas:**
  - §1 Arquitetura + fluxo de dados
  - §2 Boas práticas (o que fazer / o que nunca fazer)
  - §3 Configuração inicial (git clone, API key)
  - §5 Fluxo de trabalho
  - §8 Referências técnicas (URLs, Sheets, colunas, funções JS, filtros)
  - §9 Armadilhas técnicas conhecidas
- **Versionar quando:** Qualquer mudança técnica — nova função JS relevante, novo parâmetro, mudança de URL, novo campo no Sheets, nova armadilha descoberta, novo fluxo de publicação.

### 4.3 Ficha Técnica Dashboard

- **Arquivo atual:** `Ficha_Tecnica_Dashboard_MAZ_2026_v3.docx` + `_v3.pdf`
- **Público-alvo:** Stakeholders, gestores seniores, TI. Leitura pontual para entender o que é o sistema.
- **Tom:** Conciso, formal, informativo. Uma página de referência.
- **O que cobre:** URLs, repositório, conta GitHub, fontes de dados, arquitetura em tabela, API key, conta de serviço.
- **Versionar quando:** Mudança de URL, repositório, conta, ID de planilha, dependência externa (ex: troca de biblioteca CDN).

### 4.4 Guia do Usuário Final

- **Arquivo atual:** `Guia como usar Dashboard_Usuário final_MAZ_2026_v2.pptx` + `_v2.pdf`
- **Público-alvo:** Usuários finais do projeto — equipe da exposição, parceiros. Nível: leigo total.
- **Tom:** Visual, simples, passo a passo com capturas de tela descritas. Máximo 1 ideia por slide.
- **O que cobre:** Como acessar o dashboard, navegar entre abas, usar filtros, interpretar status, ver o Gantt, consultar requisições.
- **Versionar quando:** Mudança visual significativa (novo botão visível, nova aba, novo fluxo de navegação), mudança de URL de acesso.

---

## 5. Regras de relevância — o que dispara atualização de docs

### ✅ RELEVANTE — atualiza docs

| Tipo de mudança | Exemplos |
|---|---|
| Nova funcionalidade | Novo filtro, nova aba, novo botão visível, nova visualização |
| Comportamento alterado | Filtro que antes era simples vira multi-select, Gantt muda modos |
| Nova estrutura de dados | Nova coluna lida do Sheets, novo campo parseado |
| Mudança de URL ou ID | URL do dashboard, ID da planilha, nome da aba |
| Novo status ou cor de status | Adição de novo valor de status |
| Nova armadilha técnica | Bug descoberto e corrigido que outros devs precisam saber |
| Mudança de dependência externa | Versão do Chart.js, novo CDN |
| Novo arquivo adicionado | mobile.html criado, novo script, SERVE_DASHBOARD.bat |

### ❌ NÃO RELEVANTE — não atualiza docs

| Tipo de mudança | Exemplos |
|---|---|
| Refactor interno | Rename de variável JS, extração de função, reorganização de código |
| Ajuste visual CSS | Mudança de cor hex, padding, border-radius, font-size |
| Dados embutidos atualizados | Snapshot WBS/REQS atualizado no HTML |
| Comentários no código | Adição ou remoção de `//` comentários |
| Correção de bug invisível ao usuário | Fix de lógica interna sem mudança de comportamento perceptível |
| Atualização de data de referência | `dateLabel` ou similar |

---

## 6. Mapeamento: tipo de mudança → documentos afetados

| Mudança | Manual v6 | Onboarding v10 | Ficha Técnica | Guia Usuário |
|---|---|---|---|---|
| Novo filtro visível | ✅ §3.3 | ✅ §8 | ❌ | ✅ slide filtros |
| Nova aba no dashboard | ✅ nova seção | ✅ §1+§8 | ❌ | ✅ novo slide |
| Novo botão no header | ✅ §3 | ❌ | ❌ | ✅ |
| Nova coluna lida do Sheets | ❌ | ✅ §8 colunas | ❌ | ❌ |
| Mudança de URL | ✅ se menciona URL | ✅ §8 URLs | ✅ | ✅ acesso |
| Mudança ID planilha/aba | ❌ | ✅ §8 | ✅ | ❌ |
| Novo status/cor | ✅ §3.5 legenda | ✅ §8 | ❌ | ✅ legenda |
| Nova armadilha técnica | ❌ | ✅ §9 | ❌ | ❌ |
| Mudança de dependência CDN | ❌ | ✅ §1 arquitetura | ✅ | ❌ |
| Novo arquivo no repo | ❌ | ✅ §1+§5 | ❌ | ❌ |
| mobile.html alterado | ❌ (se não muda UX) | ✅ §8 mobile | ❌ | ✅ se UX muda |
| Mudança de comportamento EAP | ✅ §4 | ✅ §8 | ❌ | ✅ |
| Mudança de comportamento Gantt | ✅ §5 | ✅ §8 | ❌ | ✅ |
| Mudança de comportamento REQS | ✅ §6 | ✅ §8 | ❌ | ✅ |

---

## 7. Armadilhas técnicas conhecidas (não repetir esses bugs)

| Armadilha | Como evitar |
|---|---|
| Dashboard branco sem erro no console | Verificar: (a) null bytes no HTML, (b) `function` ausente em declaração JS, (c) JS truncado — verificar se `</script>` existe no final |
| Template literals aninhados | Nunca usar crase dentro de `${}` dentro de outro crase — `node --check` passa mas browser quebra |
| JS truncado | Verificar se `</script>` existe no final do arquivo antes de editar |
| Prioridade REQS | Usar APENAS coluna E (índice 4) — coluna B gera falsos positivos |
| `node --check` no Node v22 | Não aceita `.html` — extrair bloco `<script>` para arquivo `.js` temporário |
| Deduplicação de grupos | Sempre per eixo — nunca global |
| `--definir` (Definir datas) | Cor é MARROM `#92400E`, não roxo |

---

## 8. Boas práticas de desenvolvimento

**Sempre fazer:**
- Testar local antes de qualquer push
- Hard refresh (Ctrl+Shift+R) ao testar
- Salvar backup com timestamp antes de edições grandes

**Nunca fazer:**
- Editar direto no GitHub pelo browser (vai direto para produção sem teste)
- Confiar só no `node --check` — testar no browser sempre
- Resumir ou parafrasear comentários da planilha — exibir texto bruto

---

## 9. Histórico de versões dos documentos

| Documento | Versão atual | Notas |
|---|---|---|
| Manual de Uso e Manutenção | v6 | Inclui §3.5 com coluna Cor (Mai/2026) |
| Guia de Onboarding | v10 | Inclui §8 Filtro Responsável + §9 Armadilhas (Mai/2026) |
| Ficha Técnica | v3 | — |
| Guia Usuário Final | v2 | — |

---

## 10. Snapshot de referência

> O arquivo `_snapshot_ref.html` (gerado pela skill `doc-sync` após cada execução bem-sucedida) é a versão do `index.html` usada como linha de base para o próximo diff.
> Se não existir, usar o backup mais recente em `Dashboard_backups/`.
> Snapshot atual: `EAP_MAZ_2026_Dashboard_20260522_index.html`
