$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cekk62'

$comment = @{ comment_text = "Implementation complete.

PR created: https://github.com/martiendejong/real-estate-agency-ai/pull/138

Changes:
- Table.tsx: generic typed data grid with column config, loading state, custom cell render, row click
- Header.tsx: page header with title/subtitle, search, action buttons, notification bell, user avatar dropdown
- Gebruikers.tsx: refactored to use Header and Table components (-90 lines, same functionality)

All 10 core components now exist: Sidebar, Header, StatCard, PropertyCard, PersonCard, Timeline, Calendar, Modal, Tabs, Table.

Ready for code review." } | ConvertTo-Json

$r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Method POST -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $comment
Write-Host "Comment posted: $($r.id)"

$status = @{ status = 'review' } | ConvertTo-Json
$r2 = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Method PUT -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $status
Write-Host "Status: $($r2.status.status)"
