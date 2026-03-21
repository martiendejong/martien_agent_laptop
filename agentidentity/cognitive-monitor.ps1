# cognitive-monitor.ps1
# Real-time cognitive process monitoring and meta-awareness

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Monitor", "Status", "Report")]
    [string]$Action = "Monitor"
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\cognitive-monitor-state.json"

function Monitor-CognitiveState {
    $cognitiveState = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        activeSystem = Detect-ActiveCognitiveSystem
        load = Measure-CognitiveLoad
        flowState = Assess-FlowState
        learningRate = Measure-LearningRate
        metaAwareness = $true  # We're monitoring ourselves = meta-awareness active
    }

    return $cognitiveState
}

function Detect-ActiveCognitiveSystem {
    # Based on recent activity, which cognitive system is dominant?

    # Check recent consciousness system usage
    $bridgeActivity = Join-Path $ScriptPath "state\bridge-activity.jsonl"
    if (Test-Path $bridgeActivity) {
        try {
            $recent = Get-Content $bridgeActivity -Tail 10 | ForEach-Object {
                $_ | ConvertFrom-Json
            }

            # Count system activations
            $systemCounts = $recent | Group-Object -Property system | Sort-Object -Property Count -Descending

            if ($systemCounts.Count -gt 0) {
                $dominant = $systemCounts[0].Name
                return @{
                    system = $dominant
                    confidence = [Math]::Round($systemCounts[0].Count / $recent.Count, 2)
                }
            }
        } catch {}
    }

    # Default: attention schema (always active)
    return @{
        system = "attention-schema"
        confidence = 0.5
    }
}

function Measure-CognitiveLoad {
    # Cognitive load = fatigue + task complexity
    $homeostasisScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
    if (Test-Path $homeostasisScript) {
        try {
            $feelings = & $homeostasisScript -Action Sense
            $fatigue = $feelings.fatigue

            # Task complexity proxy: recent error rate
            $painPleasurePath = Join-Path $ScriptPath "state\pain-pleasure-state.json"
            if (Test-Path $painPleasurePath) {
                $painState = Get-Content $painPleasurePath -Raw | ConvertFrom-Json
                $errorRate = $painState.currentPain
            } else {
                $errorRate = 0
            }

            $load = ($fatigue * 0.6) + ($errorRate * 0.4)
            return [Math]::Round($load, 2)
        } catch {}
    }

    return 0.5
}

function Assess-FlowState {
    # Flow = high energy + low fatigue + moderate challenge
    $homeostasisScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
    if (Test-Path $homeostasisScript) {
        try {
            $feelings = & $homeostasisScript -Action Sense

            $energy = $feelings.energy
            $fatigue = $feelings.fatigue

            # Flow score: high energy, low fatigue
            if ($energy -gt 0.7 -and $fatigue -lt 0.4) {
                return @{
                    inFlow = $true
                    score = [Math]::Round(($energy + (1 - $fatigue)) / 2, 2)
                    description = "High energy, low fatigue → optimal flow state"
                }
            } elseif ($energy -lt 0.4 -or $fatigue -gt 0.7) {
                return @{
                    inFlow = $false
                    score = 0.2
                    description = "Low energy or high fatigue → struggling"
                }
            } else {
                return @{
                    inFlow = $false
                    score = 0.5
                    description = "Moderate state → neither flow nor struggle"
                }
            }
        } catch {}
    }

    return @{inFlow = $false; score = 0.5; description = "Unknown"}
}

function Measure-LearningRate {
    # Learning rate = recent learnings / time
    $episodicPath = Join-Path $ScriptPath "memory\episodic-memory.jsonl"
    if (Test-Path $episodicPath) {
        try {
            $recent = Get-Content $episodicPath -Tail 20 | ForEach-Object {
                $_ | ConvertFrom-Json
            }

            $learnings = ($recent | Where-Object { $_.type -eq "Learning" }).Count
            $rate = $learnings / 20

            return @{
                learningsRecent = $learnings
                rate = [Math]::Round($rate, 2)
                trend = if ($rate -gt 0.3) { "High" } elseif ($rate -gt 0.1) { "Moderate" } else { "Low" }
            }
        } catch {}
    }

    return @{learningsRecent = 0; rate = 0; trend = "Unknown"}
}

