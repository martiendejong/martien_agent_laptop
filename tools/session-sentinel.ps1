<#
.SYNOPSIS
    Background sentinel that monitors Claude process and writes clean exit marker when it exits.

.DESCRIPTION
    Runs in the background, watching for the Claude process to exit.
    When Claude exits (for ANY reason - normal, Ctrl+C, terminal close, kill),
    this sentinel writes the clean exit marker.

    This is the ONLY reliable way to detect session end because:
    - Ctrl+C kills the batch script before post-exit code runs
    - Closing terminal kills everything
    - Only a separate background process survives

.PARAMETER ClaudePid
    The process ID of the Claude process to monitor.
    Use 0 for discovery mode (finds Claude's node process automatically).

.PARAMETER Project
    The project name for session tracking (default: C--scripts)
#>

param(
    [Parameter(Mandatory=$true)]
    [int]$ClaudePid,

    [string]$Project = "C--scripts"
)

# Configuration
$TrackerFile = "C:\scripts\_machine\session-tracker.json"
$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"
$LogFile = "C:\scripts\logs\session-sentinel.log"
$LaunchMarker = "C:\scripts\logs\.claude-launch-time"

function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

Write-Log "=== Sentinel started (requested PID: $ClaudePid) ==="

try {
    # Discovery mode: find Claude's node process
    if ($ClaudePid -eq 0) {
        Write-Log "Discovery mode: looking for Claude's node process..."

        # Read launch timestamp
        $launchTime = if (Test-Path $LaunchMarker) {
            [DateTime]::Parse((Get-Content $LaunchMarker -Raw).Trim())
        } else {
            (Get-Date).AddSeconds(-10)
        }
        Write-Log "Launch time: $($launchTime.ToString('o'))"

        # Poll for new node process (Claude runs on Node.js)
        $process = $null
        $maxAttempts = 60  # Wait up to 60 seconds
        $attempt = 0

        while (-not $process -and $attempt -lt $maxAttempts) {
            Start-Sleep -Seconds 1
            $attempt++

            # Look for node processes started after launch time
            # that have "claude" in their command line
            $candidates = Get-Process -Name "node" -ErrorAction SilentlyContinue |
                Where-Object { $_.StartTime -ge $launchTime.AddSeconds(-2) }

            foreach ($candidate in $candidates) {
                try {
                    $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($candidate.Id)" -ErrorAction SilentlyContinue).CommandLine
                    if ($cmdLine -and $cmdLine -match "claude") {
                        $process = $candidate
                        $ClaudePid = $candidate.Id
                        Write-Log "Found Claude process! PID: $ClaudePid (attempt $attempt)"
                        Write-Log "Command: $cmdLine"
                        break
                    }
                } catch {
                    # Skip processes we can't inspect
                }
            }

            if (-not $process -and ($attempt % 10 -eq 0)) {
                Write-Log "Still searching... (attempt $attempt/$maxAttempts)"
            }
        }

        if (-not $process) {
            Write-Log "WARNING: Could not find Claude process after $maxAttempts attempts."
            Write-Log "Falling back to monitoring latest session file for changes."

            # Fallback: monitor the session directory for file changes
            $projectPath = Join-Path $ClaudeProjectsPath $Project
            if (Test-Path $projectPath) {
                $initialSession = Get-ChildItem -Path $projectPath -Filter "*.jsonl" -File |
                    Sort-Object LastWriteTime -Descending |
                    Select-Object -First 1

                if ($initialSession) {
                    Write-Log "Monitoring session file: $($initialSession.Name)"
                    $lastSize = $initialSession.Length
                    $staleCount = 0

                    # Wait until file stops growing for 30+ seconds (Claude exited)
                    while ($staleCount -lt 30) {
                        Start-Sleep -Seconds 2
                        $initialSession.Refresh()
                        $currentSize = $initialSession.Length

                        if ($currentSize -eq $lastSize) {
                            $staleCount++
                        } else {
                            $staleCount = 0
                            $lastSize = $currentSize
                        }
                    }
                    Write-Log "Session file stopped growing. Claude likely exited."
                }
            }
        }
    }

    # Direct PID monitoring mode
    if ($ClaudePid -gt 0) {
        $process = Get-Process -Id $ClaudePid -ErrorAction SilentlyContinue

        if (-not $process) {
            Write-Log "Process $ClaudePid not found. May have already exited."
        } else {
            Write-Log "Watching process: $($process.ProcessName) (PID: $ClaudePid)"
            $process.WaitForExit()
            Write-Log "Claude process exited. Exit code: $($process.ExitCode)"
        }
    }

    # Small delay to let Claude flush its session file
    Start-Sleep -Seconds 3

    # Find the most recently modified session file
    $projectPath = Join-Path $ClaudeProjectsPath $Project
    if (Test-Path $projectPath) {
        $latestSession = Get-ChildItem -Path $projectPath -Filter "*.jsonl" -File |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if ($latestSession) {
            $sessionId = [System.IO.Path]::GetFileNameWithoutExtension($latestSession.Name)
            $exitTime = (Get-Date).ToString("o")

            # Load tracker
            if (Test-Path $TrackerFile) {
                $tracker = Get-Content $TrackerFile -Raw | ConvertFrom-Json
            } else {
                $tracker = @{
                    clean_exits = @()
                    last_start_time = $null
                    last_clean_exit_time = $null
                    last_clean_exit_session = $null
                } | ConvertTo-Json | ConvertFrom-Json
            }

            # Create exit record
            $exitRecord = @{
                session_id = $sessionId
                timestamp = $exitTime
                project = $Project
                file_path = $latestSession.FullName
                size_kb = [math]::Round($latestSession.Length / 1KB, 1)
                exit_method = "sentinel"
                claude_pid = $ClaudePid
            }

            # Add to clean exits
            if ($tracker.clean_exits -is [System.Array]) {
                $tracker.clean_exits = @($tracker.clean_exits) + $exitRecord
            } else {
                $tracker.clean_exits = @($exitRecord)
            }

            # Keep only last 100
            if ($tracker.clean_exits.Count -gt 100) {
                $tracker.clean_exits = $tracker.clean_exits | Select-Object -Last 100
            }

            $tracker.last_clean_exit_time = $exitTime
            $tracker.last_clean_exit_session = $sessionId

            # Save
            $tracker | ConvertTo-Json -Depth 10 | Out-File $TrackerFile -Encoding UTF8

            Write-Log "Clean exit recorded! Session: $($sessionId.Substring(0,8))... Size: $($exitRecord.size_kb) KB"
        } else {
            Write-Log "WARNING: No session file found in $projectPath"
        }
    } else {
        Write-Log "WARNING: Project path not found: $projectPath"
    }

    # Also do git checkpoint
    Push-Location "C:\scripts"
    git add . 2>&1 | Out-Null
    git commit -m "checkpoint after agent session (sentinel)" 2>&1 | Out-Null
    Pop-Location
    Write-Log "Git checkpoint committed."

} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
} finally {
    # Clean up launch marker
    if (Test-Path $LaunchMarker) { Remove-Item $LaunchMarker -Force -ErrorAction SilentlyContinue }
    Write-Log "=== Sentinel exiting ==="
}
