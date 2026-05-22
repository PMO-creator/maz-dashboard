\# Contexto do Projeto — Dashboard MAZ 2026

> Lido automaticamente pelo Claude Code ao abrir este repositório.



\## Arquitetura

\- Dois arquivos HTML self-contained: `index.html` (desktop) e `mobile.html` (mobile)

\- Dados via Google Sheets API Key direta no browser — sem backend

\- Publicado em GitHub Pages: `pmo-creator.github.io/maz-dashboard`



\## Estrutura WBS (hierarquia de dados)

```

EIXO → GRUPO → MARCO → TAREFA

```

```javascript

const WBS = \[

&#x20; { id, name, status, children: \[        // EIXO

&#x20;   { name, status, start, end, tasks: \[ // GRUPO

&#x20;     { tarefa, tipo:'marco', status, start, end, subtasks: \[ // MARCO

&#x20;       { tarefa, status, start, end }   // TAREFA

&#x20;     ]}

&#x20;   ]}

&#x20; ]}

]

```



\## Mapeamento CSS → Hierarquia (CRÍTICO)

| Nome | Classe CSS |

|---|---|

| EIXO | `.group-name` |

| GRUPO | `.marco-name` |

| MARCO | `.mb-name` |

| TAREFA | `.tc-name` |



\## Status válidos

`Atrasado` · `Risco de atraso` · `Em andamento` · `A iniciar` ·

`Definir datas` · `Feito` · `Cancelado/Congelado`



\- Não existe "Cancelado" — sempre "Cancelado/Congelado" (`#374151`)

\- `Definir datas`: cor `#92400E`



\## Mapeamento colunas REQS (índice base 0)

| Índice | Campo | Observação |

|---|---|---|

| 0 | `req` | Número da requisição |

| 2 | `comp` | Componente/área |

| 4 | `prio` | Prioridade — \*\*usar APENAS esta\*\* |

| 5 | `desc` | Descrição |

| 6 | `status` | Status atual |

| 7 | `forn` | Fornecedor |

| 12 | `fin` | Data de finalização |



\## Google Sheets

| Planilha | ID | Aba |

|---|---|---|

| Cronograma | `17nttJ\_ShqWztvDWH3l59iNqboLqkviZs3\_PM5J3ihdA` | `master data` |

| Requisições | `1azrdS4OGO-CWD1ods69i8iZJcwq4oyISdT2n\_tu1uJM` | `Planilha de Status de Compras Prod` |



\## API Key

\- Restrita a `pmo-creator.github.io/\*`

\- Não funciona em localhost — usar chave própria para dev local

\- Valor: solicitar ao responsável



\## Gantt — SVG dimensões

```javascript

const LW = 280   // largura coluna de nomes

const TW = 1800  // largura timeline

const GRH = 68   // altura linha grupo

const TRH = 50   // altura linha marco/task

const SRH = 38   // altura linha tarefa

```



\## Ordem de desenho SVG (não alterar)

1\. Background rect

2\. Stripes/linhas

3\. Holofote filtro de data

4\. Rows: backgrounds + barras + labels

5\. Linha-guia horizontal

6\. Label column overlay

7\. Re-draw labels

8\. Separador vertical

9\. \*\*Header rects por último\*\* (cobrem tudo)



\## ⚠️ Armadilhas críticas

1\. \*\*Dashboard branco sem erro\*\* → checar: null bytes, `function` ausente, JS truncado, template literals aninhados

2\. \*\*Template literals aninhados\*\* → nunca crase dentro de `${}` dentro de outro crase

3\. \*\*JS truncado\*\* → verificar `</script>` no final antes de editar

4\. \*\*Prioridade REQS\*\* → APENAS col E (índice 4) — col B gera falsos positivos

5\. \*\*`node --check` Node v22\*\* → não aceita `.html` — extrair para `.js` temporário

6\. \*\*Write/Edit pode truncar mid-line\*\* em arquivos grandes → verificar última linha

7\. \*\*`display:none` em elementos com `max-height` JS\*\* → nunca — usar `max-height:0`

8\. \*\*Emoji com CSS filter\*\* → nunca — renderizado pelo SO



---

\## Histórico de decisões importantes

\### Mai/2026 — Reestruturação completa

\*\*API Key:\*\*

\- Chave antiga (AIzaSyAayG0UP7kFxt165Zu38BMz0P1hgvGtq18) invalidada e deletada no Google Console

\- Nova chave restrita a pmo-creator.github.io/\* apenas

\- Localhost retorna 403 propositalmente — comportamento esperado

\- Dev local deve criar chave própria restrita a localhost:8765



\*\*Arquitetura:\*\*

\- Arquivos migrados de Dashboard/ para raiz do repositório

\- gerar\_dashboard.py e ATUALIZAR\_DASHBOARD.bat descontinuados

\- Dados passaram a ser buscados diretamente no browser via API Key

\- Não há mais geração local de HTML via Python



\*\*Repositório:\*\*

\- CLAUDE.md criado como contexto técnico para o Claude Code

\- SERVE\_DASHBOARD.bat adicionado para teste local

\- ONBOARDING.md melhorado com emojis e separadores

\- ONBOARDING\_GUIA.pdf adicionado — versão visual do guia

\- Manual\_Dashboard\_MAZ\_2026.pdf adicionado — manual do usuário final



\*\*Abas das planilhas (mudança crítica):\*\*

\- Cronograma: de "cronograma exposição " para "master data"

\- Requisições: de "Planilha de Status de Compras P" para "Planilha de Status de Compras Prod"
