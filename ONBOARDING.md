# Guia de Onboarding — Dashboard MAZ 2026
> Documento para novos desenvolvedores/responsáveis pelo projeto.
> Leia do início ao fim antes de fazer qualquer alteração.

---

## Índice
1. [O que é este projeto](#1-o-que-é-este-projeto)
2. [Boas práticas de desenvolvimento](#2-boas-práticas-de-desenvolvimento)
3. [Configuração inicial](#3-configuração-inicial)
4. [Fluxo de trabalho — do teste ao ar](#4-fluxo-de-trabalho--do-teste-ao-ar)
5. [Testar no celular pela rede local](#5-testar-no-celular-pela-rede-local)
6. [Reverter para uma versão anterior](#6-reverter-para-uma-versão-anterior)
7. [Referências técnicas](#7-referências-técnicas)
8. [Skills disponíveis no repositório](#8-skills-disponíveis-no-repositório)
9. [Armadilhas técnicas conhecidas](#9-armadilhas-técnicas-conhecidas)

---

## 1. O que é este projeto

Dashboard interativo do **Museu das Amazônias 2026 (MAZ ELD)** — acompanhamento de cronograma, status report e requisições de compras.

### Arquitetura
- **Dois arquivos HTML** são o projeto inteiro:
  - `index.html` → versão desktop
  - `mobile.html` → versão mobile (3 abas: Gantt, Status Report, Requisições)
- **Dados ao vivo** — buscados direto do Google Sheets via API Key no browser, sem backend
- **Publicado** em `https://pmo-creator.github.io/maz-dashboard/` via GitHub Pages
- **Redirect automático**: o mesmo link detecta desktop ou celular e abre a versão correta

### Como os dados chegam
```
Google Sheets (Cronograma + REQS)
        ↓  API Key (sem OAuth)
    Browser do usuário
        ↓  renderiza
    Dashboard (index.html ou mobile.html)
```

### Indicador de status (canto superior direito)
| Indicador | Significado |
|---|---|
| 🟢 Ao vivo · HH:MM | Tudo funcionando, dados frescos |
| 🟡 Cronograma OK · REQ erro | Cronograma OK mas REQS falhou |
| 🔴 Erro — dados locais | Fetch falhou, mostrando dados antigos |

---

## 2. Boas práticas de desenvolvimento

### Ferramentas certas para cada tarefa

| Tipo de tarefa | Melhor ferramenta | Por quê |
|---|---|---|
| Editar arquivos HTML/CSS/JS | **Claude Code** | Acessa e edita arquivos diretamente |
| Git commit / push | **Claude Code** | Roda bash/git |
| Debug de código em arquivos | **Claude Code** | Lê o arquivo real, não uma cópia |
| Perguntas sobre o projeto | **Chat ou Cowork** | Não precisa de ferramentas, menos tokens |
| Explicações gerais de tecnologia | **Chat** | Puramente conversacional |
| Brainstorm / planejamento de features | **Chat ou Cowork** | Sem necessidade de arquivos |
| Criar documentos Word/PDF/PPT | **Cowork** | Skills especializados |
| Análise de dados / planilhas | **Cowork** | Skills de data analysis |

**Regra geral:**
- 🔧 **Claude Code** → quando precisa **tocar em arquivos** ou **rodar comandos**
- 💬 **Chat** → quando é só **pergunta, explicação ou texto**
- 🤝 **Cowork** → quando precisa de **skills especializados**

### Sempre fazer
- ✅ Testar local antes de qualquer push
- ✅ Hard refresh (`Ctrl+Shift+R`) ao testar — evita ver versão em cache
- ✅ Verificar o indicador 🟢 Ao vivo após atualizar
- ✅ Um commit por alteração com descrição clara do que foi feito
- ✅ Testar no celular também antes de publicar
- ✅ Verificar os dois arquivos (index.html E mobile.html) quando a mudança afeta ambos
- ✅ Validar JavaScript com `node --check` após qualquer alteração no código. Extrair o bloco script para um arquivo `.js` temporário e rodar: `node --check arquivo.js`
- ✅ Ao criar ou alterar o filtro de responsável, verificar os **3 estados** em desktop e mobile: (a) todos marcados → cronograma completo, (b) alguns marcados → mostra só os responsáveis selecionados, (c) nenhum marcado → conteúdo some e aparece mensagem de aviso verde

### Nunca fazer
- ❌ Editar direto no GitHub pelo browser (vai direto para produção sem teste)
- ❌ Confiar só no botão "Atualizar" do dashboard — ele re-executa o JS em cache, não baixa HTML novo
- ❌ Publicar sem testar no celular também
- ❌ Push sem mensagem de commit descritiva
- ❌ Fazer `git push --force` na branch main

### Boas práticas adicionais recomendadas
- 📌 **Sempre descreva o commit em português** com o que foi alterado e por quê (ex: `"Corrigir nome da aba REQS: 'Compras P' → 'Compras Prod'"`)
- 📌 **Nunca altere as constantes de API Key ou IDs de planilha** sem confirmar com o responsável do projeto
- 📌 **Se o indicador mostrar 🔴**, não é bug do dashboard — é problema de conectividade com o Sheets. Verifique compartilhamento da planilha e API Key
- 📌 **Qualquer mudança na estrutura das colunas das planilhas** exige atualização do código de parse (`_parseWBS` e `_parseREQS`)
- 📌 **Ao testar no celular**, use sempre o link do GitHub Pages (`pmo-creator.github.io/maz-dashboard`) — não o localhost, que não redireciona corretamente para mobile

---

## 3. Configuração inicial

### Pré-requisitos (instalar uma vez)
```
1. Git          → https://git-scm.com
2. Python 3.x   → https://python.org  (para servidor local)
3. Node.js      → https://nodejs.org  (para validar JS com node --check)
4. Claude Code  → https://claude.ai/code  (recomendado para edições)
```

Verificar instalações no terminal:
```bash
git --version
python --version
node --version
```

### Estrutura de pastas de trabalho

O projeto usa **uma única pasta** — edição, teste e publicação acontecem no mesmo lugar:

```
GitHub\
  maz-dashboard\                 ← PASTA ÚNICA — edita, testa e publica daqui
    index.html                   → Dashboard desktop (~330 KB)
    mobile.html                  → Dashboard mobile (~43 KB)
    SERVE_DASHBOARD.bat          → Servidor local (duplo-clique para preview)
    ONBOARDING.md                ← este arquivo (leia antes de trabalhar)
    CLAUDE.md
    doc-sync\                    ← skill doc-sync + contexto + snapshot
    Manual\                      ← documentação versionada (docx/pdf)
    00. Apoio\                   ← logos e banners
```

> A separação anterior em duas pastas foi eliminada em 26/Mai/2026. Tudo acontece diretamente em `maz-dashboard`; o servidor local (`SERVE_DASHBOARD.bat`) permite testar antes de commitar sem risco de publicação acidental.

### Clonar o repositório (primeira vez)
```bash
git clone https://github.com/PMO-creator/maz-dashboard
```

Você terá a pasta `maz-dashboard/` com tudo que precisa. Não há pasta de ambiente de teste separada — o servidor local (`SERVE_DASHBOARD.bat`) já cumpre esse papel dentro da própria pasta.

### Configurar acesso ao GitHub
O responsável anterior precisa te adicionar como colaborador:
- `github.com/PMO-creator/maz-dashboard` → Settings → Collaborators → Add people

---

## 4. Fluxo de trabalho — do teste ao ar

```
maz-dashboard  →  (edita + testa aqui mesmo)  →  commit/push  →  GitHub Pages
  (pasta única)                                                     (produção)
```

### Passo 0 — Puxar a versão mais recente

Antes de começar, garantir que a pasta local está atualizada:

```bash
# No terminal, dentro de maz-dashboard:
git pull
```

### Passo 1 — Subir o servidor local

Na pasta `maz-dashboard`, rodar:
```
SERVE_DASHBOARD.bat
```
→ Abre automaticamente `http://localhost:8000`

Ou manualmente:
```bash
python -m http.server 8000
```

### Passo 2 — Fazer as alterações

Edite `index.html` e/ou `mobile.html` com **Claude Code** (abrir o Claude Code na pasta `maz-dashboard`).

> ⚠️ Alterações que afetam layout, KPIs, lógica de dados ou parsing de colunas **normalmente afetam os dois arquivos**. Sempre verifique ambos.

### Passo 3 — Testar localmente

```
Desktop → http://localhost:8000/index.html
Mobile  → http://localhost:8000/mobile.html
Celular → http://[SEU-IP]:8000/index.html  (ver seção 5)
```

- Fazer **hard refresh** (`Ctrl+Shift+R`) a cada alteração
- Verificar o indicador 🟢 Ao vivo
- Testar as funcionalidades afetadas pela mudança

### Passo 4 — Publicar (só quando aprovado)

```bash
# No terminal, dentro de maz-dashboard:
git add index.html mobile.html
git commit -m "Descrição clara do que foi alterado"
git push
```

Aguardar **~2 minutos** → `https://pmo-creator.github.io/maz-dashboard/` atualizado.

Fazer **hard refresh** no GitHub Pages para confirmar (`Ctrl+Shift+R`).

---

## 5. Testar no celular pela rede local

Celular e computador precisam estar na **mesma rede Wi-Fi**.

### Encontrar o IP do computador
No terminal Windows:
```
ipconfig
```
Procurar por **"Endereço IPv4"**:
```
Adaptador de Rede Wi-Fi:
   Endereço IPv4 . . . : 192.168.1.105   ← esse é o IP
```

### Acessar no celular
No browser do celular digitar:
```
http://192.168.1.105:8000/index.html
```
O redirect automático vai direcionar para `mobile.html`.

> 💡 O IP pode mudar quando a rede muda. Sempre verifique com `ipconfig` antes de testar.

---

## 6. Reverter para uma versão anterior

### Ver o histórico de commits
```bash
git log --oneline
```

### Opção A — Reverter um commit específico (recomendado)
Cria um novo commit que desfaz as mudanças. Histórico fica intacto.
```bash
git revert <hash-do-commit>
git push
```

### Opção B — Ver como o arquivo estava em uma versão antiga
```bash
git show <hash>:index.html > versao_antiga.html
```
Abre `versao_antiga.html` para comparar ou copiar trechos.

### Opção C — Voltar o repositório inteiro para uma versão (cuidado)
⚠️ Apaga tudo que foi feito depois desse commit.
```bash
git reset --hard <hash>
git push --force
```
> Só usar em último caso. Avisar o responsável antes.

### Pelo GitHub (interface visual)
1. Acessar `github.com/PMO-creator/maz-dashboard`
2. Clicar na aba **"Commits"**
3. Encontrar o commit desejado → clicar em **"<>"** (Browse files)
4. Baixar o arquivo da versão antiga manualmente

---

## 7. Referências técnicas

### URLs
| Recurso | URL |
|---|---|
| Dashboard público | `https://pmo-creator.github.io/maz-dashboard/` |
| Repositório GitHub | `https://github.com/PMO-creator/maz-dashboard` |
| Teste local desktop | `http://localhost:8765/index.html` |
| Teste local mobile | `http://localhost:8765/mobile.html` |

### Google Sheets
| Planilha | ID | Aba |
|---|---|---|
| Cronograma | `17nttJ_ShqWztvDWH3l59iNqboLqkviZs3_PM5J3ihdA` | `master data` |
| Requisições | `1azrdS4OGO-CWD1ods69i8iZJcwq4oyISdT2n_tu1uJM` | `Planilha de Status de Compras Prod` |

> ⚠️ Ambas as planilhas precisam estar com **"Qualquer pessoa com o link pode ver"** ativado. Sem isso o dashboard retorna erro 403/400.

### API Key Google Sheets
- Chave: `[solicitar ao responsável]`
- Projeto GCP: `maz-dashboard-495414`
- Restrição: `pmo-creator.github.io/*`
- Gerenciar em: `console.cloud.google.com` → APIs e serviços → Credenciais

### Colunas das planilhas (índices 0-based)

**Cronograma (`_parseWBS`):**
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

**Requisições (`_parseREQS`):**

> ⚠️ Corrigido em commit 7662590 — índices anteriores estavam deslocados causando KPIs zerados.

| Coluna | Índice | Campo |
|---|---|---|
| A | 0 | Nº Requisição |
| B | 1 | Comprador |
| D | 3 | Prioridade ← USAR APENAS ESTA |
| E | 4 | Descrição |
| F | 5 | Status |
| G | 6 | Fornecedor |
| M | 12 | Data prevista |

> ⚠️ Prioridade: usar APENAS coluna D (índice 3). Coluna B gera falsos positivos.

### Regras de auto-status

> Atualizado em commit 2ea1b35 — ranking e regras de default revisados.

| Condição | Status resultante |
|---|---|
| Subtask sem status + sem data | `Definir datas` |
| `A iniciar` + sem data de início | `Definir datas` |
| Grupo/eixo sem status definido | `Definir datas` |
| Qualquer status + data fim já passou | `Atrasado` |
| Qualquer status + data fim nos próximos 7 dias | `Risco de atraso` |
| `Feito`, `Cancelado`, `Cancelado/Congelado` | Nunca muda |

**Ranking de pior status (rollup):**
```
Atrasado(0) > Risco de atraso(1) > Em andamento(2) > Definir datas(3) > A iniciar(4) > Feito(5) > Cancelado/Congelado(6)
```

**Cálculo automático de datas** (commit 8080c50):
- Marco: início = mínimo das subtasks · fim = máximo das subtasks
- Grupo: início = mínimo dos marcos · fim = máximo dos marcos
- Marcos sem subtasks mantêm as datas da planilha

Rollup: **marco = pior status das tarefas / grupo = pior status dos marcos / eixo = pior status dos grupos**

### Auto-refresh
15 minutos — constante `AUTO_REFRESH_MS` em ambos os HTMLs.

### Filtros do Dashboard

Os filtros globais (Status, Eixo, Data e Responsável) ficam na barra superior do desktop (`index.html`) e como chips/dropdowns no mobile (`mobile.html`). Todos alimentam a função `applyFilter()` que re-renderiza a árvore EAP e o Gantt.

#### Filtro de Fornecedor — Aba Requisições (commit b4a0b53)

Dropdown multi-select na barra de filtros da aba Requisições. Lê valores únicos da coluna G (Fornecedor). Itens sem fornecedor agrupados como "Sem Fornecedor". Botão verde **"Limpar filtros"** reseta status, fornecedor, comprador, prioridade e busca.

| Função JS | Responsabilidade |
|---|---|
| `buildReqFilters()` | Monta os filtros de status, comprador, prioridade e fornecedor |
| `applyReqFilter()` | Aplica todos os filtros e re-renderiza a lista de requisições |

---

#### Filtro de Responsável — Desktop (`index.html`)

Localização no HTML: `<div class="ms-resp-wrap">` na barra de filtros, entre o filtro de Eixos e o botão "Limpar Filtros".

| Função JS | Responsabilidade |
|---|---|
| `buildRespFilter()` | Lê os nomes únicos de responsável dos dados e monta o dropdown multi-select |
| `grupoHasResp(grupo, resp)` | Retorna `true` se o grupo ou qualquer uma de suas tarefas pertence ao responsável |
| `getFilters()` | Retorna o objeto de filtros ativos, incluindo o campo `resp` (array de nomes selecionados) |
| `applyFilter()` | Detecta "nenhum marcado" via **contagem DOM** (não via `f.resp`), exibe `#gantt-resp-msg` e oculta linhas sem correspondência |

**Label do dropdown:**
- Todos marcados → `"Todos os responsáveis"`
- 1–2 marcados → lista os nomes
- 3+ marcados → `"X selecionados"`
- Nenhum marcado → `"Nenhum selecionado"`

**Lógica de filtragem (hierarquia):**
- Marco com o responsável → mostra o marco **com todas** as suas tarefas
- Marco sem o responsável, mas com alguma tarefa do responsável → mostra o marco **só com as tarefas** do responsável
- Grupo sem nenhum marco/tarefa do responsável → desaparece
- Eixo sem nenhum grupo com o responsável → desaparece
- No Gantt: linhas sem o responsável são **ocultadas** (não esmaecidas)

#### Filtro de Responsável — Mobile (`mobile.html`)

Localização: chips horizontais com classe `.resp-chip` exibidos entre as abas e o conteúdo, nas abas Gantt e Status Report.

| Elemento/Função JS | Responsabilidade |
|---|---|
| `activeRespFilterM` | Array de responsáveis ativos no mobile |
| `buildRespFilterMobile()` | Gera os chips de responsável para o mobile |
| `grupoHasRespM(grupo)` | Versão mobile de `grupoHasResp` |
| `toggleRespChip(resp, el)` | Ativa/desativa chip e re-renderiza |
| `#gantt-resp-msg` | Mensagem "SELECIONE AO MENOS UM RESPONSÁVEL" (Gantt) |
| `#sr-resp-msg` | Mensagem "SELECIONE AO MENOS UM RESPONSÁVEL" (Status Report) |

**Lógica de filtragem mobile:**
- Chip "Todos" ativo → mostra tudo (array vazio = sem filtro)
- Chip de nome ativo → filtra eixos, grupos e marcos sem o responsável
- Eixos sem match somem da lista (tanto no Gantt quanto no Status Report)

---

## 8. Skills disponíveis no repositório

O repo inclui a skill `doc-sync` em `doc-sync/`, pronta para uso com **Cowork**:

### doc-sync — Sincronização de documentação

Compara o `index.html` atual com o snapshot anterior, identifica mudanças relevantes e atualiza automaticamente os manuais (Manual de Uso, Guia de Onboarding, Ficha Técnica, ONBOARDING.md). Roda via **Cowork** com a pasta `maz-dashboard` montada.

**Como acionar:** digitar `doc-sync` ou `"atualizar docs"` no chat Cowork.

Ver documentação completa em `doc-sync/SKILL.md`.

---

## 9. Armadilhas técnicas conhecidas

| Armadilha | Como evitar |
|---|---|
| Dashboard branco sem erro no console | Verificar: (a) null bytes no HTML, (b) palavra `function` ausente em declaração JS, (c) JS truncado sem `</script>`, (d) template literals aninhados |
| Template literals aninhados | Nunca usar crase dentro de `${}` dentro de outro crase — `node --check` passa mas browser quebra |
| JS truncado | Verificar se `</script>` existe no final do arquivo antes de editar |
| Prioridade REQS | Usar APENAS coluna D (índice 3) — coluna B gera falsos positivos. Índices antigos (E/4) causavam KPIs zerados (corrigido commit 7662590) |
| `node --check` no Node v22 | Não aceita `.html` — extrair bloco script para arquivo `.js` temporário |
| Edit tool do Claude Code falha | Arquivo contém backticks JS (template literals). Usar PowerShell com `[System.IO.File]::ReadAllBytes` |
| String não encontrada no Replace | Arquivo usa CRLF. Normalizar: `$content.Replace("\`r\`n", "\`n")` antes de substituir |

---

*Guia atualizado em 26/Mai/2026 — v12 — Dashboard MAZ 2026 · IDG PMO*
