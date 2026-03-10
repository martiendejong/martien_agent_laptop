$h = @{ Authorization = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI' }

$taskIds = @(
    '869cdpzmt', '869cdpy7n', '869cdpxh6', '869cdpxgc', '869cdpwz7', '869cdpwyf',
    '869cd5wpv', '869cd5wh2', '869cd5e2e', '869cd5bbz', '869cd4n2x', '869cd3j5h', '869cd032d', '869cd02gu'
)

foreach ($id in $taskIds) {
    $comments = Invoke-RestMethod "https://api.clickup.com/api/v2/task/$id/comment" -Headers $h
    if ($comments.comments.Count -gt 0) {
        Write-Host "`n=== TASK $id ==="
        foreach ($c in $comments.comments) {
            $text = if ($c.comment_text) { $c.comment_text } else { ($c.comment | ForEach-Object { $_.text }) -join '' }
            Write-Host "COMMENT: $($text.Substring(0, [Math]::Min(500, $text.Length)))"
        }
    }
}
