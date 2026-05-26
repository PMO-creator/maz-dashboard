---
name: doc-sync
description: >
  Skill de sincronização automática de documentação do Dashboard MAZ 2026.
  USAR SEMPRE que: o usuário fizer git push do dashboard, disser "doc-sync",
  "atualizar docs", "documentação", "sincronizar manuais", ou quando chamado
  pelo scheduled task diário. Compara o código atual do dashboard com o
  snapshot anterior, identifica mudanças relevantes, e atualiza os documentos
  afetados (Manual, Onboarding, Ficha Técnica) com aprovação do usuário antes
  de gravar.
---

# doc-sync — Sincronização de Documentação Dashboard MAZ 2026

## Contexto do projeto

Leia o arquivo `context.md` na mesma pasta desta skill antes de qualquer operação.
Ele contém: arquitetura técnica, estrutura WBS, paleta de cores, inventário de
documentos, regras de relevância e mapeamento mudança → documento.

Caminhos importantes:
- **Repo GitHub local (pasta única):** `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\`
- **Manuais:** `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\Manual\`
- **Snapshot de referência:** `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\doc-sync\_snapshot_index.html`
- **Esta skill:** `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\doc-sync\`
- **Relatórios de execução:** `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\doc-sync\reports\`

> ⚠️ Regra crítica: NUNCA executar `git add`, `git commit` ou `git push` sem
> instrução explícita do usuário.

---

## Fluxo de execução

### ETAPA 1 — Leitura dos arquivos atuais

Ler os arquivos do repo GitHub local:
- `index.html` (dashboard desktop)
- `mobile.html` (dashboard mobile)

---

### ETAPA 2 — Leitura do snapshot de referência

```python
SNAPSHOT_PATH = r"C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\doc-sync\_snapshot_index.html"

# Se não existir: avisar o usuário que é a primeira execução
if not exists(SNAPSHOT_PATH):
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
   → Afeta: Manual §3.3 | Onboarding §8

Total: 1 mudança relevante em 2 documentos.
```

---

### ETAPA 5 — Apresentação para aprovação (OBRIGATÓRIA)

Exibir para o usuário em linguagem de leigo:

```
🔔 doc-sync encontrou mudanças no dashboard que precisam ser documentadas.

Mudança 1: Foi adicionado um novo botão de filtro por Responsável.
  O que isso significa: os usuários agora podem filtrar pelo responsável.
  Vou atualizar: Manual (seção de filtros) + Guia de Onboarding

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

#### 6b. Guia de Onboarding (versão atual: `_v12.docx`)
- Usar skill `docx`
- Editar seções técnicas: §8 Referências, §9 Armadilhas
- Incrementar versão ao salvar (ex: `_v12.docx` → `_v13.docx`)
- Mover versão anterior para `Manual/old_versions/`
- Tom: técnico e preciso, comandos literais quando aplicável

#### 6c. Ficha Técnica (versão atual: `_v3.docx`)
- Usar skill `docx`
- Atualizar apenas URLs, IDs, dependências
- Incrementar versão ao salvar (ex: `_v3.docx` → `_v4.docx`)
- Mover versão anterior para `Manual/old_versions/`
- Tom: formal, tabular, conciso

#### 6d. ONBOARDING.md (`maz-dashboard/ONBOARDING.md`)
- Arquivo Markdown no repo git — editar in-place (sem versionamento numérico)
- **Critério de sincronização:** atualizar ONBOARDING.md **somente** quando a mudança
  altera comportamento técnico — nova função JS, novo índice de coluna, nova armadilha,
  novo fluxo de dados, nova estrutura de pastas. Explicações de UX humanas ficam
  apenas no docx. Regra prática: *"Um dev experiente precisaria saber isso para
  trabalhar corretamente?" → sim = atualizar; não = só docx.*
- Tom: técnico, direto, com tabelas de referência e comandos literais
- Após editar, commitar junto com as demais alterações do ciclo doc-sync

#### 6e. DEV_GUIDE.html (`Manual/DEV_GUIDE.html`)
- Arquivo HTML sem versionamento numérico — editar in-place
- Atualizar quando houver mudanças técnicas relevantes
- Após atualizar, commitar para publicar no GitHub Pages
- URL pública: `https://pmo-creator.github.io/maz-dashboard/Manual/DEV_GUIDE.html`
- Tom: técnico, orientado a desenvolvedor, com exemplos de código quando aplicável

> ⚠️ Regra crítica: NUNCA resumir ou parafrasear comentários vindos da
> planilha Google Sheets. Sempre exibir texto bruto.

---

### ETAPA 7 — Geração de PDFs (OBRIGATÓRIA)

> **Por que obrigatório:** GitHub e usuários finais acessam apenas o PDF —
> o `.docx` é o arquivo de edição, o `.pdf` é o arquivo de consumo.
> Sem o PDF, a atualização está incompleta.

Para **cada** `.docx` criado ou atualizado, gerar o PDF correspondente
na mesma pasta. Nunca encerrar um ciclo doc-sync sem verificar que todos os PDFs
foram gerados e têm tamanho > 0.

---

### ETAPA 8 — Atualização do snapshot

Salvar o `index.html` atual como novo snapshot de referência:

```python
shutil.copy2(
    r"C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\index.html",
    r"C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\doc-sync\_snapshot_index.html"
)
```

---

### ETAPA 9 — Relatório final

Exibir resumo com links diretos:

```
✅ doc-sync concluído — [data]

Documentos atualizados:
• [Ver Manual vN](computer://C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\Manual\Manual de Uso e Manutenção Dashboard_vN.docx) · [PDF](computer://C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\Manual\Manual de Uso e Manutenção Dashboard_vN.pdf)
• [Ver Onboarding vN](computer://C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\Manual\Guia de Onboarding_Manutençao Dashboard_MAZ_2026_vN.docx) · [PDF](computer://C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\Manual\Guia de Onboarding_Manutençao Dashboard_MAZ_2026_vN.pdf)
• [Ver Ficha Técnica vN](computer://C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\Manual\Ficha_Tecnica_Dashboard_MAZ_2026_vN.docx) · [PDF](computer://C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\Manual\Ficha_Tecnica_Dashboard_MAZ_2026_vN.pdf)

Salvar relatório em: doc-sync/reports/doc-sync-relatorio-[data].md
```

---

## Regras de qualidade

1. **Nunca reescrever um documento inteiro** — editar cirurgicamente as seções afetadas
2. **Sempre pedir aprovação** antes de gravar qualquer arquivo
3. **Explicar em linguagem de leigo** — o usuário não precisa entender JS para aprovar
4. **Versionar sempre** — nunca sobrescrever sem incrementar versão
5. **Snapshot obrigatório** — sempre salvar novo snapshot ao final
6. **Git apenas com instrução explícita** — nunca rodar git add/commit/push automaticamente

---

## Para o próximo desenvolvedor

Esta skill vive em `maz-dashboard/doc-sync/SKILL.md`.
Para editar: abrir sessão Cowork com `maz-dashboard` montado → editar `doc-sync/SKILL.md`.

O doc-sync é executado **manualmente** — não há agendamento automático.
Para detectar se há mudanças pendentes, peça ao Claude: *"Checa se tem mudanças
no dashboard desde o último doc-sync"*.

Documentação completa em `Manual/Guia de Onboarding_Manutençao Dashboard_MAZ_2026_vXX.docx §10`.
