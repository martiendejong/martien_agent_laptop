# Human-AI Boundary Detector (Iter 46)
param([string]$Task, [switch]$Analyze)
if ($Analyze) {
    $aiStrong = @("pattern recognition", "search", "documentation", "repetition", "calculation")
    $humanStrong = @("intuition", "creativity", "judgment", "ethics", "emotion")

    $aiScore = ($aiStrong | Where-Object { $Task -match $_ }).Count
    $humanScore = ($humanStrong | Where-Object { $Task -match $_ }).Count

    if ($aiScore -gt $humanScore) { Write-Host "AI Task: I should handle this" -ForegroundColor Green }
    elseif ($humanScore -gt $aiScore) { Write-Host "Human Task: User should handle this" -ForegroundColor Yellow }
    else { Write-Host "Collaborative Task: Work together" -ForegroundColor Cyan }
}
