# Status Report Password Protection — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Proteger a aba "Status Report" com uma senha simples, bloqueando o acesso não autorizado sem impedir o auto-refresh dos dados.

**Architecture:** Interceptação em `switchTab('eap')` verifica `sessionStorage` antes de mostrar a aba. Se não autenticado, exibe modal de senha. Senha correta salva flag na sessão e prossegue. Modal segue o padrão visual dos modais existentes no dashboard (overlay fixo inline, z-index 10000).

**Tech Stack:** HTML + JS vanilla, sessionStorage — sem dependências externas.

---

### Task 1: Adicionar HTML do modal de senha

**Files:**
- Modify: `index.html` — inserir após linha 537 (junto ao `date-err-modal`)

- [ ] **Step 1: Localizar âncora de inserção**

```powershell
$content = [System.IO.File]::ReadAllText("C:\Users\gagui\Github\maz-dashboard\index.html")
$anchor = '<div id="date-err-modal"'
$idx = $content.IndexOf($anchor)
Write-Host "Encontrado em índice: $idx"
```

Expected: número positivo (não -1)

- [ ] **Step 2: Inserir HTML do modal antes do date-err-modal**

Usar PowerShell str.replace para inserir o bloco abaixo ANTES da âncora `<div id="date-err-modal"`:

```html
<div id="eap-pw-modal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;z-index:10000;background:rgba(0,0,0,.65);align-items:center;justify-content:center">
  <div style="background:#1a2e1a;border:1px solid #4a7c59;border-radius:12px;padding:32px 36px;min-width:320px;max-width:400px;box-shadow:0 8px 32px rgba(0,0,0,.5)">
    <div style="font-size:1.3rem;font-weight:700;color:#a8d5a2;margin-bottom:8px">🔒 Status Report</div>
    <div style="color:#8ab89a;font-size:.9rem;margin-bottom:20px">Esta aba é restrita ao PMO e gerentes.</div>
    <input id="eap-pw-input" type="password" placeholder="Digite a senha" autocomplete="off"
      style="width:100%;box-sizing:border-box;padding:10px 14px;border-radius:8px;border:1px solid #4a7c59;background:#0d1f0d;color:#e0f0e0;font-size:1rem;margin-bottom:8px;outline:none"
      onkeydown="if(event.key==='Enter')_submitEapPassword()">
    <div id="eap-pw-error" style="color:#e07070;font-size:.85rem;min-height:20px;margin-bottom:12px"></div>
    <div style="display:flex;gap:10px;justify-content:flex-end">
      <button onclick="_closeEapModal()" style="padding:8px 18px;border-radius:6px;border:1px solid #4a7c59;background:transparent;color:#8ab89a;cursor:pointer;font-size:.9rem">Cancelar</button>
      <button onclick="_submitEapPassword()" style="padding:8px 22px;border-radius:6px;border:none;background:#4a7c59;color:#fff;cursor:pointer;font-size:.9rem;font-weight:600">Entrar</button>
    </div>
  </div>
</div>
```

Script PowerShell completo:

```powershell
$path = "C:\Users\gagui\Github\maz-dashboard\index.html"
$content = [System.IO.File]::ReadAllText($path)
$content = $content.Replace("`r`n", "`n")

