@echo off
start "" "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" --remote-debugging-port=9222 --user-data-dir="%TEMP%\brave-devtools-profile" --disable-blink-features=AutomationControlled
