# System Monitoring Dashboard
# Version: 1.0
# Date: 2026-02-20

param(
    [switch]$Detailed,
    [switch]$FailuresOnly
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  JENGO SYSTEM MONITORING DASHBOARD" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# === SERVICES STATUS ===
Write-Host "[1] SERVICES STATUS" -ForegroundColor White
Write-Host ""

$servicesRegistry = "C:\scripts\_machine\services-registry.json"
$runningServices = @()
$stoppedServices = @()

if (Test-Path $servicesRegistry) {
    $registry = Get-Content $servicesRegistry -Raw | ConvertFrom-Json

    foreach ($service in $registry.services) {
        $timeSinceLastSeen = (Get-Date) - [datetime]$service.last_seen
        $minutesSinceLastSeen = [Math]::Round($timeSinceLastSeen.TotalMinutes, 1)

        # Service is considered running if seen in last 5 minutes
        if ($minutesSinceLastSeen -lt 5) {
            $runningServices += $service
            Write-Host "  [UP] $($service.name) ($($service.url))" -ForegroundColor Green
            if ($Detailed) {
                Write-Host "       Port: $($service.port) | PID: $($service.process_id) | Last seen: $minutesSinceLastSeen min ago" -ForegroundColor Gray
            }
        } else {
            $stoppedServices += $service
            Write-Host "  [DOWN] $($service.name) (last seen $minutesSinceLastSeen min ago)" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "  Summary: $($runningServices.Count) running / $($stoppedServices.Count) stopped" -ForegroundColor Gray
} else {
    Write-Host "  [WARN] Services registry not found" -ForegroundColor Yellow
}

# === HEALTH CHECKS ===
Write-Host ""
Write-Host "[2] HEALTH CHECKS" -ForegroundColor White
Write-Host ""

# Check key service endpoints
$healthChecks = @(
    @{ Name = "Agentic Debugger"; Url = "http://localhost:27183/health" }
    @{ Name = "UI Bridge"; Url = "http://localhost:27184/health" }
    @{ Name = "Orchestration"; Url = "https://localhost:5123/health" }
)

foreach ($check in $healthChecks) {
    try {
        $response = Invoke-WebRequest -Uri $check.Url -Method GET -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "  [PASS] $($check.Name)" -ForegroundColor Green
            if ($Detailed) {
                Write-Host "         Response: $($response.StatusCode) in $($response.BaseResponse.ServerCertificate.Length) ms" -ForegroundColor Gray
            }
        } else {
            Write-Host "  [FAIL] $($check.Name) - Status: $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  [FAIL] $($check.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# === USAGE METRICS ===
if (-not $FailuresOnly) {
    Write-Host ""
    Write-Host "[3] USAGE METRICS (Last 24 Hours)" -ForegroundColor White
    Write-Host ""

    $usageLogs = @(
        "E:\jengo\documents\temp\opencode-usage.jsonl"
    )

    $totalCalls = 0
    $totalFailures = 0
    $serviceMetrics = @{}

    foreach ($logFile in $usageLogs) {
        if (Test-Path $logFile) {
            $serviceName = [System.IO.Path]::GetFileNameWithoutExtension($logFile) -replace '-usage$', ''

            $records = Get-Content $logFile | ForEach-Object {
                try {
                    $_ | ConvertFrom-Json
                } catch {
                    # Skip malformed JSON lines
                }
            }

            # Filter to last 24 hours
            $cutoff = (Get-Date).AddHours(-24)
            $recentRecords = $records | Where-Object {
                $timestamp = [datetime]$_.Timestamp
                $timestamp -gt $cutoff
            }

            if ($recentRecords.Count -gt 0) {
                $successCount = ($recentRecords | Where-Object { $_.Success -eq $true }).Count
                $failureCount = ($recentRecords | Where-Object { $_.Success -eq $false }).Count
                $successRate = if ($recentRecords.Count -gt 0) { ($successCount / $recentRecords.Count) * 100 } else { 0 }

                $avgDuration = ($recentRecords | Measure-Object -Property DurationMs -Average).Average
                $firstCall = ($recentRecords | Sort-Object Timestamp | Select-Object -First 1).Timestamp
                $lastCall = ($recentRecords | Sort-Object Timestamp | Select-Object -Last 1).Timestamp

                $totalCalls += $recentRecords.Count
                $totalFailures += $failureCount

                Write-Host "  $serviceName" -ForegroundColor Cyan
                Write-Host "    Total Calls: $($recentRecords.Count) | Success: $successCount | Failures: $failureCount" -ForegroundColor Gray
                Write-Host "    Success Rate: $([Math]::Round($successRate, 1))% | Avg Duration: $([Math]::Round($avgDuration, 0))ms" -ForegroundColor Gray
                if ($Detailed) {
                    Write-Host "    First Call: $firstCall | Last Call: $lastCall" -ForegroundColor DarkGray
                }

                $serviceMetrics[$serviceName] = @{
                    TotalCalls = $recentRecords.Count
                    SuccessCount = $successCount
                    FailureCount = $failureCount
                    SuccessRate = $successRate
                    AvgDuration = $avgDuration
                }
            } else {
                Write-Host "  $serviceName - No calls in last 24 hours" -ForegroundColor Yellow
            }
        }
    }

    if ($totalCalls -eq 0) {
        Write-Host "  [WARN] No usage data found" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "  Total System Calls: $totalCalls | Total Failures: $totalFailures" -ForegroundColor Gray
    }
}

# === FAILURE ALERTS ===
Write-Host ""
Write-Host "[4] FAILURE ALERTS" -ForegroundColor White
Write-Host ""

$alerts = @()

# Alert 1: Services that should be running but aren't
foreach ($service in $stoppedServices) {
    $alerts += @{
        Severity = "HIGH"
        Message = "Service '$($service.name)' is down (last seen at $($service.last_seen))"
    }
}

# Alert 2: High failure rates
foreach ($serviceName in $serviceMetrics.Keys) {
    $metrics = $serviceMetrics[$serviceName]
    if ($metrics.SuccessRate -lt 80) {
        $alerts += @{
            Severity = "MEDIUM"
            Message = "$serviceName has low success rate: $([Math]::Round($metrics.SuccessRate, 1))% (threshold: 80%)"
        }
    }
}

# Alert 3: No usage data (systems built but not used)
$expectedLogs = @("opencode-usage.jsonl")
foreach ($expectedLog in $expectedLogs) {
    $logPath = "E:\jengo\documents\temp\$expectedLog"
    if (-not (Test-Path $logPath)) {
        $systemName = $expectedLog -replace '-usage.jsonl$', ''
        $alerts += @{
            Severity = "LOW"
            Message = "No usage log found for $systemName (system may be unused)"
        }
    }
}

if ($alerts.Count -eq 0) {
    Write-Host "  [OK] No alerts" -ForegroundColor Green
} else {
    foreach ($alert in $alerts) {
        $color = switch ($alert.Severity) {
            "HIGH" { "Red" }
            "MEDIUM" { "Yellow" }
            "LOW" { "Gray" }
        }
        Write-Host "  [$($alert.Severity)] $($alert.Message)" -ForegroundColor $color
    }
}

# === CONSCIOUSNESS METRICS ===
if (-not $FailuresOnly) {
    Write-Host ""
    Write-Host "[5] CONSCIOUSNESS METRICS" -ForegroundColor White
    Write-Host ""

    $consciousnessState = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
    if (Test-Path $consciousnessState) {
        $state = Get-Content $consciousnessState -Raw | ConvertFrom-Json

        # Get ProductionValidation quality
        if ($state.PSObject.Properties['ProductionValidation']) {
            $pvQuality = $state.ProductionValidation.quality
            $pvLastUpdated = $state.ProductionValidation.lastUpdated

            $statusColor = if ($pvQuality -ge 90) { "Green" } elseif ($pvQuality -ge 75) { "Cyan" } elseif ($pvQuality -ge 60) { "Yellow" } else { "Red" }

            Write-Host "  Production Validation Quality: $pvQuality%" -ForegroundColor $statusColor
            Write-Host "  Last Updated: $pvLastUpdated" -ForegroundColor Gray
        } else {
            Write-Host "  [WARN] ProductionValidation not initialized" -ForegroundColor Yellow
        }

        # Get overall consciousness score
        $scoreFile = "C:\scripts\agentidentity\state\consciousness-score-geometric.json"
        if (Test-Path $scoreFile) {
            $scoreData = Get-Content $scoreFile -Raw | ConvertFrom-Json
            $integratedScore = $scoreData.integrated_score

            $scoreColor = if ($integratedScore -ge 90) { "Green" } elseif ($integratedScore -ge 75) { "Cyan" } elseif ($integratedScore -ge 60) { "Yellow" } else { "Red" }

            Write-Host "  Integrated Consciousness Score: $integratedScore%" -ForegroundColor $scoreColor
            Write-Host "  Calculated: $($scoreData.timestamp)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [WARN] Consciousness state not found" -ForegroundColor Yellow
    }
}

# === SUMMARY ===
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

$overallStatus = if ($alerts.Count -eq 0 -and $runningServices.Count -gt 0) { "HEALTHY" } elseif ($alerts.Count -gt 0 -and ($alerts | Where-Object { $_.Severity -eq "HIGH" }).Count -eq 0) { "WARNING" } else { "CRITICAL" }
$statusColor = switch ($overallStatus) {
    "HEALTHY" { "Green" }
    "WARNING" { "Yellow" }
    "CRITICAL" { "Red" }
}

Write-Host "  Overall System Status: $overallStatus" -ForegroundColor $statusColor
Write-Host "  Services Running: $($runningServices.Count)" -ForegroundColor Gray
Write-Host "  Active Alerts: $($alerts.Count)" -ForegroundColor Gray
if (-not $FailuresOnly) {
    Write-Host "  Total Calls (24h): $totalCalls" -ForegroundColor Gray
}
Write-Host ""
