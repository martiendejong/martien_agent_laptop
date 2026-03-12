$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== RealEstatePool recycling config ==='
    $pool = Get-Item "IIS:\AppPools\RealEstatePool"
    $recycling = $pool.recycling
    Write-Host "Periodic restart time (minutes): $($recycling.periodicRestart.time.TotalMinutes)"
    Write-Host "Memory limit (KB): $($recycling.periodicRestart.memory)"
    Write-Host "Private memory limit (KB): $($recycling.periodicRestart.privateMemory)"
    Write-Host "Requests limit: $($recycling.periodicRestart.requests)"

    Write-Host ''
    Write-Host '=== Scheduled recycle times ==='
    $pool.recycling.periodicRestart.schedule | Format-Table

    Write-Host ''
    Write-Host '=== Failure config (rapid fail protection) ==='
    $pool.failure | Format-List

    Write-Host ''
    Write-Host '=== Scheduled tasks that might restart IIS ==='
    Get-ScheduledTask | Where-Object { $_.TaskName -match 'realestate|iis|recycle|bliek' -or $_.Actions.Execute -match 'iisreset|realestate' } | Select-Object TaskName, State, LastRunTime, NextRunTime | Format-Table -AutoSize

    Write-Host ''
    Write-Host '=== SSL cert renewal tasks ==='
    Get-ScheduledTask | Where-Object { $_.TaskName -match 'acme|cert|ssl|letsencrypt|winacme' } | Select-Object TaskName, State, LastRunTime, NextRunTime | Format-Table -AutoSize
}

Remove-PSSession $s
