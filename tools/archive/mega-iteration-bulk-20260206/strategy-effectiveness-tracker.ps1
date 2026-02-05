# strategy-effectiveness-tracker.ps1
param([ValidateSet('track', 'report', 'compare')]
    [string]$Action = 'report')

$trackerPath = "C:\scripts\agentidentity\state\strategy-effectiveness.yaml"

if (Test-Path $trackerPath) {
    $data = Get-Content $trackerPath -Raw | ConvertFrom-Yaml
    
    if ($Action -eq 'report') {
        Write-Host "`n📊 STRATEGY EFFECTIVENESS REPORT" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        
        foreach ($strategyName in ($data.strategies.Keys | Sort-Object)) {
            $strategy = $data.strategies[$strategyName]
            $rate = $strategy.effectiveness_rate
            $color = if ($rate -gt 70) { "Green" } elseif ($rate -gt 50) { "Yellow" } else { "Red" }
            
            Write-Host "  $strategyName" -NoNewline -ForegroundColor White
            Write-Host " ($($strategy.successes)/$($strategy.uses)) - " -NoNewline -ForegroundColor Gray
            Write-Host "$rate%" -ForegroundColor $color
        }
        
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    }
}

Write-Output "Strategy effectiveness tracked"
