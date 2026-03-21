# ClickHub Learning Engine - Pattern Recognition & Auto-Prioritization
# Version: 1.0.0
# Created: 2026-02-28

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("RecordSuccess", "RecordFailure", "AnalyzePatterns", "PrioritizeTasks", "GetStats")]
    [string]$Action = "PrioritizeTasks",

    [Parameter(Mandatory=$false)]
    [string]$TaskId,

    [Parameter(Mandatory=$false)]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [string]$AgentId,

    [Parameter(Mandatory=$false)]
    [int]$CompletionMinutes,

    [Parameter(Mandatory=$false)]
    [string]$FailureReason,

    [Parameter(Mandatory=$false)]
    [array]$Tasks
)

$learningFile = "C:\scripts\_machine\clickhub-learning.json"

# Load learning data
function Load-LearningData {
    if (Test-Path $learningFile) {
        return Get-Content $learningFile | ConvertFrom-Json
    }

    # Return default structure
    return @{
        version = "1.0.0"
        last_updated = (Get-Date -Format "o")
        task_history = @{}
        failure_patterns = @()
        success_patterns = @()
        project_stats = @{}
        agent_performance = @{}
        priority_weights = @{
            clickup_priority = 3.0
            historical_difficulty = 0.5
            blocks_other_tasks = 2.0
            age_in_days = 0.1
            user_requested = 5.0
            has_deadline = 4.0
        }
    }
}

# Save learning data
function Save-LearningData {
    param($data)
    $data.last_updated = Get-Date -Format "o"
    $data | ConvertTo-Json -Depth 10 | Set-Content $learningFile
}

# Record successful task completion
function Record-Success {
    param($taskId, $project, $agentId, $completionMinutes)

    $data = Load-LearningData

    # Update task history
    if (-not $data.task_history.$taskId) {
        $data.task_history.$taskId = @{
            attempts = 0
            successes = 0
            failures = 0
            avg_completion_minutes = 0
            last_attempt = ""
        }
    }

    $history = $data.task_history.$taskId
    $history.attempts++
    $history.successes++
    $history.last_attempt = Get-Date -Format "o"

    # Update average completion time
    if ($completionMinutes -gt 0) {
        $totalMinutes = $history.avg_completion_minutes * ($history.successes - 1)
        $history.avg_completion_minutes = [math]::Round(($totalMinutes + $completionMinutes) / $history.successes, 1)
    }

    # Update project stats
    if (-not $data.project_stats.$project) {
        $data.project_stats.$project = @{
            total_tasks = 0
            success_rate = 0.0
            avg_completion_minutes = 0
            common_issues = @()
        }
    }

    $projStats = $data.project_stats.$project
    $projStats.total_tasks++
    $totalSuccess = $projStats.success_rate * ($projStats.total_tasks - 1) + 1
    $projStats.success_rate = [math]::Round($totalSuccess / $projStats.total_tasks, 3)

    if ($completionMinutes -gt 0) {
        $totalTime = $projStats.avg_completion_minutes * ($projStats.total_tasks - 1)
        $projStats.avg_completion_minutes = [math]::Round(($totalTime + $completionMinutes) / $projStats.total_tasks, 1)
    }

    # Update agent performance
    if (-not $data.agent_performance.$agentId) {
        $data.agent_performance.$agentId = @{
            tasks_completed = 0
            success_rate = 0.0
            specialization = @()
        }
    }

    $agentPerf = $data.agent_performance.$agentId
    $agentPerf.tasks_completed++
    $totalAgentSuccess = $agentPerf.success_rate * ($agentPerf.tasks_completed - 1) + 1
    $agentPerf.success_rate = [math]::Round($totalAgentSuccess / $agentPerf.tasks_completed, 3)

    # Track specialization (project agent works on most)
    if ($agentPerf.specialization -notcontains $project) {
        $agentPerf.specialization += $project
    }

    Save-LearningData $data

    if ($Verbose) {
        Write-Host "[LEARNING] Recorded success for task $taskId" -ForegroundColor Green
        Write-Host "  Project: $project | Agent: $agentId | Time: $completionMinutes min" -ForegroundColor Gray
        Write-Host "  Task success rate: $($history.successes)/$($history.attempts)" -ForegroundColor Gray
    }
}

