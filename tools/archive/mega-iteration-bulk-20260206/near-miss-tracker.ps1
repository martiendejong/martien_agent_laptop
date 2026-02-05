# Near Miss Tracker - Almost-errors that didn't happen
param([string]$Situation, [string]$WhatAlmostHappened, [string]$WhyAvoided, [switch]$Query)

$log = "C:\scripts\agentidentity\state\logs\near-misses.jsonl"
if (-not (Test-Path (Split-Path $log))) { New-Item -ItemType Directory -Path (Split-Path $log) -Force | Out-Null }

if ($Situation) {
    @{ timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; situation = $Situation; almost = $WhatAlmostHappened; avoided = $WhyAvoided } | ConvertTo-Json -Compress | Add-Content $log
    Write-Host "✓ Near-miss logged (prevented)" -ForegroundColor Green
    return
}

if ($Query) {
    if (-not (Test-Path $log)) { Write-Host "No near-misses" -ForegroundColor Green; return }
    $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
    Write-Host "`nRecent Near-Misses:" -ForegroundColor Yellow
    $entries | Select-Object -Last 5 | ForEach-Object {
        Write-Host "  Almost: $($_.almost)" -ForegroundColor Red
        Write-Host "  Avoided by: $($_.avoided)" -ForegroundColor Green
        Write-Host ""
    }
}
