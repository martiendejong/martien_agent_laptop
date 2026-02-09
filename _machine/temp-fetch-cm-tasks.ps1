# Fetch all open client-manager tasks with details
$tasks = @(
    '869c1dnxr', '869c1dnx7', '869c1dnww', '869bznh32', '869bzf5qc', '869bz3gzc', '869bxhk3q',
    '869c2e17v', '869c2e17t', '869c2e17p', '869c2e17m', '869c2e17j'
)

foreach($t in $tasks) {
    Write-Host "=== TASK: $t ==="
    & 'C:\scripts\tools\clickup-sync.ps1' -Action show -TaskId $t -Project client-manager
    Write-Host "---END---"
    Write-Host ""
}
