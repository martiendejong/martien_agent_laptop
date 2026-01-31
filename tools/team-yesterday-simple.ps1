<#
.SYNOPSIS
    Clean per-person daily activity table (only actual activity)

.DESCRIPTION
    Generates a clean table showing only tasks where team members actually worked:
    - Only tasks with comments, status changes, or updates by that person
    - Commit counts per day
    - PR counts (created/merged) per day
    - Clean table format like the main dashboard

.PARAMETER Days
    Number of days to look back (default: 2 for yesterday + today)

.PARAMETER Format
    Output format: console, html (default: html)

.PARAMETER OutputPath
    Path to save HTML report (default: C:\temp\team-activity-clean.html)

.PARAMETER GitHubRepo
    GitHub repository (default: martiendejong/client-manager)

.PARAMETER AllRepos
    Analyze all GitHub repositories

.EXAMPLE
    .\team-activity-clean.ps1
    .\team-activity-clean.ps1 -Days 7
    .\team-activity-clean.ps1 -Format console

.NOTES
    Only shows tasks where person actively worked (comments, updates, status changes)
#>

param(
    [int]$Days = 7,
    [ValidateSet("console", "html")]
    [string]$Format = "html",
    [string]$OutputPath = "C:\temp\team-activity-clean.html",
    [string]$GitHubRepo = "",
    [switch]$AllRepos
)

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

# Calculate date ranges
$today = Get-Date
$todayStart = $today.Date
$yesterdayStart = $todayStart.AddDays(-1)
$startDate = $todayStart.AddDays(-$Days)

Write-Host "`n🔍 Analyzing actual team activity..." -ForegroundColor Cyan

# Determine repositories to analyze
$reposToAnalyze = @()
if ($AllRepos) {
    Write-Host "  → Fetching all repositories..." -ForegroundColor Gray
    $allRepos = gh repo list --json nameWithOwner --limit 100 2>$null | ConvertFrom-Json
    $reposToAnalyze = $allRepos | ForEach-Object { $_.nameWithOwner }
} else {
    # Default to main repos
    $reposToAnalyze = @("martiendejong/client-manager", "martiendejong/Hazina", "martiendejong/machine_agents")
}

# Collect all team members first
Write-Host "  → Collecting team members..." -ForegroundColor Gray
$allTeamMembers = @{}

# Known team members (hardcoded based on your team)
$knownMembers = @("martiendejong", "Diko Mohamed", "Frank Kobaai ", "Lessy.", "Simitia Mpoe", "Timothy Opiyo")
foreach ($member in $knownMembers) {
    $allTeamMembers[$member] = $true
}

# Collect GitHub data per person per day
Write-Host "  → Collecting GitHub activity..." -ForegroundColor Gray
$userActivity = @{}

