# Improvement Dependency Graph (R24-003)
# Maps which improvements depend on others

param(
    [switch]$ShowGraph,
    [switch]$OptimalOrder,
    [string]$CheckImprovement
)

function Get-DependencyGraph {
    return @{
        # Round 21: Emergent Properties
        "R21-001" = @{
            title = "Self-Improving Prediction Loop"
            depends_on = @()
            enables = @("R21-004", "R22-004")
        }
        "R21-002" = @{
            title = "Context-Aware Semantic Search"
            depends_on = @("R21-005")  # Needs clusters
            enables = @("R22-001")
        }
        "R21-003" = @{
            title = "Cross-Session Pattern Mining"
            depends_on = @()
            enables = @("R21-004", "R22-004")
        }
        "R21-004" = @{
            title = "Proactive vs Reactive Mode"
            depends_on = @("R21-001", "R21-003")  # Needs predictions and patterns
            enables = @("R22-005")
        }
        "R21-005" = @{
            title = "Automatic Context Clustering"
            depends_on = @()
            enables = @("R21-002", "R22-001")
        }

        # Round 22: Integration & Synthesis
        "R22-001" = @{
            title = "Central Knowledge Store"
            depends_on = @("R21-002", "R21-005")  # Consolidates cluster and semantic data
            enables = @("R22-002", "R22-003", "R23-001")
        }
        "R22-002" = @{
            title = "Context Event Bus"
            depends_on = @("R22-001")  # Uses central store
            enables = @("R22-004", "R22-005")
        }
        "R22-003" = @{
            title = "Context Intelligence API"
            depends_on = @("R22-001")  # Wraps access to central store
            enables = @("R22-005")
        }
        "R22-004" = @{
            title = "Explicit Feedback Routing"
            depends_on = @("R22-002", "R21-001", "R21-003")  # Uses event bus, predictions, patterns
            enables = @("R24-001")
        }
        "R22-005" = @{
            title = "Context Loading Orchestrator"
            depends_on = @("R22-003", "R22-002", "R21-004")  # Uses API, events, mode switching
            enables = @()
        }

        # Round 23: Robustness & Resilience
        "R23-001" = @{
            title = "Knowledge Store Validation & Backup"
            depends_on = @("R22-001")  # Protects central store
            enables = @()
        }
        "R23-002" = @{
            title = "Tool Circuit Breakers"
            depends_on = @()
            enables = @("R23-004")
        }
        "R23-003" = @{
            title = "Event Queue Bounded Size"
            depends_on = @("R22-002")  # Limits event bus
            enables = @()
        }
        "R23-004" = @{
            title = "Degraded Mode Operation"
            depends_on = @("R23-002")  # Uses circuit breakers
            enables = @()
        }
        "R23-005" = @{
            title = "Automatic Weight Reset"
            depends_on = @("R21-001")  # Heals prediction system
            enables = @()
        }

        # Round 24: Meta-Learning
        "R24-001" = @{
            title = "Improvement Process Analyzer"
            depends_on = @("R22-004")  # Analyzes feedback data
            enables = @("R24-004", "R24-005")
        }
        "R24-002" = @{
            title = "Cross-Domain Improvement Transfer"
            depends_on = @()
            enables = @()
        }
        "R24-003" = @{
            title = "Improvement Dependency Graph"
            depends_on = @()
            enables = @("R24-004")
        }
        "R24-004" = @{
            title = "Strategic Improvement Selector"
            depends_on = @("R24-001", "R24-003")  # Uses analysis and dependencies
            enables = @()
        }
        "R24-005" = @{
            title = "Best Practices Extractor"
            depends_on = @("R24-001")  # Needs process analysis
            enables = @()
        }
    }
}

