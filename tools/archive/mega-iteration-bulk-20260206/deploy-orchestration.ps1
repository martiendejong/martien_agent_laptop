<#
.SYNOPSIS
    Deploy Hazina Orchestration to local C:\stores\orchestration

.DESCRIPTION
    Builds and deploys the Hazina Orchestration app with correct configuration:
    - HTTPS on port 5123 listening on all interfaces (for Tailscale)
    - DefaultCommand: C:\scripts\claude_agent.bat
    - Working directory: C:\scripts

.PARAMETER SkipBuild
    Skip the build step and just deploy existing artifacts

.PARAMETER SkipFrontend
    Skip rebuilding the React frontend (faster builds)

.EXAMPLE
    .\deploy-orchestration.ps1
    Full build and deploy

.EXAMPLE
    .\deploy-orchestration.ps1 -SkipFrontend
    Build backend only and deploy (faster)
#>

param(
    [switch]$SkipBuild,
    [switch]$SkipFrontend
)

$ErrorActionPreference = 'Stop'

# Paths
$SourceDir = "C:\Projects\hazina\apps\Demos\Hazina.Demo.AgenticOrchestration"
$PublishDir = "$SourceDir\publish\win-x64"
$DeployDir = "C:\stores\orchestration"
$ProcessName = "HazinaOrchestration"

# Configuration for local deployment
$LocalConfig = @{
    Logging = @{
        LogLevel = @{
            Default = "Information"
            "Microsoft.AspNetCore" = "Warning"
        }
    }
    AllowedHosts = "*"
    Kestrel = @{
        Endpoints = @{
            Https = @{
                Url = "https://*:5123"
                Certificate = @{
                    Path = "tailscale.crt"
                    KeyPath = "tailscale.key"
                }
            }
        }
    }
    Authentication = @{
        Enabled = $true
        Username = "bosi"
        Password = "Th1s1sSp4rt4!"
        Realm = "Hazina Agentic Orchestration"
    }
    AgenticOrchestration = @{
        DatabasePath = "C:\scripts\_machine\agent-activity.db"
        LogsPath = "C:\scripts\logs"
        EntitiesYamlPath = "entities.yaml"
        SignalR = @{
            Enabled = $true
            HubPath = "/hubs/agentic"
        }
        Polling = @{
            InstanceHeartbeatTimeoutSeconds = 60
            InteractionExpiryMinutes = 60
        }
        Features = @{
            EnableTaskQueue = $true
            EnableOutputStreaming = $true
            EnableRealtimeNotifications = $true
        }
        Terminal = @{
            DefaultCommand = "C:\scripts\claude_agent.bat"
            DefaultWorkingDirectory = "C:\scripts"
            DefaultArguments = @()
            DefaultColumns = 120
            DefaultRows = 30
            MaxConcurrentSessions = 10
            SessionTimeoutMinutes = 60
        }
        SessionLogging = @{
            Enabled = $true
            BasePath = "C:\scripts\logs\agent-sessions"
        }
    }
    Swagger = @{
        Enabled = $true
        Title = "Hazina Agentic Orchestration API"
        Description = "Web API for managing Claude Code CLI instances via Hazina declarative framework"
        Version = "v1"
    }
}

Write-Host ""
Write-Host "=" * 65 -ForegroundColor Cyan
Write-Host "  HAZINA ORCHESTRATION - Local Deployment" -ForegroundColor Cyan
Write-Host "=" * 65 -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop existing process
Write-Host "[1/5] Stopping existing process..." -ForegroundColor Yellow
$proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
if ($proc) {
    Stop-Process -Name $ProcessName -Force
    Start-Sleep -Seconds 2
    Write-Host "      Stopped PID: $($proc.Id)" -ForegroundColor Green
} else {
    Write-Host "      No process running" -ForegroundColor Gray
}

