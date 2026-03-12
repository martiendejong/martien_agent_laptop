$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== Current idle timeout ==='
    $current = (Get-ItemProperty "IIS:\AppPools\RealEstatePool" -Name processModel).idleTimeout
    Write-Host "Current: $current"

    Write-Host '=== Setting idle timeout to 0 (disabled) ==='
    Set-ItemProperty "IIS:\AppPools\RealEstatePool" -Name processModel -Value @{idleTimeout="00:00:00"}

    $updated = (Get-ItemProperty "IIS:\AppPools\RealEstatePool" -Name processModel).idleTimeout
    Write-Host "Updated: $updated"

    Write-Host ''
    Write-Host '=== Verifying startMode is AlwaysRunning ==='
    $startMode = (Get-ItemProperty "IIS:\AppPools\RealEstatePool" -Name startMode)
    Write-Host "startMode: $startMode"

    Write-Host ''
    Write-Host '=== Recycling pool to apply changes ==='
    Restart-WebAppPool -Name 'RealEstatePool'
    Start-Sleep -Seconds 5

    $state = (Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' }).state
    Write-Host "Pool state: $state"
}

Remove-PSSession $s
