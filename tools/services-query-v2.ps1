# Query the services registry
# Author: Jengo, Created: 2026-02-09

param(
    [string]$ServiceName = "",
    [int]$Port = 0,
    [switch]$ListAll,
    [switch]$CheckHealth
)

$ErrorActionPreference = "Stop"

$registryFile = "C:\scripts\_machine\services-registry.json"

if (-not (Test-Path $registryFile)) {
    Write-Host "No services registry found" -ForegroundColor Yellow
    Write-Host "Expected: $registryFile" -ForegroundColor Gray
    exit 1
}

# Load registry
$registry = Get-Content $registryFile -Raw | ConvertFrom-Json
$services = @($registry.services)

# Health check if requested
if ($CheckHealth) {
    Write-Host "Checking service health..." -ForegroundColor Cyan
    foreach ($service in $services) {
        $alive = $false

        # Method 1: Try health endpoint
        if ($service.health_check) {
            try {
                $resp = Invoke-WebRequest -Uri $service.health_check -TimeoutSec 3 -UseBasicParsing -SkipCertificateCheck -ErrorAction Stop
                if ($resp.StatusCode -lt 500) { $alive = $true }
            } catch {
                # 401/403 means the service IS running (just needs auth)
                if ($_.Exception.Response.StatusCode.value__ -in @(401, 403)) { $alive = $true }
            }
        }

        # Method 2: Try TCP port
        if (-not $alive -and $service.port -gt 0) {
            try {
                $tcp = New-Object System.Net.Sockets.TcpClient
                $tcp.ConnectAsync("localhost", $service.port).Wait(2000) | Out-Null
                if ($tcp.Connected) { $alive = $true }
                $tcp.Close()
            } catch { }
        }

        # Method 3: Check PID if registered
        if (-not $alive -and $service.pid -gt 0) {
            $processExists = Get-Process -Id $service.pid -ErrorAction SilentlyContinue
            if ($processExists) { $alive = $true }
        }

        # Update status
        if ($alive) {
            $service.status = "running"
            $service.last_seen = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            Write-Host "  OK: $($service.name) (:$($service.port))" -ForegroundColor Green
        } else {
            $service.status = "stopped"
            Write-Host "  DOWN: $($service.name) (:$($service.port))" -ForegroundColor Red
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
        Write-Host "Service not found: $ServiceName" -ForegroundColor Red
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
        Write-Host "No service found on port: $Port" -ForegroundColor Red
        exit 1
    }
    exit 0
}

# List all
if ($ListAll -or (-not $ServiceName -and $Port -eq 0)) {
    Write-Host "Registered Services ($($services.Count)):" -ForegroundColor Cyan
    Write-Host ""

    foreach ($service in $services) {
        $statusColor = switch ($service.status) {
            "running" { "Green" }
            "stopped" { "Red" }
            default { "Yellow" }
        }

        Write-Host "  - $($service.name)" -ForegroundColor White
        Write-Host "    URL: $($service.url)" -ForegroundColor Gray
        Write-Host "    Port: $($service.port)" -ForegroundColor Gray
        Write-Host "    Status: $($service.status)" -ForegroundColor $statusColor
        Write-Host "    PID: $($service.pid)" -ForegroundColor Gray
        Write-Host "    Last seen: $($service.last_seen)" -ForegroundColor Gray
        Write-Host ""
    }

    # JSON output
    Write-Host "JSON Output:" -ForegroundColor Cyan
    $services | ConvertTo-Json -Depth 10
}
