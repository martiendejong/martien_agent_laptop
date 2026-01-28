@echo off
echo Stopping Hazina Orchestration...
taskkill /IM HazinaOrchestration.exe /F 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Stopped successfully.
) else (
    echo Orchestration was not running.
)
