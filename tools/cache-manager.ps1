#Requires -Version 5.1
<#
.SYNOPSIS
    Lightweight cache manager with file-based persistence
.DESCRIPTION
    In-memory cache with JSON persistence
.PARAMETER Action
    Cache operation: Get, Set, Clear, Stats, Cleanup
.PARAMETER Key
    Cache key
.PARAMETER Value
    Value to cache
.PARAMETER TTL
    Time-to-live in seconds (default: 30 days)
.PARAMETER CacheName
    Named cache (default: 'default')
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Get","Set","Clear","Stats","Cleanup")]
    [string]$Action,
    [string]$Key,
    [object]$Value,
    [int]$TTL = 2592000,
    [string]$CacheName = "default"
)

$CACHE_DIR = "C:\scripts\_machine\cache"
$MAX_CACHE_ENTRIES = 10000

if (-not (Test-Path $CACHE_DIR)) {
    New-Item -ItemType Directory -Path $CACHE_DIR -Force | Out-Null
}

$CacheFile = Join-Path $CACHE_DIR "$CacheName.cache.json"

function Get-KeyHash {
    param([string]$InputKey)
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputKey)
    $hash = $md5.ComputeHash($bytes)
    return [System.BitConverter]::ToString($hash).Replace("-","").ToLower()
}

function Get-CacheData {
    if (-not (Test-Path $CacheFile)) { return @{} }
    try {
        $json = Get-Content $CacheFile -Raw -ErrorAction Stop
        $data = $json | ConvertFrom-Json
        $hashtable = @{}
        foreach ($property in $data.PSObject.Properties) {
            $hashtable[$property.Name] = $property.Value
        }
        return $hashtable
    } catch {
        Write-Warning "Cache file corrupted, starting fresh"
        return @{}
    }
}

function Save-CacheData {
    param([hashtable]$CacheData)
    try {
        $json = $CacheData | ConvertTo-Json -Depth 10 -Compress
        $json | Set-Content $CacheFile -Force -ErrorAction Stop
    } catch {
        Write-Error "Failed to save cache: $_"
    }
}

function Test-CacheExpired {
    param([object]$Entry)
    if (-not $Entry.ExpiresAt) { return $true }
    $expiresAt = [datetime]::Parse($Entry.ExpiresAt)
    return (Get-Date) -gt $expiresAt
}

switch ($Action) {
    "Get" {
        if (-not $Key) {
            Write-Error "-Key required for Get action"
            return $null
        }
        $keyHash = Get-KeyHash $Key
        $cache = Get-CacheData
        if (-not $cache.ContainsKey($keyHash)) {
            Write-Verbose "Cache miss: $Key"
            return $null
        }
        $entry = $cache[$keyHash]
        if (Test-CacheExpired $entry) {
            Write-Verbose "Cache expired: $Key"
            $cache.Remove($keyHash)
            Save-CacheData $cache
            return $null
        }
        $entry.LastAccessed = (Get-Date).ToString("o")
        $entry.HitCount = ($entry.HitCount -as [int]) + 1
        $cache[$keyHash] = $entry
        Save-CacheData $cache
        Write-Verbose "Cache hit: $Key"
        return $entry.Value
    }

    "Set" {
        if (-not $Key) {
            Write-Error "-Key required for Set action"
            return
        }
        $keyHash = Get-KeyHash $Key
        $cache = Get-CacheData
        $entry = @{
            Value = $Value
            ExpiresAt = (Get-Date).AddSeconds($TTL).ToString("o")
            CreatedAt = (Get-Date).ToString("o")
            LastAccessed = (Get-Date).ToString("o")
            HitCount = 0
            OriginalKey = $Key
        }
        $cache[$keyHash] = $entry
        Save-CacheData $cache
        Write-Verbose "Cached: $Key"
    }

    "Clear" {
        if (Test-Path $CacheFile) {
            Remove-Item $CacheFile -Force
            Write-Host "Cache cleared: $CacheName" -ForegroundColor Green
        }
    }

    "Stats" {
        $cache = Get-CacheData
        if ($cache.Count -eq 0) {
            Write-Host "Cache is empty: $CacheName" -ForegroundColor Yellow
            return
        }
        $validEntries = 0
        $expiredEntries = 0
        foreach ($entry in $cache.Values) {
            if (Test-CacheExpired $entry) { $expiredEntries++ }
            else { $validEntries++ }
        }
        Write-Host ""
        Write-Host "Cache Statistics: $CacheName" -ForegroundColor Cyan
        Write-Host "Total entries:  $($cache.Count)"
        Write-Host "Valid entries:  $validEntries" -ForegroundColor Green
        Write-Host "Expired:        $expiredEntries" -ForegroundColor Yellow
        Write-Host ""
    }

    "Cleanup" {
        $cache = Get-CacheData
        $initialCount = $cache.Count
        $keysToRemove = @()
        foreach ($kvp in $cache.GetEnumerator()) {
            if (Test-CacheExpired $kvp.Value) {
                $keysToRemove += $kvp.Key
            }
        }
        foreach ($key in $keysToRemove) {
            $cache.Remove($key)
        }
        Save-CacheData $cache
        Write-Host "Cleanup: Removed $($keysToRemove.Count) entries" -ForegroundColor Green
    }
}
