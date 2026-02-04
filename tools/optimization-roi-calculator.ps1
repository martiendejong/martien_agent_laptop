# Optimization ROI Calculator (Iter 32)
param([int]$Effort, [int]$Value)
if ($Effort -and $Value) {
    $roi = [math]::Round(($Value - $Effort) / $Effort * 100)
    $verdict = if ($roi -gt 100) { "EXCELLENT" } elseif ($roi -gt 50) { "GOOD" } elseif ($roi -gt 0) { "MARGINAL" } else { "NEGATIVE" }
    Write-Host "Optimization ROI: $roi% - $verdict" -ForegroundColor $(if ($roi -gt 50) {"Green"} elseif ($roi -gt 0) {"Yellow"} else {"Red"})
}
