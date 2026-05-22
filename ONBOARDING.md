# Guia de Onboarding — Dashboard MAZ 2026
> Documento para novos desenvolvedores/responsáveis pelo projeto.
> Leia do início ao fim antes de fazer qualquer alteração.

---

## Índice
1. [O que é este projeto](#1-o-que-é-este-projeto)
2. [Boas práticas de desenvolvimento](#2-boas-práticas-de-desenvolvimento)
3. [Configuração inicial](#3-configuração-inicial)
4. [Alternativa visual — GitHub Desktop](#4-alternativa-visual--github-desktop)
5. [Fluxo de trabalho — do teste ao ar](#5-fluxo-de-trabalho--do-teste-ao-ar)
6. [Testar no celular pela rede local](#6-testar-no-celular-pela-rede-local)
7. [Reverter para uma versão anterior](#7-reverter-para-uma-versão-anterior)
8. [Referências técnicas](#8-referências-técnicas)
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

### Nunca fazer
- ❌ Editar direto no GitHub pelo browser (vai direto para produção sem teste)
- ❌ Confiar só no botão "Atualizar" do dashboard — ele re-executa o JS em cache, não baixa HTML novo
- ❌ Publicar sem testar no celular também
- ❌ Push sem mensagem de commit descritiva
- ❌ Fazer `git push --force` na branch main

### Boas práticas adicionais recomendadas
- 📌 **Sempre descreva o commit em português** com o que foi alterado e por quê (ex: `"Corrigir nome da aba REQS: 'Compras P' → 'Compras Prod'"`)
- 📌 **Antes de alterar algo complexo**, faça um backup manual: copie o arquivo para `Dashboard/backups/` com a data no nome (`EAP_MAZ_2026_Dashboard_YYYYMMDD_descricao.html`)
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
3. Claude Code  → https://claude.ai/code  (recomendado para edições)
```

Verificar instalações no terminal:
```bash
git --version
python --version
```

### Clonar o repositório
```bash
git clone https://github.com/PMO-creator/maz-dashboard
cd maz-dashboard
```

Você terá a estrutura:
```
maz-dashboard/
  index.html          ← dashboard desktop
  mobile.html         ← dashboard mobile
  SERVE_DASHBOARD.bat ← servidor local de teste
  ONBOARDING.md       ← este guia
```

### Configurar acesso ao GitHub
O responsável anterior precisa te adicionar como colaborador:
- `github.com/PMO-creator/maz-dashboard` → Settings → Collaborators → Add people

### Contexto para o Claude Code
O repositório inclui um arquivo `CLAUDE.md` na raiz. Ele é lido automaticamente pelo Claude Code ao abrir o projeto e contém todo o contexto técnico necessário (arquitetura, CSS, SVG, armadilhas conhecidas). Você não precisa fazer nada — funciona automaticamente.

---

## 4. Alternativa visual — GitHub Desktop

Para quem prefere uma interface gráfica ao terminal, o **GitHub Desktop** é a alternativa recomendada ao uso de comandos `git` na linha de comando.

### Download e instalação
```
https://desktop.github.com
```

### Configuração inicial
1. Abrir o GitHub Desktop após instalação
2. Entrar com a conta GitHub (`File → Sign in`)
3. Clonar o repositório: `File → Clone repository → URL`
   - URL: `https://github.com/PMO-creator/maz-dashboard`
   - Local path: pasta de sua preferência

### Fluxo de trabalho no GitHub Desktop
1. **Antes de editar** — clicar em `Fetch origin` para garantir que está na versão mais recente
2. **Após editar** os arquivos no VS Code ou Claude Code, as mudanças aparecem automaticamente na aba `Changes`
3. **Commit** — preencher o campo `Summary` com a descrição da alteração e clicar em `Commit to main`
4. **Push** — clicar em `Push origin` para publicar no GitHub

> ⚠️ O fluxo de teste local (subir o servidor Python, hard refresh, verificar indicador 🟢) continua sendo obrigatório antes do commit — o GitHub Desktop não substitui essa etapa.

---

## 5. Fluxo de trabalho — do teste ao ar

### Passo 1 — Subir o ambiente de teste local

O repositório já inclui o arquivo `SERVE_DASHBOARD.bat`. Basta executá-lo com duplo clique.
→ Abre automaticamente http://localhost:8765/index.html

Ou manualmente no terminal:
```bash
cd maz-dashboard
python -m http.server 8765
```
Depois abrir `http://localhost:8765/index.html` no browser.

### Passo 2 — Fazer as alterações
Edite `index.html` e/ou `mobile.html` com Claude Code ou VS Code.

> ⚠️ Alterações que afetam layout, KPIs, lógica de dados ou parsing de colunas **normalmente afetam os dois arquivos**. Sempre verifique ambos.

### Passo 3 — Testar localmente
```
Desktop → http://localhost:8765/index.html
Mobile  → http://localhost:8765/mobile.html
Celular → http://[SEU-IP]:8765/index.html  (ver seção 5)
```

- Fazer **hard refresh** (`Ctrl+Shift+R`) a cada alteração
- Verificar o indicador 🟢 Ao vivo
- Testar as funcionalidades afetadas pela mudança

### Passo 4 — Publicar (só quando aprovado)
```bash
git add index.html mobile.html
git commit -m "Descrição clara do que foi alterado"
git push
```

Aguardar **~2 minutos** → `https://pmo-creator.github.io/maz-dashboard/` atualizado.

Fazer **hard refresh** no GitHub Pages para confirmar (`Ctrl+Shift+R`).

---

## 6. Testar no celular pela rede local

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
http://192.168.1.105:8765/index.html
```
O redirect automático vai direcionar para `mobile.html`.

> 💡 O IP pode mudar quando a rede muda. Sempre verifique com `ipconfig` antes de testar.

---

## 7. Reverter para uma versão anterior

### Ver o histórico de commits
```bash
git log --oneline
```
Exemplo de saída:
```
126406f  Corrigir nome da aba REQS: 'Compras P' → 'Compras Prod'
38249e4  Adicionar indicador de status: 🟢 Ao vivo / 🟡 REQ erro / 🔴 Erro dados locais
e2247e7  Corrigir nome da aba do cronograma: 'cronograma exposição' → 'master data'
9a47d9c  REQS: atualizar ID da planilha para Google Sheets nativo
```

### Opção A — Reverter um commit específico (recomendado)
Cria um novo commit que desfaz as mudanças. Histórico fica intacto.
```bash
git revert 38249e4
git push
```

### Opção B — Ver como o arquivo estava em uma versão antiga
```bash
git show 38249e4:Dashboard/index.html > versao_antiga.html
```
Abre `versao_antiga.html` para comparar ou copiar trechos.

### Opção C — Voltar o repositório inteiro para uma versão (cuidado)
⚠️ Apaga tudo que foi feito depois desse commit.
```bash
git reset --hard 38249e4
git push --force
```
> Só usar em último caso. Avisar o responsável antes.

### Pelo GitHub (interface visual)
1. Acessar `github.com/PMO-creator/maz-dashboard`
2. Clicar na aba **"Commits"**
3. Encontrar o commit desejado → clicar em **"<>"** (Browse files)
4. Baixar o arquivo da versão antiga manualmente

---

## 8. Referências técnicas

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
| Coluna | Índice | Campo |
|---|---|---|
| A | 0 | Nº Requisição |
| C | 2 | Comprador |
| E | 4 | Prioridade |
| F | 5 | Descrição |
| G | 6 | Status |
| H | 7 | Fornecedor |
| M | 12 | Data prevista |

### Regras de auto-status
| Condição | Status resultante |
|---|---|
| Status vazio | `A iniciar` |
| `A iniciar` + data início já passou | `Risco de atraso` |
| Qualquer status + data fim já passou | `Atrasado` |
| Qualquer status + data fim nos próximos 7 dias | `Risco de atraso` |
| `Feito`, `Cancelado`, `Cancelado/Congelado` | Nunca muda |

Rollup: **grupo = pior status dos marcos / eixo = pior status dos grupos**

### Auto-refresh
15 minutos — constante `AUTO_REFRESH_MS` em ambos os HTMLs.

---

## 9. Armadilhas técnicas conhecidas

| Armadilha | Como evitar |
|---|---|
| Dashboard branco sem erro no console | Verificar: (a) null bytes no HTML, (b) palavra `function` ausente em declaração JS, (c) JS truncado sem `</script>`, (d) template literals aninhados |
| Template literals aninhados | Nunca usar crase dentro de `${}` dentro de outro crase — `node --check` passa mas browser quebra |
| JS truncado | Verificar se `</script>` existe no final do arquivo antes de editar |
| Prioridade REQS | Usar APENAS coluna E (índice 4) — coluna B gera falsos positivos |
| `node --check` no Node v22 | Não aceita `.html` — extrair bloco script para arquivo `.js` temporário |

---

*Guia gerado em 22/Mai/2026 — Dashboard MAZ 2026 · IDG PMO*
