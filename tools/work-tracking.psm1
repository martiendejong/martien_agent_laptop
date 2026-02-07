# work-tracking.psm1
# Live State Engine - PowerShell Module
# Automatic work tracking for multi-agent coordination

# Compatible with PowerShell 5.1 and later

# ============================================================================
# MODULE CONFIGURATION
# ============================================================================

$script:ModuleVersion = "1.0.1"
$script:StatePath = "C:\scripts\_machine\work-state.json"
$script:EventsPath = "C:\scripts\_machine\events"
$script:DatabasePath = "C:\scripts\_machine\work-state.db"
$script:LogPath = "C:\scripts\_machine\logs\work-tracking.log"

# In-memory cache (Improvement #1)
$script:StateCache = @{
    Data = $null
    Timestamp = [DateTime]::MinValue
    TTL = [TimeSpan]::FromSeconds(5)
    FilePath = $script:StatePath
    LastWriteTime = [DateTime]::MinValue
}

# Ensure directories exist
$directories = @(
    (Split-Path $script:StatePath -Parent),
    $script:EventsPath,
    (Split-Path $script:DatabasePath -Parent),
    (Split-Path $script:LogPath -Parent)
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function Send-WorkNotification {
    <#
    .SYNOPSIS
        Send Windows toast notification
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Info', 'Warning', 'Success', 'Error')]
        [string]$Type = 'Info'
    )

    try {
        # Use BurntToast if available, otherwise fallback to basic notification
        if (Get-Command 'New-BurntToastNotification' -ErrorAction SilentlyContinue) {
            $icon = switch ($Type) {
                'Success' { '✅' }
                'Warning' { '⚠️' }
                'Error' { '❌' }
                default { '📊' }
            }

            New-BurntToastNotification -Text "$icon $Title", $Message -Silent
        }
        else {
            # Fallback: PowerShell balloon tip (requires WinForms)
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue

            $balloon = New-Object System.Windows.Forms.NotifyIcon
            $balloon.Icon = [System.Drawing.SystemIcons]::Information
            $balloon.BalloonTipIcon = $Type
            $balloon.BalloonTipText = $Message
            $balloon.BalloonTipTitle = $Title
            $balloon.Visible = $true
            $balloon.ShowBalloonTip(5000)

            Start-Sleep -Milliseconds 500
            $balloon.Dispose()
        }
    }
    catch {
        Write-TrackingLog "Failed to send notification: $_" -Level WARN
    }
}

function Write-TrackingLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG')]
        [string]$Level = 'INFO'
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    $logEntry = "[$timestamp] [$Level] $Message"

    # Write to log file
    Add-Content -Path $script:LogPath -Value $logEntry -ErrorAction SilentlyContinue

    # Also write to console in debug mode
    if ($env:WORK_TRACKING_DEBUG -eq '1') {
        Write-Host $logEntry -ForegroundColor $(switch ($Level) {
            'ERROR' { 'Red' }
            'WARN' { 'Yellow' }
            'DEBUG' { 'Cyan' }
            default { 'Gray' }
        })
    }
}

function Get-AgentId {
    <#
    .SYNOPSIS
        Auto-detect current agent ID from environment or context
    #>

    # Priority 1: Explicit environment variable
    if ($env:AGENT_ID) {
        return $env:AGENT_ID
    }

    # Priority 2: Detect from current directory (worktree path)
    $currentPath = Get-Location
    if ($currentPath -match 'worker-agents\\(agent-\d+)') {
        return $Matches[1]
    }

    # Priority 3: Check git worktree
    try {
        $worktreePath = git rev-parse --show-toplevel 2>$null
        if ($worktreePath -match 'worker-agents\\(agent-\d+)') {
            return $Matches[1]
        }
    }
    catch {
        # Not in a git repository
    }

    # Priority 4: Check process title (if set by agent launcher)
    if ($Host.UI.RawUI.WindowTitle -match 'agent-\d+') {
        if ($Host.UI.RawUI.WindowTitle -match '(agent-\d+)') {
            return $Matches[1]
        }
    }

    # Fallback: current-session (for manual operations)
    return "current-session"
}

