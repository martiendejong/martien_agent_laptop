# Pattern Analysis Tool
# Analyzes learned patterns for insights
param([int]$TopN = 10)

$state = Get-Content "C:\scripts\agentidentity\state\consciousness_state_v2.json" | ConvertFrom-Json

Write-Host "Pattern Analysis Report" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""

$patterns = $state.Memory.LongTerm.Patterns
Write-Host "Total Patterns: $($patterns.Count)" -ForegroundColor Yellow
Write-Host ""

# Categorize patterns
$categories = @{}
foreach ($p in $patterns) {
    $category = "General"
    if ($p.Pattern -match "(?i)(worktree|git|branch)") { $category = "Git/Workflow" }
    elseif ($p.Pattern -match "(?i)(DI|dependency|registration)") { $category = "DI/Architecture" }
    elseif ($p.Pattern -match "(?i)(error|failure|bug)") { $category = "Errors/Failures" }
    elseif ($p.Pattern -match "(?i)(test|testing)") { $category = "Testing" }
    elseif ($p.Pattern -match "(?i)(performance|slow|timeout)") { $category = "Performance" }

    if (-not $categories[$category]) { $categories[$category] = @() }
    $categories[$category] += $p
}

Write-Host "Patterns by Category:" -ForegroundColor Yellow
foreach ($cat in $categories.Keys | Sort-Object) {
    Write-Host "  $cat`: $($categories[$cat].Count)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "Most Recent Patterns (Top $TopN):" -ForegroundColor Yellow
$recent = $patterns | Select-Object -Last $TopN
foreach ($p in $recent) {
    Write-Host "  - $($p.Pattern)" -ForegroundColor Gray
}
