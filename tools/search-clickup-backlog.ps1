$api_key = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $api_key }

$lists = @{
    'Vera AI' = '901211218614'
    'wreckingball' = '901211218756'
    'CloudGrafo' = '901213168637'
    'Vloerenhuis' = '901213305955'
}

foreach ($listName in $lists.Keys) {
    $listId = $lists[$listName]
    Write-Host "=== $listName ($listId) ===" -ForegroundColor Cyan
    try {
        $resp = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?page=0" -Headers $headers
        $backlog = $resp.tasks | Where-Object { $_.status.status -eq 'backlog' }
        Write-Host "Backlog tasks: $($backlog.Count)"
        foreach ($t in $backlog) {
            $name = if ($t.name.Length -gt 80) { $t.name.Substring(0, 80) } else { $t.name }
            Write-Host "$($t.id) | $name"
        }
    } catch {
        Write-Host "Error: $_"
    }
    Write-Host ""
}
