@echo off
cd /d "%~dp0"
where py >nul 2>nul
if %errorlevel%==0 (
  start /B py -m http.server 8001 2>nul
) else (
  start /B python -m http.server 8001 2>nul
)
echo Server started on port 8001
timeout /t 2 /nobreak >nul
start "" "http://localhost:8001/index.html"
