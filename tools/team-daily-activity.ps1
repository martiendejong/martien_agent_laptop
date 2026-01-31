<#
.SYNOPSIS
    Per-person daily activity report with GitHub-ClickUp correlation

.DESCRIPTION
    Generates detailed individual contributor reports showing:
    - GitHub activity (commits, PRs, comments, reviews) per person
    - ClickUp tasks worked on per person
    - Links between GitHub work and ClickUp tasks (via branch naming)
    - Daily summaries for yesterday and today
    - Complete activity timeline with links

.PARAMETER Days
    Number of days to look back (default: 2 for yesterday + today)

.PARAMETER User
    Specific user to report on (optional, shows all if omitted)

.PARAMETER Format
    Output format: console, html (default: console)

.PARAMETER OutputPath
    Path to save HTML report (required for html format)

.PARAMETER GitHubRepo
    GitHub repository (default: martiendejong/client-manager)

.PARAMETER AllRepos
    Analyze all GitHub repositories

.EXAMPLE
    .\team-daily-activity.ps1
    .\team-daily-activity.ps1 -User "martiendejong"
    .\team-daily-activity.ps1 -Days 7 -Format html -OutputPath "C:\reports\team-activity.html"

.NOTES
    Branch naming convention: feature/<task-id>-<description>
    This allows automatic correlation between GitHub and ClickUp
#>

