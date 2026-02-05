# Session Context Buffer Manager
# Maintains in-memory context buffer during active session
# Flushes to disk on session end or after N events

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "init",

    [Parameter(Mandatory=$false)]
    [hashtable]$Data = @{},

    [Parameter(Mandatory=$false)]
    [int]$FlushThreshold = 50
)

$script:ContextBuffer = @{
    session_id = (Get-Date -Format "yyyy-MM-dd-HHmmss")
    events = @()
    patterns_discovered = @()
    files_accessed = @()
    decisions_made = @()
    start_time = Get-Date
}

function Add-ContextEvent {
    param($EventType, $EventData)

    $event = @{
        timestamp = (Get-Date -Format "o")
        type = $EventType
        data = $EventData
    }

    $script:ContextBuffer.events += $event

    # Append to event log
    $eventJson = $event | ConvertTo-Json -Compress
    Add-Content -Path "C:\_machine\conversation-events.log.jsonl" -Value $eventJson

    # Auto-flush if threshold reached
    if ($script:ContextBuffer.events.Count -ge $FlushThreshold) {
        Flush-ContextBuffer
    }
}

function Flush-ContextBuffer {
    $sessionFile = "C:\scripts\_machine\sessions\session-$($script:ContextBuffer.session_id).json"
    $script:ContextBuffer | ConvertTo-Json -Depth 10 | Set-Content $sessionFile

    Write-Host "Context buffer flushed to $sessionFile" -ForegroundColor Green
}

function Get-ContextBuffer {
    return $script:ContextBuffer
}

# Execute action
switch ($Action) {
    "init" {
        Write-Host "Session context buffer initialized: $($script:ContextBuffer.session_id)" -ForegroundColor Cyan
    }
    "add" {
        Add-ContextEvent -EventType $Data.type -EventData $Data.data
    }
    "flush" {
        Flush-ContextBuffer
    }
    "get" {
        return Get-ContextBuffer
    }
}
