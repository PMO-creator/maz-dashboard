# Referência: Arquitetura

## 1. Separação de ambientes

### Ambiente de teste vs. produção mal definido
**Severidade:** 🟡 MÉDIO

O QUE É: Não há separação clara entre onde você testa e onde o código vai ao vivo.

POR QUE É MÁ PRÁTICA:
- Um erro em teste vai direto para produção
- Impossível reverter rapidamente se algo quebrar
- Usuários finais veem código incompleto ou com bugs

COMO CORRIGIR (boas práticas para o nível do projeto):
- Pasta local = ambiente de teste (nunca editar direto no GitHub)
- Repositório GitHub = produção (só vai para cá código testado)
- Nunca editar arquivos diretamente na interface do GitHub (vai direto para produção)
- Branch `dev` para desenvolvimento + `main` para produção (quando o projeto crescer)

VERIFICAR:
- Existe fluxo documentado de teste → produção?
- O `CLAUDE.md` descreve os dois ambientes?

---

## 2. Arquivo único muito grande

### Single-file acima de 300KB / 3000+ linhas
**Severidade:** 🟡 MÉDIO

O QUE É: Todo o código (HTML + CSS + JS) em um único arquivo gigante.

POR QUE É MÁ PRÁTICA:
- Difícil de editar sem introduzir bugs — qualquer mudança afeta tudo
- O próximo desenvolvedor leva horas para entender onde está cada coisa
- Sem separação de responsabilidades: bug de CSS pode quebrar o JS

QUANDO É ACEITÁVEL:
- Projetos de pequena escala com deploy simples (GitHub Pages)
- Quando "zero dependências" é um requisito explícito
- Documentar como decisão arquitetural consciente, não como débito

COMO MITIGAR SEM REFATORAR:
- Comentários de seção claros (`/* === SEÇÃO: GANTT === */`)
- CLAUDE.md documentando onde está cada coisa
- Nunca usar template literals aninhados (quebra silenciosamente)

---

## 3. Ausência de fallback para falha de serviço externo

### API externa sem tratamento de erro visível
**Severidade:** 🟢 INFORMATIVO

O QUE É: Se a API externa falhar, o usuário não sabe — vê dados desatualizados sem aviso.

POR QUE É MÁ PRÁTICA:
- Usuário toma decisão com dados que podem ter horas de atraso
- Difícil diagnosticar problemas ("o dashboard está errado" vs. "a API caiu")

COMO CORRIGIR:
- Adicionar indicador visual: "⚠️ Dados do cache — última atualização: [hora]"
- Logar erros no console: `console.error('API falhou:', error)`

---

## 4. Dependência externa sem fallback local

### CDN como única fonte de biblioteca crítica
**Severidade:** 🟢 INFORMATIVO

O QUE É: Biblioteca essencial (Chart.js, etc.) carregada só via CDN externo.

POR QUE É MÁ PRÁTICA:
- Se o CDN cair ou a versão for descontinuada, a funcionalidade para de funcionar
- Versão não fixada pode mudar comportamento automaticamente

COMO CORRIGIR:
- Fixar versão específica: `chart.js@4.5.1` não `chart.js@latest`
- Adicionar cópia local como fallback:
```html
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js"
        onerror="this.onerror=null;this.src='/libs/chart.min.js'"></script>
```
