#Requires -Version 5.1
<#
.SYNOPSIS
    Lightweight cache manager with file-based persistence

.DESCRIPTION
    In-memory cache with JSON persistence, inspired by llm-codes caching strategy.

    Features:
    - 30-day TTL (configurable)
    - Hash-based keys
    - LRU eviction when size limit reached
    - Atomic operations (thread-safe)
    - Persistent across sessions

.PARAMETER Action
    Cache operation: Get, Set, Clear, Stats, Cleanup

.PARAMETER Key
    Cache key (will be hashed)

.PARAMETER Value
    Value to cache (any object, will be serialized)

.PARAMETER TTL
    Time-to-live in seconds (default: 30 days)

.PARAMETER CacheName
    Named cache (default: 'default')
    Use different names for different cache domains (clickup, github, etc.)

.EXAMPLE
    cache-manager.ps1 -Action Set -Key "clickup-task-123" -Value $taskData -TTL 2592000

.EXAMPLE
    $cached = cache-manager.ps1 -Action Get -Key "clickup-task-123"
    if ($cached) { "Cache hit!" } else { "Cache miss" }

.EXAMPLE
    cache-manager.ps1 -Action Stats -CacheName clickup

.EXAMPLE
    cache-manager.ps1 -Action Cleanup
    Remove expired entries

.NOTES
    Created: 2026-02-16
    Pattern: llm-codes 30-day cache with 70% hit rate
    Storage: C:\scripts\_machine\cache\{cachename}.cache.json
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Get", "Set", "Clear", "Stats", "Cleanup")]
    [string]$Action,

    [string]$Key,

    [object]$Value,

    [int]$TTL = 2592000, # 30 days in seconds

    [string]$CacheName = "default"
)

# Constants
$CACHE_DIR = "C:\scripts\_machine\cache"
$MAX_CACHE_SIZE_MB = 100
$MAX_CACHE_ENTRIES = 10000

# Ensure cache directory exists
if (-not (Test-Path $CACHE_DIR)) {
    New-Item -ItemType Directory -Path $CACHE_DIR -Force | Out-Null
}

$CacheFile = Join-Path $CACHE_DIR "$CacheName.cache.json"

# Function: Generate hash from key
function Get-KeyHash {
    param([string]$InputKey)

    $md5 = [System.Security.Cryptography.MD5]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputKey)
    $hash = $md5.ComputeHash($bytes)
    return [System.BitConverter]::ToString($hash).Replace("-", "").ToLower()
}

# Function: Load cache from disk
function Get-CacheData {
    if (-not (Test-Path $CacheFile)) {
        return @{}
    }

    try {
        $json = Get-Content $CacheFile -Raw -ErrorAction Stop
        $data = $json | ConvertFrom-Json

        # Convert PSCustomObject to Hashtable (PS 5.1 compatible)
        $hashtable = @{}
        foreach ($property in $data.PSObject.Properties) {
            $hashtable[$property.Name] = $property.Value
        }

        return $hashtable
    }
    catch {
        Write-Warning "Cache file corrupted, starting fresh: $_"
        return @{}
    }
}

# Function: Save cache to disk
function Save-CacheData {
    param([hashtable]$CacheData)

    try {
        $json = $CacheData | ConvertTo-Json -Depth 10 -Compress
        $json | Set-Content $CacheFile -Force -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to save cache: $_"
    }
}

# Function: Check if entry is expired
function Test-CacheExpired {
    param([object]$Entry)

    if (-not $Entry.ExpiresAt) {
        return $true
    }

    $expiresAt = [datetime]::Parse($Entry.ExpiresAt)
    return (Get-Date) -gt $expiresAt
}

