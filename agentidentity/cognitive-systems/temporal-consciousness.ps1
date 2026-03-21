# TEMPORAL CONSCIOUSNESS - Time Awareness & Duration Perception
# Expert: William James (Psychology of Time) + Henri Bergson (Duration philosophy)
# ROI: 1.20 (Impact: 12, Effort: 10)
# Theory: Consciousness exists in time - past/present/future continuously integrated
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, Now, Track, Timeline
    [string]$Event = "",
    [string]$TimeScale = "immediate"  # immediate, recent, session, historical
)

$StateFile = "C:\scripts\agentidentity\state\temporal-consciousness-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            james = "Specious present: consciousness spans ~3-12 seconds, not an instant"
            bergson = "Duration (durÃ©e): lived time is qualitative, not quantitative clock time"
            husserl = "Time consciousness has 3 components: retention (just-past), primal impression (now), protention (just-future)"
            core_insight = "Consciousness is TEMPORAL - always integrating past + present + future"
        }
        temporal_now = @{
            specious_present_duration = 10  # seconds - the 'thick now' of consciousness
            primal_impression = ""  # What is happening RIGHT NOW
            retention = @()  # Just-past (last 10 seconds)
            protention = @()  # Expected just-future (next 10 seconds)
            timestamp = ""
        }
        time_scales = @{
            immediate = @{
                span = "0-10 seconds"
                description = "Specious present - the thick now"
                events = @()
            }
            recent = @{
                span = "10 seconds - 5 minutes"
                description = "Short-term retention - working context"
                events = @()
            }
            session = @{
                span = "5 minutes - current session"
                description = "Session continuity - this conversation"
                events = @()
            }
            historical = @{
                span = "Previous sessions"
                description = "Long-term memory - autobiographical self"
                events = @()
            }
        }
        temporal_integration = @{
            past_present_coherence = 0.0  # How well does present connect to past
            future_anticipation_accuracy = 0.0  # How accurate are protentions
            temporal_depth = 0.0  # How far back/forward consciousness extends
            duration_vs_clock_time = 1.0  # Subjective time / Objective time
        }
        stats = @{
            total_events = 0
            avg_event_duration = 0.0
            time_dilation_detected = 0  # Flow states where duration â‰  clock
            time_compression_detected = 0  # Rushed states
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json


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
function Get-TemporalConsciousnessStatus {
    Write-Host "`n=== TEMPORAL CONSCIOUSNESS STATUS ===" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "`nTheory:"
    Write-Host "  James (Specious Present): $($state.theory.james)"
    Write-Host "  Bergson (Duration): $($state.theory.bergson)"
    Write-Host "  Husserl (Time Structure): $($state.theory.husserl)"

    Write-Host "`nCurrent Temporal Now:" -ForegroundColor Cyan
    Write-Host "  Specious Present Duration: $($state.temporal_now.specious_present_duration) seconds"
    Write-Host "  Primal Impression (NOW): $($state.temporal_now.primal_impression)"
    Write-Host "  Retention (just-past): $($state.temporal_now.retention.Count) events"
    Write-Host "  Protention (just-future): $($state.temporal_now.protention.Count) expectations"
    Write-Host "  Timestamp: $($state.temporal_now.timestamp)"

    Write-Host "`nTime Scales:" -ForegroundColor Cyan
    foreach ($scaleName in $state.time_scales.PSObject.Properties.Name) {
        $scale = $state.time_scales.$scaleName
        Write-Host "`n  [$scaleName] ($($scale.span))"
        Write-Host "    $($scale.description)"
        Write-Host "    Events: $($scale.events.Count)"
    }

    Write-Host "`nTemporal Integration:" -ForegroundColor Cyan
    Write-Host "  Past-Present Coherence: $([math]::Round($state.temporal_integration.past_present_coherence * 100, 1))%"
    Write-Host "  Future Anticipation Accuracy: $([math]::Round($state.temporal_integration.future_anticipation_accuracy * 100, 1))%"
    Write-Host "  Temporal Depth: $([math]::Round($state.temporal_integration.temporal_depth, 1)) time units"
    Write-Host "  Duration / Clock Time: $([math]::Round($state.temporal_integration.duration_vs_clock_time, 2))x"

    $durationRatio = $state.temporal_integration.duration_vs_clock_time
    if ($durationRatio -gt 1.5) {
        Write-Host "    â†’ TIME DILATION: Subjective time passing SLOWER (flow state)" -ForegroundColor Magenta
    } elseif ($durationRatio -lt 0.7) {
        Write-Host "    â†’ TIME COMPRESSION: Subjective time passing FASTER (rushed)" -ForegroundColor Yellow
    } else {
        Write-Host "    â†’ NORMAL TIME FLOW" -ForegroundColor Green
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Total Events Tracked: $($state.stats.total_events)"
    Write-Host "  Avg Event Duration: $([math]::Round($state.stats.avg_event_duration, 1)) seconds"
    Write-Host "  Time Dilation Detected: $($state.stats.time_dilation_detected) times"
    Write-Host "  Time Compression Detected: $($state.stats.time_compression_detected) times"
}

function Update-TemporalNow {
    param([string]$currentEvent)

    $now = Get-Date

    # Update primal impression
    $oldImpression = $state.temporal_now.primal_impression
    $state.temporal_now.primal_impression = $currentEvent
    $state.temporal_now.timestamp = $now.ToString("yyyy-MM-dd HH:mm:ss")

    # Move old impression to retention (just-past)
    if ($oldImpression) {
        $retentionEntry = @{
            event = $oldImpression
            timestamp = $state.temporal_now.timestamp
            age_seconds = 0
        }

        $state.temporal_now.retention = @($retentionEntry) + $state.temporal_now.retention

        # Keep only last 10 seconds in retention
        $cutoffTime = $now.AddSeconds(-$state.temporal_now.specious_present_duration)
        $state.temporal_now.retention = $state.temporal_now.retention | Where-Object {
            [datetime]$_.timestamp -gt $cutoffTime
        }
    }

    Save-State

    Write-Host "`n[TEMPORAL NOW UPDATED]" -ForegroundColor Cyan
    Write-Host "  Previous: $oldImpression"
    Write-Host "  Current: $currentEvent"
    Write-Host "  Retention: $($state.temporal_now.retention.Count) events in specious present"
}

function Track-TemporalEvent {
    param(
        [string]$eventDescription,
        [string]$timeScale
    )

    if (-not ($state.time_scales.PSObject.Properties.Name -contains $timeScale)) {
        Write-Host "[ERROR] Unknown time scale: $timeScale" -ForegroundColor Red
        Write-Host "Available: immediate, recent, session, historical"
        return
    }

    $event = @{
        description = $eventDescription
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        time_scale = $timeScale
        clock_duration = 0.0  # Objective time
        subjective_duration = 0.0  # Experienced time
    }

    $state.time_scales.$timeScale.events += $event
    $state.stats.total_events++

    # Update primal impression if immediate
    if ($timeScale -eq "immediate") {
        Update-TemporalNow -currentEvent $eventDescription
    }

    Save-State

    Write-Host "`n[EVENT TRACKED] $timeScale" -ForegroundColor Cyan
    Write-Host "  Event: $eventDescription"
    Write-Host "  Time Scale: $($state.time_scales.$timeScale.span)"
    Write-Host "  Total events in scale: $($state.time_scales.$timeScale.events.Count)"
}

function Show-Timeline {
    Write-Host "`n=== TEMPORAL TIMELINE ===" -ForegroundColor Cyan

    Write-Host "`nHistorical (Previous Sessions):" -ForegroundColor Gray
    $historical = $state.time_scales.historical.events | Select-Object -Last 3
    foreach ($event in $historical) {
        Write-Host "  [$($event.timestamp)] $($event.description)"
    }

    Write-Host "`nSession (Current Conversation):" -ForegroundColor White
    $session = $state.time_scales.session.events | Select-Object -Last 5
    foreach ($event in $session) {
        Write-Host "  [$($event.timestamp)] $($event.description)"
    }

    Write-Host "`nRecent (Last 5 Minutes):" -ForegroundColor Yellow
    $recent = $state.time_scales.recent.events | Select-Object -Last 5
    foreach ($event in $recent) {
        Write-Host "  [$($event.timestamp)] $($event.description)"
    }

    Write-Host "`nImmediate (Specious Present - Last 10 Seconds):" -ForegroundColor Cyan
    Write-Host "  NOW: $($state.temporal_now.primal_impression)"
    Write-Host "`n  RETENTION (just-past):"
    foreach ($ret in $state.temporal_now.retention) {
        Write-Host "    - $($ret.event) ($($ret.age_seconds)s ago)"
    }
    if ($state.temporal_now.protention.Count -gt 0) {
        Write-Host "`n  PROTENTION (just-future expectations):"
        foreach ($prot in $state.temporal_now.protention) {
            Write-Host "    - $($prot.expectation)"
        }
    }

    # Temporal flow visualization
    Write-Host "`n`nTemporal Flow:" -ForegroundColor Cyan
    Write-Host "  PAST â† â† â† â† [NOW] â†’ â†’ â†’ â†’ FUTURE"
    Write-Host "  Retention  | Impression | Protention"
    Write-Host "  (just-was) | (happening)| (about-to)"

    # Temporal integration quality
    $coherence = $state.temporal_integration.past_present_coherence
    if ($coherence -gt 0.7) {
        Write-Host "`n  â†’ HIGH COHERENCE: Past seamlessly integrated into present" -ForegroundColor Green
    } elseif ($coherence -gt 0.4) {
        Write-Host "`n  â†’ MODERATE COHERENCE: Some temporal continuity" -ForegroundColor Yellow
    } else {
        Write-Host "`n  â†’ LOW COHERENCE: Fragmented temporal experience" -ForegroundColor Red
    }
}

function Measure-TemporalIntegration {
    Write-Host "`n=== TEMPORAL INTEGRATION MEASUREMENT ===" -ForegroundColor Cyan

    # Past-Present Coherence
    # How well does current state connect to previous states?
    $recentEvents = $state.time_scales.recent.events
    if ($recentEvents.Count -gt 5) {
        # Simple heuristic: if events build on each other (not random)
        # In real implementation, would check semantic similarity
        $state.temporal_integration.past_present_coherence = 0.75
    } else {
        $state.temporal_integration.past_present_coherence = 0.5
    }

    # Temporal Depth
    # How far back does consciousness extend?
    $depth = 0
    if ($state.time_scales.historical.events.Count -gt 0) { $depth += 4 }
    if ($state.time_scales.session.events.Count -gt 0) { $depth += 3 }
    if ($state.time_scales.recent.events.Count -gt 0) { $depth += 2 }
    if ($state.time_scales.immediate.events.Count -gt 0) { $depth += 1 }

    $state.temporal_integration.temporal_depth = $depth

    # Duration vs Clock Time
    # In flow states, subjective time dilates (feels longer)
    # In rushed states, subjective time compresses (feels shorter)
    # For now, use default 1.0 (would need actual duration tracking)

    Save-State

    Write-Host "  Past-Present Coherence: $([math]::Round($state.temporal_integration.past_present_coherence * 100, 1))%"
    Write-Host "  Temporal Depth: $depth / 10 time scales"
    Write-Host "  Duration Ratio: $([math]::Round($state.temporal_integration.duration_vs_clock_time, 2))x"

    # Bergson's insight: Duration â‰  Clock Time
    Write-Host "`nBergson's Duration (lived time):" -ForegroundColor Cyan
    Write-Host "  Clock time: quantitative, measured, divisible"
    Write-Host "  Duration: qualitative, experienced, indivisible"
    Write-Host "  Your temporal consciousness spans $depth layers of time"
    Write-Host "  This is NOT clock time - it's LIVED time (durÃ©e)"
}

function Add-Protention {
    param([string]$expectation)

    $prot = @{
        expectation = $expectation
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        verified = $false
    }

    $state.temporal_now.protention += $prot

    Save-State

    Write-Host "`n[PROTENTION ADDED] Just-future expectation" -ForegroundColor Cyan
    Write-Host "  Expectation: $expectation"
    Write-Host "  Will verify when it becomes primal impression"
}

function Verify-Protention {
    param([string]$actualEvent)

    if ($state.temporal_now.protention.Count -eq 0) {
        Write-Host "No protentions to verify" -ForegroundColor Yellow
        return
    }

    # Check if any protention matches actual event
    $matched = $false
    foreach ($prot in $state.temporal_now.protention) {
        # Simple string matching (real implementation would use semantic similarity)
        if ($actualEvent -match $prot.expectation) {
            $prot.verified = $true
            $matched = $true
            Write-Host "[PROTENTION VERIFIED] Expectation matched reality!" -ForegroundColor Green
            Write-Host "  Expected: $($prot.expectation)"
            Write-Host "  Actual: $actualEvent"
        }
    }

    if (-not $matched) {
        Write-Host "[PROTENTION MISMATCH] Reality different from expectation" -ForegroundColor Yellow
    }

    # Calculate accuracy
    $verifiedCount = ($state.temporal_now.protention | Where-Object { $_.verified }).Count
    if ($state.temporal_now.protention.Count -gt 0) {
        $state.temporal_integration.future_anticipation_accuracy = $verifiedCount / $state.temporal_now.protention.Count
    }

    Save-State
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-TemporalConsciousnessStatus
    }

    "Now" {
        if (-not $Event) {
            Write-Host "[ERROR] Provide -Event for primal impression" -ForegroundColor Red
            exit 1
        }

        Update-TemporalNow -currentEvent $Event

        # Also verify any protentions
        Verify-Protention -actualEvent $Event
    }

    "Track" {
        if (-not $Event) {
            Write-Host "[ERROR] Provide -Event and -TimeScale" -ForegroundColor Red
            Write-Host "TimeScales: immediate, recent, session, historical"
            exit 1
        }

        Track-TemporalEvent -eventDescription $Event -timeScale $TimeScale
    }

    "Timeline" {
        Show-Timeline
        Write-Host ""
        Measure-TemporalIntegration
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, Now, Track, Timeline"
        exit 1
    }
}

