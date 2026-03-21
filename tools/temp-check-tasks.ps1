$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }

# Check specific tasks directly
$taskIds = @('869ccfy0t', '869ccubck', '869ccuej5', '869ccfmh3', '869c7mt8c')

foreach ($id in $taskIds) {
    try {
        $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers $headers -Method Get -ErrorAction Stop
        Write-Host "$id - $($task.name) - STATUS: $($task.status.status)"
    } catch {
        Write-Host "$id - ERROR: $($_.Exception.Message)"
    }
}
