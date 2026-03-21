# agent-merge-queue.ps1
# FIFO merge queue with conflict detection
# Usage: agent-merge-queue.ps1 -Action <Add|List|Process|Remove> [params]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Add", "List", "Process", "Remove", "ProcessAll")]
    [string]$Action,

    # For Add
    [string]$Seat,
    [string]$Branch,
    [string]$Repo,
    [string]$Priority = "normal",  # low, normal, high, urgent

    # For Remove/Process
    [string]$QueueId
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error-Msg { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Warning-Msg { param([string]$msg) Write-Host "[!] $msg" -ForegroundColor Yellow }

$queueFile = "C:\scripts\_machine\agent-mail\merge-queue.json"

function Load-Queue {
    if (Test-Path $queueFile) {
        $content = Get-Content $queueFile -Raw | ConvertFrom-Json
        return $content.queue
    } else {
        return @()
    }
}

function Save-Queue {
    param($Queue)

    $data = @{
        queue = $Queue
        last_updated = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    } | ConvertTo-Json -Depth 10

    Set-Content -Path $queueFile -Value $data
}

function Add-ToQueue {
    param($Seat, $Branch, $Repo, $Priority)

    $queue = Load-Queue

    # Check for duplicates
    $existing = $queue | Where-Object { $_.seat -eq $Seat -and $_.branch -eq $Branch -and $_.repo -eq $Repo }
    if ($existing) {
        Write-Warning-Msg "Already in queue: $Seat/$Repo/$Branch"
        return $existing.id
    }

    # Generate ID
    $id = [guid]::NewGuid().ToString().Substring(0, 8)

    # Check for conflicts with develop
    $baseRepo = "C:\Projects\$Repo"
    if (-not (Test-Path $baseRepo)) {
        Write-Error-Msg "Repository not found: $baseRepo"
        return $null
    }

    Push-Location $baseRepo
    try {
        # Fetch latest
        git fetch origin develop 2>&1 | Out-Null

        # Check for conflicts
        $conflicts = git diff --name-only develop...$Branch 2>&1

        $hasConflicts = $false
        if ($conflicts -and $conflicts -notmatch "fatal") {
            $filesChanged = @($conflicts -split "`n" | Where-Object { $_ })

            # Check if these files conflict with other queued items
            $conflictingItems = @()
            foreach ($item in $queue) {
                if ($item.repo -eq $Repo -and $item.status -eq "pending") {
                    $overlap = Compare-Object $filesChanged $item.files_changed -IncludeEqual -ExcludeDifferent
                    if ($overlap) {
                        $conflictingItems += $item
                        $hasConflicts = $true
                    }
                }
            }
        }

        $entry = @{
            id = $id
            seat = $Seat
            branch = $Branch
            repo = $Repo
            priority = $Priority
            status = "pending"  # pending, processing, merged, failed
            added_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            has_conflicts = $hasConflicts
            files_changed = $filesChanged
            merge_attempts = 0
        }

        # Priority queue (urgent/high first)
        if ($Priority -eq "urgent") {
            $queue = @($entry) + $queue
        } elseif ($Priority -eq "high") {
            $insertIndex = 0
            foreach ($i in 0..($queue.Count - 1)) {
                if ($queue[$i].priority -ne "urgent") {
                    $insertIndex = $i
                    break
                }
            }
            $queue = $queue[0..($insertIndex-1)] + @($entry) + $queue[$insertIndex..($queue.Count-1)]
        } else {
            $queue += $entry
        }

        Save-Queue -Queue $queue

        Write-Success "Added to merge queue: $id ($Seat/$Repo/$Branch)"
        if ($hasConflicts) {
            Write-Warning-Msg "Potential conflicts detected with other queued items"
        }

        return $id

    } finally {
        Pop-Location
    }
}

function Show-Queue {
    $queue = Load-Queue

    if ($queue.Count -eq 0) {
        Write-Info "Merge queue is empty"
        return
    }

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  MERGE QUEUE ($($queue.Count) items)" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    foreach ($item in $queue) {
        $statusColor = switch ($item.status) {
            "pending" { "Yellow" }
            "processing" { "Cyan" }
            "merged" { "Green" }
            "failed" { "Red" }
            default { "White" }
        }

        $priorityIcon = switch ($item.priority) {
            "urgent" { "[!!!]" }
            "high" { "[!!]" }
            "normal" { "[!]" }
            default { "[-]" }
        }

        Write-Host "$priorityIcon " -NoNewline -ForegroundColor $(if ($item.priority -eq "urgent") { "Red" } else { "Yellow" })
        Write-Host "$($item.id) " -NoNewline -ForegroundColor Cyan
        Write-Host "[$($item.status)]" -ForegroundColor $statusColor
        Write-Host "  Seat:   $($item.seat)"
        Write-Host "  Repo:   $($item.repo)"
        Write-Host "  Branch: $($item.branch)"
        Write-Host "  Files:  $($item.files_changed.Count) changed"

        if ($item.has_conflicts) {
            Write-Host "  Conflicts: YES" -ForegroundColor Red
        }

        Write-Host ""
    }
}

