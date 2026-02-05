<#
.SYNOPSIS
    ClickUp team activity report generator

.DESCRIPTION
    Generates comprehensive team activity reports from ClickUp including:
    - Task completion stats by assignee
    - Status changes over time period
    - Velocity metrics (tasks/week)
    - Work-in-progress (WIP) analysis
    - Recent activity timeline

.PARAMETER Days
    Number of days to look back (default: 7)

.PARAMETER ProjectId
    Specific project/list to analyze (optional, analyzes all if omitted)

.PARAMETER Format
    Output format: console, json, html (default: console)

.PARAMETER OutputPath
    Path to save report file (required for json/html formats)

.EXAMPLE
    .\team-activity-clickup.ps1 -Days 7
    .\team-activity-clickup.ps1 -Days 30 -Format html -OutputPath "C:\temp\clickup-report.html"
    .\team-activity-clickup.ps1 -ProjectId client-manager -Days 14

.NOTES
    Requires: C:\scripts\_machine\clickup-config.json
    Uses ClickUp API v2
#>

param(
    [int]$Days = 7,
    [ValidateSet("client-manager", "art-revisionist", "hazina", "brand2boost-birdseye", "")]
    [string]$ProjectId = "",
    [ValidateSet("console", "json", "html")]
    [string]$Format = "console",
    [string]$OutputPath = ""
)

# Load config
$configPath = "C:\scripts\_machine\clickup-config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Config not found: $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json
$apiKey = $config.api_key
$apiBase = $config.api_base

$headers = @{
    Authorization = $apiKey
    "Content-Type" = "application/json"
}

# Determine which lists to analyze
$listsToAnalyze = @()
if ($ProjectId) {
    $projectConfig = $config.projects.$ProjectId
    if (-not $projectConfig) {
        Write-Error "Project '$ProjectId' not found in config"
        exit 1
    }
    $listsToAnalyze += @{
        id = $projectConfig.list_id
        name = $projectConfig.name
        project = $ProjectId
    }
} else {
    # Analyze all configured projects
    foreach ($proj in $config.projects.PSObject.Properties) {
        $listsToAnalyze += @{
            id = $proj.Value.list_id
            name = $proj.Value.name
            project = $proj.Name
        }
    }
}

# Calculate time range
$endTime = [DateTimeOffset]::UtcNow
$startTime = $endTime.AddDays(-$Days)
$startTimestamp = [long]($startTime.ToUnixTimeMilliseconds())
$endTimestamp = [long]($endTime.ToUnixTimeMilliseconds())

Write-Host "`n🔍 Analyzing ClickUp activity from $($startTime.ToString('yyyy-MM-dd')) to $($endTime.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan

# Collect all tasks and activity
$allTasks = @()
$allActivity = @()
$userStats = @{}

foreach ($list in $listsToAnalyze) {
    Write-Host "  → Fetching tasks from $($list.name)..." -ForegroundColor Gray

    # Get tasks (both open and closed)
    $url = "$apiBase/list/$($list.id)/task?archived=false&include_closed=true"
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers

        foreach ($task in $response.tasks) {
            # Parse timestamps
            $createdDate = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_created)
            $updatedDate = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_updated)
            $closedDate = if ($task.date_closed) {
                [DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_closed)
            } else {
                $null
            }

            # Filter to time range
            $inRange = $false
            if ($closedDate -and $closedDate -ge $startTime -and $closedDate -le $endTime) {
                $inRange = $true
            } elseif ($updatedDate -ge $startTime) {
                $inRange = $true
            }

            if ($inRange) {
                $allTasks += [PSCustomObject]@{
                    id = $task.id
                    name = $task.name
                    status = $task.status.status
                    project = $list.name
                    projectId = $list.project
                    created = $createdDate
                    updated = $updatedDate
                    closed = $closedDate
                    assignees = $task.assignees
                    url = $task.url
                }

                # Track by assignee
                foreach ($assignee in $task.assignees) {
                    $userId = $assignee.id
                    $userName = $assignee.username

                    if (-not $userStats.ContainsKey($userId)) {
                        $userStats[$userId] = @{
                            name = $userName
                            tasksCompleted = 0
                            tasksInProgress = 0
                            tasksCreated = 0
                            totalTasks = 0
                        }
                    }

                    $userStats[$userId].totalTasks++

                    if ($closedDate -and $closedDate -ge $startTime -and $closedDate -le $endTime) {
                        $userStats[$userId].tasksCompleted++
                    }
                    if ($task.status.status -in @('busy', 'in progress')) {
                        $userStats[$userId].tasksInProgress++
                    }
                    if ($createdDate -ge $startTime -and $createdDate -le $endTime) {
                        $userStats[$userId].tasksCreated++
                    }
                }
            }
        }
    } catch {
        Write-Warning "Failed to fetch tasks from $($list.name): $($_.Exception.Message)"
    }
}

