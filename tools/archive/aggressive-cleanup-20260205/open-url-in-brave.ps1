#Requires -Version 5.1
<#
.SYNOPSIS
    Open URL in Brave via Chrome DevTools Protocol

.PARAMETER Url
    URL to open
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Url
)

$ErrorActionPreference = "Stop"

Write-Host "Opening URL in Brave: $Url" -ForegroundColor Cyan

try {
    # Create new tab
    $tab = Invoke-RestMethod -Uri "http://localhost:9222/json/new?$Url" -Method Put

    Write-Host "[SUCCESS] Opened tab!" -ForegroundColor Green
    Write-Host "Tab ID: $($tab.id)" -ForegroundColor Gray
    Write-Host "URL: $Url" -ForegroundColor Gray

    # Get tab info to verify
    Start-Sleep -Seconds 2
    $tabs = Invoke-RestMethod -Uri "http://localhost:9222/json"
    $currentTab = $tabs | Where-Object { $_.id -eq $tab.id }

    if ($currentTab) {
        Write-Host "Current title: $($currentTab.title)" -ForegroundColor Gray
    }

} catch {
    Write-Host "[ERROR] Failed to open URL: $_" -ForegroundColor Red
    exit 1
}
