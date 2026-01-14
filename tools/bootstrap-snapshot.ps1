<#
.SYNOPSIS
    Creates and reads a condensed bootstrap state snapshot for faster Claude agent startup.

.DESCRIPTION
    Instead of reading 6+ files at startup, this tool:
    - Generates a single JSON snapshot of all critical state
    - Caches frequently-needed information
    - Provides instant access to current system state

.PARAMETER Generate
    Generate a fresh snapshot from current state files

.PARAMETER Read
    Read and display the current snapshot (default)

.PARAMETER Format
    Output format: json, summary, or oneliner (default: summary)

.EXAMPLE
    .\bootstrap-snapshot.ps1 -Generate
    .\bootstrap-snapshot.ps1 -Read -Format oneliner
    .\bootstrap-snapshot.ps1
#>

param(
    [switch]$Generate,
    [switch]$Read,
    [ValidateSet("json", "summary", "oneliner")]
    [string]$Format = "summary"
)

$SnapshotPath = "C:\scripts\_machine\bootstrap-snapshot.json"
$PoolPath = "C:\scripts\_machine\worktrees.pool.md"
$ReflectionPath = "C:\scripts\_machine\reflection.log.md"

function Get-PoolStatus {
    $pool = @{}
    if (Test-Path $PoolPath) {
        $content = Get-Content $PoolPath -Raw
        $lines = $content -split "`n" | Where-Object { $_ -match '^\| agent-' }
        foreach ($line in $lines) {
            if ($line -match '\| (agent-\d+) .* \| (FREE|BUSY|STALE|BROKEN) \|') {
                $pool[$matches[1]] = $matches[2]
            }
        }
    }
    return $pool
}

function Get-RecentReflections {
    param([int]$Count = 5)

    $reflections = @()
    if (Test-Path $ReflectionPath) {
        $content = Get-Content $ReflectionPath -Raw
        $entries = $content -split '(?=## 20\d{2}-\d{2}-\d{2})' | Where-Object { $_ -match '^## 20\d{2}' }
        $reflections = $entries | Select-Object -First $Count | ForEach-Object {
            if ($_ -match '^## (20\d{2}-\d{2}-\d{2}) \[([^\]]+)\]') {
                @{
                    date = $matches[1]
                    tag = $matches[2]
                    preview = ($_ -split "`n" | Select-Object -Skip 1 -First 3) -join " "
                }
            }
        }
    }
    return $reflections
}

function Get-BaseRepoStatus {
    $repos = @{}
    $repoPaths = @(
        "C:\Projects\client-manager",
        "C:\Projects\hazina"
    )

    foreach ($path in $repoPaths) {
        if (Test-Path $path) {
            $repoName = Split-Path $path -Leaf
            try {
                $branch = git -C $path branch --show-current 2>$null
                $status = git -C $path status --porcelain 2>$null
                $repos[$repoName] = @{
                    branch = $branch
                    clean = [string]::IsNullOrWhiteSpace($status)
                    path = $path
                }
            } catch {
                $repos[$repoName] = @{ error = $_.Exception.Message }
            }
        }
    }
    return $repos
}

function Get-ActiveWorktrees {
    $worktrees = @()
    $agentPath = "C:\Projects\worker-agents"

    if (Test-Path $agentPath) {
        Get-ChildItem $agentPath -Directory | ForEach-Object {
            $seat = $_.Name
            Get-ChildItem $_.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $repoPath = $_.FullName
                try {
                    $branch = git -C $repoPath branch --show-current 2>$null
                    if ($branch) {
                        $worktrees += @{
                            seat = $seat
                            repo = $_.Name
                            branch = $branch
                            path = $repoPath
                        }
                    }
                } catch {}
            }
        }
    }
    return $worktrees
}

function Get-AvailableTools {
    $tools = @()
    $toolsPath = "C:\scripts\tools"

    if (Test-Path $toolsPath) {
        Get-ChildItem $toolsPath -Filter "*.ps1" | Where-Object { $_.Name -notlike "*node_modules*" } | ForEach-Object {
            $tools += @{
                name = $_.BaseName
                path = $_.FullName
                modified = $_.LastWriteTime.ToString("yyyy-MM-dd")
            }
        }
    }
    return $tools
}

