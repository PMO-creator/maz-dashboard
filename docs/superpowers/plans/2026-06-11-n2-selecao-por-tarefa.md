# N2 — Seleção por Tarefa (em vez de Marco)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mover a seleção da Pauta N2 do nível de marco para o nível de tarefa individual, exibindo as tarefas selecionadas agrupadas pelo marco pai.

**Architecture:** Todas as mudanças são no JS inline de `index.html`. O ID de storage muda de `gi:mi:ti` (3 partes = marco) para `gi:mi:ti:si` (4 partes = subtarefa). O checkbox sai do `marco-band` e vai para cada `task-card` de subtarefa. O marco-band mantém o badge N2 como indicador visual passivo.

**Tech Stack:** Vanilla JS, HTML/CSS. Substituições via Python str.replace() no Bash (nunca Edit tool — arquivo grande com backticks).

**Regra de execução:** Cada substituição Python deve fazer `print('OK')` e verificar `'OK' in output` antes de prosseguir. Se não encontrar a string, parar e reportar.

---

## Arquivos

| Arquivo | Ação |
|---|---|
| `index.html` | Modificar — todas as 8 tasks abaixo |

---

### Task 1: Remover checkbox do marco-band + adicionar às subtarefas em `taskCard`

**Files:**
- Modify: `index.html` (linhas ~1502–1531 e ~1574–1588)

**Contexto:** O `taskCard(t)` renderiza cada subtarefa dentro de um marco. Atualmente não tem checkbox. O marco-band (cabeçalho) tem o checkbox. Vamos inverter isso.

- [ ] **Step 1.1 — Atualizar assinatura e corpo de `taskCard`**

Localizar exatamente (incluindo espaços iniciais):
```
  function taskCard(t){
```
Substituir por:
```
  function taskCard(t, n2Id){
```

Executar via Python no Bash:
```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='  function taskCard(t){'
new='  function taskCard(t, n2Id){'
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

- [ ] **Step 1.2 — Adicionar id e checkbox ao task-card**

Localizar (linha ~1518–1519, EXATAMENTE estas duas linhas):
```
    let h = `<div class="task-card" style="border-color:${mc}">`;
    h += `<div class="tc-header"><span class="tc-status" style="background:${mc}">${sl_}</span><span class="tarefa-name" style="${isCancelado?'text-decoration:line-through;opacity:0.6':''}">${escH(t.tarefa||'Tarefa')}</span></div>`;
```
Substituir por:
```
    let h = `<div class="task-card"${n2Id?' id="taskcard-'+n2Id+'"':''} style="border-color:${mc}">`;
    h += `<div class="tc-header"><span class="tc-status" style="background:${mc}">${sl_}</span><span class="tarefa-name" style="${isCancelado?'text-decoration:line-through;opacity:0.6':''}">${escH(t.tarefa||'Tarefa')}</span>`;
    if(n2Id) h += `<input type="checkbox" class="n2-check" id="n2c-${n2Id}" onclick="toggleN2Task('${n2Id}',event)">`;
    h += `</div>`;
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='    let h = \`<div class=\"task-card\" style=\"border-color:\${mc}\">\`;\n    h += \`<div class=\"tc-header\"><span class=\"tc-status\" style=\"background:\${mc}\">\${sl_}</span><span class=\"tarefa-name\" style=\"\${isCancelado?\'text-decoration:line-through;opacity:0.6\':\'\'}\">\ ${escH(t.tarefa||\'Tarefa\')}</span></div>\`;'
new='    let h = \`<div class=\"task-card\"\${n2Id?\' id=\"taskcard-\'+n2Id+\'\"\":\'\'} style=\"border-color:\${mc}\">\`;\n    h += \`<div class=\"tc-header\"><span class=\"tc-status\" style=\"background:\${mc}\">\${sl_}</span><span class=\"tarefa-name\" style=\"\${isCancelado?\'text-decoration:line-through;opacity:0.6\':\'\'}\">\ ${escH(t.tarefa||\'Tarefa\')}</span>\`;\n    if(n2Id) h += \`<input type=\"checkbox\" class=\"n2-check\" id=\"n2c-\${n2Id}\" onclick=\"toggleN2Task(\'\${n2Id}\',event)\">\`;\n    h += \`</div>\`;'
assert old in c, 'STRING NAO ENCONTRADA — usar PowerShell abaixo'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

