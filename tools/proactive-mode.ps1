# Proactive vs Reactive Mode Switching (R21-004)
# Switches behavior based on context confidence

param(
    [switch]$CheckMode,
    [switch]$GetConfidence,
    [string]$Context
)

$ConfidencePath = "C:\scripts\_machine\context-confidence.yaml"

function Get-ContextConfidence {
    param([string]$ContextName)

    # Calculate confidence based on multiple signals
    $signals = @{
        historical_accuracy = 0.0
        pattern_match = 0.0
        recency = 0.0
        frequency = 0.0
    }

    # Load prediction weights if available
    $weightsFile = "C:\scripts\_machine\prediction-weights.yaml"
    if (Test-Path $weightsFile) {
        $weights = Get-Content $weightsFile -Raw | ConvertFrom-Yaml
        if ($weights.meta.accuracy) {
            $signals.historical_accuracy = $weights.meta.accuracy
        }
    }

    # Check pattern match
    $patternsFile = "C:\scripts\_machine\universal-patterns.yaml"
    if (Test-Path $patternsFile) {
        $patterns = Get-Content $patternsFile -Raw | ConvertFrom-Yaml
        # Simple heuristic: if context matches common patterns, increase confidence
        $matchFound = $false
        foreach ($ctx in $patterns.patterns.contextual) {
            if ($ctx.context -match $ContextName) {
                $matchFound = $true
                break
            }
        }
        $signals.pattern_match = if ($matchFound) { 0.8 } else { 0.3 }
    }

    # Check recency (has this context been used recently?)
    $eventLog = "C:\scripts\logs\conversation-events.log.jsonl"
    if (Test-Path $eventLog) {
        $recentEvents = Get-Content $eventLog -Tail 100 | ForEach-Object {
            try { $_ | ConvertFrom-Json } catch { $null }
        } | Where-Object { $_ -ne $null }

        $recentContextMentions = ($recentEvents | Where-Object { $_.context -match $ContextName }).Count
        $signals.recency = [math]::Min($recentContextMentions / 10.0, 1.0)
    }

    # Overall confidence (weighted average)
    $confidence = (
        $signals.historical_accuracy * 0.3 +
        $signals.pattern_match * 0.3 +
        $signals.recency * 0.4
    )

    return @{
        context = $ContextName
        confidence = [math]::Round($confidence, 3)
        signals = $signals
    }
}

function Get-CurrentMode {
    param([double]$Confidence)

    $threshold = 0.8

    if ($Confidence -ge $threshold) {
        return @{
            mode = "PROACTIVE"
            description = "High confidence - anticipate needs, preload context"
            actions = @(
                "Preload related contexts",
                "Suggest next steps",
                "Auto-prepare common operations"
            )
        }
    }
    else {
        return @{
            mode = "REACTIVE"
            description = "Lower confidence - wait for explicit requests"
            actions = @(
                "Wait for user input",
                "Respond to direct questions",
                "Load context on demand"
            )
        }
    }
}

# Main execution
if ($GetConfidence -and $Context) {
    $result = Get-ContextConfidence -ContextName $Context
    $result | ConvertTo-Json -Depth 3
}
elseif ($CheckMode -and $Context) {
    $confidence = Get-ContextConfidence -ContextName $Context
    $mode = Get-CurrentMode -Confidence $confidence.confidence

    Write-Host "`n=== Mode Determination for '$Context' ===" -ForegroundColor Cyan
    Write-Host "Confidence: $($confidence.confidence)"
    Write-Host "Mode: $($mode.mode)`n" -ForegroundColor $(if ($mode.mode -eq "PROACTIVE") { "Green" } else { "Yellow" })
    Write-Host "Description: $($mode.description)`n"
    Write-Host "Actions:" -ForegroundColor Yellow
    $mode.actions | ForEach-Object { Write-Host "  - $_" }
}
else {
    Write-Host "Usage: proactive-mode.ps1 [-CheckMode] [-GetConfidence] -Context <name>"
    Write-Host "  -CheckMode -Context <name>      : Determine current mode for context"
    Write-Host "  -GetConfidence -Context <name>  : Get confidence score (JSON)"
}
