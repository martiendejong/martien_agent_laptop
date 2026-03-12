$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== Current pool state ==='
    $pool = Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' }
    Write-Host "State: $($pool.state)"
    $pool.workerProcesses | ForEach-Object { "Worker PID: $($_.processId) State: $($_.state)" }

    Write-Host ''
    Write-Host '=== ANCM events (last 10) ==='
    Get-EventLog -LogName Application -Source '*AspNetCore*' -Newest 10 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap

    Write-Host ''
    Write-Host '=== Test port 443 locally ==='
    $c = New-Object System.Net.Sockets.TcpClient
    try { $c.Connect('127.0.0.1', 443); Write-Host 'Port 443 OPEN'; $c.Close() } catch { Write-Host "Port 443 error: $_" }

    Write-Host ''
    Write-Host '=== Test HTTPS API ==='
    try {
        [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        $r = Invoke-WebRequest -Uri 'https://realestate.martiendejong.com/api/settings/agency' -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        Write-Host "HTTP $($r.StatusCode) - API UP"
    } catch {
        Write-Host "HTTPS test: $_"
    }

    Write-Host ''
    Write-Host '=== WAS events (last 5) ==='
    Get-EventLog -LogName System -Source 'WAS' -Newest 5 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap

    Write-Host ''
    Write-Host '=== Latest log ==='
    $latest = Get-ChildItem 'C:\stores\realestate\logs' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "$($latest.Name) - $($latest.LastWriteTime) - $($latest.Length) bytes"
}

Remove-PSSession $s
