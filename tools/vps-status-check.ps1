$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== Pool state ==='
    (Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' }).state

    Write-Host '=== Site state ==='
    (Get-Website -Name 'RealEstateAgency').State

    Write-Host '=== w3wp processes ==='
    Get-Process -Name w3wp -ErrorAction SilentlyContinue | Format-Table Id, CPU, WorkingSet, StartTime -AutoSize

    Write-Host '=== ANCM recent events ==='
    Get-EventLog -LogName Application -Source '*AspNetCore*' -Newest 5 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap

    Write-Host '=== WAS recent events ==='
    Get-EventLog -LogName System -Source 'WAS' -Newest 5 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap

    Write-Host '=== Latest stdout log ==='
    $logDir = 'C:\stores\realestate\logs'
    $latest = Get-ChildItem $logDir -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) {
        Write-Host "File: $($latest.Name)"
        Get-Content $latest.FullName -Tail 30
    }
}

Remove-PSSession $s