# Record task failure
function Record-Failure {
    param($taskId, $project, $agentId, $failureReason)

    $data = Load-LearningData

    # Update task history
    if (-not $data.task_history.$taskId) {
        $data.task_history.$taskId = @{
            attempts = 0
            successes = 0
            failures = 0
            failure_reasons = @()
            last_attempt = ""
        }
    }

    $history = $data.task_history.$taskId
    $history.attempts++
    $history.failures++
    $history.last_attempt = Get-Date -Format "o"

    if (-not $history.failure_reasons) {
        $history.failure_reasons = @()
    }
    $history.failure_reasons += @{
        reason = $failureReason
        timestamp = Get-Date -Format "o"
        agent = $agentId
    }

    # Extract and record pattern
    $pattern = Extract-FailurePattern $failureReason $project
    if ($pattern) {
        $existingPattern = $data.failure_patterns | Where-Object { $_.pattern -eq $pattern }
        if ($existingPattern) {
            $existingPattern.occurrences++
            $existingPattern.last_seen = Get-Date -Format "o"
        } else {
            $data.failure_patterns += @{
                pattern = $pattern
                projects = @($project)
                occurrences = 1
                solution = Auto-Suggest-Solution $pattern
                first_seen = Get-Date -Format "o"
                last_seen = Get-Date -Format "o"
            }
        }
    }

    # Update project stats
    if (-not $data.project_stats.$project) {
        $data.project_stats.$project = @{
            total_tasks = 0
            success_rate = 1.0
            common_issues = @()
        }
    }

    $projStats = $data.project_stats.$project
    $projStats.total_tasks++
    $totalSuccess = $projStats.success_rate * ($projStats.total_tasks - 1)
    $projStats.success_rate = [math]::Round($totalSuccess / $projStats.total_tasks, 3)

    # Track common issues
    if ($projStats.common_issues -notcontains $failureReason) {
        $projStats.common_issues += $failureReason
    }

    Save-LearningData $data

    if ($Verbose) {
        Write-Host "[LEARNING] Recorded failure for task $taskId" -ForegroundColor Red
        Write-Host "  Project: $project | Agent: $agentId" -ForegroundColor Gray
        Write-Host "  Reason: $failureReason" -ForegroundColor Gray
        Write-Host "  Task failure rate: $($history.failures)/$($history.attempts)" -ForegroundColor Gray
    }
}

# Extract failure pattern from reason
function Extract-FailurePattern {
    param($reason, $project)

    $patterns = @{
        "merge conflict" = "Merge conflicts with develop"
        "build error" = "Build compilation failure"
        "test fail" = "Test failures"
        "missing credentials" = "Missing authentication credentials"
        "dependency" = "Dependency resolution failure"
        "timeout" = "Operation timeout"
        "permission" = "Permission denied"
    }

    foreach ($key in $patterns.Keys) {
        if ($reason -match $key) {
            return $patterns[$key]
        }
    }

    return $null
}

# Auto-suggest solution based on pattern
function Auto-Suggest-Solution {
    param($pattern)

    $solutions = @{
        "Merge conflicts with develop" = "Merge develop into feature branch before starting work"
        "Build compilation failure" = "Run dotnet build locally before committing"
        "Test failures" = "Run tests locally before creating PR"
        "Missing authentication credentials" = "Check vault for credentials before starting"
        "Dependency resolution failure" = "Run npm install or dotnet restore before building"
        "Operation timeout" = "Increase timeout or check network connection"
        "Permission denied" = "Check file permissions or run with elevated privileges"
    }

    return $solutions[$pattern]
}

