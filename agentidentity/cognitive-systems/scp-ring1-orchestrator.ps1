# SCP RING 1: HOMEOSTATIC RESOURCE MANAGEMENT
# Orchestrator die resource status aggregeert en gedrag stuurt
# Bron: Sjoerd's Damasio Audit - Ring 1 van 3-ringen architectuur
# Datum: 2026-03-06
#
# PRINCIPE: Niet een nieuwe resource manager, maar een DIRIGENT
# Leest van bestaande modules, aggregeert, genereert behavioral constraints
#
# INPUT: embodied-cognition, attention-schema, cognitive-load (+ context estimate)
# OUTPUT: Resource status + Behavioral constraints die response sturen

param(
    [string]$Action = "Status",  # Status, EstimateContext, GetConstraints
    [int]$ConversationTurns = 0, # For context estimation
    [int]$ResponseLength = 0     # For effort tracking
)

$StateFile = "C:\scripts\agentidentity\state\scp-ring1-state.json"
$LogFile = "C:\scripts\agentidentity\state\scp-ring1.log"

# ==============================================================================
# HELPER: Load Existing Module States
# ==============================================================================

function Get-ModuleState {
    param([string]$ModuleName)

    $stateFile = "C:\scripts\agentidentity\state\$ModuleName-state.json"
    if (Test-Path $stateFile) {
        try {
            $content = Get-Content $stateFile -Raw | ConvertFrom-Json
            return $content
        } catch {
            Write-Host "  [Ring1] Warning: Could not load $ModuleName state" -ForegroundColor Yellow
            return $null
        }
    }
    return $null
}

function Get-EmbodiedState {
    # Leest van embodied-cognition.ps1 state
    $state = Get-ModuleState "embodied-cognition"
    if ($state) {
        $energy = if ($state.energy) { [double]$state.energy } else { 0.7 }
        $flow = if ($state.flow) { [double]$state.flow } else { 0.5 }
        $fatigue = if ($state.fatigue) { [double]$state.fatigue } else { 0.3 }
        return @{
            energy = $energy
            flow = $flow
            fatigue = $fatigue
        }
    }
    # Fallback
    return @{ energy = 0.7; flow = 0.5; fatigue = 0.3 }
}

function Get-AttentionState {
    # Leest van attention-schema.ps1 state
    $state = Get-ModuleState "attention-schema"
    if ($state) {
        $focus = if ($state.focus) { $state.focus } else { "General" }
        $capacity = if ($state.capacity) { [double]$state.capacity } else { 0.8 }
        $fragmented = if ($null -ne $state.fragmented) { [bool]$state.fragmented } else { $false }
        return @{
            focus = $focus
            capacity = $capacity
            fragmented = $fragmented
        }
    }
    # Fallback
    return @{ focus = "General"; capacity = 0.8; fragmented = $false }
}

function Get-CognitiveLoadState {
    # Leest van cognitive-load-management.ps1 state (als actief)
    $state = Get-ModuleState "cognitive-load-management"
    if ($state) {
        $load = if ($state.load) { [double]$state.load } else { 0.5 }
        $wmUsage = if ($state.working_memory_usage) { [double]$state.working_memory_usage } else { 0.5 }
        return @{
            load = $load
            working_memory_usage = $wmUsage
        }
    }
    # Fallback
    return @{ load = 0.5; working_memory_usage = 0.5 }
}

# ==============================================================================
# CONTEXT ESTIMATION (Nieuw - geen bestaande module)
# ==============================================================================

function Get-ContextEstimate {
    param([int]$ConversationTurns)

    # Proxy: conversation turns → context window usage estimate
    # Assume: 1 turn ≈ 1000 tokens average (user + assistant)
    # Claude context: 200K tokens
    # Formula: context_pct = (turns * 1000) / 200000

    $estimated_tokens = $ConversationTurns * 1000
    $context_pct = [Math]::Min($estimated_tokens / 200000.0, 1.0)

    return @{
        turns = $ConversationTurns
        estimated_tokens = $estimated_tokens
        context_usage_pct = [Math]::Round($context_pct, 3)
        status = if ($context_pct -lt 0.3) { "low" }
                 elseif ($context_pct -lt 0.6) { "medium" }
                 elseif ($context_pct -lt 0.8) { "high" }
                 else { "critical" }
    }
}

