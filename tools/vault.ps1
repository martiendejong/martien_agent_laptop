<#
.SYNOPSIS
    DPAPI-encrypted credentials vault (v2)

.DESCRIPTION
    Stores and retrieves credentials encrypted with Windows DPAPI (CurrentUser scope).
    Per-user, per-machine encryption. No key management required.
    PS 5.1 compatible. Atomic file writes. ACL-protected vault file.

.PARAMETER Action
    get, set, list, delete, export-hints

.PARAMETER Service
    Service name (e.g., "clickup", "orchestration")

.PARAMETER Field
    Return single raw value: vault.ps1 -Action get -Service clickup -Field token

.PARAMETER Username
    Username for the service

.PARAMETER Password
    Password for the service

.PARAMETER Token
    API token for the service

.PARAMETER Notes
    Optional notes

.PARAMETER Tags
    String array for categorization

.PARAMETER Json
    Force JSON output

.PARAMETER Silent
    Suppress Write-Host output

.EXAMPLE
    .\vault.ps1 -Action set -Service "clickup" -Token "pk_xxx" -Tags "api"
    .\vault.ps1 -Action get -Service "clickup" -Field token
    .\vault.ps1 -Action list
    .\vault.ps1 -Action delete -Service "test"
    .\vault.ps1 -Action export-hints

.NOTES
    Author: Jengo
    Version: 2.0
    Created: 2026-02-11
    Encryption: DPAPI CurrentUser, stored as hex strings
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("get", "set", "list", "delete", "export-hints")]
    [string]$Action,

    [string]$Service = "",
    [string]$Field = "",
    [string]$Username = "",
    [string]$Password = "",
    [string]$Token = "",
    [string]$Notes = "",
    [string[]]$Tags = @(),
    [switch]$Json,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Security

$vaultFile = "C:\scripts\_machine\vault.secure.json"

# --- Helpers ---

function ConvertTo-Hashtable {
    param([Parameter(ValueFromPipeline=$true)]$InputObject)
    process {
        if ($null -eq $InputObject) { return $null }
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $result = @()
            foreach ($item in $InputObject) {
                $result += (ConvertTo-Hashtable -InputObject $item)
            }
            return ,$result
        }
        if ($InputObject -is [psobject]) {
            $hash = @{}
            foreach ($prop in $InputObject.PSObject.Properties) {
                $hash[$prop.Name] = ConvertTo-Hashtable -InputObject $prop.Value
            }
            return $hash
        }
        return $InputObject
    }
}

function Protect-Secret {
    param([string]$PlainText)
    if ([string]::IsNullOrEmpty($PlainText)) { return "" }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $encrypted = [System.Security.Cryptography.ProtectedData]::Protect(
        $bytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    $hex = ""
    foreach ($b in $encrypted) {
        $hex += $b.ToString("x2")
    }
    return $hex
}

function Unprotect-Secret {
    param([string]$HexString)
    if ([string]::IsNullOrEmpty($HexString)) { return "" }
    try {
        $byteCount = $HexString.Length / 2
        $encrypted = New-Object byte[] $byteCount
        for ($i = 0; $i -lt $byteCount; $i++) {
            $encrypted[$i] = [Convert]::ToByte($HexString.Substring($i * 2, 2), 16)
        }
        $decrypted = [System.Security.Cryptography.ProtectedData]::Unprotect(
            $encrypted, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser
        )
        return [System.Text.Encoding]::UTF8.GetString($decrypted)
    } catch {
        return "[DECRYPTION FAILED]"
    }
}

function Get-Hint {
    param([string]$Value, [int]$Length = 8)
    if ([string]::IsNullOrEmpty($Value)) { return "" }
    if ($Value.Length -le $Length) { return $Value + "..." }
    return $Value.Substring(0, $Length) + "..."
}

function Load-Vault {
    if (-not (Test-Path $vaultFile)) {
        return ,@()
    }
    $raw = Get-Content $vaultFile -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return ,@()
    }
    $parsed = $raw | ConvertFrom-Json
    $converted = ConvertTo-Hashtable -InputObject $parsed
    if ($null -eq $converted) { return ,@() }
    $creds = $converted["credentials"]
    if ($null -eq $creds) { return ,@() }
    # Force array (PS 5.1 unrolls single-element arrays from functions)
    if ($creds -is [hashtable]) {
        $arr = @($creds)
        return ,$arr
    }
    return ,$creds
}

