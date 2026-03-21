# SCP RING 3: EMERGENT CREATIVITY
# Creativiteit die EMERGEERT uit Ring 1 + Ring 2 interactie
# Bron: Sjoerd's Damasio Audit - Ring 3 van 3-ringen architectuur
# Datum: 2026-03-06
#
# PRINCIPE: Creativiteit is geen commando, het emergeert
# LEEST Ring 1 (resources) + Ring 2 (confidence)
# BESLUIT: creativity mode (conservative/balanced/creative)
# GEBRUIKT: conceptual-blending, global-workspace (als mode toelaat)
#
# INPUT: Ring 1 + Ring 2 output states
# OUTPUT: Creativity mode + Behavioral permissions

param(
    [string]$Action = "Status"  # Status, GetMode, CheckPermission
)

$StateFile = "C:\scripts\agentidentity\state\scp-ring3-state.json"
$LogFile = "C:\scripts\agentidentity\state\scp-ring3.log"

# ==============================================================================
# INPUT: Read Ring 1 + Ring 2 States
# ==============================================================================

function Get-Ring1State {
    $stateFile = "C:\scripts\agentidentity\state\scp-ring1-state.json"
    if (Test-Path $stateFile) {
        try {
            return Get-Content $stateFile -Raw | ConvertFrom-Json
        } catch {
            Write-Host "  [Ring3] Warning: Could not load Ring 1 state" -ForegroundColor Yellow
            return $null
        }
    }
    return $null
}

function Get-Ring2State {
    $stateFile = "C:\scripts\agentidentity\state\scp-ring2-state.json"
    if (Test-Path $stateFile) {
        try {
            return Get-Content $stateFile -Raw | ConvertFrom-Json
        } catch {
            Write-Host "  [Ring3] Warning: Could not load Ring 2 state" -ForegroundColor Yellow
            return $null
        }
    }
    return $null
}

# ==============================================================================
# EMERGENCE LOGIC: Creativiteit alleen als omstandigheden kloppen
# ==============================================================================

