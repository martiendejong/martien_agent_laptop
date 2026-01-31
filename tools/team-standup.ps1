<#
.SYNOPSIS
    Daily standup report - who did what yesterday

.DESCRIPTION
    Shows only team members who had activity yesterday:
    - ClickUp tasks they worked on
    - GitHub commits, branches, PRs
    - Simple, clean format for morning standup

.PARAMETER Format
    Output format: console, html (default: html)

.PARAMETER OutputPath
    Path to save HTML report (default: C:\temp\team-standup.html)

.EXAMPLE
    .\team-standup.ps1
    .\team-standup.ps1 -Format console

.NOTES
    Analyzes yesterday only, shows only people with activity
#>

param(
    [ValidateSet("console", "html")]
    [string]$Format = "html",
    [string]$OutputPath = "C:\temp\team-standup.html"
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

# Yesterday only
$today = Get-Date
$todayStart = $today.Date
$yesterdayStart = $todayStart.AddDays(-1)
$yesterdayEnd = $todayStart

Write-Host "`n📅 Daily Standup - What happened yesterday ($($yesterdayStart.ToString('yyyy-MM-dd')))..." -ForegroundColor Cyan

# Main repos to check
$repos = @("martiendejong/client-manager", "martiendejong/Hazina", "martiendejong/machine_agents")

# Collect activity
$teamActivity = @{}

# GitHub activity
Write-Host "  → Checking GitHub..." -ForegroundColor Gray
foreach ($repo in $repos) {
    $since = $yesterdayStart.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $until = $yesterdayEnd.ToString("yyyy-MM-ddTHH:mm:ssZ")

    try {
        # Get commits from yesterday
        $commitsRaw = gh api "repos/$repo/commits?since=$since&until=$until&per_page=100"
        if ($commitsRaw) {
            $commitsJson = ($commitsRaw -join "") -replace '\x1b\[[0-9;]*m', ''
            $commits = $commitsJson | ConvertFrom-Json

            foreach ($commit in $commits) {
                $author = if ($commit.author) { $commit.author.login } else { "Unknown" }

                if (-not $teamActivity.ContainsKey($author)) {
                    $teamActivity[$author] = @{
                        commits = @()
                        branches = @()
                        prs = @()
                        tasks = @()
                    }
                }

                # Add commit
                $teamActivity[$author].commits += [PSCustomObject]@{
                    message = $commit.commit.message.Split("`n")[0]
                    repo = $repo -replace '.+/', ''
                    sha = $commit.sha.Substring(0,7)
                }

                # Get branch
                try {
                    $branchesRaw = gh api "repos/$repo/commits/$($commit.sha)/branches-where-head"
                    if ($branchesRaw) {
                        $branchesJson = ($branchesRaw -join "") -replace '\x1b\[[0-9;]*m', ''
                        $branches = $branchesJson | ConvertFrom-Json
                        foreach ($branch in $branches) {
                            $exists = $false
                            foreach ($b in $teamActivity[$author].branches) {
                                if ($b.name -eq $branch.name) {
                                    $exists = $true
                                    break
                                }
                            }
                            if (-not $exists) {
                                $teamActivity[$author].branches += [PSCustomObject]@{
                                    name = $branch.name
                                    repo = $repo -replace '.+/', ''
                                }
                            }
                        }
                    }
                } catch {}
            }
        }

        # Get PRs updated yesterday
        $prsRaw = gh api "repos/$repo/pulls?state=all&per_page=100"
        if ($prsRaw) {
            $prsJson = ($prsRaw -join "") -replace '\x1b\[[0-9;]*m', ''
            $prs = $prsJson | ConvertFrom-Json

            foreach ($pr in $prs) {
                $updated = [DateTime]::Parse($pr.updated_at)
                if ($updated -ge $yesterdayStart -and $updated -lt $yesterdayEnd) {
                    $author = $pr.user.login

                    if (-not $teamActivity.ContainsKey($author)) {
                        $teamActivity[$author] = @{
                            commits = @()
                            branches = @()
                            prs = @()
                            tasks = @()
                        }
                    }

                    $teamActivity[$author].prs += [PSCustomObject]@{
                        number = $pr.number
                        title = $pr.title
                        state = if ($pr.merged_at) { "merged" } elseif ($pr.state -eq "open") { "open" } else { "closed" }
                        repo = $repo -replace '.+/', ''
                        url = $pr.html_url
                    }
                }
            }
        }
    } catch {
        Write-Warning "Failed to fetch from $repo"
    }
}

# ClickUp activity
Write-Host "  → Checking ClickUp..." -ForegroundColor Gray
foreach ($proj in $config.projects.PSObject.Properties) {
    $listId = $proj.Value.list_id
    try {
        $url = "$apiBase/list/$listId/task?archived=false&include_closed=true"
        $response = Invoke-RestMethod -Uri $url -Headers $headers

        foreach ($task in $response.tasks) {
            $updated = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_updated)

            if ($updated.DateTime -ge $yesterdayStart -and $updated.DateTime -lt $yesterdayEnd) {
                # Get task comments to see who worked on it
                try {
                    $commentsUrl = "$apiBase/task/$($task.id)/comment"
                    $commentsResponse = Invoke-RestMethod -Uri $commentsUrl -Headers $headers

                    $workersYesterday = @{}
                    foreach ($comment in $commentsResponse.comments) {
                        $commentDate = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$comment.date)
                        if ($commentDate.DateTime -ge $yesterdayStart -and $commentDate.DateTime -lt $yesterdayEnd) {
                            $workersYesterday[$comment.user.username] = $true
                        }
                    }

                    # If no comments, use assignees
                    if ($workersYesterday.Count -eq 0) {
                        foreach ($assignee in $task.assignees) {
                            $workersYesterday[$assignee.username] = $true
                        }
                    }

                    foreach ($worker in $workersYesterday.Keys) {
                        if (-not $teamActivity.ContainsKey($worker)) {
                            $teamActivity[$worker] = @{
                                commits = @()
                                branches = @()
                                prs = @()
                                tasks = @()
                            }
                        }

                        $teamActivity[$worker].tasks += [PSCustomObject]@{
                            name = $task.name
                            status = $task.status.status
                            url = $task.url
                        }
                    }
                } catch {}
            }
        }
    } catch {}
}

