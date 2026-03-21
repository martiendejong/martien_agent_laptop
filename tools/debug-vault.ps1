$output = & "C:\scripts\tools\vault.ps1" -Action get -Service whatsapp-bridge-api
Write-Host "=== Output items ==="
$output | ForEach-Object {
    Write-Host "Type: $($_.GetType().Name)"
    if ($_ -is [string]) {
        Write-Host "  String: $_"
    } else {
        Write-Host "  Object properties:"
        $_ | Get-Member -MemberType Property | ForEach-Object {
            Write-Host "    $($_.Name) = $($_[$_.Name])"
        }
    }
}

Write-Host ""
Write-Host "=== Non-string items ==="
$objects = $output | Where-Object { $_ -isnot [string] }
Write-Host "Count: $($objects.Count)"
$objects | ForEach-Object {
    Write-Host "Password: $($_.password)"
    Write-Host "Username: $($_.username)"
}
