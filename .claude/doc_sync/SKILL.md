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
- **Esta skill:** `C:\Users\gagui\OneDrive\Documentos\Claude\Projects\IDG - Relatórios de Análise\doc-sync\`
- **Relatórios de execução:** `C:\Users\gagui\OneDrive\Documentos\Claude\Projects\IDG - Relatórios de Análise\doc-sync\reports\`

> Se o snapshot não existir na primeira execução, usar o backup mais recente em
> `IDG - Relatórios de Análise\Dashboard_backups\` como linha de base.

---

## Fluxo de execução

### ETAPA 0 — Auto-sincronização da skill

> **Arquitetura:** `IDG/doc-sync/` é o local de manutenção da skill (editável via Cowork).
> O repo `maz-dashboard/.claude/doc_sync/` recebe uma cópia para portabilidade — um dev que clona o repo já encontra a skill.
> A direção é sempre IDG → repo (não o contrário), porque o diretório `.claude/` do repo
> é write-protected no Cowork.

Copiar os arquivos atualizados para o repo GitHub:

```python
import shutil, os

idg = r"C:\Users\gagui\OneDrive\Documentos\Claude\Projects\IDG - Relatórios de Análise\doc-sync"
repo = r"C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\.claude\doc_sync"

# SKILL.md e context.md: IDG é a fonte de verdade → copia para repo
for f in ["SKILL.md", "context.md"]:
    shutil.copy2(os.path.join(idg, f), os.path.join(repo, f))
    print(f"✓ Sincronizado: {f}")
```

> **Para editar a skill:** abrir sessão Cowork com `IDG - Relatórios de Análise` montado →
> editar `doc-sync/SKILL.md` → na próxima execução do doc-sync, ETAPA 0 propaga para o repo.

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

#### 6a. Manual de Uso e Manutenção (versão atual: `_v7.docx`)
- Usar skill `docx` (unpack → edit XML → repack)
- Editar apenas as seções mapeadas — nunca reescrever o documento inteiro
- Incrementar versão ao salvar (ex: `_v7.docx` → `_v8.docx`)
- Mover versão anterior para `Manual/old_versions/`
- Tom: linguagem acessível, orientado a tarefa, sem jargão técnico

#### 6b. Guia de Onboarding (versão atual: `_v11.docx`)
- Usar skill `docx`
- Editar seções técnicas: §8 Referências, §9 Armadilhas
- Incrementar versão ao salvar (ex: `_v11.docx` → `_v12.docx`)
- Mover versão anterior para `Manual/old_versions/`
- Tom: técnico e preciso, comandos literais quando aplicável

#### 6c. Ficha Técnica (versão atual: `_v3.docx`)
- Usar skill `docx`
- Atualizar apenas URLs, IDs, dependências
- Incrementar versão ao salvar (ex: `_v3.docx` → `_v4.docx`)
- Mover versão anterior para `Manual/old_versions/`
- Tom: formal, tabular, conciso

#### 6d. Guia do Usuário Final (versão atual: `_v3.pptx`)
- Usar skill `pptx`
- Atualizar slides afetados — nunca recriar o deck
- Incrementar versão ao salvar (ex: `_v3.pptx` → `_v4.pptx`)
- Mover versão anterior para `Manual/old_versions/`
- Tom: visual, simples, máximo 1 ideia por slide

#### 6e. ONBOARDING.md (`maz-dashboard/ONBOARDING.md`)
- Arquivo Markdown no repo git — editar in-place (sem versionamento numérico)
- **Critério de sincronização:** atualizar ONBOARDING.md **somente** quando a mudança altera comportamento técnico — nova função JS, novo índice de coluna, nova armadilha, novo fluxo de dados, nova estrutura de pastas. **Não atualizar** para explicações de UX humanas (como abrir PowerShell, onde clicar, passo a passo para leigos) — essas ficam apenas no docx. Regra prática: *"Um dev experiente precisaria saber isso para trabalhar corretamente?" → sim = atualizar; não = só docx.*
- Atualizar quando Guia de Onboarding docx for atualizado para nova versão, OU quando houver mudanças técnicas em: colunas Sheets, auto-status, estrutura de pastas, armadilhas, filtros do dashboard
- Tom: técnico, direto, com tabelas de referência e comandos literais
- Usar Edit tool ou PowerShell se o arquivo tiver backticks JS
- Após editar, commitar junto com as demais alterações do ciclo doc-sync:
  ```bash
  cd "C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard"
  git add ONBOARDING.md
  git commit -m "doc-sync: atualiza ONBOARDING.md ([descrição da mudança])"
  git push
  ```

#### 6f. DEV_GUIDE.html (`Manual/DEV_GUIDE.html`)
- Arquivo HTML sem versionamento numérico — editar in-place
- Atualizar quando houver mudanças técnicas relevantes (nova função, nova armadilha, novo fluxo de dados)

> ⚠️ **Verificação obrigatória antes de editar:** O DEV_GUIDE possui um botão "✏️ Editar / 💾 Baixar arquivo" que salva via download do browser para a pasta Downloads do Windows. Se o usuário editou manualmente pelo browser, o arquivo baixado precisa ser copiado de volta para `Manual/` — caso contrário, o doc-sync sobrescreve as edições.

**Antes de qualquer edição no DEV_GUIDE, executar:**
```python
import os
snapshot = r"C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\.claude\doc_sync\_snapshot_index.html"
devguide = r"C:\Users\gagui\OneDrive\Documentos\Claude\Projects\IDG - Relatórios de Análise\Manual\DEV_GUIDE.html"
snap_mtime = os.path.getmtime(snapshot)
guide_mtime = os.path.getmtime(devguide)
if guide_mtime > snap_mtime:
    from datetime import datetime
    print(f"⚠️ DEV_GUIDE.html foi modificado em {datetime.fromtimestamp(guide_mtime):%d/%m/%Y %H:%M} — APÓS o último snapshot ({datetime.fromtimestamp(snap_mtime):%d/%m/%Y %H:%M}).")
    print("Possível edição manual via botão do browser.")
    print("→ Perguntar ao usuário: 'Detectei edições manuais no DEV_GUIDE. Deseja incorporá-las antes de continuar?'")
    # AGUARDAR confirmação do usuário antes de prosseguir
