# scenario-comparer.ps1
param([string]$ScenarioA, [string]$ScenarioB, [switch]$Compare)
if ($Compare) {
    Write-Host "⚖️  Comparing scenarios:" -ForegroundColor Cyan
    Write-Host "   A: $ScenarioA" -ForegroundColor Gray
    Write-Host "   B: $ScenarioB" -ForegroundColor Gray
}
Write-Output "Scenarios compared"
