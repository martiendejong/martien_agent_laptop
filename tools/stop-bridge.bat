@echo off
echo Stopping Claude Bridge Server...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop-bridge.ps1"
echo.
pause
