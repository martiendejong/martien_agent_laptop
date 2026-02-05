# health-dashboard.ps1
# Real-time system health monitoring dashboard
# Shows agent status, worktree pool, recent errors, system metrics

param(
    [switch]$Generate,   # Generate HTML dashboard
    [switch]$Open,       # Generate and open in browser
    [switch]$Watch,      # Auto-refresh every 30s
    [int]$RefreshSeconds = 30
)

$script:DashboardPath = "C:\scripts\_machine\health-dashboard.html"
$script:PoolFile = "C:\scripts\_machine\worktrees.pool.md"
$script:ReflectionFile = "C:\scripts\_machine\reflection.log.md"
$script:LockDir = "C:\scripts\_machine\locks"

function Get-AgentStatus {
    $agents = @()

    # Parse worktree pool
    if (Test-Path $script:PoolFile) {
        $content = Get-Content $script:PoolFile -Raw
        $lines = $content -split "`n" | Where-Object { $_ -match "^\| agent-\d+" }

        foreach ($line in $lines) {
            $cols = $line -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

            if ($cols.Count -ge 8) {
                $seat = $cols[0]
                $status = $cols[4]
                $repo = $cols[5]
                $branch = $cols[6]
                $lastActivity = $cols[7]

                # Check for lock file
                $lockFile = Join-Path $script:LockDir "$seat.lock"
                $lockStatus = "None"
                $lockAge = 0

                if (Test-Path $lockFile) {
                    $lockData = Get-Content $lockFile -Raw | ConvertFrom-Json
                    $lockAge = ((Get-Date) - [datetime]$lockData.LastHeartbeat).TotalSeconds
                    $lockStatus = if ($lockAge -gt 120) { "Stale" } else { "Active" }
                }

                $agents += @{
                    Seat = $seat
                    Status = $status
                    Repo = $repo
                    Branch = $branch
                    LastActivity = $lastActivity
                    LockStatus = $lockStatus
                    LockAge = $lockAge
                }
            }
        }
    }

    return $agents
}