param(
    [int]$Days = 2,
    [string]$User = "",
    [ValidateSet("console", "html")]
    [string]$Format = "console",
    [string]$OutputPath = "",
    [string]$GitHubRepo = "martiendejong/client-manager",
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

Write-Host "`n🔍 Analyzing team activity from $($startDate.ToString('yyyy-MM-dd')) to $($today.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan

# Determine repositories to analyze
$reposToAnalyze = @()
if ($AllRepos) {
    Write-Host "  → Fetching all repositories..." -ForegroundColor Gray
    $allRepos = gh repo list --json nameWithOwner --limit 100 | ConvertFrom-Json
    $reposToAnalyze = $allRepos | ForEach-Object { $_.nameWithOwner }
} else {
    $reposToAnalyze = @($GitHubRepo)
}

# Collect GitHub data per person
Write-Host "  → Collecting GitHub activity..." -ForegroundColor Gray
$userActivity = @{}

function Extract-TaskId {
    param([string]$branchName)

    # Pattern: feature/<task-id>-<description>
    if ($branchName -match 'feature/([a-z0-9]+)-') {
        return $matches[1]
    }
    # Pattern: agent-XXX-<description> (no task ID)
    return $null
}

foreach ($repo in $reposToAnalyze) {
    Write-Host "    → Analyzing $repo..." -ForegroundColor DarkGray

    # Get commits
    $since = $startDate.ToString("yyyy-MM-ddTHH:mm:ssZ")
    try {
        $commitsJson = gh api "repos/$repo/commits?since=$since&per_page=100" 2>$null
        if ($commitsJson) {
            $commits = $commitsJson | ConvertFrom-Json
            foreach ($commit in $commits) {
                $author = if ($commit.author) { $commit.author.login } else { "Unknown" }
                if ($User -and $author -ne $User) { continue }

                $commitDate = [DateTime]::Parse($commit.commit.author.date)

                # Get branches containing this commit to extract task ID
                $branchesJson = gh api "repos/$repo/commits/$($commit.sha)/branches-where-head" 2>$null
                $taskId = $null
                if ($branchesJson) {
                    $branches = $branchesJson | ConvertFrom-Json
                    foreach ($branch in $branches) {
                        $extracted = Extract-TaskId -branchName $branch.name
                        if ($extracted) {
                            $taskId = $extracted
                            break
                        }
                    }
                }

                if (-not $userActivity.ContainsKey($author)) {
                    $userActivity[$author] = @{
                        commits = @()
                        prs = @()
                        comments = @()
                        reviews = @()
                        clickupTasks = @()
                    }
                }

                $userActivity[$author].commits += [PSCustomObject]@{
                    type = "commit"
                    repo = $repo
                    message = $commit.commit.message.Split("`n")[0]
                    sha = $commit.sha.Substring(0,7)
                    date = $commitDate
                    url = $commit.html_url
                    taskId = $taskId
                }
            }
        }
    } catch {
        Write-Warning "Failed to fetch commits from $repo"
    }

    # Get pull requests
    try {
        $prsJson = gh api "repos/$repo/pulls?state=all&per_page=100" 2>$null
        if ($prsJson) {
            $prs = $prsJson | ConvertFrom-Json
            foreach ($pr in $prs) {
                $createdDate = [DateTime]::Parse($pr.created_at)
                $updatedDate = [DateTime]::Parse($pr.updated_at)

                if ($createdDate -lt $startDate -and $updatedDate -lt $startDate) {
                    continue
                }

                $author = $pr.user.login
                if ($User -and $author -ne $User) { continue }

                # Extract task ID from branch name
                $taskId = Extract-TaskId -branchName $pr.head.ref

                if (-not $userActivity.ContainsKey($author)) {
                    $userActivity[$author] = @{
                        commits = @()
                        prs = @()
                        comments = @()
                        reviews = @()
                        clickupTasks = @()
                    }
                }

                $userActivity[$author].prs += [PSCustomObject]@{
                    type = "pr"
                    repo = $repo
                    number = $pr.number
                    title = $pr.title
                    state = $pr.state
                    merged = $pr.merged_at -ne $null
                    created = $createdDate
                    updated = $updatedDate
                    url = $pr.html_url
                    branch = $pr.head.ref
                    taskId = $taskId
                }

                # Get PR comments
                try {
                    $commentsJson = gh api "repos/$repo/issues/$($pr.number)/comments" 2>$null
                    if ($commentsJson) {
                        $comments = $commentsJson | ConvertFrom-Json
                        foreach ($comment in $comments) {
                            $commentAuthor = $comment.user.login
                            if ($User -and $commentAuthor -ne $User) { continue }

                            $commentDate = [DateTime]::Parse($comment.created_at)
                            if ($commentDate -lt $startDate) { continue }

                            if (-not $userActivity.ContainsKey($commentAuthor)) {
                                $userActivity[$commentAuthor] = @{
                                    commits = @()
                                    prs = @()
                                    comments = @()
                                    reviews = @()
                                    clickupTasks = @()
                                }
                            }

                            $userActivity[$commentAuthor].comments += [PSCustomObject]@{
                                type = "comment"
                                repo = $repo
                                pr = $pr.number
                                prTitle = $pr.title
                                body = $comment.body.Substring(0, [Math]::Min(100, $comment.body.Length))
                                date = $commentDate
                                url = $comment.html_url
                                taskId = $taskId
                            }
                        }
                    }
                } catch {
                    # Silently continue if comments fail
                }

                # Get PR reviews
                try {
                    $reviewsJson = gh api "repos/$repo/pulls/$($pr.number)/reviews" 2>$null
                    if ($reviewsJson) {
                        $reviews = $reviewsJson | ConvertFrom-Json
                        foreach ($review in $reviews) {
                            if (-not $review.user) { continue }
                            $reviewAuthor = $review.user.login
                            if ($User -and $reviewAuthor -ne $User) { continue }

                            $reviewDate = [DateTime]::Parse($review.submitted_at)
                            if ($reviewDate -lt $startDate) { continue }

                            if (-not $userActivity.ContainsKey($reviewAuthor)) {
                                $userActivity[$reviewAuthor] = @{
                                    commits = @()
                                    prs = @()
                                    comments = @()
                                    reviews = @()
                                    clickupTasks = @()
                                }
                            }

                            $userActivity[$reviewAuthor].reviews += [PSCustomObject]@{
                                type = "review"
                                repo = $repo
                                pr = $pr.number
                                prTitle = $pr.title
                                state = $review.state
                                date = $reviewDate
                                url = $review.html_url
                                taskId = $taskId
                            }
                        }
                    }
                } catch {
                    # Silently continue if reviews fail
                }
            }
        }
    } catch {
        Write-Warning "Failed to fetch PRs from $repo"
    }
}

# Collect ClickUp data
Write-Host "  → Collecting ClickUp activity..." -ForegroundColor Gray
$clickupUsers = @{}

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

            foreach ($assignee in $task.assignees) {
                $username = $assignee.username
                if ($User -and $username -ne $User) { continue }

                if (-not $clickupUsers.ContainsKey($username)) {
                    $clickupUsers[$username] = @()
                }

                $clickupUsers[$username] += [PSCustomObject]@{
                    type = "clickup_task"
                    taskId = $task.id
                    name = $task.name
                    status = $task.status.status
                    project = $proj.Value.name
                    updated = $updatedDate.DateTime
                    url = $task.url
                }

                # Add to GitHub user activity if they exist there
                if ($userActivity.ContainsKey($username)) {
                    $userActivity[$username].clickupTasks += $clickupUsers[$username][-1]
                }
            }
        }
    } catch {
        Write-Warning "Failed to fetch ClickUp tasks from $($proj.Value.name)"
    }
}

