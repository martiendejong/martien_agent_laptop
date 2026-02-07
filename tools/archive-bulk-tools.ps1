<#
.SYNOPSIS
    Archive Bulk Tools - Mass cleanup

.DESCRIPTION
    Archive Bulk Tools - Mass cleanup

.NOTES
    File: archive-bulk-tools.ps1
    Auto-generated help documentation
#>

$ErrorActionPreference = "Stop"

# Archive Bulk Tools - Mass cleanup
# Keep only essential tools, archive the rest

$toolsDir = "C:\scripts\tools"
$archiveDir = "C:\scripts\tools\archive\mega-iteration-bulk-20260206"

# Create archive directory
New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

# Core tools to KEEP (essential for workflows)
$keepTools = @(
    # Original workflow tools
    "cs-format.ps1",
    "cs-autofix.ps1",
    "clickup-sync.ps1",
    "cleanup-stale-branches.ps1",
    "diagnose-error.ps1",
    "ef-migration-status.ps1",
    "daily-summary.ps1",

    # Consciousness tools (used in CORE_IDENTITY)
    "consciousness-startup.ps1",
    "cognitive-load-monitor.ps1",
    "emotional-state-logger.ps1",
    "capture-moment.ps1",
    "curiosity-engine.ps1",
    "relationship-memory.ps1",
    "why-did-i-do-that.ps1",
    "assumption-tracker.ps1",
    "attention-monitor.ps1",
    "bias-detector.ps1",
    "meta-reasoning.ps1",
    "perspective-shifter.ps1",
    "future-self-simulator.ps1",
    "identity-drift-detector.ps1",
    "memory-consolidation.ps1",

    # New measurement tools (iteration 1-2)
    "value-alignment-audit.ps1",
    "tool-usage-analytics.ps1",
    "doc-pruning.ps1",
    "user-behavior-model.ps1",
    "proactive-problem-scan.ps1",
    "automated-scheduler.ps1",
    "pattern-miner.ps1",
    "generate-health-dashboard.ps1",
    "ab-test-framework.ps1",
    "regression-test-suite.ps1",
    "scan-tools-simple.ps1",

    # Infrastructure tools
    "world-daily-dashboard.ps1",
    "update-knowledge-network.ps1",
    "parallel-orchestrate.ps1"
)

# Get all PS1 files
$allTools = Get-ChildItem -Path $toolsDir -Filter "*.ps1" -File

# Count stats
$totalTools = $allTools.Count
$keepCount = 0
$archiveCount = 0

Write-Host "Starting bulk tool archive..." -ForegroundColor Cyan
Write-Host "Total tools: $totalTools"
Write-Host "Tools to keep: $($keepTools.Count) explicitly + older tools"

foreach ($tool in $allTools) {
    $shouldKeep = $false

    # Keep if explicitly listed
    if ($keepTools -contains $tool.Name) {
        $shouldKeep = $true
    }

    # Keep if older than 7 days (established tools)
    $age = (New-TimeSpan -Start $tool.LastWriteTime -End (Get-Date)).Days
    if ($age -gt 7) {
        $shouldKeep = $true
    }

    # Keep archive scripts
    if ($tool.Name -like "archive*") {
        $shouldKeep = $true
    }

    if ($shouldKeep) {
        $keepCount++
    } else {
        # Archive it
        $destPath = Join-Path $archiveDir $tool.Name
        Move-Item -Path $tool.FullName -Destination $destPath -Force
        $archiveCount++
    }
}

Write-Host "`nArchive complete!" -ForegroundColor Green
Write-Host "  Kept: $keepCount tools"
Write-Host "  Archived: $archiveCount tools"
Write-Host "  Archive location: $archiveDir"
