# agent-coordinator.ps1
# Central coordinator for multi-agent orchestration
# Manages agent lifecycle, priority, load balancing, and work distribution

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop", "Status", "Assign", "Balance", "Elect")]
    [string]$Action,

    [string]$AgentId = "",
    [string]$Priority = "Normal",  # Low, Normal, High, Critical
    [string]$Task = "",
    [switch]$Force
)

$script:CoordinatorState = "C:\scripts\_machine\coordinator.state.json"
$script:AgentRegistry = "C:\scripts\_machine\agents.registry.json"
$script:WorkQueue = "C:\scripts\_machine\work.queue.json"
$script:PoolFile = "C:\scripts\_machine\worktrees.pool.md"

# Ensure state files exist
foreach ($file in @($script:CoordinatorState, $script:AgentRegistry, $script:WorkQueue)) {
    if (-not (Test-Path $file)) {
        @{} | ConvertTo-Json | Set-Content -Path $file -Force
    }
}

function Get-CoordinatorState {
    if (Test-Path $script:CoordinatorState) {
        return Get-Content $script:CoordinatorState -Raw | ConvertFrom-Json
    }
    return @{
        LeaderId = $null
        LeaderElectedAt = $null
        ActiveAgents = @()
        LastHeartbeat = @{}
    }
}

function Set-CoordinatorState {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content -Path $script:CoordinatorState -Force
}

function Get-AgentRegistry {
    if (Test-Path $script:AgentRegistry) {
        $content = Get-Content $script:AgentRegistry -Raw | ConvertFrom-Json
        # Convert PSCustomObject to hashtable for easier manipulation
        if ($content -is [PSCustomObject]) {
            $hash = @{}
            $content.PSObject.Properties | ForEach-Object {
                $hash[$_.Name] = $_.Value
            }
            return $hash
        }
        return $content
    }
    return @{}
}

function Set-AgentRegistry {
    param($Registry)
    $Registry | ConvertTo-Json -Depth 10 | Set-Content -Path $script:AgentRegistry -Force
}

function Get-WorkQueue {
    if (Test-Path $script:WorkQueue) {
        return Get-Content $script:WorkQueue -Raw | ConvertFrom-Json
    }
    return @{
        Critical = @()
        High = @()
        Normal = @()
        Low = @()
    }
}

function Set-WorkQueue {
    param($Queue)
    $Queue | ConvertTo-Json -Depth 10 | Set-Content -Path $script:WorkQueue -Force
}

function Register-Agent {
    param(
        [string]$AgentId,
        [string]$Status = "Active"
    )

    $registry = Get-AgentRegistry
    $state = Get-CoordinatorState

    $agent = @{
        Id = $AgentId
        Status = $Status
        RegisteredAt = (Get-Date).ToString("o")
        LastHeartbeat = (Get-Date).ToString("o")
        TasksCompleted = 0
        TasksFailed = 0
        CurrentTask = $null
        Capabilities = @("code", "git", "worktree")
        Load = 0.0
    }

    $registry[$AgentId] = $agent
    Set-AgentRegistry -Registry $registry

    # Add to active agents
    if ($state.ActiveAgents -notcontains $AgentId) {
        $state.ActiveAgents += $AgentId
    }
    $state.LastHeartbeat[$AgentId] = (Get-Date).ToString("o")
    Set-CoordinatorState -State $state

    Write-Host "✅ Agent registered: $AgentId" -ForegroundColor Green

    # Trigger leader election if no leader
    if (-not $state.LeaderId) {
        Invoke-LeaderElection
    }
}

function Unregister-Agent {
    param([string]$AgentId, [switch]$Graceful)

    $registry = Get-AgentRegistry
    $state = Get-CoordinatorState

    if ($registry.ContainsKey($AgentId)) {
        if ($Graceful) {
            $registry[$AgentId].Status = "Shutdown"
            Write-Host "🛑 Agent gracefully stopped: $AgentId" -ForegroundColor Yellow
        } else {
            $registry.Remove($AgentId)
            Write-Host "💥 Agent removed: $AgentId" -ForegroundColor Red
        }
        Set-AgentRegistry -Registry $registry
    }

    # Remove from active agents
    $state.ActiveAgents = $state.ActiveAgents | Where-Object { $_ -ne $AgentId }
    $state.LastHeartbeat.PSObject.Properties.Remove($AgentId)
    Set-CoordinatorState -State $state

    # Re-elect leader if this was the leader
    if ($state.LeaderId -eq $AgentId) {
        Write-Host "🔄 Leader removed, triggering re-election..." -ForegroundColor Cyan
        Invoke-LeaderElection
    }
}