else:
    print("✅ DEV_GUIDE sem edições manuais desde o último snapshot. Seguro para atualizar.")
```

Se o usuário confirmar edições pendentes:
1. Verificar se existe `DEV_GUIDE.html` recente na pasta Downloads (`C:\Users\gagui\Downloads\`)
2. Se sim, perguntar: *"Encontrei DEV_GUIDE.html em Downloads (modificado em [data]). Usar esse como base?"*
3. Se sim, copiar de Downloads para `Manual/` antes de continuar

- Após atualizar, **copiar para o repo maz-dashboard e commitar** para publicar no GitHub Pages:
  ```bash
  cp "Manual/DEV_GUIDE.html" "C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\DEV_GUIDE.html"
  cd "C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard"
  git add DEV_GUIDE.html
  git commit -m "doc-sync: atualiza DEV_GUIDE.html ([descrição da mudança])"
  git push
  ```
- URL pública resultante: `https://pmo-creator.github.io/maz-dashboard/DEV_GUIDE.html`
- Tom: técnico, orientado a desenvolvedor, com exemplos de código quando aplicável

> ⚠️ Regra crítica: NUNCA resumir ou parafrasear comentários vindos da
> planilha Google Sheets. Sempre exibir texto bruto.

---

### ETAPA 7 — Geração de PDFs (OBRIGATÓRIA)

> **Por que obrigatório:** GitHub e usuários finais acessam apenas o PDF — o `.docx`/`.pptx` é o arquivo de edição, o `.pdf` é o arquivo de consumo. Sem o PDF, a atualização está incompleta.

Para **cada** `.docx` ou `.pptx` criado ou atualizado, gerar o PDF correspondente na mesma pasta:

```bash
python scripts/office/soffice.py --headless --convert-to pdf [arquivo] --outdir [mesma pasta]
```

Nunca encerrar um ciclo doc-sync sem verificar que todos os PDFs foram gerados e têm tamanho > 0.

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
• [Ver Manual vN](computer://C:\Users\gagui\OneDrive\Documentos\Claude\Projects\IDG - Relatórios de Análise\Manual\Manual de Uso e Manutenção Dashboard_vN.docx) · [PDF](computer:/