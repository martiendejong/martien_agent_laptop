$password = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('administrator', $password)
Invoke-Command -ComputerName 85.215.217.154 -Credential $cred -ScriptBlock {
    # Run with log file so we can see errors
    $logFile = 'C:\scripts\_machine\bridge.log'
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'node'
    $startInfo.Arguments = 'C:\scripts\tools\cross-machine-bridge.js'
    $startInfo.WorkingDirectory = 'C:\scripts\tools'
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true
    $proc = [System.Diagnostics.Process]::Start($startInfo)

    # Wait 3 seconds then read output
    Start-Sleep -Seconds 3

    if ($proc.HasExited) {
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        Write-Host "Process EXITED (code $($proc.ExitCode))"
        Write-Host "STDOUT: $stdout"
        Write-Host "STDERR: $stderr"
    } else {
        Write-Host "Process RUNNING (PID $($proc.Id))"
        $proc.Kill()
    }
}
