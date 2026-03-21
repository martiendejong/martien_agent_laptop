param(
    [Parameter(Mandatory=$true)]
    [string]$ListId
)

# Get all tasks from the list
$tasks = & "C:\scripts\tools\clickup-sync.ps1" -Action list -ListId $ListId

# Filter for tasks in review status
$reviewTasks = $tasks | Where-Object { $_.status.status -eq 'review' }

# Output summary
Write-Host "`n=== Review Tasks for List $ListId ===" -ForegroundColor Cyan
Write-Host "Found $($reviewTasks.Count) task(s) in review status`n" -ForegroundColor Yellow

# Output each task details
foreach ($task in $reviewTasks) {
    $assignee = if ($task.assignees -and $task.assignees.Count -gt 0) {
        $task.assignees[0].username
    } else {
        "Unassigned"
    }

    Write-Host "ID: $($task.id)" -ForegroundColor Green
    Write-Host "Name: $($task.name)" -ForegroundColor White
    Write-Host "Status: $($task.status.status)" -ForegroundColor Yellow
    Write-Host "Assignee: $assignee" -ForegroundColor Cyan
    Write-Host "URL: $($task.url)" -ForegroundColor Blue
    Write-Host ""
}

# Return the tasks as JSON for parsing
$reviewTasks | ConvertTo-Json -Depth 10
