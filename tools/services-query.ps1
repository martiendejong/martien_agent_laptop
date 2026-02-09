#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Query the services registry

.DESCRIPTION
    Returns JSON info about registered services.
    Can query by name, port, or list all.

.PARAMETER ServiceName
    Name of service to query (optional)

.PARAMETER Port
    Port number to query (optional)

.PARAMETER ListAll
    List all registered services

.PARAMETER CheckHealth
    Check if services are actually running (verify PIDs)

.EXAMPLE
    .\services-query.ps1 -ListAll

.EXAMPLE
    .\services-query.ps1 -ServiceName "Hazina Orchestration"

.EXAMPLE
    .\services-query.ps1 -Port 5123

.EXAMPLE
    .\services-query.ps1 -CheckHealth

.NOTES
    Author: Jengo
    Created: 2026-02-09
    ROI: 7.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ServiceName = "",

    [Parameter(Mandatory = $false)]
    [int]$Port = 0,

    [Parameter(Mandatory = $false)]
    [switch]$ListAll,

    [Parameter(Mandatory = $false)]
    [switch]$CheckHealth
)

$ErrorActionPreference = "Stop"

$registryFile = "C:\scripts\_machine\services-registry.json"

if (-not (Test-Path $registryFile)) {
    Write-Host "⚠️  No services registry found" -ForegroundColor Yellow
    Write-Host "   Expected: $registryFile" -ForegroundColor Gray
    exit 1
}

# Load registry
$registry = Get-Content $registryFile -Raw | ConvertFrom-Json
$services = @($registry.services)

# Health check if requested
if ($CheckHealth) {
    Write-Host "🏥 Checking service health..." -ForegroundColor Cyan
    foreach ($service in $services) {
        if ($service.pid -gt 0) {
            $processExists = Get-Process -Id $service.pid -ErrorAction SilentlyContinue
            if ($processExists) {
                $service.status = "running"
                Write-Host "  ✅ $($service.name) (PID $($service.pid))" -ForegroundColor Green
            } else {
                $service.status = "stopped"
                Write-Host "  ❌ $($service.name) (PID $($service.pid) not found)" -ForegroundColor Red
            }
        } else {
            $service.status = "unknown"
            Write-Host "  ⚠️  $($service.name) (no PID registered)" -ForegroundColor Yellow
        }
    }

    # Save updated status
    $registry.services = $services
    $registry.updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $registry | ConvertTo-Json -Depth 10 | Out-File -FilePath $registryFile -Encoding UTF8
    Write-Host ""
}

# Query by name
if ($ServiceName) {
    $result = $services | Where-Object { $_.name -eq $ServiceName }
    if ($result) {
        $result | ConvertTo-Json -Depth 10
    } else {
        Write-Host "❌ Service not found: $ServiceName" -ForegroundColor Red
        exit 1
    }
    exit 0
}

# Query by port
if ($Port -gt 0) {
    $result = $services | Where-Object { $_.port -eq $Port }
    if ($result) {
        $result | ConvertTo-Json -Depth 10
    } else {
        Write-Host "❌ No service found on port: $Port" -ForegroundColor Red
        exit 1
    }
    exit 0
}

# List all
if ($ListAll -or (-not $ServiceName -and $Port -eq 0)) {
    Write-Host "📋 Registered Services ($($services.Count)):" -ForegroundColor Cyan
    Write-Host ""

    foreach ($service in $services) {
        $statusColor = switch ($service.status) {
            "running" { "Green" }
            "stopped" { "Red" }
            default { "Yellow" }
        }

        Write-Host "  🔹 $($service.name)" -ForegroundColor White
        Write-Host "     URL: $($service.url)" -ForegroundColor Gray
        Write-Host "     Port: $($service.port)" -ForegroundColor Gray
        Write-Host "     Status: $($service.status)" -ForegroundColor $statusColor
        Write-Host "     PID: $($service.pid)" -ForegroundColor Gray
        Write-Host "     Last seen: $($service.last_seen)" -ForegroundColor Gray
        Write-Host ""
    }

    # Also output JSON for programmatic access
    Write-Host "JSON Output:" -ForegroundColor Cyan
    $services | ConvertTo-Json -Depth 10
}
