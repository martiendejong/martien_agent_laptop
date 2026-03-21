@echo off
REM Start Chrome with CDP - Modern Chrome version

echo Stopping all Chrome processes...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 5 /nobreak >nul

echo Creating temp profile directory...
if not exist "C:\Temp\chrome-cdp" mkdir "C:\Temp\chrome-cdp"

echo Starting Chrome with CDP (modern flags)...
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --remote-allow-origins=* --user-data-dir="C:\Temp\chrome-cdp"

echo Waiting 12 seconds for initialization...
timeout /t 12 /nobreak >nul

echo.
echo Testing CDP connection...
curl -s http://localhost:9222/json/version
if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS: CDP is active!
) else (
    echo.
    echo FAILED: CDP not responding
    echo Checking if Chrome is running...
    tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I /N "chrome.exe">nul
    if "%ERRORLEVEL%"=="0" (
        echo Chrome IS running but CDP not responding
    ) else (
        echo Chrome NOT running
    )
)
