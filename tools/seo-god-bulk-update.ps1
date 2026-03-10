param([string[]]$TaskIds, [string]$Status, [hashtable]$Comments)
$api_key = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $api_key; 'Content-Type' = 'application/json' }

foreach ($id in $TaskIds) {
    if ($Status) {
        $body = @{ status = $Status } | ConvertTo-Json
        Invoke-RestMethod -Method Put -Uri "https://api.clickup.com/api/v2/task/$id" -Headers $headers -Body $body | Out-Null
        Write-Host "Updated $id -> $Status"
    }
    if ($Comments -and $Comments[$id]) {
        $body = @{ comment_text = $Comments[$id] } | ConvertTo-Json -Depth 5
        Invoke-RestMethod -Method Post -Uri "https://api.clickup.com/api/v2/task/$id/comment" -Headers $headers -Body $body | Out-Null
        Write-Host "Commented on $id"
    }
}