function ConvertPSObjectToHashtable {
    param([Parameter(ValueFromPipeline)]$InputObject)

    process {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject.GetType().Name -eq 'Object[]' -or $InputObject.GetType().Name -eq 'ArrayList') {
            $collection = @()
            foreach ($object in $InputObject) {
                $collection += ConvertPSObjectToHashtable $object
            }
            return ,$collection
        }
        elseif ($InputObject.GetType().Name -eq 'PSCustomObject') {
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertPSObjectToHashtable $property.Value
            }
            return $hash
        }
        else {
            return $InputObject
        }
    }
}

function Get-WorkStateObject {
    <#
    .SYNOPSIS
        Load current work state from JSON file (with in-memory caching)
    #>

    # Check cache first (Improvement #1)
    $now = [DateTime]::Now
    $fileInfo = Get-Item $script:StatePath -ErrorAction SilentlyContinue

    if ($script:StateCache.Data -and
        $fileInfo -and
        $fileInfo.LastWriteTime -eq $script:StateCache.LastWriteTime -and
        ($now - $script:StateCache.Timestamp) -lt $script:StateCache.TTL) {

        Write-TrackingLog "Cache hit (age: $($now - $script:StateCache.Timestamp))" -Level DEBUG
        return $script:StateCache.Data
    }

    Write-TrackingLog "Cache miss - loading from disk" -Level DEBUG

    if (-not (Test-Path $script:StatePath)) {
        # Initialize empty state
        return @{
            version = $script:ModuleVersion
            agents = @{}
            summary = @{
                active_agents = 0
                total_tasks_today = 0
                prs_created_today = 0
                current_phase_counts = @{}
            }
            history = @{
                last_10_completions = @()
            }
            metadata = @{
                last_updated = (Get-Date).ToUniversalTime().ToString("o")
                tracking_started = (Get-Date).ToUniversalTime().ToString("o")
            }
        }
    }

    try {
        $json = Get-Content $script:StatePath -Raw -ErrorAction Stop
        $state = $json | ConvertFrom-Json

        # Convert PSCustomObject to hashtable (PowerShell 5.1 compatible)
        $hashtable = ConvertPSObjectToHashtable $state

        # Update cache (Improvement #1)
        $script:StateCache.Data = $hashtable
        $script:StateCache.Timestamp = $now
        $script:StateCache.LastWriteTime = $fileInfo.LastWriteTime

        return $hashtable
    }
    catch {
        Write-TrackingLog "Failed to load work state: $_" -Level ERROR

        # Invalidate cache
        $script:StateCache.Data = $null

        # Return empty state instead of null
        return @{
            version = $script:ModuleVersion
            agents = @{}
            summary = @{
                active_agents = 0
                total_tasks_today = 0
                prs_created_today = 0
                current_phase_counts = @{}
            }
            history = @{
                last_10_completions = @()
            }
            metadata = @{
                last_updated = (Get-Date).ToUniversalTime().ToString("o")
                tracking_started = (Get-Date).ToUniversalTime().ToString("o")
            }
        }
    }
}