function Invoke-LeaderElection {
    $state = Get-CoordinatorState
    $registry = Get-AgentRegistry

    Write-Host "🗳️ Starting leader election..." -ForegroundColor Cyan

    # Get all active agents
    $activeAgents = $state.ActiveAgents | Where-Object {
        $registry.ContainsKey($_) -and $registry[$_].Status -eq "Active"
    }

    if ($activeAgents.Count -eq 0) {
        Write-Host "⚠️ No active agents to elect" -ForegroundColor Yellow
        $state.LeaderId = $null
        $state.LeaderElectedAt = $null
        Set-CoordinatorState -State $state
        return
    }

    # Election strategy: Agent with most tasks completed + oldest registration
    $leader = $activeAgents | ForEach-Object {
        $agent = $registry[$_]
        [PSCustomObject]@{
            Id = $_
            Score = $agent.TasksCompleted * 10 + ([DateTime]::Now - [DateTime]$agent.RegisteredAt).TotalSeconds
            TasksCompleted = $agent.TasksCompleted
            RegisteredAt = $agent.RegisteredAt
        }
    } | Sort-Object -Property Score -Descending | Select-Object -First 1

    $state.LeaderId = $leader.Id
    $state.LeaderElectedAt = (Get-Date).ToString("o")
    Set-CoordinatorState -State $state

    Write-Host "👑 Leader elected: $($leader.Id)" -ForegroundColor Green
    Write-Host "   Tasks completed: $($leader.TasksCompleted)" -ForegroundColor Gray
    Write-Host "   Registered: $($leader.RegisteredAt)" -ForegroundColor Gray
}

function Add-WorkItem {
    param(
        [string]$Task,
        [string]$Priority
    )

    $queue = Get-WorkQueue

    $workItem = @{
        Id = [guid]::NewGuid().ToString()
        Task = $Task
        Priority = $Priority
        AddedAt = (Get-Date).ToString("o")
        AssignedTo = $null
        Status = "Pending"
    }

    $queue.$Priority += $workItem
    Set-WorkQueue -Queue $queue

    Write-Host "➕ Work item added: $($workItem.Id)" -ForegroundColor Green
    Write-Host "   Priority: $Priority" -ForegroundColor Gray
    Write-Host "   Task: $Task" -ForegroundColor Gray

    return $workItem.Id
}

function Get-NextWorkItem {
    param([string]$AgentId)

    $queue = Get-WorkQueue

    # Try priorities in order: Critical → High → Normal → Low
    foreach ($priority in @("Critical", "High", "Normal", "Low")) {
        $pending = $queue.$priority | Where-Object { $_.Status -eq "Pending" } | Select-Object -First 1

        if ($pending) {
            # Assign to agent
            $pending.AssignedTo = $AgentId
            $pending.Status = "Assigned"
            $pending.AssignedAt = (Get-Date).ToString("o")

            Set-WorkQueue -Queue $queue

            Write-Host "📋 Work assigned to $AgentId" -ForegroundColor Cyan
            Write-Host "   Task: $($pending.Task)" -ForegroundColor Gray
            Write-Host "   Priority: $priority" -ForegroundColor Gray

            return $pending
        }
    }

    Write-Host "⚠️ No work available for $AgentId" -ForegroundColor Yellow
    return $null
}

function Invoke-LoadBalancing {
    $registry = Get-AgentRegistry
    $state = Get-CoordinatorState

    Write-Host "⚖️ Balancing load across agents..." -ForegroundColor Cyan

    # Calculate current load for each agent
    $loads = @{}
    foreach ($agentId in $state.ActiveAgents) {
        if ($registry.ContainsKey($agentId)) {
            $agent = $registry[$agentId]
            # Load = 1.0 if has current task, 0.0 if idle
            $load = if ($agent.CurrentTask) { 1.0 } else { 0.0 }
            $loads[$agentId] = $load
        }
    }

    # Find idle agents
    $idleAgents = $loads.Keys | Where-Object { $loads[$_] -eq 0.0 }
    $busyAgents = $loads.Keys | Where-Object { $loads[$_] -gt 0.0 }

    Write-Host "   Idle agents: $($idleAgents.Count)" -ForegroundColor Green
    Write-Host "   Busy agents: $($busyAgents.Count)" -ForegroundColor Yellow

    # Assign work to idle agents
    if ($idleAgents.Count -gt 0) {
        foreach ($agentId in $idleAgents) {
            $work = Get-NextWorkItem -AgentId $agentId
            if ($work) {
                Write-Host "   ✅ Assigned work to $agentId" -ForegroundColor Green
            }
        }
    }

    # TODO: Work stealing from busy agents (if queue is empty but some agents overloaded)
}

