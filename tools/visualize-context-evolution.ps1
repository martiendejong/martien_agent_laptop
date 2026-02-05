# Context Evolution Visualization
# Part of Round 8 Improvements - Context Evolution Visualization
# Visual timeline of how context evolved using Git history

param(
    [Parameter(Mandatory=$false)]
    [string]$ContextPath = "C:\scripts\_machine",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\context-evolution.html",

    [Parameter(Mandatory=$false)]
    [int]$MaxCommits = 100,

    [Parameter(Mandatory=$false)]
    [string]$FileFilter = "*.md,*.yaml,*.yml"
)

$ErrorActionPreference = "Stop"

Write-Host "Context Evolution Visualization - Round 8 Implementation" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# Get git log for context files
function Get-ContextHistory {
    param([string]$Path, [int]$Limit)

    Write-Host "Analyzing git history..." -ForegroundColor Yellow

    Push-Location $Path

    try {
        # Get commit history with file stats
        $gitLog = git log --pretty=format:"%H|%an|%ae|%ad|%s" --date=iso --numstat -n $Limit -- . 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Warning: Not a git repository or no git history" -ForegroundColor Yellow
            return @()
        }

        $commits = @()
        $currentCommit = $null

        foreach ($line in $gitLog) {
            if ($line -match '^([0-9a-f]{40})\|(.+)\|(.+)\|(.+)\|(.+)$') {
                # Commit line
                if ($currentCommit) {
                    $commits += $currentCommit
                }

                $currentCommit = @{
                    Hash = $matches[1]
                    Author = $matches[2]
                    Email = $matches[3]
                    Date = [datetime]::Parse($matches[4])
                    Message = $matches[5]
                    Files = @()
                    Additions = 0
                    Deletions = 0
                }
            }
            elseif ($line -match '^(\d+)\s+(\d+)\s+(.+)$' -and $currentCommit) {
                # File stats line
                $additions = [int]$matches[1]
                $deletions = [int]$matches[2]
                $file = $matches[3]

                $currentCommit.Files += @{
                    Name = $file
                    Additions = $additions
                    Deletions = $deletions
                }

                $currentCommit.Additions += $additions
                $currentCommit.Deletions += $deletions
            }
        }

        if ($currentCommit) {
            $commits += $currentCommit
        }

        return $commits
    }
    finally {
        Pop-Location
    }
}

# Generate timeline data
Write-Host "Processing commit history..." -ForegroundColor Yellow
$commits = Get-ContextHistory -Path $ContextPath -Limit $MaxCommits

if ($commits.Count -eq 0) {
    Write-Host "No git history found. Exiting." -ForegroundColor Yellow
    return @{ Success = $false; Message = "No git history" }
}

# Group commits by date
$byDate = $commits | Group-Object -Property { $_.Date.ToString("yyyy-MM-dd") }

