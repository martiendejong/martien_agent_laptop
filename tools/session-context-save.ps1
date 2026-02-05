# Session Context Saver
# Saves current session state for restoration on next session start

param(
    [string]$SessionId = (Get-Date -Format "yyyyMMdd-HHmmss"),
    [string]$TaskDescription = "Unspecified task",
    [string[]]$FilesRead = @(),
    [string[]]$EntitiesAccessed = @()
)

$contextFile = "C:\scripts\_machine\session-context.json"

# Load existing context
$context = if (Test-Path $contextFile) {
    Get-Content $contextFile -Raw | ConvertFrom-Json
} else {
    @{
        metadata = @{
            schema_version = "1.0"
            last_updated = $null
            session_id = $null
        }
        current_session = @{}
        last_session = @{}
    }
}

# Move current to last
$context.last_session = $context.current_session

# Update current session
$context.current_session = @{
    session_id = $SessionId
    started_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    current_task = $TaskDescription
    files_read = $FilesRead
    entities_accessed = $EntitiesAccessed
    worktrees_allocated = @()
    recent_queries = @()
    context_loaded = @()
}

$context.metadata.last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$context.metadata.session_id = $SessionId

# Save
$context | ConvertTo-Json -Depth 10 | Set-Content $contextFile

Write-Host "[Session Context] Saved session state: $SessionId" -ForegroundColor Green
Write-Host "  Task: $TaskDescription" -ForegroundColor Cyan
Write-Host "  Files read: $($FilesRead.Count)" -ForegroundColor Cyan
