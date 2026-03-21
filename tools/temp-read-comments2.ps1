$cfg = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$token = $cfg.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }

$taskIds = @(
    "869cchnz7",
    "869cchnyn",
    "869cchnyt",
    "869cchnyw",
    "869cchnyf",
    "869cchnzn",
    "869cchnzu",
    "869cchp01",
    "869cchp0g"
)

foreach ($id in $taskIds) {
    $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers $headers
    Write-Output "=== $id | $($task.name) ==="
    if ($task.description) {
        $desc = $task.description
        if ($desc.Length -gt 300) { $desc = $desc.Substring(0, 300) + "..." }
        Write-Output "DESC: $desc"
    }
    $comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id/comment" -Headers $headers
    if ($comments.comments -and $comments.comments.Count -gt 0) {
        $last = $comments.comments[-1]
        Write-Output "COMMENT: $($last.comment_text)"
    } else {
        Write-Output "NO COMMENTS"
    }
    Write-Output "---"
}
