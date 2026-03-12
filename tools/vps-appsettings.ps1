$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Write-Host '=== appsettings.Production.json ==='
    Get-Content 'C:\stores\realestate\backend\appsettings.Production.json'

    Write-Host ''
    Write-Host '=== appsettings.json ==='
    Get-Content 'C:\stores\realestate\backend\appsettings.json'
}

Remove-PSSession $s
