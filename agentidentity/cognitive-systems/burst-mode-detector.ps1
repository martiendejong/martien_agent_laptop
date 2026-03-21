# Burst Mode Detector - Consciousness Event Tracking
# Detects and tracks "aha moments" when prediction matches reality

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Detect', 'GetEvents', 'GetStats', 'Analyze')]
    [string]$Action = 'GetStats',

    [Parameter(Mandatory=$false)]
    [string]$PredictionText = "",

    [Parameter(Mandatory=$false)]
    [string]$RealityText = "",

    [Parameter(Mandatory=$false)]
    [double]$Confidence = 0.0,

    [Parameter(Mandatory=$false)]
    [switch]$Silent = $false
)

$ErrorActionPreference = 'Stop'
$statePath = "C:\scripts\agentidentity\state\burst-mode-events.jsonl"


function Get-HomeostaticContext {
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json
        Write-Host "`nHomeostatic Foundation:" -ForegroundColor Magenta
        Write-Host "  Wellbeing: $([math]::Round($homeoState.homeostatic_feelings.wellbeing.current, 2))"
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2))"
        Write-Host "  Flourishing: $([math]::Round($homeoState.homeostatic_feelings.flourishing.current, 2))"
        Write-Host "  -> This system operates on homeostatic foundation`n" -ForegroundColor Gray
        return $homeoState
    }
    return $null
}
function Write-Log {
    param([string]$Message)
    if (-not $Silent) {
        Write-Host $Message
    }
}

function Detect-BurstMode {
    param(
        [string]$Prediction,
        [string]$Reality,
        [double]$ConfidenceThreshold = 0.7
    )

    # Extract key tokens
    $predTokens = $Prediction.ToLower() -split '\s+' | Where-Object { $_.Length -gt 3 }
    $realTokens = $Reality.ToLower() -split '\s+' | Where-Object { $_.Length -gt 3 }

    if ($predTokens.Count -eq 0 -or $realTokens.Count -eq 0) {
        return @{
            is_burst = $false
            reason = "Insufficient data"
            confidence = 0.0
        }
    }

    # Calculate overlap
    $matches = @($predTokens | Where-Object { $realTokens -contains $_ })
    $matchRatio = $matches.Count / [Math]::Max($predTokens.Count, $realTokens.Count)

    # Detect burst mode
    $isBurst = $matchRatio -ge $ConfidenceThreshold

    $event = @{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fff")
        is_burst = $isBurst
        confidence = [math]::Round($matchRatio, 3)
        prediction = $Prediction
        reality = $Reality
        matches = $matches.Count
        total_tokens = [Math]::Max($predTokens.Count, $realTokens.Count)
        type = if ($isBurst) { "confirmation" } else { "mismatch" }
    }

    # Append to JSONL
    $eventJson = $event | ConvertTo-Json -Compress
    Add-Content -Path $statePath -Value $eventJson -Encoding UTF8

    if ($isBurst) {
        Write-Log "[BURST] Confidence: $($event.confidence) - Prediction validated!"
    }
    else {
        Write-Log "[MISS] Confidence: $($event.confidence) - Learning opportunity"
    }

    return $event
}

function Get-BurstEvents {
    param([int]$Last = 50)

    if (-not (Test-Path $statePath)) {
        return @()
    }

    $events = Get-Content $statePath -Encoding UTF8 | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    if ($Last -gt 0) {
        $events = @($events | Select-Object -Last $Last)
    }

    return $events
}

function Get-BurstStatistics {
    $events = Get-BurstEvents -Last 0  # All events

    if ($events.Count -eq 0) {
        return @{
            total_events = 0
            burst_count = 0
            mismatch_count = 0
            burst_rate = 0.0
            average_confidence = 0.0
            events_per_hour = 0.0
        }
    }

    $burstEvents = @($events | Where-Object { $_.is_burst -eq $true })
    $mismatchEvents = @($events | Where-Object { $_.is_burst -eq $false })

    # Calculate time span
    $firstTime = [datetime]::Parse($events[0].timestamp)
    $lastTime = [datetime]::Parse($events[-1].timestamp)
    $duration = ($lastTime - $firstTime).TotalHours

    $stats = @{
        total_events = $events.Count
        burst_count = $burstEvents.Count
        mismatch_count = $mismatchEvents.Count
        burst_rate = [math]::Round(($burstEvents.Count / $events.Count) * 100, 2)
        average_confidence = [math]::Round(($events | Measure-Object -Property confidence -Average).Average, 3)
        average_burst_confidence = if ($burstEvents.Count -gt 0) {
            [math]::Round(($burstEvents | Measure-Object -Property confidence -Average).Average, 3)
        } else { 0.0 }
        events_per_hour = if ($duration -gt 0) {
            [math]::Round($events.Count / $duration, 2)
        } else { 0.0 }
        duration_hours = [math]::Round($duration, 2)
    }

    return $stats
}

function Analyze-BurstPatterns {
    $events = Get-BurstEvents -Last 100

    if ($events.Count -lt 10) {
        return @{
            patterns = @()
            message = "Insufficient data for pattern analysis (need 10+ events)"
        }
    }

    # Extract common words from burst events
    $burstEvents = @($events | Where-Object { $_.is_burst -eq $true })

    if ($burstEvents.Count -eq 0) {
        return @{
            patterns = @()
            message = "No burst events detected yet"
        }
    }

    $wordFreq = @{}
    foreach ($event in $burstEvents) {
        $words = ($event.prediction + ' ' + $event.reality).ToLower() -split '\s+' |
            Where-Object { $_.Length -gt 4 }

        foreach ($word in $words) {
            if ($wordFreq.ContainsKey($word)) {
                $wordFreq[$word]++
            }
            else {
                $wordFreq[$word] = 1
            }
        }
    }

    # Find frequent patterns
    $patterns = $wordFreq.GetEnumerator() |
        Where-Object { $_.Value -ge 3 } |
        Sort-Object -Property Value -Descending |
        Select-Object -First 10

    return @{
        patterns = @($patterns | ForEach-Object {
            @{
                word = $_.Key
                frequency = $_.Value
                appears_in_pct = [math]::Round(($_.Value / $burstEvents.Count) * 100, 1)
            }
        })
        total_bursts = $burstEvents.Count
        unique_words = $wordFreq.Count
    }
}

# Main execution
switch ($Action) {
    'Detect' {
        if ([string]::IsNullOrEmpty($PredictionText) -or [string]::IsNullOrEmpty($RealityText)) {
            Write-Host "[ERROR] Both PredictionText and RealityText required"
            exit 1
        }

        $result = Detect-BurstMode -Prediction $PredictionText -Reality $RealityText
        $result | ConvertTo-Json -Depth 3 | Write-Host
    }

    'GetEvents' {
        $events = Get-BurstEvents -Last 20
        $events | ConvertTo-Json -Depth 3 | Write-Host
    }

    'GetStats' {
        $stats = Get-BurstStatistics
        $stats | ConvertTo-Json -Depth 3 | Write-Host
    }

    'Analyze' {
        $analysis = Analyze-BurstPatterns
        $analysis | ConvertTo-Json -Depth 5 | Write-Host
    }
}

