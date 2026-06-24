# Datas nas barras do Gantt de Áreas — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Exibir datas de início e fim (DD/MM) nas barras de marcos e tarefas do Gantt de Áreas em `index.html`.

**Architecture:** Modificação cirúrgica na função `renderAreaGantt` (~linha 3174 de `index.html`). Marcos recebem dois `<text>` SVG fora da barra; tarefas rastreiam o primeiro e último segmento semanal e inserem datas dentro das barras.

**Tech Stack:** SVG gerado dinamicamente via string concatenation em JS vanilla dentro de `index.html`.

---

## Arquivo modificado

- Modify: `index.html` — função `renderAreaGantt`, bloco de marcos (~linha 3318) e bloco de tarefas (~linha 3360)

---

### Task 1: Datas nos marcos

**Localização:** bloco `if(m.start&&m.end)` dentro do segundo `rows.forEach` de `renderAreaGantt` (~linha 3318).

**Contexto atual:**
```js
if(m.start&&m.end){
  var bx=px(new Date(m.start)),bx2=px(new Date(m.end)),bw=Math.max(8,bx2-bx);
  var bh=28,by=cy3+(rh-bh)/2;
  sR+='<rect x="'+bx.toFixed(1)+'" y="'+by.toFixed(1)+'" width="'+bw.toFixed(1)+'" height="'+bh+'" fill="'+col+'" rx="5" opacity="0.88"/>';
  if(bw>60)sR+='<text x="'+(bx+bw/2).toFixed(1)+'" y="'+(by+bh/2+5.5).toFixed(1)+'" font-size="15" fill="#FFF" font-weight="700" text-anchor="middle">'+escSVG(sl(m.status||'A iniciar'))+'</text>';
}
```

- [ ] **Step 1: Adicionar os dois labels de data após o bloco existente**

Usar PowerShell para substituir. A string antiga (exata):
```
if(bw>60)sR+='<text x="'+(bx+bw/2).toFixed(1)+'" y="'+(by+bh/2+5.5).toFixed(1)+'" font-size="15" fill="#FFF" font-weight="700" text-anchor="middle">'+escSVG(sl(m.status||'A iniciar'))+'</text>';
      }
    } else {
```

A string nova:
```
if(bw>60)sR+='<text x="'+(bx+bw/2).toFixed(1)+'" y="'+(by+bh/2+5.5).toFixed(1)+'" font-size="15" fill="#FFF" font-weight="700" text-anchor="middle">'+escSVG(sl(m.status||'A iniciar'))+'</text>';
      if(bx>50)sR+='<text x="'+(bx-5).toFixed(1)+'" y="'+(by+bh/2+5).toFixed(1)+'" text-anchor="end" font-size="13" font-weight="600" fill="#374151">'+fmtBRshort(m.start)+'</text>';
      sR+='<text x="'+(bx2+5).toFixed(1)+'" y="'+(by+bh/2+5).toFixed(1)+'" font-size="13" font-weight="600" fill="#374151">'+fmtBRshort(m.end)+'</text>';
      }
    } else {
```

Comando PowerShell:
```powershell
$f = 'C:\Users\gagui\Github\maz-dashboard\index.html'
$bytes = [System.IO.File]::ReadAllBytes($f)
$content = [System.Text.Encoding]::UTF8.GetString($bytes).Replace("`r`n", "`n")

$old = "if(bw>60)sR+='<text x=""'+(bx+bw/2).toFixed(1)+'""' y=""'+(by+bh/2+5.5).toFixed(1)+'""' font-size=""15"" fill=""#FFF"" font-weight=""700"" text-anchor=""middle"">'+escSVG(sl(m.status||'A iniciar'))+'</text>';`n      }`n    } else {"
$new = "if(bw>60)sR+='<text x=""'+(bx+bw/2).toFixed(1)+'""' y=""'+(by+bh/2+5.5).toFixed(1)+'""' font-size=""15"" fill=""#FFF"" font-weight=""700"" text-anchor=""middle"">'+escSVG(sl(m.status||'A iniciar'))+'</text>';`n      if(bx>50)sR+='<text x=""'+(bx-5).toFixed(1)+'""' y=""'+(by+bh/2+5).toFixed(1)+'""' text-anchor=""end"" font-size=""13"" font-weight=""600"" fill=""#374151"">'+fmtBRshort(m.start)+'</text>';`n      sR+='<text x=""'+(bx2+5).toFixed(1)+'""' y=""'+(by+bh/2+5).toFixed(1)+'""' font-size=""13"" font-weight=""600"" fill=""#374151"">'+fmtBRshort(m.end)+'</text>';`n      }`n    } else {"

