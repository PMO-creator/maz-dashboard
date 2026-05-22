@echo off
title MAZ Dashboard — Servidor Local
cd /d "%~dp0"
echo.
echo === MAZ Dashboard — Ambiente de Teste Local ===
echo.
echo Iniciando servidor em http://localhost:8765
echo Pressione Ctrl+C para encerrar.
echo.
start "" "http://localhost:8765/index.html"
python -m http.server 8765
pause
