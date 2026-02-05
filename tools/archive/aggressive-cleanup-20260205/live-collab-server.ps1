<#
.SYNOPSIS
    Real-time collaboration WebSocket server

.DESCRIPTION
    Broadcasts agent actions in real-time to connected dashboards:
    - File edits
    - Worktree allocations
    - Tool usage
    - Errors and warnings

    Architecture:
    - WebSocket server on localhost:9998
    - JSON message protocol
    - Browser dashboard connects for visualization

.PARAMETER Port
    Port to listen on (default: 9998)

.PARAMETER Debug
    Show debug output

.EXAMPLE
    .\live-collab-server.ps1

.EXAMPLE
    .\live-collab-server.ps1 -Port 9999 -Debug
#>

param(
    [Parameter(Mandatory=$false)]
    [int]$Port = 9998,

    [Parameter(Mandatory=$false)]
    [switch]$Debug
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Real-Time Collaboration Server" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if port is in use
$portInUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "Error: Port $Port is already in use" -ForegroundColor Red
    Write-Host "Kill the process or use a different port with -Port parameter" -ForegroundColor Yellow
    exit 1
}

# Create HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")

try {
    $listener.Start()
    Write-Host "✅ Server started on http://localhost:$Port" -ForegroundColor Green
    Write-Host "✅ WebSocket endpoint: ws://localhost:$Port/ws" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Dashboard: http://localhost:$Port/dashboard" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press CTRL+C to stop server..." -ForegroundColor Gray
    Write-Host ""

    # Connected WebSocket clients
    $clients = [System.Collections.ArrayList]::new()

    # Message broadcast function
    function Broadcast-Message {
        param([string]$Message)

        if ($Debug) {
            Write-Host "📤 Broadcasting: $Message" -ForegroundColor DarkGray
        }

        $toRemove = @()
        foreach ($client in $clients) {
            try {
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($Message)
                $client.SendAsync(
                    [ArraySegment[byte]]::new($bytes),
                    [System.Net.WebSockets.WebSocketMessageType]::Text,
                    $true,
                    [System.Threading.CancellationToken]::None
                ).Wait()
            } catch {
                if ($Debug) {
                    Write-Host "❌ Client disconnected" -ForegroundColor DarkGray
                }
                $toRemove += $client
            }
        }

        # Remove disconnected clients
        foreach ($client in $toRemove) {
            $clients.Remove($client) | Out-Null
        }
    }

    # Main server loop
    while ($listener.IsListening) {
        try {
            $contextTask = $listener.GetContextAsync()

            # Poll for new messages from database
            $DbPath = "C:\scripts\_machine\agent-activity.db"
            $SqlitePath = "C:\scripts\_machine\sqlite3.exe"

            $lastCheckFile = "C:\scripts\_machine\.live-collab-lastcheck"
            if (Test-Path $lastCheckFile) {
                $lastCheck = Get-Content $lastCheckFile -Raw
            } else {
                $lastCheck = (Get-Date).AddMinutes(-1).ToString("yyyy-MM-ddTHH:mm:ss")
            }

            # Query recent activity
            $sql = "SELECT timestamp, agent_id, action_type, details FROM live_activity WHERE timestamp > '$lastCheck' ORDER BY timestamp ASC;"
            $activities = $sql | & $SqlitePath $DbPath

            if ($activities) {
                $activities -split "`n" | ForEach-Object {
                    if ($_ -match '\|') {
                        $parts = $_ -split '\|'
                        $message = @{
                            timestamp = $parts[0]
                            agent_id = $parts[1]
                            action_type = $parts[2]
                            details = $parts[3]
                        } | ConvertTo-Json -Compress

                        Broadcast-Message -Message $message
                    }
                }

                # Update last check timestamp
                $lastCheck = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
                $lastCheck | Set-Content $lastCheckFile
            }

            # Handle incoming HTTP/WebSocket connections (non-blocking check)
            if ($contextTask.Wait(100)) {
                $context = $contextTask.Result

                if ($context.Request.IsWebSocketRequest) {
                    # WebSocket connection
                    $wsContext = $context.AcceptWebSocketAsync($null).Result
                    $webSocket = $wsContext.WebSocket

                    $clients.Add($webSocket) | Out-Null
                    Write-Host "📱 New client connected (Total: $($clients.Count))" -ForegroundColor Green

                    # Send welcome message
                    $welcome = @{
                        type = "welcome"
                        message = "Connected to Real-Time Collaboration Server"
                        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
                    } | ConvertTo-Json -Compress

                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($welcome)
                    $webSocket.SendAsync(
                        [ArraySegment[byte]]::new($bytes),
                        [System.Net.WebSockets.WebSocketMessageType]::Text,
                        $true,
                        [System.Threading.CancellationToken]::None
                    ).Wait()
                }
                elseif ($context.Request.RawUrl -eq "/dashboard") {
                    # Serve HTML dashboard
                    $dashboardPath = "C:\scripts\tools\live-collab-dashboard.html"
                    if (Test-Path $dashboardPath) {
                        $html = Get-Content $dashboardPath -Raw
                        $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
                        $context.Response.ContentType = "text/html"
                        $context.Response.ContentLength64 = $buffer.Length
                        $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                    } else {
                        $error = "<h1>Dashboard not found</h1><p>Create live-collab-dashboard.html</p>"
                        $buffer = [System.Text.Encoding]::UTF8.GetBytes($error)
                        $context.Response.StatusCode = 404
                        $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                    }
                    $context.Response.Close()
                }
                else {
                    # Serve basic status page
                    $status = @{
                        status = "running"
                        port = $Port
                        clients = $clients.Count
                        uptime_seconds = ((Get-Date) - $script:startTime).TotalSeconds
                    } | ConvertTo-Json

                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($status)
                    $context.Response.ContentType = "application/json"
                    $context.Response.ContentLength64 = $buffer.Length
                    $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                    $context.Response.Close()
                }
            }

        } catch {
            if ($Debug) {
                Write-Host "⚠️ Error: $_" -ForegroundColor Yellow
            }
        }

        Start-Sleep -Milliseconds 100
    }

} catch {
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
} finally {
    if ($listener.IsListening) {
        $listener.Stop()
        Write-Host ""
        Write-Host "Server stopped." -ForegroundColor Yellow
    }
}
