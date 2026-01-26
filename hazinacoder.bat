@echo off
setlocal enabledelayedexpansion

REM --- Enable ANSI escape sequences for color support ---
REM Set initial terminal color to IDLE state (black background)
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\set-state-color.ps1" -State idle 2>nul

REM --- Set dynamic window title ---
REM Try to get current branch name, otherwise use default
for /f "tokens=*" %%i in ('git branch --show-current 2^>nul') do set BRANCH=%%i
if defined BRANCH (
    REM Convert branch name to uppercase for visibility
    for /f "tokens=*" %%a in ('powershell -Command "\"!BRANCH!\".ToUpper()"') do set BRANCH_UPPER=%%a
    title 🧠 HAZINACODER - !BRANCH_UPPER!
) else (
    title 🧠 HAZINACODER - IDLE
)

REM --- Git checkpoint ---
git add .
git commit -m "checkpoint before HazinaCoder session" >nul 2>&1

REM --- Set Ollama URL to production server ---
set OLLAMA_HOST=http://localhost:5555

REM --- HazinaCoder Autonomous Agent ---
echo Starting HazinaCoder...
echo.
echo Provider: Ollama (production server - localhost:5555)
echo.
echo Features:
echo   - Same context as Claude Code CLI (C:\scripts)
echo   - Full autonomous agent capabilities
echo   - Persistent learning (POC 1)
echo   - Self-improvement mandate
echo   - Worktree-first development
echo.

cd /d C:\Projects\hazina\apps\CLI\Hazina.App.HazinaCoder
dotnet run -- --provider ollama

pause
