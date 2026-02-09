#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Secure credentials vault using Windows DPAPI encryption

.DESCRIPTION
    Stores and retrieves credentials encrypted with Windows Data Protection API.
    Credentials are user-scoped and machine-scoped (cannot be decrypted by other users or on other machines).

.PARAMETER Action
    Action to perform: get, set, list, rotate, delete

.PARAMETER Service
    Service name (e.g., "github", "clickup", "gmail")

.PARAMETER Username
    Username for the service (used with 'set')

.PARAMETER Password
    Password for the service (used with 'set')

.PARAMETER Token
    API token for the service (alternative to username/password)

.PARAMETER Notes
    Optional notes (2FA codes, recovery keys, etc.)

.EXAMPLE
    .\vault.ps1 -Action set -Service "github" -Token "ghp_xxx"

.EXAMPLE
    .\vault.ps1 -Action get -Service "github"

.EXAMPLE
    .\vault.ps1 -Action list

.EXAMPLE
    .\vault.ps1 -Action rotate -Service "github"

.EXAMPLE
    .\vault.ps1 -Action delete -Service "github"

.NOTES
    Author: Jengo
    Created: 2026-02-09
    ROI: 8.0
    Encryption: DPAPI (user-scoped, machine-scoped)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("get", "set", "list", "rotate", "delete")]
    [string]$Action,

    [Parameter(Mandatory = $false)]
    [string]$Service = "",

    [Parameter(Mandatory = $false)]
    [string]$Username = "",

    [Parameter(Mandatory = $false)]
    [string]$Password = "",

    [Parameter(Mandatory = $false)]
    [string]$Token = "",

    [Parameter(Mandatory = $false)]
    [string]$Notes = ""
)

$ErrorActionPreference = "Stop"

$vaultFile = "C:\scripts\_machine\vault.encrypted.json"

# Encryption helpers using DPAPI
function Protect-Secret {
    param([string]$PlainText)

    if ([string]::IsNullOrEmpty($PlainText)) {
        return ""
    }

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $encryptedBytes = [System.Security.Cryptography.ProtectedData]::Protect(
        $bytes,
        $null,
        [System.Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    return [Convert]::ToBase64String($encryptedBytes)
}

function Unprotect-Secret {
    param([string]$EncryptedText)

    if ([string]::IsNullOrEmpty($EncryptedText)) {
        return ""
    }

    try {
        $encryptedBytes = [Convert]::FromBase64String($EncryptedText)
        $bytes = [System.Security.Cryptography.ProtectedData]::Unprotect(
            $encryptedBytes,
            $null,
            [System.Security.Cryptography.DataProtectionScope]::CurrentUser
        )
        return [System.Text.Encoding]::UTF8.GetString($bytes)
    } catch {
        Write-Host "⚠️  Failed to decrypt: $_" -ForegroundColor Yellow
        return "[DECRYPTION FAILED]"
    }
}

# Load or create vault
function Load-Vault {
    if (Test-Path $vaultFile) {
        $content = Get-Content $vaultFile -Raw | ConvertFrom-Json
        return @($content.credentials)
    } else {
        return @()
    }
}

function Save-Vault {
    param([array]$Credentials)

    $vaultData = @{
        version = "1.0"
        encrypted_with = "DPAPI"
        scope = "CurrentUser"
        updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        credentials = $Credentials
    }

    $vaultData | ConvertTo-Json -Depth 10 | Out-File -FilePath $vaultFile -Encoding UTF8
}

# === ACTION: LIST ===
if ($Action -eq "list") {
    $vault = Load-Vault

    if ($vault.Count -eq 0) {
        Write-Host "📭 Vault is empty" -ForegroundColor Yellow
        exit 0
    }

    Write-Host "🔐 Credentials Vault ($($vault.Count) entries):" -ForegroundColor Cyan
    Write-Host ""

    foreach ($entry in $vault) {
        $rotateWarning = if ($entry.needs_rotation) { " ⚠️  NEEDS ROTATION" } else { "" }
        Write-Host "  🔹 $($entry.service)$rotateWarning" -ForegroundColor White
        if ($entry.username) {
            Write-Host "     Username: $($entry.username)" -ForegroundColor Gray
        }
        if ($entry.token_hint) {
            Write-Host "     Token: $($entry.token_hint)" -ForegroundColor Gray
        }
        Write-Host "     Created: $($entry.created)" -ForegroundColor Gray
        Write-Host "     Updated: $($entry.updated)" -ForegroundColor Gray
        Write-Host ""
    }

    exit 0
}

# === ACTION: GET ===
if ($Action -eq "get") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "❌ Service name required for 'get' action" -ForegroundColor Red
        exit 1
    }

    $vault = Load-Vault
    $entry = $vault | Where-Object { $_.service -eq $Service }

    if (-not $entry) {
        Write-Host "❌ Service not found in vault: $Service" -ForegroundColor Red
        exit 1
    }

    # Decrypt and return
    $decrypted = @{
        service = $entry.service
        username = $entry.username
        password = Unprotect-Secret $entry.password_encrypted
        token = Unprotect-Secret $entry.token_encrypted
        notes = Unprotect-Secret $entry.notes_encrypted
        needs_rotation = $entry.needs_rotation
        created = $entry.created
        updated = $entry.updated
    }

    Write-Host "🔓 Decrypted credentials for: $Service" -ForegroundColor Green
    $decrypted | ConvertTo-Json -Depth 10

    exit 0
}