function Save-WorkStateObject {
    param(
        [Parameter(Mandatory)]
        [hashtable]$State
    )

    try {
        # Update metadata
        $State.metadata.last_updated = (Get-Date).ToUniversalTime().ToString("o")

        # Recalculate summary
        $activeAgents = ($State.agents.Values | Where-Object { $_.status -ne 'DONE' -and $_.status -ne 'IDLE' }).Count
        $phaseCounts = @{}

        foreach ($agent in $State.agents.Values) {
            if ($agent.status -ne 'DONE' -and $agent.status -ne 'IDLE') {
                if (-not $phaseCounts.ContainsKey($agent.status)) {
                    $phaseCounts[$agent.status] = 0
                }
                $phaseCounts[$agent.status]++
            }
        }

        $State.summary.active_agents = $activeAgents
        $State.summary.current_phase_counts = $phaseCounts

        # Backup current state before overwriting (Improvement #2)
        if (Test-Path $script:StatePath) {
            Copy-Item $script:StatePath "$script:StatePath.backup" -Force
        }

        # Write atomically (temp file + rename)
        $tempPath = "$script:StatePath.tmp"
        $State | ConvertTo-Json -Depth 10 | Set-Content -Path $tempPath -Force
        Move-Item -Path $tempPath -Destination $script:StatePath -Force

        # Invalidate cache after write
        $script:StateCache.Data = $null

        Write-TrackingLog "Saved work state: $activeAgents active agents" -Level DEBUG
    }
    catch {
        Write-TrackingLog "Failed to save work state: $_" -Level ERROR

        # Attempt to restore from backup (Improvement #2)
        $backupPath = "$script:StatePath.backup"
        if (Test-Path $backupPath) {
            Write-TrackingLog "Attempting to restore from backup" -Level WARN
            Copy-Item $backupPath $script:StatePath -Force
        }

        throw
    }
}

function Write-Event {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Event
    )

    try {
        # Ensure timestamp
        if (-not $Event.timestamp) {
            $Event.timestamp = (Get-Date).ToUniversalTime().ToString("o")
        }

        # Get today's event file
        $dateStr = (Get-Date).ToString("yyyy-MM-dd")
        $eventFile = Join-Path $script:EventsPath "$dateStr.jsonl"

        # Append event as JSONL
        $eventJson = $Event | ConvertTo-Json -Compress
        Add-Content -Path $eventFile -Value $eventJson

        Write-TrackingLog "Wrote event: $($Event.type) for $($Event.agent)" -Level DEBUG
    }
    catch {
        Write-TrackingLog "Failed to write event: $_" -Level ERROR
    }
}

# ============================================================================
# CORE PUBLIC FUNCTIONS
# ============================================================================

