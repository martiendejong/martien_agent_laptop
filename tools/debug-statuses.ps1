param(
    [Parameter(Mandatory=$true)]
    [string]$ListId
)

# Get all tasks from the list
$tasks = & "C:\scripts\tools\clickup-sync.ps1" -Action list -ListId $ListId

# Show ALL unique status values
Write-Host "`n=== All Unique Statuses in List ===" -ForegroundColor Cyan
$uniqueStatuses = $tasks | Select-Object -ExpandProperty status | Select-Object -ExpandProperty status -Unique
$uniqueStatuses | ForEach-Object {
    Write-Host "  '$_'" -ForegroundColor Yellow
}

# Show tasks grouped by status
Write-Host "`n=== Tasks by Status ===" -ForegroundColor Cyan
$grouped = $tasks | Group-Object -Property { $_.status.status }
foreach ($group in $grouped) {
    Write-Host "`nStatus: '$($group.Name)' ($($group.Count) tasks)" -ForegroundColor Green
    $group.Group | Select-Object -First 2 | ForEach-Object {
        Write-Host "  - $($_.id): $($_.name)" -ForegroundColor White
    }
}
