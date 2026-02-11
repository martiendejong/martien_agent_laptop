$vault = Get-Content 'C:\scripts\_machine\vault.secure.json' | ConvertFrom-Json
$creds = $vault.credentials
Write-Host "Service: $($creds.service)"
Write-Host "Username: $($creds.username)"
Write-Host "Token hint: $($creds.token_hint)"

# Try vault-simple.ps1 to get clickup token
Write-Host "`n--- Trying vault-simple.ps1 ---"
& C:\scripts\tools\vault-simple.ps1 -Action list