function Process-QueueItem {
    param($QueueId)

    $queue = Load-Queue
    $item = $queue | Where-Object { $_.id -eq $QueueId }

    if (-not $item) {
        Write-Error-Msg "Queue item not found: $QueueId"
        return $false
    }

    if ($item.status -ne "pending") {
        Write-Warning-Msg "Item already processed: $QueueId ($($item.status))"
        return $false
    }

    Write-Info "Processing merge: $QueueId ($($item.seat)/$($item.repo)/$($item.branch))"

    # Update status to processing
    $item.status = "processing"
    $item.merge_attempts++
    Save-Queue -Queue $queue

    $baseRepo = "C:\Projects\$($item.repo)"
    if (-not (Test-Path $baseRepo)) {
        Write-Error-Msg "Repository not found: $baseRepo"
        $item.status = "failed"
        $item.error = "Repository not found"
        Save-Queue -Queue $queue
        return $false
    }

    Push-Location $baseRepo
    try {
        # Fetch latest
        git fetch origin develop 2>&1 | Out-Null
        git checkout develop 2>&1 | Out-Null

        # Attempt merge
        Write-Info "Merging $($item.branch) into develop..."

        $mergeOutput = git merge --no-ff $item.branch 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Merge successful"

            # Push to remote
            git push origin develop 2>&1 | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-Success "Pushed to origin/develop"

                $item.status = "merged"
                $item.merged_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                Save-Queue -Queue $queue

                # Notify agent
                & "C:\scripts\tools\agent-send-message.ps1" `
                    -From "merge-queue" `
                    -To $item.seat `
                    -Subject "Merge complete" `
                    -Body "Your branch $($item.branch) has been merged to develop." `
                    -Priority "normal" | Out-Null

                return $true
            } else {
                Write-Error-Msg "Failed to push to remote"
                git merge --abort 2>&1 | Out-Null

                $item.status = "failed"
                $item.error = "Push failed"
                Save-Queue -Queue $queue
                return $false
            }
        } else {
            Write-Error-Msg "Merge conflict detected"
            Write-Host $mergeOutput

            git merge --abort 2>&1 | Out-Null

            $item.status = "failed"
            $item.error = "Merge conflict"
            $item.conflict_details = $mergeOutput
            Save-Queue -Queue $queue

            # Notify agent
            & "C:\scripts\tools\agent-send-message.ps1" `
                -From "merge-queue" `
                -To $item.seat `
                -Subject "Merge conflict" `
                -Body "Your branch $($item.branch) has conflicts with develop. Please resolve and resubmit." `
                -Priority "high" | Out-Null

            return $false
        }

    } finally {
        Pop-Location
    }
}

function Process-All {
    $queue = Load-Queue
    $pending = @($queue | Where-Object { $_.status -eq "pending" })

    if ($pending.Count -eq 0) {
        Write-Info "No pending items in queue"
        return
    }

    Write-Info "Processing $($pending.Count) pending item(s)..."
    Write-Host ""

    $successful = 0
    $failed = 0

    foreach ($item in $pending) {
        $result = Process-QueueItem -QueueId $item.id

        if ($result) {
            $successful++
        } else {
            $failed++
            Write-Warning-Msg "Failed to merge $($item.id). Stopping queue processing."
            break  # Stop on first failure to avoid cascading conflicts
        }

        Write-Host ""
    }

    Write-Host ""
    Write-Success "$successful merged, $failed failed"
}

function Remove-FromQueue {
    param($QueueId)

    $queue = Load-Queue
    $newQueue = @($queue | Where-Object { $_.id -ne $QueueId })

    if ($newQueue.Count -eq $queue.Count) {
        Write-Warning-Msg "Queue item not found: $QueueId"
        return
    }

    Save-Queue -Queue $newQueue
    Write-Success "Removed from queue: $QueueId"
}

# Execute action
switch ($Action) {
    "Add" {
        if (-not $Seat -or -not $Branch -or -not $Repo) {
            Write-Error-Msg "-Seat, -Branch, and -Repo required for Add"
            exit 1
        }
        Add-ToQueue -Seat $Seat -Branch $Branch -Repo $Repo -Priority $Priority
    }
    "List" {
        Show-Queue
    }
    "Process" {
        if (-not $QueueId) {
            Write-Error-Msg "-QueueId required for Process"
            exit 1
        }
        Process-QueueItem -QueueId $QueueId
    }
    "ProcessAll" {
        Process-All
    }
    "Remove" {
        if (-not $QueueId) {
            Write-Error-Msg "-QueueId required for Remove"
            exit 1
        }
        Remove-FromQueue -QueueId $QueueId
    }
}
