<#
.SYNOPSIS
    One-time migration: populate DPAPI vault from scattered credential sources

.DESCRIPTION
    Reads credentials from CLAUDE.md, credentials.md, clickup-config.json,
    FileZilla sitemanager.xml, and appsettings.Secrets.json.
    Encrypts them into the DPAPI vault. Self-verifying.

.NOTES
    Author: Jengo
    Created: 2026-02-11
    Run once, then delete or archive.
#>

$ErrorActionPreference = "Stop"

$vaultScript = "C:\scripts\tools\vault.ps1"

Write-Host "=== DPAPI Vault Migration ===" -ForegroundColor Cyan
Write-Host ""

$count = 0
$errors = 0

function Store {
    param(
        [string]$Service,
        [string]$Username = "",
        [string]$Password = "",
        [string]$Token = "",
        [string]$Notes = "",
        [string[]]$Tags = @()
    )

    $params = @{
        Action = "set"
        Service = $Service
        Silent = $true
    }
    if ($Username) { $params["Username"] = $Username }
    if ($Password) { $params["Password"] = $Password }
    if ($Token) { $params["Token"] = $Token }
    if ($Notes) { $params["Notes"] = $Notes }
    if ($Tags.Count -gt 0) { $params["Tags"] = $Tags }

    try {
        & $vaultScript @params
        $script:count++
        Write-Host "  [OK] $Service" -ForegroundColor Green
    } catch {
        $script:errors++
        Write-Host "  [FAIL] $Service : $_" -ForegroundColor Red
    }
}

# 1. Orchestration (from CLAUDE.md / quick-context.json)
Write-Host "Migrating credentials..." -ForegroundColor Yellow
Store -Service "orchestration" -Username "bosi" -Password "Th1s1sSp4rt4!" -Tags @("service", "admin")

# 2. Admin (from CLAUDE.md / quick-context.json)
Store -Service "admin" -Username "wreckingball" -Password "Th1s1sSp4rt4!" -Tags @("admin")

# 3. ClickUp API key (from clickup-config.json)
$clickupConfig = Get-Content "C:\scripts\_machine\clickup-config.json" -Raw | ConvertFrom-Json
$clickupKey = $clickupConfig.api_key
Store -Service "clickup" -Token $clickupKey -Tags @("api")

# 4. SMTP (from credentials.md)
Store -Service "smtp" -Username "info@martiendejong.nl" -Password "Voy@%JzV4*E2Hox!" -Notes "Host: mail.zxcs.nl, Port: 587 (TLS) or 465 (SSL)" -Tags @("email")

# 5. IMAP (from credentials.md)
Store -Service "imap" -Username "info@martiendejong.nl" -Password "hLPFy6MdUnfEDbYTwXps" -Notes "Host: mail.zxcs.nl, Port: 993 (SSL). Different password from SMTP!" -Tags @("email")

# 6. Email Brand2Boost (from credentials.md)
Store -Service "email-brand2boost" -Username "account@brand2boost.com" -Password "WmQZZNX7E2sWfFXrmhEn" -Notes "Host: mail.brand2boost.com" -Tags @("email")

# 7. Email Prospergenics (from credentials.md)
Store -Service "email-prospergenics" -Username "brandmanager@prospergenics.com" -Password "KeMgxLxZYtg9A5nc6zrw" -Notes "Host: mail.prospergenics.com" -Tags @("email")

# 8. WordPress martiendejong.nl (from credentials.md)
Store -Service "wordpress-martiendejong" -Username "admin" -Password "UtCI Mgr9 13EB mlBL 2S1L AY2e" -Notes "Application password for REST API. Site: https://martiendejong.nl/wp-admin/" -Tags @("admin", "api")

# 9. FTP Art Revisionist (from FileZilla sitemanager.xml - base64 decode)
$ftpPassB64 = "PzpqTzg7VHJTRlFBdHNEM2NgSU10ew=="
$ftpPassBytes = [Convert]::FromBase64String($ftpPassB64)
$ftpPass = [System.Text.Encoding]::UTF8.GetString($ftpPassBytes)
Store -Service "ftp-artrevisionist" -Username "u63291p434771" -Password $ftpPass -Notes "Host: artrevisionist.com, Port: 21, FTP" -Tags @("ftp", "deployment")

# 10. OpenAI (from appsettings.Secrets.json)
$openaiKey = "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"
Store -Service "openai" -Token $openaiKey -Notes "Service account key, used across client-manager, hazina, orchestration" -Tags @("api", "ai")

Write-Host ""
Write-Host "=== Migration Complete ===" -ForegroundColor Cyan
Write-Host "  Stored: $count" -ForegroundColor Green
if ($errors -gt 0) {
    Write-Host "  Errors: $errors" -ForegroundColor Red
}

# Self-verification: decrypt clickup token and check prefix
Write-Host ""
Write-Host "Verifying..." -ForegroundColor Yellow
$verifyToken = & $vaultScript -Action get -Service "clickup" -Field token -Silent
if ($verifyToken -like "pk_74525428_*") {
    Write-Host "  [OK] ClickUp token roundtrip verified (prefix: pk_74525428_)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] ClickUp token verification failed: $verifyToken" -ForegroundColor Red
}

$verifyPass = & $vaultScript -Action get -Service "smtp" -Field password -Silent
if ($verifyPass -eq "Voy@%JzV4*E2Hox!") {
    Write-Host "  [OK] SMTP password roundtrip verified (special chars intact)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] SMTP password verification failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "Done. Run 'vault.ps1 -Action list' to see all entries." -ForegroundColor Cyan
