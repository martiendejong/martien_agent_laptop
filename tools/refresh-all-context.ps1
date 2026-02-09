# Refresh all context files (quick-context, projects, external-tools)
# Run this when project configuration changes
# Author: Jengo, Created: 2026-02-09

param()

$ErrorActionPreference = "Stop"

Write-Host "Refreshing all context files..." -ForegroundColor Cyan
Write-Host ""

# 1. Quick context
Write-Host "[1/3] Building quick-context.json..." -ForegroundColor White
& "C:\scripts\tools\build-quick-context-v2.ps1"
Write-Host ""

# 2. Project contexts
Write-Host "[2/3] Building project contexts..." -ForegroundColor White
& "C:\scripts\tools\build-project-context-v2.ps1" -All
Write-Host ""

# 3. External tools
Write-Host "[3/3] Building external-tools.json..." -ForegroundColor White
& "C:\scripts\tools\build-external-tools-v2.ps1"
Write-Host ""

Write-Host "All context files refreshed!" -ForegroundColor Green
Write-Host ""
Write-Host "Files generated:" -ForegroundColor Cyan
Write-Host "  - C:\scripts\_machine\quick-context.json" -ForegroundColor Gray
Write-Host "  - C:\scripts\_machine\projects\*.json (4 files)" -ForegroundColor Gray
Write-Host "  - C:\scripts\_machine\external-tools.json" -ForegroundColor Gray
