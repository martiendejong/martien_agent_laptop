@echo off
REM Work Tracking Dashboard - HTTP Server
echo Starting Work Tracking Dashboard on http://localhost:4242
echo.
cd /d C:\scripts\_machine
start http://localhost:4242/work-dashboard.html
python -m http.server 4242
