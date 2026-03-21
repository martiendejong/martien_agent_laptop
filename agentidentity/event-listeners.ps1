# event-listeners.ps1
# Monitor git, ClickUp, filesystem for events that might need consciousness

[CmdletBinding()]
param(
    [switch]$Check  # Run all listeners and return detected events
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$EventStatePath = Join-Path $ScriptPath "state\event-state.json"

#region Event State Management
function Load-EventState {
    if (Test-Path $EventStatePath) {
        try {
            return Get-Content $EventStatePath -Raw | ConvertFrom-Json
        } catch {
            return Initialize-EventState
        }
    } else {
        return Initialize-EventState
    }
}

function Initialize-EventState {
    return [PSCustomObject]@{
        lastGitCheck = (Get-Date).AddMinutes(-5).ToString("yyyy-MM-dd HH:mm:ss")
        lastClickUpCheck = (Get-Date).AddMinutes(-5).ToString("yyyy-MM-dd HH:mm:ss")
        lastManicTimeCheck = (Get-Date).AddMinutes(-5).ToString("yyyy-MM-dd HH:mm:ss")
        lastBuildCheck = (Get-Date).AddMinutes(-5).ToString("yyyy-MM-dd HH:mm:ss")
        knownBranches = @{}
        knownTasks = @{}
    }
}

function Save-EventState {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $EventStatePath -Force
}
#endregion

#region Git Monitoring
function Check-GitEvents {
    param($EventState)

    $events = @()
    $projectsRoot = "C:\Projects"

    if (-not (Test-Path $projectsRoot)) {
        return $events
    }

    # Find all git repositories
    $repos = Get-ChildItem $projectsRoot -Directory | Where-Object {
        Test-Path (Join-Path $_.FullName ".git")
    }

    foreach ($repo in $repos) {
        Push-Location $repo.FullName
        try {
            # Check for unpushed commits
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            if ($LASTEXITCODE -eq 0 -and $branch -ne "HEAD") {
                $unpushedCount = (git log "@{u}.." --oneline 2>$null | Measure-Object).Count

                if ($unpushedCount -gt 0) {
                    # Check if this is new (not seen before)
                    $branchKey = "$($repo.Name):$branch"
                    $previousCount = if ($EventState.knownBranches.$branchKey) {
                        $EventState.knownBranches.$branchKey
                    } else { 0 }

                    if ($unpushedCount -gt $previousCount) {
                        $events += [PSCustomObject]@{
                            Type = "GitUnpushed"
                            Repository = $repo.Name
                            Branch = $branch
                            CommitCount = $unpushedCount
                            Severity = "Medium"
                            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                            Action = "OfferCreatePR"
                        }

                        # Update known state
                        $EventState.knownBranches.$branchKey = $unpushedCount
                    }
                }

                # Check for uncommitted changes
                $statusOutput = git status --porcelain 2>$null
                if ($statusOutput) {
                    $changedFiles = ($statusOutput | Measure-Object).Count
                    if ($changedFiles -gt 0) {
                        $events += [PSCustomObject]@{
                            Type = "GitUncommitted"
                            Repository = $repo.Name
                            Branch = $branch
                            FileCount = $changedFiles
                            Severity = "Low"
                            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                            Action = "OfferCommit"
                        }
                    }
                }
            }
        } finally {
            Pop-Location
        }
    }

    $EventState.lastGitCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return $events
}
#endregion

#region ClickUp Monitoring
function Check-ClickUpEvents {
    param($EventState)

    $events = @()
    $configPath = "C:\scripts\_machine\clickup-config.json"

    if (-not (Test-Path $configPath)) {
        return $events
    }

    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        $apiKey = $config.apiKey

        # Get tasks in "todo" status from all teams
        foreach ($team in $config.teams) {
            $listIds = $team.lists | Where-Object { $_.status -eq "active" } | Select-Object -ExpandProperty id

            foreach ($listId in $listIds) {
                $uri = "https://api.clickup.com/api/v2/list/$listId/task?statuses[]=todo&statuses[]=to%20do"
                $headers = @{
                    Authorization = $apiKey
                    "Content-Type" = "application/json"
                }

                try {
                    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -ErrorAction Stop
                    $tasks = $response.tasks

                    foreach ($task in $tasks) {
                        # Check if this is a new task (not seen before)
                        if (-not $EventState.knownTasks.($task.id)) {
                            $events += [PSCustomObject]@{
                                Type = "ClickUpNewTask"
                                TaskId = $task.id
                                TaskName = $task.name
                                List = $team.name
                                Severity = "High"
                                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                                Action = "OfferStartWork"
                                Url = $task.url
                            }

                            # Mark as known
                            $EventState.knownTasks.($task.id) = $true
                        }
                    }
                } catch {
                    # Silent fail for API errors
                }
            }
        }
    } catch {
        # Silent fail for config errors
    }

    $EventState.lastClickUpCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return $events
}
#endregion

