# Learning Velocity Tracker (Iteration 13)
param([string]$Learned, [string]$Source, [int]$TimeToLearn, [switch]$Query)
$log = "C:\scripts\agentidentity\state\logs\learning.jsonl"
if (-not (Test-Path (Split-Path $log))) { New-Item -ItemType Directory -Path (Split-Path $log) -Force | Out-Null }
if ($Learned) {
    @{ timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; learned = $Learned; source = $Source; time_minutes = $TimeToLearn } | ConvertTo-Json -Compress | Add-Content $log
    Write-Host "✓ Learning logged: $Learned" -ForegroundColor Green
}
if ($Query) {
    if (-not (Test-Path $log)) { return }
    $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
    Write-Host "Learning Stats:" -ForegroundColor Yellow
    Write-Host "  Total learnings: $($entries.Count)" -ForegroundColor White
    $sources = $entries | Group-Object -Property source | Sort-Object Count -Descending
    Write-Host "  Top sources:" -ForegroundColor White
    $sources | Select-Object -First 3 | ForEach-Object { Write-Host "    $($_.Name): $($_.Count) learnings" -ForegroundColor Gray }
}
