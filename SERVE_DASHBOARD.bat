@echo off
cd /d "%~dp0"
start /B python -m http.server 8000 2>nul
echo Server started on port 8000
timeout /t 2 /nobreak >nul
start "" "http://localhost:8000/index.html"
