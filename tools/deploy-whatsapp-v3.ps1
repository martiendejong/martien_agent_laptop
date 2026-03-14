$PublishDir = 'C:\Projects\whatsappbridge\publish'
$SessionId = '7006e4c8-b1d9-4d33-b004-62fac5b1538f'

$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

# 1. Stop site + app pool
Write-Host "Stopping WhatsAppBridgeAPI..."
Invoke-Command -Session $sess -ScriptBlock {
    Import-Module WebAdministration
    Stop-Website -Name 'WhatsAppBridgeAPI' -ErrorAction SilentlyContinue
    Stop-WebAppPool -Name 'WhatsAppBridgeAPI' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Write-Host "Site stopped"
}

# 2. Copy publish output to remote
Write-Host "Copying published files..."
Copy-Item -Path "$PublishDir\*" -Destination 'C:\inetpub\whatsappbridge-api' -ToSession $sess -Recurse -Force
Write-Host "Files copied"

# 3. Clear signals.json
Write-Host "Clearing signals.json..."
Invoke-Command -Session $sess -ScriptBlock {
    param($sid)
    $base = 'C:\inetpub\whatsappbridge-api'
    $signalsFile = Join-Path $base "whatsapp-sessions\$sid\signals.json"
    if (Test-Path $signalsFile) { Remove-Item $signalsFile -Force; Write-Host "Cleared signals.json at $signalsFile" }
    else { Write-Host "signals.json not found at $signalsFile (fresh session)" }

    # Also check bin dir
    $signalsFile2 = Join-Path $base "bin\Release\net8.0\whatsapp-sessions\$sid\signals.json"
    if (Test-Path $signalsFile2) { Remove-Item $signalsFile2 -Force; Write-Host "Cleared signals.json at $signalsFile2" }
} -ArgumentList $SessionId

# 4. Start site
Write-Host "Starting WhatsAppBridgeAPI..."
Invoke-Command -Session $sess -ScriptBlock {
    Import-Module WebAdministration
    Start-WebAppPool -Name 'WhatsAppBridgeAPI' -ErrorAction SilentlyContinue
    Start-Website -Name 'WhatsAppBridgeAPI'
    Start-Sleep -Seconds 3
    Write-Host "Site started"
}

Write-Host "Deployment complete!"
Remove-PSSession $sess