> **Nota:** Se o Python falhar por causa de escaping de backticks/aspas, usar o script PowerShell na seção "Armadilha técnica" no final deste plano.

- [ ] **Step 1.3 — Passar índice da subtarefa no forEach**

Localizar (linha ~1586):
```
        subs.forEach(s=>{ html += taskCard(s); });
```
Substituir por:
```
        subs.forEach((s,si)=>{ html += taskCard(s, gi+'-'+mi+'-'+ti+'-'+si); });
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='        subs.forEach(s=>{ html += taskCard(s); });'
new='        subs.forEach((s,si)=>{ html += taskCard(s, gi+\'-\'+mi+\'-\'+ti+\'-\'+si); });'
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

- [ ] **Step 1.4 — Remover checkbox do marco-band**

Localizar (linha ~1576, linha inteira):
```
      html += `<input type="checkbox" class="n2-check" id="n2c-${gi}-${mi}-${ti}" onclick="toggleN2Marco(${gi},${mi},${ti},event)">`;
```
Substituir por string vazia (deletar a linha).

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='      html += \`<input type=\"checkbox\" class=\"n2-check\" id=\"n2c-\${gi}-\${mi}-\${ti}\" onclick=\"toggleN2Marco(\${gi},\${mi},\${ti},event)\">\`;\n'
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,'',1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

---

### Task 2: Substituir `toggleN2Marco` + `n2Id` por `toggleN2Task`

**Files:**
- Modify: `index.html` (linhas ~1143–1157)

- [ ] **Step 2.1 — Remover função `n2Id` e substituir `toggleN2Marco` por `toggleN2Task`**

Localizar (linhas 1143–1157, EXATAMENTE):
```
  function n2Id(gi,mi,ti){return gi+':'+mi+':'+ti;}
  function toggleN2Marco(gi,mi,ti,ev){
    if(ev)ev.stopPropagation();
    if(_n2ViewMode&&!_n2Unlocked)return;
    var arr=loadN2(),id=n2Id(gi,mi,ti),idx=arr.indexOf(id);
    if(idx===-1){arr.push(id);}else{arr.splice(idx,1);}
    saveN2(arr);
    var cb=document.getElementById('n2c-'+gi+'-'+mi+'-'+ti);
    if(cb)cb.checked=(idx===-1);
    var band=document.getElementById('mband-'+gi+'-'+mi+'-'+ti);
    if(band){if(idx===-1)band.classList.add('n2-selected');else band.classList.remove('n2-selected');}
    var badge=document.getElementById('n2badge-'+gi+'-'+mi+'-'+ti);
    if(badge)badge.style.display=(idx===-1)?'inline-flex':'none';
    updateN2Fab();
  }
```

Substituir por:
```
  function toggleN2Task(domId,ev){
    if(ev)ev.stopPropagation();
    if(_n2ViewMode&&!_n2Unlocked)return;
    var storeId=domId.replace(/-/g,':');
    var arr=loadN2(),idx=arr.indexOf(storeId);
    if(idx===-1){arr.push(storeId);}else{arr.splice(idx,1);}
    saveN2(arr);
    var cb=document.getElementById('n2c-'+domId);
    if(cb)cb.checked=(idx===-1);
    var parts=domId.split('-'),marcoKey=parts[0]+'-'+parts[1]+'-'+parts[2];
    var prefix=parts[0]+':'+parts[1]+':'+parts[2]+':';
    var hasAny=arr.some(function(x){return x.startsWith(prefix);});
    var band=document.getElementById('mband-'+marcoKey);
    if(band){if(hasAny)band.classList.add('n2-selected');else band.classList.remove('n2-selected');}
    var badge=document.getElementById('n2badge-'+marcoKey);
    if(badge)badge.style.display=hasAny?'inline-flex':'none';
    updateN2Fab();
  }
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='''  function n2Id(gi,mi,ti){return gi+\':\'+mi+\':\'+ti;}
  function toggleN2Marco(gi,mi,ti,ev){
    if(ev)ev.stopPropagation();
    if(_n2ViewMode&&!_n2Unlocked)return;
    var arr=loadN2(),id=n2Id(gi,mi,ti),idx=arr.indexOf(id);
    if(idx===-1){arr.push(id);}else{arr.splice(idx,1);}
    saveN2(arr);
    var cb=document.getElementById(\'n2c-\'+gi+\'-\'+mi+\'-\'+ti);
    if(cb)cb.checked=(idx===-1);
    var band=document.getElementById(\'mband-\'+gi+\'-\'+mi+\'-\'+ti);
    if(band){if(idx===-1)band.classList.add(\'n2-selected\');else band.classList.remove(\'n2-selected\');}
    var badge=document.getElementById(\'n2badge-\'+gi+\'-\'+mi+\'-\'+ti);
    if(badge)badge.style.display=(idx===-1)?\'inline-flex\':\'none\';
    updateN2Fab();
  }'''
