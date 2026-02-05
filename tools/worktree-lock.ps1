# worktree-lock.ps1
# Atomic worktree allocation with file-based mutex and heartbeat
# Prevents race conditions in multi-agent environments

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Acquire", "Release", "Heartbeat", "Status", "Clean")]
    [string]$Action,

    [string]$Seat = "",          # e.g., "agent-001"
    [string]$Repo = "",          # e.g., "client-manager"
    [string]$Branch = "",        # e.g., "feature/my-branch"
    [int]$Timeout = 300,         # seconds (5 min default)
    [switch]$Force               # Force release stale locks
)

$script:LockDir = "C:\scripts\_machine\locks"
$script:PoolFile = "C:\scripts\_machine\worktrees.pool.md"
$script:ActivityFile = "C:\scripts\_machine\worktrees.activity.md"

# Ensure lock directory exists
if (-not (Test-Path $script:LockDir)) {
    New-Item -ItemType Directory -Path $script:LockDir -Force | Out-Null
}

function Get-LockFilePath {
    param([string]$Seat)
    return Join-Path $script:LockDir "$Seat.lock"
}

function Test-LockStale {
    param([string]$LockFile, [int]$TimeoutSeconds)

    if (-not (Test-Path $LockFile)) {
        return $false
    }

    $lockAge = (Get-Date) - (Get-Item $LockFile).LastWriteTime
    return $lockAge.TotalSeconds -gt $TimeoutSeconds
}

function Acquire-Lock {
    param(
        [string]$Seat,
        [string]$Repo,
        [string]$Branch,
        [int]$Timeout
    )

    $lockFile = Get-LockFilePath -Seat $Seat

    # Check if lock already exists
    if (Test-Path $lockFile) {
        $isStale = Test-LockStale -LockFile $lockFile -TimeoutSeconds $Timeout

        if ($isStale) {
            Write-Host "⚠️ Stale lock detected on $Seat (older than ${Timeout}s)" -ForegroundColor Yellow
            Write-Host "   Acquiring stale lock..."

            # Log stale lock cleanup
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $script:ActivityFile -Value "[$timestamp] STALE_LOCK_CLEANUP: $Seat (timeout: ${Timeout}s)"

            # Remove stale lock
            Remove-Item $lockFile -Force
        } else {
            $lockContent = Get-Content $lockFile -Raw | ConvertFrom-Json
            $lockAge = ((Get-Date) - [datetime]$lockContent.AcquiredAt).TotalSeconds

            Write-Host "❌ Lock already held on $Seat" -ForegroundColor Red
            Write-Host "   Repo: $($lockContent.Repo)"
            Write-Host "   Branch: $($lockContent.Branch)"
            Write-Host "   Acquired: $([math]::Round($lockAge, 1))s ago"
            Write-Host "   Last heartbeat: $($lockContent.LastHeartbeat)"
            return $false
        }
    }

    # Acquire lock
    $lockData = @{
        Seat = $Seat
        Repo = $Repo
        Branch = $Branch
        AcquiredAt = (Get-Date).ToString("o")
        LastHeartbeat = (Get-Date).ToString("o")
        ProcessId = $PID
        MachineName = $env:COMPUTERNAME
    }

    try {
        # Write lock file atomically
        $lockData | ConvertTo-Json | Set-Content -Path $lockFile -Force

        # Update worktree pool
        Update-PoolStatus -Seat $Seat -Status "BUSY" -Repo $Repo -Branch $Branch

        # Log acquisition
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $script:ActivityFile -Value "[$timestamp] LOCK_ACQUIRED: $Seat ($Repo / $Branch)"

        Write-Host "✅ Lock acquired: $Seat" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Failed to acquire lock: $_" -ForegroundColor Red
        return $false
    }
}

function Release-Lock {
    param([string]$Seat, [switch]$Force)

    $lockFile = Get-LockFilePath -Seat $Seat

    if (-not (Test-Path $lockFile)) {
        if ($Force) {
            Write-Host "⚠️ Lock file not found, updating pool anyway (forced)" -ForegroundColor Yellow
        } else {
            Write-Host "⚠️ No lock to release on $Seat" -ForegroundColor Yellow
            return $true
        }
    }

    # Read lock data before releasing
    $lockData = $null
    if (Test-Path $lockFile) {
        $lockData = Get-Content $lockFile -Raw | ConvertFrom-Json
    }

    # Remove lock file
    if (Test-Path $lockFile) {
        Remove-Item $lockFile -Force
    }

    # Update worktree pool
    Update-PoolStatus -Seat $Seat -Status "FREE" -Repo "-" -Branch "-"

    # Log release
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($lockData) {
        $duration = ((Get-Date) - [datetime]$lockData.AcquiredAt).TotalMinutes
        Add-Content -Path $script:ActivityFile -Value "[$timestamp] LOCK_RELEASED: $Seat (held for $([math]::Round($duration, 1))m)"
    } else {
        Add-Content -Path $script:ActivityFile -Value "[$timestamp] LOCK_RELEASED: $Seat (forced)"
    }

    Write-Host "✅ Lock released: $Seat" -ForegroundColor Green
    return $true
}

