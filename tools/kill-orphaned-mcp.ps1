# Kill only orphaned MCP/Playwright processes (keep dev servers)
Write-Host ""
Write-Host "=== KILLING ORPHANED MCP PROCESSES ===" -ForegroundColor Yellow
Write-Host ""

$killed = 0
$freed = 0

# Find Playwright and old Claude MCP processes
$nodes = Get-Process node -ErrorAction SilentlyContinue

foreach ($node in $nodes) {
    try {
        $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($node.Id)" -ErrorAction SilentlyContinue).CommandLine
        $age = ((Get-Date) - $node.StartTime).TotalMinutes
        $ram = $node.WorkingSet64 / 1MB

        # Kill if:
        # 1. Playwright process
        # 2. Old Claude MCP (> 60 minutes old)
        # 3. npm processes that aren't dev servers
        $shouldKill = $false
        $reason = ""

        if ($cmdLine -match "playwright") {
            $shouldKill = $true
            $reason = "Playwright MCP (orphaned)"
        }
        elseif ($cmdLine -match "claude.*mcp" -and $age -gt 60) {
            $shouldKill = $true
            $reason = "Old Claude MCP (> 60 min)"
        }
        elseif ($cmdLine -match "\\npm\\node_modules\\npm\\bin\\npm-cli" -and $age -gt 60) {
            $shouldKill = $true
            $reason = "Orphaned npm process"
        }

        # DON'T kill dev servers (vite, webpack, next, etc.)
        if ($cmdLine -match "vite|next|webpack|react-scripts|localhost:") {
            $shouldKill = $false
        }

        if ($shouldKill) {
            Write-Host "  Killing PID $($node.Id) | $([math]::Round($ram,0)) MB | $reason" -ForegroundColor Gray
            Stop-Process -Id $node.Id -Force -ErrorAction SilentlyContinue
            $killed++
            $freed += $ram
        }
    }
    catch {
        # Process might have exited
    }
}

Write-Host ""
Write-Host "KILLED: $killed processes" -ForegroundColor Green
Write-Host "FREED: $([math]::Round($freed/1024, 2)) GB RAM" -ForegroundColor Green
Write-Host ""
