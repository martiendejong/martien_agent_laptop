<#
.SYNOPSIS
    Build Hazina Orchestration installer package

.DESCRIPTION
    Creates a distributable installer package containing:
    - HazinaOrchestration.exe and all dependencies
    - install.ps1 (PowerShell installer script)
    - uninstall.ps1 (PowerShell uninstaller script)
    - README.txt (installation instructions)

.PARAMETER SourcePath
    Path to the orchestration build (default: C:\stores\orchestration)

.PARAMETER OutputPath
    Output directory for installer package (default: .\output)

.PARAMETER CreateMSI
    If specified, attempts to create an MSI package (requires WiX)

.EXAMPLE
    .\build-installer.ps1
    Creates installer package in .\output\

.EXAMPLE
    .\build-installer.ps1 -SourcePath "C:\custom\path" -OutputPath "C:\dist"
    Custom source and output paths
#>

param(
    [string]$SourcePath = "C:\stores\orchestration",
    [string]$OutputPath = ".\output",
    [switch]$CreateMSI
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "      HAZINA ORCHESTRATION - Installer Builder                         " -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host ""

# Verify source exists
if (-not (Test-Path $SourcePath)) {
    Write-Host "ERROR: Source path not found: $SourcePath" -ForegroundColor Red
    exit 1
}

$sourceExe = Join-Path $SourcePath "HazinaOrchestration.exe"
if (-not (Test-Path $sourceExe)) {
    Write-Host "ERROR: HazinaOrchestration.exe not found in $SourcePath" -ForegroundColor Red
    exit 1
}

# Create output directory
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$packageDir = Join-Path $OutputPath "package"
if (Test-Path $packageDir) {
    Remove-Item -Path $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null

Write-Host "[1/4] Copying Application Files" -ForegroundColor Yellow
Write-Host "   Source: $SourcePath"
Write-Host "   Destination: $packageDir"
Write-Host ""

# Copy all orchestration files
Copy-Item -Path "$SourcePath\*" -Destination $packageDir -Recurse -Force -Exclude @('*.log', '*.db', '*.db-shm', '*.db-wal')

# Copy installer scripts
Copy-Item -Path "$PSScriptRoot\install.ps1" -Destination $packageDir -Force
Copy-Item -Path "$PSScriptRoot\uninstall.ps1" -Destination $packageDir -Force

$fileInfo = Get-Item (Join-Path $packageDir "HazinaOrchestration.exe")
$sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
Write-Host "   Copied HazinaOrchestration.exe ($sizeMB MB)" -ForegroundColor Green

Write-Host ""
Write-Host "[2/4] Creating README" -ForegroundColor Yellow

$readmeContent = @"
======================================================================
          HAZINA ORCHESTRATION SERVICE - INSTALLATION
======================================================================

REQUIREMENTS:
  - Windows 10/11 or Windows Server 2016+
  - Administrator privileges
  - .NET Runtime (included in single-file executable)

INSTALLATION:
  1. Right-click install.ps1
  2. Select "Run with PowerShell"
  3. Approve administrator prompt
  4. Follow the interactive prompts

  SILENT INSTALLATION:
    .\install.ps1 -TerminalExecutable "C:\scripts\claude_agent.bat" -WorkingDirectory "C:\scripts" -Silent

  CUSTOM INSTALLATION PATH:
    .\install.ps1 -InstallPath "C:\CustomPath\Hazina"

UNINSTALLATION:
  1. Right-click uninstall.ps1
  2. Select "Run with PowerShell"
  3. Follow the prompts

  SILENT UNINSTALL (remove all data):
    .\uninstall.ps1 -RemoveData -Silent

POST-INSTALLATION:
  - Service Name: HazinaOrchestrator
  - Web Interface: https://localhost:5123
  - Default Username: bosi
  - Default Password: Th1s1sSp4rt4!

CONFIGURATION:
  Edit: <InstallPath>\appsettings.json
  After changes, restart service:
    Restart-Service HazinaOrchestrator

LOGS:
  - Startup: <InstallPath>\logs\startup.log
  - Sessions: <InstallPath>\logs\agent-sessions\

SERVICE MANAGEMENT:
  Start:    Start-Service HazinaOrchestrator
  Stop:     Stop-Service HazinaOrchestrator
  Status:   Get-Service HazinaOrchestrator
  Restart:  Restart-Service HazinaOrchestrator

FIREWALL:
  Port 5123 (HTTPS) is automatically opened during installation.

SUPPORT:
  For issues, check:
    1. Windows Event Viewer (Application logs)
    2. <InstallPath>\logs\startup.log
    3. Service status: Get-Service HazinaOrchestrator | Format-List *

======================================================================
         Built with Hazina Framework - $(Get-Date -Format 'yyyy-MM-dd')
======================================================================
"@

Set-Content -Path (Join-Path $packageDir "README.txt") -Value $readmeContent -Encoding UTF8
Write-Host "   Created README.txt" -ForegroundColor Green

Write-Host ""
Write-Host "[3/4] Creating Installer Archive" -ForegroundColor Yellow

$version = "1.0.0"
$archiveName = "HazinaOrchestration-v$version-Installer.zip"
$archivePath = Join-Path $OutputPath $archiveName

if (Test-Path $archivePath) {
    Remove-Item -Path $archivePath -Force
}

Write-Host "   Creating archive: $archiveName"
Compress-Archive -Path "$packageDir\*" -DestinationPath $archivePath -CompressionLevel Optimal -Force

$archiveInfo = Get-Item $archivePath
$archiveSizeMB = [math]::Round($archiveInfo.Length / 1MB, 2)

Write-Host "   Archive created ($archiveSizeMB MB)" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Creating Self-Extracting Installer" -ForegroundColor Yellow

# Create IExpress configuration file for self-extracting installer
$sedFile = Join-Path $OutputPath "installer-config.sed"
$installerExe = Join-Path $OutputPath "HazinaOrchestration-v$version-Setup.exe"

$sedContent = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=0
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles
[Strings]
InstallPrompt=Install Hazina Orchestration Service?
DisplayLicense=
FinishMessage=Installation package extracted. Please run install.ps1 to complete installation.
TargetName=$installerExe
FriendlyName=Hazina Orchestration Installer v$version
AppLaunched=cmd /c explorer.exe .
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="HazinaOrchestration-v$version-Installer.zip"
[SourceFiles]
SourceFiles0=$OutputPath
[SourceFiles0]
%FILE0%=
"@

# Note: IExpress doesn't support ZIP files well, so we'll create a note instead
Write-Host "   Self-extracting EXE requires manual creation with IExpress" -ForegroundColor Gray
Write-Host "   Archive is ready for distribution: $archiveName" -ForegroundColor Green

# Clean up package directory
Remove-Item -Path $packageDir -Recurse -Force

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host "                    BUILD COMPLETE                                     " -ForegroundColor Green
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output Files:" -ForegroundColor Cyan
Write-Host "   $archivePath" -ForegroundColor White
Write-Host "   Size: $archiveSizeMB MB" -ForegroundColor Gray
Write-Host ""
Write-Host "Distribution Instructions:" -ForegroundColor Yellow
Write-Host "   1. Share the ZIP file with users" -ForegroundColor Gray
Write-Host "   2. Users extract the ZIP to a folder" -ForegroundColor Gray
Write-Host "   3. Users right-click install.ps1 and select 'Run with PowerShell'" -ForegroundColor Gray
Write-Host "   4. Installation proceeds with interactive prompts" -ForegroundColor Gray
Write-Host ""
Write-Host "Silent Installation Example:" -ForegroundColor Yellow
Write-Host "   .\install.ps1 -TerminalExecutable 'C:\scripts\claude_agent.bat' -Silent" -ForegroundColor Gray
Write-Host ""

if ($CreateMSI) {
    Write-Host "[OPTIONAL] Creating MSI Package" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   MSI creation requires WiX Toolset" -ForegroundColor Gray
    Write-Host "   This feature is not yet implemented" -ForegroundColor Yellow
    Write-Host "   The ZIP installer is recommended for now" -ForegroundColor Gray
    Write-Host ""
}
