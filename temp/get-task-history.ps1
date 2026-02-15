$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$apiKey = $config.api_key
$taskId = '869bu9mem'
$headers = @{'Authorization' = $apiKey}

try {
    # Get task with history
    $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Get

    Write-Host "=== Task Status History ===" -ForegroundColor Cyan
    Write-Host "Current Status: $($task.status.status)" -ForegroundColor Yellow
    Write-Host ""

    # Get status updates from comments/history
    $comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Get

    Write-Host "=== All Comments (chronological) ===" -ForegroundColor Cyan
    $comments.comments | Sort-Object date | ForEach-Object {
        $date = [DateTimeOffset]::FromUnixTimeMilliseconds($_.date).ToString("yyyy-MM-dd HH:mm:ss")
        $user = $_.user.username
        Write-Host "[$date] [$user] $($_.comment_text)" -ForegroundColor White
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
