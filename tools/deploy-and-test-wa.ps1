$PublishDir = 'C:\Projects\whatsappbridge\publish'
$SessionId = '7006e4c8-b1d9-4d33-b004-62fac5b1538f'

$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

# 1. Stop app pool
Write-Host "Stopping app pool..."
Invoke-Command -Session $sess -ScriptBlock {
    Import-Module WebAdministration
    $pool = (Get-Website -Name 'WhatsAppBridgeAPI').applicationPool
    Stop-WebAppPool -Name $pool -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}

# 2. Copy files
Write-Host "Copying files..."
Copy-Item -Path "$PublishDir\*" -Destination 'C:\inetpub\whatsappbridge-api' -ToSession $sess -Recurse -Force

# 3. Clear signals.json and old debug logs
Write-Host "Clearing session data..."
Invoke-Command -Session $sess -ScriptBlock {
    param($sid)
    $base = 'C:\inetpub\whatsappbridge-api'

    # Clear signals.json
    $signalsFile = Join-Path $base "whatsapp-sessions\$sid\signals.json"
    if (Test-Path $signalsFile) { Remove-Item $signalsFile -Force; Write-Host "  Cleared signals.json" }

    # Clear old debug logs
    Remove-Item (Join-Path $base 'logs\signal-x3dh-debug.log') -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $base 'logs\signal-encrypt-debug.log') -Force -ErrorAction SilentlyContinue
    Write-Host "  Cleared old debug logs"
} -ArgumentList $SessionId

# 4. Start app pool
Write-Host "Starting app pool..."
Invoke-Command -Session $sess -ScriptBlock {
    Import-Module WebAdministration
    $pool = (Get-Website -Name 'WhatsAppBridgeAPI').applicationPool
    Start-WebAppPool -Name $pool
    Start-Sleep -Seconds 8
    Write-Host "  App pool state: $((Get-WebAppPoolState -Name $pool).Value)"
}

Write-Host "Deploy complete. Waiting for session..."
Remove-PSSession $sess
