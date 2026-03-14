$secpw = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('Administrator', $secpw)
$sess = New-PSSession -ComputerName '85.215.217.154' -Credential $cred -Port 5985

Invoke-Command -Session $sess -ScriptBlock {
    $base = 'C:\inetpub\whatsappbridge-api\logs'

    Write-Host "=== signal-x3dh-debug.log ==="
    $f = Join-Path $base 'signal-x3dh-debug.log'
    if (Test-Path $f) { Get-Content $f } else { Write-Host "(not found)" }

    Write-Host "`n=== signal-encrypt-debug.log ==="
    $f = Join-Path $base 'signal-encrypt-debug.log'
    if (Test-Path $f) { Get-Content $f } else { Write-Host "(not found)" }

    Write-Host "`n=== stdout log (last 50 lines) ==="
    $latest = Get-ChildItem $base -Filter 'stdout_*.log' | Sort-Object Name -Descending | Select-Object -First 1
    if ($latest) { Get-Content $latest.FullName -Tail 50 } else { Write-Host "(no stdout log)" }
}

Remove-PSSession $sess
