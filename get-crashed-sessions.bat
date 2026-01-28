@echo off
REM Quick launcher for get-crashed-sessions.ps1
REM Usage: get-crashed-sessions.bat [days]
REM Example: get-crashed-sessions.bat 3

set DAYS=%1
if "%DAYS%"=="" set DAYS=7

powershell.exe -ExecutionPolicy Bypass -File "%~dp0tools\get-crashed-sessions.ps1" -Days %DAYS% -Format list -ShowContext
