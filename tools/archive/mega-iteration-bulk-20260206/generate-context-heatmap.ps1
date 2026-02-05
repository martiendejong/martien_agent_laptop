# Context Heat Map Generator
# Part of Round 10 Improvements - Context Heat Map
# Visual representation of frequently-accessed context

param(
    [Parameter(Mandatory=$false)]
    [string]$AccessLogPath = "C:\scripts\_machine\context-access.log",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\context-heatmap.html",

    [Parameter(Mandatory=$false)]
    [int]$DaysToAnalyze = 30
)

$ErrorActionPreference = "Stop"

Write-Host "Context Heat Map Generator - Round 10 Implementation" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Create or read access log
function Get-ContextAccessData {
    param([string]$LogPath, [int]$Days)

    # If log doesn't exist, create sample data from git history
    if (-not (Test-Path $LogPath)) {
        Write-Host "Access log not found. Generating from git history..." -ForegroundColor Yellow

        Push-Location "C:\scripts"

        try {
            $cutoffDate = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-dd")
            $gitLog = git log --since="$cutoffDate" --name-only --pretty=format:"%H|%ad" --date=iso -- _machine/ 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Host "Warning: Could not read git history" -ForegroundColor Yellow
                return @()
            }

            $accessData = @()
            $currentCommit = $null

            foreach ($line in $gitLog) {
                if ($line -match '^([0-9a-f]{40})\|(.+)$') {
                    $currentCommit = @{
                        hash = $matches[1]
                        date = [datetime]::Parse($matches[2])
                    }
                }
                elseif ($line -match '\.md$|\.yaml$|\.yml$' -and $currentCommit) {
                    $accessData += @{
                        file = $line.Trim()
                        timestamp = $currentCommit.date
                        type = "modify"
                    }
                }
            }

            return $accessData
        }
        finally {
            Pop-Location
        }
    }
    else {
        # Read existing log
        $logLines = Get-Content $LogPath

        $accessData = @()

        foreach ($line in $logLines) {
            if ($line -match '^(.+?)\|(.+?)\|(.+)$') {
                $accessData += @{
                    timestamp = [datetime]::Parse($matches[1])
                    file = $matches[2]
                    type = $matches[3]
                }
            }
        }

        return $accessData
    }
}

# Log access (for future use)
function Log-ContextAccess {
    param([string]$LogPath, [string]$File, [string]$Type)

    $timestamp = (Get-Date).ToString("o")
    $entry = "$timestamp|$File|$Type"

    Add-Content -Path $LogPath -Value $entry
}

# Analyze access patterns
function Analyze-AccessPatterns {
    param([array]$AccessData)

    Write-Host "Analyzing access patterns..." -ForegroundColor Yellow

    # Group by file
    $byFile = $AccessData | Group-Object -Property file

    $stats = @()

    foreach ($group in $byFile) {
        $fileName = $group.Name
        $accessCount = $group.Count

        # Calculate recency score (recent accesses weighted higher)
        $recencyScore = 0
        $now = Get-Date

        foreach ($access in $group.Group) {
            $daysDiff = ($now - $access.timestamp).Days
            $weight = [math]::Max(0, 30 - $daysDiff) / 30.0
            $recencyScore += $weight
        }

        # Calculate frequency score
        $firstAccess = ($group.Group | Measure-Object -Property timestamp -Minimum).Minimum
        $lastAccess = ($group.Group | Measure-Object -Property timestamp -Maximum).Maximum
        $daySpan = ($lastAccess - $firstAccess).Days + 1
        $frequencyScore = $accessCount / $daySpan

        # Calculate heat score (combination of frequency and recency)
        $heatScore = ($recencyScore * 0.6) + ($accessCount * 0.4)

        $stats += @{
            file = $fileName
            accessCount = $accessCount
            recencyScore = [math]::Round($recencyScore, 2)
            frequencyScore = [math]::Round($frequencyScore, 3)
            heatScore = [math]::Round($heatScore, 2)
            firstAccess = $firstAccess
            lastAccess = $lastAccess
        }
    }

    return $stats | Sort-Object -Property heatScore -Descending
}

