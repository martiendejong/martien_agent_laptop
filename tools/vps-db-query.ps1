$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    # Query AppSettings via psql
    $env:PGPASSWORD = 'RealEstate2026Pass'
    $psql = 'C:\Program Files\PostgreSQL\16\bin\psql.exe'

    Write-Host '=== AppSettings ==='
    & $psql -h 127.0.0.1 -U realestate_user -d realestate_db -c "SELECT key, value FROM \"AppSettings\" ORDER BY key;" 2>&1

    Write-Host ''
    Write-Host '=== Email settings specifically ==='
    & $psql -h 127.0.0.1 -U realestate_user -d realestate_db -c "SELECT key, value FROM \"AppSettings\" WHERE key LIKE 'email%' OR key LIKE 'whatsapp%' ORDER BY key;" 2>&1
}

Remove-PSSession $s
