$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Write-Host '=== IIS Sites ==='
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    Get-Website | Select-Object Name, State, PhysicalPath | Format-Table -AutoSize

    Write-Host '=== App Pools ==='
    Get-WebConfiguration system.applicationHost/applicationPools/add | Select-Object name, state | Format-Table -AutoSize

    Write-Host '=== Dotnet processes ==='
    Get-Process -Name dotnet -ErrorAction SilentlyContinue | Select-Object Id, CPU, WorkingSet, StartTime | Format-Table -AutoSize

    Write-Host '=== Recent App Event Errors ==='
    Get-EventLog -LogName Application -EntryType Error -Newest 10 -ErrorAction SilentlyContinue | Select-Object TimeGenerated, Source, @{n='Msg';e={$_.Message.Substring(0, [Math]::Min(200,$_.Message.Length))}} | Format-Table -Wrap
}

Remove-PSSession $s