# Analyze patterns and generate insights
function Analyze-Patterns {
    $data = Load-LearningData

    Write-Host "`n=== PATTERN ANALYSIS ===" -ForegroundColor Cyan

    # Top failure patterns
    Write-Host "`nTop Failure Patterns:" -ForegroundColor Yellow
    $topFailures = $data.failure_patterns | Sort-Object -Property occurrences -Descending | Select-Object -First 5

    foreach ($pattern in $topFailures) {
        Write-Host "  - $($pattern.pattern) (x$($pattern.occurrences))" -ForegroundColor Red
        Write-Host "    Solution: $($pattern.solution)" -ForegroundColor Gray
        Write-Host "    Projects: $($pattern.projects -join ', ')" -ForegroundColor Gray
    }

    # Project statistics
    Write-Host "`nProject Performance:" -ForegroundColor Yellow
    foreach ($proj in $data.project_stats.Keys) {
        $stats = $data.project_stats.$proj
        $successPercent = [math]::Round($stats.success_rate * 100, 1)
        Write-Host "  - $proj" -ForegroundColor White
        Write-Host "    Success Rate: $successPercent%" -ForegroundColor Gray
        Write-Host "    Avg Completion: $($stats.avg_completion_minutes) minutes" -ForegroundColor Gray
        Write-Host "    Total Tasks: $($stats.total_tasks)" -ForegroundColor Gray
    }

    # Agent performance
    Write-Host "`nAgent Performance:" -ForegroundColor Yellow
    foreach ($agent in $data.agent_performance.Keys) {
        $perf = $data.agent_performance.$agent
        $successPercent = [math]::Round($perf.success_rate * 100, 1)
        Write-Host "  - $agent" -ForegroundColor White
        Write-Host "    Success Rate: $successPercent%" -ForegroundColor Gray
        Write-Host "    Tasks Completed: $($perf.tasks_completed)" -ForegroundColor Gray
        Write-Host "    Specialization: $($perf.specialization -join ', ')" -ForegroundColor Gray
    }
}

# Prioritize tasks using learning data
function Prioritize-Tasks {
    param($tasks)

    if (-not $tasks -or $tasks.Count -eq 0) {
        Write-Host "No tasks provided for prioritization" -ForegroundColor Yellow
        return @()
    }

    $data = Load-LearningData
    $weights = $data.priority_weights

    $scoredTasks = @()

    foreach ($task in $tasks) {
        $score = 0.0

        # ClickUp priority (urgent=1, high=2, normal=3, low=4)
        $priorityValue = switch ($task.priority.priority) {
            "urgent" { 4 }
            "high" { 3 }
            "normal" { 2 }
            "low" { 1 }
            default { 2 }
        }
        $score += $priorityValue * $weights.clickup_priority

        # Historical difficulty
        if ($data.task_history.$($task.id)) {
            $history = $data.task_history.$($task.id)
            if ($history.failures -gt 0) {
                $difficulty = [math]::Min($history.failures * 2, 10)
                $score += $difficulty * $weights.historical_difficulty
            }
        }

        # Age (how long in todo)
        $createdDate = [DateTimeOffset]::FromUnixTimeMilliseconds($task.date_created)
        $ageInDays = ((Get-Date) - $createdDate).TotalDays
        $score += $ageInDays * $weights.age_in_days

        # Has deadline
        if ($task.due_date) {
            $score += $weights.has_deadline

            # Urgent if deadline within 24 hours
            $dueDate = [DateTimeOffset]::FromUnixTimeMilliseconds($task.due_date)
            $hoursUntilDue = ($dueDate - (Get-Date)).TotalHours
            if ($hoursUntilDue -lt 24 -and $hoursUntilDue -gt 0) {
                $score += 10  # Urgent boost
            }
        }

        # User requested (check for mentions in description)
        if ($task.description -match "@\w+" -or $task.description -match "urgent" -or $task.description -match "ASAP") {
            $score += $weights.user_requested
        }

        # Add score to task
        $task | Add-Member -NotePropertyName "PriorityScore" -NotePropertyValue $score -Force

        # Add difficulty estimate
        $difficultyEstimate = "Unknown"
        if ($data.task_history.$($task.id)) {
            $avgTime = $data.task_history.$($task.id).avg_completion_minutes
            $difficultyEstimate = if ($avgTime -lt 30) { "Easy" }
                                 elseif ($avgTime -lt 60) { "Medium" }
                                 else { "Hard" }
        }
        $task | Add-Member -NotePropertyName "DifficultyEstimate" -NotePropertyValue $difficultyEstimate -Force

        $scoredTasks += $task
    }

    # Sort by priority score (descending)
    $sortedTasks = $scoredTasks | Sort-Object -Property PriorityScore -Descending

    if ($Verbose) {
        Write-Host "`n=== TASK PRIORITIZATION ===" -ForegroundColor Cyan
        foreach ($task in $sortedTasks | Select-Object -First 10) {
            Write-Host "`nTask: $($task.name)" -ForegroundColor White
            Write-Host "  ID: $($task.id)" -ForegroundColor Gray
            Write-Host "  Score: $($task.PriorityScore)" -ForegroundColor Yellow
            Write-Host "  Difficulty: $($task.DifficultyEstimate)" -ForegroundColor Gray
            Write-Host "  Priority: $($task.priority.priority)" -ForegroundColor Gray
        }
    }

    return $sortedTasks
}

