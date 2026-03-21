$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }

$taskIds = @('869ccfy0t', '869ccubck', '869ccuej5')

foreach ($id in $taskIds) {
    try {
        $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers $headers -Method Get -ErrorAction Stop
        Write-Host "=== $id - $($task.name) ==="
        Write-Host "Status: $($task.status.status)"
        Write-Host ""

        $comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id/comment" -Headers $headers -Method Get -ErrorAction Stop
        if ($comments.comments.Count -gt 0) {
            $latest = $comments.comments[0]
            Write-Host "Latest comment:"
            Write-Host $latest.comment_text
        } else {
            Write-Host "No comments"
        }
        Write-Host ""
        Write-Host "---"
        Write-Host ""
    } catch {
        Write-Host "$id - ERROR: $($_.Exception.Message)"
    }
}
