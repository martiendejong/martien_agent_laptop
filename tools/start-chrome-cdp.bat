@echo off
REM Start Chrome with CDP

echo Stopping all Chrome processes...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 5 /nobreak >nul

echo Starting Chrome with CDP on port 9222...
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="C:\Temp\chrome-cdp-profile"

echo Waiting 10 seconds...
timeout /t 10 /nobreak >nul

echo Testing connection...
curl -s http://localhost:9222/json/version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: CDP is active!
    curl http://localhost:9222/json/version
) else (
    echo FAILED: CDP not responding
)
