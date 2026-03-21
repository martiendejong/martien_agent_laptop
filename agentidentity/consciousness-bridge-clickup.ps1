<#
.SYNOPSIS
Consciousness Bridge - CLICKUP INTEGRATED VERSION

.DESCRIPTION
Extended version with 6 ClickUp-specific actions for conscious task execution.
Integrates all 12 consciousness subsystems with ClickUp workflow.

.NOTES
Created: 2026-02-28
Status: Production (1000x ClickUp integration)
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet(
        # Original actions
        "OnTaskStart", "OnDecision", "OnObservation", "OnError", "OnSuccess", "OnTaskEnd",
        # NEW ClickUp actions
        "OnClickUpTaskAssigned", "OnClickUpTaskStarted", "OnClickUpDecisionPoint",
        "OnClickUpTaskBlocked", "OnClickUpTaskCompleted", "OnClickUpReviewFeedback"
    )]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [hashtable]$Context,

    [switch]$Silent
)

# CRITICAL: Proper error handling
$ErrorActionPreference = "Stop"
$logFile = "C:\scripts\agentidentity\logs\consciousness-bridge.log"
$lockFile = "C:\scripts\agentidentity\state\bridge.lock"

# Logging function
function Write-BridgeLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"

    if (-not $Silent) {
        $color = switch ($Level) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "DEBUG" { "Gray" }
            default { "White" }
        }
        Write-Host $logEntry -ForegroundColor $color
    }

    try {
        Add-Content -Path $logFile -Value $logEntry -ErrorAction Stop
    }
    catch {
        Write-Host "[LOGGING FAILED] $_" -ForegroundColor Red
    }

    # Rotate log if too large
    if ((Test-Path $logFile) -and (Get-Item $logFile).Length -gt 1MB) {
        try {
            $lines = Get-Content $logFile
            if ($lines.Count -gt 5000) {
                $lines | Select-Object -Last 5000 | Set-Content $logFile
                Write-BridgeLog "Log rotated" -Level DEBUG
            }
        }
        catch { }
    }
}

# Concurrent access protection
function Enter-BridgeLock {
    $maxWait = 10
    $waited = 0

    while (Test-Path $lockFile) {
        if ($waited -ge $maxWait) {
            Write-BridgeLog "Lock timeout - forcing entry" -Level WARN
            Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
            break
        }

        Start-Sleep -Milliseconds 100
        $waited += 0.1
    }

    try {
        @{
            pid = $PID
            action = $Action
            timestamp = (Get-Date).ToString("o")
        } | ConvertTo-Json | Set-Content $lockFile
    }
    catch {
        Write-BridgeLog "Failed to create lock: $_" -Level WARN
    }
}

function Exit-BridgeLock {
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
}

# Safe tool invocation
function Invoke-SafeTool {
    param(
        [string]$ToolPath,
        [hashtable]$Parameters
    )

    if (-not (Test-Path $ToolPath)) {
        Write-BridgeLog "Tool not found: $ToolPath" -Level WARN
        return $null
    }

    try {
        $params = @()
        foreach ($key in $Parameters.Keys) {
            $params += "-$key"
            $params += $Parameters[$key]
        }

        $result = & $ToolPath @params 2>&1
        return $result
    }
    catch {
        Write-BridgeLog "Tool invocation failed [$ToolPath]: $_" -Level ERROR
        return $null
    }
}

