$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== Requesting Let''s Encrypt cert for realestate.martiendejong.com ==='
    Write-Host 'Site ID: 20'

    # Run win-acme to get cert for the site
    $wacsExe = 'C:\win-acme\wacs.exe'

    $result = & $wacsExe `
        --target iis `
        --siteid 20 `
        --host realestate.martiendejong.com `
        --certificatestore WebHosting `
        --installation iis `
        --installationsiteid 20 `
        --accepttos `
        --notaskscheduler `
        --verbose 2>&1

    Write-Host ($result | Out-String)
}

Remove-PSSession $s
