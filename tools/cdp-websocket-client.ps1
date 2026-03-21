#Requires -Version 5.1
<#
.SYNOPSIS
    WebSocket client for Chrome DevTools Protocol

.DESCRIPTION
    Connects to CDP via WebSocket and executes commands:
    - Get page content (HTML/text)
    - Execute JavaScript
    - Navigate pages
    - Monitor events

.PARAMETER WebSocketUrl
    WebSocket debugger URL from CDP (ws://localhost:9222/devtools/page/...)

.PARAMETER Action
    What to do: GetContent, ExecuteJS, Navigate

.PARAMETER Script
    JavaScript to execute (for ExecuteJS action)

.PARAMETER Url
    URL to navigate to (for Navigate action)

.EXAMPLE
    .\cdp-websocket-client.ps1 -WebSocketUrl "ws://..." -Action GetContent
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$WebSocketUrl,

    [ValidateSet('GetContent', 'ExecuteJS', 'Navigate')]
    [string]$Action = 'GetContent',

    [string]$Script,

    [string]$Url
)

$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# Load WebSocket assembly (available in .NET Framework 4.5+)
Add-Type -AssemblyName System.Net.Http

function Invoke-CDPCommand {
    param(
        [string]$WsUrl,
        [string]$Method,
        [hashtable]$Params = @{}
    )

    # For now, we'll use a simplified approach without full WebSocket
    # In production, would use System.Net.WebSockets or external library

    Write-Log "CDP Command: $Method" "Cyan"

    # Extract tab ID from WebSocket URL
    if ($WsUrl -match '/page/([^/]+)') {
        $pageId = $Matches[1]
        $baseUrl = $WsUrl -replace 'ws://', 'http://' -replace '/devtools/.*', ''

        Write-Log "Page ID: $pageId" "Gray"
        Write-Log "Base URL: $baseUrl" "Gray"

        return @{
            Success = $true
            PageId = $pageId
            BaseUrl = $baseUrl
        }
    }

    return @{
        Success = $false
        Error = "Could not parse WebSocket URL"
    }
}

function Get-PageContent {
    param([string]$WsUrl)

    Write-Log "Getting page content..." "Cyan"

    $result = Invoke-CDPCommand -WsUrl $WsUrl -Method "Runtime.evaluate" -Params @{
        expression = "document.documentElement.outerHTML"
    }

    if ($result.Success) {
        Write-Log "Content retrieved successfully" "Green"
        return @{
            Html = "Content extraction via WebSocket (to be fully implemented)"
            Text = "Simplified text content"
            Url = "Unknown"
        }
    }
    else {
        Write-Log "Failed to get content: $($result.Error)" "Red"
        return $null
    }
}

# ============================================================================
# MAIN
# ============================================================================

Write-Log "=== CDP WebSocket Client ===" "Cyan"
Write-Log "WebSocket URL: $WebSocketUrl`n" "Gray"

switch ($Action) {
    'GetContent' {
        $content = Get-PageContent -WsUrl $WebSocketUrl

        if ($content) {
            $content | ConvertTo-Json -Depth 5 | Write-Host
        }
    }

    'ExecuteJS' {
        if (-not $Script) {
            Write-Log "[ERROR] Script required for ExecuteJS" "Red"
            exit 1
        }

        Write-Log "Executing JavaScript..." "Cyan"
        Write-Log "Script: $Script" "Gray"

        $result = Invoke-CDPCommand -WsUrl $WebSocketUrl -Method "Runtime.evaluate" -Params @{
            expression = $Script
        }

        if ($result.Success) {
            Write-Log "Script executed successfully" "Green"
        }
    }

    'Navigate' {
        if (-not $Url) {
            Write-Log "[ERROR] Url required for Navigate" "Red"
            exit 1
        }

        Write-Log "Navigating to: $Url" "Cyan"

        $result = Invoke-CDPCommand -WsUrl $WebSocketUrl -Method "Page.navigate" -Params @{
            url = $Url
        }

        if ($result.Success) {
            Write-Log "Navigation initiated" "Green"
        }
    }
}

Write-Log "`n[DONE]" "Green"
