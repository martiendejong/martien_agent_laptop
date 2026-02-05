# Session Context Buffer - R02-002
# In-memory buffer for active session context that flushes to disk periodically
# Expert: Tom van der Berg - File System Performance Expert

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('init', 'add', 'flush', 'get', 'clear')]
    [string]$Action = 'get',

    [Parameter(Mandatory=$false)]
    [string]$Key,

    [Parameter(Mandatory=$false)]
    [string]$Value,

    [Parameter(Mandatory=$false)]
    [int]$FlushThreshold = 10
)

$global:SessionContextBuffer = @{}
$global:SessionBufferEventCount = 0
$BufferFile = "C:\_machine\session-buffer-state.json"

function Initialize-SessionBuffer {
    $global:SessionContextBuffer = @{
        'session_start' = Get-Date -Format 'o'
        'events' = @()
        'files_read' = @()
        'decisions_made' = @()
        'patterns_discovered' = @()
        'context_accessed' = @()
    }
    $global:SessionBufferEventCount = 0
    Write-Host "Session context buffer initialized" -ForegroundColor Cyan
}

function Add-ToBuffer {
    param($Key, $Value)

    if (-not $global:SessionContextBuffer.ContainsKey($Key)) {
        $global:SessionContextBuffer[$Key] = @()
    }

    $global:SessionContextBuffer[$Key] += @{
        'timestamp' = Get-Date -Format 'o'
        'value' = $Value
    }

    $global:SessionBufferEventCount++

    # Auto-flush if threshold reached
    if ($global:SessionBufferEventCount -ge $FlushThreshold) {
        Flush-Buffer
    }
}

function Flush-Buffer {
    if ($global:SessionContextBuffer.Count -eq 0) {
        Write-Host "Buffer empty, nothing to flush" -ForegroundColor Yellow
        return
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
    $flushFile = "C:\scripts\_machine\knowledge-system\buffer-flush-$timestamp.json"

    $global:SessionContextBuffer | ConvertTo-Json -Depth 10 | Out-File $flushFile -Encoding UTF8

    Write-Host "Flushed $($global:SessionBufferEventCount) events to $flushFile" -ForegroundColor Green

    # Reset counter but keep buffer structure
    $global:SessionBufferEventCount = 0
    $global:SessionContextBuffer.events = @()
}

function Get-BufferState {
    return $global:SessionContextBuffer
}

function Clear-Buffer {
    Initialize-SessionBuffer
    Write-Host "Buffer cleared" -ForegroundColor Yellow
}

# Main execution
switch ($Action) {
    'init' { Initialize-SessionBuffer }
    'add' { Add-ToBuffer -Key $Key -Value $Value }
    'flush' { Flush-Buffer }
    'get' { Get-BufferState | ConvertTo-Json -Depth 5 }
    'clear' { Clear-Buffer }
}
