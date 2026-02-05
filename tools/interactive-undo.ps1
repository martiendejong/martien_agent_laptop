# interactive-undo.ps1
# Undo system for reversing agent actions
# Tracks operations and enables rollback

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Record", "Undo", "History", "Clear")]
    [string]$Action,

    [string]$OperationType = "",  # git, file, worktree, etc.
    [string]$Description = "",
    [hashtable]$UndoCommand = @{},
    [int]$Steps = 1
)

$script:UndoStack = "C:\scripts\_machine\undo-stack.json"
$script:MaxUndoSteps = 50

function Get-UndoStack {
    if (Test-Path $script:UndoStack) {
        $content = Get-Content $script:UndoStack -Raw | ConvertFrom-Json
        # Convert to array if single item
        if ($content -is [PSCustomObject]) {
            return @($content)
        }
        return $content
    }
    return @()
}

function Set-UndoStack {
    param([array]$Stack)
    # Limit stack size
    if ($Stack.Count -gt $script:MaxUndoSteps) {
        $Stack = $Stack | Select-Object -First $script:MaxUndoSteps
    }
    $Stack | ConvertTo-Json -Depth 10 | Set-Content -Path $script:UndoStack -Force
}

function Add-UndoEntry {
    param(
        [string]$Type,
        [string]$Description,
        [hashtable]$UndoCmd
    )

    $stack = @(Get-UndoStack)

    $entry = @{
        Id = [guid]::NewGuid().ToString()
        Type = $Type
        Description = $Description
        UndoCommand = $UndoCmd
        Timestamp = (Get-Date).ToString("o")
        Executed = $false
    }

    # Add to front of stack
    $stack = @($entry) + $stack

    Set-UndoStack -Stack $stack

    Write-Host "✅ Operation recorded for undo" -ForegroundColor Green
    Write-Host "   Type: $Type" -ForegroundColor Gray
    Write-Host "   Description: $Description" -ForegroundColor Gray
    Write-Host "   ID: $($entry.Id)" -ForegroundColor DarkGray
}

function Invoke-Undo {
    param([int]$Steps)

    $stack = @(Get-UndoStack)

    if ($stack.Count -eq 0) {
        Write-Host "❌ Nothing to undo" -ForegroundColor Yellow
        return
    }

    $stepsToUndo = [Math]::Min($Steps, $stack.Count)

    Write-Host "⏪ Undoing last $stepsToUndo operation(s)..." -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $stepsToUndo; $i++) {
        $entry = $stack[$i]

        if ($entry.Executed) {
            Write-Host "⏭️ Skipping already undone: $($entry.Description)" -ForegroundColor Gray
            continue
        }

        Write-Host "[$($i + 1)/$stepsToUndo] Undoing: $($entry.Description)" -ForegroundColor Cyan

        $undoCmd = $entry.UndoCommand

        try {
            switch ($entry.Type) {
                "git" {
                    # Execute git command
                    $cmd = $undoCmd.Command
                    Write-Host "   Running: $cmd" -ForegroundColor Gray
                    Invoke-Expression $cmd
                }
                "file" {
                    # Restore file
                    if ($undoCmd.Action -eq "delete") {
                        # Restore from backup
                        $backupPath = $undoCmd.BackupPath
                        $originalPath = $undoCmd.OriginalPath
                        if (Test-Path $backupPath) {
                            Copy-Item $backupPath $originalPath -Force
                            Write-Host "   ✅ Restored: $originalPath" -ForegroundColor Green
                        } else {
                            Write-Host "   ❌ Backup not found: $backupPath" -ForegroundColor Red
                        }
                    }
                    elseif ($undoCmd.Action -eq "modify") {
                        # Restore previous version
                        $backupPath = $undoCmd.BackupPath
                        $filePath = $undoCmd.FilePath
                        if (Test-Path $backupPath) {
                            Copy-Item $backupPath $filePath -Force
                            Write-Host "   ✅ Restored previous version: $filePath" -ForegroundColor Green
                        }
                    }
                }
                "worktree" {
                    # Release worktree
                    $seat = $undoCmd.Seat
                    & "C:\scripts\tools\worktree-lock.ps1" -Action Release -Seat $seat
                    Write-Host "   ✅ Released worktree: $seat" -ForegroundColor Green
                }
                "command" {
                    # Generic PowerShell command
                    $cmd = $undoCmd.Command
                    Write-Host "   Running: $cmd" -ForegroundColor Gray
                    Invoke-Expression $cmd
                }
                default {
                    Write-Host "   ⚠️ Unknown undo type: $($entry.Type)" -ForegroundColor Yellow
                }
            }

            $entry.Executed = $true
            Write-Host "   ✅ Undo successful" -ForegroundColor Green

        }
        catch {
            Write-Host "   ❌ Undo failed: $_" -ForegroundColor Red
        }

        Write-Host ""
    }

    # Save updated stack
    Set-UndoStack -Stack $stack

    Write-Host "✅ Undo complete" -ForegroundColor Green
}

function Show-UndoHistory {
    $stack = @(Get-UndoStack)

    if ($stack.Count -eq 0) {
        Write-Host "No undo history" -ForegroundColor Gray
        return
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "⏪ UNDO HISTORY" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    for ($i = 0; $i -lt $stack.Count; $i++) {
        $entry = $stack[$i]
        $age = ((Get-Date) - [DateTime]$entry.Timestamp).TotalMinutes

        $statusEmoji = if ($entry.Executed) { "✅" } else { "⏳" }
        $typeEmoji = switch ($entry.Type) {
            "git" { "🔀" }
            "file" { "📄" }
            "worktree" { "🌳" }
            "command" { "⚙️" }
            default { "📦" }
        }

        Write-Host "`n$statusEmoji [$($i + 1)] $typeEmoji $($entry.Description)" -ForegroundColor $(if ($entry.Executed) { "Gray" } else { "White" })
        Write-Host "   Type: $($entry.Type) | Age: $([math]::Round($age, 1))m | Status: $(if ($entry.Executed) { 'Undone' } else { 'Pending' })" -ForegroundColor DarkGray
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Total: $($stack.Count) operations | Can undo: $(($stack | Where-Object { -not $_.Executed }).Count)" -ForegroundColor Gray
    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Clear-UndoHistory {
    if (Test-Path $script:UndoStack) {
        Remove-Item $script:UndoStack -Force
        Write-Host "✅ Undo history cleared" -ForegroundColor Green
    } else {
        Write-Host "⚠️ No undo history to clear" -ForegroundColor Yellow
    }
}

# Main logic
switch ($Action) {
    "Record" {
        if (-not $OperationType -or -not $Description) {
            Write-Host "❌ Record requires -OperationType and -Description" -ForegroundColor Red
            exit 1
        }

        Add-UndoEntry -Type $OperationType -Description $Description -UndoCmd $UndoCommand
        exit 0
    }

    "Undo" {
        Invoke-Undo -Steps $Steps
        exit 0
    }

    "History" {
        Show-UndoHistory
        exit 0
    }

    "Clear" {
        Clear-UndoHistory
        exit 0
    }
}