function Start-Work {
    <#
    .SYNOPSIS
        Register the start of a work session

    .DESCRIPTION
        Records work start event, updates current state, and begins tracking.
        Automatically detects agent ID from environment.

    .PARAMETER Agent
        Agent identifier (auto-detected if not provided)

    .PARAMETER ClickUpTask
        ClickUp task ID (e.g., 869c1xyz)

    .PARAMETER PR
        GitHub PR number (if working on existing PR)

    .PARAMETER Branch
        Git branch name

    .PARAMETER Objective
        Brief description of work objective (max 100 chars)

    .PARAMETER Repository
        Repository name (auto-detected from git if not provided)

    .PARAMETER WorktreePath
        Worktree path (auto-detected if not provided)

    .EXAMPLE
        Start-Work -ClickUpTask "869c1xyz" -Objective "Add user authentication"

    .EXAMPLE
        Start-Work -PR "#507" -Branch "fix/bug-123" -Objective "Fix login bug"
    #>

    [CmdletBinding()]
    param(
        [string]$Agent = (Get-AgentId),
        [string]$ClickUpTask,
        [string]$PR,
        [string]$Branch,
        [Parameter(Mandatory)]
        [ValidateLength(1, 100)]
        [string]$Objective,
        [string]$Repository,
        [string]$WorktreePath
    )

    Write-TrackingLog "Starting work for agent: $Agent, objective: $Objective" -Level INFO

    # Auto-detect repository if not provided
    if (-not $Repository) {
        try {
            $gitTopLevel = git rev-parse --show-toplevel 2>$null
            if ($gitTopLevel) {
                $Repository = Split-Path $gitTopLevel -Leaf
            }
        }
        catch {
            $Repository = "unknown"
        }
    }

    # Auto-detect worktree path
    if (-not $WorktreePath) {
        try {
            $WorktreePath = git rev-parse --show-toplevel 2>$null
        }
        catch {
            $WorktreePath = Get-Location
        }
    }

    # Create event
    $event = @{
        type = "work.started"
        agent = $Agent
        clickup = $ClickUpTask
        pr = $PR
        branch = $Branch
        objective = $Objective
        repository = $Repository
        worktree = $WorktreePath
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
    }

    # Write event to JSONL log
    Write-Event -Event $event

    # Update current state
    $state = Get-WorkStateObject
    if (-not $state.agents.ContainsKey($Agent)) {
        $state.agents[$Agent] = @{}
    }

    $state.agents[$Agent] = @{
        status = "PLANNING"
        task = @{
            clickup = $ClickUpTask
            pr = $PR
            branch = $Branch
            objective = $Objective
            repository = $Repository
        }
        phase = "Investigation"
        started = $event.timestamp
        updated = $event.timestamp
        worktree = $WorktreePath
    }

    # Increment task counter
    $state.summary.total_tasks_today++

    Save-WorkStateObject -State $state

    # Write to SQLite (async)
    Start-Job -ScriptBlock {
        param($Event, $DbPath)

        # Import SQLite module if available
        if (Get-Command 'Invoke-SqliteQuery' -ErrorAction SilentlyContinue) {
            try {
                Invoke-SqliteQuery -DataSource $DbPath -Query @"
                    INSERT INTO events (agent, event_type, event_data, timestamp)
                    VALUES (@agent, @type, @data, @timestamp)
"@ -SqlParameters @{
                    agent = $Event.agent
                    type = $Event.type
                    data = ($Event | ConvertTo-Json -Compress)
                    timestamp = $Event.timestamp
                }
            }
            catch {
                # SQLite write failed, ignore (JSONL is source of truth)
            }
        }
    } -ArgumentList $event, $script:DatabasePath | Out-Null

    Write-Host "✅ Work started: $Objective" -ForegroundColor Green
    Write-Host "   Agent: $Agent | Repository: $Repository" -ForegroundColor Gray
    if ($ClickUpTask) {
        Write-Host "   ClickUp: $ClickUpTask" -ForegroundColor Gray
    }

    # Send notification
    Send-WorkNotification -Title "Work Started" -Message "$Agent started: $Objective" -Type 'Info'
}

function Update-Work {
    <#
    .SYNOPSIS
        Update work status/phase

    .DESCRIPTION
        Records status change event and updates current state.

    .PARAMETER Agent
        Agent identifier (auto-detected if not provided)

    .PARAMETER Status
        Work status (PLANNING, CODING, TESTING, REVIEWING, MERGING, BLOCKED, DONE)

    .PARAMETER Phase
        Current work phase description

    .PARAMETER Notes
        Optional notes about current state

    .EXAMPLE
        Update-Work -Status "CODING" -Phase "Development"

    .EXAMPLE
        Update-Work -Status "BLOCKED" -Notes "Waiting for PR #506 to merge"
    #>

    [CmdletBinding()]
    param(
        [string]$Agent = (Get-AgentId),

        [ValidateSet('PLANNING', 'CODING', 'TESTING', 'REVIEWING', 'MERGING', 'BLOCKED', 'DONE', 'IDLE')]
        [string]$Status,

        [string]$Phase,
        [string]$Notes
    )

    Write-TrackingLog "Updating work for agent: $Agent, status: $Status, phase: $Phase" -Level INFO

    # Create event
    $event = @{
        type = "work.status_changed"
        agent = $Agent
        status = $Status
        phase = $Phase
        notes = $Notes
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
    }

    # Write event
    Write-Event -Event $event

    # Update state
    $state = Get-WorkStateObject
    if (-not $state.agents.ContainsKey($Agent)) {
        Write-TrackingLog "Agent $Agent not found in state, creating entry" -Level WARN
        $state.agents[$Agent] = @{
            status = $Status
            phase = $Phase
            task = @{}
            updated = $event.timestamp
        }
    }
    else {
        if ($Status) {
            $state.agents[$Agent].status = $Status
        }
        if ($Phase) {
            $state.agents[$Agent].phase = $Phase
        }
        if ($Notes) {
            $state.agents[$Agent].notes = $Notes
        }
        $state.agents[$Agent].updated = $event.timestamp
    }

    Save-WorkStateObject -State $state

    # Write to SQLite (async)
    Start-Job -ScriptBlock {
        param($Event, $DbPath)
        if (Get-Command 'Invoke-SqliteQuery' -ErrorAction SilentlyContinue) {
            try {
                Invoke-SqliteQuery -DataSource $DbPath -Query @"
                    INSERT INTO events (agent, event_type, event_data, timestamp)
                    VALUES (@agent, @type, @data, @timestamp)
"@ -SqlParameters @{
                    agent = $Event.agent
                    type = $Event.type
                    data = ($Event | ConvertTo-Json -Compress)
                    timestamp = $Event.timestamp
                }
            }
            catch { }
        }
    } -ArgumentList $event, $script:DatabasePath | Out-Null

    Write-Host "🔄 Work updated: $Status" -ForegroundColor Cyan
    if ($Phase) {
        Write-Host "   Phase: $Phase" -ForegroundColor Gray
    }
}

