# Session State Manager - R04-001 & R04-002
# Save and load session state for cross-session continuity
# Experts: Dr. Amara Johnson (Session Management) + Lisa Chen (Context Switching)

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('save', 'load', 'info', 'clear')]
    [string]$Action = 'info',

    [Parameter(Mandatory=$false)]
    [string]$SessionId
)

$SessionDir = "C:\scripts\_machine\sessions"
$CurrentSessionFile = "$SessionDir\current-session.json"
$LastSessionFile = "$SessionDir\last-session.json"

function Save-SessionState {
    Write-Host "Saving session state..." -ForegroundColor Cyan

    $sessionId = $env:CLAUDE_SESSION_ID ?? (Get-Date -Format 'yyyyMMdd-HHmmss')

    # Collect session state
    $state = @{
        'session_id' = $sessionId
        'saved_at' = Get-Date -Format 'o'
        'query_history' = @()
        'files_accessed' = @()
        'decisions_made' = @()
        'open_tasks' = @()
        'worktrees_allocated' = @()
        'hot_cache_keys' = @()
        'current_branch' = ''
        'working_directory' = $PWD.Path
    }

    # Load conversation sequences if available
    $sequenceFile = "C:\scripts\_machine\knowledge-system\sequences.jsonl"
    if (Test-Path $sequenceFile) {
        $sequences = Get-Content $sequenceFile -Tail 10 | ForEach-Object { $_ | ConvertFrom-Json }
        $state.query_history = $sequences | ForEach-Object { $_.query }

        # Extract unique files accessed
        $allFiles = @()
        foreach ($seq in $sequences) {
            if ($seq.context_files) {
                $allFiles += $seq.context_files
            }
        }
        $state.files_accessed = $allFiles | Select-Object -Unique
    }

    # Get current git branch
    try {
        $branch = git -C C:\Projects\client-manager branch --show-current 2>$null
        if ($branch) {
            $state.current_branch = $branch.Trim()
        }
    } catch {
        # Ignore git errors
    }

    # Check for open tasks (if task system is used)
    $taskFile = "C:\scripts\_machine\tasks.json"
    if (Test-Path $taskFile) {
        $tasks = Get-Content $taskFile -Raw | ConvertFrom-Json
        $state.open_tasks = $tasks | Where-Object { $_.status -ne 'completed' } | ForEach-Object { $_.subject }
    }

    # Check worktree pool for allocations
    $poolFile = "C:\scripts\_machine\worktrees.pool.md"
    if (Test-Path $poolFile) {
        $poolContent = Get-Content $poolFile -Raw
        if ($poolContent -match 'BUSY') {
            $state.worktrees_allocated = @("Check worktrees.pool.md for details")
        }
    }

    # Save to session-specific file
    $sessionFile = "$SessionDir\session-$sessionId.json"
    $state | ConvertTo-Json -Depth 10 | Out-File $sessionFile -Encoding UTF8

    # Also save as current and last
    $state | ConvertTo-Json -Depth 10 | Out-File $CurrentSessionFile -Encoding UTF8
    $state | ConvertTo-Json -Depth 10 | Out-File $LastSessionFile -Encoding UTF8

    Write-Host "Session state saved:" -ForegroundColor Green
    Write-Host "  Session ID: $sessionId" -ForegroundColor Gray
    Write-Host "  Queries: $($state.query_history.Count)" -ForegroundColor Gray
    Write-Host "  Files: $($state.files_accessed.Count)" -ForegroundColor Gray
    Write-Host "  Open tasks: $($state.open_tasks.Count)" -ForegroundColor Gray
    Write-Host "  File: $sessionFile" -ForegroundColor Gray
}

