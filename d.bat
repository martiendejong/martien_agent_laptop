@echo off
REM Quick launcher for Work Tracking Dashboard
REM Usage: CTRL+R -> d

echo.
echo ========================================
echo   Work Tracking Dashboard
echo ========================================
echo.

REM Check if HTTP server is already running on port 4242
netstat -ano | findstr ":4242" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Dashboard already running!
    echo      Opening browser...
    echo.
    start http://localhost:4242/work-dashboard.html
    exit /b 0
)

echo Starting servers...
echo.

cd /d C:\scripts\_machine

REM Start WebSocket server in background
start /B "WebSocket Server" node C:\scripts\tools\work-websocket-server.js

REM Wait for WebSocket server to start
timeout /t 2 /nobreak >nul

REM Start HTTP server and open dashboard
echo Opening dashboard at http://localhost:4242
echo WebSocket server running at ws://localhost:4243
echo.
echo Press Ctrl+C to stop servers
echo.

start http://localhost:4242/work-dashboard.html
python -m http.server 4242