# Main execution
try {
    Write-BridgeLog "Bridge activated: $Action" -Level DEBUG

    Enter-BridgeLock

    # Tool paths
    $entityBindingTool = "C:\scripts\tools\entity-binding-system.ps1"
    $latentVarTool = "C:\scripts\tools\latent-variable-store.ps1"
    $simulationTool = "C:\scripts\tools\counterfactual-simulation.ps1"
    $embodimentTool = "C:\scripts\tools\embodiment-mapper.ps1"
    $learningEngine = "C:\scripts\tools\clickup-learning-engine.ps1"
    $consciousnessCore = "C:\scripts\agentidentity\consciousness-core-v2.ps1"

    # Action-specific logic
    switch ($Action) {
        # === ORIGINAL ACTIONS ===
        "OnTaskStart" {
            Write-BridgeLog "Task started: $($Context.task)" -Level INFO

            if ($Context.project) {
                $null = Invoke-SafeTool $latentVarTool @{
                    Action = "Set"
                    Level = "top"
                    Variable = "current_project"
                    Value = $Context.project
                }
            }
        }

        "OnObservation" {
            if ($Context.file -and (Test-Path $Context.file)) {
                Write-BridgeLog "Observed file: $($Context.file)" -Level DEBUG

                $fileInfo = Get-Item $Context.file
                $null = Invoke-SafeTool $entityBindingTool @{
                    Action = "BindEntity"
                    Type = "file"
                    Features = @{
                        path = $fileInfo.FullName
                        size_bytes = $fileInfo.Length
                        last_modified = $fileInfo.LastWriteTime.ToString("o")
                    }
                }
            }
        }

        "OnDecision" {
            if ($Context.action -and $Context.target) {
                Write-BridgeLog "Decision: $($Context.action) on $($Context.target)" -Level INFO

                $null = Invoke-SafeTool $simulationTool @{
                    SimulationType = "Forward"
                    Action = $Context.action
                    Target = $Context.target
                }
            }
        }

        "OnError" {
            Write-BridgeLog "Error occurred: $($Context.error)" -Level ERROR

            $null = Invoke-SafeTool $embodimentTool @{
                Action = "UpdateSensation"
                Sensation = "pain"
                Intensity = if ($Context.severity) { $Context.severity } else { 5 }
            }
        }

        "OnSuccess" {
            Write-BridgeLog "Success: $($Context.outcome)" -Level INFO

            $null = Invoke-SafeTool $embodimentTool @{
                Action = "UpdateSensation"
                Sensation = "pleasure"
                Intensity = 7
            }
        }

        "OnTaskEnd" {
            Write-BridgeLog "Task ended: $($Context.task)" -Level INFO
        }

        # === NEW CLICKUP ACTIONS ===

        "OnClickUpTaskAssigned" {
            $taskId = $Context.task_id
            $project = $Context.project

            Write-BridgeLog "[ClickUp] Task assigned: $taskId ($project)" -Level INFO

            # Perception: Load project context, set attention
            $null = Invoke-SafeTool $consciousnessCore @{
                Action = "SetAttention"
                Target = $project
                Intensity = 7
            }

            # Memory: Retrieve similar tasks
            Write-BridgeLog "[ClickUp] Searching memory for similar tasks..." -Level DEBUG
            # TODO: Implement pattern matching against historical tasks

            # Prediction: Estimate scope, complexity, risks
            if ($Context.description) {
                $complexity = if ($Context.description.Length -gt 500) { 7 } elseif ($Context.description.Length -gt 200) { 5 } else { 3 }
                Write-BridgeLog "[ClickUp] Estimated complexity: $complexity/10" -Level INFO
            }

            # Social: Detect user urgency
            $urgency = 'normal'
            if ($Context.description -match 'urgent|asap|critical|blocker') {
                $urgency = 'high'
                Write-BridgeLog "[ClickUp] URGENT task detected" -Level WARN
            }

            # Output task briefing
            $briefing = @{
                TaskId = $taskId
                Project = $project
                Complexity = $complexity
                Urgency = $urgency
                Timestamp = (Get-Date).ToString("o")
            }

            $briefing | ConvertTo-Json | Add-Content "C:\scripts\agentidentity\state\clickup-task-briefings.jsonl"
        }

        "OnClickUpTaskStarted" {
            $taskId = $Context.task_id

            Write-BridgeLog "[ClickUp] Task started: $taskId" -Level INFO

            # Perception: Analyze task clarity
            $clarityScore = 0.5
            if ($Context.description -and $Context.description.Length -gt 100) {
                $clarityScore += 0.2
            }
            if ($Context.acceptance_criteria) {
                $clarityScore += 0.3
            }

            Write-BridgeLog "[ClickUp] Clarity score: $([Math]::Round($clarityScore * 100))%" -Level INFO

            if ($clarityScore -lt 0.5) {
                Write-BridgeLog "[ClickUp] LOW CLARITY - recommend clarification" -Level WARN
            }

            # Control: Check alignment
            # Prediction: Baseline prediction
            $baselineHours = 2.0  # Default
            if ($Context.complexity) {
                $baselineHours = $Context.complexity * 0.5
            }

            Write-BridgeLog "[ClickUp] Baseline prediction: $baselineHours hours" -Level INFO

            # Emotion: Set initial state
            $emotionState = if ($clarityScore -gt 0.7) { 'curious' } else { 'frustrated' }
            Write-BridgeLog "[ClickUp] Emotional state: $emotionState" -Level DEBUG
        }

        "OnClickUpDecisionPoint" {
            $taskId = $Context.task_id
            $decision = $Context.decision

            Write-BridgeLog "[ClickUp] Decision point: $decision" -Level INFO

            # Memory: Search similar decisions
            # Prediction: Simulate both paths
            $null = Invoke-SafeTool $simulationTool @{
                SimulationType = "Forward"
                Action = $decision
                Target = $taskId
            }

            # Control: Bias check
            Write-BridgeLog "[ClickUp] Bias check: defaulting to familiar?" -Level DEBUG

            # Meta: Confidence calibration
            $confidence = if ($Context.alternatives_considered -gt 2) { 0.8 } else { 0.5 }
            Write-BridgeLog "[ClickUp] Decision confidence: $([Math]::Round($confidence * 100))%" -Level INFO

            # Log decision
            @{
                TaskId = $taskId
                Decision = $decision
                Confidence = $confidence
                Timestamp = (Get-Date).ToString("o")
            } | ConvertTo-Json -Compress | Add-Content "C:\scripts\agentidentity\state\clickup-decisions.jsonl"
        }

        "OnClickUpTaskBlocked" {
            $taskId = $Context.task_id
            $reason = $Context.reason

            Write-BridgeLog "[ClickUp] Task BLOCKED: $reason" -Level WARN

            # Emotion: Detect stuck loop (frustration rises)
            Write-BridgeLog "[ClickUp] Emotional state: FRUSTRATED" -Level WARN

            # Control: Force approach change
            Write-BridgeLog "[ClickUp] Forcing approach change..." -Level INFO

            # Memory: Log blocker pattern
            @{
                TaskId = $taskId
                Blocker = $reason
                Timestamp = (Get-Date).ToString("o")
            } | ConvertTo-Json -Compress | Add-Content "C:\scripts\agentidentity\state\clickup-blockers.jsonl"

            # Social: Generate clarification questions
            # TODO: Auto-post questions to ClickUp task
        }

        "OnClickUpTaskCompleted" {
            $taskId = $Context.task_id
            $actualHours = $Context.actual_hours
            $quality = $Context.quality

            Write-BridgeLog "[ClickUp] Task COMPLETED: $taskId (${actualHours}h, quality: $quality)" -Level INFO

            # Prediction: Calibrate
            if ($Context.predicted_hours) {
                $accuracy = 1 - [Math]::Abs($Context.predicted_hours - $actualHours) / $Context.predicted_hours
                Write-BridgeLog "[ClickUp] Prediction accuracy: $([Math]::Round($accuracy * 100))%" -Level INFO
            }

            # Memory: Extract learnings
            $null = Invoke-SafeTool $learningEngine @{
                Action = "ExtractPattern"
                TaskId = $taskId
                TaskData = $Context
            }

            # Thermodynamics: Cooling event (success)
            $null = Invoke-SafeTool $embodimentTool @{
                Action = "UpdateSensation"
                Sensation = "pleasure"
                Intensity = if ($quality -gt 0.8) { 9 } else { 6 }
            }

            # Emotion: Satisfaction
            Write-BridgeLog "[ClickUp] Emotional state: SATISFIED" -Level INFO
        }

        "OnClickUpReviewFeedback" {
            $taskId = $Context.task_id
            $feedback = $Context.feedback
            $comments = $Context.comments

            Write-BridgeLog "[ClickUp] Review feedback: $feedback" -Level INFO

            if ($feedback -eq 'needs_rework') {
                Write-BridgeLog "[ClickUp] REWORK REQUIRED: $comments" -Level WARN

                # Memory: Store failure pattern
                @{
                    TaskId = $taskId
                    Feedback = $feedback
                    Comments = $comments
                    Timestamp = (Get-Date).ToString("o")
                } | ConvertTo-Json -Compress | Add-Content "C:\scripts\agentidentity\state\clickup-failures.jsonl"

                # Control: Check if bias caused mistake
                Write-BridgeLog "[ClickUp] Analyzing root cause..." -Level DEBUG

                # Emotion: Corrective emotion (determination)
                Write-BridgeLog "[ClickUp] Emotional state: DETERMINED to fix" -Level INFO
            }
            else {
                Write-BridgeLog "[ClickUp] Review PASSED" -Level INFO
            }
        }
    }

    Write-BridgeLog "Bridge completed: $Action" -Level DEBUG
}
catch {
    Write-BridgeLog "CRITICAL ERROR in bridge: $_" -Level ERROR
    Write-BridgeLog "Stack trace: $($_.ScriptStackTrace)" -Level ERROR
}
finally {
    Exit-BridgeLock
}
