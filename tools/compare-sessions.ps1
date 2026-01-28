<#
.SYNOPSIS
    Compare session files vs clean exits to find crashed sessions
#>

$projectPath = 'C:\Users\HP\.claude\projects\C--scripts'
$tracker = Get-Content 'C:\scripts\_machine\session-tracker.json' -Raw | ConvertFrom-Json

# Get clean exit session IDs
$cleanExitIds = @()
if ($tracker.clean_exits) {
    $cleanExitIds = $tracker.clean_exits | ForEach-Object { $_.session_id }
}

Write-Host "`nRecent session files (last 15):" -ForegroundColor Cyan
Write-Host ("-" * 70)

$allSessions = Get-ChildItem -Path $projectPath -Filter '*.jsonl' -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 15

foreach ($s in $allSessions) {
    $sessionId = [System.IO.Path]::GetFileNameWithoutExtension($s.Name)
    $shortId = $sessionId.Substring(0,8)
    $status = if ($sessionId -in $cleanExitIds) { "CLEAN" } else { "CRASHED?" }
    $color = if ($status -eq "CLEAN") { "Green" } else { "Red" }

    Write-Host "  $shortId... | " -NoNewline
    Write-Host "$($s.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))" -NoNewline
    Write-Host " | $([math]::Round($s.Length/1KB,1)) KB | " -NoNewline
    Write-Host $status -ForegroundColor $color
}

Write-Host ""
Write-Host "Sessions NOT in clean_exits = potentially crashed" -ForegroundColor Yellow
