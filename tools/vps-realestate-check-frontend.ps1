$vpsIp = "85.215.217.154"
$cred = New-Object PSCredential("administrator", (ConvertTo-SecureString "SpaceElevator1tam!" -AsPlainText -Force))
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck
$session = New-PSSession -ComputerName $vpsIp -Credential $cred -SessionOption $so -Authentication Negotiate

Invoke-Command -Session $session -ScriptBlock {
    Import-Module WebAdministration

    Write-Host "=== RealEstateAgency site bindings ==="
    Get-WebBinding -Name "RealEstateAgency" | Format-Table

    Write-Host "=== RealEstateAgency virtual directories ==="
    Get-WebVirtualDirectory -Site "RealEstateAgency" | Format-Table

    Write-Host "=== web.config of backend ==="
    if (Test-Path "C:\stores\realestate\backend\web.config") {
        Get-Content "C:\stores\realestate\backend\web.config"
    }

    Write-Host "=== www folder contents ==="
    Get-ChildItem "C:\stores\realestate\www" | Select-Object Name, Length | Format-Table

    Write-Host "=== Does backend have wwwroot? ==="
    if (Test-Path "C:\stores\realestate\backend\wwwroot") {
        Get-ChildItem "C:\stores\realestate\backend\wwwroot" | Select-Object Name | Format-Table
    } else {
        Write-Host "No wwwroot in backend"
    }

    Write-Host "=== Is there a separate frontend IIS site? ==="
    Get-Website | Where-Object { $_.PhysicalPath -like "*realestate*" } | Format-Table Name, PhysicalPath, State
}

Remove-PSSession $session
