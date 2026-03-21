$config = Get-Content 'C:/scripts/_machine/clickup-config.json' | ConvertFrom-Json
$listId = '901216032110'
$headers = @{ Authorization = $config.api_key }

Write-Host "`n=== TODO TASKS ===" -ForegroundColor Cyan
$todoTasks = (Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?subtasks=true&statuses[]=todo" -Headers $headers).tasks
$todoTasks | ForEach-Object { Write-Host "$($_.id): $($_.name)" }

Write-Host "`n=== BACKLOG TASKS ===" -ForegroundColor Yellow
$backlogTasks = (Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?subtasks=true&statuses[]=backlog" -Headers $headers).tasks
$backlogTasks | ForEach-Object { Write-Host "$($_.id): $($_.name)" }

Write-Host "`n=== BLOCKED TASKS ===" -ForegroundColor Red
$blockedTasks = (Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?subtasks=true&statuses[]=blocked" -Headers $headers).tasks
$blockedTasks | ForEach-Object { Write-Host "$($_.id): $($_.name)" }

Write-Host "`n=== SUMMARY ===" -ForegroundColor Green
Write-Host "TODO: $($todoTasks.Count)"
Write-Host "BACKLOG: $($backlogTasks.Count)"
Write-Host "BLOCKED: $($blockedTasks.Count)"
