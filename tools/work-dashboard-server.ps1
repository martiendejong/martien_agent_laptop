# work-dashboard-server.ps1
# Simple HTTP server for Work Tracking Dashboard
# Serves files from C:\scripts\_machine on http://localhost:8080

param(
    [int]$Port = 4242
)

$ErrorActionPreference = "Stop"

$basePath = "C:\scripts\_machine"
$url = "http://localhost:$Port/"

Write-Host "Starting Work Dashboard Server..." -ForegroundColor Cyan
Write-Host "URL: $url" -ForegroundColor Green
Write-Host "Base Path: $basePath" -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Create HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "âœ… Server running at $url" -ForegroundColor Green
Write-Host "ðŸ“Š Dashboard: ${url}work-dashboard.html" -ForegroundColor Cyan
Write-Host ""

# Auto-open browser
Start-Process "${url}work-dashboard.html"

try {
    while ($listener.IsListening) {
        # Wait for request
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # Parse request path
        $requestPath = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrEmpty($requestPath)) {
            $requestPath = "work-dashboard.html"
        }

        $filePath = Join-Path $basePath $requestPath

        Write-Host "$(Get-Date -Format 'HH:mm:ss') - $($request.HttpMethod) $requestPath" -ForegroundColor Gray

        # Check if file exists
        if (Test-Path $filePath -PathType Leaf) {
            try {
                # Read file
                $content = [System.IO.File]::ReadAllBytes($filePath)

                # Set content type based on extension
                $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
                $contentType = switch ($extension) {
                    ".html" { "text/html; charset=utf-8" }
                    ".css"  { "text/css; charset=utf-8" }
                    ".js"   { "application/javascript; charset=utf-8" }
                    ".json" { "application/json; charset=utf-8" }
                    ".png"  { "image/png" }
                    ".jpg"  { "image/jpeg" }
                    ".ico"  { "image/x-icon" }
                    default { "application/octet-stream" }
                }

                # Set response headers
                $response.ContentType = $contentType
                $response.ContentLength64 = $content.Length
                $response.StatusCode = 200

                # Disable caching for JSON files (always fresh data)
                if ($extension -eq ".json") {
                    $response.Headers.Add("Cache-Control", "no-cache")
                    $response.Headers.Add("Pragma", "no-cache")
                    $response.Headers.Add("Expires", "0")
                }

                # Write response
                $response.OutputStream.Write($content, 0, $content.Length)
            }
            catch {
                Write-Host "  âŒ Error reading file: $_" -ForegroundColor Red
                $response.StatusCode = 500
            }
        }
        else {
            Write-Host "  File not found: $filePath" -ForegroundColor Yellow
            $response.StatusCode = 404
            $errorHtml = '<html><body><h1>404 Not Found</h1><p>File: ' + $requestPath + '</p></body></html>'
            $errorBytes = [System.Text.Encoding]::UTF8.GetBytes($errorHtml)
            $response.ContentType = "text/html"
            $response.OutputStream.Write($errorBytes, 0, $errorBytes.Length)
        }

        # Close response
        $response.OutputStream.Close()
    }
}
catch {
    Write-Host "âŒ Server error: $_" -ForegroundColor Red
}
finally {
    if ($listener.IsListening) {
        $listener.Stop()
        $listener.Close()
        Write-Host "`nâœ… Server stopped" -ForegroundColor Green
    }
}
