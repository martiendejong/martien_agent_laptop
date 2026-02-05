# Session Snapshot System - Round 4
# Captures full session state for restore on next startup

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "save"
)

$snapshotDir = "C:\scripts\_machine\session-snapshots"
$currentSnapshot = Join-Path $snapshotDir "current-session.json"
$timestampSnapshot = Join-Path $snapshotDir "session-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

if (-not (Test-Path $snapshotDir)) {
    New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null
}

function Save-Snapshot {
    $snapshot = @{
        timestamp = Get-Date -Format "o"
        session_id = $env:CLAUDE_SESSION_ID ?? "unknown"
        working_directory = Get-Location
        git_status = @{
            branch = (git branch --show-current 2>$null)
            uncommitted_changes = (git status --short 2>$null)
        }
        active_worktrees = @()
        open_tasks = @()
        recent_files = @()
        context_state = @{
            loaded_files = @()
            predictions_active = $true
        }
        environment_vars = @{
            Path = $env:PATH
            CLAUDE_SESSION_ID = $env:CLAUDE_SESSION_ID
        }
    }

    # Save both current and timestamped versions
    $snapshot | ConvertTo-Json -Depth 10 | Set-Content $currentSnapshot
    $snapshot | ConvertTo-Json -Depth 10 | Set-Content $timestampSnapshot

    Write-Host "Session snapshot saved: $timestampSnapshot" -ForegroundColor Green
}

function Restore-Snapshot {
    if (Test-Path $currentSnapshot) {
        $snapshot = Get-Content $currentSnapshot -Raw | ConvertFrom-Json

        Write-Host "`n=== Restoring Session ===" -ForegroundColor Cyan
        Write-Host "Previous session: $($snapshot.timestamp)" -ForegroundColor Yellow
        Write-Host "Working directory: $($snapshot.working_directory)" -ForegroundColor White

        # Restore working directory
        if (Test-Path $snapshot.working_directory) {
            Set-Location $snapshot.working_directory
            Write-Host "Restored working directory" -ForegroundColor Green
        }

        return $snapshot
    } else {
        Write-Host "No previous session to restore" -ForegroundColor Yellow
        return $null
    }
}

switch ($Action) {
    "save" { Save-Snapshot }
    "restore" { return Restore-Snapshot }
    "list" {
        Get-ChildItem $snapshotDir -Filter "session-*.json" |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 10 Name, LastWriteTime
    }
}
