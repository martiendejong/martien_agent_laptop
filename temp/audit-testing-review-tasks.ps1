$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$apiKey = $config.api_key
$listId = '901214097647'  # client-manager
$headers = @{'Authorization' = $apiKey}

$statuses = @('testing', 'review')

foreach ($status in $statuses) {
    Write-Host "`n=== Tasks in '$status' status ===" -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?statuses[]=$status&subtasks=true" -Headers $headers -Method Get

    foreach ($task in $response.tasks) {
        Write-Host "`nTask: $($task.id) - $($task.name)" -ForegroundColor Yellow

        # Get comments
        $comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" -Headers $headers -Method Get

        # Check for PR link
        $hasPR = $false
        foreach ($comment in $comments.comments) {
            $pattern = "PR #\d+|github\.com/[^/]+/[^/]+/pull/\d+|AGENT COMPLETED"
            if ($comment.comment_text -match $pattern) {
                $hasPR = $true
                $date = [DateTimeOffset]::FromUnixTimeMilliseconds($comment.date).ToString("yyyy-MM-dd HH:mm")
                $preview = $comment.comment_text.Substring(0, [Math]::Min(100, $comment.comment_text.Length))
                Write-Host "  [OK] PR found: [$date] $preview" -ForegroundColor Green
                break
            }
        }

        if (-not $hasPR) {
            Write-Host "  [VIOLATION] NO PR LINK FOUND!" -ForegroundColor Red
            $commentCount = $comments.comments.Count
            Write-Host "  Comments count: $commentCount" -ForegroundColor Gray
        }
    }
}