new='''  function toggleN2Task(domId,ev){
    if(ev)ev.stopPropagation();
    if(_n2ViewMode&&!_n2Unlocked)return;
    var storeId=domId.replace(/-/g,\':\');
    var arr=loadN2(),idx=arr.indexOf(storeId);
    if(idx===-1){arr.push(storeId);}else{arr.splice(idx,1);}
    saveN2(arr);
    var cb=document.getElementById(\'n2c-\'+domId);
    if(cb)cb.checked=(idx===-1);
    var parts=domId.split(\'-\'),marcoKey=parts[0]+\'-\'+parts[1]+\'-\'+parts[2];
    var prefix=parts[0]+\':\'+parts[1]+\':\'+parts[2]+\':\';
    var hasAny=arr.some(function(x){return x.startsWith(prefix);});
    var band=document.getElementById(\'mband-\'+marcoKey);
    if(band){if(hasAny)band.classList.add(\'n2-selected\');else band.classList.remove(\'n2-selected\');}
    var badge=document.getElementById(\'n2badge-\'+marcoKey);
    if(badge)badge.style.display=hasAny?\'inline-flex\':\'none\';
    updateN2Fab();
  }'''
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

---

### Task 3: Atualizar `initN2Checkboxes` para IDs de 4 partes

**Files:**
- Modify: `index.html` (linhas ~1484–1496)

- [ ] **Step 3.1 — Substituir lógica de parse de ID**

Localizar:
```
  function initN2Checkboxes(){
    var arr=loadN2();
    arr.forEach(function(id){
      var p=id.split(':');if(p.length!==3)return;
      var gi=parseInt(p[0]),mi=parseInt(p[1]),ti=parseInt(p[2]);
      var cb=document.getElementById('n2c-'+gi+'-'+mi+'-'+ti);
      if(cb){cb.checked=true;var band=document.getElementById('mband-'+gi+'-'+mi+'-'+ti);if(band)band.classList.add('n2-selected');var badge=document.getElementById('n2badge-'+gi+'-'+mi+'-'+ti);if(badge)badge.style.display='inline-flex';}
    });
    document.querySelectorAll('.n2-check').forEach(function(cb){
      cb.disabled=_n2ViewMode&&!_n2Unlocked;
    });
    updateN2Fab();
  }
```

