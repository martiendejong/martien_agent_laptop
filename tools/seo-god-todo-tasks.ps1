$api_key = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $api_key }
$listId = '901215927087'

$resp = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?statuses[]=todo&page=0" -Headers $headers
Write-Host "=== TODO TASKS ($($resp.tasks.Count)) ===" -ForegroundColor Cyan

foreach ($t in $resp.tasks) {
    Write-Host "`n--- $($t.id) | $($t.name) ---" -ForegroundColor Yellow
    Write-Host "Description: $($t.description)"

    # Get comments
    $comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($t.id)/comment" -Headers $headers
    Write-Host "Comments ($($comments.comments.Count)):" -ForegroundColor Magenta
    foreach ($c in $comments.comments) {
        $date = [DateTimeOffset]::FromUnixTimeMilliseconds($c.date).ToString("yyyy-MM-dd HH:mm")
        $text = $c.comment_text
        Write-Host "[$date] $($c.user.username): $text"
        Write-Host "---"
    }
}
