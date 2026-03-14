$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

Invoke-Command -Session $sess -ScriptBlock {
    $logDir = 'C:\inetpub\whatsappbridge-api\logs'
    Write-Host "=== All log files ==="
    Get-ChildItem $logDir -Filter 'stdout_*.log' | Sort-Object LastWriteTime -Descending | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

    # Get ALL logs, latest first — look for the send operation
    $logs = Get-ChildItem $logDir -Filter 'stdout_*.log' | Sort-Object LastWriteTime -Descending
    foreach ($log in $logs) {
        $content = Get-Content $log.FullName -Tail 200
        $hasSend = $content | Where-Object { $_ -match 'encrypt|SendText|pre-key|bundles|pkmsg|device' }
        if ($hasSend) {
            Write-Host "`n=== $($log.Name) - Send related lines ==="
            $hasSend | ForEach-Object { Write-Host $_ }
            break
        }
    }

    # Get the NEWEST log file fully
    $newest = $logs | Select-Object -First 1
    if ($newest -and $newest.Name -ne $logs[0].Name) {
        # already printed
    } else {
        Write-Host "`n=== NEWEST LOG: $($newest.Name) (last 80 lines) ==="
        Get-Content $newest.FullName -Tail 80
    }
}

Remove-PSSession $sess