Substituir por:
```
  function initN2Checkboxes(){
    var arr=loadN2();
    arr.forEach(function(id){
      var p=id.split(':');if(p.length!==4)return;
      var domId=p.join('-');
      var cb=document.getElementById('n2c-'+domId);
      if(cb)cb.checked=true;
      var marcoKey=p[0]+'-'+p[1]+'-'+p[2];
      var band=document.getElementById('mband-'+marcoKey);
      if(band)band.classList.add('n2-selected');
      var badge=document.getElementById('n2badge-'+marcoKey);
      if(badge)badge.style.display='inline-flex';
    });
    document.querySelectorAll('.n2-check').forEach(function(cb){
      cb.disabled=_n2ViewMode&&!_n2Unlocked;
    });
    updateN2Fab();
  }
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='''  function initN2Checkboxes(){
    var arr=loadN2();
    arr.forEach(function(id){
      var p=id.split(\':\');if(p.length!==3)return;
      var gi=parseInt(p[0]),mi=parseInt(p[1]),ti=parseInt(p[2]);
      var cb=document.getElementById(\'n2c-\'+gi+\'-\'+mi+\'-\'+ti);
      if(cb){cb.checked=true;var band=document.getElementById(\'mband-\'+gi+\'-\'+mi+\'-\'+ti);if(band)band.classList.add(\'n2-selected\');var badge=document.getElementById(\'n2badge-\'+gi+\'-\'+mi+\'-\'+ti);if(badge)badge.style.display=\'inline-flex\';}
    });
    document.querySelectorAll(\'.n2-check\').forEach(function(cb){
      cb.disabled=_n2ViewMode&&!_n2Unlocked;
    });
    updateN2Fab();
  }'''
new='''  function initN2Checkboxes(){
    var arr=loadN2();
    arr.forEach(function(id){
      var p=id.split(\':\');if(p.length!==4)return;
      var domId=p.join(\'-\');
      var cb=document.getElementById(\'n2c-\'+domId);
      if(cb)cb.checked=true;
      var marcoKey=p[0]+\'-\'+p[1]+\'-\'+p[2];
      var band=document.getElementById(\'mband-\'+marcoKey);
      if(band)band.classList.add(\'n2-selected\');
      var badge=document.getElementById(\'n2badge-\'+marcoKey);
      if(badge)badge.style.display=\'inline-flex\';
    });
    document.querySelectorAll(\'.n2-check\').forEach(function(cb){
      cb.disabled=_n2ViewMode&&!_n2Unlocked;
    });
    updateN2Fab();
  }'''
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

---

### Task 4: Atualizar `clearN2Selection`

**Files:**
- Modify: `index.html` (linhas ~1173–1179)

- [ ] **Step 4.1 — Adicionar limpeza de task-cards e badges ao clearN2Selection**

Localizar:
```
  function clearN2Selection(){
    saveN2([]);n2FilterActive=false;
    document.querySelectorAll('[id^="mband-"]').forEach(function(b){b.style.display='';b.classList.remove('n2-selected');});
    document.querySelectorAll('[id^="subtask-"]').forEach(function(b){b.style.display='';});
    document.querySelectorAll('.n2-check').forEach(function(cb){cb.checked=false;});
    updateN2Fab();
  }
```

Substituir por:
```
  function clearN2Selection(){
    saveN2([]);n2FilterActive=false;
    document.querySelectorAll('[id^="mband-"]').forEach(function(b){b.style.display='';b.classList.remove('n2-selected');});
    document.querySelectorAll('[id^="subtask-"]').forEach(function(b){b.style.display='';});
    document.querySelectorAll('[id^="taskcard-"]').forEach(function(b){b.style.display='';});
    document.querySelectorAll('[id^="n2badge-"]').forEach(function(b){b.style.display='none';});
    document.querySelectorAll('.n2-check').forEach(function(cb){cb.checked=false;});
    updateN2Fab();
  }
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='''  function clearN2Selection(){
    saveN2([]);n2FilterActive=false;
    document.querySelectorAll(\'[id^=\"mband-\"]\').forEach(function(b){b.style.display=\'\';b.classList.remove(\'n2-selected\');});
    document.querySelectorAll(\'[id^=\"subtask-\"]\').forEach(function(b){b.style.display=\'\';});
    document.querySelectorAll(\'.n2-check\').forEach(function(cb){cb.checked=false;});
    updateN2Fab();
  }'''
new='''  function clearN2Selection(){
    saveN2([]);n2FilterActive=false;
    document.querySelectorAll(\'[id^=\"mband-\"]\').forEach(function(b){b.style.display=\'\';b.classList.remove(\'n2-selected\');});
    document.querySelectorAll(\'[id^=\"subtask-\"]\').forEach(function(b){b.style.display=\'\';});
    document.querySelectorAll(\'[id^=\"taskcard-\"]\').forEach(function(b){b.style.display=\'\';});
    document.querySelectorAll(\'[id^=\"n2badge-\"]\').forEach(function(b){b.style.display=\'none\';});
    document.querySelectorAll(\'.n2-check\').forEach(function(cb){cb.checked=false;});
    updateN2Fab();
  }'''
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

---

### Task 5: Atualizar `applyN2Filter` e `toggleN2Filter` para nível de tarefa

**Files:**
- Modify: `index.html` (linhas ~1180–1197)

- [ ] **Step 5.1 — Substituir `applyN2Filter`**

Localizar:
```
  function applyN2Filter(){
    if(!n2FilterActive)return;
    var arr=loadN2();
    document.querySelectorAll('[id^="mband-"]').forEach(function(band){
      var id=band.id.replace('mband-','').replace(/-/g,':'),vis=arr.indexOf(id)!==-1;
      band.style.display=vis?'':'none';
      var sub=document.getElementById('subtask-'+band.id.replace('mband-',''));
      if(sub)sub.style.display=vis?'':'none';
    });
  }
```

