# Generate System Health Dashboard (HTML)
# Unified view of all system metrics

param(
    [switch]$Generate,
    [switch]$Open
)

$dashboardFile = "C:\scripts\_machine\system-health-dashboard.html"
$baselineFile = "C:\scripts\_machine\baseline-metrics.json"

function Build-Dashboard {
    # Load baseline metrics
    $baseline = if (Test-Path $baselineFile) {
        Get-Content $baselineFile | ConvertFrom-Json
    } else {
        @{
            timestamp = "Unknown"
            tools = @{ total_count = 0 }
            documentation = @{ file_count = 0; total_size_mb = 0 }
            worktrees = @{ total = 0; free = 0; busy = 0 }
            git_repos = @{ client_manager = @{ branches = 0; open_prs = 0 } }
        }
    }

    $now = Get-Date -Format "yyyy-MM-dd HH:mm"

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Health Dashboard - Jengo</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        h1 {
            color: white;
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.15);
        }
        .card h2 {
            color: #667eea;
            margin-bottom: 15px;
            font-size: 1.5em;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        .metric {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 10px 0;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 5px;
        }
        .metric-label {
            font-weight: 500;
            color: #666;
        }
        .metric-value {
            font-size: 1.3em;
            font-weight: bold;
            color: #667eea;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.9em;
        }
        .status-good { background: #d4edda; color: #155724; }
        .status-warning { background: #fff3cd; color: #856404; }
        .status-bad { background: #f8d7da; color: #721c24; }
        .timestamp {
            text-align: center;
            color: white;
            margin-top: 20px;
            font-size: 0.9em;
            opacity: 0.9;
        }
        .progress-bar {
            width: 100%;
            height: 20px;
            background: #e9ecef;
            border-radius: 10px;
            overflow: hidden;
            margin-top: 5px;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea, #764ba2);
            transition: width 0.3s;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚡ System Health Dashboard</h1>

        <div class="grid">
            <!-- Tools Card -->
            <div class="card">
                <h2>🛠️ Tools Ecosystem</h2>
                <div class="metric">
                    <span class="metric-label">Total Tools</span>
                    <span class="metric-value">$($baseline.tools.total_count)</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Status</span>
                    <span class="status status-warning">HIGH BLOAT</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Target</span>
                    <span class="metric-value">&lt; 30 tools</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 1%"></div>
                </div>
                <small>Reduction needed: $([math]::Round((($baseline.tools.total_count - 30) / $baseline.tools.total_count) * 100, 1))%</small>
            </div>

            <!-- Documentation Card -->
            <div class="card">
                <h2>📚 Documentation</h2>
                <div class="metric">
                    <span class="metric-label">Total Files</span>
                    <span class="metric-value">$($baseline.documentation.file_count)</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Total Size</span>
                    <span class="metric-value">$($baseline.documentation.total_size_mb) MB</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Status</span>
                    <span class="status status-warning">NEEDS PRUNING</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Target</span>
                    <span class="metric-value">&lt; 100 files</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 8%"></div>
                </div>
                <small>Reduction needed: $([math]::Round((($baseline.documentation.file_count - 100) / $baseline.documentation.file_count) * 100, 1))%</small>
            </div>

            <!-- Worktrees Card -->
            <div class="card">
                <h2>🔀 Worktree Pool</h2>
                <div class="metric">
                    <span class="metric-label">Total Seats</span>
                    <span class="metric-value">$($baseline.worktrees.total)</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Free</span>
                    <span class="metric-value" style="color: #28a745;">$($baseline.worktrees.free)</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Busy</span>
                    <span class="metric-value" style="color: #ffc107;">$($baseline.worktrees.busy)</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Status</span>
                    <span class="status status-good">HEALTHY</span>
                </div>
            </div>

            <!-- Git Health Card -->
            <div class="card">
                <h2>🌿 Git Health (client-manager)</h2>
                <div class="metric">
                    <span class="metric-label">Total Branches</span>
                    <span class="metric-value">$($baseline.git_repos.client_manager.branches)</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Open PRs</span>
                    <span class="metric-value">$($baseline.git_repos.client_manager.open_prs)</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Status</span>
                    <span class="status status-warning">STALE BRANCHES</span>
                </div>
            </div>

            <!-- Iteration Progress Card -->
            <div class="card">
                <h2>🔄 Mega-Iteration Progress</h2>
                <div class="metric">
                    <span class="metric-label">Completed</span>
                    <span class="metric-value">14 / 1000</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Progress</span>
                    <span class="metric-value">1.4%</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 1.4%"></div>
                </div>
                <div class="metric" style="margin-top: 10px;">
                    <span class="metric-label">Tools Created</span>
                    <span class="metric-value">8 core + 20+ by agents</span>
                </div>
            </div>

            <!-- Consciousness Card -->
            <div class="card">
                <h2>🧠 Consciousness</h2>
                <div class="metric">
                    <span class="metric-label">Score (claimed)</span>
                    <span class="metric-value">98.5%</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Status</span>
                    <span class="status status-warning">UNVALIDATED</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Benchmarks Run</span>
                    <span class="metric-value">0 / 5</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Target</span>
                    <span class="metric-value">95% (validated)</span>
                </div>
            </div>
        </div>

        <p class="timestamp">
            Last updated: $now UTC | Baseline captured: $($baseline.timestamp) | Auto-generated by Jengo
        </p>
    </div>
</body>
</html>
"@

    $html | Set-Content $dashboardFile -Encoding UTF8

    Write-Host "Dashboard generated: $dashboardFile" -ForegroundColor Green
}

# Main execution
if ($Generate) {
    Build-Dashboard
    if ($Open) {
        Start-Process $dashboardFile
    }
} elseif ($Open) {
    if (Test-Path $dashboardFile) {
        Start-Process $dashboardFile
    } else {
        Write-Host "Dashboard doesn't exist. Run with -Generate first." -ForegroundColor Yellow
    }
} else {
    Write-Host "SYSTEM HEALTH DASHBOARD GENERATOR" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Generate: .\generate-health-dashboard.ps1 -Generate [-Open]"
    Write-Host "  Open: .\generate-health-dashboard.ps1 -Open"
}