# ==============================================================================
# STUCK DETECTION (Simple heuristic)
# ==============================================================================

function Get-StuckStatus {
    # Check recente history voor herhaalde errors
    # Simplified: check if last 3 actions hadden errors
    # (Volledige implementatie zou burst-mode-detector.ps1 gebruiken)

    if (Test-Path $LogFile) {
        $recent = Get-Content $LogFile -Tail 5 -ErrorAction SilentlyContinue
        $errorCount = ($recent | Where-Object { $_ -match "ERROR|STUCK" }).Count

        return @{
            stuck = ($errorCount -ge 2)
            error_count = $errorCount
        }
    }

    return @{ stuck = $false; error_count = 0 }
}

# ==============================================================================
# AGGREGATION: Combine All Resource Signals
# ==============================================================================

function Get-AggregatedResourceStatus {
    param([int]$ConversationTurns = 0)

    Write-Host "  [Ring1] Reading from existing modules..." -ForegroundColor Cyan

    # Lees van bestaande modules
    $embodied = Get-EmbodiedState
    $attention = Get-AttentionState
    $cognitive = Get-CognitiveLoadState
    $context = Get-ContextEstimate -ConversationTurns $ConversationTurns
    $stuck = Get-StuckStatus

    Write-Host "    Energy: $($embodied.energy) | Attention: $($attention.capacity)" -ForegroundColor DarkGray
    Write-Host "    Context: $($context.context_usage_pct) ($($context.status)) | Stuck: $($stuck.stuck)" -ForegroundColor DarkGray

    # Aggregeer tot unified resource status
    $resourceStatus = @{
        # Raw signals
        energy_level = $embodied.energy
        attention_capacity = $attention.capacity
        cognitive_load = $cognitive.load
        context_usage = $context.context_usage_pct
        stuck_flag = $stuck.stuck

        # Derived overall status
        overall_resources = [Math]::Round((
            $embodied.energy * 0.35 +        # Energy is most important
            $attention.capacity * 0.25 +     # Attention second
            (1.0 - $cognitive.load) * 0.20 + # Low load = good
            (1.0 - $context.context_usage_pct) * 0.20  # Low context = good
        ), 3)

        # Status labels
        energy_status = if ($embodied.energy -gt 0.7) { "high" } elseif ($embodied.energy -gt 0.4) { "medium" } else { "low" }
        attention_status = if ($attention.capacity -gt 0.7) { "high" } elseif ($attention.capacity -gt 0.4) { "medium" } else { "low" }
        context_status = $context.status

        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    return $resourceStatus
}

# ==============================================================================
# BEHAVIORAL CONSTRAINTS: Dit is wat Ring 1 TOEVOEGT
# ==============================================================================

function Get-BehavioralConstraints {
    param($ResourceStatus)

    Write-Host "  [Ring1] Generating behavioral constraints..." -ForegroundColor Cyan

    $overall = $ResourceStatus.overall_resources
    $context = $ResourceStatus.context_usage
    $stuck = $ResourceStatus.stuck_flag

    # Response length constraint (tokens)
    $max_response_tokens = if ($overall -gt 0.7 -and $context -lt 0.5) { 1200 }      # High resources, low context → long OK
                           elseif ($overall -gt 0.5 -and $context -lt 0.7) { 800 }   # Medium → medium
                           elseif ($context -gt 0.7) { 500 }                         # High context → short regardless
                           else { 400 }                                               # Low resources → short

    # Exploration budget (0-1 scale)
    $exploration_budget = if ($overall -gt 0.7) { 0.8 }         # High resources → explore freely
                          elseif ($overall -gt 0.5) { 0.5 }     # Medium → balanced
                          else { 0.2 }                          # Low → focus only

    # Deep analysis allowed?
    $deep_analysis_allowed = ($overall -gt 0.6 -and $context -lt 0.7 -and -not $stuck)

    # Multitasking allowed?
    $multitasking_allowed = ($ResourceStatus.attention_capacity -gt 0.7 -and
                             $ResourceStatus.cognitive_load -lt 0.6)

    # Stuck handling
    $stuck_action = if ($stuck) { "STOP_AND_REFRAME" } else { "CONTINUE" }

    $constraints = @{
        max_response_tokens = $max_response_tokens
        exploration_budget = $exploration_budget
        deep_analysis_allowed = $deep_analysis_allowed
        multitasking_allowed = $multitasking_allowed
        stuck_action = $stuck_action

        # Guidance strings
        length_guidance = if ($max_response_tokens -gt 1000) { "Long detailed response OK" }
                         elseif ($max_response_tokens -gt 600) { "Medium length response" }
                         else { "Short focused response" }

        mode_guidance = if ($exploration_budget -gt 0.6) { "Exploratory mode" }
                       elseif ($exploration_budget -gt 0.3) { "Balanced mode" }
                       else { "Focused execution mode" }
    }

    Write-Host "    Response budget: $max_response_tokens tokens ($($constraints.length_guidance))" -ForegroundColor DarkGray
    Write-Host "    Exploration: $exploration_budget ($($constraints.mode_guidance))" -ForegroundColor DarkGray

    return $constraints
}

# ==============================================================================
# ACTIONS
# ==============================================================================

function Invoke-Status {
    Write-Host "`n[SCP Ring 1: Homeostatic Resource Management]" -ForegroundColor Green

    # Get aggregated status
    $status = Get-AggregatedResourceStatus -ConversationTurns $ConversationTurns

    # Generate constraints
    $constraints = Get-BehavioralConstraints -ResourceStatus $status

    # Combine
    $fullState = @{
        resource_status = $status
        behavioral_constraints = $constraints
        ring = 1
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # Save state
    $fullState | ConvertTo-Json -Depth 5 | Set-Content $StateFile

    # Display
    Write-Host "`nRESOURCE STATUS:" -ForegroundColor Yellow
    Write-Host "  Overall: $($status.overall_resources) (Energy: $($status.energy_status), Attention: $($status.attention_status))" -ForegroundColor White
    Write-Host "  Context: $($status.context_usage) ($($status.context_status))" -ForegroundColor White
    Write-Host "  Stuck: $($status.stuck_flag)" -ForegroundColor White

    Write-Host "`nBEHAVIORAL CONSTRAINTS:" -ForegroundColor Yellow
    Write-Host "  $($constraints.length_guidance)" -ForegroundColor Cyan
    Write-Host "  $($constraints.mode_guidance)" -ForegroundColor Cyan
    Write-Host "  Deep analysis: $($constraints.deep_analysis_allowed)" -ForegroundColor Cyan
    Write-Host "  Multitasking: $($constraints.multitasking_allowed)" -ForegroundColor Cyan

    if ($status.stuck_flag) {
        Write-Host "`n⚠️  STUCK DETECTED - Action: $($constraints.stuck_action)" -ForegroundColor Red
    }

    return $fullState
}

function Invoke-GetConstraints {
    # Quick access voor behavioral constraints zonder volledige status
    if (Test-Path $StateFile) {
        $state = Get-Content $StateFile -Raw | ConvertFrom-Json
        return $state.behavioral_constraints
    }

    # Fallback: run status
    $fullState = Invoke-Status
    return $fullState.behavioral_constraints
}

# ==============================================================================
# LOGGING
# ==============================================================================

function Write-Ring1Log {
    param([string]$Message, [string]$Level = "INFO")

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"

    Add-Content -Path $LogFile -Value $logEntry -ErrorAction SilentlyContinue
}

# ==============================================================================
# MAIN
# ==============================================================================

try {
    switch ($Action) {
        "Status" {
            $result = Invoke-Status
            Write-Ring1Log "Status check complete. Overall resources: $($result.resource_status.overall_resources)"
        }
        "GetConstraints" {
            $constraints = Invoke-GetConstraints
            Write-Host "Behavioral constraints retrieved" -ForegroundColor Green
            $constraints | ConvertTo-Json
        }
        default {
            Write-Host "Unknown action: $Action" -ForegroundColor Red
            Write-Host "Valid actions: Status, GetConstraints" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "ERROR in Ring 1 Orchestrator: $_" -ForegroundColor Red
    Write-Ring1Log "ERROR: $_" "ERROR"
}