# === ACTION: SET ===
if ($Action -eq "set") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "❌ Service name required for 'set' action" -ForegroundColor Red
        exit 1
    }

    if ([string]::IsNullOrEmpty($Username) -and [string]::IsNullOrEmpty($Token)) {
        Write-Host "❌ Either Username+Password or Token required" -ForegroundColor Red
        exit 1
    }

    $vault = Load-Vault

    # Find existing or create new
    $existingIndex = -1
    for ($i = 0; $i -lt $vault.Count; $i++) {
        if ($vault[$i].service -eq $Service) {
            $existingIndex = $i
            break
        }
    }

    # Encrypt secrets
    $entry = @{
        service = $Service
        username = $Username
        password_encrypted = Protect-Secret $Password
        token_encrypted = Protect-Secret $Token
        token_hint = if ($Token) { $Token.Substring(0, [Math]::Min(10, $Token.Length)) + "..." } else { "" }
        notes_encrypted = Protect-Secret $Notes
        needs_rotation = $false
        created = if ($existingIndex -ge 0) { $vault[$existingIndex].created } else { (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
        updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }

    if ($existingIndex -ge 0) {
        $vault[$existingIndex] = $entry
        Write-Host "✅ Updated credentials for: $Service" -ForegroundColor Green
    } else {
        $vault += $entry
        Write-Host "✅ Stored new credentials for: $Service" -ForegroundColor Green
    }

    Save-Vault $vault
    Write-Host "🔒 Encrypted with DPAPI (CurrentUser scope)" -ForegroundColor Cyan

    exit 0
}

# === ACTION: ROTATE ===
if ($Action -eq "rotate") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "❌ Service name required for 'rotate' action" -ForegroundColor Red
        exit 1
    }

    $vault = Load-Vault
    $entry = $vault | Where-Object { $_.service -eq $Service }

    if (-not $entry) {
        Write-Host "❌ Service not found in vault: $Service" -ForegroundColor Red
        exit 1
    }

    $entry.needs_rotation = $true
    $entry.updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

    Save-Vault $vault
    Write-Host "⚠️  Marked for rotation: $Service" -ForegroundColor Yellow
    Write-Host "   Remember to update the actual credentials and call 'vault set' again" -ForegroundColor Gray

    exit 0
}

# === ACTION: DELETE ===
if ($Action -eq "delete") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "❌ Service name required for 'delete' action" -ForegroundColor Red
        exit 1
    }

    $vault = Load-Vault
    $newVault = $vault | Where-Object { $_.service -ne $Service }

    if ($newVault.Count -eq $vault.Count) {
        Write-Host "❌ Service not found in vault: $Service" -ForegroundColor Red
        exit 1
    }

    Save-Vault $newVault
    Write-Host "✅ Deleted credentials for: $Service" -ForegroundColor Green

    exit 0
}
