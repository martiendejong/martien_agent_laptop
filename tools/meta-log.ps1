#!/usr/bin/env pwsh
# meta-log.ps1 - Quick wrapper for logging actions with meta-cognition
# Usage: meta-log "action name" "why I did this" "what happened"

<#
.SYNOPSIS
    !/usr/bin/env pwsh

.DESCRIPTION
    !/usr/bin/env pwsh

.NOTES
    File: meta-log.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$true, Position=0)]

$ErrorActionPreference = "Stop"
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
Write-Host "ðŸ’­ Meta-Cognition:" -ForegroundColor Magenta
Write-Host "   â€¢ Why did I do this? $Why" -ForegroundColor Gray
Write-Host "   â€¢ Was this optimal? $(if ($Outcome -like '*success*' -or $Outcome -like '*Success*') { 'âœ… Yes' } else { 'âš ï¸  Could improve' })" -ForegroundColor Gray
Write-Host "   â€¢ Should this be automated? $(if ($LASTEXITCODE -ge 3) { 'ðŸ”” YES - Pattern detected!' } else { 'Not yet (occurrence #' + $LASTEXITCODE + ')' })" -ForegroundColor Gray
Write-Host ""
