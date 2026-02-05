# Parallel Context Loading
# Part of Round 9 Improvements - Parallel Context Loading
# Load multiple context files concurrently for faster startup

param(
    [Parameter(Mandatory=$false)]
    [string[]]$Files = @(),

    [Parameter(Mandatory=$false)]
    [string]$ContextPath = "C:\scripts\_machine",

    [Parameter(Mandatory=$false)]
    [int]$MaxParallel = 8,

    [Parameter(Mandatory=$false)]
    [switch]$Benchmark = $false
)

$ErrorActionPreference = "Stop"

Write-Host "Parallel Context Loader - Round 9 Implementation" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Load single file function
$loadFileScript = {
    param($FilePath)

    $result = @{
        Path = $FilePath
        Success = $false
        Size = 0
        LoadTime = 0
        Error = $null
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        if (Test-Path $FilePath) {
            $content = Get-Content $FilePath -Raw
            $result.Content = $content
            $result.Size = $content.Length
            $result.Success = $true
        }
        else {
            $result.Error = "File not found"
        }
    }
    catch {
        $result.Error = $_.Exception.Message
    }
    finally {
        $sw.Stop()
        $result.LoadTime = $sw.ElapsedMilliseconds
    }

    return $result
}

# Sequential loading (baseline)
function Load-Sequential {
    param([string[]]$FilePaths)

    Write-Host "Loading files sequentially..." -ForegroundColor Yellow

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $results = @()

    foreach ($file in $FilePaths) {
        $result = & $loadFileScript -FilePath $file
        $results += $result
    }

    $sw.Stop()

    return @{
        Results = $results
        TotalTime = $sw.ElapsedMilliseconds
        Method = "Sequential"
    }
}

# Parallel loading (optimized)
function Load-Parallel {
    param([string[]]$FilePaths, [int]$MaxParallel)

    Write-Host "Loading files in parallel (max $MaxParallel threads)..." -ForegroundColor Yellow

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    # Use runspaces for true parallelism
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxParallel)
    $runspacePool.Open()

    $jobs = @()

    foreach ($file in $FilePaths) {
        $powershell = [powershell]::Create().AddScript($loadFileScript).AddArgument($file)
        $powershell.RunspacePool = $runspacePool

        $jobs += @{
            PowerShell = $powershell
            Handle = $powershell.BeginInvoke()
            File = $file
        }
    }

    # Wait for all jobs to complete
    $results = @()
    foreach ($job in $jobs) {
        $result = $job.PowerShell.EndInvoke($job.Handle)
        $job.PowerShell.Dispose()
        $results += $result
    }

    $runspacePool.Close()
    $runspacePool.Dispose()

    $sw.Stop()

    return @{
        Results = $results
        TotalTime = $sw.ElapsedMilliseconds
        Method = "Parallel"
    }
}

# Get default files to load if none specified
if ($Files.Count -eq 0) {
    Write-Host "No files specified. Loading default critical files..." -ForegroundColor Gray

    $criticalFiles = @(
        "MACHINE_CONFIG.md",
        "GENERAL_ZERO_TOLERANCE_RULES.md",
        "CLAUDE.md",
        "docs\claude-system\STARTUP_PROTOCOL.md",
        "docs\claude-system\CAPABILITIES.md",
        "worktree-workflow.md",
        "git-workflow.md",
        "_machine\worktrees.pool.md",
        "_machine\CONTEXT_KNOWLEDGE_GRAPH.yaml",
        "_machine\DEFINITION_OF_DONE.md"
    )

    $Files = $criticalFiles | ForEach-Object {
        $path = Join-Path "C:\scripts" $_
        if (Test-Path $path) { $path }
    }
}
else {
    # Convert relative paths to absolute
    $Files = $Files | ForEach-Object {
        if (-not [System.IO.Path]::IsPathRooted($_)) {
            Join-Path $ContextPath $_
        }
        else {
            $_
        }
    }
}

Write-Host "Files to load: $($Files.Count)" -ForegroundColor Cyan
Write-Host ""

# Run benchmark if requested
if ($Benchmark) {
    Write-Host "=== BENCHMARK MODE ===" -ForegroundColor Magenta
    Write-Host ""

    $seqResult = Load-Sequential -FilePaths $Files
    Write-Host "  Sequential: $($seqResult.TotalTime) ms" -ForegroundColor Yellow

    Write-Host ""

    $parResult = Load-Parallel -FilePaths $Files -MaxParallel $MaxParallel
    Write-Host "  Parallel: $($parResult.TotalTime) ms" -ForegroundColor Green

    Write-Host ""
    Write-Host "=== RESULTS ===" -ForegroundColor Magenta

    $speedup = [math]::Round($seqResult.TotalTime / $parResult.TotalTime, 2)
    $improvement = [math]::Round((($seqResult.TotalTime - $parResult.TotalTime) / $seqResult.TotalTime) * 100, 1)

    Write-Host "  Speedup: ${speedup}x" -ForegroundColor Cyan
    Write-Host "  Improvement: $improvement%" -ForegroundColor Cyan
    Write-Host "  Time saved: $($seqResult.TotalTime - $parResult.TotalTime) ms" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "=== FILE DETAILS ===" -ForegroundColor Magenta

    foreach ($result in $parResult.Results) {
        $status = if ($result.Success) { "OK" } else { "FAIL" }
        $color = if ($result.Success) { "Green" } else { "Red" }

        Write-Host "  [$status] $(Split-Path $result.Path -Leaf)" -ForegroundColor $color -NoNewline
        Write-Host " - $($result.Size) bytes in $($result.LoadTime) ms" -ForegroundColor Gray

        if (-not $result.Success) {
            Write-Host "    Error: $($result.Error)" -ForegroundColor Red
        }
    }

    return @{
        Sequential = $seqResult
        Parallel = $parResult
        Speedup = $speedup
        Improvement = $improvement
    }
}
else {
    # Production mode - just load in parallel
    $result = Load-Parallel -FilePaths $Files -MaxParallel $MaxParallel

    $successCount = ($result.Results | Where-Object { $_.Success }).Count
    $totalSize = ($result.Results | Where-Object { $_.Success } | Measure-Object -Property Size -Sum).Sum

    Write-Host ""
    Write-Host "Parallel loading complete!" -ForegroundColor Green
    Write-Host "  Files loaded: $successCount / $($Files.Count)" -ForegroundColor Green
    Write-Host "  Total size: $([math]::Round($totalSize / 1KB, 2)) KB" -ForegroundColor Green
    Write-Host "  Total time: $($result.TotalTime) ms" -ForegroundColor Green
    Write-Host "  Avg per file: $([math]::Round($result.TotalTime / $Files.Count, 1)) ms" -ForegroundColor Gray
    Write-Host ""

    return @{
        Success = $true
        FilesLoaded = $successCount
        TotalFiles = $Files.Count
        TotalTime = $result.TotalTime
        Results = $result.Results
    }
}