function Complete-Work {
    <#
    .SYNOPSIS
        Mark work as completed

    .DESCRIPTION
        Records completion event, archives to history, and updates state.

    .PARAMETER Agent
        Agent identifier (auto-detected if not provided)

    .PARAMETER PR
        GitHub PR number created

    .PARAMETER Outcome
        Description of outcome/result

    .PARAMETER Success
        Whether work completed successfully (default: true)

    .EXAMPLE
        Complete-Work -PR "#507" -Outcome "PR created, worktree released"

    .EXAMPLE
        Complete-Work -Outcome "Task blocked, needs user input" -Success $false
    #>

    [CmdletBinding()]
    param(
        [string]$Agent = (Get-AgentId),
        [string]$PR,
        [Parameter(Mandatory)]
        [string]$Outcome,
        [bool]$Success = $true
    )

    Write-TrackingLog "Completing work for agent: $Agent, outcome: $Outcome" -Level INFO

    # Get current state to capture task details
    $state = Get-WorkStateObject
    $agentData = $state.agents[$Agent]

    # Create event
    $event = @{
        type = "work.completed"
        agent = $Agent
        pr = $PR
        outcome = $Outcome
        success = $Success
        task = $agentData.task
        started = $agentData.started
        completed = (Get-Date).ToUniversalTime().ToString("o")
        duration_seconds = if ($agentData.started) {
            ((Get-Date) - [datetime]::Parse($agentData.started)).TotalSeconds
        } else { 0 }
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
    }

    # Write event
    Write-Event -Event $event

    # Update state
    if ($state.agents.ContainsKey($Agent)) {
        $state.agents[$Agent].status = "DONE"
        $state.agents[$Agent].updated = $event.timestamp
        $state.agents[$Agent].completed = $event.timestamp
        if ($PR) {
            $state.agents[$Agent].task.pr = $PR
        }
    }

    # Add to history (keep last 10)
    $completion = @{
        agent = $Agent
        task = if ($agentData.task.clickup) { $agentData.task.clickup } else { "-" }
        objective = $agentData.task.objective
        pr = if ($PR) { $PR } elseif ($agentData.task.pr) { $agentData.task.pr } else { "-" }
        outcome = $Outcome
        completed = $event.timestamp
        duration_minutes = [math]::Round($event.duration_seconds / 60, 1)
        success = $Success
    }

    $state.history.last_10_completions = @($completion) + $state.history.last_10_completions | Select-Object -First 10

    # Increment PR counter if PR was created
    if ($PR) {
        $state.summary.prs_created_today++
    }

    Save-WorkStateObject -State $state

    # Write to SQLite (async)
    Start-Job -ScriptBlock {
        param($Event, $DbPath)
        if (Get-Command 'Invoke-SqliteQuery' -ErrorAction SilentlyContinue) {
            try {
                Invoke-SqliteQuery -DataSource $DbPath -Query @"
                    INSERT INTO events (agent, event_type, event_data, timestamp)
                    VALUES (@agent, @type, @data, @timestamp);

                    INSERT INTO work_sessions (agent, clickup_task, pr_number, branch, objective,
                        repository, started_at, completed_at, outcome, success, duration_seconds)
                    VALUES (@agent, @clickup, @pr, @branch, @objective, @repository,
                        @started, @completed, @outcome, @success, @duration)
"@ -SqlParameters @{
                    agent = $Event.agent
                    type = $Event.type
                    data = ($Event | ConvertTo-Json -Compress)
                    timestamp = $Event.timestamp
                    clickup = $Event.task.clickup
                    pr = $Event.pr
                    branch = $Event.task.branch
                    objective = $Event.task.objective
                    repository = $Event.task.repository
                    started = $Event.started
                    completed = $Event.completed
                    outcome = $Event.outcome
                    success = if ($Event.success) { 1 } else { 0 }
                    duration = $Event.duration_seconds
                }
            }
            catch { }
        }
    } -ArgumentList $event, $script:DatabasePath | Out-Null

    $icon = if ($Success) { "✅" } else { "⚠️" }
    Write-Host "$icon Work completed: $Outcome" -ForegroundColor $(if ($Success) { "Green" } else { "Yellow" })
    if ($PR) {
        Write-Host "   PR: $PR" -ForegroundColor Gray
    }
    if ($event.duration_seconds -gt 0) {
        Write-Host "   Duration: $($completion.duration_minutes) minutes" -ForegroundColor Gray
    }

    # Send notification
    $notifType = if ($Success) { 'Success' } else { 'Warning' }
    $notifMsg = "$Agent completed: $Outcome"
    if ($PR) { $notifMsg += " ($PR)" }
    Send-WorkNotification -Title "Work Completed" -Message $notifMsg -Type $notifType
}

