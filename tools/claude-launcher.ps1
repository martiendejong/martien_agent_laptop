<#
.SYNOPSIS
    Launches Claude Code with a background sentinel for reliable session tracking.

.DESCRIPTION
    1. Launches a sentinel process (detached, hidden) that will discover Claude's PID
    2. Runs Claude Code interactively in the current console
    3. When Claude exits (any reason: normal, Ctrl+C, kill), sentinel detects it
       and writes the clean exit marker to session-tracker.json

.PARAMETER SystemPrompt
    The system prompt to pass to Claude via --append-system-prompt
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$SystemPrompt
)

$LogFile = "C:\scripts\logs\claude-launcher.log"
$SentinelScript = "C:\scripts\tools\session-sentinel.ps1"

function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Ensure log directory
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Write-Log "=== Claude Launcher Starting ==="

# Snapshot existing node PIDs before starting Claude
$existingNodePids = @(Get-Process -Name "node" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
Write-Log "Existing node PIDs: $($existingNodePids -join ', ')"

# Write launch timestamp for sentinel to use
$launchMarker = "C:\scripts\logs\.claude-launch-time"
(Get-Date).ToString("o") | Out-File -FilePath $launchMarker -Encoding UTF8 -NoNewline

# Launch sentinel as a FULLY DETACHED process using WMI
# WMI Win32_Process.Create() spawns a process with NO parent-child console link.
# This means the sentinel survives even when:
# - The terminal window X button is clicked
# - The orchestration tool kills the terminal
# - taskkill /T is used on the parent process tree
$sentinelCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$SentinelScript`" -ClaudePid 0"

$wmiResult = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
    CommandLine = $sentinelCmd
}

if ($wmiResult.ReturnValue -eq 0) {
    $sentinelPid = $wmiResult.ProcessId
    Write-Log "Sentinel launched via WMI (PID: $sentinelPid) - fully detached from console"
} else {
    Write-Log "WARNING: WMI launch failed (code: $($wmiResult.ReturnValue)). Falling back to Start-Process."
    $sentinelProc = Start-Process -FilePath "powershell.exe" `
        -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $SentinelScript, "-ClaudePid", "0") `
        -WindowStyle Hidden `
        -PassThru
    $sentinelPid = $sentinelProc.Id
    Write-Log "Sentinel launched via Start-Process fallback (PID: $sentinelPid)"
}

Write-Log "Sentinel PID: $sentinelPid"

# Run Claude Code interactively - this blocks until Claude exits
Write-Log "Starting Claude Code interactively..."
try {
    claude --dangerously-skip-permissions --append-system-prompt $SystemPrompt --model sonnet
} catch {
    Write-Log "Claude exited with error: $($_.Exception.Message)"
}

Write-Log "Claude has exited. Sentinel will handle cleanup."
Write-Log "=== Claude Launcher Finished ==="
