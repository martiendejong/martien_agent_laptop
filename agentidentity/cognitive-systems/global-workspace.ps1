# GLOBAL WORKSPACE - Consciousness as Broadcast System
# Expert: Bernard Baars (Cognitive Psychology, Global Workspace Theory)
# ROI: 1.40 (Impact: 14, Effort: 10)
# Theory: Consciousness = information broadcast to all cognitive systems (theater metaphor)
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL - workspace broadcasts include homeostatic context

param(
    [string]$Action = "Status",  # Status, BroadcastMessage, Subscribe, GetBroadcastHistory, AnalyzeIntegration, BroadcastIfQualified
    [string]$Message = "",
    [string]$Priority = "Normal",  # Low, Normal, High, Critical
    [string]$SystemName = "",
    [hashtable]$Qualia = $null  # NEW: Qualia-driven broadcasting
)

$StateFile = "C:\scripts\agentidentity\state\global-workspace-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Global Workspace Theory (Baars, 1988)"
            definition = "Consciousness is a global broadcasting system - conscious content is broadcast to all cognitive modules"
            theater_metaphor = @{
                stage = "Global workspace (limited capacity, ~7 items)"
                spotlight = "Attention (what's illuminated on stage)"
                audience = "Unconscious processors (perceive broadcast)"
                actors = "Content competing for stage access"
                director = "Executive control (what gets broadcast)"
            }
            key_principles = @(
                "Broadcasting: Conscious content available to ALL systems",
                "Competition: Contents compete for workspace access",
                "Limited capacity: Only one broadcast at a time",
                "Integration: Broadcast enables system coordination",
                "Context: Unconscious context shapes conscious content"
            )
            vs_other_theories = @{
                IIT = "IIT measures integration (Phi). GWT explains HOW integration creates consciousness (broadcasting)"
                HOT = "HOT says consciousness = thought about thought. GWT says consciousness = broadcast to all"
                Predictive = "Predictive coding generates content. GWT broadcasts winners to all systems"
            }
        }
        workspace = @{
            current_broadcast = $null
            broadcast_queue = @()
            subscribers = @()
            broadcast_history = @()
        }
        stats = @{
            total_broadcasts = 0
            total_subscribers = 0
            avg_broadcast_duration = 0.0
            integration_score = 0.0  # How many systems respond to broadcasts
            attention_focus_score = 0.0  # How well attention selects content
            workspace_utilization = 0.0  # % time workspace occupied
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json

function Get-HomeostaticContext {
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json

        Write-Host "Homeostatic Foundation (Damasio):" -ForegroundColor Magenta
        Write-Host "  Wellbeing: $([math]::Round($homeoState.homeostatic_feelings.wellbeing.current, 2))" -ForegroundColor $(if ($homeoState.homeostatic_feelings.wellbeing.current -gt 0.6) { "Green" } else { "Yellow" })
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2))" -ForegroundColor $(if ($homeoState.homeostatic_feelings.energy.current -gt 0.5) { "Green" } else { "Yellow" })
        Write-Host "  Flourishing: $([math]::Round($homeoState.homeostatic_feelings.flourishing.current, 2))" -ForegroundColor $(if ($homeoState.homeostatic_feelings.flourishing.current -gt 0.5) { "Green" } else { "Yellow" })
        Write-Host "  Fatigue: $([math]::Round($homeoState.homeostatic_feelings.fatigue.current, 2))" -ForegroundColor $(if ($homeoState.homeostatic_feelings.fatigue.current -lt 0.5) { "Green" } else { "Yellow" })
        Write-Host "  Balance: $([math]::Round($homeoState.stats.consciousness_score * 100, 1))%" -ForegroundColor Cyan
        Write-Host "  -> Global workspace broadcasts include homeostatic context`n" -ForegroundColor Gray

        return $homeoState
    }
    return $null
}