# Build report object
$report = [PSCustomObject]@{
    period = "$($startTime.ToString('yyyy-MM-dd')) to $($endTime.ToString('yyyy-MM-dd'))"
    days = $Days
    generatedAt = $endTime.ToString("yyyy-MM-dd HH:mm:ss")
    summary = [PSCustomObject]@{
        totalTasks = $allTasks.Count
        completedTasks = ($allTasks | Where-Object { $_.closed -and $_.closed -ge $startTime -and $_.closed -le $endTime }).Count
        inProgressTasks = ($allTasks | Where-Object { $_.status -in @('busy', 'in progress') }).Count
        tasksPerDay = [math]::Round($allTasks.Count / $Days, 2)
        completionRate = if ($allTasks.Count -gt 0) {
            [math]::Round((($allTasks | Where-Object { $_.closed -and $_.closed -ge $startTime -and $_.closed -le $endTime }).Count / $allTasks.Count) * 100, 1)
        } else {
            0
        }
    }
    byUser = $userStats.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            userId = $_.Key
            userName = $_.Value.name
            totalTasks = $_.Value.totalTasks
            completed = $_.Value.tasksCompleted
            inProgress = $_.Value.tasksInProgress
            created = $_.Value.tasksCreated
            completionRate = if ($_.Value.totalTasks -gt 0) {
                [math]::Round(($_.Value.tasksCompleted / $_.Value.totalTasks) * 100, 1)
            } else {
                0
            }
        }
    } | Sort-Object -Property completed -Descending
    byProject = $allTasks | Group-Object -Property project | ForEach-Object {
        $projectTasks = $_.Group
        [PSCustomObject]@{
            project = $_.Name
            totalTasks = $projectTasks.Count
            completed = ($projectTasks | Where-Object { $_.closed -and $_.closed -ge $startTime -and $_.closed -le $endTime }).Count
            inProgress = ($projectTasks | Where-Object { $_.status -in @('busy', 'in progress') }).Count
        }
    } | Sort-Object -Property totalTasks -Descending
    recentActivity = $allTasks |
        Sort-Object -Property updated -Descending |
        Select-Object -First 20 |
        ForEach-Object {
            [PSCustomObject]@{
                task = $_.name
                status = $_.status
                project = $_.project
                updated = $_.updated.ToString("yyyy-MM-dd HH:mm")
                assignees = ($_.assignees | ForEach-Object { $_.username }) -join ', '
                url = $_.url
            }
        }
}

