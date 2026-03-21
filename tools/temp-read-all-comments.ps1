$cfg = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$key = $cfg.api_key
$ids = @('869cchp0g','869cchnzu','869cchnzn','869cchnyf','869ccfvqa','869ccfndh','869cc94jx','869cc0j4c')

foreach ($taskId in $ids) {
    Write-Output "=== TASK $taskId ==="
    try {
        $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers @{Authorization=$key} -Method Get
        Write-Output "Name: $($task.name)"
        Write-Output "Status: $($task.status.status)"
        Write-Output "Priority: $($task.priority.priority)"
        $desc = if ($task.description.Length -gt 500) { $task.description.Substring(0,500) + '...' } else { $task.description }
        Write-Output "Description: $desc"
        Write-Output ""
        $r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers @{Authorization=$key} -Method Get
        if ($r.comments.Count -gt 0) {
            Write-Output "--- COMMENTS ($($r.comments.Count)) ---"
            foreach ($c in $r.comments) {
                Write-Output "  By: $($c.user.username)"
                $ctext = if ($c.comment_text.Length -gt 300) { $c.comment_text.Substring(0,300) + '...' } else { $c.comment_text }
                Write-Output "  Text: $ctext"
                Write-Output ""
            }
        } else {
            Write-Output "No comments"
        }
    } catch {
        Write-Output "Error: $_"
    }
    Write-Output "========================================="
    Write-Output ""
}
