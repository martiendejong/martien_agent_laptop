# path-not-taken-analyzer.ps1
param([string]$PathNotTaken, [switch]$Analyze)
if ($Analyze) {
    Write-Host "🔍 Analyzing path not taken: $PathNotTaken" -ForegroundColor Yellow
    Write-Host "   What would have happened?" -ForegroundColor Gray
}
Write-Output "Path analyzed"
