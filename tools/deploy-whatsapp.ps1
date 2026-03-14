param(
    [string]$PublishDir = 'C:\Projects\whatsappbridge\publish',
    [string]$Server = '85.215.217.154',
    [int]$Port = 5985,
    [string]$SessionId = '7006e4c8-b1d9-4d33-b004-62fac5b1538f'
)

$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)

Write-Host "Connecting to $Server..."
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port $Port

Write-Host "Stopping IIS site..."
Invoke-Command -Session $sess -ScriptBlock { Stop-Website -Name 'WhatsAppBridge' -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2 }

Write-Host "Copying files..."
$remoteDir = 'C:\inetpub\whatsappbridge'
$files = Get-ChildItem -Path $PublishDir -File
foreach ($f in $files) {
    Copy-Item -Path $f.FullName -Destination "$remoteDir\$($f.Name)" -ToSession $sess -Force
}

Write-Host "Clearing signals.json..."
Invoke-Command -Session $sess -ScriptBlock {
    param($sid)
    $signalsFile = "C:\inetpub\whatsappbridge\whatsapp-sessions\$sid\signals.json"
    if (Test-Path $signalsFile) { Remove-Item $signalsFile -Force; Write-Host "Cleared signals.json" }
    else { Write-Host "signals.json not found (fresh)" }
} -ArgumentList $SessionId

Write-Host "Starting IIS site..."
Invoke-Command -Session $sess -ScriptBlock { Start-Website -Name 'WhatsAppBridge'; Start-Sleep -Seconds 3 }

Write-Host "Deployment complete."
Remove-PSSession $sess
