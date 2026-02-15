$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$apiKey = $config.api_key
$taskId = '869bu9mem'
$headers = @{'Authorization' = $apiKey}

try {
    $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Get
    if ($response.comments.Count -gt 0) {
        foreach ($comment in $response.comments) {
            $date = [DateTimeOffset]::FromUnixTimeMilliseconds($comment.date).ToString("yyyy-MM-dd HH:mm")
            Write-Host "[$date] $($comment.comment_text)" -ForegroundColor White
            Write-Host ""
        }
    } else {
        Write-Host "No comments found" -ForegroundColor Gray
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
