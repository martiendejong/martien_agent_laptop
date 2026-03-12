$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    # 1. Check rapid fail protection state
    Write-Host '=== Rapid fail state ==='
    $pool = Get-Item "IIS:\AppPools\RealEstatePool"
    Write-Host "Pool state: $($pool.state)"
    Write-Host "Failure.autoShutdownExe: $($pool.failure.autoShutdownExe)"

    # 2. Switch web.config to outofprocess (more stable for .NET hosted in IIS)
    $webConfig = 'C:\stores\realestate\backend\web.config'
    $content = Get-Content $webConfig -Raw

    # Change inprocess to outofprocess
    $newContent = $content -replace 'hostingModel="inprocess"', 'hostingModel="outofprocess"'
    $newContent | Set-Content $webConfig -Encoding UTF8
    Write-Host ''
    Write-Host '=== Updated web.config ==='
    Get-Content $webConfig

    # 3. Hard reset the pool
    Write-Host ''
    Write-Host '=== Resetting pool ==='
    Stop-WebAppPool -Name 'RealEstatePool'
    Start-Sleep -Seconds 3

    # Reset rapid fail counter by toggling rapidFailProtection
    Set-WebConfiguration system.applicationHost/applicationPools/add[@name='RealEstatePool']/failure -Value @{rapidFailProtection=$false}
    Start-Sleep -Seconds 1
    Set-WebConfiguration system.applicationHost/applicationPools/add[@name='RealEstatePool']/failure -Value @{rapidFailProtection=$true; rapidFailProtectionInterval='00:05:00'; rapidFailProtectionMaxCrashes=5}

    Start-WebAppPool -Name 'RealEstatePool'
    Write-Host 'Waiting 20 seconds for startup...'
    Start-Sleep -Seconds 20

    Write-Host ''
    Write-Host '=== Pool state after restart ==='
    (Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' }).state

    Write-Host ''
    Write-Host '=== ANCM events ==='
    Get-EventLog -LogName Application -Source '*AspNetCore*' -Newest 5 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap

    Write-Host ''
    Write-Host '=== Dotnet processes (outofprocess) ==='
    Get-Process -Name dotnet -ErrorAction SilentlyContinue | Format-Table Id, CPU, WorkingSet, StartTime -AutoSize

    Write-Host ''
    Write-Host '=== Test API ==='
    try {
        [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        $r = Invoke-WebRequest -Uri 'https://realestate.martiendejong.com/api/settings/agency' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        Write-Host "HTTP $($r.StatusCode) - API UP!"
    } catch {
        Write-Host "API test: $_"
    }
}

Remove-PSSession $s
