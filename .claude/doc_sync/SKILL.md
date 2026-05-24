---
name: doc-sync
description: >
  Skill de sincronização automática de documentação do Dashboard MAZ 2026.
  USAR SEMPRE que: o usuário fizer git push do dashboard, disser "doc-sync",
  "atualizar docs", "documentação", "sincronizar manuais", ou quando chamado
  pelo scheduled task diário. Compara o código atual do dashboard com o
  snapshot anterior, identifica mudanças relevantes, e atualiza os documentos
  afetados (Manual, Onboarding, Ficha Técnica, Guia do Usuário Final) com
  aprovação do usuário antes de gravar.
---

# doc-sync — Sincronização de Documentação Dashboard MAZ 2026

## Contexto do projeto

Leia o arquivo `context.md` na mesma pasta desta skill antes de qualquer operação.
Ele contém: arquitetura técnica, estrutura WBS, paleta de cores, inventário de
documentos, regras de relevância e mapeamento mudança → documento.

Caminhos importantes:
- **Repo GitHub local:** `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\`
- **Pasta de documentos:** `C:\Users\gagui\OneDrive\Documentos\Claude\Projects\IDG - Relatórios de Análise\Manual\`
- **Snapshot de referência:** `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\.claude\doc_sync\_snapshot_index.html`
- **Esta skill:** `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\.claude\doc_sync\`

> Se o snapshot não existir na primeira execução, usar o backup mais recente em
> `IDG - Relatórios de Análise\Dashboard_backups\` como linha de base.

---

## Fluxo de execução

### ETAPA 0 — Auto-sincronização da skill

Antes de qualquer coisa, copiar os arquivos da skill para o repo GitHub para
garantir portabilidade:

```bash
# Garante que .claude/doc-sync/ existe no repo
mkdir -p "C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\.claude\doc-sync"

# Copia skill e contexto para o repo (sobrescreve)
cp SKILL.md  "C:\...\maz-dashboard\.claude\doc_sync\SKILL.md"
cp context.md "C:\...\maz-dashboard\.claude\doc_sync\context.md"
```

> Isso garante que o próximo desenvolvedor, ao clonar o repo, já tem a skill.

---

### ETAPA 1 — Leitura dos arquivos atuais

Ler os arquivos do repo GitHub local:
- `index.html` (dashboard desktop)
- `mobile.html` (dashboard mobile)

```python
# Bash equivalente
cat "C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\index.html" > /tmp/current_index.html
cat "C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\mobile.html" > /tmp/current_mobile.html
```

---

### ETAPA 2 — Leitura do snapshot de referência

```python
SNAPSHOT_PATH = r"C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\.claude\doc_sync\_snapshot_index.html"

# Se não existir: usar backup mais recente
if not exists(SNAPSHOT_PATH):
    usar o arquivo mais recente em Dashboard_backups/
    avisar o usuário que é a primeira execução
```

---

### ETAPA 3 — Diff e classificação de mudanças

Comparar `index.html` atual com o snapshot linha a linha.
Para cada bloco diferente, classificar usando as regras do `context.md §5`:

**Classificações:**
- `RELEVANTE_UX` — novo botão, nova aba, novo filtro visível, mudança de navegação
- `RELEVANTE_TECH` — nova função JS relevante, novo campo Sheets, nova URL, nova armadilha
- `RELEVANTE_DADOS` — nova coluna parseada, novo status, ID de planilha alterado
- `IGNORAR` — refactor interno, CSS cosmético, dados embutidos atualizados, comentários

**Regra de ouro:** se um usuário final ou dev novo precisaria saber para usar ou
manter o dashboard → `RELEVANTE`. Dúvida → `RELEVANTE`.

Se **nenhuma mudança relevante** for encontrada:
```
✅ Commit limpo — nenhuma mudança que afete a documentação.
Snapshot atualizado. Nada a fazer.
```
Atualizar snapshot e encerrar.

---

### ETAPA 4 — Mapeamento de impacto

Para cada mudança `RELEVANTE_*`, usar a tabela do `context.md §6` para
determinar quais documentos e seções precisam ser atualizados.

Montar um relatório de impacto:

```
📋 MUDANÇAS ENCONTRADAS — [data]

1. [RELEVANTE_UX] Novo filtro de Responsável adicionado ao header
   → Afeta: Manual v6 §3.3 | Onboarding v10 §8 | Guia Usuário slide filtros

2. [RELEVANTE_TECH] URL do dashboard alterada de X para Y
   → Afeta: Manual v6 (menção de URL) | Onboarding v10 §8 URLs | Ficha Técnica v3

Total: 2 mudanças relevantes em 3 documentos.
```

---

### ETAPA 5 — Apresentação para aprovação (OBRIGATÓRIA)

Exibir para o usuário em linguagem de leigo:

```
🔔 doc-sync encontrou mudanças no dashboard que precisam ser documentadas.

