<#
.SYNOPSIS
    Real-time collaboration client - publishes agent actions

.DESCRIPTION
    Publishes agent actions to live-collab-server for real-time visualization:
    - File edits
    - Worktree operations
    - Tool usage
    - Errors

    Called by other tools to broadcast their activity.

.PARAMETER Action
    Type of action (edit, allocate, release, tool, error)

.PARAMETER Details
    JSON or string details about the action

.PARAMETER AgentId
    Override agent ID (defaults to current agent)

.EXAMPLE
    .\live-collab-client.ps1 -Action edit -Details '{"file":"Customer.cs","line":42}'

.EXAMPLE
    .\live-collab-client.ps1 -Action allocate -Details '{"repo":"client-manager","seat":"agent-001"}'
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('edit', 'allocate', 'release', 'tool', 'error', 'warning', 'success')]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$Details,

    [Parameter(Mandatory=$false)]
    [string]$AgentId
)

$ErrorActionPreference = 'Stop'

# Get agent ID
if (-not $AgentId) {
    if (Test-Path "C:\scripts\_machine\.current_agent_id") {
        $AgentId = (Get-Content "C:\scripts\_machine\.current_agent_id" -Raw).Trim()
    } else {
        $AgentId = "unknown"
    }
}

# Insert into database (server polls this table)
$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

$timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

# Escape single quotes in details
$detailsEscaped = $Details -replace "'", "''"

$sql = @"
INSERT INTO live_activity (timestamp, agent_id, action_type, details)
VALUES ('$timestamp', '$AgentId', '$Action', '$detailsEscaped');
"@

try {
    $sql | & $SqlitePath $DbPath
    Write-Host "✅ Published: $Action" -ForegroundColor Green
} catch {
    # Fail silently - don't break tools if collaboration server is down
    Write-Host "⚠️ Live collaboration server not available" -ForegroundColor DarkGray
}
