<#
.SYNOPSIS
    GitHub team activity report generator

.DESCRIPTION
    Generates comprehensive team activity reports from GitHub including:
    - Commits by author
    - Pull requests created/reviewed/merged
    - Code review participation
    - Repository activity breakdown
    - Contribution timeline

.PARAMETER Days
    Number of days to look back (default: 7)

.PARAMETER Repo
    Specific repository to analyze (default: martiendejong/client-manager)
    Format: owner/repo

.PARAMETER Format
    Output format: console, json, html (default: console)

.PARAMETER OutputPath
    Path to save report file (required for json/html formats)

.PARAMETER AllRepos
    Analyze all repositories (overrides -Repo)

.EXAMPLE
    .\team-activity-github.ps1 -Days 7
    .\team-activity-github.ps1 -Days 30 -Format html -OutputPath "C:\temp\github-report.html"
    .\team-activity-github.ps1 -Repo martiendejong/hazina -Days 14
    .\team-activity-github.ps1 -AllRepos -Days 7

.NOTES
    Requires: gh CLI authenticated
#>

param(
    [int]$Days = 7,
    [string]$Repo = "martiendejong/client-manager",
    [ValidateSet("console", "json", "html")]
    [string]$Format = "console",
    [string]$OutputPath = "",
    [switch]$AllRepos
)

# Calculate date range
$endDate = Get-Date
$startDate = $endDate.AddDays(-$Days)
$since = $startDate.ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "`n🔍 Analyzing GitHub activity from $($startDate.ToString('yyyy-MM-dd')) to $($endDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan

# Determine repositories to analyze
$reposToAnalyze = @()
if ($AllRepos) {
    Write-Host "  → Fetching all repositories..." -ForegroundColor Gray
    $allRepos = gh repo list --json nameWithOwner --limit 100 | ConvertFrom-Json
    $reposToAnalyze = $allRepos | ForEach-Object { $_.nameWithOwner }
} else {
    $reposToAnalyze = @($Repo)
}

# Collect data
$allCommits = @()
$allPRs = @()
$userStats = @{}

foreach ($repository in $reposToAnalyze) {
    Write-Host "  → Analyzing $repository..." -ForegroundColor Gray

    # Get commits
    try {
        $commitsJson = gh api "repos/$repository/commits?since=$since&per_page=100" 2>$null
        if ($commitsJson) {
            $commits = $commitsJson | ConvertFrom-Json
            foreach ($commit in $commits) {
                $author = if ($commit.author) { $commit.author.login } else { "Unknown" }
                $commitDate = [DateTime]::Parse($commit.commit.author.date)

                $allCommits += [PSCustomObject]@{
                    repo = $repository
                    author = $author
                    message = $commit.commit.message.Split("`n")[0]  # First line only
                    date = $commitDate
                    sha = $commit.sha.Substring(0,7)
                    url = $commit.html_url
                }

                # Track by user
                if (-not $userStats.ContainsKey($author)) {
                    $userStats[$author] = @{
                        commits = 0
                        prsCreated = 0
                        prsReviewed = 0
                        prsMerged = 0
                    }
                }
                $userStats[$author].commits++
            }
        }
    } catch {
        Write-Warning "Failed to fetch commits from $repository"
    }

    # Get pull requests
    try {
        $prsJson = gh api "repos/$repository/pulls?state=all&per_page=100" 2>$null
        if ($prsJson) {
            $prs = $prsJson | ConvertFrom-Json
            foreach ($pr in $prs) {
                $createdDate = [DateTime]::Parse($pr.created_at)
                $updatedDate = [DateTime]::Parse($pr.updated_at)

                # Filter to time range
                if ($createdDate -ge $startDate -or $updatedDate -ge $startDate) {
                    $author = $pr.user.login

                    $allPRs += [PSCustomObject]@{
                        repo = $repository
                        number = $pr.number
                        title = $pr.title
                        author = $author
                        state = $pr.state
                        merged = $pr.merged_at -ne $null
                        created = $createdDate
                        updated = $updatedDate
                        url = $pr.html_url
                    }

                    # Track by user
                    if (-not $userStats.ContainsKey($author)) {
                        $userStats[$author] = @{
                            commits = 0
                            prsCreated = 0
                            prsReviewed = 0
                            prsMerged = 0
                        }
                    }

                    if ($createdDate -ge $startDate) {
                        $userStats[$author].prsCreated++
                    }
                    if ($pr.merged_at -and ([DateTime]::Parse($pr.merged_at)) -ge $startDate) {
                        $userStats[$author].prsMerged++
                    }
                }
            }
        }
    } catch {
        Write-Warning "Failed to fetch PRs from $repository"
    }
}

