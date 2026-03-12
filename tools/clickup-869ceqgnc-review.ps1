$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869ceqgnc'

$comment = @{ comment_text = "Implementation complete.

PR created: https://github.com/martiendejong/real-estate-agency-ai/pull/136

Changes:
- MainLayout.tsx: hamburger button in mobile topbar, sidebarOpen state
- Sidebar.tsx: isOpen/onClose props, overlay backdrop, open CSS class, close on nav click
- main.css: slide-in drawer at mobile breakpoint (768px), overlay styles

Ready for code review." } | ConvertTo-Json

$r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Method POST -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $comment
Write-Host "Comment posted: $($r.id)"

$status = @{ status = 'review' } | ConvertTo-Json
$r2 = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Method PUT -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $status
Write-Host "Status: $($r2.status.status)"
