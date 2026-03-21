$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$listId = '901216032110'

$task = @{
    name = "Debug WhatsApp en Email communicatie met woningzoekende"
    description = @"
PROBLEEM:
WhatsApp en email communicatie met woningzoekenden werkt niet correct.

SCOPE:
- Browser debugging om exact probleem te identificeren
- Check backend API endpoints voor WhatsApp/Email
- Check frontend formulieren en event handlers
- Verificatie van database opslag
- Error logging analysis

VERWACHTE OUTPUT:
- Root cause identified
- PR met fix
- Browser test screenshots als bewijs
"@
    status = 'busy'
    priority = 2
} | ConvertTo-Json

$created = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task" `
    -Method Post `
    -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
    -Body $task

Write-Host "Task created: $($created.id)" -ForegroundColor Green
Write-Host "URL: https://app.clickup.com/9012956001/t/$($created.id)" -ForegroundColor Cyan

# Output task ID for next step
$created.id
