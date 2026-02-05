# Resilient Tool Wrapper - Combines all resilience features
# Uses circuit breakers, bounded queues, graceful degradation

param(
    [Parameter(Mandatory)]
    [string]$Tool,

    [Parameter(Mandatory)]
    [string]$Operation,

    [hashtable]$Parameters = @{},
    [switch]$AllowDegradedMode
)

$MaxEventQueueSize = 1000
$MinAccuracyThreshold = 0.3

function Test-CircuitOpen {
    param([string]$ToolName)

    $status = & "C:\scripts\tools\circuit-breaker.ps1" -ToolName $ToolName -CheckStatus | ConvertFrom-Json
    return $status.state -eq "OPEN"
}

function Invoke-WithCircuitBreaker {
    param(
        [string]$ToolName,
        [scriptblock]$Action
    )

    # Check circuit status
    if (Test-CircuitOpen -ToolName $ToolName) {
        Write-Host "Circuit breaker OPEN for $ToolName - using fallback" -ForegroundColor Yellow

        if (!$AllowDegradedMode) {
            throw "Tool $ToolName is disabled and degraded mode not allowed"
        }

        return Invoke-FallbackOperation -Tool $ToolName
    }

    # Try to execute
    try {
        $result = & $Action

        # Record success
        & "C:\scripts\tools\circuit-breaker.ps1" -ToolName $ToolName -RecordSuccess | Out-Null

        return $result
    }
    catch {
        Write-Host "Tool execution failed: $_" -ForegroundColor Red

        # Record failure
        & "C:\scripts\tools\circuit-breaker.ps1" -ToolName $ToolName -RecordFailure | Out-Null

        # Try fallback if allowed
        if ($AllowDegradedMode) {
            Write-Host "Attempting fallback operation..." -ForegroundColor Yellow
            return Invoke-FallbackOperation -Tool $ToolName
        }
        else {
            throw
        }
    }
}

function Invoke-FallbackOperation {
    param([string]$Tool)

    Write-Host "Using degraded mode for $Tool" -ForegroundColor Yellow

    switch ($Tool) {
        "prediction" {
            # Fallback: Use simple time-of-day heuristic
            $hour = (Get-Date).Hour
            if ($hour -ge 9 -and $hour -lt 12) {
                return @{ context = "debug"; confidence = 0.5; method = "time_heuristic" }
            }
            elseif ($hour -ge 14 -and $hour -lt 18) {
                return @{ context = "feature"; confidence = 0.5; method = "time_heuristic" }
            }
            else {
                return @{ context = "unknown"; confidence = 0.3; method = "time_heuristic" }
            }
        }

        "clustering" {
            # Fallback: Return empty clusters
            return @{ clusters = @{}; method = "empty_fallback" }
        }

        "pattern_mining" {
            # Fallback: Return default patterns
            return @{
                patterns = @{
                    workflow = @{ debug = 0; feature = 0; refactor = 0; docs = 0 }
                }
                method = "default_fallback"
            }
        }

        default {
            return @{ status = "degraded"; method = "null_fallback" }
        }
    }
}

function Invoke-BoundedEventQueue {
    param([scriptblock]$Action)

    $store = Get-Content "C:\scripts\_machine\knowledge-store.yaml" -Raw | ConvertFrom-Yaml

    # Check queue size
    if ($store.events.queue.Count -ge $MaxEventQueueSize) {
        Write-Host "Event queue at capacity ($MaxEventQueueSize), trimming..." -ForegroundColor Yellow

        # Drop oldest events
        $store.events.queue = $store.events.queue |
            Sort-Object timestamp -Descending |
            Select-Object -First $MaxEventQueueSize

        $store | ConvertTo-Yaml | Out-File -FilePath "C:\scripts\_machine\knowledge-store.yaml" -Encoding UTF8
    }

    & $Action
}

function Test-PredictionHealth {
    $store = Get-Content "C:\scripts\_machine\knowledge-store.yaml" -Raw | ConvertFrom-Yaml

    if ($store.predictions.accuracy.overall_accuracy -lt $MinAccuracyThreshold) {
        Write-Host "Prediction accuracy below threshold ($($store.predictions.accuracy.overall_accuracy) < $MinAccuracyThreshold)" -ForegroundColor Red
        Write-Host "Resetting weights to defaults..." -ForegroundColor Yellow

        # Reset weights
        $store.predictions.weights = @{
            time_of_day = 1.0
            recent_files = 1.5
            conversation_intent = 1.2
            markov_chain = 1.0
            project_context = 1.3
            semantic_similarity = 1.1
        }

        $store | ConvertTo-Yaml | Out-File -FilePath "C:\scripts\_machine\knowledge-store.yaml" -Encoding UTF8
        Write-Host "Weights reset to defaults" -ForegroundColor Green
    }
}

# Main execution
Write-Host "Invoking resilient tool: $Tool.$Operation" -ForegroundColor Cyan

$result = Invoke-WithCircuitBreaker -ToolName $Tool -Action {
    switch ($Operation) {
        "predict" {
            Import-Module "C:\scripts\tools\ContextIntelligence.psm1" -Force
            Get-ContextPrediction @Parameters
        }
        "cluster" {
            Invoke-BoundedEventQueue {
                Import-Module "C:\scripts\tools\ContextIntelligence.psm1" -Force
                Update-ContextClusters
            }
        }
        "mine_patterns" {
            Import-Module "C:\scripts\tools\ContextIntelligence.psm1" -Force
            Update-UniversalPatterns
        }
        "check_health" {
            Test-PredictionHealth
        }
        default {
            throw "Unknown operation: $Operation"
        }
    }
}

Write-Host "Operation completed" -ForegroundColor Green
return $result
