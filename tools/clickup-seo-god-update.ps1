param([string]$TaskId, [string]$Status, [string]$Comment)
$api_key = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $api_key; 'Content-Type' = 'application/json' }

if ($Status) {
    $body = @{ status = $Status } | ConvertTo-Json
    $resp = Invoke-RestMethod -Method Put -Uri "https://api.clickup.com/api/v2/task/$TaskId" -Headers $headers -Body $body
    Write-Host "Updated $TaskId to status: $Status"
}

if ($Comment) {
    $body = @{ comment_text = $Comment } | ConvertTo-Json
    $resp = Invoke-RestMethod -Method Post -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" -Headers $headers -Body $body
    Write-Host "Posted comment on $TaskId"
}
