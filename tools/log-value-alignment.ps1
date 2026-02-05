# Simple Value Alignment Logger

param(
    [string]$Activity,
    [int]$UserValueScore,
    [int]$TimeSpent
)

$auditFile = "C:\scripts\_machine\value-alignment-audit.jsonl"

if ($Activity -and $UserValueScore) {
    $entry = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        activity = $Activity
        userValueScore = $UserValueScore
        timeSpentMinutes = $TimeSpent
        valuePerMinute = if ($TimeSpent -gt 0) { [math]::Round($UserValueScore / $TimeSpent, 3) } else { 0 }
    } | ConvertTo-Json -Compress

    Add-Content -Path $auditFile -Value $entry
    Write-Host "Logged: $Activity (value: $UserValueScore/10, time: $TimeSpent min)" -ForegroundColor Green
}
else {
    Write-Host "Usage: .\log-value-alignment.ps1 -Activity 'description' -UserValueScore 7 -TimeSpent 45" -ForegroundColor Yellow
}
