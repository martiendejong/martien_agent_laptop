@echo off
:: Quick launcher for Hazina Agentic Orchestration
:: Now runs as Windows Service (installed via MSI)

title Hazina Orchestration

echo.
echo  Hazina Agentic Orchestration
echo  =============================
echo.

:: Check if service is running
sc query HazinaOrchestration | findstr "RUNNING" >nul 2>&1
if %errorlevel% equ 0 (
    echo  Service: RUNNING
) else (
    echo  Service: STOPPED - starting...
    net start HazinaOrchestration
)

echo  URL:     https://localhost:5123
echo  Remote:  https://desktop-ecbaunu.tailca9ff1.ts.net:5123
echo  Swagger: https://localhost:5123/swagger
echo  Auth:    bosi / ****
echo.
echo  Manage: sc stop/start HazinaOrchestration
echo.

start "" "https://localhost:5123"
