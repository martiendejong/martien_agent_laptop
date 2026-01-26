@echo off
REM Start Brave with Chrome DevTools Protocol enabled
REM This allows programmatic control via CDP on port 9222

echo Starting Brave with DevTools Protocol...

REM Find Brave installation
set BRAVE_PATH=""

if exist "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" (
    set BRAVE_PATH="C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
) else if exist "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe" (
    set BRAVE_PATH="C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe"
) else if exist "%LocalAppData%\BraveSoftware\Brave-Browser\Application\brave.exe" (
    set BRAVE_PATH="%LocalAppData%\BraveSoftware\Brave-Browser\Application\brave.exe"
)

if %BRAVE_PATH%=="" (
    echo ERROR: Brave browser not found!
    echo Please install Brave or update the path in this script.
    pause
    exit /b 1
)

echo Found Brave at: %BRAVE_PATH%
echo.
echo DevTools Protocol will be available at: http://localhost:9222
echo.

REM Start Brave with remote debugging
start "" %BRAVE_PATH% ^
    --remote-debugging-port=9222 ^
    --user-data-dir="%TEMP%\brave-devtools-profile" ^
    --disable-blink-features=AutomationControlled

echo.
echo Brave started with DevTools Protocol enabled!
echo.
echo You can now:
echo - Connect via CDP at ws://localhost:9222
echo - Use Puppeteer/Playwright to control the browser
echo - Access DevTools at http://localhost:9222
echo.
pause
