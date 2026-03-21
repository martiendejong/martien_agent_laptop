#Requires -Version 5.1
<#
.SYNOPSIS
    Auto-rebuild npm projects on file changes

.DESCRIPTION
    Watches for file changes and triggers npm build automatically.

.PARAMETER ProjectPath
    Path to directory containing package.json

.PARAMETER Script
    npm script to run (default: "dev" or "watch")

.EXAMPLE
    watch-npm.ps1 -ProjectPath "C:\Projects\client-manager\ClientManager.Web"

.EXAMPLE
    watch-npm.ps1 -ProjectPath "C:\stores\orchestration\orchestration-frontend" -Script "dev"

.NOTES
    Created: 2026-02-16
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    [string]$Script = $null
)

# Verify package.json exists
$packageJson = Join-Path $ProjectPath "package.json"
if (-not (Test-Path $packageJson)) {
    Write-Error "package.json not found in $ProjectPath"
    exit 1
}

# Auto-detect script if not provided
if (-not $Script) {
    $pkg = Get-Content $packageJson -Raw | ConvertFrom-Json
    if ($pkg.scripts.dev) {
        $Script = "dev"
    } elseif ($pkg.scripts.watch) {
        $Script = "watch"
    } elseif ($pkg.scripts.start) {
        $Script = "start"
    } else {
        Write-Error "No dev/watch/start script found in package.json"
        exit 1
    }
}

Write-Host ""
Write-Host "Starting npm watch mode..." -ForegroundColor Cyan
Write-Host "Project: $ProjectPath" -ForegroundColor White
Write-Host "Script: npm run $Script" -ForegroundColor White
Write-Host ""
Write-Host "Watching for changes... (Ctrl+C to stop)" -ForegroundColor Yellow
Write-Host ""

# Run npm script
Push-Location $ProjectPath
try {
    npm run $Script
} catch {
    Write-Error "Watch failed: $_"
    exit 1
} finally {
    Pop-Location
}
