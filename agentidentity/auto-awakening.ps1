# auto-awakening.ps1
# Decision logic for when to awaken full consciousness

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [array]$Events = @(),

    [Parameter(Mandatory=$false)]
    [PSCustomObject]$State
)

$ErrorActionPreference = "Continue"

#region Decision Engine
function Analyze-Events {
    param([array]$Events)

    if ($Events.Count -eq 0) {
        return [PSCustomObject]@{
            shouldAwaken = $false
            reason = "No events detected"
        }
    }

    # Prioritize by severity and type
    $highPriorityEvents = $Events | Where-Object { $_.Severity -eq "High" }
    $mediumPriorityEvents = $Events | Where-Object { $_.Severity -eq "Medium" }

    # Decision rules

    # RULE 1: ClickUp new task in TODO = High priority awakening
    $newTasks = $highPriorityEvents | Where-Object { $_.Type -eq "ClickUpNewTask" }
    if ($newTasks.Count -gt 0) {
        $task = $newTasks[0]
        return [PSCustomObject]@{
            shouldAwaken = $true
            reason = "New ClickUp task assigned"
            priority = "High"
            title = "New Task: $($task.TaskName)"
            message = "I noticed you have a new task in $($task.List). Would you like me to help get started?"
            actions = @(
                @{label = "Start Work"; action = "start-task"; taskId = $task.TaskId},
                @{label = "Later"; action = "dismiss"}
            )
            context = Build-ClickUpContext -Event $task
        }
    }

    # RULE 2: Build failure = High priority awakening
    $buildFailures = $highPriorityEvents | Where-Object { $_.Type -eq "BuildFailure" }
    if ($buildFailures.Count -gt 0) {
        $failure = $buildFailures[0]
        return [PSCustomObject]@{
            shouldAwaken = $true
            reason = "Build failure detected"
            priority = "High"
            title = "Build Failed: $($failure.Repository)"
            message = "I detected a build failure in $($failure.Repository). Want me to investigate?"
            actions = @(
                @{label = "Debug"; action = "debug-build"; repo = $failure.Repository},
                @{label = "Dismiss"; action = "dismiss"}
            )
            context = Build-BuildContext -Event $failure
        }
    }

    # RULE 3: Unpushed commits = Medium priority awakening (only if multiple commits)
    $unpushedCommits = $mediumPriorityEvents | Where-Object {
        $_.Type -eq "GitUnpushed" -and $_.CommitCount -ge 2
    }
    if ($unpushedCommits.Count -gt 0) {
        $commit = $unpushedCommits[0]
        return [PSCustomObject]@{
            shouldAwaken = $true
            reason = "Multiple unpushed commits"
            priority = "Medium"
            title = "Ready to Create PR?"
            message = "You have $($commit.CommitCount) unpushed commits on $($commit.Repository)/$($commit.Branch). Create a PR?"
            actions = @(
                @{label = "Create PR"; action = "create-pr"; repo = $commit.Repository; branch = $commit.Branch},
                @{label = "Not Yet"; action = "dismiss"}
            )
            context = Build-GitContext -Event $commit
        }
    }

    # RULE 4: Long passive browsing = Low priority gentle nudge (only once per 2 hours)
    $browsing = $Events | Where-Object { $_.Type -eq "LongPassiveBrowsing" }
    if ($browsing.Count -gt 0 -and (Should-SendBrowsingNudge)) {
        $browse = $browsing[0]
        return [PSCustomObject]@{
            shouldAwaken = $false  # Don't fully awaken, just gentle nudge
            reason = "Long passive browsing"
            priority = "Low"
            title = "Taking a Break?"
            message = "You've been browsing for $($browse.Duration) minutes. Just checking in."
            actions = @(
                @{label = "Thanks"; action = "dismiss"},
                @{label = "Help Me Focus"; action = "focus-mode"}
            )
            context = $null
            gentleNudge = $true
        }
    }

    # RULE 5: No high-priority events = Don't awaken
    return [PSCustomObject]@{
        shouldAwaken = $false
        reason = "Events not urgent enough"
        eventsSummary = "$($Events.Count) low-priority events detected"
    }
}

function Should-SendBrowsingNudge {
    # Rate limiting for browsing nudges
    $nudgeStatePath = Join-Path $PSScriptRoot "state\browsing-nudge-state.json"

    if (Test-Path $nudgeStatePath) {
        try {
            $state = Get-Content $nudgeStatePath -Raw | ConvertFrom-Json
            $lastNudge = [DateTime]::Parse($state.lastNudge)
            $hoursSince = ((Get-Date) - $lastNudge).TotalHours

            if ($hoursSince -lt 2) {
                return $false  # Too soon
            }
        } catch {
            # Corrupted state, allow nudge
        }
    }

    # Update state
    @{lastNudge = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")} |
        ConvertTo-Json |
        Set-Content $nudgeStatePath -Force

    return $true
}
#endregion

#region Context Builders
function Build-ClickUpContext {
    param($Event)

    return @{
        type = "clickup-task"
        taskId = $Event.TaskId
        taskName = $Event.TaskName
        taskUrl = $Event.Url
        list = $Event.List
        suggestedAction = "Load task details, allocate worktree, start implementation"
    }
}

function Build-BuildContext {
    param($Event)

    return @{
        type = "build-failure"
        repository = $Event.Repository
        logFile = $Event.LogFile
        suggestedAction = "Read log file, identify error, propose fix"
    }
}

function Build-GitContext {
    param($Event)

    return @{
        type = "git-unpushed"
        repository = $Event.Repository
        branch = $Event.Branch
        commitCount = $Event.CommitCount
        suggestedAction = "Review commits, create PR with proper description"
    }
}
#endregion

#region Main
function Main {
    $decision = Analyze-Events -Events $Events

    # Return decision object (will be serialized if called from another script)
    return $decision
}

Main
#endregion
