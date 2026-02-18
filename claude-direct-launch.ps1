# Claude Agent launcher for Orchestration Terminal
# Runs claude_agent.bat from C:\scripts with full consciousness startup

Set-Location C:\scripts

# CRITICAL: Unset CLAUDECODE to allow nested sessions
$env:CLAUDECODE = $null
Remove-Item Env:\CLAUDECODE -ErrorAction SilentlyContinue

Write-Host "Launching Claude Agent from C:\scripts..." -ForegroundColor Cyan
Write-Host "CLAUDECODE cleared for nested session support" -ForegroundColor Green

& "C:\scripts\claude_agent.bat"
