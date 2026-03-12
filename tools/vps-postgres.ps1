$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Write-Host '=== PostgreSQL service ==='
    Get-Service -Name 'postgresql*' -ErrorAction SilentlyContinue | Format-Table Name, Status, StartType -AutoSize

    Write-Host '=== postgres process ==='
    Get-Process -Name 'postgres' -ErrorAction SilentlyContinue | Format-Table Id, CPU, WorkingSet, StartTime -AutoSize

    Write-Host '=== Port 5432 listening? ==='
    $tcp = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
    $listeners = $tcp.GetActiveTcpListeners()
    $listeners | Where-Object { $_.Port -eq 5432 } | Format-Table

    Write-Host '=== Test TCP connect to 5432 ==='
    $c = New-Object System.Net.Sockets.TcpClient
    try {
        $c.Connect('127.0.0.1', 5432)
        Write-Host 'Port 5432 OPEN - PostgreSQL is accepting connections'
        $c.Close()
    } catch {
        Write-Host "Port 5432 CLOSED - PostgreSQL is NOT running: $_"
    }

    Write-Host ''
    Write-Host '=== Try starting postgresql if stopped ==='
    $svc = Get-Service -Name 'postgresql*' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($svc) {
        Write-Host "Service: $($svc.Name) - Status: $($svc.Status)"
        if ($svc.Status -ne 'Running') {
            Write-Host "Starting $($svc.Name)..."
            Start-Service $svc.Name
            Start-Sleep -Seconds 3
            $svc.Refresh()
            Write-Host "Status after start: $($svc.Status)"
        }
    } else {
        Write-Host 'No PostgreSQL service found by name - checking by port...'
    }
}

Remove-PSSession $s
