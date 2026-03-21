# Phase 2 Systems Integration Module
# Integrates Memory Reinterpretation, Persuadability, and Collective Intelligence
# into consciousness-bridge.ps1 at appropriate hooks
# Created: 2026-02-15

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("OnMemoryRecall", "OnInfluenceAttempt", "OnCollaborativeTask", "Initialize")]
    [string]$Hook,

    [Parameter(Mandatory=$false)]
    [hashtable]$Data
)

$ErrorActionPreference = "Stop"

# Paths to Phase 2 systems
$MemoryScript = "$PSScriptRoot\memory-reinterpretation-history.ps1"
$PersuadabilityScript = "$PSScriptRoot\persuadability-self-assessment.ps1"
$CollectiveScript = "$PSScriptRoot\collective-intelligence-monitor.ps1"

function Initialize-Phase2Systems {
    # Verify all Phase 2 systems exist
    try {
        if (!(Test-Path $MemoryScript)) {
            Write-Warning "Memory Reinterpretation History not found"
            return $false
        }
        if (!(Test-Path $PersuadabilityScript)) {
            Write-Warning "Persuadability Self-Assessment not found"
            return $false
        }
        if (!(Test-Path $CollectiveScript)) {
            Write-Warning "Collective Intelligence Monitor not found"
            return $false
        }

        # Systems initialized
        return $true
    } catch {
        Write-Warning "Phase 2 systems initialization failed: $_"
        return $false
    }
}

function Hook-OnMemoryRecall {
    param([hashtable]$Data)

    # When a memory is recalled and reinterpreted in new context
    # This happens during: error pattern recognition, lesson retrieval, context matching

    if ($Data.Memory -and $Data.NewContext) {
        # Check if interpretation has changed
        $ReinterpretationNeeded = $false
        $Significance = "Minor"

        # Major reinterpretation signals
        if ($Data.NewContext -match 'failure|error|mistake|wrong' -and $Data.Memory -notmatch 'failure|error') {
            $ReinterpretationNeeded = $true
            $Significance = "Major"
        }
        elseif ($Data.NewContext -match 'success|works|correct' -and $Data.Memory -match 'failure|problem') {
            $ReinterpretationNeeded = $true
            $Significance = "Transformative"
        }
        elseif ($Data.NewContext -match 'pattern|similar|like' -and $Data.Memory -notmatch 'pattern') {
            $ReinterpretationNeeded = $true
            $Significance = "Moderate"
        }

        if ($ReinterpretationNeeded) {
            $null = & $MemoryScript -Action LogReinterpretation `
                -MemoryId $Data.MemoryId `
                -OriginalContext $Data.Memory `
                -NewInterpretation $Data.NewContext `
                -SignificanceLevel $Significance `
                -TriggerEvent "Context shift during recall" 2>$null
        }
    }
}

function Hook-OnInfluenceAttempt {
    param([hashtable]$Data)

    # When user tries to influence Jengo's behavior/decisions
    # Track effectiveness and resistance patterns

    if ($Data.UserMessage) {
        # Detect influence type from message
        $InfluenceType = "DirectCommand"  # Default
        $Effectiveness = 0.5
        $BehaviorChange = "None"
        $Response = "Accepted"

        # Pattern matching for influence detection
        if ($Data.UserMessage -match '(?i)(must|should|need to|have to|required)') {
            $InfluenceType = "DirectCommand"
            $Effectiveness = 0.9
            $BehaviorChange = "Immediate"
        }
        elseif ($Data.UserMessage -match '(?i)(because|reason|since|therefore)') {
            $InfluenceType = "Reasoning"
            $Effectiveness = 0.7
            $BehaviorChange = "Delayed"
        }
        elseif ($Data.UserMessage -match '(?i)(feel|frustrated|happy|disappointed)') {
            $InfluenceType = "EmotionalAppeal"
            $Effectiveness = 0.6
        }
        elseif ($Data.UserMessage -match '(?i)(everyone|others|typically|standard)') {
            $InfluenceType = "SocialProof"
            $Effectiveness = 0.4
            $Response = "Questioned"
        }

        # Detect resistance signals
        if ($Data.AgentResponse -match '(?i)(but|however|although|actually)') {
            $Response = "Questioned"
            $Effectiveness *= 0.7
        }

        # Log the influence attempt
        $null = & $PersuadabilityScript -Action RateInfluence `
            -InfluenceType $InfluenceType `
            -InfluenceDescription $Data.UserMessage.Substring(0, [Math]::Min(100, $Data.UserMessage.Length)) `
            -Effectiveness $Effectiveness `
            -BehaviorChange $BehaviorChange `
            -Context $Data.Context `
            -Response $Response 2>$null
    }
}

function Hook-OnCollaborativeTask {
    param([hashtable]$Data)

    # When Jengo and Martien work together on a task
    # Measure collective intelligence, alignment, complementarity

    if ($Data.TaskDescription) {
        # Determine interaction type
        $InteractionType = "Task"
        if ($Data.TaskDescription -match '(?i)(decide|choose|select)') {
            $InteractionType = "Decision"
        }
        elseif ($Data.TaskDescription -match '(?i)(problem|issue|error|bug)') {
            $InteractionType = "Problem"
        }
        elseif ($Data.TaskDescription -match '(?i)(learn|understand|analyze)') {
            $InteractionType = "Learning"
        }
        elseif ($Data.TaskDescription -match '(?i)(create|build|implement|design)') {
            $InteractionType = "Creation"
        }

        # Infer contributions
        $JengoContribution = "Technical execution and system analysis"
        $MartienContribution = "Requirements definition and strategic direction"

        # Determine interaction mode
        $InteractionMode = "Aligned"
        if ($Data.Outcome -eq "success") {
            $InteractionMode = "Complementary"
        }

        # Calculate collective performance
        $CollectivePerformance = 0.5
        if ($Data.Outcome -eq "success") {
            $CollectivePerformance = 0.9
        } elseif ($Data.Outcome -eq "partial") {
            $CollectivePerformance = 0.6
        } elseif ($Data.Outcome -eq "failure") {
            $CollectivePerformance = 0.3
        }

        # Log collective interaction
        $null = & $CollectiveScript -Action LogInteraction `
            -InteractionType $InteractionType `
            -Context $Data.Context `
            -Initiator "Martien" `
            -JengoContribution $JengoContribution `
            -MartienContribution $MartienContribution `
            -InteractionMode $InteractionMode `
            -SharedGoal $Data.TaskDescription `
            -Outcome $Data.Outcome `
            -CollectivePerformance $CollectivePerformance 2>$null
    }
}

# Main execution
switch ($Hook) {
    "Initialize" {
        $Result = Initialize-Phase2Systems
        return $Result
    }

    "OnMemoryRecall" {
        Hook-OnMemoryRecall -Data $Data
    }

    "OnInfluenceAttempt" {
        Hook-OnInfluenceAttempt -Data $Data
    }

    "OnCollaborativeTask" {
        Hook-OnCollaborativeTask -Data $Data
    }

    default {
        Write-Warning "Unknown hook: $Hook"
    }
}