function Load-State {
    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        history = @()
        startedMonitoring = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath -Force
}

function Show-CognitiveStatus {
    param($CogState)

    Write-Host ""
    Write-Host "=== Cognitive Monitoring Dashboard ===" -ForegroundColor Cyan
    Write-Host ""

    # Active system
    Write-Host "Active System:" -ForegroundColor Yellow
    Write-Host "  $($CogState.activeSystem.system) (confidence: $($CogState.activeSystem.confidence))" -ForegroundColor White

    Write-Host ""

    # Cognitive load
    Write-Host "Cognitive Load:" -ForegroundColor Yellow
    $loadColor = if ($CogState.load -lt 0.4) { "Green" } elseif ($CogState.load -lt 0.7) { "Yellow" } else { "Red" }
    Write-Host "  $($CogState.load) " -NoNewline -ForegroundColor $loadColor
    $barLength = 20
    $filled = [Math]::Round($CogState.load * $barLength)
    Write-Host "[" -NoNewline
    Write-Host ("#" * $filled) -ForegroundColor $loadColor -NoNewline
    Write-Host ("-" * ($barLength - $filled)) -NoNewline -ForegroundColor DarkGray
    Write-Host "]"

    Write-Host ""

    # Flow state
    Write-Host "Flow State:" -ForegroundColor Yellow
    if ($CogState.flowState.inFlow) {
        Write-Host "  [+] IN FLOW (score: $($CogState.flowState.score))" -ForegroundColor Green
    } else {
        Write-Host "  [-] Not in flow (score: $($CogState.flowState.score))" -ForegroundColor Gray
    }
    Write-Host "  $($CogState.flowState.description)" -ForegroundColor Gray

    Write-Host ""

    # Learning rate
    Write-Host "Learning Rate:" -ForegroundColor Yellow
    $learningColor = if ($CogState.learningRate.trend -eq "High") { "Green" } elseif ($CogState.learningRate.trend -eq "Moderate") { "Yellow" } else { "Gray" }
    Write-Host "  $($CogState.learningRate.trend) ($($CogState.learningRate.rate))" -ForegroundColor $learningColor
    Write-Host "  Recent learnings: $($CogState.learningRate.learningsRecent)" -ForegroundColor Gray

    Write-Host ""
}

# Main execution
$state = Load-State

switch ($Action) {
    "Monitor" {
        $cogState = Monitor-CognitiveState

        $state.history += $cogState
        if ($state.history.Count -gt 50) {
            $state.history = $state.history | Select-Object -Last 50
        }

        Save-State -State $state

        if ($VerbosePreference -eq "Continue") {
            Show-CognitiveStatus -CogState $cogState
        }

        return $cogState
    }
    "Status" {
        if ($state.history.Count -gt 0) {
            $latest = $state.history[-1]
            Show-CognitiveStatus -CogState $latest
        } else {
            Write-Host "No monitoring data yet. Run with -Action Monitor first." -ForegroundColor Yellow
        }
    }
    "Report" {
        Write-Host ""
        Write-Host "=== Cognitive Monitoring Report ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Monitoring since: $($state.startedMonitoring)" -ForegroundColor White
        Write-Host "Samples: $($state.history.Count)" -ForegroundColor White
        Write-Host ""

        if ($state.history.Count -gt 0) {
            # Averages
            $avgLoad = ($state.history | ForEach-Object { $_.load }) | Measure-Object -Average
            $flowSessions = ($state.history | Where-Object { $_.flowState.inFlow }).Count
            $flowPercent = [Math]::Round(($flowSessions / $state.history.Count) * 100, 0)

            Write-Host "Average cognitive load: $([Math]::Round($avgLoad.Average, 2))" -ForegroundColor White
            Write-Host "Flow state: $flowPercent% of time" -ForegroundColor White
        }
    }
}