# Step 2: Build
if (-not $SkipBuild) {
    Write-Host ""
    Write-Host "[2/5] Building..." -ForegroundColor Yellow

    Push-Location $SourceDir
    try {
        if ($SkipFrontend) {
            & .\build-release.ps1 -Platform windows -SkipFrontend
        } else {
            & .\build-release.ps1 -Platform windows
        }

        if ($LASTEXITCODE -ne 0) {
            throw "Build failed with exit code $LASTEXITCODE"
        }
        Write-Host "      Build completed" -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
} else {
    Write-Host ""
    Write-Host "[2/5] Skipping build (using existing artifacts)" -ForegroundColor Gray
}

# Step 3: Create deploy directory if needed
Write-Host ""
Write-Host "[3/5] Preparing deployment directory..." -ForegroundColor Yellow
if (-not (Test-Path $DeployDir)) {
    New-Item -ItemType Directory -Path $DeployDir -Force | Out-Null
    Write-Host "      Created: $DeployDir" -ForegroundColor Green
} else {
    Write-Host "      Exists: $DeployDir" -ForegroundColor Gray
}

# Step 4: Copy files (excluding appsettings.json - we'll write our own)
Write-Host ""
Write-Host "[4/5] Deploying files..." -ForegroundColor Yellow

# Copy all files except appsettings.json
Get-ChildItem -Path $PublishDir -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Substring($PublishDir.Length + 1)
    $destPath = Join-Path $DeployDir $relativePath

    if ($_.PSIsContainer) {
        if (-not (Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }
    } else {
        # Skip appsettings.json - we'll write our own config
        if ($_.Name -ne "appsettings.json") {
            $destDir = Split-Path $destPath -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $destPath -Force
        }
    }
}

# Write the correct local configuration
$configPath = Join-Path $DeployDir "appsettings.json"
$LocalConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8
Write-Host "      Files deployed" -ForegroundColor Green
Write-Host "      Config written with:" -ForegroundColor Green
Write-Host "        - HTTPS on *:5123 (Tailscale compatible)" -ForegroundColor Gray
Write-Host "        - Command: C:\scripts\claude_agent.bat" -ForegroundColor Gray

# Generate/refresh Tailscale HTTPS certificate
Write-Host "      Generating Tailscale certificate..." -ForegroundColor Gray
$certPath = Join-Path $DeployDir "tailscale.crt"
$keyPath = Join-Path $DeployDir "tailscale.key"
$tailscaleResult = & tailscale cert --cert-file $certPath --key-file $keyPath "desktop-ecbaunu.tailca9ff1.ts.net" 2>&1
if (Test-Path $certPath) {
    Write-Host "        - Tailscale certificate: OK" -ForegroundColor Gray
} else {
    Write-Host "        - Tailscale certificate: FAILED" -ForegroundColor Yellow
}

# Step 5: Start the service
Write-Host ""
Write-Host "[5/5] Starting service..." -ForegroundColor Yellow
Start-Process -FilePath (Join-Path $DeployDir "HazinaOrchestration.exe") `
              -WorkingDirectory $DeployDir `
              -WindowStyle Hidden

Start-Sleep -Seconds 4

# Verify
$proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
if ($proc) {
    Write-Host "      Started PID: $($proc.Id)" -ForegroundColor Green

    # Check if listening
    $listening = netstat -an | Select-String ":5123.*LISTENING"
    if ($listening) {
        Write-Host "      Listening on port 5123" -ForegroundColor Green
    }
} else {
    Write-Host "      WARNING: Process not running!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=" * 65 -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETE" -ForegroundColor Green
Write-Host "=" * 65 -ForegroundColor Green
Write-Host ""
Write-Host "  Access URLs:" -ForegroundColor Cyan
Write-Host "    Local:     https://localhost:5123" -ForegroundColor White
Write-Host "    Tailscale: https://desktop-ecbaunu.tailca9ff1.ts.net:5123" -ForegroundColor White
Write-Host "    Swagger:   https://localhost:5123/swagger" -ForegroundColor White
Write-Host ""
Write-Host "  Credentials: bosi / Th1s1sSp4rt4!" -ForegroundColor Gray
Write-Host ""
