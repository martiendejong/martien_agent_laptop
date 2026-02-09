param([string]$Date, [string]$TimeFilter)
$sessions = Get-ChildItem "C:\Users\HP\.claude\projects\C--scripts\*.jsonl" |
    Where-Object { $_.LastWriteTime.Date -eq [datetime]$Date } |
    Sort-Object LastWriteTime
foreach ($s in $sessions) {
    $time = $s.LastWriteTime.ToString('HH:mm')
    if ($TimeFilter -and $time -notlike "*$TimeFilter*") { continue }
    # Get first line to find session start
    $first = Get-Content $s.FullName -First 1 | ConvertFrom-Json -ErrorAction SilentlyContinue
    $lastMsg = ""
    # Get last few lines for context
    $lines = Get-Content $s.FullName -Tail 5
    foreach ($line in $lines) {
        $obj = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($obj -and $obj.type -eq 'human') {
            $lastMsg = $obj.message.content.Substring(0, [Math]::Min(100, $obj.message.content.Length))
        }
    }
    Write-Output "$time | $([Math]::Round($s.Length/1024))KB | $($s.BaseName) | $lastMsg"
}
