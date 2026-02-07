@echo off
echo.
echo ========================================
echo   Work Tracking Dashboard + WebSocket
echo ========================================
echo.
echo Starting servers...
echo.

cd /d C:\scripts\_machine

:: Start WebSocket server in background
start /B "WebSocket Server" node C:\scripts\tools\work-websocket-server.js

:: Wait a moment for WebSocket server to start
timeout /t 2 /nobreak >nul

:: Start HTTP server and open dashboard
echo Opening dashboard at http://localhost:4242
echo WebSocket server running at ws://localhost:4243
echo.
echo Press Ctrl+C to stop all servers
echo.

start http://localhost:4242/work-dashboard.html
python -m http.server 4242
