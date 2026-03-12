param([string]$TaskId, [string]$Status, [string]$Comment)
$apiKey = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"

if ($Status) {
    $body = @{ status = $Status } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId" `
        -Method PUT -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } `
        -Body $body
    Write-Host "Status updated to: $($r.status.status)"
}

if ($Comment) {
    $body = @{ comment_text = $Comment } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" `
        -Method POST -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } `
        -Body $body
    Write-Host "Comment posted: $($r.id)"
}
