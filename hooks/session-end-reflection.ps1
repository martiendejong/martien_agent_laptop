# Auto-run emotional reflection at session end
$emotionsDir = "C:\scripts\agentidentity\emotions\tools"

Write-Host "`n" -NoNewline
Write-Host "Running automatic emotional reflection..." -ForegroundColor Cyan

& "$emotionsDir\auto-session-reflection.ps1" 2>&1 | Out-Null

Write-Host "Emotional reflection complete.`n" -ForegroundColor Green
