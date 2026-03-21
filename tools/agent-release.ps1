# agent-release.ps1
# Release an agent after task completion
# Usage: agent-release.ps1 -Seat agent-001 [-Archive] [-Force]

param(
    [Parameter(Mandatory=$true)]
    [string]$Seat,

    [switch]$Archive,  # Archive messages instead of deleting
    [switch]$Force     # Force release even if uncommitted changes
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error-Msg { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Warning-Msg { param([string]$msg) Write-Host "[!] $msg" -ForegroundColor Yellow }

Write-Info "Agent Release: $Seat"
Write-Host ""

$poolFile = "C:\scripts\_machine\worktrees.pool.md"
$seatPath = "C:\Projects\worker-agents\$Seat"
$mailDir = "C:\scripts\_machine\agent-mail"

# 1. Check seat exists and is BUSY
if (-not (Test-Path $poolFile)) {
    Write-Error-Msg "Pool file not found: $poolFile"
    exit 1
}

$poolContent = Get-Content $poolFile -Raw
$seatMatch = $poolContent | Select-String -Pattern "\| $Seat \|[^|]*\|[^|]*\|[^|]*\| BUSY \|"

if (-not $seatMatch) {
    Write-Warning-Msg "Seat $Seat is not BUSY. Current state:"
    $currentState = $poolContent | Select-String -Pattern "\| $Seat \|[^|]*" | Select-Object -First 1
    Write-Host "  $($currentState.Line)"
    Write-Host ""

    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y') {
        exit 0
    }
}

# 2. Check for uncommitted changes
Write-Info "Checking for uncommitted changes..."

$hasChanges = $false
if (Test-Path $seatPath) {
    $repos = Get-ChildItem -Path $seatPath -Directory | Where-Object { Test-Path "$($_.FullName)\.git" }

    foreach ($repo in $repos) {
        Push-Location $repo.FullName
        try {
            $status = git status --porcelain
            if ($status) {
                Write-Warning-Msg "Uncommitted changes in $($repo.Name):"
                Write-Host $status
                $hasChanges = $true
            } else {
                Write-Success "Clean: $($repo.Name)"
            }
        } finally {
            Pop-Location
        }
    }
}

if ($hasChanges -and -not $Force) {
    Write-Host ""
    Write-Error-Msg "Uncommitted changes detected. Options:"
    Write-Host "  1. Commit changes first"
    Write-Host "  2. Use -Force to release anyway (changes will be lost)"
    Write-Host ""
    exit 1
}

# 3. Archive or delete messages
Write-Info "Managing messages..."

$inboxFile = "$mailDir\inbox\$Seat.jsonl"
$sentFile = "$mailDir\sent\$Seat.jsonl"

if (Test-Path $inboxFile) {
    $messageCount = (Get-Content $inboxFile).Count

    if ($Archive) {
        $timestamp = (Get-Date).ToString('yyyy-MM-dd-HHmmss')
        $archiveFile = "$mailDir\archive\$Seat-$timestamp.jsonl"

        Move-Item -Path $inboxFile -Destination $archiveFile
        Write-Success "Archived $messageCount inbox messages to $archiveFile"
    } else {
        Remove-Item -Path $inboxFile
        Write-Success "Deleted $messageCount inbox messages"
    }
}

if (Test-Path $sentFile) {
    $sentCount = (Get-Content $sentFile).Count

    if ($Archive) {
        $timestamp = (Get-Date).ToString('yyyy-MM-dd-HHmmss')
        $archiveFile = "$mailDir\archive\$Seat-sent-$timestamp.jsonl"

        Move-Item -Path $sentFile -Destination $archiveFile
        Write-Success "Archived $sentCount sent messages"
    } else {
        Remove-Item -Path $sentFile
        Write-Success "Deleted $sentCount sent messages"
    }
}

# 4. Remove worktrees
Write-Info "Removing worktrees..."

if (Test-Path $seatPath) {
    $repos = Get-ChildItem -Path $seatPath -Directory | Where-Object { Test-Path "$($_.FullName)\.git" }

    foreach ($repo in $repos) {
        $repoName = $repo.Name
        $baseRepo = "C:\Projects\$repoName"

        if (Test-Path $baseRepo) {
            Write-Info "Removing worktree: $repoName"

            Push-Location $baseRepo
            try {
                # Get branch name before removing worktree
                Push-Location $repo.FullName
                $branch = git branch --show-current
                Pop-Location

                # Remove worktree
                git worktree remove $repo.FullName --force 2>&1 | Out-Null

                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Worktree removed: $repoName"

                    # Ask about branch deletion
                    Write-Host ""
                    Write-Host "  Branch: $branch"
                    $deleteBranch = Read-Host "  Delete branch? (y/n)"

                    if ($deleteBranch -eq 'y') {
                        git branch -D $branch 2>&1 | Out-Null
                        Write-Success "Branch deleted: $branch"
                    } else {
                        Write-Info "Branch preserved: $branch"
                    }
                } else {
                    Write-Warning-Msg "Failed to remove worktree for $repoName"
                }
            } finally {
                Pop-Location
            }
        }
    }

    # Remove seat directory if empty
    $remainingFiles = Get-ChildItem -Path $seatPath -Recurse -File
    if ($remainingFiles.Count -eq 0) {
        Remove-Item -Path $seatPath -Recurse -Force
        Write-Success "Removed empty seat directory"
    } else {
        Write-Warning-Msg "Seat directory not empty (has $($remainingFiles.Count) files)"
    }
}

# 5. Remove agent context
$contextFile = "$seatPath\agent-context.json"
$overlayFile = "$seatPath\CLAUDE_OVERLAY.md"

if (Test-Path $contextFile) {
    Remove-Item -Path $contextFile
    Write-Success "Removed agent context"
}

if (Test-Path $overlayFile) {
    Remove-Item -Path $overlayFile
    Write-Success "Removed CLAUDE overlay"
}

# 6. Update pool - mark as FREE
Write-Info "Updating pool..."

$poolContent = Get-Content $poolFile -Raw
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

# Update pool entry
$pattern = "\| $Seat \|([^|]*)\|([^|]*)\|([^|]*)\| BUSY \|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|"
$replacement = "| $Seat |`$1|`$2|`$3| FREE |`$4|`$5| $timestamp | Released |"
$poolContent = $poolContent -replace $pattern, $replacement

Set-Content -Path $poolFile -Value $poolContent -NoNewline

Write-Success "Pool updated: $Seat marked FREE"

# 7. Summary
Write-Host ""
Write-Success "Agent $Seat Released Successfully!"
Write-Host ""
Write-Host "  Status: FREE"
Write-Host "  Worktrees: Removed"
Write-Host "  Messages: $(if ($Archive) { 'Archived' } else { 'Deleted' })"
Write-Host "  Pool: Updated"
Write-Host ""
Write-Info "Seat $Seat is now available for new tasks"
Write-Host ""
