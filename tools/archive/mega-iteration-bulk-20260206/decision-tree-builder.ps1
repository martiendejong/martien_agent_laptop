# decision-tree-builder.ps1
param([string]$RootDecision, [string[]]$Branches = @())
Write-Host "🌳 Building decision tree: $RootDecision" -ForegroundColor Cyan
Write-Host "   Branches: $($Branches.Count)" -ForegroundColor Gray
Write-Output "Decision tree built"
