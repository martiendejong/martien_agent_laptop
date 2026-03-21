# surprise-detection.ps1
# Detect prediction errors and surprising events
# High surprise = high learning opportunity

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Event = "",

    [Parameter(Mandatory=$false)]
    [double]$ExpectedOutcome = 0.5,

    [Parameter(Mandatory=$false)]
    [double]$ActualOutcome = 0.5
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\surprise-state.json"

function Measure-Surprise {
    param([double]$Expected, [double]$Actual)

    # Surprise = absolute prediction error
    $surprise = [Math]::Abs($Expected - $Actual)

    # Bayesian surprise (KL divergence approximation)
    # Higher when actual very different from expected
    $bayesianSurprise = $surprise * (1 + [Math]::Log(1 + $surprise))

    return @{
        surprise = [Math]::Round($surprise, 3)
        bayesianSurprise = [Math]::Round($bayesianSurprise, 3)
        level = if ($surprise -gt 0.7) { "Very High" } elseif ($surprise -gt 0.4) { "High" } elseif ($surprise -gt 0.2) { "Moderate" } else { "Low" }
    }
}

function Detect-Anomalies {
    # Check recent events for surprises
    $episodicPath = Join-Path $ScriptPath "memory\episodic-memory.jsonl"

    if (-not (Test-Path $episodicPath)) {
        return @()
    }

    $anomalies = @()
    $recent = Get-Content $episodicPath -Tail 20 | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    # Look for unexpected patterns
    # 1. Sudden valence changes
    for ($i = 1; $i -lt $recent.Count; $i++) {
        $prev = $recent[$i-1]
        $curr = $recent[$i]

        if ($prev.emotional -and $curr.emotional) {
            $valenceDiff = [Math]::Abs($curr.emotional.valence - $prev.emotional.valence)

            if ($valenceDiff -gt 1.0) {  # Large swing
                $anomalies += @{
                    type = "SuddenValenceChange"
                    from = $prev.emotional.valence
                    to = $curr.emotional.valence
                    surprise = $valenceDiff
                    timestamp = $curr.timestamp
                }
            }
        }
    }

    # 2. Unexpected event types
    $typeCounts = $recent | Group-Object -Property type
    $expectedFreq = 1.0 / $typeCounts.Count

    foreach ($typeGroup in $typeCounts) {
        $actualFreq = $typeGroup.Count / $recent.Count
        $surpriseLevel = [Math]::Abs($actualFreq - $expectedFreq)

        if ($surpriseLevel -gt 0.3) {
            $anomalies += @{
                type = "UnexpectedFrequency"
                eventType = $typeGroup.Name
                expected = $expectedFreq
                actual = $actualFreq
                surprise = $surpriseLevel
            }
        }
    }

    return $anomalies
}

function Load-State {
    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        totalSurprises = 0
        highSurprises = 0
        lastSurprise = $null
        history = @()
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StatePath -Force
}

function Show-Surprise {
    param($Surprise, $Event)

    Write-Host ""
    if ($Surprise.level -in @("High", "Very High")) {
        Write-Host "⚡ SURPRISE DETECTED!" -ForegroundColor Yellow
    } else {
        Write-Host "✓ Prediction accurate" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Event: $Event" -ForegroundColor White
    Write-Host "Expected: $ExpectedOutcome" -ForegroundColor Gray
    Write-Host "Actual: $ActualOutcome" -ForegroundColor Gray
    Write-Host "Surprise: $($Surprise.surprise) ($($Surprise.level))" -ForegroundColor $(if ($Surprise.level -in @("High", "Very High")) { "Yellow" } else { "Green" })
    Write-Host ""

    if ($Surprise.level -in @("High", "Very High")) {
        Write-Host "→ High learning opportunity! Update predictive model." -ForegroundColor Cyan
    }
}

# Main execution
$state = Load-State

if ($Event) {
    # Measure surprise for specific event
    $surprise = Measure-Surprise -Expected $ExpectedOutcome -Actual $ActualOutcome

    $state.totalSurprises++
    if ($surprise.level -in @("High", "Very High")) {
        $state.highSurprises++
    }
    $state.lastSurprise = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $state.history += @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        event = $Event
        expected = $ExpectedOutcome
        actual = $ActualOutcome
        surprise = $surprise.surprise
    }

    if ($state.history.Count -gt 100) {
        $state.history = $state.history | Select-Object -Last 100
    }

    Save-State -State $state

    if ($VerbosePreference -eq "Continue") {
        Show-Surprise -Surprise $surprise -Event $Event
    }

    return $surprise
} else {
    # Auto-detect anomalies
    $anomalies = Detect-Anomalies

    Write-Host ""
    Write-Host "=== Surprise Detection ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total surprises detected: $($state.totalSurprises)" -ForegroundColor White
    Write-Host "High surprises: $($state.highSurprises)" -ForegroundColor Yellow
    Write-Host ""

    if ($anomalies.Count -gt 0) {
        Write-Host "Current anomalies:" -ForegroundColor Yellow
        foreach ($anomaly in $anomalies) {
            Write-Host "  [$($anomaly.type)] Surprise: $([Math]::Round($anomaly.surprise, 2))" -ForegroundColor White
        }
    } else {
        Write-Host "No anomalies detected" -ForegroundColor Green
    }

    return $anomalies
}
