$apiKey = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$listId = "901216032110"

$response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?statuses[]=todo&include_closed=false" `
    -Headers @{ Authorization = $apiKey }

Write-Host "Found $($response.tasks.Count) TODO tasks"
foreach ($task in $response.tasks) {
    $priority = if ($task.priority) { $task.priority.priority } else { "none" }
    Write-Host ""
    Write-Host "[$($task.id)] $($task.name)"
    Write-Host "  Priority: $priority"
    Write-Host "  Description preview: $($task.text_content.Substring(0, [Math]::Min(200, $task.text_content.Length)))"
}
