$apiKey = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$headers = @{
    "Authorization" = $apiKey
    "Content-Type"  = "application/json"
}

$taskIds = @(
    "869ccunh3",
    "869ccunbt",
    "869ccun2h",
    "869ccubck",
    "869ccfy0t",
    "869ccv84k",
    "869ccv7ta",
    "869ccuej5",
    "869c7mt8c",
    "869ccfmh3"
)

foreach ($taskId in $taskIds) {
    Write-Host ""
    Write-Host "=============================================="
    Write-Host "TASK ID: $taskId"
    Write-Host "=============================================="

    # Get task details for status
    try {
        $taskUrl = "https://api.clickup.com/api/v2/task/$taskId"
        $task = Invoke-RestMethod -Uri $taskUrl -Headers $headers -Method Get
        $taskName = $task.name
        $taskStatus = $task.status.status
        Write-Host "NAME: $taskName"
        Write-Host "STATUS: $taskStatus"
    } catch {
        Write-Host "ERROR fetching task: $($_.Exception.Message)"
        continue
    }

    # Get comments
    try {
        $commentUrl = "https://api.clickup.com/api/v2/task/$taskId/comment"
        $response = Invoke-RestMethod -Uri $commentUrl -Headers $headers -Method Get
        $comments = $response.comments

        if ($comments -and $comments.Count -gt 0) {
            # Comments come newest first from API
            $lastComment = $comments[0]
            $commentText = $lastComment.comment_text
            $commentBy = $lastComment.user.username
            $commentDate = [DateTimeOffset]::FromUnixTimeMilliseconds($lastComment.date).DateTime.ToString("yyyy-MM-dd HH:mm:ss")
            Write-Host "LAST COMMENT BY: $commentBy"
            Write-Host "LAST COMMENT DATE: $commentDate"
            Write-Host "LAST COMMENT TEXT:"
            Write-Host $commentText
        } else {
            Write-Host "NO COMMENTS on this task."
        }
    } catch {
        Write-Host "ERROR fetching comments: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "=============================================="
Write-Host "DONE - All $($taskIds.Count) tasks processed"
Write-Host "=============================================="
