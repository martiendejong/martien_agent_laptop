$vpsIp = "85.215.217.154"
$cred = New-Object PSCredential("administrator", (ConvertTo-SecureString "SpaceElevator1tam!" -AsPlainText -Force))
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck
$session = New-PSSession -ComputerName $vpsIp -Credential $cred -SessionOption $so -Authentication Negotiate

Invoke-Command -Session $session -ScriptBlock {
    Write-Host "=== Checking src folder ==="
    Get-ChildItem "C:\stores\realestate\src" | Select-Object Name | Format-Table -HideTableHeaders

    Set-Location "C:\stores\realestate\src"

    Write-Host "=== Git status ==="
    git status
    git branch

    Write-Host "=== Git remote ==="
    git remote -v
}

Remove-PSSession $session
