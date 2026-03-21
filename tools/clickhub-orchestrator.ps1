# ClickHub Multi-Agent Orchestrator
# Version: 1.0.0
# Created: 2026-02-28
# Purpose: Coordinate multiple agents working in parallel

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Start", "Status", "Stop", "Balance")]
    [string]$Action = "Start",

    [Parameter(Mandatory=$false)]
    [int]$MaxAgents = 6,

    [Parameter(Mandatory=$false)]
    [array]$Projects,

    [Parameter(Mandatory=$false)]
    [int]$CycleDurationMinutes = 10,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$orchestratorStateFile = "C:\scripts\_machine\clickhub-orchestrator-state.json"
$worktreePoolFile = "C:\scripts\_machine\worktrees.pool.md"
$learningFile = "C:\scripts\_machine\clickhub-learning.json"

# Load orchestrator state
function Load-OrchestratorState {
    if (Test-Path $orchestratorStateFile) {
        return Get-Content $orchestratorStateFile | ConvertFrom-Json
    }

    return @{
        version = "1.0.0"
        status = "stopped"
        started_at = $null
        agents = @{}
        cycles_completed = 0
        tasks_completed = 0
        last_cycle = $null
    }
}

# Save orchestrator state
function Save-OrchestratorState {
    param($state)
    $state.last_updated = Get-Date -Format "o"
    $state | ConvertTo-Json -Depth 10 | Set-Content $orchestratorStateFile
}

# Get available agent seats
function Get-AvailableAgents {
    if (-not (Test-Path $worktreePoolFile)) {
        Write-Host "Error: Worktree pool file not found at $worktreePoolFile" -ForegroundColor Red
        return @()
    }

    $poolContent = Get-Content $worktreePoolFile -Raw
    $lines = $poolContent -split "`n"

    $availableAgents = @()

    foreach ($line in $lines) {
        if ($line -match '\|\s*(agent-\d+)\s*\|.*\|\s*FREE\s*\|') {
            $agentId = $matches[1]
            $availableAgents += @{
                id = $agentId
                status = "FREE"
            }
        }
    }

    return $availableAgents
}

