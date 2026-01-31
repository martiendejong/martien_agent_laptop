<#
.SYNOPSIS
    Unified team activity dashboard combining ClickUp and GitHub

.DESCRIPTION
    Generates a comprehensive team activity dashboard that combines:
    - ClickUp task management metrics
    - GitHub code contribution metrics
    - Cross-platform team insights
    - Unified HTML dashboard with charts

.PARAMETER Days
    Number of days to look back (default: 7)

.PARAMETER OutputPath
    Path to save HTML dashboard (default: C:\temp\team-dashboard.html)

.PARAMETER ClickUpProject
    Specific ClickUp project to analyze (optional, analyzes all if omitted)

.PARAMETER GitHubRepo
    Specific GitHub repository to analyze (default: martiendejong/client-manager)

.PARAMETER AllGitHubRepos
    Analyze all GitHub repositories

.PARAMETER AutoOpen
    Automatically open dashboard in browser (default: true)

.EXAMPLE
    .\team-activity-dashboard.ps1 -Days 7
    .\team-activity-dashboard.ps1 -Days 30 -OutputPath "C:\reports\team.html"
    .\team-activity-dashboard.ps1 -Days 14 -ClickUpProject client-manager -GitHubRepo martiendejong/client-manager

.NOTES
    Requires: clickup-config.json, gh CLI authenticated
    Combines data from team-activity-clickup.ps1 and team-activity-github.ps1
#>

param(
    [int]$Days = 7,
    [string]$OutputPath = "C:\temp\team-dashboard.html",
    [string]$ClickUpProject = "",
    [string]$GitHubRepo = "martiendejong/client-manager",
    [switch]$AllGitHubRepos,
    [bool]$AutoOpen = $true
)

Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        📊 UNIFIED TEAM ACTIVITY DASHBOARD GENERATOR          ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$startTime = Get-Date

# Ensure output directory exists
$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Generate ClickUp report
Write-Host "🔄 Generating ClickUp activity report..." -ForegroundColor Yellow
$clickUpArgs = @{
    Days = $Days
    Format = "json"
    OutputPath = "$outputDir\clickup-data.json"
}
if ($ClickUpProject) {
    $clickUpArgs.ProjectId = $ClickUpProject
}

$clickUpReport = & "$PSScriptRoot\team-activity-clickup.ps1" @clickUpArgs

# Generate GitHub report
Write-Host "🔄 Generating GitHub activity report..." -ForegroundColor Yellow
$githubArgs = @{
    Days = $Days
    Format = "json"
    OutputPath = "$outputDir\github-data.json"
}
if ($AllGitHubRepos) {
    $githubArgs.AllRepos = $true
} else {
    $githubArgs.Repo = $GitHubRepo
}

$githubReport = & "$PSScriptRoot\team-activity-github.ps1" @githubArgs

# Load JSON data
$clickUpData = Get-Content "$outputDir\clickup-data.json" | ConvertFrom-Json
$githubData = Get-Content "$outputDir\github-data.json" | ConvertFrom-Json

Write-Host "✅ Data collection complete. Building unified dashboard..." -ForegroundColor Green

# Combine user data
$combinedUsers = @{}

foreach ($user in $clickUpData.byUser) {
    if ($user.userName) {
        $combinedUsers[$user.userName] = @{
            clickup = $user
            github = $null
        }
    }
}

foreach ($user in $githubData.byUser) {
    if ($user.user) {
        if ($combinedUsers.ContainsKey($user.user)) {
            $combinedUsers[$user.user].github = $user
        } else {
            $combinedUsers[$user.user] = @{
                clickup = $null
                github = $user
            }
        }
    }
}