function Get-AvailableSkills {
    $skills = @()
    $skillsPath = "C:\scripts\.claude\skills"

    if (Test-Path $skillsPath) {
        Get-ChildItem $skillsPath -Directory | ForEach-Object {
            $skillFile = Join-Path $_.FullName "SKILL.md"
            if (Test-Path $skillFile) {
                $skills += $_.Name
            }
        }
    }
    return $skills
}

function Generate-Snapshot {
    $snapshot = @{
        generated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        pool = Get-PoolStatus
        baseRepos = Get-BaseRepoStatus
        activeWorktrees = Get-ActiveWorktrees
        recentReflections = Get-RecentReflections -Count 5
        tools = Get-AvailableTools
        skills = Get-AvailableSkills
        summary = @{
            freeSeats = 0
            busySeats = 0
            activeWorktreeCount = 0
            toolCount = 0
            skillCount = 0
        }
    }

    # Calculate summary
    $snapshot.pool.Values | ForEach-Object {
        if ($_ -eq "FREE") { $snapshot.summary.freeSeats++ }
        elseif ($_ -eq "BUSY") { $snapshot.summary.busySeats++ }
    }
    $snapshot.summary.activeWorktreeCount = $snapshot.activeWorktrees.Count
    $snapshot.summary.toolCount = $snapshot.tools.Count
    $snapshot.summary.skillCount = $snapshot.skills.Count

    $snapshot | ConvertTo-Json -Depth 5 | Set-Content $SnapshotPath -Encoding UTF8

    return $snapshot
}

function Read-Snapshot {
    if (-not (Test-Path $SnapshotPath)) {
        Write-Host "No snapshot exists. Generating..." -ForegroundColor Yellow
        return Generate-Snapshot
    }
    return Get-Content $SnapshotPath -Raw | ConvertFrom-Json
}

# Main execution
if ($Generate) {
    Write-Host "Generating bootstrap snapshot..." -ForegroundColor Cyan
    $snapshot = Generate-Snapshot
    Write-Host "Snapshot saved to: $SnapshotPath" -ForegroundColor Green
} else {
    $snapshot = Read-Snapshot
}

# Output based on format
switch ($Format) {
    "json" {
        $snapshot | ConvertTo-Json -Depth 5
    }
    "oneliner" {
        $s = $snapshot.summary
        $baseStatus = ($snapshot.baseRepos.PSObject.Properties | ForEach-Object {
            "$($_.Name):$($_.Value.branch)"
        }) -join ", "
        Write-Host "Seats: $($s.freeSeats) FREE / $($s.busySeats) BUSY | Worktrees: $($s.activeWorktreeCount) | Base: $baseStatus | Tools: $($s.toolCount) | Skills: $($s.skillCount)"
    }
    "summary" {
        Write-Host ""
        Write-Host "=== BOOTSTRAP SNAPSHOT ===" -ForegroundColor Cyan
        Write-Host "Generated: $($snapshot.generated)" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "WORKTREE POOL:" -ForegroundColor Yellow
        $snapshot.pool.PSObject.Properties | ForEach-Object {
            $color = if ($_.Value -eq "FREE") { "Green" } elseif ($_.Value -eq "BUSY") { "Red" } else { "Gray" }
            Write-Host "  $($_.Name): " -NoNewline
            Write-Host $_.Value -ForegroundColor $color
        }
        Write-Host ""

        Write-Host "BASE REPOSITORIES:" -ForegroundColor Yellow
        $snapshot.baseRepos.PSObject.Properties | ForEach-Object {
            $status = if ($_.Value.clean) { "[clean]" } else { "[dirty]" }
            Write-Host "  $($_.Name): $($_.Value.branch) $status"
        }
        Write-Host ""

        if ($snapshot.activeWorktrees.Count -gt 0) {
            Write-Host "ACTIVE WORKTREES:" -ForegroundColor Yellow
            $snapshot.activeWorktrees | ForEach-Object {
                Write-Host "  $($_.seat)/$($_.repo) @ $($_.branch)"
            }
            Write-Host ""
        }

        Write-Host "RECENT REFLECTIONS:" -ForegroundColor Yellow
        $snapshot.recentReflections | ForEach-Object {
            Write-Host "  $($_.date) [$($_.tag)]" -ForegroundColor DarkCyan
        }
        Write-Host ""

        Write-Host "SUMMARY: " -NoNewline -ForegroundColor White
        $s = $snapshot.summary
        Write-Host "$($s.freeSeats) free seats, $($s.busySeats) busy, $($s.toolCount) tools, $($s.skillCount) skills"
    }
}
