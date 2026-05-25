# Referência: Dependências Externas

## 1. CDN sem versão fixada

### Biblioteca carregada com @latest ou sem versão
**Severidade:** 🟡 MÉDIO

O QUE É: URL de CDN que não especifica versão exata da biblioteca.

POR QUE É MÁ PRÁTICA:
- Uma atualização automática da biblioteca pode quebrar seu código
- Impossível reproduzir um bug se a versão muda sem você saber
- `@latest` hoje pode ser uma versão com breaking changes amanhã

COMO CORRIGIR:
```html
<!-- ❌ Sem versão fixada -->
<script src="https://cdn.jsdelivr.net/npm/chart.js/dist/chart.umd.min.js"></script>

<!-- ✅ Com versão fixada -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js"></script>
```

VERIFICAR:
- Toda URL de CDN tem versão específica (`@4.5.1`, `/4.5.1/`)?
- A versão usada tem CVE conhecido? Checar em https://snyk.io/vuln

---

## 2. CDN sem fallback local

### Dependência crítica sem cópia local de emergência
**Severidade:** 🟢 INFORMATIVO

O QUE É: Se o CDN cair, a funcionalidade para completamente.

POR QUE É MÁ PRÁTICA:
- CDNs caem (raro, mas acontece)
- Em apresentações ou demos ao vivo, uma CDN lenta pode travar tudo

COMO CORRIGIR:
```html
<!-- Tenta CDN primeiro, cai para local se falhar -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js"
        onerror="this.onerror=null;this.src='/libs/chart.min.js'"></script>
```

Baixar e salvar no repositório:
```bash
# Criar pasta de libs locais
mkdir libs
curl -o libs/chart.min.js https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js
```

---

## 3. Nova dependência adicionada sem avaliação

### Import ou CDN novo incluído sem análise
**Severidade:** 🟡 MÉDIO (gatilho automático de sugestão de auditoria)

O QUE É: Uma biblioteca ou recurso externo foi adicionado ao projeto.

CHECKLIST para toda nova dependência:
- [ ] A biblioteca é mantida ativamente? (último commit no GitHub)
- [ ] Tem vulnerabilidades conhecidas? (snyk.io/vuln)
- [ ] A versão está fixada?
- [ ] É realmente necessária, ou existe forma nativa de fazer o mesmo?
- [ ] O domínio do CDN é confiável? (jsdelivr, cdnjs, unpkg são seguros)
- [ ] Foi adicionada ao CLAUDE.md como dependência do projeto?

DOMÍNIOS CDN CONFIÁVEIS:
- `cdn.jsdelivr.net` ✅
- `cdnjs.cloudflare.com` ✅
- `unpkg.com` ✅
- `cdn.googleapis.com` ✅
- Domínios desconhecidos ou pessoais ❌ — verificar antes de usar

---

## 4. Subresource Integrity (SRI) ausente

**Severidade:** 🟢 INFORMATIVO

O QUE É: Atributo de segurança que garante que o arquivo baixado do CDN não foi
adulterado.

POR QUE É MÁ PRÁTICA:
- Sem SRI, se o CDN for comprometido, código malicioso pode ser injetado no seu site

COMO CORRIGIR:
```html
<!-- Com SRI — o hash garante integridade -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js"
        integrity="sha384-[hash-aqui]"
        crossorigin="anonymous"></script>
```

Gerar o hash em: https://www.srihash.org/

NOTA: Para projetos simples internos, SRI é bom ter mas não crítico.
Priorizar outras melhorias primeiro.
