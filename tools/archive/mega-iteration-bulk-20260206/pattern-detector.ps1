# Pattern Detector (Iter 16) - Auto-detect recurring patterns
param([string]$Action, [switch]$Analyze)
$log = "C:\scripts\agentidentity\state\logs\actions.jsonl"
if ($Action) { @{ts=Get-Date -Format "yyyy-MM-dd HH:mm:ss";action=$Action} | ConvertTo-Json -Compress | Add-Content $log }
if ($Analyze) {
    $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
    $patterns = $entries | Group-Object -Property action | Where-Object { $_.Count -ge 3 } | Sort-Object Count -Descending
    Write-Host "Recurring Patterns (3+):" -ForegroundColor Yellow
    $patterns | ForEach-Object { Write-Host "  $($_.Count)x $($_.Name)" -ForegroundColor Cyan }
}
