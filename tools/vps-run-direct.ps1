$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    # Run with Production env, capture output, kill after 10 seconds
    $env:ASPNETCORE_ENVIRONMENT = 'Production'
    $env:ASPNETCORE_URLS = 'http://localhost:5099'

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'dotnet'
    $psi.Arguments = 'C:\stores\realestate\backend\RealEstateAgencyAPI.dll'
    $psi.WorkingDirectory = 'C:\stores\realestate\backend'
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.EnvironmentVariables['ASPNETCORE_ENVIRONMENT'] = 'Production'
    $psi.EnvironmentVariables['ASPNETCORE_URLS'] = 'http://localhost:5099'

    $p = [System.Diagnostics.Process]::Start($psi)
    Start-Sleep -Seconds 8
    $p.Kill()

    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()

    Write-Host '=== STDOUT ==='
    Write-Host $stdout
    Write-Host '=== STDERR ==='
    Write-Host $stderr
}

Remove-PSSession $s
