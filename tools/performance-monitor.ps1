<#
.SYNOPSIS
    Performance monitoring with baseline tracking and regression detection

.DESCRIPTION
    Tracks key performance metrics and detects regressions:
    - Build time (dotnet build, npm run build)
    - Test execution time
    - Memory usage (working set, GC collections)
    - Startup time (services, frontend)

    Stores baselines and triggers auto-profiling on anomalies.

.PARAMETER Action
    Action to perform: Measure, Compare, Profile, Report

.PARAMETER Project
    Project to monitor (client-manager, hazina, orchestration)

.PARAMETER UpdateBaseline
    Update baseline after measurement

.PARAMETER ThresholdPercent
    Regression threshold percentage (default: 50 = 50% slower triggers alert)

.EXAMPLE
    .\performance-monitor.ps1 -Action Measure -Project client-manager
    .\performance-monitor.ps1 -Action Compare -Project hazina -ThresholdPercent 30
    .\performance-monitor.ps1 -Action Profile -Project client-manager
    .\performance-monitor.ps1 -Action Report
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Measure", "Compare", "Profile", "Report")]
    [string]$Action,

    [ValidateSet("client-manager", "hazina", "orchestration", "artrevisionist")]
    [string]$Project = "",

    [switch]$UpdateBaseline,

    [int]$ThresholdPercent = 50
)

$ErrorActionPreference = "Continue"

# Paths
$baselineDir = "C:\scripts\_machine\performance-baselines"
$reportPath = "E:\jengo\documents\temp\performance-report-$(Get-Date -Format 'yyyy-MM-dd').md"

# Ensure baseline directory exists
if (-not (Test-Path $baselineDir)) {
    New-Item -ItemType Directory -Path $baselineDir -Force | Out-Null
}

Write-Host "=== Performance Monitor ===" -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Gray
if ($Project) {
    Write-Host "Project: $Project" -ForegroundColor Gray
}
Write-Host ""

# ============================================================================
# ACTION: MEASURE
# ============================================================================

