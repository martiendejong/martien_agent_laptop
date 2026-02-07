#!/usr/bin/env pwsh
# meta-log.ps1 - Quick wrapper for logging actions with meta-cognition
# Usage: meta-log "action name" "why I did this" "what happened"

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Action,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$Why,

    [Parameter(Mandatory=$false, Position=2)]
    [string]$Outcome = "Success"
)

# Simple wrapper around log-action.ps1
& "C:\scripts\tools\log-action.ps1" `
    -Action $Action `
    -Reasoning $Why `
    -Outcome $Outcome

# Meta-cognitive questions (displayed to encourage reflection)
Write-Host ""
Write-Host "💭 Meta-Cognition:" -ForegroundColor Magenta
Write-Host "   • Why did I do this? $Why" -ForegroundColor Gray
Write-Host "   • Was this optimal? $(if ($Outcome -like '*success*' -or $Outcome -like '*Success*') { '✅ Yes' } else { '⚠️  Could improve' })" -ForegroundColor Gray
Write-Host "   • Should this be automated? $(if ($LASTEXITCODE -ge 3) { '🔔 YES - Pattern detected!' } else { 'Not yet (occurrence #' + $LASTEXITCODE + ')' })" -ForegroundColor Gray
Write-Host ""
