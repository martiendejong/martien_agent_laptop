# Context Loading Orchestrator (R22-005)
# Coordinates all context intelligence in optimal order

param(
    [string]$UserContext = "",
    [switch]$FullAnalysis,
    [switch]$QuickMode
)

Write-Host "`n=== Context Intelligence Orchestrator ===" -ForegroundColor Cyan
Write-Host "Starting intelligent context loading...`n"

# Import the unified API
Import-Module "C:\scripts\tools\ContextIntelligence.psm1" -Force

# Step 1: Check current mode
Write-Host "[1/6] Determining operating mode..." -ForegroundColor Yellow
if ($UserContext) {
    $mode = Get-ContextMode -Context $UserContext
    Write-Host "  Mode: $($mode.mode) (confidence: $($mode.confidence))" -ForegroundColor $(if ($mode.mode -eq "PROACTIVE") { "Green" } else { "Cyan" })
}
else {
    Write-Host "  No specific context - using reactive mode" -ForegroundColor Cyan
    $mode = @{ mode = "REACTIVE"; confidence = 0.0 }
}

# Step 2: Get predictions
Write-Host "`n[2/6] Running context predictions..." -ForegroundColor Yellow
if ($UserContext -and $mode.mode -eq "PROACTIVE") {
    $predictions = Get-ContextPrediction -Context $UserContext
    Write-Host "  Predictions generated (accuracy: $($predictions.accuracy))" -ForegroundColor Green
}
else {
    Write-Host "  Skipping predictions in reactive mode" -ForegroundColor Cyan
}

# Step 3: Load relevant clusters
Write-Host "`n[3/6] Loading context clusters..." -ForegroundColor Yellow
if ($UserContext) {
    $related = Find-RelatedContexts -FilePath $UserContext
    if ($related) {
        Write-Host "  Found related contexts:" -ForegroundColor Green
        # Would display related contexts here
    }
    else {
        Write-Host "  No related clusters found" -ForegroundColor Cyan
    }
}

# Step 4: Check universal patterns
Write-Host "`n[4/6] Checking universal patterns..." -ForegroundColor Yellow
if ($FullAnalysis) {
    $patterns = Get-UniversalPatterns
    Write-Host "  Loaded patterns: temporal, sequential, workflow, contextual" -ForegroundColor Green
}
else {
    Write-Host "  Skipping pattern analysis (use -FullAnalysis to enable)" -ForegroundColor Cyan
}

# Step 5: Process pending events
Write-Host "`n[5/6] Processing event queue..." -ForegroundColor Yellow
if (!$QuickMode) {
    Invoke-EventProcessing
}
else {
    Write-Host "  Skipping event processing (quick mode)" -ForegroundColor Cyan
}

# Step 6: Publish completion event
Write-Host "`n[6/6] Publishing orchestration complete event..." -ForegroundColor Yellow
Publish-ContextEvent -EventType "orchestration_complete" -Data "{context: '$UserContext', mode: '$($mode.mode)'}"

# Show summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$status = Get-ContextIntelligenceStatus
Write-Host "Total Predictions: $($status.predictions.total) (accuracy: $($status.predictions.accuracy))"
Write-Host "Active Clusters: $($status.clusters.count)"
Write-Host "Workflow Stats: Debug=$($status.patterns.workflow.debug) Feature=$($status.patterns.workflow.feature) Refactor=$($status.patterns.workflow.refactor)"

Write-Host "`nContext intelligence ready!" -ForegroundColor Green