# Generate HTML dashboard
$generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Team Activity Dashboard</title>
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

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .metric-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 5px solid #667eea;
            transition: transform 0.2s;
        }
        .metric-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .metric-card .label { font-size: 12px; color: #666; text-transform: uppercase; margin-bottom: 10px; }
        .metric-card .value { font-size: 32px; font-weight: bold; color: #333; }
        .metric-card .subtext { font-size: 14px; color: #999; margin-top: 5px; }

        .section { margin-bottom: 40px; }
        .section h2 {
            font-size: 24px;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #667eea;
        }

        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        td { padding: 12px 15px; border-bottom: 1px solid #eee; }
        tr:hover { background: #f8f9fa; }
        tr:nth-child(even) { background: #fafafa; }

        .platform-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
            margin-right: 5px;
        }
        .badge-clickup { background: #7B68EE; color: white; }
        .badge-github { background: #24292e; color: white; }

        .stats-row { display: flex; gap: 10px; flex-wrap: wrap; }
        .stat-pill {
            background: #e9ecef;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 13px;
            white-space: nowrap;
        }

        .timestamp {
            text-align: center;
            color: #999;
            font-size: 12px;
            padding: 20px;
            border-top: 1px solid #eee;
            margin-top: 40px;
        }

        .url { color: #667eea; text-decoration: none; font-weight: 500; }
        .url:hover { text-decoration: underline; }

        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
            font-style: italic;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Team Activity Dashboard</h1>
            <p>$($clickUpData.period)</p>
        </div>

        <div class="content">
            <!-- SUMMARY METRICS -->
            <div class="section">
                <h2>📈 Overview Metrics</h2>
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="label">ClickUp Tasks</div>
                        <div class="value">$($clickUpData.summary.totalTasks)</div>
                        <div class="subtext">$($clickUpData.summary.completedTasks) completed ($($clickUpData.summary.completionRate)%)</div>
                    </div>
                    <div class="metric-card">
                        <div class="label">GitHub Commits</div>
                        <div class="value">$($githubData.summary.totalCommits)</div>
                        <div class="subtext">$($githubData.summary.commitsPerDay) per day</div>
                    </div>
                    <div class="metric-card">
                        <div class="label">Pull Requests</div>
                        <div class="value">$($githubData.summary.totalPRs)</div>
                        <div class="subtext">$($githubData.summary.mergedPRs) merged, $($githubData.summary.openPRs) open</div>
                    </div>
                    <div class="metric-card">
                        <div class="label">Active Contributors</div>
                        <div class="value">$($combinedUsers.Count)</div>
                        <div class="subtext">Across both platforms</div>
                    </div>
                    <div class="metric-card">
                        <div class="label">Tasks In Progress</div>
                        <div class="value">$($clickUpData.summary.inProgressTasks)</div>
                        <div class="subtext">ClickUp WIP</div>
                    </div>
                    <div class="metric-card">
                        <div class="label">Tasks/Day</div>
                        <div class="value">$($clickUpData.summary.tasksPerDay)</div>
                        <div class="subtext">ClickUp velocity</div>
                    </div>
                </div>
            </div>

            <!-- TEAM PERFORMANCE -->
            <div class="section">
                <h2>👥 Team Performance</h2>
                <table>
                    <tr>
                        <th>User</th>
                        <th>Platform</th>
                        <th>ClickUp Activity</th>
                        <th>GitHub Activity</th>
                        <th>Total Activity Score</th>
                    </tr>
"@

foreach ($userEntry in $combinedUsers.GetEnumerator() | Sort-Object {
    $cu = if ($_.Value.clickup) { $_.Value.clickup.totalTasks } else { 0 }
    $gh = if ($_.Value.github) { $_.Value.github.totalActivity } else { 0 }
    -($cu + $gh)
}) {
    $user = $userEntry.Key
    $data = $userEntry.Value

    $clickupStats = if ($data.clickup) {
        "Tasks: $($data.clickup.totalTasks) | Done: $($data.clickup.completed) | WIP: $($data.clickup.inProgress)"
    } else {
        "-"
    }

    $githubStats = if ($data.github) {
        "Commits: $($data.github.commits) | PRs: $($data.github.prsCreated) | Merged: $($data.github.prsMerged)"
    } else {
        "-"
    }

    $totalScore = 0
    $platforms = @()
    if ($data.clickup) {
        $totalScore += $data.clickup.totalTasks + $data.clickup.completed * 2
        $platforms += '<span class="platform-badge badge-clickup">ClickUp</span>'
    }
    if ($data.github) {
        $totalScore += $data.github.totalActivity * 3
        $platforms += '<span class="platform-badge badge-github">GitHub</span>'
    }

    $html += @"
                    <tr>
                        <td><strong>$user</strong></td>
                        <td>$($platforms -join ' ')</td>
                        <td>$clickupStats</td>
                        <td>$githubStats</td>
                        <td><strong>$totalScore</strong></td>
                    </tr>
"@
}

$html += @"
                </table>
            </div>

            <!-- CLICKUP PROJECTS -->
            <div class="section">
                <h2>📂 ClickUp Projects</h2>
                <table>
                    <tr>
                        <th>Project</th>
                        <th>Total Tasks</th>
                        <th>Completed</th>
                        <th>In Progress</th>
                        <th>Completion Rate</th>
                    </tr>
"@

foreach ($project in $clickUpData.byProject) {
    $completionRate = if ($project.totalTasks -gt 0) {
        [math]::Round(($project.completed / $project.totalTasks) * 100, 1)
    } else {
        0
    }
    $html += @"
                    <tr>
                        <td><strong>$($project.project)</strong></td>
                        <td>$($project.totalTasks)</td>
                        <td style="color: #28a745; font-weight: bold;">$($project.completed)</td>
                        <td style="color: #ffc107;">$($project.inProgress)</td>
                        <td>$completionRate%</td>
                    </tr>
"@
}

$html += @"
                </table>
            </div>

            <!-- GITHUB REPOSITORIES -->
            <div class="section">
                <h2>🐙 GitHub Repositories</h2>
                <table>
                    <tr>
                        <th>Repository</th>
                        <th>Commits</th>
                        <th>Pull Requests</th>
                        <th>Contributors</th>
                    </tr>
"@

foreach ($repo in $githubData.byRepo) {
    $html += @"
                    <tr>
                        <td><strong>$($repo.repository -replace '/', ' / ')</strong></td>
                        <td>$($repo.commits)</td>
                        <td>$($repo.prs)</td>
                        <td>$($repo.contributors)</td>
                    </tr>
"@
}

$html += @"
                </table>
            </div>

            <!-- RECENT ACTIVITY -->
            <div class="section">
                <h2>🕒 Recent Activity</h2>

                <h3 style="margin-top: 20px; color: #7B68EE;">ClickUp Tasks (Last 10)</h3>
                <table>
                    <tr>
                        <th>Task</th>
                        <th>Status</th>
                        <th>Project</th>
                        <th>Updated</th>
                    </tr>
"@

foreach ($activity in ($clickUpData.recentActivity | Select-Object -First 10)) {
    $html += @"
                    <tr>
                        <td><a href="$($activity.url)" class="url" target="_blank">$($activity.task)</a></td>
                        <td>$($activity.status)</td>
                        <td>$($activity.project)</td>
                        <td>$($activity.updated)</td>
                    </tr>
"@
}

$html += @"
                </table>

                <h3 style="margin-top: 30px; color: #24292e;">GitHub Commits (Last 10)</h3>
                <table>
                    <tr>
                        <th>Message</th>
                        <th>Author</th>
                        <th>Repository</th>
                        <th>Date</th>
                    </tr>
"@

foreach ($commit in ($githubData.recentCommits | Select-Object -First 10)) {
    if ($commit) {
        $commitDate = if ($commit.date) { $commit.date.ToString("yyyy-MM-dd HH:mm") } else { "-" }
        $html += @"
                    <tr>
                        <td><a href="$($commit.url)" class="url" target="_blank">$($commit.message)</a></td>
                        <td>$($commit.author)</td>
                        <td>$($commit.repo -replace '.+/', '')</td>
                        <td>$commitDate</td>
                    </tr>
"@
    }
}

$html += @"
                </table>
            </div>
        </div>

        <div class="timestamp">
            Generated: $generatedAt | Period: $($clickUpData.period) ($Days days)<br>
            ClickUp Projects: $($clickUpData.byProject.Count) | GitHub Repos: $($githubData.byRepo.Count)
        </div>
    </div>
</body>
</html>
"@

# Save dashboard
$html | Out-File -FilePath $OutputPath -Encoding UTF8

$elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 2)

Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  ✅ DASHBOARD GENERATED                       ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n📁 Location:   $OutputPath" -ForegroundColor Cyan
Write-Host "⏱️  Time:       $elapsed seconds" -ForegroundColor Gray
Write-Host "📊 Period:     $($clickUpData.period)" -ForegroundColor Yellow
Write-Host "👥 Users:      $($combinedUsers.Count)" -ForegroundColor Yellow
Write-Host "📋 Tasks:      $($clickUpData.summary.totalTasks)" -ForegroundColor Yellow
Write-Host "💻 Commits:    $($githubData.summary.totalCommits)" -ForegroundColor Yellow

if ($AutoOpen) {
    Write-Host "`n🌐 Opening dashboard in browser..." -ForegroundColor Cyan
    Start-Process $OutputPath
}

Write-Host "`n✨ Dashboard ready! Next time, just run this command for instant results." -ForegroundColor Green