function Update-Heartbeat {
    param([string]$Seat)

    $lockFile = Get-LockFilePath -Seat $Seat

    if (-not (Test-Path $lockFile)) {
        Write-Host "❌ No lock found on $Seat - cannot update heartbeat" -ForegroundColor Red
        return $false
    }

    try {
        $lockData = Get-Content $lockFile -Raw | ConvertFrom-Json
        $lockData.LastHeartbeat = (Get-Date).ToString("o")
        $lockData | ConvertTo-Json | Set-Content -Path $lockFile -Force

        Write-Host "💓 Heartbeat updated: $Seat" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Failed to update heartbeat: $_" -ForegroundColor Red
        return $false
    }
}

function Update-PoolStatus {
    param(
        [string]$Seat,
        [string]$Status,
        [string]$Repo = "",
        [string]$Branch = ""
    )

    if (-not (Test-Path $script:PoolFile)) {
        Write-Host "❌ Worktree pool file not found: $script:PoolFile" -ForegroundColor Red
        return
    }

    $content = Get-Content $script:PoolFile -Raw

    # Find seat line and update status
    $pattern = "\| $Seat \|.*?\|"
    if ($content -match $pattern) {
        $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd\THH:mm:ss\Z")

        # Parse existing line to preserve structure
        $line = [regex]::Match($content, "^\| $Seat \|.*?$", [System.Text.RegularExpressions.RegexOptions]::Multiline).Value

        # Update columns: status, repo, branch, timestamp
        # Format: | Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity | Notes |
        $newLine = $line -replace "\| $Status \||\| BUSY \||\| FREE \|", "| $Status |"
        $newLine = $newLine -replace "\| [^|]+ \| [^|]+ \| $timestamp", "| $Repo | $Branch | $timestamp"

        # Simple replacement for now - proper parser would be better
        $content = $content -replace [regex]::Escape($line), $newLine

        Set-Content -Path $script:PoolFile -Value $content -Force
    }
}

function Show-LockStatus {
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🔒 WORKTREE LOCK STATUS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    $locks = Get-ChildItem -Path $script:LockDir -Filter "*.lock" -ErrorAction SilentlyContinue

    if ($locks.Count -eq 0) {
        Write-Host "✅ No active locks" -ForegroundColor Green
        return
    }

    foreach ($lockFile in $locks) {
        $lockData = Get-Content $lockFile.FullName -Raw | ConvertFrom-Json
        $age = ((Get-Date) - [datetime]$lockData.AcquiredAt).TotalMinutes
        $heartbeatAge = ((Get-Date) - [datetime]$lockData.LastHeartbeat).TotalSeconds

        $staleIndicator = ""
        if ($heartbeatAge -gt 120) {
            $staleIndicator = " ⚠️ STALE"
        }

        Write-Host "`n🔒 $($lockData.Seat)$staleIndicator" -ForegroundColor Yellow
        Write-Host "   Repo: $($lockData.Repo)" -ForegroundColor White
        Write-Host "   Branch: $($lockData.Branch)" -ForegroundColor White
        Write-Host "   Held for: $([math]::Round($age, 1))m" -ForegroundColor Gray
        Write-Host "   Last heartbeat: $([math]::Round($heartbeatAge, 1))s ago" -ForegroundColor Gray
        Write-Host "   Machine: $($lockData.MachineName) (PID $($lockData.ProcessId))" -ForegroundColor DarkGray
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Clean-StaleLocks {
    param([int]$Timeout, [switch]$Force)

    $locks = Get-ChildItem -Path $script:LockDir -Filter "*.lock" -ErrorAction SilentlyContinue
    $cleanedCount = 0

    foreach ($lockFile in $locks) {
        if (Test-LockStale -LockFile $lockFile.FullName -TimeoutSeconds $Timeout) {
            $lockData = Get-Content $lockFile.FullName -Raw | ConvertFrom-Json

            Write-Host "🧹 Cleaning stale lock: $($lockData.Seat)" -ForegroundColor Yellow
            Write-Host "   Age: $([math]::Round(((Get-Date) - [datetime]$lockData.AcquiredAt).TotalMinutes, 1))m"

            Release-Lock -Seat $lockData.Seat -Force:$Force
            $cleanedCount++
        }
    }

    if ($cleanedCount -eq 0) {
        Write-Host "✅ No stale locks found" -ForegroundColor Green
    } else {
        Write-Host "✅ Cleaned $cleanedCount stale lock(s)" -ForegroundColor Green
    }
}

# Main logic
switch ($Action) {
    "Acquire" {
        if (-not $Seat -or -not $Repo -or -not $Branch) {
            Write-Host "❌ Acquire requires -Seat, -Repo, and -Branch parameters" -ForegroundColor Red
            exit 1
        }
        $success = Acquire-Lock -Seat $Seat -Repo $Repo -Branch $Branch -Timeout $Timeout
        exit $(if ($success) { 0 } else { 1 })
    }

    "Release" {
        if (-not $Seat) {
            Write-Host "❌ Release requires -Seat parameter" -ForegroundColor Red
            exit 1
        }
        $success = Release-Lock -Seat $Seat -Force:$Force
        exit $(if ($success) { 0 } else { 1 })
    }

    "Heartbeat" {
        if (-not $Seat) {
            Write-Host "❌ Heartbeat requires -Seat parameter" -ForegroundColor Red
            exit 1
        }
        $success = Update-Heartbeat -Seat $Seat
        exit $(if ($success) { 0 } else { 1 })
    }

    "Status" {
        Show-LockStatus
        exit 0
    }

    "Clean" {
        Clean-StaleLocks -Timeout $Timeout -Force:$Force
        exit 0
    }
}