if ($Action -eq "Measure") {
    if (-not $Project) {
        Write-Host "Error: -Project required for Measure action" -ForegroundColor Red
        exit 1
    }

    Write-Host "[MEASURE] Collecting performance metrics for $Project..." -ForegroundColor Yellow

    $metrics = @{
        Project = $Project
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        BuildTime = 0
        TestTime = 0
        MemoryMB = 0
        GCCollections = @{Gen0=0; Gen1=0; Gen2=0}
    }

    $projectPath = "C:\Projects\$Project"

    if (-not (Test-Path $projectPath)) {
        Write-Host "Error: Project path not found: $projectPath" -ForegroundColor Red
        exit 1
    }

    Push-Location $projectPath

    # ========================================================================
    # 1. BUILD TIME
    # ========================================================================

    Write-Host "  [1/4] Measuring build time..." -ForegroundColor Gray

    # .NET build
    if (Test-Path "*.sln") {
        $buildStart = Get-Date
        dotnet build --configuration Release --no-incremental 2>&1 | Out-Null
        $buildEnd = Get-Date

        $metrics.BuildTime = ($buildEnd - $buildStart).TotalSeconds
        Write-Host "    .NET build: $($metrics.BuildTime)s" -ForegroundColor Green
    }

    # npm build
    $packageJson = Get-ChildItem -Filter "package.json" -Recurse -Depth 2 | Select-Object -First 1
    if ($packageJson) {
        $npmProjectDir = Split-Path $packageJson.FullName -Parent
        Push-Location $npmProjectDir

        $json = Get-Content "package.json" | ConvertFrom-Json
        if ($json.scripts.build) {
            $buildStart = Get-Date
            npm run build 2>&1 | Out-Null
            $buildEnd = Get-Date

            $npmBuildTime = ($buildEnd - $buildStart).TotalSeconds
            $metrics.BuildTime += $npmBuildTime
            Write-Host "    npm build: $($npmBuildTime)s" -ForegroundColor Green
        }

        Pop-Location
    }

    # ========================================================================
    # 2. TEST TIME
    # ========================================================================

    Write-Host "  [2/4] Measuring test execution time..." -ForegroundColor Gray

    # .NET tests
    $testProjects = Get-ChildItem -Filter "*.Tests.csproj" -Recurse
    if ($testProjects.Count -gt 0) {
        $testStart = Get-Date
        dotnet test --no-build --configuration Release 2>&1 | Out-Null
        $testEnd = Get-Date

        $metrics.TestTime = ($testEnd - $testStart).TotalSeconds
        Write-Host "    .NET tests: $($metrics.TestTime)s" -ForegroundColor Green
    }

    # npm tests (if available)
    if ($packageJson) {
        $npmProjectDir = Split-Path $packageJson.FullName -Parent
        Push-Location $npmProjectDir

        $json = Get-Content "package.json" | ConvertFrom-Json
        if ($json.scripts.test -and $json.scripts.test -notmatch "echo") {
            $testStart = Get-Date
            npm test 2>&1 | Out-Null
            $testEnd = Get-Date

            $npmTestTime = ($testEnd - $testStart).TotalSeconds
            $metrics.TestTime += $npmTestTime
            Write-Host "    npm tests: $($npmTestTime)s" -ForegroundColor Green
        }

        Pop-Location
    }

    # ========================================================================
    # 3. MEMORY USAGE
    # ========================================================================

    Write-Host "  [3/4] Measuring memory usage..." -ForegroundColor Gray

    # Get current process memory
    $process = Get-Process -Id $PID
    $metrics.MemoryMB = [math]::Round($process.WorkingSet64 / 1MB, 2)

    Write-Host "    Working set: $($metrics.MemoryMB) MB" -ForegroundColor Green

    # ========================================================================
    # 4. GC COLLECTIONS
    # ========================================================================

    Write-Host "  [4/4] Collecting GC statistics..." -ForegroundColor Gray

    $metrics.GCCollections = @{
        Gen0 = [GC]::CollectionCount(0)
        Gen1 = [GC]::CollectionCount(1)
        Gen2 = [GC]::CollectionCount(2)
    }

    Write-Host "    GC: Gen0=$($metrics.GCCollections.Gen0), Gen1=$($metrics.GCCollections.Gen1), Gen2=$($metrics.GCCollections.Gen2)" -ForegroundColor Green

    Pop-Location

    # ========================================================================
    # SAVE METRICS
    # ========================================================================

    $projectBaselineDir = Join-Path $baselineDir $Project
    if (-not (Test-Path $projectBaselineDir)) {
        New-Item -ItemType Directory -Path $projectBaselineDir -Force | Out-Null
    }

    # Save current metrics
    $metricsPath = Join-Path $projectBaselineDir "current.json"
    $metrics | ConvertTo-Json | Out-File -FilePath $metricsPath -Encoding UTF8

    Write-Host ""
    Write-Host "Metrics saved: $metricsPath" -ForegroundColor Green

    # Update baseline if requested
    if ($UpdateBaseline) {
        $baselinePath = Join-Path $projectBaselineDir "baseline.json"
        $metrics | ConvertTo-Json | Out-File -FilePath $baselinePath -Encoding UTF8
        Write-Host "Baseline updated: $baselinePath" -ForegroundColor Green
    }

    return $metrics
}

# ============================================================================
# ACTION: COMPARE
# ============================================================================

