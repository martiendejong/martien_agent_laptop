<#
.SYNOPSIS
    Manages active Claude Code sessions for crash detection.

.DESCRIPTION
    Tracks currently running sessions in active-sessions.json.
    - Register: Called when session starts (adds to file)
    - Unregister: Called when session ends cleanly (removes from file)
    - List: Shows all active sessions
    - Crashed: Shows sessions that weren't properly closed (survived restart)

.PARAMETER Action
    register, unregister, list, crashed

.PARAMETER SessionId
    The session ID (GUID) - required for register/unregister

.PARAMETER Project
    Project folder (default: C--scripts)

.PARAMETER SessionFile
    Full path to session .jsonl file (for context)

.EXAMPLE
    .\active-session.ps1 -Action register -SessionId "abc-123" -Project "C--scripts"
    .\active-session.ps1 -Action unregister -SessionId "abc-123"
    .\active-session.ps1 -Action list
    .\active-session.ps1 -Action crashed
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("register", "unregister", "list", "crashed")]
    [string]$Action,

    [string]$SessionId,
    [string]$Project = "C--scripts",
    [string]$SessionFile,
    [switch]$Json,
    [switch]$ShowContext
)

$ErrorActionPreference = "Stop"
$ActiveSessionsFile = "C:\scripts\_machine\active-sessions.json"
$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"

# Ensure file exists
if (-not (Test-Path $ActiveSessionsFile)) {
    @{
        description = "Tracks currently active Claude Code sessions. Sessions remaining after restart = crashed."
        sessions = @{}
    } | ConvertTo-Json -Depth 5 | Out-File $ActiveSessionsFile -Encoding UTF8
}

# Load current state
$data = Get-Content $ActiveSessionsFile -Raw | ConvertFrom-Json
if (-not $data.sessions) {
    $data | Add-Member -NotePropertyName "sessions" -NotePropertyValue @{} -Force
}

# Convert sessions to hashtable for easier manipulation
$sessions = @{}
$data.sessions.PSObject.Properties | ForEach-Object {
    $sessions[$_.Name] = $_.Value
}

function Save-Sessions {
    $output = @{
        description = "Tracks currently active Claude Code sessions. Sessions remaining after restart = crashed."
        sessions = $sessions
        last_updated = (Get-Date).ToString("o")
    }
    $output | ConvertTo-Json -Depth 10 | Out-File $ActiveSessionsFile -Encoding UTF8
}

function Get-LastUserMessage {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) { return "" }

    try {
        $lines = Get-Content $FilePath -Tail 50 -ErrorAction SilentlyContinue
        $lastMsg = ""
        foreach ($line in $lines) {
            $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($entry -and $entry.type -eq "user" -and $entry.message.content) {
                $content = $entry.message.content
                if ($content -is [string] -and -not $content.StartsWith("<")) {
                    $lastMsg = $content
                }
            }
        }
        return if ($lastMsg.Length -gt 100) { $lastMsg.Substring(0, 100) + "..." } else { $lastMsg }
    } catch {
        return ""
    }
}

