param(
    [Parameter(Mandatory=$true)]
    [string]$ListId
)

# Load config
$config = Get-Content "C:\scripts\_machine\clickup-config.json" | ConvertFrom-Json
$apiKey = $config.api_key

# API headers
$headers = @{
    Authorization = $apiKey
    'Content-Type' = 'application/json'
}

# Fetch tasks - try multiple status variations
$statusVariations = @('review', 'Review', 'REVIEW', 'review ')
$allTasks = @()

foreach ($statusName in $statusVariations) {
    try {
        $uri = "https://api.clickup.com/api/v2/list/$ListId/task?archived=false&statuses[]=$statusName"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -ErrorAction SilentlyContinue
        if ($response.tasks) {
            $allTasks += $response.tasks
        }
    } catch {
        # Silent - status might not exist
    }
}

# Deduplicate by ID
$uniqueTasks = $allTasks | Group-Object -Property id | ForEach-Object { $_.Group[0] }

Write-Host "`n=== Review Tasks for List $ListId ===" -ForegroundColor Cyan
Write-Host "Found $($uniqueTasks.Count) task(s) in review status`n" -ForegroundColor Yellow

foreach ($task in $uniqueTasks) {
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

# Return as JSON for further processing
$uniqueTasks | ConvertTo-Json -Depth 10