# Generate HTML heat map
function Generate-HeatMapHTML {
    param([array]$Stats, [int]$Days)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Calculate color based on heat score
    function Get-HeatColor {
        param([double]$Score, [double]$Max)

        $intensity = [math]::Min(1.0, $Score / $Max)

        # Color gradient: cool (blue) -> warm (red)
        $r = [int]($intensity * 255)
        $g = [int]((1 - $intensity) * 200)
        $b = [int]((1 - $intensity) * 255)

        return "rgb($r,$g,$b)"
    }

    $maxHeat = ($Stats | Measure-Object -Property heatScore -Maximum).Maximum

    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Context Access Heat Map</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
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
        .heatmap {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 10px;
            margin-bottom: 30px;
        }
        .heatmap-item {
            padding: 15px;
            border-radius: 6px;
            text-align: center;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .heatmap-item:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        .heatmap-item-name {
            font-size: 12px;
            font-weight: bold;
            color: white;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
            margin-bottom: 5px;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .heatmap-item-score {
            font-size: 18px;
            font-weight: bold;
            color: white;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
        }
        .stats-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 30px;
        }
        .stats-table th,
        .stats-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        .stats-table th {
            background: #ecf0f1;
            font-weight: bold;
            color: #2c3e50;
        }
        .stats-table tr:hover {
            background: #f8f9fa;
        }
        .chart-container {
            margin-top: 30px;
            height: 400px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Context Access Heat Map</h1>
        <div class="meta">
            <strong>Generated:</strong> $timestamp<br>
            <strong>Analysis Period:</strong> Last $Days days<br>
            <strong>Files Tracked:</strong> $($Stats.Count)
        </div>

        <h2>Heat Map</h2>
        <div class="heatmap">
"@

    # Generate heat map tiles
    foreach ($stat in ($Stats | Select-Object -First 50)) {
        $color = Get-HeatColor -Score $stat.heatScore -Max $maxHeat
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($stat.file)

        $html += @"
            <div class="heatmap-item" style="background-color: $color;" title="$($stat.file) - Heat: $($stat.heatScore)">
                <div class="heatmap-item-name">$fileName</div>
                <div class="heatmap-item-score">$($stat.heatScore)</div>
            </div>
"@
    }

    $html += @"
        </div>

        <h2>Access Frequency Over Time</h2>
        <div class="chart-container">
            <canvas id="frequencyChart"></canvas>
        </div>

        <h2>Detailed Statistics</h2>
        <table class="stats-table">
            <thead>
                <tr>
                    <th>Rank</th>
                    <th>File</th>
                    <th>Heat Score</th>
                    <th>Access Count</th>
                    <th>Recency</th>
                    <th>Last Access</th>
                </tr>
            </thead>
            <tbody>
"@

    # Generate table rows
    $rank = 1
    foreach ($stat in ($Stats | Select-Object -First 20)) {
        $html += @"
                <tr>
                    <td>$rank</td>
                    <td>$($stat.file)</td>
                    <td>$($stat.heatScore)</td>
                    <td>$($stat.accessCount)</td>
                    <td>$($stat.recencyScore)</td>
                    <td>$($stat.lastAccess.ToString("yyyy-MM-dd HH:mm"))</td>
                </tr>
"@
        $rank++
    }

    # Generate chart data
    $chartLabels = ($Stats | Select-Object -First 15 | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.file) }) -join '","'
    $chartData = ($Stats | Select-Object -First 15 | ForEach-Object { $_.heatScore }) -join ','

    $html += @"
            </tbody>
        </table>
    </div>

    <script>
        const ctx = document.getElementById('frequencyChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["$chartLabels"],
                datasets: [{
                    label: 'Heat Score',
                    data: [$chartData],
                    backgroundColor: 'rgba(231, 76, 60, 0.6)',
                    borderColor: 'rgba(231, 76, 60, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Heat Score'
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>
"@

    return $html
}

# Main execution
Write-Host "Loading access data..." -ForegroundColor Yellow
$accessData = Get-ContextAccessData -LogPath $AccessLogPath -Days $DaysToAnalyze

if ($accessData.Count -eq 0) {
    Write-Host "No access data found." -ForegroundColor Yellow
    return @{ Success = $false; Message = "No data" }
}

Write-Host "  Loaded $($accessData.Count) access records" -ForegroundColor Green
Write-Host ""

$stats = Analyze-AccessPatterns -AccessData $accessData

Write-Host ""
Write-Host "Generating heat map visualization..." -ForegroundColor Yellow

$html = Generate-HeatMapHTML -Stats $stats -Days $DaysToAnalyze
$html | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host ""
Write-Host "Heat map generated successfully!" -ForegroundColor Green
Write-Host "  Files analyzed: $($stats.Count)" -ForegroundColor Green
Write-Host "  Output: $OutputPath" -ForegroundColor Cyan
Write-Host "  Open in browser to view" -ForegroundColor Gray
Write-Host ""

# Show top 5
Write-Host "Top 5 Most Accessed Files:" -ForegroundColor Yellow
foreach ($stat in ($stats | Select-Object -First 5)) {
    Write-Host "  $($stat.file) (Heat: $($stat.heatScore))" -ForegroundColor Cyan
}
Write-Host ""

return @{
    Success = $true
    OutputPath = $OutputPath
    FilesAnalyzed = $stats.Count
    TopFiles = $stats | Select-Object -First 10
}
