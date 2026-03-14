$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

Invoke-Command -Session $sess -ScriptBlock {
    Import-Module WebAdministration
    $bindings = Get-WebBinding -Name 'WhatsAppBridgeAPI'
    Write-Host "Bindings for WhatsAppBridgeAPI:"
    $bindings | Format-Table protocol, bindingInformation -AutoSize

    # Check if the site is responsive locally
    try {
        $resp = Invoke-WebRequest -Uri 'http://localhost:5080/api/WhatsApp/test-status/7006e4c8-b1d9-4d33-b004-62fac5b1538f' -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        Write-Host "Local test (port 5080): $($resp.StatusCode) - $($resp.Content)"
    } catch {
        Write-Host "Port 5080 failed: $($_.Exception.Message)"
    }

    # Check the logs
    $logDir = 'C:\inetpub\whatsappbridge-api\whatsapp-sessions\7006e4c8-b1d9-4d33-b004-62fac5b1538f'
    Write-Host "`nSession dir contents:"
    if (Test-Path $logDir) {
        Get-ChildItem $logDir -Name
    } else {
        Write-Host "Session dir does not exist"
    }

    # Check stdout logs
    $stdoutLog = Get-ChildItem 'C:\inetpub\whatsappbridge-api\logs' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($stdoutLog) {
        Write-Host "`nLatest log: $($stdoutLog.Name)"
        Get-Content $stdoutLog.FullName -Tail 30
    }
}

Remove-PSSession $sess
