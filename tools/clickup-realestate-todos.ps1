$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$listId = '901216032110'

$r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?statuses[]=todo" `
    -Headers @{ Authorization = $apiKey }

foreach ($task in $r.tasks) {
    $pri = if ($task.priority) { $task.priority.priority } else { 'normal' }
    Write-Host "[$pri] $($task.id): $($task.name)"
}
