#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Register a running service in the services registry

.DESCRIPTION
    Updates C:\scripts\_machine\services-registry.json with service details.
    Services call this on startup to announce themselves.

.PARAMETER ServiceName
    Name of the service (e.g., "Hazina Orchestration")

.PARAMETER Port
    Port number the service is running on

.PARAMETER Url
    Full URL of the service (e.g., "https://localhost:5123")

.PARAMETER Pid
    Process ID of the service

.PARAMETER HealthCheck
    Optional health check endpoint URL

.EXAMPLE
    .\register-service.ps1 -ServiceName "My API" -Port 5000 -Url "http://localhost:5000" -Pid $PID

.NOTES
    Author: Jengo
    Created: 2026-02-09
    ROI: 7.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServiceName,

    [Parameter(Mandatory = $true)]
    [int]$Port,

    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $false)]
    [int]$ProcessId = 0,

    [Parameter(Mandatory = $false)]
    [string]$HealthCheck = "",

    [Parameter(Mandatory = $false)]
    [string]$StartupCommand = ""
)

$ErrorActionPreference = "Stop"

$registryFile = "C:\scripts\_machine\services-registry.json"

# Load or create registry
if (Test-Path $registryFile) {
    $registry = Get-Content $registryFile -Raw | ConvertFrom-Json
    $services = @($registry.services)
} else {
    $services = @()
}

# Find existing entry
$existingIndex = -1
for ($i = 0; $i -lt $services.Count; $i++) {
    if ($services[$i].name -eq $ServiceName) {
        $existingIndex = $i
        break
    }
}

# Create/update service entry
$serviceEntry = @{
    name = $ServiceName
    port = $Port
    url = $Url
    pid = $ProcessId
    health_check = $HealthCheck
    startup_command = $StartupCommand
    status = "running"
    last_seen = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

if ($existingIndex -ge 0) {
    # Update existing
    $services[$existingIndex] = $serviceEntry
    Write-Host "✅ Updated service: $ServiceName" -ForegroundColor Green
} else {
    # Add new
    $services += $serviceEntry
    Write-Host "✅ Registered new service: $ServiceName" -ForegroundColor Green
}

# Save registry
$registryData = @{
    updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    services = $services
}

$registryData | ConvertTo-Json -Depth 10 | Out-File -FilePath $registryFile -Encoding UTF8

Write-Host "Registry updated: $registryFile" -ForegroundColor Cyan
Write-Host "   $ServiceName to $Url (PID: $ProcessId)" -ForegroundColor Gray
