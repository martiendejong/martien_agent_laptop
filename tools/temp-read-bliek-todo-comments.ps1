# Read comments for all Bliek TODO tasks
$apiKey = "pk_77846532_O87KQUL83MTASERA2PU7N7KW2PHJIXFF"
$headers = @{Authorization = $apiKey}

$taskIds = @('869cc94k3', '869cc0j5y', '869cc0j4z', '869cc0j1p')

foreach ($taskId in $taskIds) {
    Write-Host "`n=== Task $taskId ===" -ForegroundColor Cyan

    # Get task details
    $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers
    Write-Host "Title: $($response.name)" -ForegroundColor Yellow
    Write-Host "Status: $($response.status.status)" -ForegroundColor Gray
    Write-Host "Description: $($response.description.Substring(0, [Math]::Min(200, $response.description.Length)))..." -ForegroundColor White

    # Get comments
    $comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers
    if ($comments.comments.Count -gt 0) {
        $lastComment = $comments.comments[0]
        $date = [DateTimeOffset]::FromUnixTimeMilliseconds($lastComment.date).ToString("yyyy-MM-dd HH:mm")
        Write-Host "Last Comment ($date):" -ForegroundColor Green
        Write-Host $lastComment.comment_text -ForegroundColor White
    } else {
        Write-Host "No comments" -ForegroundColor Red
    }
}
