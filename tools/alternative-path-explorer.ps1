# alternative-path-explorer.ps1
param([string]$RejectedAlternative, [switch]$Explore)
if ($Explore) {
    Write-Host "🛤️  Exploring rejected path: $RejectedAlternative" -ForegroundColor Yellow
}
Write-Output "Alternative explored"
