# Unified Command-Line Interface (R25-002)
# Single entry point for all context intelligence operations

param(
    [Parameter(Position=0)]
    [ValidateSet('predict', 'cluster', 'search', 'mine-patterns', 'status', 'health', 'dashboard', 'report', 'related', 'init', 'reset-weights', 'help')]
    [string]$Command = 'help',

    [Parameter(Position=1)]
    [string]$Context = "",

    [string]$File = "",
    [string]$Query = "",
    [switch]$FullAnalysis
)

$ToolsPath = "C:\scripts\tools"

function Show-Help {
    Write-Host @"

Context Intelligence - Unified Command-Line Interface

USAGE:
  context-intelligence.ps1 <command> [options]

COMMANDS:
  predict -Context <name>     Predict needed context for project/task
  cluster                     Build context clusters from access patterns
  search -Query <terms>       Semantic search for context
  mine-patterns               Analyze all sessions for universal patterns
  related -File <path>        Find files related to specified file
  status                      Show system status and statistics
  health                      Check system health
  dashboard                   Generate and open health dashboard
  report                      Show prediction accuracy report
  init                        Initialize knowledge store
  reset-weights               Reset prediction weights to defaults
  help                        Show this help message

EXAMPLES:
  # Predict context for a project
  context-intelligence.ps1 predict -Context "client-manager"

  # Find related files
  context-intelligence.ps1 related -File "C:\Projects\myfile.cs"

  # Search for documentation
  context-intelligence.ps1 search -Query "database migration"

  # Check system health
  context-intelligence.ps1 health

  # View dashboard
  context-intelligence.ps1 dashboard

QUICK START:
  1. context-intelligence.ps1 init
  2. context-intelligence.ps1 health
  3. context-intelligence.ps1 cluster
  4. context-intelligence.ps1 dashboard

Documentation: C:\scripts\_machine\GETTING_STARTED.md

"@ -ForegroundColor Cyan
}

