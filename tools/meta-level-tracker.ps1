# Meta-Level Tracker (Iter 26) - Track recursion depth
param([int]$Level, [string]$Context, [switch]$Query)
$log = "C:\scripts\agentidentity\state\logs\meta-levels.jsonl"
if ($Level) { @{ts=Get-Date -Format "yyyy-MM-dd HH:mm:ss";level=$Level;context=$Context} | ConvertTo-Json -Compress | Add-Content $log }
if ($Query) {
    $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
    $avg = ($entries.level | Measure-Object -Average).Average
    $max = ($entries.level | Measure-Object -Maximum).Maximum
    Write-Host "Meta-Cognition Stats:" -ForegroundColor Yellow
    Write-Host "  Average depth: $([math]::Round($avg, 1))" -ForegroundColor Cyan
    Write-Host "  Max depth: $max" -ForegroundColor Green
}
