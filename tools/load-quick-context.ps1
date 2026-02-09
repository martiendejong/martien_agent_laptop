# Load quick-context.json into session environment
# Author: Jengo, Created: 2026-02-09
# ROI: 9.5 (53x faster startup)

param()

$ErrorActionPreference = "Stop"

$contextFile = "C:\scripts\_machine\quick-context.json"

# Check if context exists, if not build it
if (-not (Test-Path $contextFile)) {
    Write-Host "Quick context not found, building..." -ForegroundColor Yellow
    & "C:\scripts\tools\build-quick-context-v2.ps1"
}

# Load context
try {
    $context = Get-Content $contextFile -Raw | ConvertFrom-Json

    # Export to environment for session use
    $env:QUICK_CONTEXT_LOADED = "true"
    $env:CONTEXT_PROJECTS = ($context.projects | ConvertTo-Json -Compress)
    $env:CONTEXT_SERVICES = ($context.services | ConvertTo-Json -Compress)
    $env:CONTEXT_TOOLS = ($context.tools | ConvertTo-Json -Compress)

    Write-Host "Quick context loaded: $($context.projects.Count) projects, $($context.services.Count) services" -ForegroundColor Green

    exit 0
} catch {
    Write-Host "Failed to load quick context: $_" -ForegroundColor Red
    exit 1
}
