# Referência: Qualidade de Código

## 1. Nomenclatura contra-intuitiva

### Classes CSS ou variáveis com nomes que contradizem sua função
**Severidade:** 🟡 MÉDIO

O QUE É: Um elemento tem um nome no código que não corresponde ao que ele representa
visualmente ou funcionalmente.

POR QUE É MÁ PRÁTICA:
- O próximo desenvolvedor vai procurar `.grupo-name` para encontrar o grupo
  e vai mexer na coisa errada
- Bugs de manutenção são os mais difíceis de encontrar porque "tudo parece certo"
- Multiplica o tempo de onboarding de qualquer dev novo

COMO CORRIGIR:
- Renomear para refletir a realidade: `.eixo-name`, `.grupo-name`, `.marco-name`
- Fazer substituição global (busca e substitui) — nunca manual linha a linha
- Documentar no CLAUDE.md se a renomeação não for possível agora

---

## 2. Ausência de comentários em lógica complexa

### Código que faz algo não óbvio sem explicação
**Severidade:** 🟢 INFORMATIVO

O QUE É: Função ou bloco de código que realiza lógica não trivial sem nenhum comentário.

POR QUE É MÁ PRÁTICA:
- Em 3 meses, nem você mesmo vai lembrar por que escreveu assim
- O próximo dev vai "corrigir" o que na verdade é intencional

COMO CORRIGIR:
- Comentar o "por quê", não o "o quê":
```javascript
// ❌ Ruim: incrementa o índice
i++;

// ✅ Bom: pula a linha de cabeçalho (índice 0 e 1 são headers no Sheet)
i += 2;
```
- Armadilhas conhecidas DEVEM ter comentário inline além do CLAUDE.md

---

## 3. Template literals aninhados

### Backtick dentro de ${} dentro de outro backtick
**Severidade:** 🔴 CRÍTICO

O QUE É: Template literal JavaScript aninhado — crase dentro de `${}` dentro de outra crase.

POR QUE É MÁ PRÁTICA:
- `node --check` passa sem erro
- O browser quebra silenciosamente em runtime — página branca sem mensagem de erro
- Extremamente difícil de debugar

COMO CORRIGIR:
```javascript
// ❌ Nunca fazer:
const html = `<div class="${`prefix-${nome}`}">`;

// ✅ Fazer assim:
const classe = `prefix-${nome}`;
const html = `<div class="${classe}">`;
```

---

## 4. Ausência de validação de dados externos

### Dados de API usados sem verificação de formato
**Severidade:** 🟡 MÉDIO

O QUE É: Dados recebidos de API externa (Google Sheets, etc.) são usados diretamente
sem verificar se têm o formato esperado.

POR QUE É MÁ PRÁTICA:
- Se alguém mudar o nome de uma coluna na planilha, o dashboard quebra silenciosamente
- Impossível distinguir "API retornou vazio" de "coluna foi renomeada"

COMO CORRIGIR:
```javascript
// ❌ Sem validação:
const nome = rows[i][3];

// ✅ Com validação básica:
const nome = rows[i]?.[3] ?? 'Sem nome';
// Ou com log de aviso:
if (!rows[i][3]) console.warn(`Linha ${i}: campo Marco vazio`);
```

---

## 5. Ausência de tratamento de erro no fetch

### Requisição HTTP sem catch de erro
**Severidade:** 🟡 MÉDIO

O QUE É: Chamada para API externa sem tratar o caso de falha.

POR QUE É MÁ PRÁTICA:
- Falha silenciosa — usuário não sabe, desenvolvedor não sabe
- Impossível diagnosticar problemas em produção

COMO CORRIGIR:
```javascript
// ❌ Sem tratamento:
fetch(url).then(r => r.json()).then(data => processar(data));

// ✅ Com tratamento:
fetch(url)
  .then(r => {
    if (!r.ok) throw new Error(`HTTP ${r.status}`);
    return r.json();
  })
  .then(data => processar(data))
  .catch(err => {
    console.error('Falha ao carregar dados:', err);
    // Mostrar indicador visual de dados desatualizados
  });
```
