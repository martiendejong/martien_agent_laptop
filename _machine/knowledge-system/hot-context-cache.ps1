# Hot Context Cache - R02-005
# Keep frequently-accessed context in memory, invalidate on updates
# Expert: Dr. Yuki Tanaka - Real-time Database Architect

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('init', 'get', 'set', 'invalidate', 'stats', 'clear')]
    [string]$Action = 'stats',

    [Parameter(Mandatory=$false)]
    [string]$Key,

    [Parameter(Mandatory=$false)]
    [string]$FilePath,

    [Parameter(Mandatory=$false)]
    [int]$TTLSeconds = 300  # 5 minutes default TTL
)

# Global cache store
if (-not $global:HotContextCache) {
    $global:HotContextCache = @{}
    $global:CacheStats = @{
        'hits' = 0
        'misses' = 0
        'invalidations' = 0
        'entries' = 0
    }
}

function Initialize-Cache {
    $global:HotContextCache = @{}
    $global:CacheStats = @{
        'hits' = 0
        'misses' = 0
        'invalidations' = 0
        'entries' = 0
        'initialized' = Get-Date -Format 'o'
    }
    Write-Host "Hot context cache initialized" -ForegroundColor Green
}

function Get-CachedContext {
    param($Key)

    if ($global:HotContextCache.ContainsKey($Key)) {
        $entry = $global:HotContextCache[$Key]

        # Check TTL
        $age = (Get-Date) - [DateTime]$entry.timestamp
        if ($age.TotalSeconds -lt $TTLSeconds) {
            $global:CacheStats.hits++
            Write-Host "Cache HIT for $Key (age: $([int]$age.TotalSeconds)s)" -ForegroundColor Green
            return $entry.data
        } else {
            # Expired
            $global:HotContextCache.Remove($Key)
            $global:CacheStats.entries--
            Write-Host "Cache EXPIRED for $Key" -ForegroundColor Yellow
        }
    }

    $global:CacheStats.misses++
    Write-Host "Cache MISS for $Key" -ForegroundColor Red
    return $null
}

function Set-CachedContext {
    param($Key, $FilePath)

    if (-not (Test-Path $FilePath)) {
        Write-Host "File not found: $FilePath" -ForegroundColor Red
        return
    }

    $data = Get-Content $FilePath -Raw
    $fileInfo = Get-Item $FilePath

    $entry = @{
        'data' = $data
        'timestamp' = Get-Date -Format 'o'
        'file_path' = $FilePath
        'file_modified' = $fileInfo.LastWriteTime.ToString('o')
        'size_bytes' = $fileInfo.Length
    }

    if ($global:HotContextCache.ContainsKey($Key)) {
        Write-Host "Updating cache entry for $Key" -ForegroundColor Cyan
    } else {
        $global:CacheStats.entries++
        Write-Host "Adding new cache entry for $Key" -ForegroundColor Green
    }

    $global:HotContextCache[$Key] = $entry
}

function Invalidate-CacheEntry {
    param($Key)

    if ($global:HotContextCache.ContainsKey($Key)) {
        $global:HotContextCache.Remove($Key)
        $global:CacheStats.invalidations++
        $global:CacheStats.entries--
        Write-Host "Invalidated cache entry for $Key" -ForegroundColor Yellow
    } else {
        Write-Host "No cache entry found for $Key" -ForegroundColor Yellow
    }
}

function Get-CacheStats {
    $stats = $global:CacheStats.Clone()
    $stats['current_entries'] = $global:HotContextCache.Count

    # Calculate hit rate
    $totalAccess = $stats.hits + $stats.misses
    if ($totalAccess -gt 0) {
        $stats['hit_rate'] = [math]::Round(($stats.hits / $totalAccess) * 100, 2)
    } else {
        $stats['hit_rate'] = 0
    }

    # Calculate cache size
    $totalBytes = 0
    foreach ($entry in $global:HotContextCache.Values) {
        $totalBytes += $entry.size_bytes
    }
    $stats['total_size_kb'] = [math]::Round($totalBytes / 1KB, 2)
    $stats['total_size_mb'] = [math]::Round($totalBytes / 1MB, 2)

    return $stats
}

function Clear-Cache {
    $count = $global:HotContextCache.Count
    Initialize-Cache
    Write-Host "Cleared $count cache entries" -ForegroundColor Yellow
}

# Main execution
switch ($Action) {
    'init' { Initialize-Cache }
    'get' {
        if (-not $Key) {
            Write-Host "Key required for get operation" -ForegroundColor Red
            exit 1
        }
        $result = Get-CachedContext -Key $Key
        if ($result) {
            return $result
        }
    }
    'set' {
        if (-not $Key -or -not $FilePath) {
            Write-Host "Key and FilePath required for set operation" -ForegroundColor Red
            exit 1
        }
        Set-CachedContext -Key $Key -FilePath $FilePath
    }
    'invalidate' {
        if (-not $Key) {
            Write-Host "Key required for invalidate operation" -ForegroundColor Red
            exit 1
        }
        Invalidate-CacheEntry -Key $Key
    }
    'stats' {
        $stats = Get-CacheStats
        Write-Host "`nHot Context Cache Statistics:" -ForegroundColor Cyan
        Write-Host "================================" -ForegroundColor Cyan
        $stats | ConvertTo-Json -Depth 3
    }
    'clear' { Clear-Cache }
}