# Build report
$report = [PSCustomObject]@{
    period = "$($startDate.ToString('yyyy-MM-dd')) to $($endDate.ToString('yyyy-MM-dd'))"
    days = $Days
    repositories = $reposToAnalyze
    generatedAt = $endDate.ToString("yyyy-MM-dd HH:mm:ss")
    summary = [PSCustomObject]@{
        totalCommits = $allCommits.Count
        totalPRs = $allPRs.Count
        openPRs = ($allPRs | Where-Object { $_.state -eq 'open' }).Count
        mergedPRs = ($allPRs | Where-Object { $_.merged }).Count
        contributors = $userStats.Keys.Count
        commitsPerDay = [math]::Round($allCommits.Count / $Days, 2)
    }
    byUser = $userStats.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            user = $_.Key
            commits = $_.Value.commits
            prsCreated = $_.Value.prsCreated
            prsMerged = $_.Value.prsMerged
            totalActivity = $_.Value.commits + $_.Value.prsCreated + $_.Value.prsMerged
        }
    } | Sort-Object -Property totalActivity -Descending
    byRepo = $allCommits | Group-Object -Property repo | ForEach-Object {
        $repoCommits = $_.Group
        $repoPRs = $allPRs | Where-Object { $_.repo -eq $_.Name }
        [PSCustomObject]@{
            repository = $_.Name
            commits = $repoCommits.Count
            prs = $repoPRs.Count
            contributors = ($repoCommits | Select-Object -Property author -Unique).Count
        }
    } | Sort-Object -Property commits -Descending
    recentCommits = $allCommits |
        Sort-Object -Property date -Descending |
        Select-Object -First 20
    recentPRs = $allPRs |
        Sort-Object -Property updated -Descending |
        Select-Object -First 10
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

        $repoList = ($report.repositories -join '<br>') -replace '/', ' / '

        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>GitHub Team Activity Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #24292e; border-bottom: 3px solid #0366d6; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 30px; }
        .metric { display: inline-block; margin: 10px 20px 10px 0; padding: 15px; background: #f9f9f9; border-radius: 5px; border-left: 4px solid #0366d6; }
        .metric .label { font-size: 12px; color: #666; text-transform: uppercase; }
        .metric .value { font-size: 28px; font-weight: bold; color: #333; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th { background: #24292e; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #eee; }
        tr:hover { background: #f5f5f5; }
        .timestamp { color: #999; font-size: 12px; text-align: right; margin-top: 30px; }
        .url { color: #0366d6; text-decoration: none; }
        .url:hover { text-decoration: underline; }
        .sha { font-family: 'Courier New', monospace; background: #f6f8fa; padding: 2px 6px; border-radius: 3px; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐙 GitHub Team Activity Report</h1>
        <p><strong>Period:</strong> $($report.period)</p>
        <p><strong>Repositories:</strong><br>$repoList</p>

        <h2>📈 Summary Metrics</h2>
        <div class="metric">
            <div class="label">Total Commits</div>
            <div class="value">$($report.summary.totalCommits)</div>
        </div>
        <div class="metric">
            <div class="label">Total PRs</div>
            <div class="value">$($report.summary.totalPRs)</div>
        </div>
        <div class="metric">
            <div class="label">Merged PRs</div>
            <div class="value" style="color: #28a745;">$($report.summary.mergedPRs)</div>
        </div>
        <div class="metric">
            <div class="label">Open PRs</div>
            <div class="value" style="color: #ffc107;">$($report.summary.openPRs)</div>
        </div>
        <div class="metric">
            <div class="label">Contributors</div>
            <div class="value">$($report.summary.contributors)</div>
        </div>
        <div class="metric">
            <div class="label">Commits/Day</div>
            <div class="value">$($report.summary.commitsPerDay)</div>
        </div>

        <h2>👥 Contributor Activity</h2>
        <table>
            <tr>
                <th>User</th>
                <th>Commits</th>
                <th>PRs Created</th>
                <th>PRs Merged</th>
                <th>Total Activity</th>
            </tr>
"@
        foreach ($user in $report.byUser) {
            $html += @"
            <tr>
                <td><strong>$($user.user)</strong></td>
                <td>$($user.commits)</td>
                <td>$($user.prsCreated)</td>
                <td style="color: #28a745;">$($user.prsMerged)</td>
                <td><strong>$($user.totalActivity)</strong></td>
            </tr>
"@
        }

        $html += @"
        </table>

        <h2>📂 By Repository</h2>
        <table>
            <tr>
                <th>Repository</th>
                <th>Commits</th>
                <th>PRs</th>
                <th>Contributors</th>
            </tr>
"@
        foreach ($repo in $report.byRepo) {
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

        <h2>🕒 Recent Commits (Last 20)</h2>
        <table>
            <tr>
                <th>SHA</th>
                <th>Message</th>
                <th>Author</th>
                <th>Repository</th>
                <th>Date</th>
            </tr>
"@
        foreach ($commit in $report.recentCommits) {
            $html += @"
            <tr>
                <td><a href="$($commit.url)" class="url sha" target="_blank">$($commit.sha)</a></td>
                <td>$($commit.message)</td>
                <td>$($commit.author)</td>
                <td>$($commit.repo -replace '.+/', '')</td>
                <td>$($commit.date.ToString("yyyy-MM-dd HH:mm"))</td>
            </tr>
"@
        }

        $html += @"
        </table>

        <h2>🔀 Recent Pull Requests (Last 10)</h2>
        <table>
            <tr>
                <th>#</th>
                <th>Title</th>
                <th>Author</th>
                <th>Repository</th>
                <th>State</th>
                <th>Updated</th>
            </tr>
"@
        foreach ($pr in $report.recentPRs) {
            $stateColor = if ($pr.merged) { "#6f42c1" } elseif ($pr.state -eq "open") { "#28a745" } else { "#d73a49" }
            $stateText = if ($pr.merged) { "Merged" } else { $pr.state }
            $html += @"
            <tr>
                <td><a href="$($pr.url)" class="url" target="_blank">#$($pr.number)</a></td>
                <td>$($pr.title)</td>
                <td>$($pr.author)</td>
                <td>$($pr.repo -replace '.+/', '')</td>
                <td style="color: $stateColor; font-weight: bold;">$stateText</td>
                <td>$($pr.updated.ToString("yyyy-MM-dd HH:mm"))</td>
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
        Write-Host "║           🐙 GITHUB TEAM ACTIVITY REPORT                     ║" -ForegroundColor Cyan
        Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

        Write-Host "`n📅 Period: $($report.period)" -ForegroundColor Yellow
        Write-Host "📂 Repositories: $($report.repositories.Count)" -ForegroundColor Yellow

        Write-Host "`n📈 SUMMARY METRICS" -ForegroundColor Green
        Write-Host "  Total Commits:    $($report.summary.totalCommits)"
        Write-Host "  Total PRs:        $($report.summary.totalPRs)"
        Write-Host "  Merged PRs:       $($report.summary.mergedPRs)" -ForegroundColor Green
        Write-Host "  Open PRs:         $($report.summary.openPRs)" -ForegroundColor Yellow
        Write-Host "  Contributors:     $($report.summary.contributors)"
        Write-Host "  Commits/Day:      $($report.summary.commitsPerDay)" -ForegroundColor Cyan

        Write-Host "`n👥 CONTRIBUTOR ACTIVITY" -ForegroundColor Green
        $report.byUser | Format-Table -Property user, commits, prsCreated, prsMerged, totalActivity -AutoSize

        Write-Host "📂 BY REPOSITORY" -ForegroundColor Green
        $report.byRepo | Format-Table -Property repository, commits, prs, contributors -AutoSize

        Write-Host "🕒 RECENT COMMITS (Last 20)" -ForegroundColor Green
        $report.recentCommits | Format-Table -Property sha, message, author, date -AutoSize

        Write-Host "🔀 RECENT PULL REQUESTS (Last 10)" -ForegroundColor Green
        $report.recentPRs | ForEach-Object {
            $stateColor = if ($_.merged) { "Magenta" } elseif ($_.state -eq "open") { "Green" } else { "Red" }
            $stateText = if ($_.merged) { "Merged" } else { $_.state }
            Write-Host "  #$($_.number) - $($_.title)" -ForegroundColor Cyan
            Write-Host "    Author: $($_.author) | State: $stateText | Repo: $($_.repo)" -ForegroundColor $stateColor
        }

        Write-Host "`n✅ Report complete!" -ForegroundColor Green
    }
}

# Return report object for piping
return $report