function Save-Vault {
    param([array]$Credentials)

    $vaultData = @{
        version = "2.0"
        encryption = "dpapi"
        scope = "CurrentUser"
        storage = "hex"
        updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        credentials = $Credentials
    }

    $jsonContent = $vaultData | ConvertTo-Json -Depth 10

    # Atomic write: .tmp -> delete original -> rename
    $tmpFile = $vaultFile + ".tmp"
    $jsonContent | Out-File -FilePath $tmpFile -Encoding UTF8

    if (Test-Path $vaultFile) {
        Remove-Item $vaultFile -Force
    }
    Rename-Item -Path $tmpFile -NewName (Split-Path $vaultFile -Leaf)

    # ACL: current user only
    try {
        $acl = Get-Acl $vaultFile
        $acl.SetAccessRuleProtection($true, $false)
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $currentUser, "FullControl", "Allow"
        )
        $acl.SetAccessRule($rule)
        Set-Acl $vaultFile $acl
    } catch {
        # ACL setting may fail in some environments, vault still works
    }
}

function Write-VaultHost {
    param([string]$Message, [string]$Color = "White")
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# --- Actions ---

# === LIST ===
if ($Action -eq "list") {
    $vault = Load-Vault

    if ($vault.Count -eq 0) {
        Write-VaultHost "Vault is empty" "Yellow"
        exit 0
    }

    if ($Json) {
        $output = @()
        foreach ($entry in $vault) {
            $output += @{
                service = $entry["service"]
                username = $entry["username"]
                password_hint = $entry["password_hint"]
                token_hint = $entry["token_hint"]
                tags = $entry["tags"]
                created = $entry["created"]
                updated = $entry["updated"]
            }
        }
        $output | ConvertTo-Json -Depth 10
        exit 0
    }

    Write-VaultHost "Credentials Vault ($($vault.Count) entries):" "Cyan"
    Write-VaultHost ""

    foreach ($entry in $vault) {
        $svc = $entry["service"]
        $user = $entry["username"]
        $phint = $entry["password_hint"]
        $thint = $entry["token_hint"]
        $tagList = $entry["tags"]
        $updated = $entry["updated"]

        $tagStr = ""
        if ($tagList -and $tagList.Count -gt 0) {
            $tagStr = " [" + ($tagList -join ", ") + "]"
        }

        Write-VaultHost "  $svc$tagStr" "White"
        if ($user) {
            Write-VaultHost "    Username: $user" "Gray"
        }
        if ($phint) {
            Write-VaultHost "    Password: $phint" "Gray"
        }
        if ($thint) {
            Write-VaultHost "    Token: $thint" "Gray"
        }
        Write-VaultHost "    Updated: $updated" "Gray"
        Write-VaultHost ""
    }

    exit 0
}

# === GET ===
if ($Action -eq "get") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-VaultHost "Service name required for get action" "Red"
        exit 1
    }

    $vault = Load-Vault
    $entry = $null
    foreach ($e in $vault) {
        if ($e["service"] -eq $Service) {
            $entry = $e
            break
        }
    }

    if ($null -eq $entry) {
        Write-VaultHost "Service not found: $Service" "Red"
        exit 1
    }

    $decUsername = $entry["username"]
    $decPassword = Unprotect-Secret $entry["password_enc"]
    $decToken = Unprotect-Secret $entry["token_enc"]
    $decNotes = Unprotect-Secret $entry["notes_enc"]

    # Single field extraction: return raw value only
    if (-not [string]::IsNullOrEmpty($Field)) {
        switch ($Field.ToLower()) {
            "username" { Write-Output $decUsername }
            "password" { Write-Output $decPassword }
            "token"    { Write-Output $decToken }
            "notes"    { Write-Output $decNotes }
            "service"  { Write-Output $entry["service"] }
            default {
                Write-VaultHost "Unknown field: $Field (valid: username, password, token, notes, service)" "Red"
                exit 1
            }
        }
        exit 0
    }

    # Full output
    $result = @{
        service = $entry["service"]
        username = $decUsername
        password = $decPassword
        token = $decToken
        notes = $decNotes
        tags = $entry["tags"]
        created = $entry["created"]
        updated = $entry["updated"]
    }

    if ($Json) {
        $result | ConvertTo-Json -Depth 10
    } else {
        Write-VaultHost "Credentials for: $Service" "Green"
        $result | ConvertTo-Json -Depth 10
    }

    exit 0
}

