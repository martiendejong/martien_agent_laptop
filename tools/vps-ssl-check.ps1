$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== HTTPS bindings for RealEstateAgency ==='
    Get-WebBinding -Name 'RealEstateAgency' | Format-Table -AutoSize

    Write-Host ''
    Write-Host '=== SSL certificates bound to port 443 ==='
    netsh http show sslcert 2>&1 | Select-String -Pattern 'realestate|0\.0\.0\.0:443|Application ID|Cert Hash' -Context 0,2

    Write-Host ''
    Write-Host '=== All SSL cert bindings (port 443) ==='
    netsh http show sslcert ipport=0.0.0.0:443 2>&1

    Write-Host ''
    Write-Host '=== Certificates in IIS site binding ==='
    Get-ChildItem 'IIS:\SslBindings' -ErrorAction SilentlyContinue | Format-Table -AutoSize

    Write-Host ''
    Write-Host '=== Certificates in Cert store for this domain ==='
    Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -match 'realestate' -or $_.DnsNameList -match 'realestate' } |
        Select-Object Subject, Thumbprint, NotAfter, @{n='SAN';e={$_.DnsNameList -join ', '}} | Format-Table -Wrap

    Write-Host ''
    Write-Host '=== All certs (check expiry) ==='
    Get-ChildItem Cert:\LocalMachine\My | Select-Object Subject, Thumbprint, NotAfter | Sort-Object NotAfter | Format-Table -AutoSize
}

Remove-PSSession $s
