# Secure credentials vault using Windows DPAPI
# Author: Jengo, Created: 2026-02-09

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("get", "set", "list", "delete")]
    [string]$Action,

    [string]$Service = "",
    [string]$Username = "",
    [string]$Password = "",
    [string]$Token = "",
    [string]$Notes = ""
)

$ErrorActionPreference = "Stop"

$vaultFile = "C:\scripts\_machine\vault.encrypted.json"

# Encryption using DPAPI
function Protect-Secret {
    param([string]$PlainText)
    if ([string]::IsNullOrEmpty($PlainText)) { return "" }

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $encryptedBytes = [System.Security.Cryptography.ProtectedData]::Protect(
        $bytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    return [Convert]::ToBase64String($encryptedBytes)
}

function Unprotect-Secret {
    param([string]$EncryptedText)
    if ([string]::IsNullOrEmpty($EncryptedText)) { return "" }

    try {
        $encryptedBytes = [Convert]::FromBase64String($EncryptedText)
        $bytes = [System.Security.Cryptography.ProtectedData]::Unprotect(
            $encryptedBytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser
        )
        return [System.Text.Encoding]::UTF8.GetString($bytes)
    } catch {
        return "[DECRYPTION FAILED]"
    }
}

function Load-Vault {
    if (Test-Path $vaultFile) {
        $content = Get-Content $vaultFile -Raw | ConvertFrom-Json
        return @($content.credentials)
    }
    return @()
}

function Save-Vault {
    param([array]$Credentials)

    $vaultData = @{
        version = "1.0"
        encrypted_with = "DPAPI"
        updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        credentials = $Credentials
    }

    $vaultData | ConvertTo-Json -Depth 10 | Out-File -FilePath $vaultFile -Encoding UTF8
}

# LIST action
if ($Action -eq "list") {
    $vault = Load-Vault

    if ($vault.Count -eq 0) {
        Write-Host "Vault is empty" -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Credentials Vault ($($vault.Count) entries):" -ForegroundColor Cyan
    foreach ($entry in $vault) {
        Write-Host "  - $($entry.service)" -ForegroundColor White
        if ($entry.username) {
            Write-Host "    Username: $($entry.username)" -ForegroundColor Gray
        }
        if ($entry.token_hint) {
            Write-Host "    Token: $($entry.token_hint)" -ForegroundColor Gray
        }
    }

    exit 0
}

# GET action
if ($Action -eq "get") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "Service name required for get action" -ForegroundColor Red
        exit 1
    }

    $vault = Load-Vault
    $entry = $vault | Where-Object { $_.service -eq $Service }

    if (-not $entry) {
        Write-Host "Service not found: $Service" -ForegroundColor Red
        exit 1
    }

    $decrypted = @{
        service = $entry.service
        username = $entry.username
        password = Unprotect-Secret $entry.password_encrypted
        token = Unprotect-Secret $entry.token_encrypted
        notes = Unprotect-Secret $entry.notes_encrypted
    }

    Write-Host "Decrypted credentials for: $Service" -ForegroundColor Green
    $decrypted | ConvertTo-Json -Depth 10

    exit 0
}

# SET action
if ($Action -eq "set") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "Service name required for set action" -ForegroundColor Red
        exit 1
    }

    $vault = Load-Vault

    $existingIndex = -1
    for ($i = 0; $i -lt $vault.Count; $i++) {
        if ($vault[$i].service -eq $Service) {
            $existingIndex = $i
            break
        }
    }

    $entry = @{
        service = $Service
        username = $Username
        password_encrypted = Protect-Secret $Password
        token_encrypted = Protect-Secret $Token
        token_hint = if ($Token) { $Token.Substring(0, [Math]::Min(10, $Token.Length)) + "..." } else { "" }
        notes_encrypted = Protect-Secret $Notes
        created = if ($existingIndex -ge 0) { $vault[$existingIndex].created } else { (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
        updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }

    if ($existingIndex -ge 0) {
        $vault[$existingIndex] = $entry
        Write-Host "Updated credentials for: $Service" -ForegroundColor Green
    } else {
        $vault += $entry
        Write-Host "Stored new credentials for: $Service" -ForegroundColor Green
    }

    Save-Vault $vault
    Write-Host "Encrypted with DPAPI" -ForegroundColor Cyan

    exit 0
}

# DELETE action
if ($Action -eq "delete") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "Service name required for delete action" -ForegroundColor Red
        exit 1
    }

    $vault = Load-Vault
    $newVault = $vault | Where-Object { $_.service -ne $Service }

    if ($newVault.Count -eq $vault.Count) {
        Write-Host "Service not found: $Service" -ForegroundColor Red
        exit 1
    }

    Save-Vault $newVault
    Write-Host "Deleted credentials for: $Service" -ForegroundColor Green

    exit 0
}