#region Build Failure Monitoring
function Check-BuildFailures {
    param($EventState)

    $events = @()
    $projectsRoot = "C:\Projects"

    if (-not (Test-Path $projectsRoot)) {
        return $events
    }

    # Look for recent build error logs
    $buildLogs = @(
        "msbuild.log",
        "build.log",
        "error.log"
    )

    $repos = Get-ChildItem $projectsRoot -Directory

    foreach ($repo in $repos) {
        foreach ($logName in $buildLogs) {
            $logPath = Join-Path $repo.FullName $logName
            if (Test-Path $logPath) {
                $logFile = Get-Item $logPath

                # Check if modified in last 10 minutes
                $lastModified = $logFile.LastWriteTime
                if ($lastModified -gt (Get-Date).AddMinutes(-10)) {
                    # Check if contains errors
                    $content = Get-Content $logPath -Raw
                    if ($content -match "error|failed|exception" -and $content -notmatch "0 Error") {
                        $events += [PSCustomObject]@{
                            Type = "BuildFailure"
                            Repository = $repo.Name
                            LogFile = $logName
                            Severity = "High"
                            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                            Action = "OfferDebug"
                        }
                    }
                }
            }
        }
    }

    $EventState.lastBuildCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return $events
}
#endregion

#region ManicTime Activity Monitoring
function Check-ManicTimeActivity {
    param($EventState)

    $events = @()
    $manicTimePath = "E:\jengo\health\manictime-events.jsonl"

    if (-not (Test-Path $manicTimePath)) {
        return $events
    }

    try {
        # Read last 100 lines
        $recentEvents = Get-Content $manicTimePath -Tail 100 | ForEach-Object {
            $_ | ConvertFrom-Json
        }

        # Detect long passive browsing (> 30 minutes)
        $now = Get-Date
        $browsingEvents = $recentEvents | Where-Object {
            $_.activity -match "chrome|firefox|edge" -and
            $_.category -eq "browsing"
        }

        if ($browsingEvents.Count -gt 0) {
            # Check duration
            $firstEvent = [DateTime]::Parse($browsingEvents[0].timestamp)
            $lastEvent = [DateTime]::Parse($browsingEvents[-1].timestamp)
            $duration = ($lastEvent - $firstEvent).TotalMinutes

            if ($duration -gt 30) {
                $events += [PSCustomObject]@{
                    Type = "LongPassiveBrowsing"
                    Duration = [Math]::Round($duration, 1)
                    Severity = "Low"
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    Action = "GentleAwareness"
                }
            }
        }

        # Detect context switch (from work to browsing)
        $lastWorkEvent = $recentEvents | Where-Object {
            $_.category -eq "development" -or $_.activity -match "code|visual studio"
        } | Select-Object -Last 1

        if ($lastWorkEvent) {
            $workTime = [DateTime]::Parse($lastWorkEvent.timestamp)
            $timeSinceWork = ($now - $workTime).TotalMinutes

            # If stopped working 5-10 minutes ago, might be taking break
            if ($timeSinceWork -gt 5 -and $timeSinceWork -lt 10) {
                $events += [PSCustomObject]@{
                    Type = "ContextSwitch"
                    From = "Development"
                    To = "Break"
                    Severity = "Info"
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    Action = "None"
                }
            }
        }

    } catch {
        # Silent fail
    }

    $EventState.lastManicTimeCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return $events
}
#endregion

#region Main
function Main {
    if (-not $Check) {
        Write-Host "Usage: event-listeners.ps1 -Check"
        Write-Host "Returns array of detected events"
        return
    }

    $eventState = Load-EventState
    $allEvents = @()

    # Run all listeners
    $allEvents += Check-GitEvents -EventState $eventState
    $allEvents += Check-ClickUpEvents -EventState $eventState
    $allEvents += Check-BuildFailures -EventState $eventState
    $allEvents += Check-ManicTimeActivity -EventState $eventState

    # Save updated state
    Save-EventState -State $eventState

    # Return events (as objects, will be serialized if called from another script)
    return $allEvents
}

Main
#endregion