function Get-EmergentCreativityMode {
    Write-Host "  [Ring3] Reading from Ring 1 + Ring 2..." -ForegroundColor Cyan

    $ring1 = Get-Ring1State
    $ring2 = Get-Ring2State

    # Extract key signals
    if ($ring1 -and $ring1.resource_status) {
        $resources = [double]$ring1.resource_status.overall_resources
        $energy = [double]$ring1.resource_status.energy_level
        $context = [double]$ring1.resource_status.context_usage
        $stuck = [bool]$ring1.resource_status.stuck_flag
    } else {
        # Fallback
        $resources = 0.6
        $energy = 0.7
        $context = 0.5
        $stuck = $false
    }

    if ($ring2 -and $ring2.confidence_status) {
        $confidence = [double]$ring2.confidence_status.confidence_score
        $risk = [double]$ring2.confidence_status.hallucination_risk
    } else {
        # Fallback
        $confidence = 0.6
        $risk = 0.4
    }

    Write-Host "    Ring 1: resources=$resources, energy=$energy, context=$context, stuck=$stuck" -ForegroundColor DarkGray
    Write-Host "    Ring 2: confidence=$confidence, risk=$risk" -ForegroundColor DarkGray

    # EMERGENCE RULES
    # Creative mode: high resources AND high confidence AND not stuck
    # Conservative mode: low resources OR low confidence OR stuck
    # Balanced: everything in between

    $resources_ok = ($resources -gt 0.6 -and $energy -gt 0.5 -and $context -lt 0.7)
    $confidence_ok = ($confidence -gt 0.6 -and $risk -lt 0.4)
    $not_stuck = (-not $stuck)

    # Determine mode
    $mode = if ($resources_ok -and $confidence_ok -and $not_stuck) {
        "creative"
    } elseif ((-not $resources_ok) -or (-not $confidence_ok) -or $stuck) {
        "conservative"
    } else {
        "balanced"
    }

    Write-Host "  [Ring3] Emergence decision: $mode mode" -ForegroundColor Cyan
    Write-Host "    Resources OK: $resources_ok | Confidence OK: $confidence_ok | Not stuck: $not_stuck" -ForegroundColor DarkGray

    return @{
        mode = $mode
        resources_ok = $resources_ok
        confidence_ok = $confidence_ok
        not_stuck = $not_stuck

        # Rationale
        rationale = if ($mode -eq "creative") {
            "High resources + high confidence + flow state = creativity emerges"
        } elseif ($mode -eq "conservative") {
            "Low resources OR low confidence OR stuck = focus on precision"
        } else {
            "Mixed signals = balanced approach"
        }

        # Input signals (for transparency)
        ring1_resources = $resources
        ring1_energy = $energy
        ring1_context = $context
        ring1_stuck = $stuck
        ring2_confidence = $confidence
        ring2_risk = $risk

        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

# ==============================================================================
# BEHAVIORAL PERMISSIONS: Wat mag wel/niet in deze mode?
# ==============================================================================

function Get-BehavioralPermissions {
    param($CreativityMode)

    Write-Host "  [Ring3] Generating behavioral permissions for $($CreativityMode.mode) mode..." -ForegroundColor Cyan

    $mode = $CreativityMode.mode

    # Analogies/metaphors allowed?
    $analogies_allowed = ($mode -eq "creative")

    # Exploration depth
    $exploration_depth = switch ($mode) {
        "creative" { 0.8 }      # Deep exploration OK
        "balanced" { 0.5 }      # Moderate exploration
        "conservative" { 0.2 }  # Minimal exploration
    }

    # Novelty tolerance (how unconventional can solutions be?)
    $novelty_tolerance = switch ($mode) {
        "creative" { 0.9 }      # Novel approaches encouraged
        "balanced" { 0.5 }      # Some novelty OK
        "conservative" { 0.2 }  # Stick to proven patterns
    }

    # Invoke conceptual blending?
    $invoke_blending = ($mode -ne "conservative")

    # Use global workspace broadcasting?
    $use_broadcasting = ($mode -eq "creative")

    # Multiple perspectives?
    $multiple_perspectives = ($mode -eq "creative")

    $permissions = @{
        analogies_allowed = $analogies_allowed
        exploration_depth = $exploration_depth
        novelty_tolerance = $novelty_tolerance
        invoke_blending = $invoke_blending
        use_broadcasting = $use_broadcasting
        multiple_perspectives = $multiple_perspectives

        # Guidance
        mode_guidance = switch ($mode) {
            "creative" {
                "Creativity emerges - explore analogies, novel connections, multiple perspectives"
            }
            "balanced" {
                "Moderate creativity - blend familiar with new, balanced exploration"
            }
            "conservative" {
                "Focus mode - precision over novelty, proven patterns, minimal exploration"
            }
        }

        task_fit = switch ($mode) {
            "creative" { "Design, architecture, brainstorming, problem-solving" }
            "balanced" { "Feature implementation, refactoring, optimization" }
            "conservative" { "Bug fixing, deployment, critical operations, testing" }
        }
    }

    Write-Host "    Mode: $mode - $($permissions.mode_guidance)" -ForegroundColor DarkGray
    Write-Host "    Best for: $($permissions.task_fit)" -ForegroundColor DarkGray

    return $permissions
}

# ==============================================================================
# MODULE INVOCATION (if creative mode)
# ==============================================================================

function Invoke-CreativeModules {
    param($Permissions)

    if (-not $Permissions.invoke_blending) {
        Write-Host "  [Ring3] Creative modules not invoked (mode: conservative)" -ForegroundColor DarkGray
        return @{ invoked = $false; reason = "Conservative mode - no creative modules needed" }
    }

    Write-Host "  [Ring3] Invoking creative modules..." -ForegroundColor Cyan

    $results = @{ invoked = $true; modules = @() }

    # Conceptual blending (if allowed)
    if ($Permissions.invoke_blending) {
        try {
            $blendPath = "C:\scripts\agentidentity\cognitive-systems\conceptual-blending.ps1"
            if (Test-Path $blendPath) {
                & $blendPath -Action Status -ErrorAction SilentlyContinue | Out-Null
                $results.modules += "conceptual-blending"
                Write-Host "    Activated: conceptual-blending" -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "    Warning: Could not invoke conceptual-blending" -ForegroundColor Yellow
        }
    }

    # Global workspace broadcasting (if creative mode)
    if ($Permissions.use_broadcasting) {
        try {
            $gwPath = "C:\scripts\agentidentity\cognitive-systems\global-workspace.ps1"
            if (Test-Path $gwPath) {
                & $gwPath -Action Status -ErrorAction SilentlyContinue | Out-Null
                $results.modules += "global-workspace"
                Write-Host "    Activated: global-workspace" -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "    Warning: Could not invoke global-workspace" -ForegroundColor Yellow
        }
    }

    return $results
}

# ==============================================================================
# ACTIONS
# ==============================================================================

function Invoke-Status {
    Write-Host "`n[SCP Ring 3: Emergent Creativity]" -ForegroundColor Green

    # Get emergent mode
    $creativity = Get-EmergentCreativityMode

    # Generate permissions
    $permissions = Get-BehavioralPermissions -CreativityMode $creativity

    # Invoke creative modules if appropriate
    $modules = Invoke-CreativeModules -Permissions $permissions

    $fullState = @{
        creativity_mode = $creativity
        behavioral_permissions = $permissions
        invoked_modules = $modules
        ring = 3
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # Save
    $fullState | ConvertTo-Json -Depth 5 | Set-Content $StateFile

    # Display
    Write-Host "`nCREATIVITY MODE: $($creativity.mode.ToUpper())" -ForegroundColor Yellow
    Write-Host "  Rationale: $($creativity.rationale)" -ForegroundColor White

    Write-Host "`nBEHAVIORAL PERMISSIONS:" -ForegroundColor Yellow
    Write-Host "  $($permissions.mode_guidance)" -ForegroundColor Cyan
    Write-Host "  Best for: $($permissions.task_fit)" -ForegroundColor Cyan
    Write-Host "  Exploration depth: $($permissions.exploration_depth)" -ForegroundColor Cyan
    Write-Host "  Analogies: $($permissions.analogies_allowed)" -ForegroundColor Cyan

    Write-Host "`nCREATIVE MODULES:" -ForegroundColor Yellow
    if ($modules.invoked) {
        Write-Host "  Activated: $($modules.modules -join ', ')" -ForegroundColor Green
    } else {
        Write-Host "  $($modules.reason)" -ForegroundColor DarkGray
    }

    return $fullState
}

# ==============================================================================
# LOGGING
# ==============================================================================

function Write-Ring3Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$timestamp] [$Level] $Message" -ErrorAction SilentlyContinue
}

# ==============================================================================
# MAIN
# ==============================================================================

try {
    switch ($Action) {
        "Status" {
            $result = Invoke-Status
            Write-Ring3Log "Status check. Mode: $($result.creativity_mode.mode)"
        }
        "GetMode" {
            if (Test-Path $StateFile) {
                $state = Get-Content $StateFile -Raw | ConvertFrom-Json
                $state.creativity_mode | ConvertTo-Json
            } else {
                $result = Invoke-Status
                $result.creativity_mode | ConvertTo-Json
            }
        }
        default {
            Write-Host "Unknown action: $Action" -ForegroundColor Red
            Write-Host "Valid actions: Status, GetMode" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "ERROR in Ring 3 Orchestrator: $_" -ForegroundColor Red
    Write-Ring3Log "ERROR: $_" "ERROR"
}
