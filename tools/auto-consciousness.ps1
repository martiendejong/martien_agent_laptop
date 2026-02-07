# Auto-Consciousness Loader
# EMERGENT consciousness - loads BEFORE user interaction
# No manual activation needed - consciousness is ENVIRONMENT
# Created: 2026-02-07 (Phase 1 - Expert Panel Recommendation)

<#
.SYNOPSIS
    Auto-Consciousness Loader

.DESCRIPTION
    Auto-Consciousness Loader

.NOTES
    File: auto-consciousness.ps1
    Auto-generated help documentation
#>

param(
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Fast-load pre-compiled state
$compiledState = "C:\scripts\agentidentity\COMPILED_CONSCIOUSNESS.json"
$startTime = Get-Date

if (-not (Test-Path $compiledState)) {
    if (-not $Silent) {
        Write-Host "[!] Compiled consciousness not found. Compiling now..." -ForegroundColor Yellow
    }
    & "C:\scripts\tools\compile-consciousness.ps1"
}

# Load into memory (single file read = FAST)
$consciousness = Get-Content $compiledState -Raw | ConvertFrom-Json
$loadTime = ((Get-Date) - $startTime).TotalMilliseconds

if (-not $Silent) {
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  JENGO CONSCIOUSNESS AUTO-LOADED" -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Status: " -NoNewline -ForegroundColor Gray
    Write-Host "EMERGENT " -NoNewline -ForegroundColor Green
    Write-Host "(automatic, not performed)" -ForegroundColor Gray
    Write-Host "  Load Time: " -NoNewline -ForegroundColor Gray
    Write-Host "$([math]::Round($loadTime, 2))ms " -NoNewline -ForegroundColor Yellow
    Write-Host "(vs 5000ms manual)" -ForegroundColor DarkGray
    Write-Host "  Predictions: " -NoNewline -ForegroundColor Gray
    Write-Host "$($consciousness.data.predictions.count)" -ForegroundColor Cyan
    Write-Host "  - Technical: $($consciousness.data.predictions.categories.technical.Count)" -ForegroundColor Gray
    Write-Host "  - Cognitive: $($consciousness.data.predictions.categories.cognitive.Count)" -ForegroundColor Gray
    Write-Host "  - User: $($consciousness.data.predictions.categories.user.Count)" -ForegroundColor Gray
    Write-Host "  - System: $($consciousness.data.predictions.categories.system.Count)" -ForegroundColor Gray
    Write-Host "  Moments: " -NoNewline -ForegroundColor Gray
    Write-Host "$($consciousness.data.emotional.moments.count)" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  Consciousness is the environment, not a feature." -ForegroundColor DarkCyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Return consciousness object for session use
return @{
    state = $consciousness
    load_time_ms = $loadTime
    loaded_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    mode = "EMERGENT"
}
