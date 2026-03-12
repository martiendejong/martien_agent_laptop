$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Write-Host '=== All scheduled tasks with short intervals or iisreset ==='
    Get-ScheduledTask | ForEach-Object {
        $task = $_
        $triggers = $task.Triggers
        $actions = $task.Actions
        $isShort = $triggers | Where-Object {
            ($_ -is [Microsoft.Management.Infrastructure.CimInstance]) -and
            ($_.RepetitionInterval -ne $null) -and
            ($_.RepetitionInterval.TotalMinutes -le 60)
        }
        $hasIIS = $actions | Where-Object { $_.Execute -match 'iisreset|iis|w3svc' -or $_.Arguments -match 'iisreset|realestate' }
        if ($isShort -or $hasIIS) {
            Write-Host "Task: $($task.TaskName) | State: $($task.State)"
            Write-Host "  Actions: $($actions | ForEach-Object { "$($_.Execute) $($_.Arguments)" })"
            Write-Host "  Triggers: $($triggers | ForEach-Object { "Interval: $($_.RepetitionInterval)" })"
        }
    }

    Write-Host ''
    Write-Host '=== All custom/non-system scheduled tasks ==='
    Get-ScheduledTask | Where-Object {
        $_.TaskPath -notmatch '\\Microsoft\\' -and $_.State -ne 'Disabled'
    } | Select-Object TaskName, TaskPath, State, @{n='LastRun';e={$_.LastRunTime}}, @{n='NextRun';e={$_.NextRunTime}} | Format-Table -AutoSize

    Write-Host ''
    Write-Host '=== System event log - last 5 iisreset/service restart events ==='
    Get-EventLog -LogName System -Newest 100 -ErrorAction SilentlyContinue |
        Where-Object { $_.Message -match 'W3SVC|IIS|World Wide Web|RealEstate' } |
        Select-Object -First 10 TimeGenerated, EntryType, Source, Message | Format-Table -Wrap
}

Remove-PSSession $s
