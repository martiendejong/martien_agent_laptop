#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Find all Bitwarden accounts using a leaked password
.DESCRIPTION
    Uses Bitwarden CLI to search for accounts with a specific password
    SECURITY: Run this, then IMMEDIATELY delete the export file
.EXAMPLE
    .\check-leaked-password.ps1 -LeakedPassword "MyOldPassword123"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$LeakedPassword,

    [Parameter(Mandatory=$false)]
    [switch]$Interactive
)

$ErrorActionPreference = "Stop"

# Set bw path
$bw = "C:\scripts\tools\bw.exe"

# Check if bw CLI is installed
if (-not (Test-Path $bw)) {
    Write-Host "❌ Bitwarden CLI niet gevonden op: $bw" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run eerst: .\bw-quick-login.ps1" -ForegroundColor Yellow
    exit 1
}

# Get password securely if not provided
if (-not $LeakedPassword) {
    Write-Host "🔐 Voer het gelekte wachtwoord in (wordt niet getoond):" -ForegroundColor Cyan
    $SecurePassword = Read-Host -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $LeakedPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
}

Write-Host ""
Write-Host "🔍 Stap 1: Bitwarden sessie starten..." -ForegroundColor Cyan

# Check if already logged in
$status = & $bw status | ConvertFrom-Json
if ($status.status -eq "unauthenticated") {
    Write-Host "⚠️  Niet ingelogd. Run eerst: .\bw-quick-login.ps1" -ForegroundColor Yellow
    exit 1
}

# Unlock if needed
if ($status.status -eq "locked") {
    Write-Host "🔓 Vault is locked. Unlock nu..." -ForegroundColor Yellow
    $session = & $bw unlock --raw
    $env:BW_SESSION = $session
} else {
    Write-Host "✅ Vault is unlocked" -ForegroundColor Green
}

Write-Host ""
Write-Host "📥 Stap 2: Bitwarden items ophalen..." -ForegroundColor Cyan

# Export to temp file
$tempFile = Join-Path $env:TEMP "bw-export-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$items = & $bw list items | ConvertFrom-Json

Write-Host "✅ $($items.Count) items opgehaald" -ForegroundColor Green

Write-Host ""
Write-Host "🔎 Stap 3: Zoeken naar matches..." -ForegroundColor Cyan

$matches = @()

foreach ($item in $items) {
    if ($item.login -and $item.login.password -eq $LeakedPassword) {
        $matches += [PSCustomObject]@{
            Name = $item.name
            Username = $item.login.username
            Uri = if ($item.login.uris) { $item.login.uris[0].uri } else { "Geen URI" }
            FolderId = $item.folderId
        }
    }
}

Write-Host ""
if ($matches.Count -eq 0) {
    Write-Host "✅ GOED NIEUWS: Geen accounts gevonden met dit wachtwoord" -ForegroundColor Green
    exit 0
}

Write-Host "⚠️  GEVONDEN: $($matches.Count) account(s) gebruiken dit wachtwoord" -ForegroundColor Red
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red

foreach ($match in $matches) {
    Write-Host ""
    Write-Host "🔴 $($match.Name)" -ForegroundColor Red
    Write-Host "   Username: $($match.Username)" -ForegroundColor Yellow
    Write-Host "   URI: $($match.Uri)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red

# Save to file
$reportFile = "C:\scripts\_machine\leaked-password-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$matches | Format-List | Out-File $reportFile -Encoding UTF8

Write-Host ""
Write-Host "📄 Rapport opgeslagen: $reportFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚡ ACTIE VEREIST:" -ForegroundColor Red
Write-Host "1. Wijzig deze wachtwoorden ONMIDDELLIJK" -ForegroundColor Yellow
Write-Host "2. Check productie omgevingen op ongeautoriseerde toegang" -ForegroundColor Yellow
Write-Host "3. Overweeg 2FA inschakelen waar mogelijk" -ForegroundColor Yellow
Write-Host ""

# Offer to open Bitwarden vault
Write-Host "Wil je Bitwarden vault openen om te updaten? (j/n): " -NoNewline -ForegroundColor Cyan
$response = Read-Host
if ($response -eq 'j') {
    Start-Process "https://vault.bitwarden.com"
}
