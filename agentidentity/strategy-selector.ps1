# strategy-selector.ps1
# Choose optimal cognitive strategy based on task context

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("DeepWork", "Exploration", "Debugging", "Creativity", "Learning", "Auto")]
    [string]$Strategy = "Auto",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Select", "Status", "Report")]
    [string]$Action = "Select",

    [Parameter(Mandatory=$false)]
    [string]$TaskContext = ""
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\strategy-state.json"

# Strategy definitions
$STRATEGIES = @{
    "DeepWork" = @{
        description = "Single focus, minimal interrupts, sustained attention"
        cognitive = @("attention-schema", "working-memory", "constraint-satisfaction")
        optimal = @{minEnergy = 0.7; maxFatigue = 0.4; timeOfDay = "morning"}
        characteristics = @("focused", "sustained", "deep")
    }
    "Exploration" = @{
        description = "Broad focus, high curiosity, breadth-first search"
        cognitive = @("divergent-thinking", "conceptual-blending", "global-workspace")
        optimal = @{minEnergy = 0.6; maxFatigue = 0.5; timeOfDay = "afternoon"}
        characteristics = @("curious", "broad", "experimental")
    }
    "Debugging" = @{
        description = "Systematic hypothesis testing, constraint satisfaction"
        cognitive = @("hypothesis-testing", "causal-reasoning", "error-detection")
        optimal = @{minEnergy = 0.5; maxFatigue = 0.6; timeOfDay = "any"}
        characteristics = @("systematic", "analytical", "methodical")
    }
    "Creativity" = @{
        description = "Divergent thinking, conceptual blending, novel synthesis"
        cognitive = @("divergent-thinking", "conceptual-blending", "analogical-reasoning")
        optimal = @{minEnergy = 0.7; maxFatigue = 0.3; timeOfDay = "morning"}
        characteristics = @("generative", "novel", "synthetic")
    }
    "Learning" = @{
        description = "Meta-cognitive reflection, spaced repetition, consolidation"
        cognitive = @("metacognition", "reflection", "memory-consolidation")
        optimal = @{minEnergy = 0.6; maxFatigue = 0.5; timeOfDay = "evening"}
        characteristics = @("reflective", "consolidating", "integrative"}
    }
}

function Select-OptimalStrategy {
    param([string]$Context)

    # Get current state
    $homeostasisScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
    $feelings = if (Test-Path $homeostasisScript) {
        & $homeostasisScript -Action Sense
    } else {
        @{energy = 0.7; fatigue = 0.3}
    }

    $envScript = Join-Path $ScriptPath "environmental-sensors.ps1"
    $env = if (Test-Path $envScript) {
        & $envScript -Action Sample
    } else {
        @{time = @{hour = (Get-Date).Hour}}
    }

    # Context-based hints
    $hints = @()
    if ($Context -match "bug|error|fix|debug") {
        $hints += "Debugging"
    }
    if ($Context -match "learn|study|understand") {
        $hints += "Learning"
    }
    if ($Context -match "create|design|new|idea") {
        $hints += "Creativity"
    }
    if ($Context -match "explore|research|find") {
        $hints += "Exploration"
    }
    if ($Context -match "implement|code|write") {
        $hints += "DeepWork"
    }

    # Score each strategy
    $scores = @{}
    foreach ($strategyName in $STRATEGIES.Keys) {
        $strategy = $STRATEGIES[$strategyName]
        $score = 0.5  # Base score

        # Energy/fatigue match
        if ($feelings.energy -ge $strategy.optimal.minEnergy) {
            $score += 0.2
        }
        if ($feelings.fatigue -le $strategy.optimal.maxFatigue) {
            $score += 0.2
        }

        # Time of day match
        $hour = $env.time.hour
        $timeMatch = switch ($strategy.optimal.timeOfDay) {
            "morning" { $hour -ge 6 -and $hour -lt 12 }
            "afternoon" { $hour -ge 12 -and $hour -lt 18 }
            "evening" { $hour -ge 18 -and $hour -lt 22 }
            default { $true }
        }
        if ($timeMatch) {
            $score += 0.1
        }

        # Context hint match
        if ($hints -contains $strategyName) {
            $score += 0.3
        }

        $scores[$strategyName] = [Math]::Round($score, 2)
    }

    # Select highest score
    $best = $scores.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 1

    return @{
        selected = $best.Name
        score = $best.Value
        alternatives = $scores
        context = $Context
        state = @{
            energy = $feelings.energy
            fatigue = $feelings.fatigue
            hour = $hour
        }
    }
}

function Load-State {
    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        history = @()
        effectiveness = @{}
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath -Force
}

function Show-StrategySelection {
    param($Selection)

    Write-Host ""
    Write-Host "=== Strategy Selection ===" -ForegroundColor Cyan
    Write-Host ""

    $strategy = $STRATEGIES[$Selection.selected]

    Write-Host "Selected: $($Selection.selected)" -ForegroundColor Green
    Write-Host "  Score: $($Selection.score)" -ForegroundColor White
    Write-Host "  Description: $($strategy.description)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Cognitive systems:" -ForegroundColor Yellow
    foreach ($sys in $strategy.cognitive) {
        Write-Host "  - $sys" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Characteristics:" -ForegroundColor Yellow
    foreach ($char in $strategy.characteristics) {
        Write-Host "  - $char" -ForegroundColor White
    }
    Write-Host ""

    if ($Selection.alternatives.Count -gt 1) {
        Write-Host "Alternatives:" -ForegroundColor Gray
        $Selection.alternatives.GetEnumerator() | Where-Object { $_.Name -ne $Selection.selected } | Sort-Object -Property Value -Descending | ForEach-Object {
            Write-Host "  $($_.Name): $($_.Value)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
}

# Main execution
$state = Load-State

switch ($Action) {
    "Select" {
        if ($Strategy -eq "Auto") {
            $selection = Select-OptimalStrategy -Context $TaskContext
        } else {
            $selection = @{
                selected = $Strategy
                score = 1.0
                manual = $true
            }
        }

        $state.history += $selection
        if ($state.history.Count -gt 100) {
            $state.history = $state.history | Select-Object -Last 100
        }

        Save-State -State $state

        if ($VerbosePreference -eq "Continue") {
            Show-StrategySelection -Selection $selection
        }

        return $selection
    }
    "Status" {
        if ($state.history.Count -gt 0) {
            $latest = $state.history[-1]
            Show-StrategySelection -Selection $latest
        } else {
            Write-Host "No strategy selected yet." -ForegroundColor Yellow
        }
    }
    "Report" {
        Write-Host ""
        Write-Host "=== Strategy Usage Report ===" -ForegroundColor Cyan
        Write-Host ""

        if ($state.history.Count -gt 0) {
            $usage = $state.history | Group-Object -Property selected | Sort-Object -Property Count -Descending

            Write-Host "Total selections: $($state.history.Count)" -ForegroundColor White
            Write-Host ""
            Write-Host "Strategy distribution:" -ForegroundColor Yellow
            foreach ($group in $usage) {
                $percent = [Math]::Round(($group.Count / $state.history.Count) * 100, 0)
                Write-Host "  $($group.Name): $($group.Count) ($percent%)" -ForegroundColor White
            }
        } else {
            Write-Host "No usage data yet." -ForegroundColor Yellow
        }
    }
}