Substituir por:
```
  function applyN2Filter(){
    if(!n2FilterActive)return;
    var arr=loadN2();
    var selSet=new Set(arr);
    document.querySelectorAll('[id^="taskcard-"]').forEach(function(card){
      var domId=card.id.replace('taskcard-','');
      var storeId=domId.replace(/-/g,':');
      card.style.display=selSet.has(storeId)?'':'none';
    });
    document.querySelectorAll('[id^="mband-"]').forEach(function(band){
      var marcoKey=band.id.replace('mband-','');
      var prefix=marcoKey.replace(/-/g,':')+':';
      var hasAny=arr.some(function(x){return x.startsWith(prefix);});
      band.style.display=hasAny?'':'none';
      var sub=document.getElementById('subtask-'+marcoKey);
      if(sub){sub.style.display=hasAny?'':'none';if(hasAny)sub.style.maxHeight='none';}
    });
  }
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='''  function applyN2Filter(){
    if(!n2FilterActive)return;
    var arr=loadN2();
    document.querySelectorAll(\'[id^=\"mband-\"]\').forEach(function(band){
      var id=band.id.replace(\'mband-\',\'\').replace(/-/g,\':\'),vis=arr.indexOf(id)!==-1;
      band.style.display=vis?\'\':\'none\';
      var sub=document.getElementById(\'subtask-\'+band.id.replace(\'mband-\',\'\'));
      if(sub)sub.style.display=vis?\'\':\'none\';
    });
  }'''
new='''  function applyN2Filter(){
    if(!n2FilterActive)return;
    var arr=loadN2();
    var selSet=new Set(arr);
    document.querySelectorAll(\'[id^=\"taskcard-\"]\').forEach(function(card){
      var domId=card.id.replace(\'taskcard-\',\'\');
      var storeId=domId.replace(/-/g,\':\');
      card.style.display=selSet.has(storeId)?\'\':\'none\';
    });
    document.querySelectorAll(\'[id^=\"mband-\"]\').forEach(function(band){
      var marcoKey=band.id.replace(\'mband-\',\'\');
      var prefix=marcoKey.replace(/-/g,\':\')+\':\';
      var hasAny=arr.some(function(x){return x.startsWith(prefix);});
      band.style.display=hasAny?\'\':\'none\';
      var sub=document.getElementById(\'subtask-\'+marcoKey);
      if(sub){sub.style.display=hasAny?\'\':\'none\';if(hasAny)sub.style.maxHeight=\'none\';}
    });
  }'''
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

- [ ] **Step 5.2 — Atualizar `toggleN2Filter` para também restaurar task-cards**

Localizar:
```
  function toggleN2Filter(){
    n2FilterActive=!n2FilterActive;
    if(!n2FilterActive){
      document.querySelectorAll('[id^="mband-"]').forEach(function(b){b.style.display='';});
      document.querySelectorAll('[id^="subtask-"]').forEach(function(b){b.style.display='';});
    }else{applyN2Filter();}
    updateN2Fab();
  }
```

Substituir por:
```
  function toggleN2Filter(){
    n2FilterActive=!n2FilterActive;
    if(!n2FilterActive){
      document.querySelectorAll('[id^="mband-"]').forEach(function(b){b.style.display='';});
      document.querySelectorAll('[id^="subtask-"]').forEach(function(b){b.style.display='';});
      document.querySelectorAll('[id^="taskcard-"]').forEach(function(b){b.style.display='';});
    }else{applyN2Filter();}
    updateN2Fab();
  }
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='''  function toggleN2Filter(){
    n2FilterActive=!n2FilterActive;
    if(!n2FilterActive){
      document.querySelectorAll(\'[id^=\"mband-\"]\').forEach(function(b){b.style.display=\'\';});
      document.querySelectorAll(\'[id^=\"subtask-\"]\').forEach(function(b){b.style.display=\'\';});
    }else{applyN2Filter();}
    updateN2Fab();
  }'''
