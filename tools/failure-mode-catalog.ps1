# Failure Mode Catalog - Track how I fail
param([string]$Mode, [string]$Description, [string]$Prevention, [switch]$Query)

$log = "C:\scripts\agentidentity\state\logs\failure-modes.jsonl"
if (-not (Test-Path (Split-Path $log))) { New-Item -ItemType Directory -Path (Split-Path $log) -Force | Out-Null }

if ($Mode -and $Description) {
    @{ timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; mode = $Mode; description = $Description; prevention = $Prevention } | ConvertTo-Json -Compress | Add-Content $log
    Write-Host "✓ Failure mode logged: $Mode" -ForegroundColor Yellow
    return
}

if ($Query) {
    if (-not (Test-Path $log)) { Write-Host "No failures logged" -ForegroundColor Green; return }
    $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
    $grouped = $entries | Group-Object -Property mode | Sort-Object Count -Descending
    Write-Host "`nTop Failure Modes:" -ForegroundColor Yellow
    $grouped | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.Count)x $($_.Name)" -ForegroundColor Red
    }
}
