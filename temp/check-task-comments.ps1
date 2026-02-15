param($TaskId)
$headers = @{
    'Authorization' = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
}
$response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" -Headers $headers
Write-Host "Comments: $($response.comments.Count)"
Write-Host ""
if ($response.comments.Count -gt 0) {
    $response.comments | ForEach-Object {
        Write-Host "=== Comment ===" -ForegroundColor Yellow
        Write-Host $_.comment_text
        Write-Host ""
    }
}
