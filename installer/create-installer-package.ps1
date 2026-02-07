<#
.SYNOPSIS
    Create minimal installer package for Hazina Orchestration

.DESCRIPTION
    Creates a ZIP package with installer scripts (not full copy of files).
    Users extract and run install.ps1 which copies from source location.
#>

param(
    [string]$SourcePath = "C:\stores\orchestration",
    [string]$OutputPath = "$env:USERPROFILE\Downloads"
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "      HAZINA ORCHESTRATION - Minimal Installer Package                 " -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host ""

# Verify source
if (-not (Test-Path (Join-Path $SourcePath "HazinaOrchestration.exe"))) {
    Write-Host "ERROR: HazinaOrchestration.exe not found in $SourcePath" -ForegroundColor Red
    exit 1
}

$version = "1.0.0"
$packageName = "HazinaOrchestration-v$version-Installer"
$zipPath = Join-Path $OutputPath "$packageName.zip"

Write-Host "[1/3] Creating temporary package structure" -ForegroundColor Yellow

$tempDir = Join-Path $env:TEMP $packageName
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Copy installer scripts
$installerDir = "C:\scripts\installer\HazinaOrchestration"
Copy-Item -Path (Join-Path $installerDir "install.ps1") -Destination $tempDir
Copy-Item -Path (Join-Path $installerDir "uninstall.ps1") -Destination $tempDir

# Create modified install script that references source path
$installScript = Get-Content (Join-Path $tempDir "install.ps1") -Raw
$installScript = $installScript -replace '\$SourceDir = \$PSScriptRoot', "`$SourceDir = '$SourcePath'"
Set-Content -Path (Join-Path $tempDir "install.ps1") -Value $installScript

Write-Host "   Installer scripts prepared" -ForegroundColor Green

# Create README
$readme = @"
======================================================================
          HAZINA ORCHESTRATION SERVICE - INSTALLER v$version
======================================================================

WHAT'S INCLUDED:
  - install.ps1: PowerShell installer script
  - uninstall.ps1: PowerShell uninstaller script
  - This README

SOURCE FILES:
  The installer will copy files from: $SourcePath
  Ensure this path is accessible during installation.

INSTALLATION:
  1. Extract this ZIP to any folder
  2. Right-click install.ps1
  3. Select "Run with PowerShell"
  4. Approve administrator prompt
  5. Follow interactive prompts

CUSTOM INSTALLATION:
  .\install.ps1 -InstallPath "C:\MyPath" -TerminalExecutable "C:\scripts\claude_agent.bat"

POST-INSTALLATION:
  - Service: HazinaOrchestrator
  - Web UI: https://localhost:5123
  - Username: bosi
  - Password: Th1s1sSp4rt4!

UNINSTALLATION:
  Run: .\uninstall.ps1

======================================================================
"@

Set-Content -Path (Join-Path $tempDir "README.txt") -Value $readme

Write-Host ""
Write-Host "[2/3] Creating ZIP package" -ForegroundColor Yellow

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

$zipInfo = Get-Item $zipPath
$zipSizeKB = [math]::Round($zipInfo.Length / 1KB, 2)

Write-Host "   Package created: $zipSizeKB KB" -ForegroundColor Green

# Cleanup
Remove-Item -Path $tempDir -Recurse -Force

Write-Host ""
Write-Host "[3/3] Creating installation instructions" -ForegroundColor Yellow

$instructionsPath = Join-Path $OutputPath "$packageName-Instructions.txt"

$instructions = @"
======================================================================
HAZINA ORCHESTRATION - INSTALLATION INSTRUCTIONS
======================================================================

PACKAGE: $packageName.zip
VERSION: $version
DATE: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

DISTRIBUTION STEPS:
------------------

1. SHARE THE ZIP FILE:
   Location: $zipPath
   Size: $zipSizeKB KB

2. USER EXTRACTS ZIP:
   - Right-click ZIP file
   - Select "Extract All..."
   - Choose destination folder

3. USER RUNS INSTALLER:
   - Navigate to extracted folder
   - Right-click "install.ps1"
   - Select "Run with PowerShell"
   - Click "Yes" on UAC prompt
   - Follow interactive prompts

4. SILENT INSTALLATION (Optional):
   Open PowerShell as Administrator and run:

   .\install.ps1 -TerminalExecutable "C:\path\to\terminal.exe" -WorkingDirectory "C:\workdir" -Silent

VERIFICATION:
------------
After installation:
  - Service should be running: Get-Service HazinaOrchestrator
  - Web UI accessible at: https://localhost:5123
  - Login with: bosi / Th1s1sSp4rt4!

REQUIREMENTS:
------------
  - Windows 10/11 or Server 2016+
  - Administrator privileges
  - Source files must be accessible at: $SourcePath

SUPPORT:
-------
  - Check service: Get-Service HazinaOrchestrator | Format-List *
  - View logs: Get-Content "C:\Program Files\Hazina Framework\Hazina Orchestration\logs\startup.log" -Tail 50
  - Event Viewer: Application logs

======================================================================
"@

Set-Content -Path $instructionsPath -Value $instructions

Write-Host "   Instructions created" -ForegroundColor Green

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host "                    PACKAGE COMPLETE                                   " -ForegroundColor Green
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output Files:" -ForegroundColor Cyan
Write-Host "  1. Installer: $zipPath ($zipSizeKB KB)" -ForegroundColor White
Write-Host "  2. Instructions: $instructionsPath" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  - Share the ZIP file with users"
Write-Host "  - Ensure source files remain at: $SourcePath"
Write-Host "  - Or rebuild from orchestration source for standalone package"
Write-Host ""