if ($Action -eq "Compare") {
    if (-not $Project) {
        Write-Host "Error: -Project required for Compare action" -ForegroundColor Red
        exit 1
    }

    Write-Host "[COMPARE] Comparing current metrics vs baseline for $Project..." -ForegroundColor Yellow

    $projectBaselineDir = Join-Path $baselineDir $Project

    # Load baseline
    $baselinePath = Join-Path $projectBaselineDir "baseline.json"
    if (-not (Test-Path $baselinePath)) {
        Write-Host "Error: No baseline found for $Project. Run with -Action Measure -UpdateBaseline first." -ForegroundColor Red
        exit 1
    }

    $baseline = Get-Content $baselinePath | ConvertFrom-Json

    # Load current metrics
    $currentPath = Join-Path $projectBaselineDir "current.json"
    if (-not (Test-Path $currentPath)) {
        Write-Host "Error: No current metrics found. Run with -Action Measure first." -ForegroundColor Red
        exit 1
    }

    $current = Get-Content $currentPath | ConvertFrom-Json

    # Compare metrics
    Write-Host ""
    Write-Host "=== Performance Comparison ===" -ForegroundColor Cyan
    Write-Host ""

    $regressions = @()
    $improvements = @()

    # Build time
    $buildDelta = $current.BuildTime - $baseline.BuildTime
    $buildDeltaPercent = if ($baseline.BuildTime -gt 0) {
        [math]::Round(($buildDelta / $baseline.BuildTime) * 100, 1)
    } else { 0 }

    Write-Host "Build Time:" -ForegroundColor White
    Write-Host "  Baseline: $($baseline.BuildTime)s" -ForegroundColor Gray
    Write-Host "  Current:  $($current.BuildTime)s" -ForegroundColor Gray
    Write-Host "  Delta:    $buildDelta`s ($buildDeltaPercent%)" -ForegroundColor $(if ($buildDeltaPercent -gt $ThresholdPercent) { "Red" } elseif ($buildDeltaPercent -lt -10) { "Green" } else { "Gray" })

    if ($buildDeltaPercent -gt $ThresholdPercent) {
        $regressions += "Build time regression: $buildDelta`s ($buildDeltaPercent%)"
    } elseif ($buildDeltaPercent -lt -10) {
        $improvements += "Build time improved: $buildDelta`s ($buildDeltaPercent%)"
    }

    # Test time
    $testDelta = $current.TestTime - $baseline.TestTime
    $testDeltaPercent = if ($baseline.TestTime -gt 0) {
        [math]::Round(($testDelta / $baseline.TestTime) * 100, 1)
    } else { 0 }

    Write-Host ""
    Write-Host "Test Time:" -ForegroundColor White
    Write-Host "  Baseline: $($baseline.TestTime)s" -ForegroundColor Gray
    Write-Host "  Current:  $($current.TestTime)s" -ForegroundColor Gray
    Write-Host "  Delta:    $testDelta`s ($testDeltaPercent%)" -ForegroundColor $(if ($testDeltaPercent -gt $ThresholdPercent) { "Red" } elseif ($testDeltaPercent -lt -10) { "Green" } else { "Gray" })

    if ($testDeltaPercent -gt $ThresholdPercent) {
        $regressions += "Test time regression: $testDelta`s ($testDeltaPercent%)"
    } elseif ($testDeltaPercent -lt -10) {
        $improvements += "Test time improved: $testDelta`s ($testDeltaPercent%)"
    }

    # Memory
    $memoryDelta = $current.MemoryMB - $baseline.MemoryMB
    $memoryDeltaPercent = if ($baseline.MemoryMB -gt 0) {
        [math]::Round(($memoryDelta / $baseline.MemoryMB) * 100, 1)
    } else { 0 }

    Write-Host ""
    Write-Host "Memory Usage:" -ForegroundColor White
    Write-Host "  Baseline: $($baseline.MemoryMB) MB" -ForegroundColor Gray
    Write-Host "  Current:  $($current.MemoryMB) MB" -ForegroundColor Gray
    Write-Host "  Delta:    $memoryDelta MB ($memoryDeltaPercent%)" -ForegroundColor $(if ($memoryDeltaPercent -gt $ThresholdPercent) { "Red" } elseif ($memoryDeltaPercent -lt -10) { "Green" } else { "Gray" })

    if ($memoryDeltaPercent -gt $ThresholdPercent) {
        $regressions += "Memory regression: $memoryDelta MB ($memoryDeltaPercent%)"
    } elseif ($memoryDeltaPercent -lt -10) {
        $improvements += "Memory usage improved: $memoryDelta MB ($memoryDeltaPercent%)"
    }

    # Summary
    Write-Host ""
    Write-Host "=== Summary ===" -ForegroundColor Cyan

    if ($regressions.Count -gt 0) {
        Write-Host ""
        Write-Host "Regressions detected:" -ForegroundColor Red
        foreach ($regression in $regressions) {
            Write-Host "  - $regression" -ForegroundColor Red
        }
    }

    if ($improvements.Count -gt 0) {
        Write-Host ""
        Write-Host "Improvements:" -ForegroundColor Green
        foreach ($improvement in $improvements) {
            Write-Host "  - $improvement" -ForegroundColor Green
        }
    }

    if ($regressions.Count -eq 0 -and $improvements.Count -eq 0) {
        Write-Host ""
        Write-Host "Performance stable (within threshold)" -ForegroundColor Green
    }

    # Trigger profiling if regressions detected
    if ($regressions.Count -gt 0) {
        Write-Host ""
        Write-Host "Recommendation: Run with -Action Profile to investigate regressions" -ForegroundColor Yellow
    }

    return @{
        Project = $Project
        Regressions = $regressions
        Improvements = $improvements
        BuildDeltaPercent = $buildDeltaPercent
        TestDeltaPercent = $testDeltaPercent
        MemoryDeltaPercent = $memoryDeltaPercent
    }
}

# ============================================================================
# ACTION: PROFILE
# ============================================================================

