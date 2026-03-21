param([string]$TaskId = "869ccbbz6")

$cfg = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$token = $cfg.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }

# Get task with subtasks - try different approach
$task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId" -Headers $headers
Write-Output "TASK: $($task.name)"
Write-Output "STATUS: $($task.status.status)"
Write-Output "PARENT: $($task.parent)"

# Check for subtasks in the list
$listId = $task.list.id
Write-Output "LIST ID: $listId"

# Get all tasks in the list that have this as parent
$listTasks = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?subtasks=true&include_closed=true" -Headers $headers

Write-Output "`n---ALL TASKS IN LIST---"
foreach ($t in $listTasks.tasks) {
    $parentInfo = ""
    if ($t.parent) { $parentInfo = " [PARENT: $($t.parent)]" }
    Write-Output "$($t.id) | $($t.status.status) | $($t.name)$parentInfo"
}
