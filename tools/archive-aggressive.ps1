# Aggressive Archive - Keep ONLY essential tools
# Target: 30 tools

$toolsDir = "C:\scripts\tools"
$archiveDir = "C:\scripts\tools\archive\aggressive-cleanup-20260205"

# Create archive directory
New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

# ONLY these tools should remain - referenced in core documentation
$essentialTools = @(
    # Consciousness tools (CORE_IDENTITY.md)
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

    # Workflow tools (scripts.md, workflow docs)
    "cs-format.ps1",
    "cs-autofix.ps1",
    "clickup-sync.ps1",
    "cleanup-stale-branches.ps1",
    "diagnose-error.ps1",
    "ef-migration-status.ps1",
    "daily-summary.ps1",
    "validate-pr-base.ps1",
    "merge-pr-sequence.ps1",

    # Archive tools (meta)
    "archive-bulk-tools.ps1",
    "archive-bulk-docs.ps1",
    "archive-aggressive.ps1",
    "archive-reflections.ps1",

    # Utility
    "ai-image.ps1",
    "ai-vision.ps1"
)

# Get all PS1 files
$allTools = Get-ChildItem -Path $toolsDir -Filter "*.ps1" -File

$totalTools = $allTools.Count
$keepCount = 0
$archiveCount = 0

Write-Host "AGGRESSIVE CLEANUP" -ForegroundColor Red
Write-Host "Total tools: $totalTools"
Write-Host "Essential tools: $($essentialTools.Count)"
Write-Host ""

foreach ($tool in $allTools) {
    if ($essentialTools -contains $tool.Name) {
        $keepCount++
        Write-Host "  KEEP: $($tool.Name)" -ForegroundColor Green
    } else {
        # Archive it
        $destPath = Join-Path $archiveDir $tool.Name
        Move-Item -Path $tool.FullName -Destination $destPath -Force
        $archiveCount++
    }
}

Write-Host ""
Write-Host "Archive complete!" -ForegroundColor Cyan
Write-Host "  Kept: $keepCount tools"
Write-Host "  Archived: $archiveCount tools"
Write-Host "  Archive location: $archiveDir"
