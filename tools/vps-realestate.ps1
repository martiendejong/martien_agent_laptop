$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration -ErrorAction SilentlyContinue

    Write-Host '=== RealEstateAgency Site Bindings ==='
    Get-WebBinding -Name 'RealEstateAgency' | Format-Table -AutoSize

    Write-Host '=== RealEstate App Pool State ==='
    Get-WebConfiguration system.applicationHost/applicationPools/add | Where-Object { $_.name -eq 'RealEstatePool' } | Format-List

    Write-Host '=== w3wp processes ==='
    Get-Process -Name w3wp -ErrorAction SilentlyContinue | Format-Table Id, CPU, WorkingSet, StartTime -AutoSize

    Write-Host '=== Backend folder contents ==='
    Get-ChildItem C:\stores\realestate\backend -ErrorAction SilentlyContinue | Select-Object Name, LastWriteTime | Format-Table -AutoSize

    Write-Host '=== web.config ==='
    Get-Content C:\stores\realestate\backend\web.config -ErrorAction SilentlyContinue

    Write-Host '=== ANCM / App crash log ==='
    $logPath = "C:\stores\realestate\backend\logs"
    if (Test-Path $logPath) {
        $latest = Get-ChildItem $logPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latest) {
            Write-Host "Latest log: $($latest.FullName)"
            Get-Content $latest.FullName -Tail 50
        }
    } else {
        Write-Host "No logs folder at $logPath"
        # Try stdout logs
        Get-ChildItem C:\stores\realestate\backend -Filter "*.log" -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "--- $($_.Name) ---"
            Get-Content $_.FullName -Tail 30
        }
    }

    Write-Host '=== IIS ANCM event log ==='
    Get-EventLog -LogName Application -Source '*AspNetCore*' -Newest 10 -ErrorAction SilentlyContinue |
        Select-Object TimeGenerated, EntryType, Message | Format-Table -Wrap
}

Remove-PSSession $s