Write-Host "✅ Data collected" -ForegroundColor Green

# Generate report
$reportDate = $yesterdayStart.ToString("yyyy-MM-dd")

if ($Format -eq "console") {
    Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        📅 DAILY STANDUP - $reportDate                   ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    if ($teamActivity.Count -eq 0) {
        Write-Host "  No activity yesterday." -ForegroundColor Yellow
    } else {
        foreach ($person in ($teamActivity.Keys | Sort-Object)) {
            $activity = $teamActivity[$person]

            Write-Host "👤 $person" -ForegroundColor Green

            # GitHub
            if ($activity.commits.Count -gt 0) {
                Write-Host "   GitHub: $($activity.commits.Count) commits" -ForegroundColor White
                foreach ($commit in ($activity.commits | Select-Object -First 3)) {
                    Write-Host "     • $($commit.message) ($($commit.repo))" -ForegroundColor Gray
                }
                if ($activity.commits.Count -gt 3) {
                    Write-Host "     ... and $($activity.commits.Count - 3) more commits" -ForegroundColor DarkGray
                }
            }

            if ($activity.prs.Count -gt 0) {
                Write-Host "   PRs: $($activity.prs.Count) pull requests" -ForegroundColor White
                foreach ($pr in $activity.prs) {
                    Write-Host "     • #$($pr.number): $($pr.title) [$($pr.state)] ($($pr.repo))" -ForegroundColor Gray
                }
            }

            # ClickUp
            if ($activity.tasks.Count -gt 0) {
                Write-Host "   ClickUp: $($activity.tasks.Count) tasks" -ForegroundColor White
                foreach ($task in ($activity.tasks | Select-Object -First 5)) {
                    Write-Host "     • $($task.name) [$($task.status)]" -ForegroundColor Gray
                }
                if ($activity.tasks.Count -gt 5) {
                    Write-Host "     ... and $($activity.tasks.Count - 5) more tasks" -ForegroundColor DarkGray
                }
            }

            Write-Host ""
        }
    }
} else {
    # HTML format
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Daily Standup - $reportDate</title>
    <meta charset="UTF-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 { font-size: 32px; margin-bottom: 5px; }
        .header p { font-size: 16px; opacity: 0.9; }
        .content { padding: 30px; }

        .person-card {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 5px solid #667eea;
        }
        .person-card h2 {
            color: #667eea;
            font-size: 24px;
            margin-bottom: 15px;
        }

        .section {
            margin-bottom: 15px;
        }
        .section-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            font-size: 14px;
        }
        .github { color: #24292e; }
        .clickup { color: #7B68EE; }

        ul {
            list-style: none;
            padding-left: 0;
        }
        li {
            padding: 5px 0;
            color: #666;
        }
        li:before {
            content: "•";
            color: #667eea;
            font-weight: bold;
            display: inline-block;
            width: 1em;
            margin-left: -1em;
        }

        a {
            color: #667eea;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }

        .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: bold;
            margin-left: 5px;
        }
        .badge-open { background: #28a745; color: white; }
        .badge-merged { background: #6f42c1; color: white; }
        .badge-closed { background: #dc3545; color: white; }

        .empty {
            text-align: center;
            padding: 40px;
            color: #999;
            font-style: italic;
        }

        .timestamp {
            text-align: center;
            color: #999;
            font-size: 12px;
            padding: 20px;
            border-top: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📅 Daily Standup</h1>
            <p>What happened yesterday: $reportDate</p>
        </div>

        <div class="content">
"@

    if ($teamActivity.Count -eq 0) {
        $html += "<div class='empty'>No activity yesterday.</div>"
    } else {
        foreach ($person in ($teamActivity.Keys | Sort-Object)) {
            $activity = $teamActivity[$person]

            $html += "<div class='person-card'>"
            $html += "<h2>👤 $person</h2>"

            # GitHub
            if ($activity.commits.Count -gt 0 -or $activity.prs.Count -gt 0) {
                $html += "<div class='section'>"
                $html += "<div class='section-title github'>🐙 GitHub</div>"

                if ($activity.commits.Count -gt 0) {
                    $html += "<div style='margin-bottom: 10px;'><strong>$($activity.commits.Count) commits</strong></div>"
                    $html += "<ul>"
                    foreach ($commit in ($activity.commits | Select-Object -First 3)) {
                        $html += "<li>$($commit.message) <span style='color: #999; font-size: 12px;'>($($commit.repo))</span></li>"
                    }
                    if ($activity.commits.Count -gt 3) {
                        $html += "<li style='color: #999;'>... and $($activity.commits.Count - 3) more commits</li>"
                    }
                    $html += "</ul>"
                }

                if ($activity.prs.Count -gt 0) {
                    $html += "<div style='margin: 10px 0;'><strong>$($activity.prs.Count) pull requests</strong></div>"
                    $html += "<ul>"
                    foreach ($pr in $activity.prs) {
                        $badgeClass = "badge-$($pr.state)"
                        $html += "<li><a href='$($pr.url)' target='_blank'>#$($pr.number): $($pr.title)</a> <span class='badge $badgeClass'>$($pr.state)</span> <span style='color: #999; font-size: 12px;'>($($pr.repo))</span></li>"
                    }
                    $html += "</ul>"
                }

                $html += "</div>"
            }

            # ClickUp
            if ($activity.tasks.Count -gt 0) {
                $html += "<div class='section'>"
                $html += "<div class='section-title clickup'>📋 ClickUp</div>"
                $html += "<div style='margin-bottom: 10px;'><strong>$($activity.tasks.Count) tasks</strong></div>"
                $html += "<ul>"
                foreach ($task in ($activity.tasks | Select-Object -First 5)) {
                    $html += "<li><a href='$($task.url)' target='_blank'>$($task.name)</a> <span style='color: #999; font-size: 12px;'>[$($task.status)]</span></li>"
                }
                if ($activity.tasks.Count -gt 5) {
                    $html += "<li style='color: #999;'>... and $($activity.tasks.Count - 5) more tasks</li>"
                }
                $html += "</ul>"
                $html += "</div>"
            }

            $html += "</div>"
        }
    }

    $html += @"
            <div class="timestamp">
                Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            </div>
        </div>
    </div>
</body>
</html>
"@

    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "`n✅ Daily standup report saved to: $OutputPath" -ForegroundColor Green
    Start-Process $OutputPath
}
