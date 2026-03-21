$file = "E:\projects\bliek\src\Bliek.API\bin\Debug\net9.0\Bliek.Infrastructure.dll"
$ErrorActionPreference = 'SilentlyContinue'

# Find all processes that have this file's directory open
$dir = Split-Path $file
$procs = Get-Process | Where-Object {
    $_.Modules | Where-Object { $_.FileName -like "*Bliek*" }
}

if ($procs) {
    foreach ($p in $procs) {
        Write-Output "Found: $($p.ProcessName) PID=$($p.Id)"
        Stop-Process -Id $p.Id -Force
        Write-Output "  -> Killed"
    }
} else {
    Write-Output "No processes found with Bliek modules loaded"
    # Try handle-based approach - just kill all dotnet
    $dotnetProcs = Get-Process dotnet -ErrorAction SilentlyContinue
    if ($dotnetProcs) {
        foreach ($p in $dotnetProcs) {
            Write-Output "Killing dotnet PID=$($p.Id)"
            Stop-Process -Id $p.Id -Force
        }
    } else {
        Write-Output "No dotnet processes running either"
        # Last resort: try to delete the locked file
        try {
            Remove-Item $file -Force
            Write-Output "Deleted locked file, rebuild will recreate it"
        } catch {
            Write-Output "Cannot delete: $($_.Exception.Message)"
        }
    }
}
