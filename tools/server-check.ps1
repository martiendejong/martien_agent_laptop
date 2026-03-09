$password = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('administrator', $password)
Invoke-Command -ComputerName 85.215.217.154 -Credential $cred -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -ScriptBlock {
    Write-Host "=== Node.js ==="
    node --version 2>&1
    Write-Host "=== Listening ports ==="
    netstat -ano | Select-String ':9998|:5123|:3000|:27183'
    Write-Host "=== C:\scripts exists? ==="
    Test-Path C:\scripts
    Write-Host "=== C:\jengo exists? ==="
    Test-Path C:\jengo
    Write-Host "=== Running services ==="
    Get-Service | Where-Object { $_.Status -eq 'Running' -and $_.Name -match 'jengo|orche|whats|bridge|nssm' } | Select-Object Name, DisplayName
}
