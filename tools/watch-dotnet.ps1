#Requires -Version 5.1
<#
.SYNOPSIS
    Auto-rebuild .NET projects on file changes

.DESCRIPTION
    Watches for file changes and triggers dotnet build automatically.
    Pattern from Poltergeist integration concept.

.PARAMETER ProjectPath
    Path to .csproj file or directory containing it

.PARAMETER Configuration
    Build configuration (Debug/Release), default: Debug

.PARAMETER OnChange
    Command to run after successful build

.EXAMPLE
    watch-dotnet.ps1 -ProjectPath "C:\Projects\hazina"

.EXAMPLE
    watch-dotnet.ps1 -ProjectPath "C:\Projects\client-manager\ClientManager.API" -Configuration Release

.NOTES
    Created: 2026-02-16
    Uses dotnet watch (built-in to .NET SDK)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    [string]$Configuration = "Debug",
    [string]$OnChange
)

# Find .csproj file
$projectFile = $null
if (Test-Path $ProjectPath -PathType Container) {
    $projectFile = Get-ChildItem -Path $ProjectPath -Filter "*.csproj" | Select-Object -First 1
    if (-not $projectFile) {
        Write-Error "No .csproj file found in $ProjectPath"
        exit 1
    }
    $projectFile = $projectFile.FullName
} else {
    $projectFile = $ProjectPath
}

if (-not (Test-Path $projectFile)) {
    Write-Error "Project file not found: $projectFile"
    exit 1
}

Write-Host ""
Write-Host "Starting .NET watch mode..." -ForegroundColor Cyan
Write-Host "Project: $projectFile" -ForegroundColor White
Write-Host "Configuration: $Configuration" -ForegroundColor White
Write-Host ""
Write-Host "Watching for changes... (Ctrl+C to stop)" -ForegroundColor Yellow
Write-Host ""

# Use dotnet watch
$watchArgs = @("watch", "build", $projectFile, "-c", $Configuration, "--no-hot-reload")

try {
    & dotnet $watchArgs
} catch {
    Write-Error "Watch failed: $_"
    exit 1
}
