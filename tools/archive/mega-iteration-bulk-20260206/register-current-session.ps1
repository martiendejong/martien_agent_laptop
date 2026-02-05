<#
.SYNOPSIS
    Registers the current Claude Code session for crash tracking.

.DESCRIPTION
    Extracts the session ID from the scratchpad path and registers it
    in active-sessions.json. Should be called at the start of every session.

.PARAMETER ScratchpadPath
    The scratchpad path containing the session ID (optional - can auto-detect)

.PARAMETER SessionId
    Direct session ID if known

.PARAMETER Project
    Project name (default: C--scripts)

.EXAMPLE
    .\register-current-session.ps1 -SessionId "a741942c-16aa-4458-ae55-a693872305a9"
    .\register-current-session.ps1 -ScratchpadPath "C:\Users\HP\AppData\Local\Temp\claude\C--scripts\a741942c-16aa-4458-ae55-a693872305a9\scratchpad"
#>

param(
    [string]$ScratchpadPath,
    [string]$SessionId,
    [string]$Project = "C--scripts"
)

$ErrorActionPreference = "Stop"

# Extract session ID from scratchpad path if provided
if ($ScratchpadPath -and -not $SessionId) {
    # Path format: ...\claude\<project>\<session-id>\scratchpad
    $pathParts = $ScratchpadPath -split '[/\\]'
    # Find the GUID-like part (session ID is a GUID)
    foreach ($part in $pathParts) {
        if ($part -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
            $SessionId = $part
            break
        }
    }
}

if (-not $SessionId) {
    Write-Error "Could not determine session ID. Provide -SessionId or -ScratchpadPath"
    exit 1
}

# Validate it looks like a GUID
if ($SessionId -notmatch '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
    Write-Error "Invalid session ID format: $SessionId (expected GUID)"
    exit 1
}

# Register using active-session.ps1
& "$PSScriptRoot\active-session.ps1" -Action register -SessionId $SessionId -Project $Project

Write-Host ""
Write-Host "Session registered for crash tracking." -ForegroundColor Green
Write-Host "If this session crashes, it will appear in: .\tools\active-session.ps1 -Action crashed" -ForegroundColor Gray