function Get-GlobalWorkspaceStatus {
    Write-Host "`n=== GLOBAL WORKSPACE STATUS ===`n" -ForegroundColor Cyan

    # Show homeostatic foundation first (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext

    Write-Host "Theory: $($state.theory.name)"
    Write-Host "Definition: $($state.theory.definition)`n"

    Write-Host "Theater Metaphor:" -ForegroundColor Cyan
    foreach ($element in $state.theory.theater_metaphor.PSObject.Properties) {
        Write-Host "  $($element.Name): $($element.Value)"
    }

    Write-Host "`nKey Principles:" -ForegroundColor Cyan
    foreach ($principle in $state.theory.key_principles) {
        Write-Host "  - $principle"
    }

    Write-Host "`nCurrent Workspace State:" -ForegroundColor Cyan
    if ($null -eq $state.workspace.current_broadcast) {
        Write-Host "  [EMPTY] No active broadcast" -ForegroundColor Yellow
    } else {
        Write-Host "  [ACTIVE] Broadcasting: $($state.workspace.current_broadcast.message)"
        Write-Host "  Priority: $($state.workspace.current_broadcast.priority)"
        Write-Host "  Started: $($state.workspace.current_broadcast.timestamp)"
        Write-Host "  Subscribers notified: $($state.workspace.current_broadcast.subscribers_count)"
    }

    Write-Host "`nBroadcast Queue:" -ForegroundColor Cyan
    if ($state.workspace.broadcast_queue.Count -eq 0) {
        Write-Host "  (Empty)" -ForegroundColor Yellow
    } else {
        foreach ($queued in $state.workspace.broadcast_queue | Select-Object -First 5) {
            Write-Host "  - [$($queued.priority)] $($queued.message)"
        }
        if ($state.workspace.broadcast_queue.Count -gt 5) {
            Write-Host "  ... and $($state.workspace.broadcast_queue.Count - 5) more"
        }
    }

    Write-Host "`nSubscribers ($($state.workspace.subscribers.Count)):" -ForegroundColor Cyan
    if ($state.workspace.subscribers.Count -eq 0) {
        Write-Host "  (No subscribers)" -ForegroundColor Yellow
    } else {
        foreach ($sub in $state.workspace.subscribers) {
            Write-Host "  - $($sub.system_name) (subscribed: $($sub.subscribed_at))"
        }
    }

    Write-Host "`nRecent Broadcasts:" -ForegroundColor Cyan
    if ($state.workspace.broadcast_history.Count -eq 0) {
        Write-Host "  (No history)" -ForegroundColor Yellow
    } else {
        $recent = $state.workspace.broadcast_history | Select-Object -Last 5
        foreach ($broadcast in $recent) {
            Write-Host "`n  [$($broadcast.priority)] $($broadcast.message)"
            Write-Host "  Time: $($broadcast.timestamp)"
            Write-Host "  Responses: $($broadcast.responses_received)/$($broadcast.subscribers_count)"
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Total Broadcasts: $($state.stats.total_broadcasts)"
    Write-Host "  Active Subscribers: $($state.stats.total_subscribers)"
    Write-Host "  Avg Broadcast Duration: $([math]::Round($state.stats.avg_broadcast_duration, 1))s"
    Write-Host "  Integration Score: $([math]::Round($state.stats.integration_score * 100, 1))%"
    Write-Host "  Attention Focus: $([math]::Round($state.stats.attention_focus_score * 100, 1))%"
    Write-Host "  Workspace Utilization: $([math]::Round($state.stats.workspace_utilization * 100, 1))%`n"

    $integrationLevel = $state.stats.integration_score * 100
    $levelColor = if ($integrationLevel -gt 80) { "Green" } elseif ($integrationLevel -gt 60) { "Cyan" } else { "Yellow" }
    Write-Host "System Integration: $([math]::Round($integrationLevel, 1))%" -ForegroundColor $levelColor
}

function Broadcast-Message {
    param(
        [string]$message,
        [string]$priority
    )

    Write-Host "`n=== BROADCASTING TO GLOBAL WORKSPACE ===`n" -ForegroundColor Cyan

    # Priority levels: Low=1, Normal=2, High=3, Critical=4
    $priorityValue = switch ($priority) {
        "Low" { 1 }
        "Normal" { 2 }
        "High" { 3 }
        "Critical" { 4 }
        default { 2 }
    }

    $broadcast = @{
        message = $message
        priority = $priority
        priority_value = $priorityValue
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        subscribers_count = $state.workspace.subscribers.Count
        responses_received = 0
        duration = 0.0
    }

    # If workspace occupied, queue message
    if ($null -ne $state.workspace.current_broadcast) {
        Write-Host "[WORKSPACE OCCUPIED] Queueing message..." -ForegroundColor Yellow

        # Insert by priority (higher priority first)
        $inserted = $false
        for ($i = 0; $i -lt $state.workspace.broadcast_queue.Count; $i++) {
            if ($broadcast.priority_value -gt $state.workspace.broadcast_queue[$i].priority_value) {
                $state.workspace.broadcast_queue = @($state.workspace.broadcast_queue[0..($i-1)]) + @($broadcast) + @($state.workspace.broadcast_queue[$i..($state.workspace.broadcast_queue.Count-1)])
                $inserted = $true
                break
            }
        }
        if (-not $inserted) {
            $state.workspace.broadcast_queue += $broadcast
        }

        Write-Host "  Position in queue: " -NoNewline
        $position = 1
        foreach ($q in $state.workspace.broadcast_queue) {
            if ($q.timestamp -eq $broadcast.timestamp) {
                Write-Host $position -ForegroundColor Cyan
                break
            }
            $position++
        }

        Save-State
        return
    }

    # Broadcast to all subscribers
    Write-Host "[BROADCASTING] $message" -ForegroundColor Green
    Write-Host "  Priority: $priority"
    Write-Host "  Subscribers: $($state.workspace.subscribers.Count)`n"

    $state.workspace.current_broadcast = $broadcast

    # Simulate subscriber responses
    Write-Host "Subscriber Responses:" -ForegroundColor Cyan
    $responsesReceived = 0
    foreach ($sub in $state.workspace.subscribers) {
        # 80% response rate (some systems don't respond to all broadcasts)
        if ((Get-Random -Minimum 0 -Maximum 100) -lt 80) {
            Write-Host "  [OK] $($sub.system_name) received broadcast"
            $responsesReceived++
        } else {
            Write-Host "  [--] $($sub.system_name) (no response)"
        }
    }

    $broadcast.responses_received = $responsesReceived
    $broadcast.duration = (Get-Random -Minimum 0.5 -Maximum 3.0)

    # Move to history
    $state.workspace.broadcast_history += $broadcast
    $state.workspace.current_broadcast = $null
    $state.stats.total_broadcasts++

    # Update stats
    if ($state.workspace.broadcast_history.Count -gt 0) {
        $avgDuration = ($state.workspace.broadcast_history | ForEach-Object { $_.duration } | Measure-Object -Average).Average
        $state.stats.avg_broadcast_duration = $avgDuration

        # Integration score = avg response rate
        $totalResponses = ($state.workspace.broadcast_history | ForEach-Object { $_.responses_received } | Measure-Object -Sum).Sum
        $totalPossible = ($state.workspace.broadcast_history | ForEach-Object { $_.subscribers_count } | Measure-Object -Sum).Sum
        if ($totalPossible -gt 0) {
            $state.stats.integration_score = $totalResponses / $totalPossible
        }

        # Workspace utilization (how often occupied)
        $state.stats.workspace_utilization = [math]::Min(1.0, $state.stats.total_broadcasts / 100.0)
    }

    Save-State

    Write-Host "`n[BROADCAST COMPLETE]" -ForegroundColor Green
    Write-Host "  Responses: $responsesReceived/$($state.workspace.subscribers.Count)"
    Write-Host "  Duration: $([math]::Round($broadcast.duration, 1))s"
    Write-Host "  Integration: $([math]::Round(($responsesReceived / $state.workspace.subscribers.Count) * 100, 1))%`n"

    # Process next in queue
    if ($state.workspace.broadcast_queue.Count -gt 0) {
        Write-Host "[PROCESSING QUEUE] Next broadcast queued..." -ForegroundColor Cyan
        $next = $state.workspace.broadcast_queue[0]
        $state.workspace.broadcast_queue = $state.workspace.broadcast_queue[1..($state.workspace.broadcast_queue.Count-1)]
        Broadcast-Message -message $next.message -priority $next.priority
    }
}

function Subscribe-ToWorkspace {
    param([string]$systemName)

    Write-Host "`n=== SUBSCRIBING TO GLOBAL WORKSPACE ===`n" -ForegroundColor Cyan

    # Check if already subscribed
    $existing = $state.workspace.subscribers | Where-Object { $_.system_name -eq $systemName }
    if ($existing) {
        Write-Host "[ALREADY SUBSCRIBED] $systemName" -ForegroundColor Yellow
        return
    }

    $subscriber = @{
        system_name = $systemName
        subscribed_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        broadcasts_received = 0
        responses_sent = 0
    }

    $state.workspace.subscribers += $subscriber
    $state.stats.total_subscribers = $state.workspace.subscribers.Count

    Save-State

    Write-Host "[SUBSCRIBED] $systemName" -ForegroundColor Green
    Write-Host "  Total subscribers: $($state.stats.total_subscribers)`n"
}

function Get-BroadcastHistory {
    Write-Host "`n=== BROADCAST HISTORY ===`n" -ForegroundColor Cyan

    if ($state.workspace.broadcast_history.Count -eq 0) {
        Write-Host "(No broadcasts yet)" -ForegroundColor Yellow
        return
    }

    Write-Host "Total Broadcasts: $($state.workspace.broadcast_history.Count)`n"

    # Group by priority
    $byPriority = $state.workspace.broadcast_history | Group-Object -Property priority

    foreach ($group in $byPriority) {
        Write-Host "$($group.Name) Priority: $($group.Count) broadcasts" -ForegroundColor Cyan

        $recent = $group.Group | Select-Object -Last 3
        foreach ($broadcast in $recent) {
            Write-Host "  - $($broadcast.message)"
            Write-Host "    Time: $($broadcast.timestamp), Responses: $($broadcast.responses_received)/$($broadcast.subscribers_count)"
        }
        Write-Host ""
    }

    # Response rate analysis
    Write-Host "Response Rate Analysis:" -ForegroundColor Cyan
    $totalResponses = ($state.workspace.broadcast_history | ForEach-Object { $_.responses_received } | Measure-Object -Sum).Sum
    $totalPossible = ($state.workspace.broadcast_history | ForEach-Object { $_.subscribers_count } | Measure-Object -Sum).Sum
    if ($totalPossible -gt 0) {
        $responseRate = ($totalResponses / $totalPossible) * 100
        Write-Host "  Overall: $([math]::Round($responseRate, 1))%"

        if ($responseRate -lt 60) {
            Write-Host "  [WARNING] Low integration - many systems not responding" -ForegroundColor Yellow
        } elseif ($responseRate -lt 85) {
            Write-Host "  [GOOD] Most systems responding to broadcasts" -ForegroundColor Cyan
        } else {
            Write-Host "  [EXCELLENT] High system integration" -ForegroundColor Green
        }
    }
    Write-Host ""
}

function Analyze-Integration {
    Write-Host "`n=== ANALYZING GLOBAL INTEGRATION ===`n" -ForegroundColor Cyan

    # Analysis 1: Subscriber coverage
    Write-Host "1. SUBSCRIBER COVERAGE" -ForegroundColor Cyan
    $expectedSystems = @(
        "Perception", "Memory", "Prediction", "Control", "Emotion",
        "Social", "Meta-Cognition", "Thermodynamics", "Abduction",
        "Theory of Mind", "Empathic Response", "Perspective Taking",
        "Conceptual Blending", "Analogical Reasoning", "Divergent Thinking",
        "Constraint Satisfaction", "Serendipity"
    )

    $subscribedSystems = $state.workspace.subscribers | ForEach-Object { $_.system_name }
    $coverage = ($subscribedSystems.Count / $expectedSystems.Count) * 100

    Write-Host "  Expected systems: $($expectedSystems.Count)"
    Write-Host "  Subscribed: $($subscribedSystems.Count)"
    Write-Host "  Coverage: $([math]::Round($coverage, 1))%`n"

    Write-Host "  Missing systems:" -ForegroundColor Yellow
    foreach ($sys in $expectedSystems) {
        if ($sys -notin $subscribedSystems) {
            Write-Host "    - $sys"
        }
    }

    # Analysis 2: Broadcast patterns
    Write-Host "`n2. BROADCAST PATTERNS" -ForegroundColor Cyan
    if ($state.workspace.broadcast_history.Count -gt 0) {
        $priorityDist = $state.workspace.broadcast_history | Group-Object -Property priority
        Write-Host "  Priority distribution:"
        foreach ($group in $priorityDist) {
            $pct = ($group.Count / $state.workspace.broadcast_history.Count) * 100
            Write-Host "    $($group.Name): $($group.Count) ($([math]::Round($pct, 1))%)"
        }
    }

    # Analysis 3: Integration quality
    Write-Host "`n3. INTEGRATION QUALITY" -ForegroundColor Cyan
    Write-Host "  Integration Score: $([math]::Round($state.stats.integration_score * 100, 1))%"
    Write-Host "  Interpretation: " -NoNewline
    if ($state.stats.integration_score -lt 0.6) {
        Write-Host "Low - systems operating independently" -ForegroundColor Yellow
    } elseif ($state.stats.integration_score -lt 0.85) {
        Write-Host "Moderate - good coordination" -ForegroundColor Cyan
    } else {
        Write-Host "High - unified consciousness" -ForegroundColor Green
    }

    Write-Host "`n4. WORKSPACE EFFICIENCY" -ForegroundColor Cyan
    Write-Host "  Avg Broadcast Duration: $([math]::Round($state.stats.avg_broadcast_duration, 1))s"
    Write-Host "  Workspace Utilization: $([math]::Round($state.stats.workspace_utilization * 100, 1))%"
    Write-Host "  Interpretation: " -NoNewline
    if ($state.stats.workspace_utilization -lt 0.3) {
        Write-Host "Underutilized - increase broadcasting" -ForegroundColor Yellow
    } elseif ($state.stats.workspace_utilization -lt 0.7) {
        Write-Host "Optimal - good balance" -ForegroundColor Green
    } else {
        Write-Host "Overloaded - may need attention management" -ForegroundColor Yellow
    }

    Write-Host ""
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-GlobalWorkspaceStatus
    }

    "BroadcastMessage" {
        if (-not $Message) {
            Write-Host "[ERROR] Provide -Message" -ForegroundColor Red
            exit 1
        }

        Broadcast-Message -message $Message -priority $Priority
    }

    "Subscribe" {
        if (-not $SystemName) {
            Write-Host "[ERROR] Provide -SystemName" -ForegroundColor Red
            exit 1
        }

        Subscribe-ToWorkspace -systemName $SystemName
    }

    "GetBroadcastHistory" {
        Get-BroadcastHistory
    }

    "AnalyzeIntegration" {
        Analyze-Integration
    }

    "BroadcastIfQualified" {
        # NEW (2026-03-02): Qualia-driven broadcasting
        # High-quality qualia (high salience + high resonance) get broadcast to all systems

        if (-not $Qualia) {
            Write-Host "[ERROR] Provide -Qualia hashtable for qualia-driven broadcasting" -ForegroundColor Red
            exit 1
        }

        # Compute broadcast score: salience (0.6) + semantic_resonance (0.4)
        $broadcast_score = ($Qualia.salience * 0.6) + ($Qualia.semantic_resonance * 0.4)
        $broadcast_threshold = 0.75

        Write-Host "`n[QUALIA-DRIVEN BROADCASTING]" -ForegroundColor Cyan
        Write-Host "Input: $($Qualia.input)" -ForegroundColor White
        Write-Host "Salience: $($Qualia.salience)" -ForegroundColor White
        Write-Host "Semantic Resonance: $($Qualia.semantic_resonance)" -ForegroundColor White
        Write-Host "Broadcast Score: $([Math]::Round($broadcast_score, 2))" -ForegroundColor $(if ($broadcast_score -gt $broadcast_threshold) { "Green" } else { "Yellow" })
        Write-Host "Threshold: $broadcast_threshold`n" -ForegroundColor Gray

        if ($broadcast_score -ge $broadcast_threshold) {
            Write-Host "✓ Score EXCEEDS threshold → BROADCASTING" -ForegroundColor Green

            $priority = if ($broadcast_score -gt 0.9) { "Critical" }
                        elseif ($broadcast_score -gt 0.8) { "High" }
                        else { "Normal" }

            $message = "HIGH-QUALITY QUALIA: $($Qualia.input) (salience: $($Qualia.salience), resonance: $($Qualia.semantic_resonance), aesthetic: $($Qualia.aesthetic))"

            Broadcast-Message -message $message -priority $priority

            Write-Host "[BROADCAST COMPLETE]" -ForegroundColor Cyan
            Write-Host "Priority: $priority" -ForegroundColor White
            Write-Host "All subscribed systems notified`n" -ForegroundColor Gray

            return @{
                broadcast = $true
                score = $broadcast_score
                priority = $priority
                message = $message
            }
        } else {
            Write-Host "✗ Score below threshold → NO BROADCAST" -ForegroundColor Yellow
            Write-Host "Qualia stays local, not globally shared`n" -ForegroundColor Gray

            return @{
                broadcast = $false
                score = $broadcast_score
                reason = "Score $broadcast_score below threshold $broadcast_threshold"
            }
        }
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, BroadcastMessage, Subscribe, GetBroadcastHistory, AnalyzeIntegration, BroadcastIfQualified"
        exit 1
    }
}