function Show-CoordinatorStatus {
    $state = Get-CoordinatorState
    $registry = Get-AgentRegistry
    $queue = Get-WorkQueue

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🎯 AGENT COORDINATOR STATUS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    # Leader info
    if ($state.LeaderId) {
        Write-Host "`n👑 Leader: $($state.LeaderId)" -ForegroundColor Green
        Write-Host "   Elected: $($state.LeaderElectedAt)" -ForegroundColor Gray
    } else {
        Write-Host "`n⚠️ No leader elected" -ForegroundColor Yellow
    }

    # Active agents
    Write-Host "`n👥 Active Agents: $($state.ActiveAgents.Count)" -ForegroundColor Cyan
    foreach ($agentId in $state.ActiveAgents) {
        if ($registry.ContainsKey($agentId)) {
            $agent = $registry[$agentId]
            $lastHeartbeat = [DateTime]$agent.LastHeartbeat
            $heartbeatAge = ((Get-Date) - $lastHeartbeat).TotalSeconds

            $statusColor = if ($agent.Status -eq "Active") { "Green" } else { "Yellow" }
            $heartbeatStatus = if ($heartbeatAge -lt 60) { "✅" } elseif ($heartbeatAge -lt 300) { "⚠️" } else { "❌" }

            Write-Host "   $heartbeatStatus $agentId" -ForegroundColor $statusColor
            Write-Host "      Status: $($agent.Status) | Load: $($agent.Load) | Tasks: $($agent.TasksCompleted) completed, $($agent.TasksFailed) failed" -ForegroundColor Gray
            Write-Host "      Last heartbeat: $([math]::Round($heartbeatAge, 0))s ago" -ForegroundColor DarkGray
            if ($agent.CurrentTask) {
                Write-Host "      Current: $($agent.CurrentTask)" -ForegroundColor DarkGray
            }
        }
    }

    # Work queue
    Write-Host "`n📋 Work Queue:" -ForegroundColor Cyan
    $totalPending = 0
    foreach ($priority in @("Critical", "High", "Normal", "Low")) {
        $pending = ($queue.$priority | Where-Object { $_.Status -eq "Pending" }).Count
        $assigned = ($queue.$priority | Where-Object { $_.Status -eq "Assigned" }).Count
        $total = $pending + $assigned
        if ($total -gt 0) {
            Write-Host "   $priority: $pending pending, $assigned assigned" -ForegroundColor White
        }
        $totalPending += $pending
    }

    if ($totalPending -eq 0) {
        Write-Host "   ✅ Queue empty" -ForegroundColor Green
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# Main logic
switch ($Action) {
    "Start" {
        if (-not $AgentId) {
            Write-Host "❌ Start requires -AgentId parameter" -ForegroundColor Red
            exit 1
        }
        Register-Agent -AgentId $AgentId
        exit 0
    }

    "Stop" {
        if (-not $AgentId) {
            Write-Host "❌ Stop requires -AgentId parameter" -ForegroundColor Red
            exit 1
        }
        Unregister-Agent -AgentId $AgentId -Graceful:(-not $Force)
        exit 0
    }

    "Status" {
        Show-CoordinatorStatus
        exit 0
    }

    "Assign" {
        if (-not $Task) {
            Write-Host "❌ Assign requires -Task parameter" -ForegroundColor Red
            exit 1
        }
        $workId = Add-WorkItem -Task $Task -Priority $Priority
        Invoke-LoadBalancing
        Write-Host "✅ Work item created: $workId" -ForegroundColor Green
        exit 0
    }

    "Balance" {
        Invoke-LoadBalancing
        exit 0
    }

    "Elect" {
        Invoke-LeaderElection
        exit 0
    }
}
