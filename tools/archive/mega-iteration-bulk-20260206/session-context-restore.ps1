# Session Context Restorer
# Restores last session state

param(
    [switch]$ShowOnly  # Just show summary, don't restore
)

$contextFile = "C:\scripts\_machine\session-context.json"

if (-not (Test-Path $contextFile)) {
    Write-Host "[Session Context] No previous session found" -ForegroundColor Yellow
    exit 0
}

$context = Get-Content $contextFile -Raw | ConvertFrom-Json

if (-not $context.last_session.session_id) {
    Write-Host "[Session Context] No previous session to restore" -ForegroundColor Yellow
    exit 0
}

# Display last session summary
Write-Host "`n=== LAST SESSION SUMMARY ===" -ForegroundColor Cyan
Write-Host "Session ID: $($context.last_session.session_id)" -ForegroundColor White
Write-Host "Ended: $($context.last_session.ended_at)" -ForegroundColor Gray
Write-Host "Task: $($context.last_session.current_task)" -ForegroundColor Yellow
Write-Host "Files accessed: $($context.last_session.files_read.Count)" -ForegroundColor Gray

if ($context.last_session.files_read.Count -gt 0) {
    Write-Host "`nRecent files:" -ForegroundColor Cyan
    $context.last_session.files_read | Select-Object -Last 5 | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }
}

if ($ShowOnly) {
    exit 0
}

Write-Host "`n[Session Context] Context restored from last session" -ForegroundColor Green
Write-Host "Resume where you left off!" -ForegroundColor Yellow