function Get-WorkState {
    <#
    .SYNOPSIS
        Get current work state

    .DESCRIPTION
        Returns current work state object with all active agents and summary.

    .PARAMETER Agent
        Filter by specific agent ID

    .PARAMETER AsJson
        Return as JSON string instead of object

    .EXAMPLE
        Get-WorkState

    .EXAMPLE
        Get-WorkState -Agent "agent-001"

    .EXAMPLE
        Get-WorkState -AsJson | Out-File state.json
    #>

    [CmdletBinding()]
    param(
        [string]$Agent,
        [switch]$AsJson
    )

    $state = Get-WorkStateObject

    if ($Agent) {
        if ($state.agents.ContainsKey($Agent)) {
            $result = @{
                agent = $Agent
                data = $state.agents[$Agent]
            }
        }
        else {
            Write-Warning "Agent $Agent not found in state"
            return $null
        }
    }
    else {
        $result = $state
    }

    if ($AsJson) {
        return ($result | ConvertTo-Json -Depth 10)
    }

    return $result
}

function Get-WorkHistory {
    <#
    .SYNOPSIS
        Query work history from event logs

    .DESCRIPTION
        Reads JSONL event files and returns filtered history.

    .PARAMETER Date
        Filter by date (default: today)

    .PARAMETER Agent
        Filter by agent ID

    .PARAMETER EventType
        Filter by event type

    .PARAMETER Last
        Return last N events

    .EXAMPLE
        Get-WorkHistory -Date "2026-02-07"

    .EXAMPLE
        Get-WorkHistory -Agent "agent-001" -Last 10

    .EXAMPLE
        Get-WorkHistory -EventType "work.completed"
    #>

    [CmdletBinding()]
    param(
        [string]$Date = (Get-Date).ToString("yyyy-MM-dd"),
        [string]$Agent,
        [string]$EventType,
        [int]$Last
    )

    $eventFile = Join-Path $script:EventsPath "$Date.jsonl"

    if (-not (Test-Path $eventFile)) {
        Write-Warning "No events found for date: $Date"
        return @()
    }

    $events = Get-Content $eventFile | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    # Apply filters
    if ($Agent) {
        $events = $events | Where-Object { $_.agent -eq $Agent }
    }

    if ($EventType) {
        $events = $events | Where-Object { $_.type -eq $EventType }
    }

    if ($Last) {
        $events = $events | Select-Object -Last $Last
    }

    return $events
}

