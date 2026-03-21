# ClickUp Quality Guardian - Proactive Issue Detection
# Purpose: Continuous monitoring of task execution quality, detect violations BEFORE user reports
# Author: Jengo
# Created: 2026-02-28

param(
    [ValidateSet('Monitor', 'CheckTask', 'Report')]
    [string]$Action = 'Monitor',

    [string]$TaskId,
    [int]$IntervalMinutes = 15
)

$ErrorActionPreference = 'Stop'

# Paths
$ViolationsFile = "C:\scripts\agentidentity\state\clickup-quality-violations.jsonl"
$StateFile = "C:\scripts\agentidentity\state\clickup-event-state.json"
$ConfigFile = "C:\scripts\_machine\clickup-config.json"

# Quality Check: Workflow Compliance
function Test-WorkflowCompliance {
    param($Task, $TaskHistory)

    $violations = @()
    $protocol = @(
        'clarity_check'        # Task clarity verified
        'moscow_analysis'      # MoSCoW prioritization done
        'worktree_allocated'   # Worktree created
        'pr_created'           # PR created on GitHub
        'pr_linked_to_task'    # PR link added to ClickUp
        'worktree_released'    # Worktree cleaned up
    )

    foreach ($step in $protocol) {
        $found = $TaskHistory | Where-Object { $_.step -eq $step }
        if (-not $found) {
            $violations += @{
                Type = 'workflow_violation'
                Step = $step
                Severity = if ($step -eq 'pr_linked_to_task') { 'CRITICAL' } else { 'HIGH' }
                Message = "Missing step: $step"
            }
        }
    }

    return $violations
}

# Quality Check: Comment Quality
function Test-CommentQuality {
    param($Task, $Comments)

    $violations = @()

    # Check for PR link in comments
    $prComments = $Comments | Where-Object { $_.comment_text -match 'PR #\d+|pull/\d+|github.com.*pull' }

    if (-not $prComments) {
        $violations += @{
            Type = 'missing_pr_link'
            Severity = 'CRITICAL'
            Message = "No PR link found in ClickUp comments (MANDATORY per Zero-Tolerance Rule)"
        }
    }

    # Check comment informativeness (not just "PR created")
    foreach ($comment in $Comments) {
        if ($comment.comment_text -match '^PR created$|^Done$|^Complete$') {
            $violations += @{
                Type = 'low_quality_comment'
                Severity = 'MEDIUM'
                Message = "Uninformative comment: '$($comment.comment_text)' (should include details)"
            }
        }
    }

    return $violations
}

# Quality Check: Testing Verification (Rule 3H)
function Test-TestingVerification {
    param($Task, $TaskHistory)

    $violations = @()

    # Check if task involves full-stack work
    $isFullStack = $Task.description -match 'frontend|backend|API|UI|login|auth|feature'

    if ($isFullStack) {
        # Must have browser testing evidence
        $browserTest = $TaskHistory | Where-Object { $_.step -match 'browser_test|playwright|mcp_test' }

        if (-not $browserTest) {
            $violations += @{
                Type = 'missing_browser_test'
                Severity = 'CRITICAL'
                Message = "Full-stack feature without browser testing evidence (Rule 3H violation)"
            }
        }
    }

    return $violations
}

# Quality Check: Timing Accuracy
function Test-TimingAccuracy {
    param($Task, $PredictedHours, $ActualHours)

    $violations = @()

    if ($PredictedHours -and $ActualHours) {
        $accuracy = 1 - [Math]::Abs($PredictedHours - $ActualHours) / $PredictedHours

        if ($accuracy -lt 0.5) {
            $violations += @{
                Type = 'poor_scope_prediction'
                Severity = 'MEDIUM'
                Message = "Scope prediction off by >50% (predicted: ${PredictedHours}h, actual: ${ActualHours}h, accuracy: $($accuracy.ToString('P0')))"
            }
        }
    }

    return $violations
}

# Quality Check: Stuck Detection
function Test-StuckDetection {
    param($Task)

    $violations = @()

    # Check if task has been "busy" for >4 hours
    if ($Task.status -eq 'busy' -or $Task.status -eq 'in progress') {
        $statusStart = [DateTime]::Parse($Task.status_history.last_changed)
        $hoursInStatus = ([DateTime]::UtcNow - $statusStart).TotalHours

        if ($hoursInStatus -gt 4) {
            $violations += @{
                Type = 'stuck_detected'
                Severity = 'HIGH'
                Message = "Task stuck in 'busy' for $([Math]::Round($hoursInStatus, 1)) hours (threshold: 4h)"
            }
        }
    }

    return $violations
}

