# Context Preloader - R03-004
# Given predicted context files, load them into hot cache before user asks
# Expert: Alex Kim - Context-Aware Computing Specialist

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('preload', 'preload-pattern', 'preload-predictions', 'status')]
    [string]$Action = 'status',

    [Parameter(Mandatory=$false)]
    [string[]]$FilePaths,

    [Parameter(Mandatory=$false)]
    [string]$WorkflowPattern,

    [Parameter(Mandatory=$false)]
    [double]$ConfidenceThreshold = 0.5
)

$CacheScript = "C:\scripts\_machine\knowledge-system\hot-context-cache.ps1"
$PatternDetector = "C:\scripts\_machine\knowledge-system\workflow-pattern-detector.ps1"
$PreloadLog = "C:\scripts\_machine\knowledge-system\preload-activity.log"

function Preload-ContextFiles {
    param([string[]]$Files)

    if (-not $Files -or $Files.Count -eq 0) {
        Write-Host "No files to preload" -ForegroundColor Yellow
        return
    }

    Write-Host "`nPreloading $($Files.Count) context files..." -ForegroundColor Cyan

    $preloaded = 0
    $failed = 0

    foreach ($file in $Files) {
        if (Test-Path $file) {
            # Generate cache key from file path
            $key = [System.IO.Path]::GetFileNameWithoutExtension($file)

            try {
                & $CacheScript -Action set -Key $key -FilePath $file
                $preloaded++
                Write-Host "  ✓ Preloaded: $file" -ForegroundColor Green
            } catch {
                $failed++
                Write-Host "  ✗ Failed: $file - $_" -ForegroundColor Red
            }
        } else {
            $failed++
            Write-Host "  ✗ Not found: $file" -ForegroundColor Red
        }
    }

    # Log preload activity
    $logEntry = @{
        'timestamp' = Get-Date -Format 'o'
        'action' = 'preload'
        'files_requested' = $Files.Count
        'preloaded' = $preloaded
        'failed' = $failed
        'files' = $Files
    } | ConvertTo-Json -Compress

    Add-Content -Path $PreloadLog -Value $logEntry -Encoding UTF8

    Write-Host "`nPreload complete: $preloaded succeeded, $failed failed" -ForegroundColor $(if ($failed -eq 0) { 'Green' } else { 'Yellow' })
}

function Preload-FromPattern {
    param(
        [string]$Pattern,
        [double]$Confidence
    )

    Write-Host "Preloading context for workflow pattern: $Pattern" -ForegroundColor Cyan

    # Get pattern-specific context files
    $patterns = @{
        'debug' = @(
            'C:\scripts\ci-cd-troubleshooting.md'
            'C:\scripts\_machine\reflection.log.md'
            'C:\Projects\client-manager\README.md'
            'C:\scripts\development-patterns.md'
        )
        'feature' = @(
            'C:\scripts\worktree-workflow.md'
            'C:\scripts\development-patterns.md'
            'C:\scripts\_machine\worktrees.pool.md'
            'C:\scripts\git-workflow.md'
        )
        'documentation' = @(
            'C:\scripts\CLAUDE.md'
            'C:\scripts\docs\claude-system\STARTUP_PROTOCOL.md'
            'C:\scripts\continuous-improvement.md'
        )
        'ci-cd' = @(
            'C:\scripts\ci-cd-troubleshooting.md'
            'C:\Projects\client-manager\.github\workflows'
        )
        'git-workflow' = @(
            'C:\scripts\git-workflow.md'
            'C:\scripts\_machine\worktrees.activity.md'
            'C:\scripts\worktree-workflow.md'
        )
        'worktree-management' = @(
            'C:\scripts\worktree-workflow.md'
            'C:\scripts\_machine\worktrees.pool.md'
            'C:\scripts\_machine\worktrees.protocol.md'
        )
        'exploration' = @(
            'C:\scripts\CLAUDE.md'
            'C:\Projects\client-manager\README.md'
            'C:\scripts\tools\README.md'
        )
        'review' = @(
            'C:\scripts\development-patterns.md'
            'C:\scripts\_machine\DEFINITION_OF_DONE.md'
            'C:\scripts\git-workflow.md'
        )
    }

    if ($patterns.ContainsKey($Pattern)) {
        Preload-ContextFiles -Files $patterns[$Pattern]
    } else {
        Write-Host "Unknown pattern: $Pattern" -ForegroundColor Red
        Write-Host "Available patterns: $($patterns.Keys -join ', ')" -ForegroundColor Gray
    }
}

function Preload-FromPredictions {
    param([double]$Confidence)

    Write-Host "Preloading context based on predictions (confidence >$($Confidence * 100)%)..." -ForegroundColor Cyan

    # This would integrate with Markov predictor and pattern detector
    # For now, implement essentials preloading

    $essentialFiles = @(
        'C:\scripts\CLAUDE.md'
        'C:\scripts\MACHINE_CONFIG.md'
        'C:\scripts\_machine\worktrees.pool.md'
        'C:\scripts\docs\claude-system\STARTUP_PROTOCOL.md'
    )

    Write-Host "Preloading essential context files (always high probability)..." -ForegroundColor Yellow
    Preload-ContextFiles -Files $essentialFiles
}

function Get-PreloadStatus {
    Write-Host "`nContext Preloader Status:" -ForegroundColor Cyan
    Write-Host "==========================" -ForegroundColor Cyan

    # Get cache stats
    Write-Host "`nHot Cache Statistics:" -ForegroundColor Yellow
    & $CacheScript -Action stats

    # Show recent preload activity
    if (Test-Path $PreloadLog) {
        Write-Host "`nRecent Preload Activity:" -ForegroundColor Yellow

        $recentActivity = Get-Content $PreloadLog -Tail 5 | ForEach-Object { $_ | ConvertFrom-Json }

        $recentActivity | ForEach-Object {
            Write-Host "  $($_.timestamp): $($_.preloaded)/$($_.files_requested) files preloaded" -ForegroundColor Gray
        }

        # Calculate success rate
        $totalRequested = ($recentActivity.files_requested | Measure-Object -Sum).Sum
        $totalPreloaded = ($recentActivity.preloaded | Measure-Object -Sum).Sum

        if ($totalRequested -gt 0) {
            $successRate = [math]::Round(($totalPreloaded / $totalRequested) * 100, 1)
            Write-Host "`nOverall preload success rate: $successRate%" -ForegroundColor Green
        }
    } else {
        Write-Host "`nNo preload activity yet" -ForegroundColor Gray
    }
}

# Main execution
switch ($Action) {
    'preload' {
        if (-not $FilePaths -or $FilePaths.Count -eq 0) {
            Write-Host "FilePaths required for preload operation" -ForegroundColor Red
            Write-Host "Example: -FilePaths 'C:\scripts\CLAUDE.md','C:\scripts\git-workflow.md'" -ForegroundColor Gray
            exit 1
        }
        Preload-ContextFiles -Files $FilePaths
    }
    'preload-pattern' {
        if (-not $WorkflowPattern) {
            Write-Host "WorkflowPattern required" -ForegroundColor Red
            Write-Host "Example: -WorkflowPattern 'debug'" -ForegroundColor Gray
            exit 1
        }
        Preload-FromPattern -Pattern $WorkflowPattern -Confidence $ConfidenceThreshold
    }
    'preload-predictions' {
        Preload-FromPredictions -Confidence $ConfidenceThreshold
    }
    'status' {
        Get-PreloadStatus
    }
}