function Get-SystemMetrics {
    $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue
    $memUsage = (Get-Counter '\Memory\% Committed Bytes In Use' -ErrorAction SilentlyContinue).CounterSamples.CookedValue

    return @{
        CPU = [math]::Round($cpuUsage, 1)
        Memory = [math]::Round($memUsage, 1)
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

function Get-RecentErrors {
    $errors = @()

    if (Test-Path $script:ReflectionFile) {
        $content = Get-Content $script:ReflectionFile -Raw
        $errorMatches = [regex]::Matches($content, "## \d{4}-\d{2}-\d{2}.*?(?:ERROR|CRITICAL|FAILURE|BUG|VIOLATION).*?`n`n(.*?)`n`n", [System.Text.RegularExpressions.RegexOptions]::Singleline)

        foreach ($match in $errorMatches | Select-Object -First 10) {
            $errors += @{
                Timestamp = $match.Groups[0].Value -replace "##\s*(\d{4}-\d{2}-\d{2}).*", '$1'
                Description = $match.Groups[1].Value.Substring(0, [Math]::Min(200, $match.Groups[1].Value.Length))
            }
        }
    }

    return $errors
}

function Generate-HTMLDashboard {
    $agents = Get-AgentStatus
    $metrics = Get-SystemMetrics
    $errors = Get-RecentErrors

    $freeCount = ($agents | Where-Object { $_.Status -eq "FREE" }).Count
    $busyCount = ($agents | Where-Object { $_.Status -eq "BUSY" }).Count
    $staleCount = ($agents | Where-Object { $_.LockStatus -eq "Stale" }).Count

    # Generate agent rows
    $agentRows = ""
    foreach ($agent in $agents) {
        $statusColor = switch ($agent.Status) {
            "FREE" { "success" }
            "BUSY" { "warning" }
            "STALE" { "danger" }
            "BROKEN" { "danger" }
            default { "secondary" }
        }

        $lockBadge = switch ($agent.LockStatus) {
            "Active" { "<span class='badge bg-info'>Lock Active</span>" }
            "Stale" { "<span class='badge bg-danger'>Lock Stale ($([math]::Round($agent.LockAge, 0))s)</span>" }
            default { "<span class='badge bg-secondary'>No Lock</span>" }
        }

        $agentRows += @"
        <tr>
            <td><code>$($agent.Seat)</code></td>
            <td><span class="badge bg-$statusColor">$($agent.Status)</span></td>
            <td><code>$($agent.Repo)</code></td>
            <td><code>$($agent.Branch)</code></td>
            <td>$lockBadge</td>
            <td><small class="text-muted">$($agent.LastActivity)</small></td>
        </tr>
"@
    }

    # Generate error rows
    $errorRows = ""
    if ($errors.Count -eq 0) {
        $errorRows = "<tr><td colspan='2' class='text-center text-success'>✅ No recent errors</td></tr>"
    } else {
        foreach ($error in $errors) {
            $errorRows += @"
            <tr>
                <td><small class="text-muted">$($error.Timestamp)</small></td>
                <td><small>$($error.Description)</small></td>
            </tr>
"@
        }
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jengo Health Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .dashboard-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 30px;
        }
        .metric-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .metric-value {
            font-size: 2.5rem;
            font-weight: bold;
        }
        .metric-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        code {
            background: #f8f9fa;
            padding: 2px 6px;
            border-radius: 3px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="dashboard-container">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1>🤖 Jengo Health Dashboard</h1>
                <span class="badge bg-success">ONLINE</span>
            </div>

            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="metric-card">
                        <div class="metric-value">$freeCount</div>
                        <div class="metric-label">FREE Agents</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="metric-card">
                        <div class="metric-value">$busyCount</div>
                        <div class="metric-label">BUSY Agents</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="metric-card">
                        <div class="metric-value">$($metrics.CPU)%</div>
                        <div class="metric-label">CPU Usage</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="metric-card">
                        <div class="metric-value">$($metrics.Memory)%</div>
                        <div class="metric-label">Memory Usage</div>
                    </div>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">👥 Agent Status</h5>
                </div>
                <div class="card-body p-0">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Seat</th>
                                <th>Status</th>
                                <th>Repo</th>
                                <th>Branch</th>
                                <th>Lock</th>
                                <th>Last Activity</th>
                            </tr>
                        </thead>
                        <tbody>
                            $agentRows
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card">
                <div class="card-header bg-danger text-white">
                    <h5 class="mb-0">🚨 Recent Errors</h5>
                </div>
                <div class="card-body p-0">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th width="150">Timestamp</th>
                                <th>Description</th>
                            </tr>
                        </thead>
                        <tbody>
                            $errorRows
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="mt-4 text-center text-muted">
                <small>Last updated: $($metrics.Timestamp) | Auto-refresh: ${RefreshSeconds}s</small>
            </div>
        </div>
    </div>

    <script>
        // Auto-refresh
        setTimeout(() => {
            location.reload();
        }, ${RefreshSeconds}000);
    </script>
</body>
</html>
"@

    Set-Content -Path $script:DashboardPath -Value $html -Force
    Write-Host "✅ Dashboard generated: $script:DashboardPath" -ForegroundColor Green

    return $script:DashboardPath
}

# Main logic
if ($Generate -or $Open -or $Watch) {
    $dashboardPath = Generate-HTMLDashboard

    if ($Open) {
        Write-Host "🌐 Opening dashboard in browser..." -ForegroundColor Cyan
        Start-Process $dashboardPath
    }

    if ($Watch) {
        Write-Host "👀 Watching for changes (refresh every ${RefreshSeconds}s)..." -ForegroundColor Cyan
        Write-Host "Press Ctrl+C to stop"

        if (-not $Open) {
            Start-Process $dashboardPath
        }

        while ($true) {
            Start-Sleep -Seconds $RefreshSeconds
            Generate-HTMLDashboard | Out-Null
        }
    }
} else {
    Write-Host @"
Health Dashboard Generator
==========================

Generates real-time system health monitoring dashboard.

Usage:
  health-dashboard.ps1 -Generate               # Generate HTML dashboard
  health-dashboard.ps1 -Open                   # Generate and open in browser
  health-dashboard.ps1 -Watch                  # Auto-refresh every 30s
  health-dashboard.ps1 -Watch -RefreshSeconds 10  # Custom refresh rate

Features:
  - Agent status (FREE/BUSY/STALE)
  - Worktree lock monitoring
  - System metrics (CPU/Memory)
  - Recent errors from reflection.log

Output:
  C:\scripts\_machine\health-dashboard.html

"@
}
