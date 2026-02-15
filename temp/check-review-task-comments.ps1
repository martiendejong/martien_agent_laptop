$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$apiKey = $config.api_key
$tasks = @('869c3q8tc', '869c3q8t7', '869c3q8ju')

foreach ($taskId in $tasks) {
    Write-Host "`n=== Task $taskId ===" -ForegroundColor Cyan
    $headers = @{'Authorization' = $apiKey}
    try {
        $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Get
        if ($response.comments.Count -gt 0) {
            foreach ($comment in $response.comments | Select-Object -First 5) {
                $date = [DateTimeOffset]::FromUnixTimeMilliseconds($comment.date).ToString("yyyy-MM-dd HH:mm")
                Write-Host "[$date] $($comment.comment_text)" -ForegroundColor White
            }
        } else {
            Write-Host "No comments" -ForegroundColor Gray
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}
