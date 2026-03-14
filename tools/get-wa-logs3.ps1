$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

Invoke-Command -Session $sess -ScriptBlock {
    # Check all log files updated in last 30 mins
    Write-Host "=== Recent log files ==="
    Get-ChildItem 'C:\inetpub\whatsappbridge-api\logs' -Recurse |
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-30) } |
        Sort-Object LastWriteTime -Descending |
        Format-Table Name, Length, LastWriteTime -AutoSize

    # Check for the newest stdout log
    $allLogs = Get-ChildItem 'C:\inetpub\whatsappbridge-api\logs' -Filter 'stdout_*.log' | Sort-Object Name -Descending
    Write-Host "`n=== 3 newest log files by name ==="
    $allLogs | Select-Object -First 3 | Format-Table Name, Length, LastWriteTime -AutoSize

    # Read the ACTUAL newest (by name, which includes timestamp)
    $newest = $allLogs | Select-Object -First 1
    Write-Host "`n=== $($newest.Name) - FULL CONTENT ==="
    Get-Content $newest.FullName

    # Check w3wp process
    Write-Host "`n=== w3wp processes ==="
    Get-Process w3wp -ErrorAction SilentlyContinue | Select-Object Id, StartTime, WorkingSet64 | Format-Table -AutoSize
}

Remove-PSSession $sess