foreach ($repo in $reposToAnalyze) {
    Write-Host "    → Analyzing $repo..." -ForegroundColor DarkGray

    # Get commits
    $since = $startDate.ToString("yyyy-MM-ddTHH:mm:ssZ")
    try {
        $commitsRaw = gh api "repos/$repo/commits?since=$since&per_page=100"
        if ($commitsRaw) {
            $commitsJson = ($commitsRaw -join "") -replace '\x1b\[[0-9;]*m', ''
            $commits = $commitsJson | ConvertFrom-Json
            foreach ($commit in $commits) {
                $author = if ($commit.author) { $commit.author.login } else { "Unknown" }
                $commitDate = [DateTime]::Parse($commit.commit.author.date)
                $dayKey = $commitDate.Date.ToString("yyyy-MM-dd")

                $allTeamMembers[$author] = $true

                if (-not $userActivity.ContainsKey($author)) {
                    $userActivity[$author] = @{}
                }
                if (-not $userActivity[$author].ContainsKey($dayKey)) {
                    $userActivity[$author][$dayKey] = @{
                        commits = 0
                        prsCreated = 0
                        prsMerged = 0
                        tasks = @()
                        branches = @()
                        prs = @()
                    }
                }
                $userActivity[$author][$dayKey].commits++

                # Get branches for this commit
                try {
                    $branchesJson = gh api "repos/$repo/commits/$($commit.sha)/branches-where-head" 2>$null
                    if ($branchesJson) {
                        $branches = $branchesJson | ConvertFrom-Json
                        foreach ($branch in $branches) {
                            $branchName = $branch.name
                            # Add to branches list if not already there
                            $branchExists = $false
                            foreach ($b in $userActivity[$author][$dayKey].branches) {
                                if ($b.name -eq $branchName) {
                                    $branchExists = $true
                                    break
                                }
                            }
                            if (-not $branchExists) {
                                $userActivity[$author][$dayKey].branches += [PSCustomObject]@{
                                    name = $branchName
                                    repo = $repo
                                }
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

    # Get pull requests
    try {
        $prsRaw = gh api "repos/$repo/pulls?state=all&per_page=100"
        if ($prsRaw) {
            $prsJson = ($prsRaw -join "") -replace '\x1b\[[0-9;]*m', ''
            $prs = $prsJson | ConvertFrom-Json
            foreach ($pr in $prs) {
                $createdDate = [DateTime]::Parse($pr.created_at)
                $updatedDate = [DateTime]::Parse($pr.updated_at)

                # Track PR involvement (author, commenter, reviewer)
                $involvedUsers = @{}

                # PR author
                $author = $pr.user.login
                $involvedUsers[$author] = $true
                $allTeamMembers[$author] = $true

                # PR reviewers - get reviews
                try {
                    $reviewsJson = gh api "repos/$repo/pulls/$($pr.number)/reviews" 2>$null
                    if ($reviewsJson) {
                        $reviews = $reviewsJson | ConvertFrom-Json
                        foreach ($review in $reviews) {
                            if ($review.user) {
                                $reviewer = $review.user.login
                                $involvedUsers[$reviewer] = $true
                                $allTeamMembers[$reviewer] = $true
                            }
                        }
                    }
                } catch {
                    # Silently continue
                }

                # Track PR for each involved user
                foreach ($user in $involvedUsers.Keys) {
                    # Determine the relevant day (created or updated)
                    $relevantDates = @()
                    if ($createdDate -ge $startDate) {
                        $relevantDates += $createdDate.Date.ToString("yyyy-MM-dd")
                    }
                    if ($updatedDate -ge $startDate -and $updatedDate.Date -ne $createdDate.Date) {
                        $relevantDates += $updatedDate.Date.ToString("yyyy-MM-dd")
                    }

                    foreach ($dayKey in $relevantDates) {
                        if (-not $userActivity.ContainsKey($user)) {
                            $userActivity[$user] = @{}
                        }
                        if (-not $userActivity[$user].ContainsKey($dayKey)) {
                            $userActivity[$user][$dayKey] = @{
                                commits = 0
                                prsCreated = 0
                                prsMerged = 0
                                tasks = @()
                                branches = @()
                                prs = @()
                            }
                        }

                        # Add PR if not already there
                        $prExists = $false
                        foreach ($p in $userActivity[$user][$dayKey].prs) {
                            if ($p.number -eq $pr.number) {
                                $prExists = $true
                                break
                            }
                        }
                        if (-not $prExists) {
                            $userActivity[$user][$dayKey].prs += [PSCustomObject]@{
                                number = $pr.number
                                title = $pr.title
                                url = $pr.html_url
                                state = $pr.state
                                merged = $pr.merged_at -ne $null
                                repo = $repo
                                isAuthor = ($user -eq $author)
                            }
                        }

                        # Track stats
                        if ($user -eq $author -and $createdDate.Date.ToString("yyyy-MM-dd") -eq $dayKey) {
                            $userActivity[$user][$dayKey].prsCreated++
                        }
                        if ($pr.merged_at) {
                            $mergedDate = [DateTime]::Parse($pr.merged_at)
                            if ($mergedDate.Date.ToString("yyyy-MM-dd") -eq $dayKey -and $pr.merged_by -and $pr.merged_by.login -eq $user) {
                                $userActivity[$user][$dayKey].prsMerged++
                            }
                        }
                    }
                }
            }
        }
    } catch {
        # Silently continue
    }
}

# Collect ClickUp data - only tasks with actual activity
Write-Host "  → Collecting ClickUp activity (only actual work)..." -ForegroundColor Gray

foreach ($proj in $config.projects.PSObject.Properties) {
    $listId = $proj.Value.list_id
    try {
        $url = "$apiBase/list/$listId/task?archived=false&include_closed=true"
        $response = Invoke-RestMethod -Uri $url -Headers $headers

        foreach ($task in $response.tasks) {
            $updatedDate = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_updated)

            if ($updatedDate.DateTime -lt $startDate) {
                continue
            }

            # Get task comments to see who actually worked on it
            $taskCommenters = @{}
            try {
                $commentsUrl = "$apiBase/task/$($task.id)/comment"
                $commentsResponse = Invoke-RestMethod -Uri $commentsUrl -Headers $headers

                foreach ($comment in $commentsResponse.comments) {
                    $commentDate = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$comment.date)
                    if ($commentDate.DateTime -ge $startDate) {
                        $commenter = $comment.user.username
                        $dayKey = $commentDate.DateTime.Date.ToString("yyyy-MM-dd")

                        if (-not $taskCommenters.ContainsKey($commenter)) {
                            $taskCommenters[$commenter] = @()
                        }
                        if ($dayKey -notin $taskCommenters[$commenter]) {
                            $taskCommenters[$commenter] += $dayKey
                        }
                    }
                }
            } catch {
                # If comments fail, fall back to assignees who updated recently
                foreach ($assignee in $task.assignees) {
                    $username = $assignee.username
                    $dayKey = $updatedDate.DateTime.Date.ToString("yyyy-MM-dd")
                    if (-not $taskCommenters.ContainsKey($username)) {
                        $taskCommenters[$username] = @()
                    }
                    if ($dayKey -notin $taskCommenters[$username]) {
                        $taskCommenters[$username] += $dayKey
                    }
                }
            }

            # Add task to users who actually worked on it
            foreach ($username in $taskCommenters.Keys) {
                foreach ($dayKey in $taskCommenters[$username]) {
                    if (-not $userActivity.ContainsKey($username)) {
                        $userActivity[$username] = @{}
                    }
                    if (-not $userActivity[$username].ContainsKey($dayKey)) {
                        $userActivity[$username][$dayKey] = @{
                            commits = 0
                            prsCreated = 0
                            prsMerged = 0
                            tasks = @()
                        }
                    }

                    # Add task if not already added
                    $taskExists = $false
                    foreach ($t in $userActivity[$username][$dayKey].tasks) {
                        if ($t.id -eq $task.id) {
                            $taskExists = $true
                            break
                        }
                    }

                    if (-not $taskExists) {
                        $userActivity[$username][$dayKey].tasks += [PSCustomObject]@{
                            id = $task.id
                            name = $task.name
                            status = $task.status.status
                            url = $task.url
                        }
                    }
                }
            }
        }
    } catch {
        Write-Warning "Failed to fetch ClickUp tasks from $($proj.Value.name)"
    }
}

Write-Host "✅ Data collection complete. Generating report..." -ForegroundColor Green

# Build report data
$reportData = @()
$allDays = @()

# Get all unique days
for ($i = 0; $i -lt $Days; $i++) {
    $day = $todayStart.AddDays(-$i)
    $allDays += $day.ToString("yyyy-MM-dd")
}
$allDays = $allDays | Sort-Object

foreach ($userEntry in ($userActivity.GetEnumerator() | Sort-Object Name)) {
    $username = $userEntry.Key
    $userDays = $userEntry.Value

    $userRow = [PSCustomObject]@{
        user = $username
        days = @{}
    }

    foreach ($dayKey in $allDays) {
        if ($userDays.ContainsKey($dayKey)) {
            $dayData = $userDays[$dayKey]
            $userRow.days[$dayKey] = [PSCustomObject]@{
                commits = $dayData.commits
                prsCreated = $dayData.prsCreated
                prsMerged = $dayData.prsMerged
                tasks = $dayData.tasks
                hasActivity = ($dayData.commits -gt 0 -or $dayData.prsCreated -gt 0 -or $dayData.prsMerged -gt 0 -or $dayData.tasks.Count -gt 0)
            }
        } else {
            $userRow.days[$dayKey] = [PSCustomObject]@{
                commits = 0
                prsCreated = 0
                prsMerged = 0
                tasks = @()
                hasActivity = $false
            }
        }
    }

    $reportData += $userRow
}

# Output based on format
$generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

switch ($Format) {
    "console" {
        Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║           📊 TEAM ACTIVITY TABLE (ACTUAL WORK ONLY)          ║" -ForegroundColor Cyan
        Write-Host "╚═══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

        foreach ($dayKey in $allDays) {
            Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
            Write-Host "📅 $dayKey" -ForegroundColor Cyan
            Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow

            foreach ($person in $reportData) {
                $dayData = $person.days[$dayKey]
                if ($dayData.hasActivity) {
                    Write-Host "`n👤 $($person.user)" -ForegroundColor Green

                    # GitHub stats
                    $stats = @()
                    if ($dayData.commits -gt 0) { $stats += "$($dayData.commits) commits" }
                    if ($dayData.prsCreated -gt 0) { $stats += "$($dayData.prsCreated) PRs created" }
                    if ($dayData.prsMerged -gt 0) { $stats += "$($dayData.prsMerged) PRs merged" }
                    if ($stats.Count -gt 0) {
                        Write-Host "   GitHub: $($stats -join ', ')" -ForegroundColor White
                    }

                    # Tasks
                    if ($dayData.tasks.Count -gt 0) {
                        Write-Host "   Tasks:" -ForegroundColor White
                        foreach ($task in $dayData.tasks) {
                            Write-Host "     • $($task.name) [$($task.status)]" -ForegroundColor Gray
                            Write-Host "       $($task.url)" -ForegroundColor DarkGray
                        }
                    }
                }
            }
        }

        Write-Host "`n✅ Report complete!" -ForegroundColor Green
    }

    "html" {
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Team Activity Table</title>
    <meta charset="UTF-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
        }
        .container {
            max-width: 1600px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        .header h1 { font-size: 36px; margin-bottom: 10px; }
        .header p { font-size: 18px; opacity: 0.9; }
        .content { padding: 40px; }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        td {
            padding: 15px;
            border-bottom: 1px solid #eee;
            vertical-align: top;
        }
        tr:hover {
            background: #f8f9fa;
        }

        .user-name {
            font-weight: 600;
            color: #667eea;
            font-size: 16px;
        }

        .tasks-list {
            margin: 0;
            padding: 0;
            list-style: none;
        }
        .tasks-list li {
            margin-bottom: 8px;
        }
        .tasks-list a {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }
        .tasks-list a:hover {
            text-decoration: underline;
        }
        .task-status {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 11px;
            margin-left: 5px;
            background: #e9ecef;
            color: #666;
        }

        .stat-number {
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }
        .stat-label {
            font-size: 11px;
            color: #999;
            text-transform: uppercase;
        }
        .stat-group {
            display: flex;
            gap: 20px;
            align-items: center;
        }
        .stat-item {
            text-align: center;
        }

        .no-activity {
            color: #ccc;
            font-style: italic;
            text-align: center;
        }

        .day-header {
            background: #f8f9fa !important;
            color: #333 !important;
            font-size: 14px;
            text-align: center;
        }

        .timestamp {
            text-align: center;
            color: #999;
            font-size: 12px;
            padding: 20px;
            border-top: 1px solid #eee;
            margin-top: 40px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Team Activity Table</h1>
            <p>Actual Work Only (Comments, Updates, Commits, PRs)</p>
            <p>$($startDate.ToString('yyyy-MM-dd')) to $($today.ToString('yyyy-MM-dd'))</p>
        </div>

        <div class="content">
            <table>
                <thead>
                    <tr>
                        <th style="width: 200px;">Team Member</th>
"@

        foreach ($dayKey in $allDays) {
            $dayDate = [DateTime]::Parse($dayKey)
            $dayName = $dayDate.ToString("ddd")
            $html += "<th class='day-header'>$dayName<br>$dayKey</th>"
        }

        $html += @"
                    </tr>
                </thead>
                <tbody>
"@

        foreach ($person in $reportData) {
            $html += "<tr><td class='user-name'>👤 $($person.user)</td>"

            foreach ($dayKey in $allDays) {
                $dayData = $person.days[$dayKey]

                if ($dayData.hasActivity) {
                    $html += "<td>"

                    # GitHub stats
                    if ($dayData.commits -gt 0 -or $dayData.prsCreated -gt 0 -or $dayData.prsMerged -gt 0) {
                        $html += "<div class='stat-group'>"
                        if ($dayData.commits -gt 0) {
                            $html += @"
                                <div class='stat-item'>
                                    <div class='stat-number'>$($dayData.commits)</div>
                                    <div class='stat-label'>Commits</div>
                                </div>
"@
                        }
                        if ($dayData.prsCreated -gt 0) {
                            $html += @"
                                <div class='stat-item'>
                                    <div class='stat-number'>$($dayData.prsCreated)</div>
                                    <div class='stat-label'>PRs Created</div>
                                </div>
"@
                        }
                        if ($dayData.prsMerged -gt 0) {
                            $html += @"
                                <div class='stat-item'>
                                    <div class='stat-number'>$($dayData.prsMerged)</div>
                                    <div class='stat-label'>PRs Merged</div>
                                </div>
"@
                        }
                        $html += "</div>"
                    }

                    # Tasks
                    if ($dayData.tasks.Count -gt 0) {
                        if ($dayData.commits -gt 0 -or $dayData.prsCreated -gt 0 -or $dayData.prsMerged -gt 0) {
                            $html += "<hr style='margin: 15px 0; border: none; border-top: 1px solid #eee;'>"
                        }
                        $html += "<ul class='tasks-list'>"
                        foreach ($task in $dayData.tasks) {
                            $html += "<li><a href='$($task.url)' target='_blank'>$($task.name)</a> <span class='task-status'>$($task.status)</span></li>"
                        }
                        $html += "</ul>"
                    }

                    $html += "</td>"
                } else {
                    $html += "<td class='no-activity'>-</td>"
                }
            }

            $html += "</tr>"
        }

        $html += @"
                </tbody>
            </table>

            <div class="timestamp">
                Generated: $generatedAt
            </div>
        </div>
    </div>
</body>
</html>
"@

        $html | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "`n✅ HTML report saved to: $OutputPath" -ForegroundColor Green
        Start-Process $OutputPath
    }
}

