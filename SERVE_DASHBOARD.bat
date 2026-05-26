@echo off
cd /d "%~dp0"
start /B python -m http.server 8765 2>nul
echo Server started on port 8765
timeout /t 2 /nobreak >nul
start "" "http://localhost:8765/index.html"