# Get all tasks across configured projects
function Get-AllUnassignedTasks {
    param($projects)

    # Load config
    $config = Get-Content "C:\scripts\_machine\clickup-config.json" | ConvertFrom-Json

    $allTasks = @()

    # Default projects if not specified
    if (-not $projects) {
        $internalProjects = @("client-manager", "hazina", "brand2boost-birdseye", "learningtool")
        $clientProjects = @("art-revisionist", "vera-ai", "wreckingball", "cloudgrafo", "vloerenhuis")
        $projects = $internalProjects + $clientProjects
    }

    foreach ($project in $projects) {
        if (-not $config.projects.$project) {
            if ($Verbose) {
                Write-Host "Warning: Project $project not found in config" -ForegroundColor Yellow
            }
            continue
        }

        $listId = $config.projects.$project.list_id

        # Fetch tasks (using clickup-sync.ps1)
        try {
            $tasks = & "C:\scripts\tools\clickup-sync.ps1" -Action list -ListId $listId 2>$null

            if ($tasks) {
                # Filter unassigned tasks in todo status
                $unassigned = $tasks | Where-Object {
                    $_.assignees.Count -eq 0 -and
                    ($_.status.status -match "todo|to do|backlog|refined")
                }

                # Add project context
                foreach ($task in $unassigned) {
                    $task | Add-Member -NotePropertyName "ProjectContext" -NotePropertyValue $project -Force
                    $task | Add-Member -NotePropertyName "ProjectType" -NotePropertyValue $config.projects.$project.type -Force
                }

                $allTasks += $unassigned
            }
        } catch {
            Write-Host "Warning: Failed to fetch tasks for $project - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    if ($Verbose) {
        Write-Host "Found $($allTasks.Count) unassigned tasks across $($projects.Count) projects" -ForegroundColor Cyan
    }

    return $allTasks
}

# Prioritize and score tasks using learning engine
function Prioritize-And-Score-Tasks {
    param($tasks)

    if ($tasks.Count -eq 0) {
        return @()
    }

    # Use learning engine to prioritize
    $prioritized = & "C:\scripts\tools\clickhub-learning-engine.ps1" -Action PrioritizeTasks -Tasks $tasks -Verbose:$Verbose

    return $prioritized
}

# Match agent to task based on specialization
function Match-Agent-To-Task {
    param($task, $availableAgents)

    # Load learning data to check agent specialization
    $learningData = if (Test-Path $learningFile) {
        Get-Content $learningFile | ConvertFrom-Json
    } else {
        $null
    }

    # Scoring system for agent-task matching
    $agentScores = @{}

    foreach ($agent in $availableAgents) {
        $score = 0

        # Check if agent has worked on this project before
        if ($learningData -and $learningData.agent_performance.$($agent.id)) {
            $agentPerf = $learningData.agent_performance.$($agent.id)
            if ($agentPerf.specialization -contains $task.ProjectContext) {
                $score += 5  # Prefer specialized agents
            }

            # Higher success rate = higher score
            $score += $agentPerf.success_rate * 3
        }

        # Task type matching (if we have environment info)
        # Frontend tasks prefer agents with browser MCP
        # Backend tasks prefer agents with VS debugger
        # WordPress tasks prefer agents with XAMPP access

        $agentScores[$agent.id] = $score
    }

    # Pick highest scoring agent (or random if all equal)
    $bestAgent = $availableAgents | Sort-Object { $agentScores[$_.id] } -Descending | Select-Object -First 1

    return $bestAgent
}

# Assign task to agent
function Assign-Task-To-Agent {
    param($task, $agent, $state)

    if ($DryRun) {
        Write-Host "[DRY RUN] Would assign task $($task.id) to $($agent.id)" -ForegroundColor Yellow
        return
    }

    # Record assignment in state
    $state.agents.$($agent.id) = @{
        status = "BUSY"
        task_id = $task.id
        task_name = $task.name
        project = $task.ProjectContext
        started_at = Get-Date -Format "o"
        expected_completion = (Get-Date).AddMinutes(45).ToString("o")  # Default 45min estimate
    }

    if ($Verbose) {
        Write-Host "Assigned task $($task.id) ($($task.name)) to $($agent.id)" -ForegroundColor Green
        Write-Host "  Project: $($task.ProjectContext) | Priority Score: $($task.PriorityScore)" -ForegroundColor Gray
    }

    # Trigger agent execution (spawn background process)
    Invoke-Agent $agent.id $task
}

# Invoke agent in background
function Invoke-Agent {
    param($agentId, $task)

    $scriptBlock = {
        param($agentId, $taskId, $project)

        # This would invoke the actual clickhub-coding-agent skill
        # For now, placeholder
        Write-Host "Agent $agentId starting work on task $taskId in project $project"

        # In production, this would:
        # 1. Allocate worktree
        # 2. Run clickhub-coding-agent workflow
        # 3. Record completion/failure
    }

    if (-not $DryRun) {
        Start-Job -Name "ClickHub-$agentId" -ScriptBlock $scriptBlock -ArgumentList $agentId, $task.id, $task.ProjectContext
    }

    Write-Host "Started background job for $agentId on task $($task.id)" -ForegroundColor Cyan
}

# Monitor agent progress
function Monitor-Agent-Progress {
    param($state)

    $activeAgents = $state.agents.Keys | Where-Object { $state.agents.$_.status -eq "BUSY" }

    foreach ($agentId in $activeAgents) {
        $agentState = $state.agents.$agentId

        # Check if agent is still running
        $job = Get-Job -Name "ClickHub-$agentId" -ErrorAction SilentlyContinue

        if ($job) {
            if ($job.State -eq "Completed") {
                # Agent finished
                Write-Host "Agent $agentId completed task $($agentState.task_id)" -ForegroundColor Green

                # Record success
                $completionTime = ((Get-Date) - [DateTime]$agentState.started_at).TotalMinutes
                & "C:\scripts\tools\clickhub-learning-engine.ps1" -Action RecordSuccess `
                    -TaskId $agentState.task_id `
                    -Project $agentState.project `
                    -AgentId $agentId `
                    -CompletionMinutes ([math]::Round($completionTime))

                # Mark agent as free
                $state.agents.$agentId = @{ status = "FREE" }
                $state.tasks_completed++

                Remove-Job -Name "ClickHub-$agentId"
            }
            elseif ($job.State -eq "Failed") {
                # Agent failed
                Write-Host "Agent $agentId failed task $($agentState.task_id)" -ForegroundColor Red

                # Record failure
                & "C:\scripts\tools\clickhub-learning-engine.ps1" -Action RecordFailure `
                    -TaskId $agentState.task_id `
                    -Project $agentState.project `
                    -AgentId $agentId `
                    -FailureReason "Job execution failed"

                # Mark agent as free
                $state.agents.$agentId = @{ status = "FREE" }

                Remove-Job -Name "ClickHub-$agentId"
            }
        } else {
            # Job not found - might have crashed
            $timeSinceStart = ((Get-Date) - [DateTime]$agentState.started_at).TotalMinutes

            if ($timeSinceStart -gt 120) {  # 2 hour timeout
                Write-Host "Agent $agentId timed out on task $($agentState.task_id)" -ForegroundColor Red
                $state.agents.$agentId = @{ status = "FREE" }
            }
        }
    }

    Save-OrchestratorState $state
}

# Start orchestrator
function Start-Orchestrator {
    $state = Load-OrchestratorState
    $state.status = "running"
    $state.started_at = Get-Date -Format "o"

    Write-Host "`n=== CLICKHUB ORCHESTRATOR STARTED ===" -ForegroundColor Green
    Write-Host "Max Agents: $MaxAgents" -ForegroundColor Cyan
    Write-Host "Cycle Duration: $CycleDurationMinutes minutes" -ForegroundColor Cyan
    Write-Host "Projects: $($Projects -join ', ')" -ForegroundColor Cyan

    $cycleCount = 0

    while ($state.status -eq "running") {
        $cycleCount++
        Write-Host "`n--- Cycle $cycleCount ---" -ForegroundColor Yellow
        $state.cycles_completed = $cycleCount
        $state.last_cycle = Get-Date -Format "o"

        # 1. Get available agents
        $availableAgents = Get-AvailableAgents
        Write-Host "Available agents: $($availableAgents.Count)" -ForegroundColor Cyan

        # 2. Get all unassigned tasks
        $tasks = Get-AllUnassignedTasks -projects $Projects
        Write-Host "Unassigned tasks: $($tasks.Count)" -ForegroundColor Cyan

        if ($tasks.Count -eq 0) {
            Write-Host "No tasks to process. Sleeping..." -ForegroundColor Gray
        } else {
            # 3. Prioritize tasks
            $prioritizedTasks = Prioritize-And-Score-Tasks -tasks $tasks

            # 4. Assign tasks to agents
            $assignedCount = 0
            foreach ($task in $prioritizedTasks) {
                if ($availableAgents.Count -eq 0) {
                    Write-Host "No more available agents. Queuing remaining tasks..." -ForegroundColor Yellow
                    break
                }

                if ($assignedCount -ge $MaxAgents) {
                    break
                }

                # Match agent to task
                $agent = Match-Agent-To-Task -task $task -availableAgents $availableAgents

                # Assign
                Assign-Task-To-Agent -task $task -agent $agent -state $state

                # Remove from available pool
                $availableAgents = $availableAgents | Where-Object { $_.id -ne $agent.id }

                $assignedCount++
            }

            Write-Host "Assigned $assignedCount tasks to agents" -ForegroundColor Green
        }

        # 5. Monitor progress
        Monitor-Agent-Progress -state $state

        Save-OrchestratorState $state

        # 6. Sleep before next cycle
        Write-Host "Sleeping for $CycleDurationMinutes minutes..." -ForegroundColor Gray
        Start-Sleep -Seconds ($CycleDurationMinutes * 60)

        # Check if should stop (check for stop flag file)
        if (Test-Path "C:\scripts\_machine\clickhub-stop.flag") {
            Write-Host "`nStop flag detected. Shutting down gracefully..." -ForegroundColor Yellow
            $state.status = "stopped"
            Remove-Item "C:\scripts\_machine\clickhub-stop.flag"
            break
        }
    }

    Write-Host "`n=== ORCHESTRATOR STOPPED ===" -ForegroundColor Red
    Write-Host "Total Cycles: $cycleCount" -ForegroundColor Cyan
    Write-Host "Tasks Completed: $($state.tasks_completed)" -ForegroundColor Cyan

    Save-OrchestratorState $state
}

# Show status
function Show-Status {
    $state = Load-OrchestratorState

    Write-Host "`n=== CLICKHUB ORCHESTRATOR STATUS ===" -ForegroundColor Cyan
    Write-Host "Status: $($state.status)" -ForegroundColor White
    Write-Host "Started At: $($state.started_at)" -ForegroundColor White
    Write-Host "Cycles Completed: $($state.cycles_completed)" -ForegroundColor White
    Write-Host "Tasks Completed: $($state.tasks_completed)" -ForegroundColor White
    Write-Host "Last Cycle: $($state.last_cycle)" -ForegroundColor White

    Write-Host "`nActive Agents:" -ForegroundColor Yellow
    foreach ($agentId in $state.agents.Keys) {
        $agentState = $state.agents.$agentId
        if ($agentState.status -eq "BUSY") {
            Write-Host "  - $agentId" -ForegroundColor White
            Write-Host "    Task: $($agentState.task_id) - $($agentState.task_name)" -ForegroundColor Gray
            Write-Host "    Project: $($agentState.project)" -ForegroundColor Gray
            Write-Host "    Started: $($agentState.started_at)" -ForegroundColor Gray
        }
    }
}

# Stop orchestrator
function Stop-Orchestrator {
    # Create stop flag
    "STOP" | Set-Content "C:\scripts\_machine\clickhub-stop.flag"
    Write-Host "Stop flag created. Orchestrator will shut down after current cycle." -ForegroundColor Yellow
}

# Main execution
switch ($Action) {
    "Start" {
        Start-Orchestrator
    }
    "Status" {
        Show-Status
    }
    "Stop" {
        Stop-Orchestrator
    }
    "Balance" {
        # Future: Rebalance workload across agents
        Write-Host "Load balancing not yet implemented" -ForegroundColor Yellow
    }
}