# Merge ClickUp-only users into main activity
foreach ($username in $clickupUsers.Keys) {
    if (-not $userActivity.ContainsKey($username)) {
        $userActivity[$username] = @{
            commits = @()
            prs = @()
            comments = @()
            reviews = @()
            clickupTasks = $clickupUsers[$username]
        }
    }
}

Write-Host "✅ Data collection complete. Generating report..." -ForegroundColor Green

# Generate report
$report = @()

foreach ($userEntry in $userActivity.GetEnumerator() | Sort-Object Name) {
    $username = $userEntry.Key
    $data = $userEntry.Value

    # Categorize by day
    $todayActivity = @{
        commits = @($data.commits | Where-Object { $_.date -ge $todayStart })
        prs = @($data.prs | Where-Object { $_.created -ge $todayStart -or $_.updated -ge $todayStart })
        comments = @($data.comments | Where-Object { $_.date -ge $todayStart })
        reviews = @($data.reviews | Where-Object { $_.date -ge $todayStart })
        clickupTasks = @($data.clickupTasks | Where-Object { $_.updated -ge $todayStart })
    }

    $yesterdayActivity = @{
        commits = @($data.commits | Where-Object { $_.date -ge $yesterdayStart -and $_.date -lt $todayStart })
        prs = @($data.prs | Where-Object { ($_.created -ge $yesterdayStart -and $_.created -lt $todayStart) -or ($_.updated -ge $yesterdayStart -and $_.updated -lt $todayStart) })
        comments = @($data.comments | Where-Object { $_.date -ge $yesterdayStart -and $_.date -lt $todayStart })
        reviews = @($data.reviews | Where-Object { $_.date -ge $yesterdayStart -and $_.date -lt $todayStart })
        clickupTasks = @($data.clickupTasks | Where-Object { $_.updated -ge $yesterdayStart -and $_.updated -lt $todayStart })
    }

    # Generate daily summaries
    $todaySummary = @()
    if ($todayActivity.commits.Count -gt 0) { $todaySummary += "$($todayActivity.commits.Count) commits" }
    if ($todayActivity.prs.Count -gt 0) { $todaySummary += "$($todayActivity.prs.Count) PRs" }
    if ($todayActivity.comments.Count -gt 0) { $todaySummary += "$($todayActivity.comments.Count) comments" }
    if ($todayActivity.reviews.Count -gt 0) { $todaySummary += "$($todayActivity.reviews.Count) reviews" }
    if ($todayActivity.clickupTasks.Count -gt 0) { $todaySummary += "$($todayActivity.clickupTasks.Count) tasks" }

    $yesterdaySummary = @()
    if ($yesterdayActivity.commits.Count -gt 0) { $yesterdaySummary += "$($yesterdayActivity.commits.Count) commits" }
    if ($yesterdayActivity.prs.Count -gt 0) { $yesterdaySummary += "$($yesterdayActivity.prs.Count) PRs" }
    if ($yesterdayActivity.comments.Count -gt 0) { $yesterdaySummary += "$($yesterdayActivity.comments.Count) comments" }
    if ($yesterdayActivity.reviews.Count -gt 0) { $yesterdaySummary += "$($yesterdayActivity.reviews.Count) reviews" }
    if ($yesterdayActivity.clickupTasks.Count -gt 0) { $yesterdaySummary += "$($yesterdayActivity.clickupTasks.Count) tasks" }

    # Combine all activity items
    $allItems = @()
    $allItems += $data.commits
    $allItems += $data.prs
    $allItems += $data.comments
    $allItems += $data.reviews
    $allItems += $data.clickupTasks

    $report += [PSCustomObject]@{
        user = $username
        todaySummary = if ($todaySummary.Count -gt 0) { $todaySummary -join ", " } else { "No activity today" }
        yesterdaySummary = if ($yesterdaySummary.Count -gt 0) { $yesterdaySummary -join ", " } else { "No activity yesterday" }
        todayActivity = $todayActivity
        yesterdayActivity = $yesterdayActivity
        allItems = $allItems | Sort-Object -Property date, updated, created -Descending
        totalCommits = $data.commits.Count
        totalPRs = $data.prs.Count
        totalComments = $data.comments.Count
        totalReviews = $data.reviews.Count
        totalClickUpTasks = $data.clickupTasks.Count
    }
}