new='''  function toggleN2Filter(){
    n2FilterActive=!n2FilterActive;
    if(!n2FilterActive){
      document.querySelectorAll(\'[id^=\"mband-\"]\').forEach(function(b){b.style.display=\'\';});
      document.querySelectorAll(\'[id^=\"subtask-\"]\').forEach(function(b){b.style.display=\'\';});
      document.querySelectorAll(\'[id^=\"taskcard-\"]\').forEach(function(b){b.style.display=\'\';});
    }else{applyN2Filter();}
    updateN2Fab();
  }'''
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

---

### Task 6: Atualizar bloco `n2FilterActive` no `toggleGroup`

**Files:**
- Modify: `index.html` (linha ~1710)

**Contexto:** Quando um grupo (eixo) fecha e reabre, o `toggleGroup` reaplica o filtro N2. A linha atual usa a lógica antiga de IDs de 3 partes. Simplificar chamando `applyN2Filter()`.

- [ ] **Step 6.1 — Substituir lógica inline no toggleGroup**

Localizar (linha ~1710, EXATAMENTE):
```
    if(n2FilterActive){var _n2a=loadN2();ml.querySelectorAll('[id^="mband-"]').forEach(function(b){var id=b.id.replace('mband-','').replace(/-/g,':');if(_n2a.indexOf(id)===-1)b.style.display='none';});}
```

Substituir por:
```
    if(n2FilterActive){applyN2Filter();}
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='    if(n2FilterActive){var _n2a=loadN2();ml.querySelectorAll(\'[id^=\"mband-\"]\').forEach(function(b){var id=b.id.replace(\'mband-\',\'\').replace(/-/g,\':\');if(_n2a.indexOf(id)===-1)b.style.display=\'none\';});}'
new='    if(n2FilterActive){applyN2Filter();}'
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

---

### Task 7: Atualizar textos de alerta em `publishN2Pauta` e `exportN2PPT`

**Files:**
- Modify: `index.html` (linhas ~1252, ~1261, ~1297)

- [ ] **Step 7.1 — Atualizar alerta do publishN2Pauta**

Localizar:
```
    if(!arr.length){alert('Nenhum marco selecionado para publicar.');return;}
```
Substituir por:
```
    if(!arr.length){alert('Nenhuma tarefa selecionada para publicar.');return;}
```

- [ ] **Step 7.2 — Atualizar alertas do exportN2PPT**

Localizar:
```
    if(!arr.length){alert('Nenhum marco selecionado para exportar.');return;}
```
Substituir por:
```
    if(!arr.length){alert('Nenhuma tarefa selecionada para exportar.');return;}
```

Localizar:
```
    if(!byEixo.length){alert('Nenhum marco encontrado com os filtros atuais.');return;}
