#!/usr/bin/env pwsh
# daily-report.ps1
# Generates daily work report
#
# Usage:
#   .\daily-report.ps1              # Report for today
#   .\daily-report.ps1 -Date "2026-02-07"   # Report for specific date
#   .\daily-report.ps1 -Email "user@example.com"  # Email report

param(
    [string]$Date = (Get-Date -Format 'yyyy-MM-dd'),
    [string]$Email = $env:WORK_TRACKING_EMAIL
)

# Import work tracking module
$modulePath = "C:\scripts\tools\work-tracking.psm1"
if (Test-Path $modulePath) {
    Import-Module $modulePath -Force
} else {
    Write-Error "Work tracking module not found at $modulePath"
    exit 1
}

# Generate report
$reportPath = New-DailyReport -Date $Date -Email $Email

if ($reportPath) {
    Write-Host "`n📄 Report contents:" -ForegroundColor Cyan
    Get-Content $reportPath | Write-Host

    # Open report in default editor
    if (Test-Path $reportPath) {
        Start-Process $reportPath
    }
}
