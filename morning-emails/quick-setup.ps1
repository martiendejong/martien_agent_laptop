#Requires -Version 5.1

<#
.SYNOPSIS
    Quick setup script for Morning Email Briefing

.DESCRIPTION
    Automates the initial setup process:
    1. Install Node.js dependencies
    2. Install Python edge-tts (optional)
    3. Create .env file
    4. Guide through OAuth setup
    5. Test the system
    6. Optionally register scheduled task

.EXAMPLE
    .\quick-setup.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ScriptDir = $PSScriptRoot

Write-Host ""
Write-Host "=== Morning Email Briefing - Quick Setup ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Install Node.js dependencies
Write-Host "[1/6] Installing Node.js dependencies..." -ForegroundColor Yellow
Push-Location $ScriptDir
try {
    if (Test-Path "node_modules") {
        Write-Host "  ✓ Dependencies already installed" -ForegroundColor Green
    } else {
        npm install
        Write-Host "  ✓ Dependencies installed" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to install dependencies: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# Step 2: Install Python edge-tts
Write-Host ""
Write-Host "[2/6] Checking Python and edge-tts..." -ForegroundColor Yellow

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}

if ($pythonCmd) {
    Write-Host "  ✓ Python found: $($pythonCmd.Version)" -ForegroundColor Green

    # Check if edge-tts installed
    $edgeTtsCheck = & $pythonCmd.Source -c "import edge_tts" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ edge-tts already installed" -ForegroundColor Green
    } else {
        Write-Host "  Installing edge-tts..." -ForegroundColor Gray
        $installChoice = Read-Host "  Install edge-tts for better voice quality? (Y/n)"
        if ($installChoice -ne 'n') {
            & pip install edge-tts
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ edge-tts installed" -ForegroundColor Green
            } else {
                Write-Host "  ⚠ edge-tts installation failed (will use Windows TTS fallback)" -ForegroundColor Yellow
            }
        }
    }
} else {
    Write-Host "  ⚠ Python not found (will use Windows TTS fallback)" -ForegroundColor Yellow
}

# Step 3: Create .env file
Write-Host ""
Write-Host "[3/6] Creating .env configuration..." -ForegroundColor Yellow

$envPath = Join-Path $ScriptDir ".env"
if (Test-Path $envPath) {
    Write-Host "  ✓ .env already exists" -ForegroundColor Green
} else {
    Copy-Item (Join-Path $ScriptDir ".env.example") $envPath
    Write-Host "  ✓ .env created from template" -ForegroundColor Green
}

# Step 4: Guide through OAuth setup
Write-Host ""
Write-Host "[4/6] Gmail OAuth Setup" -ForegroundColor Yellow
Write-Host ""
Write-Host "You need Gmail OAuth credentials to access your email." -ForegroundColor Gray
Write-Host ""
Write-Host "Options:" -ForegroundColor Cyan
Write-Host "  A) Use existing Gmail MCP credentials (if you have them)" -ForegroundColor White
Write-Host "  B) Create new OAuth credentials from Google Cloud Console" -ForegroundColor White
Write-Host "  C) Skip for now (setup manually later)" -ForegroundColor White
Write-Host ""

$oauthChoice = Read-Host "Choose option (A/B/C)"

switch ($oauthChoice.ToUpper()) {
    'A' {
        Write-Host ""
        $gmcpPath = Read-Host "  Enter path to Gmail MCP credentials.json"
        if (Test-Path $gmcpPath) {
            # Update .env
            $envContent = Get-Content $envPath -Raw
            $envContent = $envContent -replace 'GMAIL_CREDENTIALS_PATH=.*', "GMAIL_CREDENTIALS_PATH=$gmcpPath"
            $envContent = $envContent -replace 'GMAIL_TOKEN_PATH=.*', "GMAIL_TOKEN_PATH=$([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($gmcpPath), 'token.json'))"
            Set-Content -Path $envPath -Value $envContent
            Write-Host "  ✓ .env updated with Gmail MCP paths" -ForegroundColor Green
        } else {
            Write-Host "  ✗ File not found: $gmcpPath" -ForegroundColor Red
        }
    }
    'B' {
        Write-Host ""
        Write-Host "  Follow these steps:" -ForegroundColor Cyan
        Write-Host "  1. Go to https://console.cloud.google.com/" -ForegroundColor White
        Write-Host "  2. Create a project or select existing" -ForegroundColor White
        Write-Host "  3. Enable Gmail API" -ForegroundColor White
        Write-Host "  4. Create OAuth 2.0 credentials (Desktop app)" -ForegroundColor White
        Write-Host "  5. Download JSON and save as: $ScriptDir\credentials.json" -ForegroundColor White
        Write-Host ""
        Read-Host "  Press Enter when credentials.json is ready"

        if (Test-Path (Join-Path $ScriptDir "credentials.json")) {
            Write-Host "  ✓ credentials.json found" -ForegroundColor Green
            Write-Host "  Running OAuth setup..." -ForegroundColor Gray
            node (Join-Path $ScriptDir "setup-oauth.js")
        } else {
            Write-Host "  ✗ credentials.json not found" -ForegroundColor Red
        }
    }
    'C' {
        Write-Host "  Skipped. Run 'node setup-oauth.js' manually when ready." -ForegroundColor Yellow
    }
}

# Step 5: Test the system
Write-Host ""
Write-Host "[5/6] Testing the system..." -ForegroundColor Yellow

$testChoice = Read-Host "  Run test now? (Y/n)"
if ($testChoice -ne 'n') {
    & (Join-Path $ScriptDir "morning-briefing.ps1") -Test -Silent
}

# Step 6: Register scheduled task
Write-Host ""
Write-Host "[6/6] Scheduled Task Registration" -ForegroundColor Yellow
Write-Host ""

$taskChoice = Read-Host "  Register scheduled task to run on login? (Y/n)"
if ($taskChoice -ne 'n') {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        & (Join-Path $ScriptDir "register-scheduled-task.ps1")
    } else {
        Write-Host "  ⚠ Administrator rights required for scheduled task registration" -ForegroundColor Yellow
        Write-Host "  Run this command as administrator:" -ForegroundColor Gray
        Write-Host "    .\register-scheduled-task.ps1" -ForegroundColor White
    }
}

# Done
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  • Test manually: .\morning-briefing.ps1 -Test" -ForegroundColor White
Write-Host "  • View logs: Get-Content briefing.log -Tail 20" -ForegroundColor White
Write-Host "  • See README.md for full documentation" -ForegroundColor White
Write-Host ""
