<#
.SYNOPSIS
    UI Automation Bridge Server - Windows UI control via HTTP API

.DESCRIPTION
    Starts the UI Automation Bridge server that enables programmatic control
    of Windows desktop applications via FlaUI.

    Runs on http://localhost:27184 by default.

.PARAMETER Port
    Port to listen on (default: 27184)

.PARAMETER Debug
    Enable debug logging

.PARAMETER Build
    Force rebuild before starting

.EXAMPLE
    .\ui-automation-bridge-server.ps1

.EXAMPLE
    .\ui-automation-bridge-server.ps1 -Debug

.EXAMPLE
    .\ui-automation-bridge-server.ps1 -Port 27185
#>

param(
    [int]$Port = 27184,
    [switch]$Debug,
    [switch]$Build
)

$ErrorActionPreference = "Stop"

$projectPath = Join-Path $PSScriptRoot "ui-automation-bridge\UIAutomationBridge"
$dllPath = Join-Path $projectPath "bin\Debug\net9.0\UIAutomationBridge.dll"

# Check if project exists
if (-not (Test-Path $projectPath)) {
    Write-Host "[ERROR] Project not found at: $projectPath" -ForegroundColor Red
    Write-Host "Run: cd C:\scripts\tools && dotnet new console -n UIAutomationBridge" -ForegroundColor Yellow
    exit 1
}

# Build if requested or if DLL doesn't exist
if ($Build -or -not (Test-Path $dllPath)) {
    Write-Host "[BUILD] Building UI Automation Bridge..." -ForegroundColor Cyan
    Push-Location $projectPath
    try {
        dotnet build -c Debug
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Build failed" -ForegroundColor Red
            exit 1
        }
        Write-Host "[BUILD] Build completed successfully" -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}

# Start server
Write-Host "[START] Starting UI Automation Bridge server..." -ForegroundColor Cyan

$args = @($Port)
if ($Debug) {
    $args += "--debug"
}

try {
    dotnet $dllPath @args
}
catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
