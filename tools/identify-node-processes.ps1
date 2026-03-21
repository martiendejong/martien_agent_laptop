# Identify what all these node processes are doing
Write-Host ""
Write-Host "=== NODE PROCESS BREAKDOWN ===" -ForegroundColor Cyan
Write-Host ""

$nodes = Get-Process node -ErrorAction SilentlyContinue
$groups = @{
    "Claude MCP" = @()
    "Development Servers" = @()
    "Build Tools" = @()
    "Unknown/Orphaned" = @()
}

foreach ($node in $nodes) {
    try {
        $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($node.Id)" -ErrorAction SilentlyContinue).CommandLine
        $ram = [math]::Round($node.WorkingSet64/1MB, 0)
        $age = ((Get-Date) - $node.StartTime).TotalMinutes

        $info = @{
            PID = $node.Id
            RAM = $ram
            Age = [math]::Round($age, 1)
            CmdLine = $cmdLine
        }

        # Categorize
        if ($cmdLine -match "claude|mcp-server|@modelcontextprotocol") {
            $groups["Claude MCP"] += $info
        }
        elseif ($cmdLine -match "next|vite|webpack|react-scripts|vue-cli|angular|localhost|serve|http-server") {
            $groups["Development Servers"] += $info
        }
        elseif ($cmdLine -match "webpack|esbuild|rollup|parcel|gulp|grunt") {
            $groups["Build Tools"] += $info
        }
        else {
            $groups["Unknown/Orphaned"] += $info
        }
    }
    catch {
        # Process might have exited
    }
}

# Display results
foreach ($category in $groups.Keys | Sort-Object) {
    $items = $groups[$category]
    if ($items.Count -gt 0) {
        Write-Host "[$category]: $($items.Count) processes" -ForegroundColor Yellow

        foreach ($item in $items | Sort-Object RAM -Descending | Select-Object -First 10) {
            Write-Host "  PID $($item.PID) | $($item.RAM) MB | Age: $($item.Age) min" -ForegroundColor Gray

            # Show abbreviated command line
            $shortCmd = if ($item.CmdLine.Length -gt 80) {
                $item.CmdLine.Substring(0, 77) + "..."
            } else {
                $item.CmdLine
            }
            Write-Host "    $shortCmd" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

# Summary
$total = $nodes.Count
$totalRAM = [math]::Round(($nodes | Measure-Object -Property WorkingSet64 -Sum).Sum / 1GB, 2)
Write-Host "TOTAL: $total processes using $totalRAM GB RAM" -ForegroundColor Cyan
Write-Host ""
