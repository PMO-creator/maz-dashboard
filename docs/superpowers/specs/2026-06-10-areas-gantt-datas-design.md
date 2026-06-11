# Design: datas nas barras do Gantt de Áreas

**Data:** 2026-06-10  
**Escopo:** `renderAreaGantt` em `index.html`

## Objetivo

Exibir datas de início e fim nas barras de marcos e tarefas do Gantt de Áreas, tornando-o equivalente ao Gantt principal nesse aspecto.

## Comportamento por tipo de linha

### Marcos

- A barra e o label de status no centro permanecem **sem alteração**
- Adicionar dois `<text>` SVG **fora da barra**:
  - Início: `text-anchor="end"`, posicionado 5px à esquerda de `bx`, `font-size="13"`, `fill="#374151"`, condicional `bx > 50` (evita colar na borda esquerda)
  - Fim: posicionado 5px à direita de `bx2`, mesma fonte e cor, sem condição de largura
- Formato: `fmtBRshort` → `DD/MM`

### Tarefas

- As barras são segmentadas por semana (loop `weeks.forEach`)
- Rastrear o **primeiro** e o **último** segmento visível (com `_sS < _sE`)
- **Primeiro segmento** (largura ≥ 45px): data de início, alinhada à esquerda dentro da barra — `x = _bx + 4`, `text-anchor="start"`, `font-size="11"`, `fill="#FFF"`
- **Último segmento** (largura ≥ 45px): data de fim, alinhada à direita — `x = _bx2 - 4`, `text-anchor="end"`, mesma fonte
- Se início e fim estiverem no **mesmo segmento**: início à esquerda + fim à direita, desde que a largura seja ≥ 80px (espaço para os dois)
- Formato: `fmtBRshort` → `DD/MM`

## Localização no código

Função `renderAreaGantt`, linha ~3174, arquivo `index.html`.

- Bloco de marcos: linhas ~3318–3323
- Bloco de tarefas: linhas ~3360–3371

## Fora do escopo

- `mobile.html` (não alterado)
- Gantt principal (não alterado)
- Export PDF (não alterado)
