$config = Get-Content 'C:/scripts/_machine/clickup-config.json' | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key }
$task = Invoke-RestMethod -Uri 'https://api.clickup.com/api/v2/task/869ccvzgh' -Headers $headers

Write-Host "Task: $($task.name)" -ForegroundColor Cyan
Write-Host "`nDescription:" -ForegroundColor Yellow
Write-Host $task.description
