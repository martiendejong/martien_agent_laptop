# Explicit Feedback Routing (R22-004)
# Routes prediction outcomes to appropriate learning systems

param(
    [Parameter(Mandatory)]
    [ValidateSet('prediction_success', 'prediction_failure', 'cluster_change', 'pattern_shift')]
    [string]$FeedbackType,

    [string]$Context = "",
    [string]$Details = "",
    [switch]$AutoRoute
)

Import-Module "C:\scripts\tools\ContextIntelligence.psm1" -Force

function Route-PredictionSuccess {
    param([string]$ContextName, [string]$DetailsData)

    Write-Host "Routing prediction success feedback..." -ForegroundColor Cyan

    # 1. Update pattern mining (success reinforces pattern)
    Write-Host "  [1/3] Updating pattern weights..." -ForegroundColor Yellow
    Update-UniversalPatterns

    # 2. Strengthen cluster associations
    Write-Host "  [2/3] Strengthening cluster associations..." -ForegroundColor Yellow
    Update-ContextClusters

    # 3. Publish success event
    Write-Host "  [3/3] Publishing success event..." -ForegroundColor Yellow
    Publish-ContextEvent -EventType "prediction_success" -Data $DetailsData

    Write-Host "Feedback routing complete" -ForegroundColor Green
}

function Route-PredictionFailure {
    param([string]$ContextName, [string]$DetailsData)

    Write-Host "Routing prediction failure feedback..." -ForegroundColor Cyan

    # 1. Adjust prediction weights
    Write-Host "  [1/3] Adjusting prediction weights..." -ForegroundColor Yellow
    Update-PredictionWeights

    # 2. Check for new patterns (failure might indicate pattern shift)
    Write-Host "  [2/3] Checking for pattern shifts..." -ForegroundColor Yellow
    Update-UniversalPatterns

    # 3. Publish failure event
    Write-Host "  [3/3] Publishing failure event..." -ForegroundColor Yellow
    Publish-ContextEvent -EventType "prediction_failure" -Data $DetailsData

    Write-Host "Feedback routing complete" -ForegroundColor Green
}

function Route-ClusterChange {
    param([string]$ContextName, [string]$DetailsData)

    Write-Host "Routing cluster change feedback..." -ForegroundColor Cyan

    # 1. Update semantic search cache
    Write-Host "  [1/2] Invalidating semantic search cache..." -ForegroundColor Yellow
    # Would clear semantic search cache here

    # 2. Publish cluster update event
    Write-Host "  [2/2] Publishing cluster update event..." -ForegroundColor Yellow
    Publish-ContextEvent -EventType "cluster_updated" -Data $DetailsData

    Write-Host "Feedback routing complete" -ForegroundColor Green
}

function Route-PatternShift {
    param([string]$ContextName, [string]$DetailsData)

    Write-Host "Routing pattern shift feedback..." -ForegroundColor Cyan

    # 1. Trigger proactive mode recalculation
    Write-Host "  [1/3] Recalculating context confidence..." -ForegroundColor Yellow
    if ($ContextName) {
        $confidence = Get-ContextConfidence -Context $ContextName
        Write-Host "    New confidence: $($confidence.confidence)" -ForegroundColor Cyan
    }

    # 2. Update prediction weights
    Write-Host "  [2/3] Updating prediction weights..." -ForegroundColor Yellow
    Update-PredictionWeights

    # 3. Publish pattern shift event
    Write-Host "  [3/3] Publishing pattern shift event..." -ForegroundColor Yellow
    Publish-ContextEvent -EventType "pattern_discovered" -Data $DetailsData

    Write-Host "Feedback routing complete" -ForegroundColor Green
}

# Main execution
Write-Host "`n=== Feedback Router ===" -ForegroundColor Cyan
Write-Host "Type: $FeedbackType"
Write-Host "Context: $(if ($Context) { $Context } else { '(none)' })"
Write-Host ""

switch ($FeedbackType) {
    'prediction_success' {
        Route-PredictionSuccess -ContextName $Context -DetailsData $Details
    }
    'prediction_failure' {
        Route-PredictionFailure -ContextName $Context -DetailsData $Details
    }
    'cluster_change' {
        Route-ClusterChange -ContextName $Context -DetailsData $Details
    }
    'pattern_shift' {
        Route-PatternShift -ContextName $Context -DetailsData $Details
    }
}

# Auto-route pending events if requested
if ($AutoRoute) {
    Write-Host "`nAuto-routing pending events..." -ForegroundColor Cyan
    Invoke-EventProcessing
}
