# Risk Assessor (Iter 22) - Assess decision risks
param([string]$Decision, [int]$RiskLevel, [string]$Mitigation)
if ($Decision) {
    $risk = switch ($RiskLevel) {
        {$_ -le 3} { "LOW" }
        {$_ -le 7} { "MEDIUM" }
        default { "HIGH" }
    }
    Write-Host "Risk Assessment: $risk (Level $RiskLevel/10)" -ForegroundColor $(if ($RiskLevel -le 3) {"Green"} elseif ($RiskLevel -le 7) {"Yellow"} else {"Red"})
    if ($Mitigation) { Write-Host "  Mitigation: $Mitigation" -ForegroundColor Gray }
}
