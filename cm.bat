@echo off
REM Quick launcher for Client Manager Frontend
REM Usage: CTRL+R → cm
REM Auto-validates node_modules before starting

cd /d C:\Projects\client-manager\ClientManagerFrontend

REM Check if node_modules exists and is valid
echo Checking node_modules status...
npm list --depth=0 >nul 2>&1
if errorlevel 1 (
    echo [WARNING] node_modules is out of sync or corrupt!
    echo Running npm install to fix...
    npm install
    if errorlevel 1 (
        echo [ERROR] npm install failed! Please fix manually.
        pause
        exit /b 1
    )
    echo [OK] Dependencies installed successfully.
)

echo [OK] Starting Client Manager Frontend...
start "Client Manager Frontend" cmd /k "npm run dev"
