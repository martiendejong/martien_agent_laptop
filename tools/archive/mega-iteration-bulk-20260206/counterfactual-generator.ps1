# counterfactual-generator.ps1
param([string]$Decision, [switch]$Generate)
if ($Generate) {
    Write-Host "🔄 Counterfactual: What if NOT $Decision?" -ForegroundColor Cyan
    Write-Host "   • Alternative outcomes to consider" -ForegroundColor Gray
}
Write-Output "Counterfactual generated"
