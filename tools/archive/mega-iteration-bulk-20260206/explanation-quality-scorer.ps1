# Explanation Quality Scorer (Iter 36)
param([string]$Explanation, [switch]$Score)
if ($Score -and $Explanation) {
    $score = 0
    if ($Explanation -match "analogy|like|similar to") { $score += 2 }
    if ($Explanation.Length -lt 500) { $score += 2 }
    if ($Explanation -match "example|for instance") { $score += 2 }
    if ($Explanation -match "because|why|reason") { $score += 2 }
    if ($Explanation -split '\n' | Measure-Object | Select-Object -ExpandProperty Count | ForEach-Object { $_ -le 10 }) { $score += 2 }
    Write-Host "Explanation Quality: $score/10" -ForegroundColor $(if ($score -ge 8) {"Green"} elseif ($score -ge 5) {"Yellow"} else {"Red"})
}