Mudança 1: Foi adicionado um novo botão de filtro por Responsável.
  O que isso significa: os usuários agora podem filtrar o dashboard pelo nome
  de quem é responsável por cada tarefa.
  Vou atualizar: Manual (seção de filtros) + Guia do Usuário (slide de filtros)

Mudança 2: O endereço do dashboard mudou.
  O que isso significa: o link para acessar o dashboard é diferente agora.
  Vou atualizar: Manual + Guia de Manutenção + Ficha Técnica

Posso prosseguir com as atualizações? [Sim / Não / Ver detalhes técnicos]
```

**Aguardar aprovação antes de qualquer escrita em arquivo.**

Se o usuário pedir detalhes técnicos, mostrar o diff bruto da mudança.
Se o usuário disser "não" em algum item específico, pular aquele item.

---

### ETAPA 6 — Atualização dos documentos

Para cada documento afetado, executar na ordem:

#### 6a. Manual de Uso e Manutenção (`_v6.docx`)
- Usar skill `docx` (unpack → edit XML → repack)
- Editar apenas as seções mapeadas — nunca reescrever o documento inteiro
- Incrementar versão: `_v6.docx` → `_v7.docx`
- Tom: linguagem acessível, orientado a tarefa, sem jargão técnico

#### 6b. Guia de Onboarding (`_v10.docx`)
- Usar skill `docx`
- Editar seções técnicas: §8 Referências, §9 Armadilhas
- Incrementar versão: `_v10.docx` → `_v11.docx`
- Tom: técnico e preciso, comandos literais quando aplicável

#### 6c. Ficha Técnica (`_v3.docx`)
- Usar skill `docx`
- Atualizar apenas URLs, IDs, dependências
- Incrementar versão: `_v3.docx` → `_v4.docx`
- Tom: formal, tabular, conciso

#### 6d. Guia do Usuário Final (`_v2.pptx`)
- Usar skill `pptx`
- Atualizar slides afetados — nunca recriar o deck
- Incrementar versão: `_v2.pptx` → `_v3.pptx`
- Tom: visual, simples, máximo 1 ideia por slide

> ⚠️ Regra crítica: NUNCA resumir ou parafrasear comentários vindos da
> planilha Google Sheets. Sempre exibir texto bruto.

---

### ETAPA 7 — Regeneração dos PDFs

Para cada `.docx` ou `.pptx` atualizado, gerar o PDF correspondente:

```bash
python scripts/office/soffice.py --headless --convert-to pdf [arquivo] --outdir [mesma pasta]
```

---

### ETAPA 8 — Atualização do snapshot

Salvar o `index.html` atual como novo snapshot de referência:

```bash
cp index.html ".claude/doc-sync/_snapshot_index.html"
```

> O snapshot do `mobile.html` não é necessário — as mudanças relevantes do
> mobile são rastreadas via diff do `index.html` (ambos compartilham lógica).

---

### ETAPA 9 — Relatório final

Exibir resumo com links diretos:

```
✅ doc-sync concluído — [data]

Documentos atualizados:
• [Ver Manual v7](computer://C:\...\Manual de Uso e Manutenção Dashboard_v7.docx)
• [Ver Onboarding v11](computer://C:\...\Guia de Onboarding_v11.docx)
• [Ver Ficha Técnica v4](computer://C:\...\Ficha_Tecnica_v4.docx)
• [Ver Guia Usuário v3](computer://C:\...\Guia como usar Dashboard_v3.pptx)

Próximo doc-sync: amanhã às 08:00
```

---

## Regras de qualidade

1. **Nunca reescrever um documento inteiro** — editar cirurgicamente as seções afetadas
2. **Sempre pedir aprovação** antes de gravar qualquer arquivo
3. **Explicar em linguagem de leigo** — o usuário não precisa entender JS para aprovar
4. **Versionar sempre** — nunca sobrescrever sem incrementar versão
5. **Auto-sincronizar** — sempre copiar SKILL.md + context.md para o repo no início
6. **Snapshot obrigatório** — sempre salvar novo snapshot ao final

---

## Configuração inicial (primeira execução)

Na primeira vez que esta skill for executada, verificar:

1. ✅ O repo GitHub está clonado em `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\`?
2. ✅ A pasta `.claude\doc_sync\` existe no repo?
3. ✅ Existe um snapshot de referência?

Se qualquer um for "não", guiar o usuário na configuração antes de prosseguir.

---

## Para o próximo desenvolvedor

Esta skill vive em `.claude/doc-sync/SKILL.md` dentro do repositório.
Ao clonar o repo, instale a skill no seu Claude/Cowork importando o arquivo `.skill`
que está na raiz do repositório (`doc-sync.skill`).

Para configurar o scheduled task diário (varredura automática às 08:00):
1. Abra o Cowork
2. Digite: *"Configurar doc-sync para rodar todo dia às 08:00"*
3. O Claude vai configurar automaticamente

Documentação completa em `Guia de Onboarding_Manutençao Dashboard_MAZ_2026_vXX.docx §10`.
