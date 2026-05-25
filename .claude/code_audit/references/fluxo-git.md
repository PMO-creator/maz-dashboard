# Referência: Fluxo Git e Teste vs. Produção

## 1. Push direto para main sem teste

### Commit vai direto para branch de produção
**Severidade:** 🟡 MÉDIO

O QUE É: Todo desenvolvimento acontece no branch `main`, que é o que está ao vivo.

POR QUE É MÁ PRÁTICA:
- Um commit com bug vai direto para o usuário final
- Sem rede de segurança entre "achei que funcionava" e "está em produção"
- Impossível ter código em revisão sem afetar o que está ao vivo

COMO CORRIGIR (progressivo):
- **Nível 1 (mínimo):** testar sempre em localhost antes de qualquer push
- **Nível 2 (recomendado):** criar branch `dev` para desenvolvimento, `main` só recebe
  código testado via Pull Request
- **Nível 3 (avançado):** GitHub Actions para rodar verificações automáticas no PR

VERIFICAR:
- Existe pasta local de teste separada do repositório de produção?
- O CLAUDE.md documenta o fluxo?
- Nunca editar direto na interface do GitHub (bypassa o teste local)

---

## 2. Ausência de CHANGELOG

### Sem registro do que mudou e quando
**Severidade:** 🟢 INFORMATIVO

O QUE É: Não há arquivo documentando o histórico de mudanças do projeto.

POR QUE É MÁ PRÁTICA:
- Impossível saber "o que mudou desde a última versão" sem ler todos os commits
- Cliente ou próximo dev não consegue rastrear evolução do projeto
- Difícil identificar qual commit introduziu um bug

COMO CORRIGIR:
Criar `CHANGELOG.md` na raiz do projeto com formato simples:
```markdown
# CHANGELOG

## [v3] — Mai/2026
- Adicionado filtro por Responsável
- Corrigida nomenclatura CSS (eixo/grupo/marco/tarefa)

## [v2] — Abr/2026
- Migração para Google Sheets API ao vivo
- Adicionado mobile.html
```

---

## 3. Commits sem mensagem descritiva

### Mensagem de commit genérica ou vazia
**Severidade:** 🟢 INFORMATIVO

O QUE É: Commit com mensagem como "update", "fix", "changes" sem descrever o que mudou.

POR QUE É MÁ PRÁTICA:
- Git log inútil — impossível saber o que cada commit fez
- Dificulta reverter para uma versão específica
- Péssima impressão em auditoria de código

COMO CORRIGIR — formato recomendado:
```
[tipo]: [o que foi feito] — [arquivo/área afetada]

Exemplos:
feat: adiciona filtro por responsável — header
fix: corrige nomenclatura CSS eixo/grupo/marco — index.html
docs: atualiza CLAUDE.md com nova armadilha de template literal
chore: atualiza snapshot de referência doc-sync
```

---

## 4. Arquivo sensível sem .gitignore

### Arquivo que não deve ir ao GitHub está sendo rastreado
**Severidade:** 🔴 CRÍTICO

O QUE É: Arquivo com credenciais, dados pessoais ou configuração local está
sendo commitado para o repositório.

POR QUE É MÁ PRÁTICA:
- Uma vez no histórico git, é quase impossível remover completamente
- GitHub indexa repositórios públicos — bots de scraping capturam em minutos

VERIFICAR — estes padrões NUNCA devem ir ao git:
```
.env
*.env
config.local.js
secrets.json
*.key
*.pem
node_modules/
__pycache__/
*.pyc
.DS_Store
Thumbs.db
```

COMO CORRIGIR:
```bash
# Criar/atualizar .gitignore
echo ".env" >> .gitignore
echo "secrets.json" >> .gitignore

# Se já foi commitado por engano:
git rm --cached .env
git commit -m "chore: remove .env do rastreamento git"
# E revogar qualquer credencial que estava no arquivo
```