function Get-WorkMetrics {
    <#
    .SYNOPSIS
        Calculate work metrics and analytics

    .DESCRIPTION
        Analyzes work history and returns productivity metrics.

    .PARAMETER Date
        Date to analyze (default: today)

    .PARAMETER Agent
        Filter by specific agent

    .EXAMPLE
        Get-WorkMetrics

    .EXAMPLE
        Get-WorkMetrics -Agent "agent-001"
    #>

    [CmdletBinding()]
    param(
        [string]$Date = (Get-Date).ToString("yyyy-MM-dd"),
        [string]$Agent
    )

    $events = Get-WorkHistory -Date $Date -Agent $Agent

    $completions = $events | Where-Object { $_.type -eq 'work.completed' }

    $metrics = @{
        date = $Date
        total_events = $events.Count
        total_completions = $completions.Count
        total_prs = ($completions | Where-Object { $_.pr }).Count
        avg_duration_minutes = if ($completions.Count -gt 0) {
            ($completions | Measure-Object -Property duration_seconds -Average).Average / 60
        } else { 0 }
        success_rate = if ($completions.Count -gt 0) {
            ($completions | Where-Object { $_.success }).Count / $completions.Count * 100
        } else { 0 }
        agents_active = ($events | Select-Object -ExpandProperty agent -Unique).Count
    }

    return $metrics
}

function Clear-WorkState {
    <#
    .SYNOPSIS
        Clear completed work from current state

    .DESCRIPTION
        Removes DONE agents from active state (keeps in history/events).

    .PARAMETER Agent
        Clear specific agent (if not provided, clears all DONE agents)

    .PARAMETER Force
        Force clear even if not DONE

    .EXAMPLE
        Clear-WorkState

    .EXAMPLE
        Clear-WorkState -Agent "agent-001"
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Agent,
        [switch]$Force
    )

    $state = Get-WorkStateObject
    $removed = 0

    if ($Agent) {
        if ($state.agents.ContainsKey($Agent)) {
            if ($Force -or $state.agents[$Agent].status -eq 'DONE') {
                if ($PSCmdlet.ShouldProcess($Agent, "Clear work state")) {
                    $state.agents.Remove($Agent)
                    $removed++
                }
            }
            else {
                Write-Warning "Agent $Agent is not DONE (use -Force to clear anyway)"
            }
        }
    }
    else {
        $toClear = $state.agents.Keys | Where-Object {
            $state.agents[$_].status -eq 'DONE'
        }

        foreach ($agentId in $toClear) {
            if ($PSCmdlet.ShouldProcess($agentId, "Clear work state")) {
                $state.agents.Remove($agentId)
                $removed++
            }
        }
    }

    if ($removed -gt 0) {
        Save-WorkStateObject -State $state
        Write-Host "✅ Cleared $removed agent(s) from active state" -ForegroundColor Green
    }
    else {
        Write-Host "No agents to clear" -ForegroundColor Gray
    }
}

# ============================================================================
# MODULE INITIALIZATION
# ============================================================================

# Auto-detect and set agent ID if in agent context
$detectedAgentId = Get-AgentId
if ($detectedAgentId -and $detectedAgentId -ne "current-session") {
    $env:AGENT_ID = $detectedAgentId
    Write-TrackingLog "Auto-detected agent ID: $detectedAgentId" -Level INFO
}

# Export public functions
Export-ModuleMember -Function @(
    'Start-Work',
    'Update-Work',
    'Complete-Work',
    'Get-WorkState',
    'Get-WorkHistory',
    'Get-WorkMetrics',
    'Clear-WorkState'
)

Write-TrackingLog "Work tracking module loaded (v$script:ModuleVersion)" -Level INFO
