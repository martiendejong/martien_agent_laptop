$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration -ErrorAction SilentlyContinue

    Write-Host '=== Stdout logs ==='
    $logDir = 'C:\stores\realestate\logs'
    if (Test-Path $logDir) {
        $latest = Get-ChildItem $logDir -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 3
        foreach ($f in $latest) {
            Write-Host "--- $($f.Name) ($(($f.LastWriteTime))) ---"
            Get-Content $f.FullName -Tail 60 -ErrorAction SilentlyContinue
            Write-Host ''
        }
    } else {
        Write-Host "Log dir not found: $logDir"
    }

    Write-Host '=== Restarting RealEstateAgency ==='
    Stop-WebAppPool -Name 'RealEstatePool' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-WebAppPool -Name 'RealEstatePool'
    Start-Sleep -Seconds 3

    Write-Host '=== App pool state after restart ==='
    (Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' }).state

    Write-Host '=== Testing API endpoint ==='
    Start-Sleep -Seconds 5
    try {
        $r = Invoke-WebRequest -Uri 'http://localhost/api/settings/agency' -Headers @{Host='realestate.martiendejong.com'} -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        Write-Host "HTTP $($r.StatusCode) - API responding"
    } catch {
        Write-Host "API test failed: $_"
    }

    Write-Host '=== ANCM events after restart ==='
    Get-EventLog -LogName Application -Source '*AspNetCore*' -Newest 5 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap
}

Remove-PSSession $s
