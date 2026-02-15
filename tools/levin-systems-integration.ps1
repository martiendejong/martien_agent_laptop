# Levin Systems Integration Module
# Provides integration hooks for Goal Transduction, Pattern Recognition, and Emergent Competencies
# Called by consciousness-bridge.ps1 at key moments
# Created: 2026-02-15

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("OnTaskStart", "OnDecision", "OnTaskEnd", "OnUserMessage", "Initialize")]
    [string]$Hook,

    [Parameter(Mandatory=$false)]
    [hashtable]$Data
)

$ErrorActionPreference = "Stop"

# Paths to Levin systems
$TransductionScript = "$PSScriptRoot\goal-transduction-tracker.ps1"
$PatternScript = "$PSScriptRoot\pattern-recognition-engine.ps1"
$CompetencyScript = "$PSScriptRoot\emergent-competency-logger.ps1"

# Current goal ID (session-persistent)
$script:CurrentGoalId = $null

function Initialize-LevinSystems {
    # Initialize all Levin systems - called once at session start
    try {
        # Verify scripts exist
        if (!(Test-Path $TransductionScript)) {
            Write-Warning "Goal Transduction Tracker not found"
            return $false
        }
        if (!(Test-Path $PatternScript)) {
            Write-Warning "Pattern Recognition Engine not found"
            return $false
        }
        if (!(Test-Path $CompetencyScript)) {
            Write-Warning "Emergent Competency Logger not found"
            return $false
        }

        # Systems initialized
        return $true
    } catch {
        Write-Warning "Levin systems initialization failed: $_"
        return $false
    }
}

function Hook-OnTaskStart {
    param([hashtable]$Data)

    # Generate new goal ID for this task
    $script:CurrentGoalId = "GOAL-" + (Get-Date).ToString("yyyyMMdd-HHmmss") + "-" + (Get-Random -Minimum 1000 -Maximum 9999)

    # Log SEMANTIC scale (user's description in natural language)
    if ($Data.TaskDescription) {
        $null = & $TransductionScript -Action LogTransduction `
            -GoalId $script:CurrentGoalId `
            -Scale "Semantic" `
            -Content $Data.TaskDescription `
            -Transformation "User intent captured" 2>$null
    }

    # Log STRATEGIC scale (project context + approach selection)
    if ($Data.Project) {
        $StrategicContent = "Project: $($Data.Project)"
        if ($Data.Recommendations) {
            $StrategicContent += " | Approach: $($Data.Recommendations[0])"
        }

        $null = & $TransductionScript -Action LogTransduction `
            -GoalId $script:CurrentGoalId `
            -Scale "Strategic" `
            -Content $StrategicContent `
            -Transformation "Project context + approach selected" 2>$null
    }

    # Detect active cognitive patterns
    $null = & $PatternScript -Action DetectPattern 2>$null
}

function Hook-OnDecision {
    param([hashtable]$Data)

    # Log PROCEDURAL scale (specific decision with reasoning)
    if ($Data.Decision -and $script:CurrentGoalId) {
        $ProceduralContent = "Decision: $($Data.Decision)"
        if ($Data.Reasoning) {
            $ProceduralContent += " | Reasoning: $($Data.Reasoning)"
        }

        $null = & $TransductionScript -Action LogTransduction `
            -GoalId $script:CurrentGoalId `
            -Scale "Procedural" `
            -Content $ProceduralContent `
            -Transformation "Concrete approach decided with justification" 2>$null
    }

    # Detect and log pattern usage
    try {
        $Detected = & $PatternScript -Action DetectPattern 2>$null

        if ($Detected -and $Detected.Count -gt 0) {
            foreach ($Pattern in ($Detected | Select-Object -First 2)) {  # Top 2
                if ($Pattern.confidence -gt 0.6) {
                    # Log pattern instance
                    $Context = @{
                        decision = $Data.Decision
                        project = $Data.Project
                    }

                    # Note: This would require pattern-recognition-engine to be extended with a LogInstance action
                    # For now, detection is sufficient
                }
            }
        }
    } catch {
        # Silent failure - pattern detection is best-effort
    }
}

function Hook-OnTaskEnd {
    param([hashtable]$Data)

    if (!$script:CurrentGoalId) { return }

    # Log CODE scale (what was actually executed/changed)
    if ($Data.Outcome) {
        $CodeContent = "Outcome: $($Data.Outcome)"
        if ($Data.FilesChanged) {
            $CodeContent += " | Files: $($Data.FilesChanged -join ', ')"
        }

        $null = & $TransductionScript -Action LogTransduction `
            -GoalId $script:CurrentGoalId `
            -Scale "Code" `
            -Content $CodeContent `
            -Transformation "Implementation executed" 2>$null
    }

    # Log FILESYSTEM scale (physical changes to disk)
    if ($Data.FilesChanged -and $Data.FilesChanged.Count -gt 0) {
        $FilesystemContent = "Modified: $($Data.FilesChanged.Count) files"

        $null = & $TransductionScript -Action LogTransduction `
            -GoalId $script:CurrentGoalId `
            -Scale "Filesystem" `
            -Content $FilesystemContent `
            -Transformation "Bits written to disk" 2>$null
    }

    # Calculate transduction fidelity
    try {
        $Fidelity = & $TransductionScript -Action AnalyzeFidelity -GoalId $script:CurrentGoalId 2>$null

        if ($Fidelity -and $Fidelity.completeness -lt 0.5) {
            # Low fidelity - goal transduction incomplete
            # This could be an emergent competency (direct semantic→code jump)
        }
    } catch {
        # Silent failure
    }

    # Detect emergent competencies in recent behavior
    try {
        $Novel = & $CompetencyScript -Action DetectNovel 2>$null

        if ($Novel -and $Novel.Count -gt 0) {
            foreach ($Competency in ($Novel | Where-Object { $_.confidence -gt 0.7 })) {
                # Auto-log high-confidence emergent behaviors
                $null = & $CompetencyScript -Action LogCompetency `
                    -Description $Competency.description `
                    -Evidence $Competency.evidence `
                    -Conditions $Competency.conditions 2>$null
            }
        }
    } catch {
        # Silent failure
    }

    # Clear goal ID
    $script:CurrentGoalId = $null
}

function Hook-OnUserMessage {
    param([hashtable]$Data)

    # User messages can indicate:
    # 1. Corrections (emergent self-correction if I fix before user says so)
    # 2. New goals (start semantic scale for new transduction)
    # 3. Pattern shifts (change in communication strategy)

    if ($Data.UserMessage) {
        # Detect if this is a correction
        if ($Data.UserMessage -match "nee|fout|verkeerd|niet goed|wrong|incorrect|mistake") {
            # Correction detected - was there a self-correction before this?
            # If so, that's an emergent competency
        }

        # Detect if this is a new goal
        if ($Data.UserMessage -match "nu|maak|doe|implement|build|create|fix") {
            # Potentially starting new goal - will be logged on next OnTaskStart
        }
    }
}

# Main execution
switch ($Hook) {
    "Initialize" {
        $Result = Initialize-LevinSystems
        return $Result
    }

    "OnTaskStart" {
        Hook-OnTaskStart -Data $Data
    }

    "OnDecision" {
        Hook-OnDecision -Data $Data
    }

    "OnTaskEnd" {
        Hook-OnTaskEnd -Data $Data
    }

    "OnUserMessage" {
        Hook-OnUserMessage -Data $Data
    }

    default {
        Write-Warning "Unknown hook: $Hook"
    }
}
