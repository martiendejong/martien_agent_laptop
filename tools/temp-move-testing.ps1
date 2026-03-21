$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }
$body = '{"status":"testing"}'

$tasks = @(
    @{ id = '869ccfy0t'; name = 'Download Button' },
    @{ id = '869ccubck'; name = 'FAQ from URL Cards' },
    @{ id = '869ccuej5'; name = 'Build Fix' }
)

foreach ($task in $tasks) {
    Write-Host "Moving $($task.id) ($($task.name)) to testing..."
    $result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)" -Headers $headers -Method Put -Body $body -ErrorAction Stop
    Write-Host "  Status: $($result.status.status)"

    $comment = @{
        comment_text = "PR #68 merged into develop (commit bda4009). Code review passed with fixes applied. Moving to TESTING."
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" -Headers $headers -Method Post -Body $comment -ErrorAction Stop | Out-Null
    Write-Host "  Comment added."
}

Write-Host "`nAll 3 tasks moved to testing."