function Load-SessionState {
    param([string]$SessionId)

    Write-Host "Loading session state..." -ForegroundColor Cyan

    $sessionFile = $null

    if ($SessionId) {
        $sessionFile = "$SessionDir\session-$SessionId.json"
    } elseif (Test-Path $LastSessionFile) {
        $sessionFile = $LastSessionFile
    } else {
        Write-Host "No session to load" -ForegroundColor Yellow
        return $null
    }

    if (-not (Test-Path $sessionFile)) {
        Write-Host "Session file not found: $sessionFile" -ForegroundColor Red
        return $null
    }

    $state = Get-Content $sessionFile -Raw | ConvertFrom-Json

    Write-Host "`n" -NoNewline
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    SESSION RESUMED                         ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

    Write-Host "`nSession ID: " -NoNewline -ForegroundColor Gray
    Write-Host $state.session_id -ForegroundColor Yellow

    Write-Host "Saved at: " -NoNewline -ForegroundColor Gray
    Write-Host $state.saved_at -ForegroundColor Yellow

    if ($state.query_history -and $state.query_history.Count -gt 0) {
        Write-Host "`nLast $($state.query_history.Count) queries:" -ForegroundColor Green
        $state.query_history[-5..-1] | ForEach-Object {
            Write-Host "  → $_" -ForegroundColor Gray
        }
    }

    if ($state.files_accessed -and $state.files_accessed.Count -gt 0) {
        Write-Host "`nFiles accessed ($($state.files_accessed.Count)):" -ForegroundColor Green
        $state.files_accessed | Select-Object -First 5 | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Gray
        }
        if ($state.files_accessed.Count -gt 5) {
            Write-Host "  ... and $($state.files_accessed.Count - 5) more" -ForegroundColor DarkGray
        }
    }

    if ($state.open_tasks -and $state.open_tasks.Count -gt 0) {
        Write-Host "`nOpen tasks ($($state.open_tasks.Count)):" -ForegroundColor Green
        $state.open_tasks | ForEach-Object {
            Write-Host "  ☐ $_" -ForegroundColor Yellow
        }
    }

    if ($state.worktrees_allocated -and $state.worktrees_allocated.Count -gt 0) {
        Write-Host "`nAllocated worktrees:" -ForegroundColor Green
        $state.worktrees_allocated | ForEach-Object {
            Write-Host "  ⚙ $_" -ForegroundColor Cyan
        }
    }

    if ($state.current_branch) {
        Write-Host "`nGit branch: " -NoNewline -ForegroundColor Gray
        Write-Host $state.current_branch -ForegroundColor Magenta
    }

    Write-Host "`nWorking directory: " -NoNewline -ForegroundColor Gray
    Write-Host $state.working_directory -ForegroundColor Gray

    Write-Host "`n" -NoNewline
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Ready to continue where you left off!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    return $state
}

function Get-SessionInfo {
    Write-Host "`nSession State Information:" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan

    # List available sessions
    $sessions = Get-ChildItem "$SessionDir\session-*.json" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10

    if ($sessions) {
        Write-Host "`nRecent sessions:" -ForegroundColor Yellow
        foreach ($session in $sessions) {
            $state = Get-Content $session.FullName -Raw | ConvertFrom-Json
            Write-Host "  $($state.session_id) - $($state.saved_at) - $($state.query_history.Count) queries" -ForegroundColor Gray
        }
    } else {
        Write-Host "No saved sessions found" -ForegroundColor Yellow
    }

    # Show last session summary
    if (Test-Path $LastSessionFile) {
        Write-Host "`nLast session available for quick resume" -ForegroundColor Green

        $last = Get-Content $LastSessionFile -Raw | ConvertFrom-Json
        Write-Host "  ID: $($last.session_id)" -ForegroundColor Gray
        Write-Host "  Saved: $($last.saved_at)" -ForegroundColor Gray
        Write-Host "  Queries: $($last.query_history.Count)" -ForegroundColor Gray
    } else {
        Write-Host "`nNo last session available" -ForegroundColor Yellow
    }
}

function Clear-SessionState {
    if (Test-Path $CurrentSessionFile) {
        Remove-Item $CurrentSessionFile -Force
        Write-Host "Cleared current session state" -ForegroundColor Yellow
    }

    if (Test-Path $LastSessionFile) {
        Remove-Item $LastSessionFile -Force
        Write-Host "Cleared last session state" -ForegroundColor Yellow
    }
}

# Main execution
switch ($Action) {
    'save' {
        Save-SessionState
    }
    'load' {
        Load-SessionState -SessionId $SessionId
    }
    'info' {
        Get-SessionInfo
    }
    'clear' {
        Clear-SessionState
    }
}
