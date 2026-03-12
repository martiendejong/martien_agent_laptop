$vpsIp = "85.215.217.154"
$cred = New-Object PSCredential("administrator", (ConvertTo-SecureString "SpaceElevator1tam!" -AsPlainText -Force))
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck

# Allow unencrypted for this session (WinRM HTTP)
$session = New-PSSession -ComputerName $vpsIp -Credential $cred -SessionOption $so -Authentication Negotiate

Invoke-Command -Session $session -ScriptBlock {
    Write-Host "=== Finding source repo ==="
    $candidates = @("C:\stores\realestate","C:\inetpub\wwwroot\realestate","C:\sites\realestate","C:\realestate","C:\projects\realestate","C:\app")
    foreach ($p in $candidates) {
        if (Test-Path $p) {
            Write-Host "EXISTS: $p"
            Get-ChildItem $p | Select-Object Name | Format-Table -HideTableHeaders
        }
    }

    Write-Host "=== Git check ==="
    try { git --version } catch { Write-Host "Git not found" }

    Write-Host "=== IIS Sites ==="
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    Get-Website | Select-Object Name, PhysicalPath, State | Format-Table
}

Remove-PSSession $session