# === SET ===
if ($Action -eq "set") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-VaultHost "Service name required for set action" "Red"
        exit 1
    }

    if ([string]::IsNullOrEmpty($Username) -and [string]::IsNullOrEmpty($Password) -and [string]::IsNullOrEmpty($Token) -and [string]::IsNullOrEmpty($Notes)) {
        Write-VaultHost "At least one of -Username, -Password, -Token, or -Notes required" "Red"
        exit 1
    }

    $vault = Load-Vault

    $existingIndex = -1
    for ($i = 0; $i -lt $vault.Count; $i++) {
        if ($vault[$i]["service"] -eq $Service) {
            $existingIndex = $i
            break
        }
    }

    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $createdDate = $now
    if ($existingIndex -ge 0) {
        $createdDate = $vault[$existingIndex]["created"]
    }

    $entry = @{
        service = $Service
        username = $Username
        password_enc = Protect-Secret $Password
        password_hint = Get-Hint $Password
        token_enc = Protect-Secret $Token
        token_hint = Get-Hint $Token
        notes_enc = Protect-Secret $Notes
        tags = $Tags
        created = $createdDate
        updated = $now
    }

    if ($existingIndex -ge 0) {
        $vault[$existingIndex] = $entry
        Write-VaultHost "Updated: $Service" "Green"
    } else {
        $vault += $entry
        Write-VaultHost "Stored: $Service" "Green"
    }

    Save-Vault $vault
    Write-VaultHost "Encrypted with DPAPI (CurrentUser scope)" "Cyan"

    exit 0
}

# === DELETE ===
if ($Action -eq "delete") {
    if ([string]::IsNullOrEmpty($Service)) {
        Write-VaultHost "Service name required for delete action" "Red"
        exit 1
    }

    $vault = Load-Vault
    $newVault = @()
    $found = $false
    foreach ($e in $vault) {
        if ($e["service"] -eq $Service) {
            $found = $true
        } else {
            $newVault += $e
        }
    }

    if (-not $found) {
        Write-VaultHost "Service not found: $Service" "Red"
        exit 1
    }

    Save-Vault $newVault
    Write-VaultHost "Deleted: $Service" "Green"

    exit 0
}

# === EXPORT-HINTS ===
if ($Action -eq "export-hints") {
    $vault = Load-Vault

    if ($vault.Count -eq 0) {
        Write-VaultHost "Vault is empty" "Yellow"
        exit 0
    }

    $hints = @()
    foreach ($entry in $vault) {
        $hints += @{
            service = $entry["service"]
            username = $entry["username"]
            password_hint = $entry["password_hint"]
            token_hint = $entry["token_hint"]
            tags = $entry["tags"]
        }
    }

    $hints | ConvertTo-Json -Depth 10
    exit 0
}
