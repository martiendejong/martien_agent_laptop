$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

Invoke-Command -Session $sess -ScriptBlock {
    $logDir = 'C:\inetpub\whatsappbridge-api\logs'
    $latest = Get-ChildItem $logDir -Filter 'stdout_*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) {
        Write-Host "=== $($latest.Name) (last 120 lines) ==="
        Get-Content $latest.FullName -Tail 120
    }

    # Also check signal-debug.log
    $debugLog = 'C:\inetpub\whatsappbridge-api\logs\signal-debug.log'
    if (Test-Path $debugLog) {
        Write-Host "`n=== signal-debug.log ==="
        Get-Content $debugLog -Tail 30
    }
}

Remove-PSSession $sess
