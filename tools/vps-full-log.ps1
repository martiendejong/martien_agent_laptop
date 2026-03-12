$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    # Get the latest log
    $logDir = 'C:\stores\realestate\logs'
    $latest = Get-ChildItem $logDir | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "=== Full log: $($latest.Name) ($($latest.Length) bytes) ==="

    # Show only lines containing error/warn/fail/shutdown
    $content = Get-Content $latest.FullName
    $interesting = $content | Where-Object {
        $_ -match 'fail:|error|warn:|Exception|shutdown|stopped|Unhandled|critical|CRIT' -and
        $_ -notmatch 'global query filter|navigation as optional'
    }
    Write-Host ($interesting | Out-String)

    Write-Host ''
    Write-Host '=== Last 50 lines ==='
    $content | Select-Object -Last 50 | ForEach-Object { Write-Host $_ }
}

Remove-PSSession $s