# Generate HTML visualization
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Context Evolution Timeline</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f7fa;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        .meta {
            color: #7f8c8d;
            margin-bottom: 30px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #ecf0f1;
            padding: 20px;
            border-radius: 6px;
            text-align: center;
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #3498db;
        }
        .stat-label {
            color: #7f8c8d;
            margin-top: 5px;
        }
        .chart-container {
            margin: 30px 0;
            height: 400px;
        }
        .timeline {
            margin-top: 30px;
        }
        .commit {
            border-left: 3px solid #3498db;
            padding-left: 20px;
            margin-bottom: 20px;
            position: relative;
        }
        .commit::before {
            content: '';
            position: absolute;
            left: -7px;
            top: 5px;
            width: 11px;
            height: 11px;
            border-radius: 50%;
            background: #3498db;
        }
        .commit-date {
            color: #7f8c8d;
            font-size: 12px;
        }
        .commit-message {
            font-weight: bold;
            color: #2c3e50;
            margin: 5px 0;
        }
        .commit-author {
            color: #95a5a6;
            font-size: 13px;
        }
        .commit-stats {
            color: #27ae60;
            font-size: 13px;
            margin-top: 5px;
        }
        .deletions {
            color: #e74c3c;
        }
        .file-list {
            margin-top: 10px;
            padding-left: 20px;
            font-size: 12px;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Context Evolution Timeline</h1>
        <div class="meta">
            <strong>Generated:</strong> $timestamp<br>
            <strong>Path:</strong> $ContextPath<br>
            <strong>Commits Analyzed:</strong> $($commits.Count)
        </div>

        <div class="stats">
            <div class="stat-card">
                <div class="stat-value">$($commits.Count)</div>
                <div class="stat-label">Total Commits</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$(($commits | ForEach-Object { $_.Author } | Select-Object -Unique).Count)</div>
                <div class="stat-label">Contributors</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$(($commits | Measure-Object -Property Additions -Sum).Sum)</div>
                <div class="stat-label">Total Additions</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$(($commits | Measure-Object -Property Deletions -Sum).Sum)</div>
                <div class="stat-label">Total Deletions</div>
            </div>
        </div>

        <h2>Activity Over Time</h2>
        <div class="chart-container">
            <canvas id="activityChart"></canvas>
        </div>

        <h2>Commit Timeline</h2>
        <div class="timeline">
"@

# Add timeline entries
foreach ($commit in $commits | Select-Object -First 50) {
    $html += @"
            <div class="commit">
                <div class="commit-date">$($commit.Date.ToString("yyyy-MM-dd HH:mm:ss"))</div>
                <div class="commit-message">$($commit.Message)</div>
                <div class="commit-author">by $($commit.Author)</div>
                <div class="commit-stats">
                    <span class="additions">+$($commit.Additions)</span> /
                    <span class="deletions">-$($commit.Deletions)</span>
                </div>
                <div class="file-list">
"@

    foreach ($file in ($commit.Files | Select-Object -First 5)) {
        $html += "                    $($file.Name) (+$($file.Additions)/-$($file.Deletions))<br>`n"
    }

    if ($commit.Files.Count -gt 5) {
        $html += "                    ... and $($commit.Files.Count - 5) more files<br>`n"
    }

    $html += @"
                </div>
            </div>
"@
}

# Generate chart data
$chartLabels = ($byDate | Sort-Object -Property Name | Select-Object -First 30 | ForEach-Object { $_.Name }) -join '","'
$chartCommits = ($byDate | Sort-Object -Property Name | Select-Object -First 30 | ForEach-Object { $_.Count }) -join ','
$chartAdditions = ($byDate | Sort-Object -Property Name | Select-Object -First 30 | ForEach-Object {
    ($_.Group | Measure-Object -Property Additions -Sum).Sum
}) -join ','
$chartDeletions = ($byDate | Sort-Object -Property Name | Select-Object -First 30 | ForEach-Object {
    ($_.Group | Measure-Object -Property Deletions -Sum).Sum
}) -join ','

$html += @"
        </div>
    </div>

    <script>
        const ctx = document.getElementById('activityChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ["$chartLabels"],
                datasets: [
                    {
                        label: 'Commits',
                        data: [$chartCommits],
                        borderColor: '#3498db',
                        backgroundColor: 'rgba(52, 152, 219, 0.1)',
                        yAxisID: 'y'
                    },
                    {
                        label: 'Additions',
                        data: [$chartAdditions],
                        borderColor: '#27ae60',
                        backgroundColor: 'rgba(39, 174, 96, 0.1)',
                        yAxisID: 'y1'
                    },
                    {
                        label: 'Deletions',
                        data: [$chartDeletions],
                        borderColor: '#e74c3c',
                        backgroundColor: 'rgba(231, 76, 60, 0.1)',
                        yAxisID: 'y1'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                scales: {
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        title: { display: true, text: 'Commits' }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        title: { display: true, text: 'Lines Changed' },
                        grid: { drawOnChartArea: false }
                    }
                }
            }
        });
    </script>
</body>
</html>
"@

# Save HTML
$html | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host ""
Write-Host "Context evolution visualization generated!" -ForegroundColor Green
Write-Host "  Commits analyzed: $($commits.Count)" -ForegroundColor Green
Write-Host "  Output file: $OutputPath" -ForegroundColor Cyan
Write-Host "  Open in browser to view timeline" -ForegroundColor Gray
Write-Host ""

return @{
    Success = $true
    CommitCount = $commits.Count
    OutputPath = $OutputPath
}
