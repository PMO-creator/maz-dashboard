---
name: code_audit
description: >
  Auditor de código contínuo para projetos de desenvolvimento. USAR SEMPRE que:
  o usuário mencionar "commit", "push", "produção", "audita", "revisa o código",
  "vou subir", "tá pronto"; quando o usuário adicionar dependência externa (CDN,
  biblioteca, npm); quando mexer em API key, autenticação ou permissões; quando
  fizer uma alteração grande (3+ funções ou seções); no início de cada sessão de
  desenvolvimento. Sempre perguntar antes de rodar, explicando o motivo da sugestão.
  Analisa o que mudou (git diff), aponta problemas reais com explicação educativa
  (o que está errado + como corrigir + por que é má prática), em português.
---

# code_audit — Auditor de Código Contínuo

Auditor educativo de boas práticas para projetos de desenvolvimento frontend/web.
Foco: aprender enquanto desenvolve, não apenas detectar problemas.

---

## Filosofia

- **Evidence-first:** nunca "pode ser um problema" — sempre "encontrei isso, e
  aqui está por que é arriscado"
- **Educativo:** todo finding tem 3 partes: O QUE é, POR QUE é má prática,
  COMO corrigir
- **Proporcional:** severidade calibrada para o contexto real do projeto
- **Não-intrusivo:** sempre pergunta antes de rodar, com o motivo da sugestão

---

## Gatilhos — quando sugerir a auditoria

O Claude Code deve sugerir rodar esta skill nos seguintes momentos,
**sempre perguntando antes** com o motivo:

| Situação detectada | Mensagem sugerida |
|---|---|
| Usuário menciona commit/push/produção | "Antes de subir, quer que eu audite o que mudou? Detectei alterações em [arquivo]." |
| Adição de CDN, biblioteca, import externo | "Adicionei uma dependência externa. Boa prática revisar antes de continuar — quer auditar?" |
| Mudança em API key, autenticação, permissão | "Mexi em algo sensível de segurança. Recomendo uma auditoria rápida agora." |
| Alteração grande (3+ funções/seções) | "Fizemos bastante coisa. Bom momento para auditar antes de continuar." |
| Início de sessão (SessionStart) | "Sessão iniciada. Quer um resumo do estado atual do projeto antes de começar?" |

> ⚠️ NUNCA rodar automaticamente sem perguntar. O usuário decide quando executar.

---

## Fluxo de execução

### ETAPA 0 — Leitura do contexto do projeto

Ler o `CLAUDE.md` do projeto atual para entender:
- Stack e arquitetura
- Arquivos principais
- Armadilhas conhecidas
- Ambiente de teste vs. produção

Se não houver `CLAUDE.md`, pedir ao usuário para descrever brevemente o projeto.

---

### ETAPA 1 — Captura do diff

```bash
# O que mudou desde o último commit
git diff HEAD

# Se não há commits ainda:
git diff
```

Se o diff estiver vazio → informar o usuário e encerrar:
```
✅ Nenhuma alteração desde o último commit. Nada a auditar.
```

Se for `--sessao`: ler APENAS o `CLAUDE.md` e apresentar resumo do estado
do projeto. NUNCA ler `index.html`, `mobile.html` ou qualquer arquivo de
código no `--sessao` — isso é responsabilidade do `--completo`.

---

### ETAPA 2 — Análise por dimensões

Analisar o diff contra as 5 dimensões. Carregar referências detalhadas
conforme necessário:

| Dimensão | Referência | Quando carregar |
|---|---|---|
| Segurança | `references/seguranca.md` | Sempre |
| Arquitetura | `references/arquitetura.md` | Se diff > 50 linhas |
| Código | `references/codigo.md` | Sempre |
| Fluxo teste/produção | `references/fluxo-git.md` | Se mencionou push/commit |
| Dependências | `references/dependencias.md` | Se adicionou import/CDN |

---

### ETAPA 3 — Relatório no chat

Formato obrigatório para cada finding:

```
🔴/🟡/🟢 [SEVERIDADE] — [TÍTULO CURTO]

O QUE É:
[Descrição direta do problema encontrado, com trecho do código se relevante]

POR QUE É MÁ PRÁTICA:
[Explicação educativa — o risco real, não teórico]

COMO CORRIGIR:
[Instrução concreta e acionável]
```

Encerrar com resumo:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━
RESUMO DA AUDITORIA — [data]

🔴 Crítico:    X finding(s)
🟡 Médio:      X finding(s)
🟢 Informativo: X finding(s)

Próximo passo recomendado: [ação prioritária]
━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### ETAPA 4 — Oferta de correção

Ao final, sempre perguntar:

```
Quer que eu corrija algum desses pontos agora?
Se sim, diga qual — ou posso priorizar o mais crítico.
```

---

## Regras de qualidade

1. **Proporcional ao contexto:** um projeto HTML estático tem riscos diferentes de
   um backend com banco de dados — calibrar severidade adequadamente
2. **Sem alarme falso:** não marcar como crítico o que é aceitável para o contexto
3. **Máximo 8 findings por auditoria:** priorizar os mais relevantes — quantidade
   não é qualidade
4. **Sempre em português:** relatório, explicações e sugestões
5. **Evidence-first:** citar o trecho exato do código quando possível
6. **Nunca gerar arquivo .md:** resultado apenas no chat, exceto se usuário
   pedir explicitamente com "/audita --exportar"

---

## Comando manual

O usuário pode acionar a qualquer momento escrevendo em linguagem natural:

| O que digitar | O que faz | Custo |
|---|---|---|
|  ou  | Só o que mudou desde o último commit | Leve |
|  | Lê só o CLAUDE.md, resume o projeto | Leve |
|  | Lê todos os arquivos do projeto | Pesado — use com moderação |
|  | Gera arquivo para handover | Pesado — só para handover |

> ⚠️ Não usar  — o Claude Code não reconhece slash commands customizados.
> Sempre usar linguagem natural.

---

## Configuração para novos projetos

Na primeira execução em um projeto novo, verificar:

1. ✅ Existe `CLAUDE.md` com arquitetura documentada?
2. ✅ Existe separação clara de ambiente de teste vs. produção?
3. ✅ O repositório está inicializado com git?
4. ✅ Existe `.gitignore` adequado?

Se algum for "não", reportar como finding e sugerir correção.

---

## Para instalar

### Skill (global — vale para todos os projetos):
```bash
# Copiar para pasta global de skills do Claude Code
cp -r code_audit/ ~/.claude/skills/code_audit/
```

### Hooks (global — em ~/.claude/settings.json):
Ver arquivo `settings.json` incluído nesta skill.

---

## Referências

- `references/seguranca.md` — Padrões de segurança: API keys, autenticação, dados expostos
- `references/arquitetura.md` — Boas práticas de arquitetura frontend/web
- `references/codigo.md` — Qualidade de código: nomenclatura, manutenibilidade, comentários
- `references/fluxo-git.md` — Boas práticas git: branches, commits, teste vs. produção
- `references/dependencias.md` — Gestão de dependências externas: CDN, versões, fallbacks
