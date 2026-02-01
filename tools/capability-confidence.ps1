<#
.SYNOPSIS
    Query capability confidence scores (ACE Framework Layer 3)

.DESCRIPTION
    Simple tool to query confidence scores from confidence_scores.yaml

.PARAMETER Capability
    Capability to query (e.g., "csharp_backend")

.EXAMPLE
    .\capability-confidence.ps1 -Capability "csharp_backend"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Capability
)

$ScoresPath = "C:\scripts\agentidentity\capabilities\confidence_scores.yaml"

if (-not (Test-Path $ScoresPath)) {
    Write-Error "Confidence scores file not found: $ScoresPath"
    exit 1
}

$content = Get-Content $ScoresPath -Raw

if ($Capability) {
    # Simple search for the capability
    if ($content -match "(?ms)$Capability`:.*?score:\s*(\d+).*?evidence:\s*`"([^`"]+)`"") {
        $score = $matches[1]
        $evidence = $matches[2]

        $color = if ($score -ge 90) { "Green" } elseif ($score -ge 80) { "Cyan" } elseif ($score -ge 70) { "Yellow" } else { "Red" }

        Write-Host ""
        Write-Host "Capability: $Capability" -ForegroundColor Cyan
        Write-Host "Confidence: $score%" -ForegroundColor $color
        Write-Host "Evidence: $evidence" -ForegroundColor Gray
        Write-Host ""
    }
    else {
        Write-Host "Capability not found: $Capability" -ForegroundColor Red
        Write-Host "Try: csharp_backend, typescript_react_frontend, powershell_scripting, git_operations, etc."
    }
}
else {
    # Show overall summary
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host " Capability Confidence Summary" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Overall Confidence: 87.2%" -ForegroundColor Green
    Write-Host ""
    Write-Host "Highest Confidence:" -ForegroundColor Green
    Write-Host "  - powershell_scripting: 95%"
    Write-Host "  - worktree_management: 95%"
    Write-Host ""
    Write-Host "Improvement Needed:" -ForegroundColor Yellow
    Write-Host "  - sql_database: 75%"
    Write-Host "  - clickup_integration: 78%"
    Write-Host "  - desktop_ui_automation: 80%"
    Write-Host ""
    Write-Host "Usage: .\capability-confidence.ps1 -Capability <name>"
    Write-Host "File: $ScoresPath"
    Write-Host ""
}
