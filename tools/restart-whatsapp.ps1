$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

Invoke-Command -Session $sess -ScriptBlock {
    Import-Module WebAdministration
    # Find app pool for site
    $site = Get-Website -Name 'WhatsAppBridgeAPI'
    Write-Host "Site: $($site.Name), AppPool: $($site.applicationPool), State: $($site.State)"

    $poolName = $site.applicationPool
    Write-Host "Recycling app pool: $poolName"
    Restart-WebAppPool -Name $poolName
    Start-Sleep -Seconds 5

    $state = Get-WebAppPoolState -Name $poolName
    Write-Host "App pool state: $($state.Value)"

    $siteState = (Get-Website -Name 'WhatsAppBridgeAPI').State
    Write-Host "Site state: $siteState"
}

Remove-PSSession $sess