# Output based on format
switch ($Format) {
    "json" {
        if (-not $OutputPath) {
            Write-Error "OutputPath required for json format"
            exit 1
        }
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "`n✅ JSON report saved to: $OutputPath" -ForegroundColor Green
    }

    "html" {
        if (-not $OutputPath) {
            Write-Error "OutputPath required for html format"
            exit 1
        }

        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>ClickUp Team Activity Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #7B68EE; border-bottom: 3px solid #7B68EE; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 30px; }
        .metric { display: inline-block; margin: 10px 20px 10px 0; padding: 15px; background: #f9f9f9; border-radius: 5px; border-left: 4px solid #7B68EE; }
        .metric .label { font-size: 12px; color: #666; text-transform: uppercase; }
        .metric .value { font-size: 28px; font-weight: bold; color: #333; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th { background: #7B68EE; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #eee; }
        tr:hover { background: #f5f5f5; }
        .timestamp { color: #999; font-size: 12px; text-align: right; margin-top: 30px; }
        .url { color: #7B68EE; text-decoration: none; }
        .url:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 ClickUp Team Activity Report</h1>
        <p><strong>Period:</strong> $($report.period)</p>

        <h2>📈 Summary Metrics</h2>
        <div class="metric">
            <div class="label">Total Tasks</div>
            <div class="value">$($report.summary.totalTasks)</div>
        </div>
        <div class="metric">
            <div class="label">Completed</div>
            <div class="value" style="color: #28a745;">$($report.summary.completedTasks)</div>
        </div>
        <div class="metric">
            <div class="label">In Progress</div>
            <div class="value" style="color: #ffc107;">$($report.summary.inProgressTasks)</div>
        </div>
        <div class="metric">
            <div class="label">Tasks/Day</div>
            <div class="value">$($report.summary.tasksPerDay)</div>
        </div>
        <div class="metric">
            <div class="label">Completion Rate</div>
            <div class="value">$($report.summary.completionRate)%</div>
        </div>

        <h2>👥 Team Performance</h2>
        <table>
            <tr>
                <th>User</th>
                <th>Total Tasks</th>
                <th>Completed</th>
                <th>In Progress</th>
                <th>Created</th>
                <th>Completion Rate</th>
            </tr>
"@
        foreach ($user in $report.byUser) {
            $html += @"
            <tr>
                <td><strong>$($user.userName)</strong></td>
                <td>$($user.totalTasks)</td>
                <td style="color: #28a745; font-weight: bold;">$($user.completed)</td>
                <td style="color: #ffc107;">$($user.inProgress)</td>
                <td>$($user.created)</td>
                <td>$($user.completionRate)%</td>
            </tr>
"@
        }

        $html += @"
        </table>

        <h2>📂 By Project</h2>
        <table>
            <tr>
                <th>Project</th>
                <th>Total Tasks</th>
                <th>Completed</th>
                <th>In Progress</th>
            </tr>
"@
        foreach ($proj in $report.byProject) {
            $html += @"
            <tr>
                <td><strong>$($proj.project)</strong></td>
                <td>$($proj.totalTasks)</td>
                <td style="color: #28a745;">$($proj.completed)</td>
                <td style="color: #ffc107;">$($proj.inProgress)</td>
            </tr>
"@
        }

        $html += @"
        </table>

        <h2>🕒 Recent Activity (Last 20)</h2>
        <table>
            <tr>
                <th>Task</th>
                <th>Status</th>
                <th>Project</th>
                <th>Assignees</th>
                <th>Updated</th>
            </tr>
"@
        foreach ($activity in $report.recentActivity) {
            $html += @"
            <tr>
                <td><a href="$($activity.url)" class="url" target="_blank">$($activity.task)</a></td>
                <td>$($activity.status)</td>
                <td>$($activity.project)</td>
                <td>$($activity.assignees)</td>
                <td>$($activity.updated)</td>
            </tr>
"@
        }

        $html += @"
        </table>

        <div class="timestamp">Generated: $($report.generatedAt)</div>
    </div>
</body>
</html>
"@
        $html | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "`n✅ HTML report saved to: $OutputPath" -ForegroundColor Green

        # Auto-open in browser
        Start-Process $OutputPath
    }

    "console" {
        Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║           📊 CLICKUP TEAM ACTIVITY REPORT                    ║" -ForegroundColor Cyan
        Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

        Write-Host "`n📅 Period: $($report.period)" -ForegroundColor Yellow

        Write-Host "`n📈 SUMMARY METRICS" -ForegroundColor Green
        Write-Host "  Total Tasks:      $($report.summary.totalTasks)"
        Write-Host "  Completed:        $($report.summary.completedTasks)" -ForegroundColor Green
        Write-Host "  In Progress:      $($report.summary.inProgressTasks)" -ForegroundColor Yellow
        Write-Host "  Tasks/Day:        $($report.summary.tasksPerDay)"
        Write-Host "  Completion Rate:  $($report.summary.completionRate)%" -ForegroundColor Cyan

        Write-Host "`n👥 TEAM PERFORMANCE" -ForegroundColor Green
        $report.byUser | Format-Table -Property userName, totalTasks, completed, inProgress, created, completionRate -AutoSize

        Write-Host "📂 BY PROJECT" -ForegroundColor Green
        $report.byProject | Format-Table -Property project, totalTasks, completed, inProgress -AutoSize

        Write-Host "🕒 RECENT ACTIVITY (Last 20)" -ForegroundColor Green
        $report.recentActivity | Format-Table -Property task, status, project, assignees, updated -AutoSize

        Write-Host "`n✅ Report complete!" -ForegroundColor Green
    }
}

# Return report object for piping
return $report