switch ($Action) {
    "register" {
        if (-not $SessionId) {
            Write-Error "SessionId is required for register action"
            exit 1
        }

        $sessionInfo = @{
            session_id = $SessionId
            project = $Project
            started_at = (Get-Date).ToString("o")
            pid = $PID
            file_path = if ($SessionFile) { $SessionFile } else { "" }
        }

        $sessions[$SessionId] = $sessionInfo
        Save-Sessions

        if ($Json) {
            $sessionInfo | ConvertTo-Json
        } else {
            Write-Host "Registered session: $SessionId" -ForegroundColor Green
        }
    }

    "unregister" {
        if (-not $SessionId) {
            Write-Error "SessionId is required for unregister action"
            exit 1
        }

        if ($sessions.ContainsKey($SessionId)) {
            $sessions.Remove($SessionId)
            Save-Sessions

            if (-not $Json) {
                Write-Host "Unregistered session: $SessionId" -ForegroundColor Green
            }
        } else {
            if (-not $Json) {
                Write-Host "Session not found: $SessionId" -ForegroundColor Yellow
            }
        }
    }

    "list" {
        if ($Json) {
            $sessions.Values | ConvertTo-Json -Depth 5
        } else {
            Write-Host "`n" -NoNewline
            Write-Host "=" * 60 -ForegroundColor DarkGray
            Write-Host "  ACTIVE SESSIONS" -ForegroundColor Cyan
            Write-Host "=" * 60 -ForegroundColor DarkGray
            Write-Host ""

            if ($sessions.Count -eq 0) {
                Write-Host "  No active sessions registered." -ForegroundColor Gray
            } else {
                Write-Host "  $($sessions.Count) active session(s):" -ForegroundColor White
                Write-Host ""

                foreach ($session in $sessions.Values) {
                    $shortId = $session.session_id.Substring(0, 8)
                    Write-Host "  [$shortId...]" -ForegroundColor Cyan
                    Write-Host "    Project:  $($session.project)" -ForegroundColor Gray
                    Write-Host "    Started:  $($session.started_at)" -ForegroundColor Gray
                    Write-Host "    PID:      $($session.pid)" -ForegroundColor Gray
                    Write-Host ""
                }
            }

            Write-Host "=" * 60 -ForegroundColor DarkGray
        }
    }

    "crashed" {
        # Sessions in file that are no longer running = crashed
        $crashedSessions = @()
        $counter = 1

        foreach ($session in $sessions.Values) {
            # Check if the process is still running
            $processRunning = $false
            if ($session.pid) {
                try {
                    $proc = Get-Process -Id $session.pid -ErrorAction SilentlyContinue
                    if ($proc -and $proc.ProcessName -like "*claude*") {
                        $processRunning = $true
                    }
                } catch {}
            }

            if (-not $processRunning) {
                # Find the session file
                $projectPath = Join-Path $ClaudeProjectsPath $session.project
                $sessionFile = Join-Path $projectPath "$($session.session_id).jsonl"

                $fileInfo = $null
                if (Test-Path $sessionFile) {
                    $fileInfo = Get-Item $sessionFile
                }

                $lastUserMsg = ""
                if ($ShowContext -and $fileInfo) {
                    $lastUserMsg = Get-LastUserMessage -FilePath $sessionFile
                }

                $easyId = "crash-{0:D3}" -f $counter
                $crashedSessions += [PSCustomObject]@{
                    EasyId = $easyId
                    SessionId = $session.session_id
                    ShortId = $session.session_id.Substring(0, 8)
                    Project = $session.project
                    StartedAt = $session.started_at
                    LastActivity = if ($fileInfo) { $fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm") } else { "unknown" }
                    SizeKB = if ($fileInfo) { [math]::Round($fileInfo.Length / 1KB, 1) } else { 0 }
                    FilePath = $sessionFile
                    LastUserMessage = $lastUserMsg
                    OriginalPid = $session.pid
                }
                $counter++
            }
        }

        if ($Json) {
            $crashedSessions | ConvertTo-Json -Depth 5
            exit 0
        }

        Write-Host "`n" -NoNewline
        Write-Host "=" * 70 -ForegroundColor DarkGray
        Write-Host "  CRASHED SESSIONS (Active Session Tracking)" -ForegroundColor Red
        Write-Host "=" * 70 -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Active sessions registered: $($sessions.Count)" -ForegroundColor DarkGray
        Write-Host ""

        if ($crashedSessions.Count -eq 0) {
            Write-Host "  No crashed sessions found!" -ForegroundColor Green
            Write-Host "  All registered sessions are still running or were properly closed."
            Write-Host ""
        } else {
            Write-Host "  Found $($crashedSessions.Count) crashed session(s):" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  " + ("-" * 66) -ForegroundColor DarkGray

            foreach ($chat in $crashedSessions) {
                Write-Host ""
                Write-Host "  [$($chat.EasyId)]" -ForegroundColor Cyan -NoNewline
                Write-Host "  $($chat.ShortId)..." -ForegroundColor White
                Write-Host "    Project:   $($chat.Project)" -ForegroundColor Gray
                Write-Host "    Started:   $($chat.StartedAt)" -ForegroundColor Gray
                Write-Host "    Last:      $($chat.LastActivity)" -ForegroundColor Gray
                Write-Host "    Size:      $($chat.SizeKB) KB" -ForegroundColor Gray

                if ($ShowContext -and $chat.LastUserMessage) {
                    Write-Host "    Context:   " -ForegroundColor Gray -NoNewline
                    Write-Host "$($chat.LastUserMessage)" -ForegroundColor DarkYellow
                }
            }

            Write-Host ""
            Write-Host "  " + ("-" * 66) -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  To restore, run:" -ForegroundColor White
            Write-Host "    .\tools\restore-chat.ps1 -ChatId crash-001" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  To clean up (remove from tracking):" -ForegroundColor White
            Write-Host "    .\tools\active-session.ps1 -Action unregister -SessionId <id>" -ForegroundColor Cyan
            Write-Host ""
        }

        Write-Host "=" * 70 -ForegroundColor DarkGray

        # Return for pipeline
        $crashedSessions
    }
}
