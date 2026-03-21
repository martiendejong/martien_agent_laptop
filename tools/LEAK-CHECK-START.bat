@echo off
cd /d C:\scripts\tools
powershell.exe -NoExit -ExecutionPolicy Bypass -Command ^
"Write-Host 'Bitwarden Security Check' -ForegroundColor Cyan; ^
Write-Host ''; ^
Write-Host 'Stap 1: Login...' -ForegroundColor Yellow; ^
& '.\bw.exe' login martiendejong2008@gmail.com; ^
if ($LASTEXITCODE -eq 0) { ^
    Write-Host ''; ^
    Write-Host 'Stap 2: Unlock...' -ForegroundColor Yellow; ^
    $session = & '.\bw.exe' unlock --raw; ^
    $env:BW_SESSION = $session; ^
    Write-Host ''; ^
    Write-Host 'Stap 3: Scanning...' -ForegroundColor Yellow; ^
    & '.\scan-only.ps1'; ^
} else { ^
    Write-Host 'Login failed' -ForegroundColor Red ^
}"
