$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    # Stop and start cleanly
    Write-Host '=== Stopping pool ==='
    Stop-WebAppPool -Name 'RealEstatePool'
    Start-Sleep -Seconds 3

    Write-Host '=== Starting pool ==='
    Start-WebAppPool -Name 'RealEstatePool'
    Start-Sleep -Seconds 8

    Write-Host '=== Pool state ==='
    (Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' }).state

    Write-Host '=== w3wp for RealEstate ==='
    Get-Process -Name w3wp -ErrorAction SilentlyContinue | Format-Table Id, CPU, WorkingSet, StartTime -AutoSize

    Write-Host '=== ANCM events ==='
    Get-EventLog -LogName Application -Source '*AspNetCore*' -Newest 5 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap

    Write-Host '=== Latest stdout log (last 40 lines) ==='
    $logDir = 'C:\stores\realestate\logs'
    $latest = Get-ChildItem $logDir -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) {
        Write-Host "File: $($latest.Name) - Modified: $($latest.LastWriteTime)"
        Get-Content $latest.FullName -Tail 40
    }
}

Remove-PSSession $s
