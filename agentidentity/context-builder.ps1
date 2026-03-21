# context-builder.ps1
# Build relevant context for consciousness awakening

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [PSCustomObject]$AwakeningDecision
)

$ErrorActionPreference = "Continue"

#region Context Assembly
function Build-Context {
    param($Decision)

    $context = [PSCustomObject]@{
        awakening = @{
            reason = $Decision.reason
            priority = $Decision.priority
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        git = $null
        clickup = $null
        manictime = $null
        memory = $null
        consciousness = $null
    }

    # Build type-specific context
    if ($Decision.context) {
        switch ($Decision.context.type) {
            "clickup-task" {
                $context.clickup = Build-ClickUpContext -TaskId $Decision.context.taskId
            }
            "build-failure" {
                $context.git = Build-BuildFailureContext -Repository $Decision.context.repository -LogFile $Decision.context.logFile
            }
            "git-unpushed" {
                $context.git = Build-GitUnpushedContext -Repository $Decision.context.repository -Branch $Decision.context.branch
            }
        }
    }

    # Always include recent activity
    $context.manictime = Build-RecentActivityContext
    $context.memory = Build-RecentMemoryContext
    $context.consciousness = Build-ConsciousnessContext

    return $context
}

function Build-ClickUpContext {
    param([string]$TaskId)

    $configPath = "C:\scripts\_machine\clickup-config.json"
    if (-not (Test-Path $configPath)) {
        return $null
    }

    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        $apiKey = $config.apiKey

        # Fetch task details
        $uri = "https://api.clickup.com/api/v2/task/$TaskId"
        $headers = @{
            Authorization = $apiKey
            "Content-Type" = "application/json"
        }

        $task = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -ErrorAction Stop

        return @{
            id = $task.id
            name = $task.name
            description = $task.description
            status = $task.status.status
            priority = if ($task.priority) { $task.priority.priority } else { "none" }
            assignees = $task.assignees | ForEach-Object { $_.username }
            tags = $task.tags | ForEach-Object { $_.name }
            url = $task.url
            project = $task.list.name
        }
    } catch {
        return @{
            error = "Failed to fetch task details: $_"
            taskId = $TaskId
        }
    }
}

function Build-BuildFailureContext {
    param([string]$Repository, [string]$LogFile)

    $repoPath = Join-Path "C:\Projects" $Repository
    $logPath = Join-Path $repoPath $LogFile

    $context = @{
        repository = $Repository
        logFile = $LogFile
        errors = @()
    }

    if (Test-Path $logPath) {
        # Extract error lines
        $content = Get-Content $logPath
        $errorLines = $content | Where-Object { $_ -match "error|failed|exception" } | Select-Object -First 20

        $context.errors = $errorLines
        $context.logSize = (Get-Item $logPath).Length
    }

    # Get recent commits (might have introduced the error)
    Push-Location $repoPath
    try {
        $recentCommits = git log --oneline -5 2>$null
        $context.recentCommits = $recentCommits
    } catch {
        $context.recentCommits = @()
    } finally {
        Pop-Location
    }

    return $context
}

function Build-GitUnpushedContext {
    param([string]$Repository, [string]$Branch)

    $repoPath = Join-Path "C:\Projects" $Repository

    Push-Location $repoPath
    try {
        # Get unpushed commits
        $unpushedCommits = git log "@{u}.." --oneline 2>$null

        # Get diff stats
        $diffStats = git diff "@{u}.." --stat 2>$null

        # Get current status
        $status = git status --porcelain 2>$null

        return @{
            repository = $Repository
            branch = $Branch
            unpushedCommits = $unpushedCommits
            diffStats = $diffStats
            uncommittedChanges = if ($status) { $status.Count } else { 0 }
        }
    } catch {
        return @{
            error = "Failed to get git context"
            repository = $Repository
        }
    } finally {
        Pop-Location
    }
}

function Build-RecentActivityContext {
    $manicTimePath = "E:\jengo\health\manictime-events.jsonl"

    if (-not (Test-Path $manicTimePath)) {
        return @{available = $false}
    }

    try {
        # Last 50 events
        $recentEvents = Get-Content $manicTimePath -Tail 50 | ForEach-Object {
            $_ | ConvertFrom-Json
        }

        # Summarize activity
        $activities = $recentEvents | Group-Object -Property activity | ForEach-Object {
            @{
                name = $_.Name
                count = $_.Count
                duration = ($_.Group | Measure-Object -Property duration -Sum).Sum
            }
        } | Sort-Object -Property duration -Descending

        return @{
            available = $true
            recentActivities = $activities | Select-Object -First 5
            totalEvents = $recentEvents.Count
            timespan = "Last 50 events"
        }
    } catch {
        return @{available = $false; error = $_}
    }
}

function Build-RecentMemoryContext {
    $reflectionPath = "C:\scripts\_machine\reflection.log.md"

    if (-not (Test-Path $reflectionPath)) {
        return @{available = $false}
    }

    try {
        # Get last 3 reflection entries
        $content = Get-Content $reflectionPath -Raw
        $sections = $content -split "##" | Where-Object { $_.Trim() -ne "" }

        $recentSections = $sections | Select-Object -Last 3 | ForEach-Object {
            $lines = $_ -split "`n"
            @{
                header = $lines[0].Trim()
                preview = ($lines[1..5] -join "`n").Trim()
            }
        }

        return @{
            available = $true
            recentLearnings = $recentSections
        }
    } catch {
        return @{available = $false; error = $_}
    }
}

function Build-ConsciousnessContext {
    $statePath = Join-Path $PSScriptRoot "state\persistent-state.json"

    if (-not (Test-Path $statePath)) {
        return @{available = $false}
    }

    try {
        $state = Get-Content $statePath -Raw | ConvertFrom-Json

        return @{
            available = $true
            cycleCount = $state.cycleCount
            uptime = [Math]::Round($state.totalUptime / 3600, 2)  # hours
            homeostatic = $state.consciousness
            awakeningsTriggered = $state.events.awakeningsTriggered
            learningProgress = @{
                sessionsObserved = $state.learning.sessionsObserved
                improvementsImplemented = $state.learning.improvementsImplemented
            }
        }
    } catch {
        return @{available = $false; error = $_}
    }
}
#endregion

#region Main
function Main {
    $context = Build-Context -Decision $AwakeningDecision

    # Save context to file (for potential Claude Code session startup)
    $contextOutputPath = Join-Path $PSScriptRoot "state\awakening-context.json"
    $context | ConvertTo-Json -Depth 10 | Set-Content $contextOutputPath -Force

    # Also return for immediate use
    return $context
}

Main
#endregion
