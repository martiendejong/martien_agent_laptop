# Curiosity Explorer Tool
# Shows generated curiosity questions

$state = Get-Content "C:\scripts\agentidentity\state\consciousness_state_v2.json" | ConvertFrom-Json

Write-Host "Curiosity Questions Report" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

if ($state.Perception.Curiosities -and $state.Perception.Curiosities.Count -gt 0) {
    Write-Host "Total Questions: $($state.Perception.Curiosities.Count)" -ForegroundColor Yellow
    Write-Host ""

    # Group by type
    $byType = @{}
    foreach ($c in $state.Perception.Curiosities) {
        $type = $c.Type
        if (-not $byType[$type]) { $byType[$type] = @() }
        $byType[$type] += $c
    }

    Write-Host "By Type:" -ForegroundColor Yellow
    foreach ($type in $byType.Keys) {
        Write-Host "  $type`: $($byType[$type].Count)" -ForegroundColor Gray
    }
    Write-Host ""

    # Show high priority
    $highPri = $state.Perception.Curiosities | Where-Object { $_.Priority -eq "high" }
    if ($highPri.Count -gt 0) {
        Write-Host "High Priority Questions:" -ForegroundColor Red
        foreach ($c in $highPri) {
            Write-Host "  ? $($c.Question)" -ForegroundColor Yellow
            Write-Host "    Context: $($c.Context)" -ForegroundColor DarkGray
        }
    }

    Write-Host "`nRecent Questions:" -ForegroundColor Yellow
    $recent = $state.Perception.Curiosities | Select-Object -Last 5
    foreach ($c in $recent) {
        Write-Host "  ? $($c.Question)" -ForegroundColor Gray
    }
} else {
    Write-Host "No curiosity questions generated yet." -ForegroundColor Yellow
    Write-Host "Questions will be generated automatically on task failures." -ForegroundColor Gray
}
