$ErrorActionPreference = 'SilentlyContinue'

# Kill dotnet processes that lock Bliek DLLs
Get-Process dotnet | ForEach-Object {
    $cmdline = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
    if ($cmdline -match 'bliek|Bliek') {
        Write-Output "Killing dotnet PID $($_.Id): $cmdline"
        Stop-Process -Id $_.Id -Force
    }
}

# Kill any node/vite processes on Bliek ports
$ports = @(3500, 3501, 5000, 7000)
foreach ($port in $ports) {
    $conn = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($conn) {
        foreach ($c in $conn) {
            $proc = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Output "Killing $($proc.ProcessName) PID $($proc.Id) on port $port"
                Stop-Process -Id $proc.Id -Force
            }
        }
    }
}

Write-Output "Done - all Bliek processes killed"
