---
name: code-audit
description: >
  Auditor de código do Dashboard MAZ 2026. USAR SEMPRE que o dev disser
  "audita", "auditoria", "revisa o código", "code review", "o que mudou",
  "está seguro commitar?" ou qualquer variação. Analisa index.html e/ou
  mobile.html completos em busca de problemas de segurança, arquitetura,
  qualidade de código, armadilhas JavaScript e dependências externas.
  Roda via Claude Code (terminal) com a pasta maz-dashboard aberta.
---

# code-audit — Auditor de Código Dashboard MAZ 2026

## Contexto do projeto

Antes de auditar, leia o `CLAUDE.md` e o `ONBOARDING.md` na raiz do repo.
Eles contêm: regras de trabalho, mapeamento de colunas das planilhas,
regras de auto-status, armadilhas técnicas conhecidas e estrutura WBS.

**Caminhos importantes:**
- Repo: `C:\Users\gagui\OneDrive\Documentos\GitHub\maz-dashboard\`
- Dashboard desktop: `index.html` (~330 KB)
- Dashboard mobile: `mobile.html` (~43 KB)
- Armadilhas conhecidas: `ONBOARDING.md §9`

---

## Modos de execução

O dev escolhe o modo ao acionar a skill:

| O que digitar | Modo | Escopo |
|---|---|---|
| `"audita o que mudou"` | **Diff** | Só `git diff` atual — leve e rápido |
| `"auditoria completa"` | **Full** | Lê index.html + mobile.html inteiros |
| `"audita o index"` | **File** | Só index.html |
| `"audita o mobile"` | **File** | Só mobile.html |

Se o dev não especificar, perguntar qual modo antes de começar.

---

## ETAPA 1 — Coleta do código

**Modo Diff:**
```bash
git diff
git diff --cached   # inclui staged
```

**Modo Full / File:**
Ler o(s) arquivo(s) HTML completo(s) com a ferramenta Read.

---

## ETAPA 2 — Análise por categoria

Para cada trecho de código relevante, verificar as categorias abaixo.
Reportar apenas achados reais — não inventar alertas.

### 🔴 Segurança
- API Key exposta ou hardcoded fora do escopo esperado
- URLs externas novas não listadas no ONBOARDING.md
- Inputs sem sanitização inseridos no DOM via `innerHTML`
- Fetch sem tratamento de erro que possa vazar dados sensíveis

### 🟠 Arquitetura
- Lógica de negócio duplicada entre index.html e mobile.html sem comentário explicativo
- Funções com mais de ~150 linhas sem separação clara de responsabilidades
- Constantes (API Key, Sheet IDs) alteradas sem justificativa visível
- Novos campos de planilha consumidos sem atualizar `_parseWBS` ou `_parseREQS`

### 🟡 Qualidade de código
- Template literals aninhados (crase dentro de `${}` — passa no `node --check` mas quebra no browser)
- `</script>` ausente ou truncado no final do bloco JS
- Null bytes ou caracteres invisíveis no HTML
- Variáveis declaradas mas não usadas
- `console.log` de debug esquecidos no código

### 🔵 Fluxo Git
- Arquivos grandes (>500 KB) sendo adicionados inadvertidamente
- Arquivos de ambiente ou segredos (`.env`, `*.key`) rastreados
- Mensagem de commit ausente ou genérica ("update", "fix")

### ⚪ Dependências externas
- CDNs novas adicionadas — verificar se são confiáveis
- Versões de bibliotecas fixadas ou sem integridade (SRI hash)
- Remoção de dependências existentes sem substituição

---

## ETAPA 3 — Verificação das armadilhas conhecidas

Checar explicitamente as armadilhas do `ONBOARDING.md §9`:

| Armadilha | O que verificar |
|---|---|
| Dashboard branco | Null bytes, `function` ausente, JS truncado, template literals aninhados |
| Prioridade REQS | Coluna D (índice 3) sendo usada — nunca coluna B |
| `node --check` no Node v22 | Se o dev tentar rodar `.html` diretamente (orientar a extrair o `<script>`) |
| Edit tool com backticks | Aviso se o diff mostrar template literals problemáticos |
| String CRLF | Se o diff mostrar mudanças só de line endings, orientar sobre normalização |

---

## ETAPA 4 — Relatório final

Estruturar a resposta assim:

```
## Resultado da auditoria — [modo] — [data]

### Resumo
[Aprovado / Aprovado com ressalvas / Reprovado] — [1 frase explicando]

### Achados

🔴 CRÍTICO (bloqueia commit)
- [item] → [onde está] → [como corrigir]

🟠 IMPORTANTE (corrigir antes do próximo push)
- [item] → [onde está] → [como corrigir]

🟡 ATENÇÃO (melhorias recomendadas)
- [item] → [onde está] → [sugestão]

🔵 GIT
- [item]

✅ Sem achados em: [categorias limpas]

### Próximos passos recomendados
[Lista curta e acionável]
```

Se não houver nenhum achado em todas as categorias:
> ✅ Código aprovado — pode commitar com segurança.

---

## Regras de conduta

- **Nunca executar** `git add`, `git commit` ou `git push` — só analisar
- **Nunca alterar** index.html ou mobile.html durante a auditoria
- Se o dev pedir para corrigir um achado, sair do modo auditoria e confirmar antes de editar
- Ser direto: achados críticos primeiro, sem eufemismos
