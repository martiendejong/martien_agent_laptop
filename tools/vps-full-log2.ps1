$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    $logDir = 'C:\stores\realestate\logs'
    $latest = Get-ChildItem $logDir | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "=== COMPLETE log: $($latest.Name) ==="
    Get-Content $latest.FullName
}

Remove-PSSession $s
