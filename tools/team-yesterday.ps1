<#
.SYNOPSIS
    Team activity table for YESTERDAY ONLY - full width, 3 columns

.DESCRIPTION
    Simple table with exactly 3 columns:
    1. Name
    2. ClickUp tasks (links)
    3. Branches + commit count

.EXAMPLE
    .\team-yesterday.ps1

.NOTES
    Opens automatically in browser
#>

param()

# Load ClickUp config
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

# YESTERDAY only
$today = Get-Date
$yesterday = $today.Date.AddDays(-1)
$yesterdayEnd = $today.Date
$yesterdayKey = $yesterday.ToString("yyyy-MM-dd")

Write-Host "`n🔍 Analyzing YESTERDAY ($yesterdayKey)..." -ForegroundColor Cyan

# Team members
$knownMembers = @("martiendejong", "Diko Mohamed", "Frank Kobaai ", "Lessy.", "Simitia Mpoe", "Timothy Opiyo")
$userActivity = @{}

foreach ($member in $knownMembers) {
    $userActivity[$member] = @{
        tasks = @()
        branches = @()
        commitCount = 0
    }
}

# GitHub repositories
$reposToAnalyze = @("martiendejong/client-manager", "martiendejong/Hazina", "martiendejong/machine_agents")

# Collect GitHub data
Write-Host "  → Collecting GitHub commits & branches..." -ForegroundColor Gray

foreach ($repo in $reposToAnalyze) {
    try {
        $since = $yesterday.ToString("yyyy-MM-ddTHH:mm:ssZ")
        $until = $yesterdayEnd.ToString("yyyy-MM-ddTHH:mm:ssZ")

        $commitsRaw = gh api "repos/$repo/commits?since=$since&until=$until&per_page=100" 2>$null
        if ($commitsRaw) {
            $commitsJson = ($commitsRaw -join "") -replace '\x1b\[[0-9;]*m', ''
            $commits = $commitsJson | ConvertFrom-Json

            foreach ($commit in $commits) {
                $author = if ($commit.author) { $commit.author.login } else { "Unknown" }

                if (-not $userActivity.ContainsKey($author)) {
                    $userActivity[$author] = @{
                        tasks = @()
                        branches = @()
                        commitCount = 0
                    }
                }

                $userActivity[$author].commitCount++

                # Get branches for this commit
                try {
                    $branchesJson = gh api "repos/$repo/commits/$($commit.sha)/branches-where-head" 2>$null
                    if ($branchesJson) {
                        $branches = $branchesJson | ConvertFrom-Json
                        foreach ($branch in $branches) {
                            $branchName = $branch.name
                            $fullBranchName = "$repo/$branchName"

                            if ($fullBranchName -notin $userActivity[$author].branches) {
                                $userActivity[$author].branches += $fullBranchName
                            }
                        }
                    }
                } catch {
                    # Silently continue
                }
            }
        }
    } catch {
        # Silently continue
    }
}

# Collect ClickUp data
Write-Host "  → Collecting ClickUp tasks..." -ForegroundColor Gray

foreach ($proj in $config.projects.PSObject.Properties) {
    $listId = $proj.Value.list_id
    try {
        $url = $apiBase + "/list/" + $listId + "/task?archived=false&include_closed=true"
        $response = Invoke-RestMethod -Uri $url -Headers $headers

        foreach ($task in $response.tasks) {
            $updatedDate = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_updated)

            if ($updatedDate.DateTime -lt $yesterday -or $updatedDate.DateTime -ge $yesterdayEnd) {
                continue
            }

            # Get task comments to see who actually worked on it
            $taskCommenters = @{}
            try {
                $commentsUrl = $apiBase + "/task/" + $task.id + "/comment"
                $commentsResponse = Invoke-RestMethod -Uri $commentsUrl -Headers $headers

                foreach ($comment in $commentsResponse.comments) {
                    $commentDate = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$comment.date)
                    if ($commentDate.DateTime -ge $yesterday -and $commentDate.DateTime -lt $yesterdayEnd) {
                        $commenter = $comment.user.username
                        $taskCommenters[$commenter] = $true
                    }
                }
            } catch {
                # If comments fail, fall back to assignees
                foreach ($assignee in $task.assignees) {
                    $username = $assignee.username
                    $taskCommenters[$username] = $true
                }
            }

            # Add task to users who worked on it
            foreach ($username in $taskCommenters.Keys) {
                if (-not $userActivity.ContainsKey($username)) {
                    $userActivity[$username] = @{
                        tasks = @()
                        branches = @()
                        commitCount = 0
                    }
                }

                # Add task if not already added
                $taskExists = $false
                foreach ($t in $userActivity[$username].tasks) {
                    if ($t.id -eq $task.id) {
                        $taskExists = $true
                        break
                    }
                }

                if (-not $taskExists) {
                    $userActivity[$username].tasks += [PSCustomObject]@{
                        id = $task.id
                        name = $task.name
                        status = $task.status.status
                        url = $task.url
                    }
                }
            }
        }
    } catch {
        Write-Warning "Failed to fetch ClickUp tasks from $($proj.Value.name)"
    }
}

Write-Host "✅ Data collected. Generating HTML..." -ForegroundColor Green

# Generate HTML
$generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$outputPath = "C:\temp\team-yesterday.html"