$modal = @'
<div id="eap-pw-modal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;z-index:10000;background:rgba(0,0,0,.65);align-items:center;justify-content:center">
  <div style="background:#1a2e1a;border:1px solid #4a7c59;border-radius:12px;padding:32px 36px;min-width:320px;max-width:400px;box-shadow:0 8px 32px rgba(0,0,0,.5)">
    <div style="font-size:1.3rem;font-weight:700;color:#a8d5a2;margin-bottom:8px">🔒 Status Report</div>
    <div style="color:#8ab89a;font-size:.9rem;margin-bottom:20px">Esta aba é restrita ao PMO e gerentes.</div>
    <input id="eap-pw-input" type="password" placeholder="Digite a senha" autocomplete="off"
      style="width:100%;box-sizing:border-box;padding:10px 14px;border-radius:8px;border:1px solid #4a7c59;background:#0d1f0d;color:#e0f0e0;font-size:1rem;margin-bottom:8px;outline:none"
      onkeydown="if(event.key==='Enter')_submitEapPassword()">
    <div id="eap-pw-error" style="color:#e07070;font-size:.85rem;min-height:20px;margin-bottom:12px"></div>
    <div style="display:flex;gap:10px;justify-content:flex-end">
      <button onclick="_closeEapModal()" style="padding:8px 18px;border-radius:6px;border:1px solid #4a7c59;background:transparent;color:#8ab89a;cursor:pointer;font-size:.9rem">Cancelar</button>
      <button onclick="_submitEapPassword()" style="padding:8px 22px;border-radius:6px;border:none;background:#4a7c59;color:#fff;cursor:pointer;font-size:.9rem;font-weight:600">Entrar</button>
    </div>
  </div>
</div>

'@

$anchor = '<div id="date-err-modal"'
$new = $content.Replace($anchor, $modal + $anchor)

if ($new -eq $content) { Write-Host "ERRO: âncora não encontrada"; exit 1 }
[System.IO.File]::WriteAllText($path, $new)
Write-Host "Modal inserido com sucesso"
```

- [ ] **Step 3: Verificar inserção**

```powershell
Select-String -Path "C:\Users\gagui\Github\maz-dashboard\index.html" -Pattern "eap-pw-modal" | Select-Object -First 3
```

Expected: 2 ocorrências (o div + o input)

---

### Task 2: Adicionar constante de senha e funções JS

**Files:**
- Modify: `index.html` — inserir constante e funções no bloco `<script>`

- [ ] **Step 1: Inserir constante EAP_PASSWORD após `hideDateError`**

Localizar âncora `function hideDateError`:

```powershell
Select-String -Path "C:\Users\gagui\Github\maz-dashboard\index.html" -Pattern "function hideDateError"
```

Expected: linha ~1795

- [ ] **Step 2: Inserir constante + funções após `hideDateError`**

Script PowerShell:

```powershell
$path = "C:\Users\gagui\Github\maz-dashboard\index.html"
$content = [System.IO.File]::ReadAllText($path)
$content = $content.Replace("`r`n", "`n")

$anchor = 'function hideDateError(){const m=document.getElementById(''date-err-modal'');if(m)m.style.display=''none'';}'

$newCode = @'

// ── Status Report password ──────────────────────────────────────────────────
const EAP_PASSWORD = 'maz2026'; // alterar aqui para mudar a senha
function _showEapModal(){
  var m=document.getElementById('eap-pw-modal');
  if(m){m.style.display='flex';}
  var inp=document.getElementById('eap-pw-input');
  if(inp){inp.value='';setTimeout(function(){inp.focus();},80);}
  var err=document.getElementById('eap-pw-error');
  if(err)err.textContent='';
}
function _closeEapModal(){
  var m=document.getElementById('eap-pw-modal');
  if(m)m.style.display='none';
}
function _submitEapPassword(){
  var inp=document.getElementById('eap-pw-input');
  var err=document.getElementById('eap-pw-error');
  if(!inp)return;
  if(inp.value===EAP_PASSWORD){
    sessionStorage.setItem('eap_unlocked','1');
    _closeEapModal();
    switchTab('eap');
  } else {
    if(err)err.textContent='Senha incorreta. Tente novamente.';
    inp.value='';
    inp.focus();
  }
}
// ────────────────────────────────────────────────────────────────────────────
'@

$new = $content.Replace($anchor, $anchor + $newCode)

