$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== All app event errors in last 30 min ==='
    $cutoff = (Get-Date).AddMinutes(-30)
    Get-EventLog -LogName Application -EntryType Error,Warning -After $cutoff -ErrorAction SilentlyContinue |
        Where-Object { $_.Source -match 'ASP|IIS|dotnet|W3|WAS|RealEstate' -or $_.Message -match 'RealEstate|realestate' } |
        Select-Object TimeGenerated, EntryType, Source, @{n='Msg';e={$_.Message.Substring(0,[Math]::Min(400,$_.Message.Length))}} |
        Format-Table -Wrap

    Write-Host ''
    Write-Host '=== All event errors in last 30 min (broader) ==='
    Get-EventLog -LogName Application -EntryType Error -After $cutoff -ErrorAction SilentlyContinue |
        Select-Object -First 15 TimeGenerated, Source, @{n='Msg';e={$_.Message.Substring(0,[Math]::Min(300,$_.Message.Length))}} |
        Format-Table -Wrap

    Write-Host ''
    Write-Host '=== Try hitting API locally ==='
    try {
        $r = Invoke-WebRequest -Uri 'http://localhost/api/settings/agency' `
            -Headers @{Host='realestate.martiendejong.com'} `
            -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        Write-Host "HTTP $($r.StatusCode)"
        Write-Host $r.Content.Substring(0, [Math]::Min(500, $r.Content.Length))
    } catch {
        Write-Host "Error: $_"
        if ($_.Exception.Response) {
            Write-Host "Status: $($_.Exception.Response.StatusCode)"
        }
    }

    Write-Host ''
    Write-Host '=== Check if new stdout log appeared ==='
    Get-ChildItem 'C:\stores\realestate\logs' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 5 |
        Format-Table Name, LastWriteTime, Length -AutoSize

    Write-Host ''
    Write-Host '=== Run app directly to see startup error ==='
    $env:ASPNETCORE_ENVIRONMENT = 'Production'
    $output = & 'C:\stores\realestate\backend\RealEstateAgencyAPI.exe' --no-launch-profile 2>&1
    Write-Host ($output | Select-Object -First 30 | Out-String)
}

Remove-PSSession $s
