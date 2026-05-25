# Referência: Segurança

## 1. API Keys e credenciais

### Hardcoded no código
**Severidade:** 🔴 CRÍTICO (backend) / 🟡 MÉDIO (frontend restrito)

O QUE É: Chave de API, senha, token ou credencial escrita diretamente no código-fonte.

POR QUE É MÁ PRÁTICA:
- Qualquer pessoa com acesso ao repositório (ou que inspecionar o HTML) vê a chave
- Git guarda histórico para sempre — mesmo depois de deletar, a chave fica nos commits antigos
- Bots varrem GitHub automaticamente procurando por padrões de chaves expostas

COMO CORRIGIR (por contexto):
- **Frontend puro (sem backend):** restringir a chave por domínio/referrer no console do provedor + documentar a limitação arquitetural + rotacionar a cada 90 dias
- **Projeto com backend:** mover para variável de ambiente (`.env`) + adicionar `.env` ao `.gitignore`
- **Histórico git comprometido:** revogar a chave imediatamente + emitir nova

VERIFICAR:
- Padrões: `AIza`, `sk-`, `ghp_`, `Bearer `, `password=`, `secret=`
- O `.gitignore` exclui arquivos `.env`?
- A chave antiga foi revogada se já foi exposta?

---

## 2. Permissões de dados

### Dados com acesso público não intencional
**Severidade:** 🟡 MÉDIO

O QUE É: Planilha, banco de dados ou arquivo acessível por qualquer pessoa com o link.

POR QUE É MÁ PRÁTICA:
- Dados do projeto (cronogramas, requisições, fornecedores) expostos publicamente
- IDs de planilhas no código + planilha aberta = qualquer pessoa acessa os dados

COMO CORRIGIR:
- Verificar permissão: "Restrito" (apenas pessoas autorizadas) vs. "Qualquer pessoa com o link"
- Para dashboards internos: sempre "Restrito" + API key read-only

---

## 3. Dados sensíveis em URLs

### IDs e parâmetros expostos em query strings
**Severidade:** 🟢 INFORMATIVO

O QUE É: IDs de recursos, tokens ou dados do usuário passados como parâmetros de URL.

POR QUE É MÁ PRÁTICA:
- URLs aparecem em logs de servidor, histórico do browser e cabeçalhos Referer
- Podem ser compartilhadas acidentalmente

COMO CORRIGIR:
- Dados sensíveis em POST body, não em URL
- Tokens de sessão em cookies HTTPOnly, não em query string

---

## 4. Dependências com vulnerabilidades conhecidas

### Biblioteca externa desatualizada ou com CVE
**Severidade:** 🟡 MÉDIO

O QUE É: Uso de versão antiga de biblioteca que tem vulnerabilidade conhecida publicada.

POR QUE É MÁ PRÁTICA:
- CVEs (vulnerabilidades) são públicos — atacantes sabem exatamente como explorar
- CDN sem versão fixada (`@latest`) pode puxar versão vulnerável automaticamente

COMO CORRIGIR:
- Fixar versão específica no CDN (`@4.5.1` em vez de `@latest`)
- Verificar CVEs em: https://snyk.io/vuln ou https://cve.mitre.org

---

## 5. Ausência de Content Security Policy (CSP)

**Severidade:** 🟢 INFORMATIVO (para projetos simples)

O QUE É: Cabeçalho HTTP que controla quais recursos o browser pode carregar.

POR QUE É MÁ PRÁTICA:
- Sem CSP, scripts injetados por XSS têm acesso total à página
- Para GitHub Pages: limitação de plataforma — não é configurável diretamente

COMO CORRIGIR:
- GitHub Pages não suporta cabeçalhos customizados nativamente
- Documentar como limitação arquitetural aceita
- Alternativa: adicionar meta tag `<meta http-equiv="Content-Security-Policy">`