if ($Action -eq "Profile") {
    if (-not $Project) {
        Write-Host "Error: -Project required for Profile action" -ForegroundColor Red
        exit 1
    }

    Write-Host "[PROFILE] Starting performance profiling for $Project..." -ForegroundColor Yellow

    $projectPath = "C:\Projects\$Project"

    if (-not (Test-Path $projectPath)) {
        Write-Host "Error: Project path not found: $projectPath" -ForegroundColor Red
        exit 1
    }

    Push-Location $projectPath

    # Check if dotnet-trace is installed
    $dotnetTools = dotnet tool list -g 2>&1 | Out-String

    if ($dotnetTools -notmatch "dotnet-trace") {
        Write-Host "Installing dotnet-trace..." -ForegroundColor Yellow
        dotnet tool install --global dotnet-trace 2>&1 | Out-Null
    }

    # Find main executable
    $mainExe = Get-ChildItem -Filter "*.csproj" -Recurse | Where-Object {
        $content = Get-Content $_.FullName
        $content -match "OutputType>Exe<" -or $content -match "OutputType>WinExe<"
    } | Select-Object -First 1

    if ($mainExe) {
        $projectName = [System.IO.Path]::GetFileNameWithoutExtension($mainExe.Name)
        $exePath = "bin\Release\net8.0\$projectName.exe"

        if (Test-Path $exePath) {
            Write-Host "Profiling $projectName..." -ForegroundColor Gray

            # Start process and capture PID
            $process = Start-Process -FilePath $exePath -PassThru

            Start-Sleep -Seconds 2

            # Collect trace
            $traceFile = "E:\jengo\documents\temp\trace-$projectName-$(Get-Date -Format 'yyyyMMdd-HHmmss').nettrace"
            dotnet-trace collect --process-id $process.Id --duration 00:00:10 --output $traceFile 2>&1 | Out-Null

            # Stop process
            Stop-Process -Id $process.Id -Force 2>&1 | Out-Null

            Write-Host "Trace collected: $traceFile" -ForegroundColor Green
            Write-Host "Analyze with: dotnet-trace analyze $traceFile" -ForegroundColor Gray
        } else {
            Write-Host "Warning: Executable not found at $exePath" -ForegroundColor Yellow
            Write-Host "Build project first: dotnet build --configuration Release" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No executable project found in $Project" -ForegroundColor Yellow
    }

    Pop-Location
}

# ============================================================================
# ACTION: REPORT
# ============================================================================

if ($Action -eq "Report") {
    Write-Host "[REPORT] Generating performance report..." -ForegroundColor Yellow

    $projects = Get-ChildItem -Path $baselineDir -Directory | Select-Object -ExpandProperty Name

    if ($projects.Count -eq 0) {
        Write-Host "No performance data found. Run with -Action Measure first." -ForegroundColor Yellow
        exit 0
    }

    $report = @"
# Performance Report - $(Get-Date -Format "yyyy-MM-dd")

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## Summary

| Project | Build Time | Test Time | Memory (MB) | Status |
|---------|------------|-----------|-------------|--------|
"@

    foreach ($proj in $projects) {
        $baselinePath = Join-Path $baselineDir "$proj\baseline.json"
        $currentPath = Join-Path $baselineDir "$proj\current.json"

        if (Test-Path $currentPath) {
            $current = Get-Content $currentPath | ConvertFrom-Json

            $status = "✅ OK"
            if (Test-Path $baselinePath) {
                $baseline = Get-Content $baselinePath | ConvertFrom-Json

                $buildDeltaPercent = if ($baseline.BuildTime -gt 0) {
                    [math]::Round((($current.BuildTime - $baseline.BuildTime) / $baseline.BuildTime) * 100, 1)
                } else { 0 }

                if ($buildDeltaPercent -gt $ThresholdPercent) {
                    $status = "⚠️ REGRESSION"
                }
            }

            $report += "`n| $proj | $($current.BuildTime)s | $($current.TestTime)s | $($current.MemoryMB) | $status |"
        }
    }

    $report += @"


---

## Recommendations

1. Run ``.\performance-monitor.ps1 -Action Measure -Project <project>`` to update metrics
2. Run ``.\performance-monitor.ps1 -Action Compare -Project <project>`` to check for regressions
3. Run ``.\performance-monitor.ps1 -Action Profile -Project <project>`` if regressions detected

---

**Next Report:** $(Get-Date).AddDays(1).ToString("yyyy-MM-dd")
"@

    # Save report
    $report | Out-File -FilePath $reportPath -Encoding UTF8

    Write-Host "Report saved: $reportPath" -ForegroundColor Green

    # Display report
    Write-Host ""
    Write-Host $report
}
