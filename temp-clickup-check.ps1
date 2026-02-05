$configPath = "C:\scripts\_machine\clickup-config.json"
$config = Get-Content $configPath | ConvertFrom-Json
$apiKey = $config.api_key
$apiBase = $config.api_base
$ListId = $config.default_list_id

$headers = @{
    Authorization = $apiKey
    "Content-Type" = "application/json"
}

$url = "$apiBase/list/$ListId/task?archived=false&include_closed=false"
$response = Invoke-RestMethod -Uri $url -Headers $headers

# Check all statuses and their assignment status
$allTasks = @{}
$response.tasks | ForEach-Object {
    if (-not $allTasks[$_.status.status]) {
        $allTasks[$_.status.status] = @()
    }
    $assigned = if ($_.assignees -and $_.assignees.Count -gt 0) { "YES" } else { "NO" }
    $priority = if ($_.priority) { $_.priority.priority } else { "None" }
    $allTasks[$_.status.status] += @{
        id = $_.id
        name = $_.name
        assigned = $assigned
        priority = $priority
    }
}

# Show summary by status
foreach ($status in $allTasks.Keys | Sort-Object) {
    $tasks = $allTasks[$status]
    $unassigned = @($tasks | Where-Object { $_.assigned -eq "NO" })
    Write-Host "`n[$status] - Total: $($tasks.Count), Unassigned: $($unassigned.Count)" -ForegroundColor Yellow

    if ($unassigned.Count -gt 0) {
        $unassigned | ForEach-Object {
            Write-Host "  - $($_.id) | $($_.name.Substring(0, [Math]::Min(50, $_.name.Length))) | $($_.priority)"
        }
    }
}
