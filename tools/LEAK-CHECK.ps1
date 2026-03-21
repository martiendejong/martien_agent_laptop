#!/usr/bin/env pwsh
# Interactive Bitwarden Leak Check
# Right-click -> Run with PowerShell

$ErrorActionPreference = "Continue"
Set-Location "C:\scripts\tools"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BITWARDEN SECURITY CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Email: martiendejong2008@gmail.com" -ForegroundColor Yellow
Write-Host ""

# Step 1: Login
Write-Host "STAP 1: Login bij Bitwarden" -ForegroundColor Yellow
Write-Host "Je master password wordt gevraagd..." -ForegroundColor Gray
Write-Host ""

& ".\bw.exe" login martiendejong2008@gmail.com

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Login gefaald. Mogelijk al ingelogd?" -ForegroundColor Yellow
    Write-Host "Probeer unlock..." -ForegroundColor Yellow
}

Write-Host ""

# Step 2: Unlock
Write-Host "STAP 2: Vault unlocken" -ForegroundColor Yellow
Write-Host ""

$session = & ".\bw.exe" unlock --raw

if ($session -and $session.Length -gt 0) {
    $env:BW_SESSION = $session
    Write-Host "OK: Vault unlocked!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Unlock failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Druk op ENTER om af te sluiten..." -ForegroundColor Gray
    Read-Host
    exit 1
}

Write-Host ""

# Step 3: Scan
Write-Host "STAP 3: Scannen voor gelekt wachtwoord" -ForegroundColor Yellow
Write-Host ""

& ".\scan-only.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Druk op ENTER om af te sluiten..." -ForegroundColor Gray
Read-Host
