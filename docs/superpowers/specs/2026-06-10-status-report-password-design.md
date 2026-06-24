# Design: Proteção por Senha — Aba Status Report

**Data:** 2026-06-10  
**Escopo:** index.html — aba `eap` (Status Report)

## Problema

Durante os 4 dias de atualização do status report, o PMO e gerentes editam a planilha enquanto realizam reuniões. Outros usuários abrem a aba acidentalmente e conflitam com o trabalho em andamento.

## Solução

Modal de senha no acesso à aba Status Report. Grupo pequeno (PMO + gerentes) compartilha a senha fora do sistema.

## Comportamento

1. Usuário clica no botão "Status Report" na barra de abas
2. Se `sessionStorage.getItem('eap_unlocked')` for `'1'` → acesso direto (já autenticado nesta sessão)
3. Se não → exibe modal de senha
4. Senha correta → salva `sessionStorage`, fecha modal, abre aba
5. Senha errada → exibe mensagem de erro, campo limpo, foco no input
6. "Cancelar" → fecha modal, permanece na aba atual

## Componentes

### HTML — Modal
- Overlay fixo `z-index:10000` (acima dos modais existentes que usam 9999)
- Card centralizado com: título, campo password, botão Entrar, botão Cancelar, div de erro
- `id="eap-pw-modal"`, segue estilo inline dos modais existentes

### JS — Constante de senha
```js
const EAP_PASSWORD = 'maz2026'; // alterar aqui para mudar a senha
```

### JS — Interceptação em switchTab
```js
if (name === 'eap') {
  if (sessionStorage.getItem('eap_unlocked') !== '1') {
    _showEapModal();
    return;
  }
}
```

### JS — Funções
- `_showEapModal()` — exibe o modal, foca no input
- `_submitEapPassword()` — valida senha, salva sessionStorage ou mostra erro
- `_closeEapModal()` — esconde modal

## Localização das edições em index.html

| O quê | Onde |
|---|---|
| HTML do modal | Após linha 537 (junto aos outros modais) |
| Constante `EAP_PASSWORD` | Próximo ao início do `<script>`, fácil de localizar |
| Interceptação em `switchTab` | Linha 840, início da função |
| Funções `_showEapModal` etc. | Após `hideDateError` (~linha 1795) |

## Fora do escopo

- mobile.html (avaliar separadamente se necessário)
- Expiração de senha / rotação automática
- Múltiplos níveis de acesso