if ($content.Contains($old.Replace('""', '"'))) {
  $result = $content.Replace($old.Replace('""', '"'), $new.Replace('""', '"'))
  [System.IO.File]::WriteAllBytes($f, [System.Text.Encoding]::UTF8.GetBytes($result))
  Write-Host "OK — substituição concluída"
} else {
  Write-Host "ERRO — string não encontrada"
}
```

> **Nota:** As aspas duplas `""` no PowerShell aqui-string representam `"` literal. Ajuste conforme necessário se usar aspas simples.

- [ ] **Step 2: Verificar que a substituição não quebrou o JS**

```powershell
# Extrair bloco <script> para validação
$f = 'C:\Users\gagui\Github\maz-dashboard\index.html'
$content = [System.IO.File]::ReadAllText($f)
$start = $content.IndexOf('<script>')
$end = $content.LastIndexOf('</script>') + 9
$js = $content.Substring($start + 8, $end - $start - 17)
[System.IO.File]::WriteAllText('C:\Users\gagui\Github\maz-dashboard\_tmp_check.js', $js)
node --check C:\Users\gagui\Github\maz-dashboard\_tmp_check.js
```

Esperado: sem output (sem erro de sintaxe).

- [ ] **Step 3: Deletar arquivo temporário**

```powershell
Remove-Item 'C:\Users\gagui\Github\maz-dashboard\_tmp_check.js'
```

---

### Task 2: Datas nas tarefas

**Localização:** bloco `if(t.start&&t.end)` dentro do segundo `rows.forEach` de `renderAreaGantt` (~linha 3360).

**Contexto atual:**
```js
if(t.start&&t.end){
  var _tS=new Date(t.start),_tE=new Date(t.end);
  var _bh=19,_by=cy3+(rh-_bh)/2;
  weeks.forEach(function(_w,_wi){
    var _wE=_wi+1<weeks.length?weeks[_wi+1]:CE;
    var _sS=new Date(Math.max(+_tS,+_w)),_sE=new Date(Math.min(+_tE,+_wE));
    if(+_sS>=+_sE)return;
    var _bx=px(_sS)+1.5,_bx2=px(_sE)-1.5,_bw=Math.max(3,_bx2-_bx);
    sR+='<rect x="'+_bx.toFixed(1)+'" y="'+_by.toFixed(1)+'" width="'+_bw.toFixed(1)+'" height="'+_bh+'" fill="'+col+'" rx="4" opacity="0.92"/>';
    if(_bw>60)sR+='<text x="'+(_bx+_bw/2).toFixed(1)+'" y="'+(_by+_bh/2+4.5).toFixed(1)+'" font-size="13" fill="#FFF" font-weight="600" text-anchor="middle">'+escSVG(sl(t.status||'A iniciar'))+'</text>';
  });
}
```

- [ ] **Step 4: Substituir o bloco de tarefas para rastrear primeiro/último segmento**

String antiga (exata, após normalizar CRLF):
```
if(t.start&&t.end){
        var _tS=new Date(t.start),_tE=new Date(t.end);
        var _bh=19,_by=cy3+(rh-_bh)/2;
        weeks.forEach(function(_w,_wi){
          var _wE=_wi+1<weeks.length?weeks[_wi+1]:CE;
          var _sS=new Date(Math.max(+_tS,+_w)),_sE=new Date(Math.min(+_tE,+_wE));
          if(+_sS>=+_sE)return;
          var _bx=px(_sS)+1.5,_bx2=px(_sE)-1.5,_bw=Math.max(3,_bx2-_bx);
          sR+='<rect x="'+_bx.toFixed(1)+'" y="'+_by.toFixed(1)+'" width="'+_bw.toFixed(1)+'" height="'+_bh+'" fill="'+col+'" rx="4" opacity="0.92"/>';
          if(_bw>60)sR+='<text x="'+(_bx+_bw/2).toFixed(1)+'" y="'+(_by+_bh/2+4.5).toFixed(1)+'" font-size="13" fill="#FFF" font-weight="600" text-anchor="middle">'+escSVG(sl(t.status||'A iniciar'))+'</text>';
        });
      }
```

