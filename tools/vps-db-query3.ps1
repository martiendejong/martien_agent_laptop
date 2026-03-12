$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    $env:PGPASSWORD = 'RealEstate2026Pass'
    $psql = 'C:\Program Files\PostgreSQL\16\bin\psql.exe'

    $sql = @'
SELECT "Key", "Value" FROM "AppSettings" ORDER BY "Key";
'@
    $sqlFile = 'C:\Windows\Temp\query.sql'
    $sql | Set-Content $sqlFile -Encoding UTF8

    Write-Host '=== AppSettings ==='
    & $psql -h 127.0.0.1 -U realestate_user -d realestate_db -f $sqlFile 2>&1
}

Remove-PSSession $s
