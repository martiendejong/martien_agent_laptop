param([string]$TaskId = "869ccbbz6")

$cfg = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$token = $cfg.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }

# Get task with subtasks
$task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId`?include_subtasks=true" -Headers $headers
Write-Output "TASK: $($task.name)"
Write-Output "STATUS: $($task.status.status)"
Write-Output "LIST: $($task.list.name) (ID: $($task.list.id))"
Write-Output "SPACE: $($task.space.id)"
Write-Output "FOLDER: $($task.folder.name) (ID: $($task.folder.id))"

if ($task.description) {
    $desc = $task.description
    if ($desc.Length -gt 1000) { $desc = $desc.Substring(0, 1000) + "..." }
    Write-Output "DESCRIPTION:`n$desc"
}

Write-Output "`n---SUBTASKS---"
if ($task.subtasks -and $task.subtasks.Count -gt 0) {
    foreach ($s in $task.subtasks) {
        Write-Output "$($s.id) | $($s.status.status) | $($s.name)"
    }
} else {
    Write-Output "No subtasks found in task response"
}

# Get comments
Write-Output "`n---LAST COMMENT---"
$comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" -Headers $headers
if ($comments.comments.Count -gt 0) {
    $last = $comments.comments[-1]
    Write-Output "BY: $($last.user.username)"
    Write-Output "TEXT: $($last.comment_text)"
} else {
    Write-Output "No comments"
}
