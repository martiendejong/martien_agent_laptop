#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Hazina Orchestration Service Installer

.DESCRIPTION
    Installs Hazina Orchestration as a Windows service with custom terminal configuration.

.EXAMPLE
    .\install.ps1
    Interactive installation with prompts

.EXAMPLE
    .\install.ps1 -TerminalExecutable "C:\scripts\claude_agent.bat" -WorkingDirectory "C:\scripts" -Silent
    Silent installation with parameters
#>

param(
    [string]$InstallPath = "C:\Program Files\Hazina Framework\Hazina Orchestration",
    [string]$TerminalExecutable,
    [string]$WorkingDirectory,
    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

# Banner
Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "           HAZINA ORCHESTRATION SERVICE INSTALLER                      " -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This installer must be run as Administrator" -ForegroundColor Red
    Write-Host "Please right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Source directory (where files are extracted)
$SourceDir = $PSScriptRoot
$SourceExe = Join-Path $SourceDir "HazinaOrchestration.exe"

if (-not (Test-Path $SourceExe)) {
    Write-Host "ERROR: HazinaOrchestration.exe not found in $SourceDir" -ForegroundColor Red
    Write-Host "Please ensure the installer package is extracted completely." -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/6] Installation Configuration" -ForegroundColor Yellow
Write-Host ""

# Get installation path
if (-not $Silent) {
    Write-Host "Installation Path: $InstallPath" -ForegroundColor Cyan
    $response = Read-Host "Press Enter to accept or type a new path"
    if ($response) {
        $InstallPath = $response
    }
}

Write-Host "   Installing to: $InstallPath" -ForegroundColor Green
Write-Host ""

# Get terminal executable
if (-not $TerminalExecutable) {
    Write-Host "Terminal Executable Configuration" -ForegroundColor Cyan
    Write-Host "   This is the command that will be executed by the orchestrator." -ForegroundColor Gray
    Write-Host "   Examples:" -ForegroundColor Gray
    Write-Host "   - C:\Windows\System32\cmd.exe" -ForegroundColor Gray
    Write-Host "   - C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ForegroundColor Gray
    Write-Host "   - C:\scripts\claude_agent.bat" -ForegroundColor Gray
    Write-Host ""

    $defaultTerminal = "C:\Windows\System32\cmd.exe"
    $TerminalExecutable = Read-Host "Terminal executable [$defaultTerminal]"

    if ([string]::IsNullOrWhiteSpace($TerminalExecutable)) {
        $TerminalExecutable = $defaultTerminal
    }
}

# Validate terminal executable exists
if (-not (Test-Path $TerminalExecutable)) {
    Write-Host "WARNING: Terminal executable not found: $TerminalExecutable" -ForegroundColor Yellow
    if (-not $Silent) {
        $continue = Read-Host "Continue anyway? (y/N)"
        if ($continue -ne 'y') {
            Write-Host "Installation cancelled." -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "   Terminal: $TerminalExecutable" -ForegroundColor Green
Write-Host ""

# Get working directory
if (-not $WorkingDirectory) {
    Write-Host "Terminal Working Directory" -ForegroundColor Cyan
    $defaultWorkDir = "C:\scripts"
    $WorkingDirectory = Read-Host "Working directory [$defaultWorkDir]"

    if ([string]::IsNullOrWhiteSpace($WorkingDirectory)) {
        $WorkingDirectory = $defaultWorkDir
    }
}

Write-Host "   Working Directory: $WorkingDirectory" -ForegroundColor Green
Write-Host ""

# Create working directory if it doesn't exist
if (-not (Test-Path $WorkingDirectory)) {
    Write-Host "   Creating working directory..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path $WorkingDirectory -Force | Out-Null
}

Write-Host ""
Write-Host "[2/6] Copying Files" -ForegroundColor Yellow

# Create installation directory
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}

# Create subdirectories
$dataPath = Join-Path $InstallPath "data"
$logsPath = Join-Path $InstallPath "logs"
$sessionLogsPath = Join-Path $logsPath "agent-sessions"

New-Item -ItemType Directory -Path $dataPath -Force | Out-Null
New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
New-Item -ItemType Directory -Path $sessionLogsPath -Force | Out-Null

# Copy all files
Write-Host "   Copying application files..."
Copy-Item -Path "$SourceDir\*" -Destination $InstallPath -Recurse -Force -Exclude "install.ps1"

$exePath = Join-Path $InstallPath "HazinaOrchestration.exe"
$fileInfo = Get-Item $exePath
$sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)

Write-Host "   Copied HazinaOrchestration.exe ($sizeMB MB)" -ForegroundColor Green
Write-Host ""

Write-Host "[3/6] Configuring Application" -ForegroundColor Yellow

# Update appsettings.json
$appSettingsPath = Join-Path $InstallPath "appsettings.json"

if (Test-Path $appSettingsPath) {
    Write-Host "   Updating appsettings.json..."

    $jsonContent = Get-Content $appSettingsPath -Raw | ConvertFrom-Json

    # Update terminal configuration
    $jsonContent.AgenticOrchestration.Terminal.DefaultCommand = $TerminalExecutable
    $jsonContent.AgenticOrchestration.Terminal.DefaultWorkingDirectory = $WorkingDirectory

    # Update paths to use installation directory
    $jsonContent.AgenticOrchestration.DatabasePath = Join-Path $dataPath "agent-activity.db"
    $jsonContent.AgenticOrchestration.LogsPath = $logsPath
    $jsonContent.AgenticOrchestration.SessionLogging.BasePath = $sessionLogsPath

    # Save updated configuration
    $jsonContent | ConvertTo-Json -Depth 10 | Set-Content $appSettingsPath -Encoding UTF8

    Write-Host "   Configuration updated:" -ForegroundColor Green
    Write-Host "   - Terminal: $TerminalExecutable" -ForegroundColor Green
    Write-Host "   - Working Dir: $WorkingDirectory" -ForegroundColor Green
    Write-Host "   - Database: $(Join-Path $dataPath 'agent-activity.db')" -ForegroundColor Green
    Write-Host "   - Logs: $logsPath" -ForegroundColor Green
}
else {
    Write-Host "   WARNING: appsettings.json not found" -ForegroundColor Yellow
}

Write-Host ""

Write-Host "[4/6] Installing Windows Service" -ForegroundColor Yellow

# Stop and remove existing service if it exists
$serviceName = "HazinaOrchestrator"
$existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($existingService) {
    Write-Host "   Stopping existing service..."
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    Write-Host "   Removing existing service..."
    sc.exe delete $serviceName | Out-Null
    Start-Sleep -Seconds 1
}

# Create new service
Write-Host "   Creating service '$serviceName'..."

$serviceBinary = "`"$exePath`""
$serviceDescription = "Manages Claude Code CLI instances via Hazina framework"

# Create service using sc.exe (more reliable than New-Service for complex configurations)
$createResult = sc.exe create $serviceName binPath= $serviceBinary start= auto DisplayName= "Hazina Orchestration Service" | Out-String

if ($LASTEXITCODE -eq 0) {
    Write-Host "   Service created successfully" -ForegroundColor Green

    # Set description
    sc.exe description $serviceName $serviceDescription | Out-Null

    # Configure service recovery options (restart on failure)
    sc.exe failure $serviceName reset= 86400 actions= restart/60000/restart/60000/restart/60000 | Out-Null

    Write-Host "   Service configured for automatic restart on failure" -ForegroundColor Green
}
else {
    Write-Host "   ERROR: Failed to create service" -ForegroundColor Red
    Write-Host $createResult -ForegroundColor Red
    exit 1
}

Write-Host ""

Write-Host "[5/6] Configuring Firewall" -ForegroundColor Yellow

# Add firewall rule for HTTPS port 5123
$firewallRuleName = "Hazina Orchestration HTTPS"
$existingRule = Get-NetFirewallRule -DisplayName $firewallRuleName -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "   Removing existing firewall rule..."
    Remove-NetFirewallRule -DisplayName $firewallRuleName
}

Write-Host "   Creating firewall rule for port 5123..."
New-NetFirewallRule -DisplayName $firewallRuleName `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5123 `
    -Action Allow `
    -Profile Any `
    -Description "Allows HTTPS access to Hazina Orchestration Service" | Out-Null

Write-Host "   Firewall rule created" -ForegroundColor Green
Write-Host ""

Write-Host "[6/6] Starting Service" -ForegroundColor Yellow

# Start the service
Write-Host "   Starting service..."
Start-Service -Name $serviceName

Start-Sleep -Seconds 3

# Verify service is running
$service = Get-Service -Name $serviceName

if ($service.Status -eq 'Running') {
    Write-Host "   Service started successfully" -ForegroundColor Green
}
else {
    Write-Host "   WARNING: Service status is: $($service.Status)" -ForegroundColor Yellow
    Write-Host "   Check Windows Event Viewer for details" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host "                    INSTALLATION COMPLETE                              " -ForegroundColor Green
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Service Name:    $serviceName" -ForegroundColor Cyan
Write-Host "Service Status:  $($service.Status)" -ForegroundColor Cyan
Write-Host "Install Path:    $InstallPath" -ForegroundColor Cyan
Write-Host "Web Interface:   https://localhost:5123" -ForegroundColor Cyan
Write-Host ""
Write-Host "Authentication:" -ForegroundColor Yellow
Write-Host "   Username: bosi" -ForegroundColor Gray
Write-Host "   Password: Th1s1sSp4rt4!" -ForegroundColor Gray
Write-Host ""
Write-Host "Management Commands:" -ForegroundColor Yellow
Write-Host "   Start Service:   Start-Service $serviceName" -ForegroundColor Gray
Write-Host "   Stop Service:    Stop-Service $serviceName" -ForegroundColor Gray
Write-Host "   Service Status:  Get-Service $serviceName" -ForegroundColor Gray
Write-Host "   View Logs:       Get-Content '$logsPath\startup.log' -Tail 50" -ForegroundColor Gray
Write-Host ""
Write-Host "To uninstall, run: .\uninstall.ps1" -ForegroundColor Yellow
Write-Host ""
