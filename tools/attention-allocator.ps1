# Attention Allocation Tracker (Iteration 12)
param([string]$FocusOn, [int]$Minutes, [string]$Why, [switch]$Report)
$log = "C:\scripts\agentidentity\state\logs\attention.jsonl"
if (-not (Test-Path (Split-Path $log))) { New-Item -ItemType Directory -Path (Split-Path $log) -Force | Out-Null }
if ($FocusOn) {
    @{ timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; focus = $FocusOn; minutes = $Minutes; why = $Why } | ConvertTo-Json -Compress | Add-Content $log
    Write-Host "✓ Attention allocated: $Minutes min on $FocusOn" -ForegroundColor Cyan
}
if ($Report) {
    if (-not (Test-Path $log)) { return }
    $entries = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
    $grouped = $entries | Group-Object -Property focus | Sort-Object { ($_.Group | Measure-Object -Property minutes -Sum).Sum } -Descending
    Write-Host "Attention Distribution:" -ForegroundColor Yellow
    $grouped | Select-Object -First 5 | ForEach-Object {
        $total = ($_.Group | Measure-Object -Property minutes -Sum).Sum
        Write-Host "  $($_.Name): $total minutes" -ForegroundColor White
    }
}