# Output based on format
switch ($Format) {
    "console" {
        Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║        👥 TEAM DAILY ACTIVITY REPORT (PER PERSON)            ║" -ForegroundColor Cyan
        Write-Host "╚═══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

        foreach ($person in $report) {
            Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
            Write-Host "👤 $($person.user)" -ForegroundColor Cyan
            Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow

            Write-Host "`n📅 TODAY ($($todayStart.ToString('yyyy-MM-dd'))):" -ForegroundColor Green
            Write-Host "   $($person.todaySummary)" -ForegroundColor White

            Write-Host "`n📅 YESTERDAY ($($yesterdayStart.ToString('yyyy-MM-dd'))):" -ForegroundColor Green
            Write-Host "   $($person.yesterdaySummary)" -ForegroundColor White

            Write-Host "`n📊 TOTAL ACTIVITY (Last $Days days):" -ForegroundColor Green
            Write-Host "   Commits: $($person.totalCommits) | PRs: $($person.totalPRs) | Comments: $($person.totalComments) | Reviews: $($person.totalReviews) | ClickUp: $($person.totalClickUpTasks)" -ForegroundColor White

            Write-Host "`n📋 DETAILED ACTIVITY:" -ForegroundColor Green

            foreach ($item in $person.allItems) {
                $date = if ($item.date) { $item.date } elseif ($item.updated) { $item.updated } elseif ($item.created) { $item.created } else { $today }
                $dateStr = $date.ToString("yyyy-MM-dd HH:mm")
                $clickupLink = if ($item.taskId) { " [ClickUp: https://app.clickup.com/t/$($item.taskId)]" } else { "" }

                switch ($item.type) {
                    "commit" {
                        Write-Host "   🔹 $dateStr - COMMIT: $($item.message)" -ForegroundColor Cyan
                        Write-Host "      Repo: $($item.repo) | SHA: $($item.sha) | URL: $($item.url)$clickupLink" -ForegroundColor DarkGray
                    }
                    "pr" {
                        $state = if ($item.merged) { "MERGED" } elseif ($item.state -eq "open") { "OPEN" } else { "CLOSED" }
                        Write-Host "   🔹 $dateStr - PR #$($item.number): $($item.title) [$state]" -ForegroundColor Magenta
                        Write-Host "      Repo: $($item.repo) | Branch: $($item.branch) | URL: $($item.url)$clickupLink" -ForegroundColor DarkGray
                    }
                    "comment" {
                        Write-Host "   🔹 $dateStr - COMMENT on PR #$($item.pr): $($item.prTitle)" -ForegroundColor Yellow
                        Write-Host "      $($item.body)... | URL: $($item.url)$clickupLink" -ForegroundColor DarkGray
                    }
                    "review" {
                        Write-Host "   🔹 $dateStr - REVIEW on PR #$($item.pr): $($item.prTitle) [$($item.state)]" -ForegroundColor Green
                        Write-Host "      Repo: $($item.repo) | URL: $($item.url)$clickupLink" -ForegroundColor DarkGray
                    }
                    "clickup_task" {
                        Write-Host "   🔹 $dateStr - CLICKUP: $($item.name) [$($item.status)]" -ForegroundColor White
                        Write-Host "      Project: $($item.project) | URL: $($item.url)" -ForegroundColor DarkGray
                    }
                }
            }

            Write-Host ""
        }

        Write-Host "✅ Report complete!" -ForegroundColor Green
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
    <title>Team Daily Activity Report</title>
    <meta charset="UTF-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
        }
        .container {
            max-width: 1400px;
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

        .person-card {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 30px;
            margin-bottom: 30px;
            border-left: 5px solid #667eea;
        }
        .person-card h2 {
            color: #667eea;
            font-size: 28px;
            margin-bottom: 20px;
        }

        .daily-summary {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }
        .day-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            border: 2px solid #e9ecef;
        }
        .day-card h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 18px;
        }
        .day-card.today { border-color: #28a745; }
        .day-card.yesterday { border-color: #ffc107; }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
            margin-bottom: 30px;
        }
        .stat-box {
            background: white;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
            border: 1px solid #dee2e6;
        }
        .stat-box .value {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }
        .stat-box .label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
        }

        .activity-timeline {
            background: white;
            padding: 20px;
            border-radius: 8px;
        }
        .activity-timeline h3 {
            margin-bottom: 20px;
            color: #333;
        }
        .activity-item {
            padding: 15px;
            border-left: 3px solid #dee2e6;
            margin-bottom: 15px;
            position: relative;
            padding-left: 25px;
        }
        .activity-item::before {
            content: '';
            position: absolute;
            left: -6px;
            top: 20px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #667eea;
        }
        .activity-item.commit { border-left-color: #17a2b8; }
        .activity-item.pr { border-left-color: #6f42c1; }
        .activity-item.comment { border-left-color: #ffc107; }
        .activity-item.review { border-left-color: #28a745; }
        .activity-item.clickup_task { border-left-color: #7B68EE; }

        .activity-item .time {
            font-size: 12px;
            color: #999;
            margin-bottom: 5px;
        }
        .activity-item .title {
            font-weight: 600;
            margin-bottom: 5px;
            color: #333;
        }
        .activity-item .details {
            font-size: 13px;
            color: #666;
        }
        .activity-item a {
            color: #667eea;
            text-decoration: none;
        }
        .activity-item a:hover {
            text-decoration: underline;
        }

        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
            margin-left: 5px;
        }
        .badge-clickup { background: #7B68EE; color: white; }
        .badge-merged { background: #6f42c1; color: white; }
        .badge-open { background: #28a745; color: white; }
        .badge-closed { background: #dc3545; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👥 Team Daily Activity Report</h1>
            <p>Per-Person Activity with GitHub-ClickUp Correlation</p>
            <p>$($startDate.ToString('yyyy-MM-dd')) to $($today.ToString('yyyy-MM-dd'))</p>
        </div>

        <div class="content">
"@

        foreach ($person in $report) {
            $html += @"
            <div class="person-card">
                <h2>👤 $($person.user)</h2>

                <div class="daily-summary">
                    <div class="day-card today">
                        <h3>📅 Today ($($todayStart.ToString('yyyy-MM-dd')))</h3>
                        <p>$($person.todaySummary)</p>
                    </div>
                    <div class="day-card yesterday">
                        <h3>📅 Yesterday ($($yesterdayStart.ToString('yyyy-MM-dd')))</h3>
                        <p>$($person.yesterdaySummary)</p>
                    </div>
                </div>

                <div class="stats-grid">
                    <div class="stat-box">
                        <div class="value">$($person.totalCommits)</div>
                        <div class="label">Commits</div>
                    </div>
                    <div class="stat-box">
                        <div class="value">$($person.totalPRs)</div>
                        <div class="label">Pull Requests</div>
                    </div>
                    <div class="stat-box">
                        <div class="value">$($person.totalComments)</div>
                        <div class="label">Comments</div>
                    </div>
                    <div class="stat-box">
                        <div class="value">$($person.totalReviews)</div>
                        <div class="label">Reviews</div>
                    </div>
                    <div class="stat-box">
                        <div class="value">$($person.totalClickUpTasks)</div>
                        <div class="label">ClickUp Tasks</div>
                    </div>
                </div>

                <div class="activity-timeline">
                    <h3>📋 Activity Timeline</h3>
"@

            foreach ($item in $person.allItems) {
                $date = if ($item.date) { $item.date } elseif ($item.updated) { $item.updated } elseif ($item.created) { $item.created } else { $today }
                $dateStr = $date.ToString("yyyy-MM-dd HH:mm")
                $clickupBadge = if ($item.taskId) { "<a href='https://app.clickup.com/t/$($item.taskId)' target='_blank'><span class='badge badge-clickup'>ClickUp: $($item.taskId)</span></a>" } else { "" }

                switch ($item.type) {
                    "commit" {
                        $html += @"
                    <div class="activity-item commit">
                        <div class="time">$dateStr</div>
                        <div class="title">🔹 COMMIT: $($item.message)</div>
                        <div class="details">
                            Repo: $($item.repo) | SHA: <a href="$($item.url)" target="_blank">$($item.sha)</a>
                            $clickupBadge
                        </div>
                    </div>
"@
                    }
                    "pr" {
                        $stateBadge = if ($item.merged) { "merged" } elseif ($item.state -eq "open") { "open" } else { "closed" }
                        $html += @"
                    <div class="activity-item pr">
                        <div class="time">$dateStr</div>
                        <div class="title">🔹 PR #$($item.number): <a href="$($item.url)" target="_blank">$($item.title)</a> <span class="badge badge-$stateBadge">$($stateBadge)</span></div>
                        <div class="details">
                            Repo: $($item.repo) | Branch: $($item.branch)
                            $clickupBadge
                        </div>
                    </div>
"@
                    }
                    "comment" {
                        $html += @"
                    <div class="activity-item comment">
                        <div class="time">$dateStr</div>
                        <div class="title">🔹 COMMENT on <a href="$($item.url)" target="_blank">PR #$($item.pr): $($item.prTitle)</a></div>
                        <div class="details">
                            $($item.body)...
                            $clickupBadge
                        </div>
                    </div>
"@
                    }
                    "review" {
                        $html += @"
                    <div class="activity-item review">
                        <div class="time">$dateStr</div>
                        <div class="title">🔹 REVIEW on <a href="$($item.url)" target="_blank">PR #$($item.pr): $($item.prTitle)</a> [$($item.state)]</div>
                        <div class="details">
                            Repo: $($item.repo)
                            $clickupBadge
                        </div>
                    </div>
"@
                    }
                    "clickup_task" {
                        $html += @"
                    <div class="activity-item clickup_task">
                        <div class="time">$dateStr</div>
                        <div class="title">🔹 CLICKUP: <a href="$($item.url)" target="_blank">$($item.name)</a> [$($item.status)]</div>
                        <div class="details">
                            Project: $($item.project)
                        </div>
                    </div>
"@
                    }
                }
            }

            $html += @"
                </div>
            </div>
"@
        }

        $html += @"
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
