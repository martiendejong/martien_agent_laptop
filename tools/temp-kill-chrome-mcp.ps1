$ErrorActionPreference = 'SilentlyContinue'
$chromes = Get-Process chrome -ErrorAction SilentlyContinue
foreach ($c in $chromes) {
    $cmdline = (Get-CimInstance Win32_Process -Filter "ProcessId = $($c.Id)").CommandLine
    if ($cmdline -match 'mcp-chrome') {
        Write-Output "Killing Chrome MCP PID $($c.Id)"
        Stop-Process -Id $c.Id -Force
    }
}
# Also remove the entire user data dir to start fresh
if (Test-Path 'C:\Users\HP\AppData\Local\ms-playwright\mcp-chrome-0938cce') {
    Remove-Item 'C:\Users\HP\AppData\Local\ms-playwright\mcp-chrome-0938cce' -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output "Removed stale MCP Chrome profile"
}
Write-Output "Done"