```
Substituir por:
```
    if(!byEixo.length){alert('Nenhuma tarefa selecionada encontrada com os filtros atuais.');return;}
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
c=c.replace(\"alert('Nenhum marco selecionado para publicar.')\",\"alert('Nenhuma tarefa selecionada para publicar.')\",1)
c=c.replace(\"alert('Nenhum marco selecionado para exportar.')\",\"alert('Nenhuma tarefa selecionada para exportar.')\",1)
c=c.replace(\"alert('Nenhum marco encontrado com os filtros atuais.')\",\"alert('Nenhuma tarefa selecionada encontrada com os filtros atuais.')\",1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

---

### Task 8: Atualizar `exportN2PPT` para iterar subtarefas selecionadas individualmente

**Files:**
- Modify: `index.html` (linhas ~1279–1296)

**Contexto:** Atualmente, `exportN2PPT` verifica se o marco inteiro está no Set de selecionados. Precisa mudar para verificar cada subtarefa individualmente pelo índice `si`.

- [ ] **Step 8.1 — Substituir lógica de iteração no exportN2PPT**

Localizar (linhas ~1279–1296):
```
        var marcoItems=[];
        visTasks.forEach(function(task,ti){
          if(task.tipo==='marco'){
            var id=gi+':'+mi+':'+ti;
            if(selected.has(id)){
              var allSubs=task.subtasks||[];
              var filteredSubs=(sfLow.length===0||filterLevel==='marco')?allSubs:allSubs.filter(function(s){return sfOk(s.status);});
              var rfActive=currentFilters.resp&&currentFilters.resp.length>0;
              if(rfActive&&!(task.resp&&currentFilters.resp.indexOf(task.resp)>=0))
                filteredSubs=filteredSubs.filter(function(s){return s.resp&&currentFilters.resp.indexOf(s.resp)>=0;});
              marcoItems.push({task:task,subtasks:filteredSubs});
            }
          }
        });
```

Substituir por:
```
        var marcoItems=[];
        visTasks.forEach(function(task,ti){
          if(task.tipo==='marco'){
            var allSubs=task.subtasks||[];
            var selectedSubs=[];
            allSubs.forEach(function(s,si){
              var id=gi+':'+mi+':'+ti+':'+si;
              if(selected.has(id))selectedSubs.push(s);
            });
            if(selectedSubs.length>0){marcoItems.push({task:task,subtasks:selectedSubs});}
          }
        });
```

```bash
python3 -c "
f=open('index.html','r',encoding='utf-8')
c=f.read()
f.close()
old='''        var marcoItems=[];
        visTasks.forEach(function(task,ti){
          if(task.tipo===\'marco\'){
            var id=gi+\':\'+mi+\':\'+ti;
            if(selected.has(id)){
              var allSubs=task.subtasks||[];
              var filteredSubs=(sfLow.length===0||filterLevel===\'marco\')?allSubs:allSubs.filter(function(s){return sfOk(s.status);});
              var rfActive=currentFilters.resp&&currentFilters.resp.length>0;
              if(rfActive&&!(task.resp&&currentFilters.resp.indexOf(task.resp)>=0))
                filteredSubs=filteredSubs.filter(function(s){return s.resp&&currentFilters.resp.indexOf(s.resp)>=0;});
              marcoItems.push({task:task,subtasks:filteredSubs});
            }
          }
        });'''
new='''        var marcoItems=[];
        visTasks.forEach(function(task,ti){
          if(task.tipo===\'marco\'){
            var allSubs=task.subtasks||[];
            var selectedSubs=[];
            allSubs.forEach(function(s,si){
              var id=gi+\':\'+mi+\':\'+ti+\':\'+si;
              if(selected.has(id))selectedSubs.push(s);
            });
            if(selectedSubs.length>0){marcoItems.push({task:task,subtasks:selectedSubs});}
          }
        });'''
assert old in c, 'STRING NAO ENCONTRADA'
c=c.replace(old,new,1)
f=open('index.html','w',encoding='utf-8')
f.write(c)
f.close()
print('OK')
"
```

---

### Task 9: Verificação manual

- [ ] **Step 9.1 — Validar JS**

```bash
grep -c "toggleN2Marco" "index.html"
# Expected: 0 (não deve aparecer mais)

grep -c "toggleN2Task" "index.html"
# Expected: 2 (definição + chamada no onclick)

grep -c "taskcard-" "index.html"
# Expected: >= 3 (id no task-card, clearN2Selection, applyN2Filter, toggleN2Filter)
```

- [ ] **Step 9.2 — Abrir no servidor local**

Abrir `SERVE_DASHBOARD.bat` e navegar para `http://localhost:8000`.

Checklist de verificação:
1. [ ] Nenhum checkbox na barra de cabeçalho do marco (marco-band)
2. [ ] Cada subtarefa dentro de um marco expandido tem checkbox no canto direito
3. [ ] Marcar uma subtarefa → marco-band ganha outline verde + badge N2
4. [ ] Desmarcar todas as subtarefas do marco → outline some + badge some
5. [ ] Botão "📋 Pauta N2" aparece com contagem correta de tarefas
6. [ ] Clicar "📋 Pauta N2" filtra mostrando só marcos com tarefas selecionadas, expandidos, mostrando só as tarefas selecionadas
7. [ ] "✕ Ver todos" volta ao estado completo
8. [ ] "Limpar seleção" desmarca tudo
9. [ ] "Publicar" gera URL com IDs no formato `gi:mi:ti:si`
10. [ ] Abrir URL publicada → modo view travado, checkboxes desabilitados, marcos corretos visíveis

---

## Armadilha técnica — fallback PowerShell

Se qualquer substituição Python falhar por encoding/CRLF, usar:

```powershell
$path = "C:\Users\gagui\Github\maz-dashboard\index.html"
$bytes = [System.IO.File]::ReadAllBytes($path)
$content = [System.Text.Encoding]::UTF8.GetString($bytes).Replace("`r`n", "`n")
$content = $content.Replace('OLD', 'NEW')
$out = [System.Text.Encoding]::UTF8.GetBytes($content)
[System.IO.File]::WriteAllBytes($path, $out)
```