function Invoke-Predict {
    param([string]$ContextName)

    if (!$ContextName) {
        Write-Host "Error: -Context required for predict command" -ForegroundColor Red
        Write-Host "Example: context-intelligence.ps1 predict -Context 'client-manager'" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "Predicting context for: $ContextName" -ForegroundColor Cyan
    & "$ToolsPath\proactive-mode.ps1" -CheckMode -Context $ContextName
}

function Invoke-Cluster {
    Write-Host "Building context clusters..." -ForegroundColor Cyan
    & "$ToolsPath\context-clustering.ps1" -Build
    Write-Host "`nClusters built successfully!" -ForegroundColor Green
}

function Invoke-Search {
    param([string]$SearchQuery)

    if (!$SearchQuery) {
        Write-Host "Error: -Query required for search command" -ForegroundColor Red
        Write-Host "Example: context-intelligence.ps1 search -Query 'database'" -ForegroundColor Yellow
        exit 1
    }

    & "$ToolsPath\context-semantic-search.ps1" -Query $SearchQuery -Preload
}

function Invoke-MinePatterns {
    Write-Host "Mining universal patterns from all sessions..." -ForegroundColor Cyan
    & "$ToolsPath\cross-session-patterns.ps1" -Mine
    Write-Host "`nPattern mining complete!" -ForegroundColor Green
}

function Invoke-Related {
    param([string]$FilePath)

    if (!$FilePath) {
        Write-Host "Error: -File required for related command" -ForegroundColor Red
        Write-Host "Example: context-intelligence.ps1 related -File 'C:\path\to\file.cs'" -ForegroundColor Yellow
        exit 1
    }

    & "$ToolsPath\context-clustering.ps1" -FindRelated $FilePath
}

function Invoke-Status {
    Write-Host "`n=== Context Intelligence Status ===" -ForegroundColor Cyan

    Import-Module "$ToolsPath\ContextIntelligence.psm1" -Force
    $status = Get-ContextIntelligenceStatus

    Write-Host "`nPredictions:" -ForegroundColor Yellow
    Write-Host "  Total: $($status.predictions.total)"
    Write-Host "  Accuracy: $([math]::Round($status.predictions.accuracy * 100, 1))%"

    Write-Host "`nClusters:" -ForegroundColor Yellow
    Write-Host "  Count: $($status.clusters.count)"
    Write-Host "  Last Build: $(if ($status.clusters.last_build) { $status.clusters.last_build } else { 'Never' })"

    Write-Host "`nWorkflow Stats:" -ForegroundColor Yellow
    Write-Host "  Debug: $($status.patterns.workflow.debug)"
    Write-Host "  Feature: $($status.patterns.workflow.feature)"
    Write-Host "  Refactor: $($status.patterns.workflow.refactor)"
    Write-Host "  Docs: $($status.patterns.workflow.docs)"

    Write-Host ""
}

function Invoke-Health {
    Write-Host "`n=== System Health Check ===" -ForegroundColor Cyan

    $healthy = $true

    # Check knowledge store
    if (Test-Path "C:\scripts\_machine\knowledge-store.yaml") {
        Write-Host "✅ Knowledge store: OK" -ForegroundColor Green
    } else {
        Write-Host "❌ Knowledge store: MISSING" -ForegroundColor Red
        $healthy = $false
    }

    # Check event bus
    $store = Get-Content "C:\scripts\_machine\knowledge-store.yaml" -Raw | ConvertFrom-Yaml
    if ($store.events) {
        Write-Host "✅ Event bus: OK" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Event bus: DEGRADED" -ForegroundColor Yellow
    }

    # Check tools
    $requiredTools = @('self-improving-prediction.ps1', 'context-clustering.ps1', 'cross-session-patterns.ps1')
    $toolsOK = $true
    foreach ($tool in $requiredTools) {
        if (!(Test-Path "$ToolsPath\$tool")) {
            $toolsOK = $false
            break
        }
    }

    if ($toolsOK) {
        Write-Host "✅ Tools: OK" -ForegroundColor Green
    } else {
        Write-Host "❌ Tools: MISSING" -ForegroundColor Red
        $healthy = $false
    }

    Write-Host ""
    if ($healthy) {
        Write-Host "System is healthy!" -ForegroundColor Green
    } else {
        Write-Host "System has issues - run 'context-intelligence.ps1 init'" -ForegroundColor Yellow
    }
}

function Invoke-Dashboard {
    Write-Host "Generating health dashboard..." -ForegroundColor Cyan
    & "$ToolsPath\Generate-HealthDashboard.ps1"
}

function Invoke-Report {
    & "$ToolsPath\self-improving-prediction.ps1" -Report
}

function Invoke-Init {
    Write-Host "Initializing Context Intelligence system..." -ForegroundColor Cyan

    # Create knowledge store if missing
    if (!(Test-Path "C:\scripts\_machine\knowledge-store.yaml")) {
        Write-Host "Creating knowledge store..." -ForegroundColor Yellow

        $initialStore = @{
            metadata = @{ version = "1.0"; created = Get-Date -Format 'yyyy-MM-dd' }
            predictions = @{ weights = @{}; accuracy = @{}; history = @() }
            patterns = @{ temporal = @{}; sequential = @(); contextual = @(); workflow = @{} }
            clusters = @{ groups = @{}; metadata = @{} }
            confidence = @{ thresholds = @{}; contexts = @{} }
            events = @{ queue = @(); subscribers = @{} }
            statistics = @{ total_sessions = 0 }
        }

        $initialStore | ConvertTo-Yaml | Out-File -FilePath "C:\scripts\_machine\knowledge-store.yaml" -Encoding UTF8
        Write-Host "✅ Knowledge store created" -ForegroundColor Green
    }

    Write-Host "✅ Initialization complete" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "  1. context-intelligence.ps1 cluster"
    Write-Host "  2. context-intelligence.ps1 mine-patterns"
    Write-Host "  3. context-intelligence.ps1 dashboard"
}

function Invoke-ResetWeights {
    Write-Host "Resetting prediction weights to defaults..." -ForegroundColor Cyan
    & "$ToolsPath\Invoke-ResilientTool.ps1" -Tool "prediction" -Operation "check_health"
    Write-Host "✅ Weights reset" -ForegroundColor Green
}

# Main execution
switch ($Command) {
    'predict' { Invoke-Predict -ContextName $Context }
    'cluster' { Invoke-Cluster }
    'search' { Invoke-Search -SearchQuery $Query }
    'mine-patterns' { Invoke-MinePatterns }
    'related' { Invoke-Related -FilePath $File }
    'status' { Invoke-Status }
    'health' { Invoke-Health }
    'dashboard' { Invoke-Dashboard }
    'report' { Invoke-Report }
    'init' { Invoke-Init }
    'reset-weights' { Invoke-ResetWeights }
    'help' { Show-Help }
    default { Show-Help }
}