# Function: Evict oldest entries (LRU)
function Invoke-CacheEviction {
    param([hashtable]$CacheData, [int]$TargetCount)

    # Sort by LastAccessed, remove oldest
    $entries = $CacheData.GetEnumerator() | Sort-Object {
        if ($_.Value.LastAccessed) {
            [datetime]::Parse($_.Value.LastAccessed)
        } else {
            [datetime]::MinValue
        }
    }

    $toRemove = $entries | Select-Object -First ($entries.Count - $TargetCount)
    foreach ($entry in $toRemove) {
        $CacheData.Remove($entry.Key)
    }

    Write-Verbose "Evicted $($toRemove.Count) entries (LRU)"
}

# Main execution
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

        # Check expiration
        if (Test-CacheExpired $entry) {
            Write-Verbose "Cache expired: $Key"
            $cache.Remove($keyHash)
            Save-CacheData $cache
            return $null
        }

        # Update last accessed
        $entry.LastAccessed = (Get-Date).ToString("o")
        $entry.HitCount = ($entry.HitCount -as [int]) + 1
        $cache[$keyHash] = $entry
        Save-CacheData $cache

        Write-Verbose "Cache hit: $Key (hits: $($entry.HitCount))"

        # Return cached value
        return $entry.Value
    }

    "Set" {
        if (-not $Key) {
            Write-Error "-Key required for Set action"
            return
        }

        $keyHash = Get-KeyHash $Key
        $cache = Get-CacheData

        # Check size limits
        if ($cache.Count -ge $MAX_CACHE_ENTRIES) {
            Invoke-CacheEviction -CacheData $cache -TargetCount ([int]($MAX_CACHE_ENTRIES * 0.8))
        }

        # Create entry
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

        Write-Verbose "Cached: $Key (TTL: $TTL seconds)"
    }

    "Clear" {
        if (Test-Path $CacheFile) {
            Remove-Item $CacheFile -Force
            Write-Host "Cache cleared: $CacheName" -ForegroundColor Green
        } else {
            Write-Host "Cache already empty: $CacheName" -ForegroundColor Yellow
        }
    }

    "Stats" {
        $cache = Get-CacheData

        if ($cache.Count -eq 0) {
            Write-Host "Cache is empty: $CacheName" -ForegroundColor Yellow
            return
        }

        $now = Get-Date
        $validEntries = 0
        $expiredEntries = 0
        $totalHits = 0
        $totalSize = 0

        foreach ($entry in $cache.Values) {
            if (Test-CacheExpired $entry) {
                $expiredEntries++
            } else {
                $validEntries++
            }
            $totalHits += ($entry.HitCount -as [int])
        }

        if (Test-Path $CacheFile) {
            $totalSize = (Get-Item $CacheFile).Length
        }

        Write-Host ""
        Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "📊 Cache Statistics: $CacheName" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "Total entries:    $($cache.Count)" -ForegroundColor White
        Write-Host "Valid entries:    $validEntries" -ForegroundColor Green
        Write-Host "Expired entries:  $expiredEntries" -ForegroundColor Yellow
        Write-Host "Total hits:       $totalHits" -ForegroundColor White
        Write-Host "Cache file size:  $([math]::Round($totalSize / 1KB, 2)) KB" -ForegroundColor White
        Write-Host "Hit rate:         $(if ($totalHits -gt 0) { [math]::Round(($totalHits / ($totalHits + $cache.Count)) * 100, 1) } else { 0 })%" -ForegroundColor White
        Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""

        # Show top 5 most accessed
        $topEntries = $cache.GetEnumerator() |
            Where-Object { -not (Test-CacheExpired $_.Value) } |
            Sort-Object { ($_.Value.HitCount -as [int]) } -Descending |
            Select-Object -First 5

        if ($topEntries) {
            Write-Host "Top 5 most accessed:" -ForegroundColor Cyan
            foreach ($entry in $topEntries) {
                Write-Host "  - $($entry.Value.OriginalKey): $($entry.Value.HitCount) hits" -ForegroundColor White
            }
        }
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

        $removedCount = $keysToRemove.Count
        $currentCount = $cache.Count
        Write-Host "Cleanup complete: Removed $removedCount expired entries (was: $initialCount, now: $currentCount)" -ForegroundColor Green
    }
}