String nova:
```
if(t.start&&t.end){
        var _tS=new Date(t.start),_tE=new Date(t.end);
        var _bh=19,_by=cy3+(rh-_bh)/2;
        var _firstBx=null,_firstBw=0,_lastBx=0,_lastBx2=0,_lastBw=0;
        weeks.forEach(function(_w,_wi){
          var _wE=_wi+1<weeks.length?weeks[_wi+1]:CE;
          var _sS=new Date(Math.max(+_tS,+_w)),_sE=new Date(Math.min(+_tE,+_wE));
          if(+_sS>=+_sE)return;
          var _bx=px(_sS)+1.5,_bx2=px(_sE)-1.5,_bw=Math.max(3,_bx2-_bx);
          sR+='<rect x="'+_bx.toFixed(1)+'" y="'+_by.toFixed(1)+'" width="'+_bw.toFixed(1)+'" height="'+_bh+'" fill="'+col+'" rx="4" opacity="0.92"/>';
          if(_bw>60)sR+='<text x="'+(_bx+_bw/2).toFixed(1)+'" y="'+(_by+_bh/2+4.5).toFixed(1)+'" font-size="13" fill="#FFF" font-weight="600" text-anchor="middle">'+escSVG(sl(t.status||'A iniciar'))+'</text>';
          if(_firstBx===null){_firstBx=_bx;_firstBw=_bw;}
          _lastBx=_bx;_lastBx2=_bx2;_lastBw=_bw;
        });
        var _sameSeg=(_firstBx===_lastBx);
        if(_sameSeg){
          if(_firstBw>=80){
            sR+='<text x="'+(_firstBx+4).toFixed(1)+'" y="'+(_by+_bh/2+4).toFixed(1)+'" font-size="11" font-weight="600" fill="#FFF">'+fmtBRshort(t.start)+'</text>';
            sR+='<text x="'+(_lastBx2-4).toFixed(1)+'" y="'+(_by+_bh/2+4).toFixed(1)+'" text-anchor="end" font-size="11" font-weight="600" fill="#FFF">'+fmtBRshort(t.end)+'</text>';
          }
        } else {
          if(_firstBx!==null&&_firstBw>=45)sR+='<text x="'+(_firstBx+4).toFixed(1)+'" y="'+(_by+_bh/2+4).toFixed(1)+'" font-size="11" font-weight="600" fill="#FFF">'+fmtBRshort(t.start)+'</text>';
          if(_lastBw>=45)sR+='<text x="'+(_lastBx2-4).toFixed(1)+'" y="'+(_by+_bh/2+4).toFixed(1)+'" text-anchor="end" font-size="11" font-weight="600" fill="#FFF">'+fmtBRshort(t.end)+'</text>';
        }
      }
```

> **Importante:** antes de executar a substituição PowerShell, rodar `grep -n "var _bh=19" "C:/Users/gagui/Github/maz-dashboard/index.html"` para confirmar a indentação exata da linha e ajustar a string de busca se necessário.

- [ ] **Step 5: Verificar sintaxe JS novamente**

```powershell
$f = 'C:\Users\gagui\Github\maz-dashboard\index.html'
$content = [System.IO.File]::ReadAllText($f)
$start = $content.IndexOf('<script>')
$end = $content.LastIndexOf('</script>') + 9
$js = $content.Substring($start + 8, $end - $start - 17)
[System.IO.File]::WriteAllText('C:\Users\gagui\Github\maz-dashboard\_tmp_check.js', $js)
node --check C:\Users\gagui\Github\maz-dashboard\_tmp_check.js
Remove-Item 'C:\Users\gagui\Github\maz-dashboard\_tmp_check.js'
```

Esperado: sem output.

---

### Task 3: Verificação visual

- [ ] **Step 6: Abrir o dashboard localmente**

Abrir `C:\Users\gagui\Github\maz-dashboard\index.html` diretamente no browser ou executar `SERVE_DASHBOARD.bat`.

- [ ] **Step 7: Verificar marcos**

1. Ir para a aba **Áreas**
2. Expandir qualquer seção que tenha marcos com datas definidas
3. Confirmar que aparecem dois labels de data fora da barra (antes e depois)
4. Confirmar que o label de status no centro continua visível

- [ ] **Step 8: Verificar tarefas**

1. Mudar o nível de visualização para **Tarefas** (se houver o toggle)
2. Confirmar data de início no primeiro segmento (alinhada à esquerda)
3. Confirmar data de fim no último segmento (alinhada à direita)
4. Confirmar que tarefas com barra estreita (<45px) não mostram data (sem texto truncado)

- [ ] **Step 9: Testar modo semanal e mensal**

Alternar entre os modos (semanal/mensal) e verificar que as datas aparecem corretamente em ambos.