# Build HTML with string concatenation (no here-strings to avoid parsing issues)
$html = "<!DOCTYPE html>`n<html>`n<head>`n"
$html += "    <title>Team Activity - Yesterday ($yesterdayKey)</title>`n"
$html += "    <meta charset='UTF-8'>`n"
$html += "    <style>`n"
$html += "        * { margin: 0; padding: 0; box-sizing: border-box; }`n"
$html += "        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; min-height: 100vh; }`n"
$html += "        .container { width: 100%; max-width: 100%; margin: 0 auto; background: white; border-radius: 12px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); overflow: hidden; }`n"
$html += "        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; text-align: center; }`n"
$html += "        .header h1 { font-size: 36px; margin-bottom: 10px; }`n"
$html += "        .header p { font-size: 18px; opacity: 0.9; }`n"
$html += "        .content { padding: 40px; }`n"
$html += "        table { width: 100%; border-collapse: collapse; margin: 20px 0; }`n"
$html += "        th { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: left; font-weight: 600; font-size: 18px; position: sticky; top: 0; z-index: 10; }`n"
$html += "        td { padding: 20px; border-bottom: 1px solid #eee; vertical-align: top; font-size: 15px; }`n"
$html += "        tr:hover { background: #f8f9fa; }`n"
$html += "        .col-name { width: 20%; }`n"
$html += "        .col-tasks { width: 50%; }`n"
$html += "        .col-branches { width: 30%; }`n"
$html += "        .user-name { font-weight: 700; color: #667eea; font-size: 18px; }`n"
$html += "        .tasks-list { margin: 0; padding: 0; list-style: none; }`n"
$html += "        .tasks-list li { margin-bottom: 12px; padding-left: 20px; position: relative; }`n"
$html += "        .tasks-list li:before { content: '→'; position: absolute; left: 0; color: #667eea; font-weight: bold; }`n"
$html += "        .tasks-list a { color: #667eea; text-decoration: none; font-weight: 500; font-size: 14px; }`n"
$html += "        .tasks-list a:hover { text-decoration: underline; color: #764ba2; }`n"
$html += "        .task-status { display: inline-block; padding: 3px 10px; border-radius: 12px; font-size: 11px; margin-left: 8px; background: #e9ecef; color: #666; font-weight: 600; }`n"
$html += "        .branches-list { margin: 0; padding: 0; list-style: none; }`n"
$html += "        .branches-list li { margin-bottom: 8px; padding: 8px 12px; background: #f8f9fa; border-left: 3px solid #667eea; font-family: 'Courier New', monospace; font-size: 13px; border-radius: 4px; }`n"
$html += "        .commit-count { display: inline-block; background: #667eea; color: white; padding: 4px 12px; border-radius: 20px; font-weight: bold; font-size: 16px; margin-bottom: 15px; }`n"
$html += "        .no-activity { color: #ccc; font-style: italic; text-align: center; }`n"
$html += "        .timestamp { text-align: center; color: #999; font-size: 12px; padding: 20px; border-top: 1px solid #eee; margin-top: 40px; }`n"
$html += "    </style>`n</head>`n<body>`n"
$html += "    <div class='container'>`n"
$html += "        <div class='header'>`n"
$html += "            <h1>📊 Team Activity - Yesterday</h1>`n"
$html += "            <p>$yesterdayKey (All activity from yesterday only)</p>`n"
$html += "        </div>`n"
$html += "        <div class='content'>`n"
$html += "            <table>`n"
$html += "                <thead>`n"
$html += "                    <tr>`n"
$html += "                        <th class='col-name'>Team Member</th>`n"
$html += "                        <th class='col-tasks'>ClickUp Tasks</th>`n"
$html += "                        <th class='col-branches'>Branches & Commits</th>`n"
$html += "                    </tr>`n"
$html += "                </thead>`n"
$html += "                <tbody>`n"

foreach ($userEntry in ($userActivity.GetEnumerator() | Sort-Object Name)) {
    $username = $userEntry.Key
    $data = $userEntry.Value

    # Skip if no activity
    if ($data.tasks.Count -eq 0 -and $data.commitCount -eq 0) {
        continue
    }

    $html += "                    <tr>`n"

    # Column 1: Name
    $html += "                        <td class='user-name'>👤 $username</td>`n"

    # Column 2: ClickUp Tasks
    $html += "                        <td>`n"
    if ($data.tasks.Count -gt 0) {
        $html += "                            <ul class='tasks-list'>`n"
        foreach ($task in $data.tasks) {
            $taskUrl = $task.url
            $taskName = $task.name
            $taskStatus = $task.status
            $html += "                                <li><a href='$taskUrl' target='_blank'>$taskName</a> <span class='task-status'>$taskStatus</span></li>`n"
        }
        $html += "                            </ul>`n"
    } else {
        $html += "                            <span class='no-activity'>No tasks</span>`n"
    }
    $html += "                        </td>`n"

    # Column 3: Branches & Commits
    $html += "                        <td>`n"
    if ($data.commitCount -gt 0) {
        $html += "                            <div class='commit-count'>$($data.commitCount) commits</div>`n"
    }
    if ($data.branches.Count -gt 0) {
        $html += "                            <ul class='branches-list'>`n"
        foreach ($branch in $data.branches) {
            $html += "                                <li>$branch</li>`n"
        }
        $html += "                            </ul>`n"
    } elseif ($data.commitCount -eq 0) {
        $html += "                            <span class='no-activity'>No commits</span>`n"
    }
    $html += "                        </td>`n"

    $html += "                    </tr>`n"
}

$html += "                </tbody>`n"
$html += "            </table>`n"
$html += "            <div class='timestamp'>Generated: $generatedAt</div>`n"
$html += "        </div>`n"
$html += "    </div>`n"
$html += "</body>`n</html>"

$html | Out-File -FilePath $outputPath -Encoding UTF8
Write-Host "`n✅ HTML report saved to: $outputPath" -ForegroundColor Green
Start-Process $outputPath
