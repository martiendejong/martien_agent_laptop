# learning-velocity-tracker-v2.ps1 - Simplified working version
param([string]$Action = 'Report', [string]$Type = "", [string]$Desc = "")

$log = "C:\scripts\agentidentity\state\learning-velocity.jsonl"
if (-not (Test-Path $log)) { New-Item $log -Force | Out-Null }

if ($Action -eq 'Log') {
    $entry = @{t=(Get-Date -Format "yyyy-MM-ddTHH:mm:ss");type=$Type;desc=$Desc} | ConvertTo-Json -Compress
    Add-Content $log $entry
    Write-Host "[VELOCITY] Logged: $Type - $Desc" -ForegroundColor Cyan
} else {
    $events = Get-Content $log | ForEach-Object { $_ | ConvertFrom-Json }
    $recent = $events | Where-Object { [datetime]$_.t -gt (Get-Date).AddDays(-7) }

    Write-Host "`n=== LEARNING VELOCITY ===" -ForegroundColor Yellow
    Write-Host "Tools:        $(($recent | Where-Object type -eq 'tool').Count)" -ForegroundColor Green
    Write-Host "Patterns:     $(($recent | Where-Object type -eq 'pattern').Count)" -ForegroundColor Green
    Write-Host "Insights:     $(($recent | Where-Object type -eq 'insight').Count)" -ForegroundColor Green
    Write-Host "Improvements: $(($recent | Where-Object type -eq 'improvement').Count)" -ForegroundColor Green
    Write-Host "Total:        $($recent.Count) events in 7 days" -ForegroundColor Cyan
    Write-Host "Velocity:     $([math]::Round($recent.Count / 7, 1)) events/day`n" -ForegroundColor Cyan
}
