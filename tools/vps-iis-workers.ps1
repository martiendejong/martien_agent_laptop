$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== Worker processes per app pool ==='
    Get-WebConfiguration system.applicationHost/applicationPools/add | ForEach-Object {
        $pool = $_.name
        $workers = $_.workerProcesses
        if ($workers -and $workers.Count -gt 0) {
            foreach ($w in $workers) {
                Write-Host "Pool: $pool | PID: $($w.processId) | State: $($w.state)"
            }
        }
    }

    Write-Host ''
    Write-Host '=== RealEstatePool worker processes specifically ==='
    $rePool = Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' }
    Write-Host "Pool state: $($rePool.state)"
    Write-Host "Worker processes: $($rePool.workerProcesses.Count)"
    $rePool.workerProcesses | ForEach-Object { Write-Host "  PID: $($_.processId) | State: $($_.state)" }

    Write-Host ''
    Write-Host '=== Force fresh pool start ==='
    Stop-WebAppPool -Name 'RealEstatePool'
    Start-Sleep -Seconds 5
    Start-WebAppPool -Name 'RealEstatePool'
    Write-Host 'Waiting 15 seconds for startup...'
    Start-Sleep -Seconds 15

    Write-Host '=== Worker processes after start ==='
    $rePool2 = Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' }
    Write-Host "Pool state: $($rePool2.state)"
    $rePool2.workerProcesses | ForEach-Object { Write-Host "  PID: $($_.processId) | State: $($_.state)" }

    Write-Host ''
    Write-Host '=== ANCM events (newest first) ==='
    Get-EventLog -LogName Application -Source '*AspNetCore*' -Newest 8 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap

    Write-Host ''
    Write-Host '=== Newest stdout log ==='
    Get-ChildItem 'C:\stores\realestate\logs' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 3 |
        ForEach-Object {
            Write-Host "$($_.Name) - $($_.LastWriteTime) - $($_.Length) bytes"
            if ($_.Length -gt 0) { Get-Content $_.FullName -Tail 20 }
        }
}

Remove-PSSession $s
