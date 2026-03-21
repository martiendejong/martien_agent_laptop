$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json

$headers = @{
    'Authorization' = $config.api_key
}

$task = Invoke-RestMethod -Uri 'https://api.clickup.com/api/v2/task/869ccw9ar' -Method Get -Headers $headers

Write-Output "Task: $($task.name)"
Write-Output "Status: $($task.status.status)"
Write-Output "List: $($task.list.name)"