function Get-OptimalImplementationOrder {
    $graph = Get-DependencyGraph
    $order = @()
    $implemented = @()

    # Topological sort
    $remaining = $graph.Keys | Sort-Object
    $maxIterations = 100
    $iteration = 0

    while ($remaining.Count -gt 0 -and $iteration -lt $maxIterations) {
        $iteration++
        $readyToImplement = @()

        foreach ($improvement in $remaining) {
            $deps = $graph[$improvement].depends_on
            $allDepsImplemented = $true

            foreach ($dep in $deps) {
                if ($dep -notin $implemented) {
                    $allDepsImplemented = $false
                    break
                }
            }

            if ($allDepsImplemented) {
                $readyToImplement += $improvement
            }
        }

        if ($readyToImplement.Count -eq 0) {
            Write-Host "Warning: Circular dependency or orphaned improvements" -ForegroundColor Yellow
            break
        }

        $order += $readyToImplement
        $implemented += $readyToImplement
        $remaining = $remaining | Where-Object { $_ -notin $readyToImplement }
    }

    return $order
}

function Show-DependencyGraph {
    $graph = Get-DependencyGraph

    Write-Host "`n=== Improvement Dependency Graph ===" -ForegroundColor Cyan

    foreach ($improvement in $graph.Keys | Sort-Object) {
        $info = $graph[$improvement]
        Write-Host "`n[$improvement] $($info.title)" -ForegroundColor Yellow

        if ($info.depends_on.Count -gt 0) {
            Write-Host "  Depends on:" -ForegroundColor Cyan
            $info.depends_on | ForEach-Object {
                Write-Host "    - $_ ($($graph[$_].title))"
            }
        }

        if ($info.enables.Count -gt 0) {
            Write-Host "  Enables:" -ForegroundColor Green
            $info.enables | ForEach-Object {
                Write-Host "    - $_ ($($graph[$_].title))"
            }
        }
    }
}

function Show-OptimalOrder {
    $order = Get-OptimalImplementationOrder

    Write-Host "`n=== Optimal Implementation Order ===" -ForegroundColor Cyan
    Write-Host "(All dependencies satisfied before dependent improvements)`n"

    $graph = Get-DependencyGraph
    for ($i = 0; $i -lt $order.Count; $i++) {
        $improvement = $order[$i]
        $info = $graph[$improvement]
        Write-Host "$($i + 1). [$improvement] $($info.title)" -ForegroundColor Green
    }
}

function Check-Improvement {
    param([string]$ImprovementId)

    $graph = Get-DependencyGraph

    if (!$graph.ContainsKey($ImprovementId)) {
        Write-Host "Unknown improvement: $ImprovementId" -ForegroundColor Red
        return
    }

    $info = $graph[$ImprovementId]

    Write-Host "`n=== $ImprovementId ===" -ForegroundColor Cyan
    Write-Host "Title: $($info.title)`n"

    if ($info.depends_on.Count -gt 0) {
        Write-Host "Prerequisites (must implement first):" -ForegroundColor Yellow
        $info.depends_on | ForEach-Object {
            Write-Host "  - $_ ($($graph[$_].title))"
        }
    }
    else {
        Write-Host "No prerequisites - can implement immediately" -ForegroundColor Green
    }

    if ($info.enables.Count -gt 0) {
        Write-Host "`nEnables these improvements:" -ForegroundColor Cyan
        $info.enables | ForEach-Object {
            Write-Host "  - $_ ($($graph[$_].title))"
        }
    }
}

# Main execution
if ($ShowGraph) {
    Show-DependencyGraph
}
elseif ($OptimalOrder) {
    Show-OptimalOrder
}
elseif ($CheckImprovement) {
    Check-Improvement -ImprovementId $CheckImprovement
}
else {
    Write-Host "Usage: Show-ImprovementDependencies.ps1 [-ShowGraph] [-OptimalOrder] [-CheckImprovement <id>]"
    Write-Host "  -ShowGraph               : Display full dependency graph"
    Write-Host "  -OptimalOrder            : Show optimal implementation order"
    Write-Host "  -CheckImprovement <id>   : Check dependencies for specific improvement"
}
