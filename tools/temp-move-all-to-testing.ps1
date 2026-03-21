$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'

$tasks = @(
    @{id='869cc0j1p'; pr=87; name='Email Notifications'},
    @{id='869cc94k3'; pr=88; name='AI Message Classification'},
    @{id='869cc0j5y'; pr=89; name='Automated Follow-ups'},
    @{id='869cc0j4z'; pr=90; name='Calendar Synchronization'}
)

foreach ($task in $tasks) {
    Write-Host "Moving $($task.name) to TESTING..." -ForegroundColor Cyan

    $comment = @{
        comment_text = "✅ CODE REVIEWED & MERGED

PR #$($task.pr) merged to develop
Code is now on develop branch and ready for testing

-- Claude Code Agent"
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" `
        -Method Post `
        -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
        -Body $comment | Out-Null

    $update = @{ status = 'testing' } | ConvertTo-Json
    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)" `
        -Method Put `
        -Headers @{Authorization=$apiKey; 'Content-Type'='application/json'} `
        -Body $update | Out-Null

    Write-Host "  $($task.name) moved to TESTING" -ForegroundColor Green
}

Write-Host ""
Write-Host "All 4 features moved to TESTING!" -ForegroundColor Green
