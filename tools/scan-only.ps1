#!/usr/bin/env pwsh
# Just scan - assumes already logged in

$ErrorActionPreference = "Stop"
$bw = "C:\scripts\tools\bw.exe"
$leakedPassword = "3WsXcFr$7YhNmKi*"

Write-Host "Bitwarden Security Scan" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check status
Write-Host "Checking Bitwarden status..." -ForegroundColor Yellow
$status = & $bw status | ConvertFrom-Json

if ($status.status -eq "unauthenticated") {
    Write-Host ""
    Write-Host "ERROR: Not logged in!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run first:" -ForegroundColor Yellow
    Write-Host "  bw login martiendejong2008@gmail.com" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

if ($status.status -eq "locked") {
    Write-Host ""
    Write-Host "ERROR: Vault is locked!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run first:" -ForegroundColor Yellow
    Write-Host "  bw unlock" -ForegroundColor Cyan
    Write-Host "  Then set: `$env:BW_SESSION = '[session key]'" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host "OK: Vault is unlocked" -ForegroundColor Green
Write-Host ""
Write-Host "Fetching all items..." -ForegroundColor Yellow

# Get all items
$items = & $bw list items | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Failed to fetch items" -ForegroundColor Red
    exit 1
}

Write-Host "OK: Got $($items.Count) items" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Scanning for leaked password..." -ForegroundColor Cyan
Write-Host ""

$matches = @()

foreach ($item in $items) {
    if ($item.login -and $item.login.password -eq $leakedPassword) {
        $matches += [PSCustomObject]@{
            Name = $item.name
            Username = $item.login.username
            Uri = if ($item.login.uris) { $item.login.uris[0].uri } else { "Geen URI" }
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan

if ($matches.Count -eq 0) {
    Write-Host ""
    Write-Host "GOED NIEUWS!" -ForegroundColor Green
    Write-Host "Geen accounts gevonden met dit wachtwoord" -ForegroundColor Green
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "!!! KRITIEK: $($matches.Count) ACCOUNT(S) GEVONDEN !!!" -ForegroundColor Red
Write-Host ""
Write-Host "========================================" -ForegroundColor Red

$productionAccounts = @()
$otherAccounts = @()

foreach ($match in $matches) {
    $uri = $match.Uri.ToLower()
    $name = $match.Name.ToLower()

    $isProduction = $uri -match '(prod|api|server|cloud|aws|azure|database|admin)' -or $name -match '(prod|api|server|cloud|aws|azure|database|admin)'

    if ($isProduction) {
        $productionAccounts += $match
    } else {
        $otherAccounts += $match
    }
}

if ($productionAccounts.Count -gt 0) {
    Write-Host ""
    Write-Host "PRODUCTIE ACCOUNTS (HOOGSTE PRIORITEIT):" -ForegroundColor Red
    Write-Host ""
    foreach ($match in $productionAccounts) {
        Write-Host "  [URGENT] $($match.Name)" -ForegroundColor Red
        Write-Host "           User: $($match.Username)" -ForegroundColor Yellow
        Write-Host "           URI:  $($match.Uri)" -ForegroundColor Yellow
        Write-Host ""
    }
}

if ($otherAccounts.Count -gt 0) {
    Write-Host ""
    Write-Host "OVERIGE ACCOUNTS:" -ForegroundColor Yellow
    Write-Host ""
    foreach ($match in $otherAccounts) {
        Write-Host "  [WARNING] $($match.Name)" -ForegroundColor Yellow
        Write-Host "            User: $($match.Username)" -ForegroundColor Gray
        Write-Host "            URI:  $($match.Uri)" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Red

# Save report
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportFile = "C:\scripts\_machine\leaked-password-report-$timestamp.txt"

$report = "BITWARDEN SECURITY SCAN REPORT`n"
$report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$report += "`nTOTAL MATCHES: $($matches.Count)`n"
$report += "- Production accounts: $($productionAccounts.Count)`n"
$report += "- Other accounts: $($otherAccounts.Count)`n`n"
$report += "========================================`n`n"

if ($productionAccounts.Count -gt 0) {
    $report += "PRODUCTION ACCOUNTS (URGENT):`n`n"
    foreach ($match in $productionAccounts) {
        $report += "  Name: $($match.Name)`n"
        $report += "  User: $($match.Username)`n"
        $report += "  URI:  $($match.Uri)`n`n"
    }
}

if ($otherAccounts.Count -gt 0) {
    $report += "OTHER ACCOUNTS:`n`n"
    foreach ($match in $otherAccounts) {
        $report += "  Name: $($match.Name)`n"
        $report += "  User: $($match.Username)`n"
        $report += "  URI:  $($match.Uri)`n`n"
    }
}

$report += "========================================`n"
$report += "`nREQUIRED ACTIONS:`n"
$report += "1. Update ALL passwords IMMEDIATELY`n"
$report += "2. Check production logs for unauthorized access`n"
$report += "3. Enable 2FA where possible`n"
$report += "4. Rotate API keys for production services`n"
$report += "5. Monitor for unusual activity (24-48h)`n"

$report | Out-File $reportFile -Encoding UTF8

Write-Host ""
Write-Host "Report saved: $reportFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "DIRECTE ACTIE VEREIST:" -ForegroundColor Red
Write-Host "1. Update ALLE wachtwoorden NU" -ForegroundColor Yellow
Write-Host "2. Check productie logs" -ForegroundColor Yellow
Write-Host "3. Enable 2FA" -ForegroundColor Yellow
Write-Host ""
