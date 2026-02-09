# Simple credentials vault with base64 encoding
# Security: File permissions (user-scoped)
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

$vaultFile = "C:\scripts\_machine\vault.secure.json"

function Encode-Secret {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return "" }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    return [Convert]::ToBase64String($bytes)
}

function Decode-Secret {
    param([string]$Encoded)
    if ([string]::IsNullOrEmpty($Encoded)) { return "" }
    try {
        $bytes = [Convert]::FromBase64String($Encoded)
        return [System.Text.Encoding]::UTF8.GetString($bytes)
    } catch {
        return "[DECODE FAILED]"
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
        encoding = "base64"
        note = "Secured by file permissions"
        updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        credentials = $Credentials
    }

    $vaultData | ConvertTo-Json -Depth 10 | Out-File -FilePath $vaultFile -Encoding UTF8

    # Set file permissions (user-only)
    $acl = Get-Acl $vaultFile
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
        "FullControl",
        "Allow"
    )
    $acl.SetAccessRule($rule)
    Set-Acl $vaultFile $acl
}

# LIST
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
        Write-Host "    Updated: $($entry.updated)" -ForegroundColor Gray
    }

    exit 0
}

# GET
if ($Action -eq "get") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "Service name required" -ForegroundColor Red
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
        password = Decode-Secret $entry.password_encoded
        token = Decode-Secret $entry.token_encoded
        notes = Decode-Secret $entry.notes_encoded
    }

    Write-Host "Credentials for: $Service" -ForegroundColor Green
    $decrypted | ConvertTo-Json -Depth 10

    exit 0
}

# SET
if ($Action -eq "set") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "Service name required" -ForegroundColor Red
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
        password_encoded = Encode-Secret $Password
        token_encoded = Encode-Secret $Token
        token_hint = if ($Token) { $Token.Substring(0, [Math]::Min(10, $Token.Length)) + "..." } else { "" }
        notes_encoded = Encode-Secret $Notes
        created = if ($existingIndex -ge 0) { $vault[$existingIndex].created } else { (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
        updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }

    if ($existingIndex -ge 0) {
        $vault[$existingIndex] = $entry
        Write-Host "Updated: $Service" -ForegroundColor Green
    } else {
        $vault += $entry
        Write-Host "Stored: $Service" -ForegroundColor Green
    }

    Save-Vault $vault
    Write-Host "Secured by file permissions" -ForegroundColor Cyan

    exit 0
}

# DELETE
if ($Action -eq "delete") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "Service name required" -ForegroundColor Red
        exit 1
    }

    $vault = Load-Vault
    $newVault = $vault | Where-Object { $_.service -ne $Service }

    if ($newVault.Count -eq $vault.Count) {
        Write-Host "Service not found: $Service" -ForegroundColor Red
        exit 1
    }

    Save-Vault $newVault
    Write-Host "Deleted: $Service" -ForegroundColor Green

    exit 0
}
