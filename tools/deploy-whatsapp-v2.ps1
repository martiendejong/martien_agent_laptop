$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

# 1. Check server paths and IIS sites
Write-Host "=== Checking server ==="
Invoke-Command -Session $sess -ScriptBlock {
    Write-Host "IIS Sites:"
    Get-Website | Select-Object Name, State, PhysicalPath | Format-Table -AutoSize
    Write-Host ""
    Write-Host "App Pools:"
    Get-WebAppPoolState | Format-Table -AutoSize
    Write-Host ""
    Write-Host "WhatsApp dir contents:"
    if (Test-Path 'C:\inetpub\whatsappbridge') {
        Get-ChildItem 'C:\inetpub\whatsappbridge' -Name | Select-Object -First 10
    } else {
        Write-Host "C:\inetpub\whatsappbridge does NOT exist"
        # Search for it
        Get-ChildItem 'C:\inetpub' -Directory -Name
    }
}

Remove-PSSession $sess
