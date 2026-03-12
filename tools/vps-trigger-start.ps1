$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== Check dotnet is available ==='
    & dotnet --version 2>&1

    Write-Host ''
    Write-Host '=== Trigger app with HTTP request (warm up) ==='
    try {
        $r = Invoke-WebRequest -Uri 'http://localhost/' -Headers @{Host='realestate.martiendejong.com'} -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        Write-Host "HTTP $($r.StatusCode)"
    } catch {
        Write-Host "Request result: $($_.Exception.Message)"
        if ($_.Exception.Response) { Write-Host "Status: $($_.Exception.Response.StatusCode)" }
    }

    Start-Sleep -Seconds 10

    Write-Host ''
    Write-Host '=== Dotnet processes ==='
    Get-Process -Name dotnet -ErrorAction SilentlyContinue | Format-Table Id, CPU, WorkingSet, StartTime -AutoSize

    Write-Host ''
    Write-Host '=== ANCM events ==='
    Get-EventLog -LogName Application -Source '*AspNetCore*' -Newest 5 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap

    Write-Host ''
    Write-Host '=== Latest log ==='
    $logs = Get-ChildItem 'C:\stores\realestate\logs' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "$($logs.Name) - $($logs.LastWriteTime) - $($logs.Length) bytes"
}

Remove-PSSession $s
