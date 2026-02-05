# Hot Context Cache
# In-memory cache for frequently-accessed context files
# Reduces file I/O during active conversations

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "init",

    [Parameter(Mandatory=$false)]
    [string]$FilePath = "",

    [Parameter(Mandatory=$false)]
    [int]$TTL = 300  # 5 minutes default
)

# Global cache hashtable
if (-not $global:HotContextCache) {
    $global:HotContextCache = @{
        entries = @{}
        hits = 0
        misses = 0
        stats_start = Get-Date
    }
}

function Get-CachedContent {
    param([string]$Path)

    $entry = $global:HotContextCache.entries[$Path]

    if ($entry) {
        $age = ((Get-Date) - $entry.cached_at).TotalSeconds

        if ($age -lt $entry.ttl) {
            $global:HotContextCache.hits++
            Write-Host "Cache HIT: $Path (age: $([int]$age)s)" -ForegroundColor Green
            return $entry.content
        } else {
            Write-Host "Cache EXPIRED: $Path" -ForegroundColor Yellow
            $global:HotContextCache.entries.Remove($Path)
        }
    }

    $global:HotContextCache.misses++
    Write-Host "Cache MISS: $Path" -ForegroundColor Cyan

    # Read from disk and cache
    if (Test-Path $Path) {
        $content = Get-Content $Path -Raw

        $global:HotContextCache.entries[$Path] = @{
            content = $content
            cached_at = Get-Date
            ttl = $TTL
            access_count = 1
        }

        return $content
    }

    return $null
}

function Invalidate-Cache {
    param([string]$Path)

    if ($global:HotContextCache.entries.ContainsKey($Path)) {
        $global:HotContextCache.entries.Remove($Path)
        Write-Host "Cache INVALIDATED: $Path" -ForegroundColor Red
    }
}

function Get-CacheStats {
    $hitRate = if ($global:HotContextCache.hits + $global:HotContextCache.misses -gt 0) {
        ($global:HotContextCache.hits / ($global:HotContextCache.hits + $global:HotContextCache.misses)) * 100
    } else { 0 }

    $runtime = ((Get-Date) - $global:HotContextCache.stats_start).TotalMinutes

    return @{
        hits = $global:HotContextCache.hits
        misses = $global:HotContextCache.misses
        hit_rate = [math]::Round($hitRate, 2)
        cached_files = $global:HotContextCache.entries.Count
        runtime_minutes = [math]::Round($runtime, 2)
    }
}

function Clear-Cache {
    $global:HotContextCache.entries = @{}
    Write-Host "Cache cleared" -ForegroundColor Yellow
}

# Execute action
switch ($Action) {
    "get" {
        return Get-CachedContent -Path $FilePath
    }
    "invalidate" {
        Invalidate-Cache -Path $FilePath
    }
    "stats" {
        $stats = Get-CacheStats
        Write-Host "`nHot Context Cache Statistics:" -ForegroundColor Cyan
        Write-Host "  Hits: $($stats.hits)" -ForegroundColor Green
        Write-Host "  Misses: $($stats.misses)" -ForegroundColor Yellow
        Write-Host "  Hit Rate: $($stats.hit_rate)%" -ForegroundColor $(if($stats.hit_rate -gt 70){"Green"}else{"Yellow"})
        Write-Host "  Cached Files: $($stats.cached_files)" -ForegroundColor Cyan
        Write-Host "  Runtime: $($stats.runtime_minutes) minutes" -ForegroundColor Gray
        return $stats
    }
    "clear" {
        Clear-Cache
    }
    "init" {
        Write-Host "Hot context cache initialized (TTL: $TTL seconds)" -ForegroundColor Cyan
    }
}