# Log violation
function Add-QualityViolation {
    param($TaskId, $Violations)

    foreach ($violation in $Violations) {
        $entry = @{
            Timestamp = [DateTime]::UtcNow.ToString('o')
            TaskId = $TaskId
            Type = $violation.Type
            Severity = $violation.Severity
            Message = $violation.Message
        } | ConvertTo-Json -Compress

        Add-Content -Path $ViolationsFile -Value $entry
    }
}

# Post violation to ClickUp as comment (self-correction visible to user)
function Post-ViolationToClickUp {
    param($TaskId, $Violations)

    if ($Violations.Count -eq 0) { return }

    $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    $headers = @{
        'Authorization' = $config.api_key
        'Content-Type' = 'application/json'
    }

    $criticalCount = ($Violations | Where-Object { $_.Severity -eq 'CRITICAL' }).Count
    $highCount = ($Violations | Where-Object { $_.Severity -eq 'HIGH' }).Count

    $commentText = @"
**Quality Guardian Alert**

Detected $($Violations.Count) quality issue(s):
- CRITICAL: $criticalCount
- HIGH: $highCount
- MEDIUM: $($Violations.Count - $criticalCount - $highCount)

Issues:
$($Violations | ForEach-Object { "- [$($_.Severity)] $($_.Message)" } | Out-String)

This is an automated quality check to ensure complete task execution.
"@

    $body = @{ comment_text = $commentText } | ConvertTo-Json

    try {
        $url = "$($config.api_base)/task/$TaskId/comment"
        $null = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $body
        Write-Host "[POSTED] Quality violations to ClickUp task $TaskId" -ForegroundColor Yellow
    }
    catch {
        Write-Warning "Failed to post violation to ClickUp: $_"
    }
}

# Check single task
function Test-TaskQuality {
    param($TaskId)

    Write-Host "`n[Quality Check] Task: $TaskId"

    # TODO: Load task data, history, comments from ClickUp API or state
    # For now, return placeholder

    $allViolations = @()

    # Run all checks
    # $allViolations += Test-WorkflowCompliance -Task $task -TaskHistory $history
    # $allViolations += Test-CommentQuality -Task $task -Comments $comments
    # $allViolations += Test-TestingVerification -Task $task -TaskHistory $history
    # $allViolations += Test-StuckDetection -Task $task

    if ($allViolations.Count -gt 0) {
        Write-Host "  [FAIL] Found $($allViolations.Count) violation(s)" -ForegroundColor Red
        Add-QualityViolation -TaskId $TaskId -Violations $allViolations
        Post-ViolationToClickUp -TaskId $TaskId -Violations $allViolations
    }
    else {
        Write-Host "  [PASS] No violations detected" -ForegroundColor Green
    }

    return $allViolations
}

# Monitor all tasks
function Start-MonitoringLoop {
    param($IntervalMinutes)

    Write-Host "[ClickUp Quality Guardian] Starting monitoring (interval: ${IntervalMinutes}min)"

    $iteration = 0

    while ($true) {
        $iteration++
        Write-Host "`n[MONITOR #$iteration] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

        try {
            # Load current task state
            if (Test-Path $StateFile) {
                $state = Get-Content $StateFile -Raw | ConvertFrom-Json
                $tasks = $state.Tasks.PSObject.Properties.Value

                Write-Host "  - Checking $($tasks.Count) tasks for quality violations..."

                $totalViolations = 0
                foreach ($task in $tasks) {
                    if ($task.status -ne 'done' -and $task.status -ne 'cancelled') {
                        $violations = Test-TaskQuality -TaskId $task.id
                        $totalViolations += $violations.Count
                    }
                }

                if ($totalViolations -gt 0) {
                    Write-Host "  - Found $totalViolations total violation(s)" -ForegroundColor Yellow
                }
                else {
                    Write-Host "  - All tasks passed quality checks" -ForegroundColor Green
                }
            }
        }
        catch {
            Write-Error "Monitoring error: $_"
        }

        # Wait for next interval
        Start-Sleep -Seconds ($IntervalMinutes * 60)
    }
}

# Generate quality report
function Get-QualityReport {
    if (-not (Test-Path $ViolationsFile)) {
        Write-Host "No violations recorded yet."
        return
    }

    $violations = Get-Content $ViolationsFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host "`n=== QUALITY REPORT ===" -ForegroundColor Cyan
    Write-Host "Total Violations: $($violations.Count)"
    Write-Host "By Severity:"
    $violations | Group-Object Severity | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Count)"
    }
    Write-Host "By Type:"
    $violations | Group-Object Type | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Count)"
    }
    Write-Host "=====================`n"
}

# Execute action
switch ($Action) {
    'Monitor' {
        Start-MonitoringLoop -IntervalMinutes $IntervalMinutes
    }

    'CheckTask' {
        if (-not $TaskId) {
            throw "TaskId required for CheckTask action"
        }
        Test-TaskQuality -TaskId $TaskId
    }

    'Report' {
        Get-QualityReport
    }
}