if ($new -eq $content) { Write-Host "ERRO: âncora não encontrada"; exit 1 }
[System.IO.File]::WriteAllText($path, $new)
Write-Host "Funções inseridas com sucesso"
```

- [ ] **Step 3: Verificar inserção**

```powershell
Select-String -Path "C:\Users\gagui\Github\maz-dashboard\index.html" -Pattern "EAP_PASSWORD|_showEapModal|_submitEapPassword" | Select-Object -First 5
```

Expected: 4+ ocorrências

---

### Task 3: Interceptar switchTab para a aba 'eap'

**Files:**
- Modify: `index.html` — início da função `switchTab` (~linha 840)

- [ ] **Step 1: Localizar âncora exata dentro de switchTab**

```powershell
Select-String -Path "C:\Users\gagui\Github\maz-dashboard\index.html" -Pattern "function switchTab" -Context 0,3
```

Confirmar a linha seguinte que começa com `document.querySelectorAll('.tab-panel')`.

- [ ] **Step 2: Inserir verificação de senha no início de switchTab**

A âncora é a linha dentro de switchTab:
`document.querySelectorAll('.tab-panel').forEach(p=>p.classList.remove('active'));`

Script PowerShell:

```powershell
$path = "C:\Users\gagui\Github\maz-dashboard\index.html"
$content = [System.IO.File]::ReadAllText($path)
$content = $content.Replace("`r`n", "`n")

$anchor = "function switchTab(name){`n  document.querySelectorAll('.tab-panel').forEach(p=>p.classList.remove('active'));"

$replacement = "function switchTab(name){`n  if(name==='eap'&&sessionStorage.getItem('eap_unlocked')!=='1'){_showEapModal();return;}`n  document.querySelectorAll('.tab-panel').forEach(p=>p.classList.remove('active'));"

$new = $content.Replace($anchor, $replacement)

if ($new -eq $content) { Write-Host "ERRO: âncora não encontrada"; exit 1 }
[System.IO.File]::WriteAllText($path, $new)
Write-Host "Interceptação inserida com sucesso"
```

- [ ] **Step 3: Verificar**

```powershell
Select-String -Path "C:\Users\gagui\Github\maz-dashboard\index.html" -Pattern "eap_unlocked" | Select-Object -First 3
```

Expected: 2 ocorrências (interceptação + _submitEapPassword)

---

### Task 4: Validação manual no browser

- [ ] **Step 1: Abrir o dashboard localmente**

Duplo-clique em `SERVE_DASHBOARD.bat` ou abrir `index.html` no browser.

- [ ] **Step 2: Testar acesso bloqueado**

Clicar na aba "Status Report" sem estar autenticado.
Expected: modal de senha aparece com campo de input e botões "Cancelar" / "Entrar".

- [ ] **Step 3: Testar senha errada**

Digitar qualquer texto errado e clicar "Entrar".
Expected: mensagem "Senha incorreta. Tente novamente." aparece, campo limpa, foco retorna ao input.

- [ ] **Step 4: Testar tecla Enter**

Com o modal aberto, digitar a senha errada e pressionar Enter.
Expected: mesmo comportamento do clique em "Entrar".

- [ ] **Step 5: Testar cancelar**

Clicar "Cancelar".
Expected: modal fecha, permanece na aba anterior.

- [ ] **Step 6: Testar senha correta**

Digitar `maz2026` e clicar "Entrar".
Expected: modal fecha, aba Status Report abre normalmente.

- [ ] **Step 7: Testar que sessionStorage mantém acesso**

Com a aba já aberta, navegar para outra aba e voltar para "Status Report".
Expected: acesso direto, sem modal.

- [ ] **Step 8: Testar que outras abas não foram afetadas**

Navegar por Gantt, Requisições, Áreas.
Expected: funcionamento normal sem modal.

- [ ] **Step 9: Testar que o auto-refresh continua funcionando**

Aguardar o intervalo de refresh (ou forçar via console: `loadSheetsData()`).
Expected: dados atualizam normalmente com a aba Status Report desbloqueada.

---

### Task 5: Commit

- [ ] **Step 1: Verificar estado do git**

```powershell
git status
git diff --stat
```

Expected: apenas `index.html` modificado

- [ ] **Step 2: Commit**

```powershell
git add index.html
git commit -m "feat: adiciona proteção por senha na aba Status Report"
```