# Get statistics
function Get-Stats {
    $data = Load-LearningData

    $totalTasks = 0
    $totalSuccesses = 0
    foreach ($proj in $data.project_stats.Keys) {
        $stats = $data.project_stats.$proj
        $totalTasks += $stats.total_tasks
        $totalSuccesses += [math]::Round($stats.total_tasks * $stats.success_rate)
    }

    $overallSuccessRate = if ($totalTasks -gt 0) {
        [math]::Round(($totalSuccesses / $totalTasks) * 100, 1)
    } else {
        0
    }

    return @{
        total_tasks = $totalTasks
        success_rate = $overallSuccessRate
        failure_patterns_count = $data.failure_patterns.Count
        agents_tracked = $data.agent_performance.Keys.Count
    }
}

# Main execution
switch ($Action) {
    "RecordSuccess" {
        if (-not $TaskId -or -not $Project -or -not $AgentId) {
            Write-Host "Error: TaskId, Project, and AgentId required for RecordSuccess" -ForegroundColor Red
            exit 1
        }
        Record-Success -taskId $TaskId -project $Project -agentId $AgentId -completionMinutes $CompletionMinutes
    }

    "RecordFailure" {
        if (-not $TaskId -or -not $Project -or -not $AgentId -or -not $FailureReason) {
            Write-Host "Error: TaskId, Project, AgentId, and FailureReason required for RecordFailure" -ForegroundColor Red
            exit 1
        }
        Record-Failure -taskId $TaskId -project $Project -agentId $AgentId -failureReason $FailureReason
    }

    "AnalyzePatterns" {
        Analyze-Patterns
    }

    "PrioritizeTasks" {
        if (-not $Tasks) {
            Write-Host "Error: Tasks array required for PrioritizeTasks" -ForegroundColor Red
            exit 1
        }
        $prioritized = Prioritize-Tasks -tasks $Tasks
        return $prioritized
    }

    "GetStats" {
        $stats = Get-Stats
        Write-Host "`n=== CLICKHUB LEARNING STATS ===" -ForegroundColor Cyan
        Write-Host "Total Tasks Processed: $($stats.total_tasks)" -ForegroundColor White
        Write-Host "Overall Success Rate: $($stats.success_rate)%" -ForegroundColor White
        Write-Host "Failure Patterns Identified: $($stats.failure_patterns_count)" -ForegroundColor White
        Write-Host "Agents Tracked: $($stats.agents_tracked)" -ForegroundColor White
        return $stats
    }
}
