#!/usr/bin/env pwsh
# Automated leak check for Martien

$ErrorActionPreference = "Stop"
$bw = "C:\scripts\tools\bw.exe"

$email = "martiendejong2008@gmail.com"
$leakedPassword = "3WsXcFr$7YhNmKi*"

Write-Host "Bitwarden Security Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check status
$status = & $bw status | ConvertFrom-Json

if ($status.status -eq "unauthenticated") {
    Write-Host "Login vereist voor: $email" -ForegroundColor Yellow
    Write-Host ""
    & $bw login $email

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Login failed" -ForegroundColor Red
        exit 1
    }

    # Get status again
    $status = & $bw status | ConvertFrom-Json
}

# Unlock if needed
if ($status.status -eq "locked") {
    Write-Host "Vault unlocking..." -ForegroundColor Cyan
    $session = & $bw unlock --raw

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Unlock failed" -ForegroundColor Red
        exit 1
    }

    $env:BW_SESSION = $session
}

Write-Host "OK: Authenticated!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Scanning for leaked password..." -ForegroundColor Cyan
Write-Host ""

# Get all items
$items = & $bw list items | ConvertFrom-Json

Write-Host "Scanning $($items.Count) items..." -ForegroundColor Yellow

$matches = @()

foreach ($item in $items) {
    if ($item.login -and $item.login.password -eq $leakedPassword) {
        $matches += [PSCustomObject]@{
            Name = $item.name
            Username = $item.login.username
            Uri = if ($item.login.uris) { $item.login.uris[0].uri } else { "Geen URI" }
            FolderId = $item.folderId
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($matches.Count -eq 0) {
    Write-Host ""
    Write-Host "GOED NIEUWS!" -ForegroundColor Green
    Write-Host "Geen accounts gevonden met dit wachtwoord" -ForegroundColor Green
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "KRITIEK: $($matches.Count) ACCOUNT(S) GEVONDEN" -ForegroundColor Red
Write-Host ""
Write-Host "========================================" -ForegroundColor Red

$productionAccounts = @()
$otherAccounts = @()

foreach ($match in $matches) {
    # Check if it's likely a production account
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
        Write-Host "  [!] $($match.Name)" -ForegroundColor Red
        Write-Host "      User: $($match.Username)" -ForegroundColor Yellow
        Write-Host "      URI:  $($match.Uri)" -ForegroundColor Yellow
        Write-Host ""
    }
    Write-Host "========================================" -ForegroundColor Red
}

if ($otherAccounts.Count -gt 0) {
    Write-Host ""
    Write-Host "OVERIGE ACCOUNTS:" -ForegroundColor Yellow
    Write-Host ""
    foreach ($match in $otherAccounts) {
        Write-Host "  [-] $($match.Name)" -ForegroundColor Yellow
        Write-Host "      User: $($match.Username)" -ForegroundColor Gray
        Write-Host "      URI:  $($match.Uri)" -ForegroundColor Gray
        Write-Host ""
    }
}

# Save report
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportFile = "C:\scripts\_machine\leaked-password-report-$timestamp.txt"

$report = "BITWARDEN SECURITY SCAN REPORT`n"
$report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$report += "Email: $email`n"
$report += "Leaked Password: *** (redacted)`n"
$report += "`n"
$report += "TOTAL MATCHES: $($matches.Count)`n"
$report += "- Production accounts: $($productionAccounts.Count)`n"
$report += "- Other accounts: $($otherAccounts.Count)`n"
$report += "`n"
$report += "========================================`n"
$report += "`n"
$report += "PRODUCTION ACCOUNTS (URGENT):`n"

foreach ($match in $productionAccounts) {
    $report += "`n"
    $report += "- Name: $($match.Name)`n"
    $report += "  Username: $($match.Username)`n"
    $report += "  URI: $($match.Uri)`n"
}

$report += "`n`n"
$report += "OTHER ACCOUNTS:`n"

foreach ($match in $otherAccounts) {
    $report += "`n"
    $report += "- Name: $($match.Name)`n"
    $report += "  Username: $($match.Username)`n"
    $report += "  URI: $($match.Uri)`n"
}

$report += "`n`n"
$report += "========================================`n"
$report += "`n"
$report += "REQUIRED ACTIONS:`n"
$report += "1. Update ALL passwords listed above IMMEDIATELY`n"
$report += "2. Check production logs for unauthorized access`n"
$report += "3. Enable 2FA where possible`n"
$report += "4. Consider rotating API keys/tokens for production services`n"
$report += "5. Monitor for unusual activity in next 24-48 hours`n"
$report += "`n"
$report += "========================================`n"

$report | Out-File $reportFile -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Rapport opgeslagen: $reportFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "DIRECTE ACTIE VEREIST:" -ForegroundColor Red
Write-Host ""
Write-Host "  1. Update ALLE bovenstaande wachtwoorden NU" -ForegroundColor Yellow
Write-Host "  2. Check productie logs voor verdachte toegang" -ForegroundColor Yellow
Write-Host "  3. Schakel 2FA in waar mogelijk" -ForegroundColor Yellow
Write-Host "  4. Roteer API keys voor productie services" -ForegroundColor Yellow
Write-Host ""

# Offer to open Bitwarden
Write-Host "Bitwarden vault openen om te updaten? (j/n): " -NoNewline -ForegroundColor Cyan
$response = Read-Host
if ($response -eq 'j') {
    Start-Process "https://vault.bitwarden.com"
}

Write-Host ""
Write-Host "Scan compleet" -ForegroundColor Green
