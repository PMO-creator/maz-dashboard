# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Arquitetura

Dois arquivos HTML self-contained: `index.html` (desktop) e `mobile.html` (mobile). Cada um contém todo o HTML, CSS e JS inline — sem módulos, sem build step, sem dependências locais.

- Dados via Google Sheets API diretamente no browser — sem backend
- Chart.js carregado via CDN para gráficos
- Gantt renderizado em SVG gerado dinamicamente
- Publicado em GitHub Pages: `pmo-creator.github.io/maz-dashboard`
- Auto-redirect: desktop→mobile e vice-versa baseado em `navigator.userAgent` + `window.innerWidth`

## Comandos de Desenvolvimento

**Servidor local (necessário — API Key não funciona via `file://`):**
```
SERVE_DASHBOARD.bat
```
Ou manualmente: `python -m http.server 8765` → abrir `http://localhost:8765/index.html`

**Validar JS extraído de HTML:**
```powershell
# Extrair bloco <script> para arquivo temporário e checar sintaxe
node --check temp.js
```
`node --check` não aceita `.html` direto — extrair para `.js` antes.

**Deploy:** push para `main` → GitHub Pages atualiza automaticamente (sem CI/CD).

## Estrutura WBS (hierarquia de dados)

```
EIXO → GRUPO → MARCO → TAREFA
```

```javascript
const WBS = [
  { id, name, status, children: [        // EIXO
    { name, status, start, end, tasks: [ // GRUPO
      { tarefa, tipo:'marco', status, start, end, subtasks: [ // MARCO
        { tarefa, status, start, end }   // TAREFA
      ]}
    ]}
  ]}
]
```

## Mapeamento CSS → Hierarquia (CRÍTICO)

| Nome | Classe CSS |
|---|---|
| EIXO | `.group-name` |
| GRUPO | `.marco-name` |
| MARCO | `.mb-name` |
| TAREFA | `.tc-name` |

Os nomes das classes são contra-intuitivos — `.group-name` é o nível mais alto (EIXO), não grupo.

## Status válidos

`Atrasado` · `Risco de atraso` · `Em andamento` · `A iniciar` · `Definir datas` · `Feito` · `Cancelado/Congelado`

- Não existe "Cancelado" isolado — sempre `Cancelado/Congelado` (cor `#374151`)
- `Definir datas`: cor `#92400E`

## Mapeamento colunas REQS (índice base 0)

| Índice | Campo | Observação |
|---|---|---|
| 0 | `req` | Número da requisição |
| 2 | `comp` | Componente/área |
| 4 | `prio` | Prioridade — **usar APENAS esta** |
| 5 | `desc` | Descrição |
| 6 | `status` | Status atual |
| 7 | `forn` | Fornecedor |
| 12 | `fin` | Data de finalização |

Col B (índice 1) também tem um campo parecido com prioridade — ignorar, gera falsos positivos.

## Google Sheets

| Planilha | ID | Aba |
|---|---|---|
| Cronograma | `17nttJ_ShqWztvDWH3l59iNqboLqkviZs3_PM5J3ihdA` | `master data` |
| Requisições | `1azrdS4OGO-CWD1ods69i8iZJcwq4oyISdT2n_tu1uJM` | `Planilha de Status de Compras Prod` |

## API Key

- Restrita a `pmo-creator.github.io/*`
- Localhost retorna 403 propositalmente — comportamento esperado
- Dev local: criar chave própria restrita a `localhost:8765` no Google Console

## Gantt — SVG dimensões

```javascript
const LW = 280   // largura coluna de nomes
const TW = 1800  // largura timeline
const GRH = 68   // altura linha grupo
const TRH = 50   // altura linha marco/task
const SRH = 38   // altura linha tarefa
```

## Ordem de desenho SVG (não alterar)

1. Background rect
2. Stripes/linhas
3. Holofote filtro de data
4. Rows: backgrounds + barras + labels
5. Linha-guia horizontal
6. Label column overlay
7. Re-draw labels
8. Separador vertical
9. **Header rects por último** (cobrem tudo)

## ⚠️ Armadilhas críticas

1. **Dashboard branco sem erro** → checar: null bytes, `function` ausente, JS truncado, template literals aninhados
2. **Template literals aninhados** → nunca backtick dentro de `${}` dentro de outro backtick
3. **JS truncado** → verificar `</script>` no final antes de editar
4. **Prioridade REQS** → APENAS col E (índice 4) — col B gera falsos positivos
5. **`node --check` Node v22** → não aceita `.html` — extrair para `.js` temporário
6. **Write/Edit pode truncar mid-line** em arquivos grandes → verificar última linha após editar
7. **`display:none` em elementos com `max-height` JS** → nunca — usar `max-height:0`
8. **Emoji com CSS filter** → nunca — renderizado pelo SO, filter quebra aparência
9. **Edit tool com backticks** → falha ao fazer match em strings com backtick `` ` `` — usar PowerShell `[System.IO.File]` para substituições nesses casos

## Histórico de decisões importantes

### Mai/2026 — Reestruturação completa

**API Key:**
- Chave antiga (AIzaSyAayG0UP7kFxt165Zu38BMz0P1hgvGtq18) invalidada e deletada no Google Console
- Nova chave restrita a pmo-creator.github.io/* apenas

**Arquitetura:**
- Arquivos migrados de Dashboard/ para raiz do repositório
- `gerar_dashboard.py` e `ATUALIZAR_DASHBOARD.bat` descontinuados
- Dados passaram a ser buscados diretamente no browser via API Key
- Não há mais geração local de HTML via Python

**Abas das planilhas (mudança crítica):**
- Cronograma: de `"cronograma exposição "` para `"master data"`
- Requisições: de `"Planilha de Status de Compras P"` para `"Planilha de Status de Compras Prod"`
