# Quick launcher for sentinel process (fully hidden and detached)
# This runs completely in the background with no visible windows

$sentinelScript = "C:\scripts\tools\session-sentinel.ps1"

# Use WMI to create a fully detached process
$wmiResult = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
    CommandLine = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$sentinelScript`" -ClaudePid 0"
}

if ($wmiResult.ReturnValue -eq 0) {
    # Success - sentinel is running with PID: $wmiResult.ProcessId
    exit 0
} else {
    # Fallback to Start-Process
    Start-Process -FilePath "powershell.exe" `
        -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", $sentinelScript, "-ClaudePid", "0") `
        -WindowStyle Hidden
    exit 0
}
