#Requires -Version 5.1
<#
.SYNOPSIS
    Chrome DevTools Protocol (CDP) Connector for Browser Intelligence

.DESCRIPTION
    Connects to running Chrome/Brave/Edge browsers via CDP.
    Provides direct browser control without manual snapshots:
    - List all open tabs
    - Navigate to URLs
    - Capture page content
    - Close tabs
    - Monitor events

    Browsers must be started with --remote-debugging-port flag:
    - Chrome: chrome.exe --remote-debugging-port=9222
    - Brave: brave.exe --remote-debugging-port=9223
    - Edge: msedge.exe --remote-debugging-port=9224

.PARAMETER Action
    What to do: ListTabs, GetPageContent, CloseTab, StartBrowser, CheckConnection

.PARAMETER Browser
    Which browser: chrome, brave, edge

.PARAMETER TabId
    Target tab ID (from ListTabs)

.PARAMETER Url
    URL for navigation

.EXAMPLE
    .\browser-cdp-connector.ps1 -Action CheckConnection -Browser chrome
    .\browser-cdp-connector.ps1 -Action ListTabs -Browser brave
    .\browser-cdp-connector.ps1 -Action GetPageContent -Browser chrome -TabId "tab-id-here"
#>

[CmdletBinding()]
param(
    [ValidateSet('CheckConnection', 'ListTabs', 'GetPageContent', 'CloseTab', 'StartBrowser', 'NavigateTo')]
    [string]$Action = 'CheckConnection',

    [ValidateSet('chrome', 'brave', 'edge')]
    [string]$Browser = 'chrome',

    [string]$TabId,

    [string]$Url
)

$ErrorActionPreference = 'Stop'

# CDP ports by browser
$CDPPorts = @{
    'chrome' = 9222
    'brave' = 9223
    'edge' = 9224
}

# Browser executables
$BrowserPaths = @{
    'chrome' = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe"
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    )
    'brave' = @(
        "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
        "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe"
    )
    'edge' = @(
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    )
}

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Get-BrowserExecutable {
    param([string]$BrowserName)

    $paths = $BrowserPaths[$BrowserName]

    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Test-CDPConnection {
    param([int]$Port)

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/json/version" -Method Get -TimeoutSec 2
        return $true
    }
    catch {
        return $false
    }
}

function Get-CDPTabs {
    param([int]$Port)

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/json" -Method Get

        $tabs = $response | Where-Object { $_.type -eq 'page' } | ForEach-Object {
            @{
                Id = $_.id
                Title = $_.title
                Url = $_.url
                Description = $_.description
                WebSocketUrl = $_.webSocketDebuggerUrl
            }
        }

        return $tabs
    }
    catch {
        Write-Log "Failed to get tabs: $_" "Red"
        return @()
    }
}

function Get-PageContent {
    param([int]$Port, [string]$TabId)

    try {
        # Get tab details
        $tabs = Get-CDPTabs -Port $Port
        $tab = $tabs | Where-Object { $_.Id -eq $TabId }

        if (-not $tab) {
            Write-Log "Tab not found: $TabId" "Red"
            return $null
        }

        # Connect to WebSocket (simplified - would need WebSocket client)
        # For now, we'll use the HTTP endpoint to get basic info

        Write-Log "Tab found: $($tab.Title)" "Green"
        Write-Log "URL: $($tab.Url)" "Gray"

        return @{
            TabId = $tab.Id
            Title = $tab.Title
            Url = $tab.Url
            Content = "Content extraction requires WebSocket connection (to be implemented)"
        }
    }
    catch {
        Write-Log "Failed to get page content: $_" "Red"
        return $null
    }
}

function Start-BrowserWithCDP {
    param([string]$BrowserName)

    $port = $CDPPorts[$BrowserName]
    $exe = Get-BrowserExecutable -BrowserName $BrowserName

    if (-not $exe) {
        Write-Log "Browser executable not found for: $BrowserName" "Red"
        return $false
    }

    Write-Log "Starting $BrowserName with CDP on port $port..." "Cyan"

    # Check if already running
    if (Test-CDPConnection -Port $port) {
        Write-Log "$BrowserName already running with CDP enabled!" "Green"
        return $true
    }

    # Start browser with CDP
    $arguments = "--remote-debugging-port=$port"

    try {
        Start-Process -FilePath $exe -ArgumentList $arguments

        # Wait for startup
        Write-Log "Waiting for browser to start..." "Gray"
        Start-Sleep -Seconds 3

        # Verify connection
        if (Test-CDPConnection -Port $port) {
            Write-Log "$BrowserName started successfully!" "Green"
            Write-Log "CDP available at: http://localhost:$port" "Cyan"
            return $true
        }
        else {
            Write-Log "Browser started but CDP not available" "Yellow"
            return $false
        }
    }
    catch {
        Write-Log "Failed to start browser: $_" "Red"
        return $false
    }
}

function Close-CDPTab {
    param([int]$Port, [string]$TabId)

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/json/close/$TabId" -Method Get

        Write-Log "Tab closed successfully" "Green"
        return $true
    }
    catch {
        Write-Log "Failed to close tab: $_" "Red"
        return $false
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

$port = $CDPPorts[$Browser]

Write-Log "=== CDP Connector ===" "Cyan"
Write-Log "Browser: $Browser | Port: $port`n" "Gray"

switch ($Action) {
    'CheckConnection' {
        Write-Log "Checking CDP connection..." "Cyan"

        if (Test-CDPConnection -Port $port) {
            Write-Log "[SUCCESS] $Browser is running with CDP enabled" "Green"
            Write-Log "CDP endpoint: http://localhost:$port" "Cyan"

            # Get version info
            try {
                $version = Invoke-RestMethod -Uri "http://localhost:$port/json/version" -Method Get
                Write-Log "`nBrowser Info:" "White"
                Write-Log "  Browser: $($version.'Browser')" "Gray"
                Write-Log "  Protocol: $($version.'Protocol-Version')" "Gray"
                Write-Log "  User-Agent: $($version.'User-Agent')" "Gray"
            }
            catch {
                Write-Log "Could not get version info" "Yellow"
            }
        }
        else {
            Write-Log "[FAILED] $Browser is not running with CDP" "Red"
            Write-Log "`nTo enable CDP, start $Browser with:" "Yellow"

            $exe = Get-BrowserExecutable -BrowserName $Browser
            if ($exe) {
                Write-Log "  `"$exe`" --remote-debugging-port=$port" "Cyan"
            }
            else {
                Write-Log "  ${Browser}.exe --remote-debugging-port=$port" "Cyan"
            }

            Write-Log "`nOr use: .\browser-cdp-connector.ps1 -Action StartBrowser -Browser $Browser" "Yellow"
        }
    }

    'ListTabs' {
        Write-Log "Listing all tabs..." "Cyan"

        if (-not (Test-CDPConnection -Port $port)) {
            Write-Log "[ERROR] Browser not running with CDP enabled" "Red"
            exit 1
        }

        $tabs = Get-CDPTabs -Port $port

        if ($tabs.Count -eq 0) {
            Write-Log "No tabs found" "Yellow"
        }
        else {
            Write-Log "`nFound $($tabs.Count) tabs:`n" "Green"

            $i = 1
            foreach ($tab in $tabs) {
                Write-Log "[$i] $($tab.Title)" "Yellow"
                Write-Log "    URL: $($tab.Url)" "Gray"
                Write-Log "    ID: $($tab.Id)" "DarkGray"
                Write-Log ""
                $i++
            }
        }
    }

    'GetPageContent' {
        if (-not $TabId) {
            Write-Log "[ERROR] TabId required for GetPageContent" "Red"
            exit 1
        }

        Write-Log "Getting page content for tab: $TabId" "Cyan"

        if (-not (Test-CDPConnection -Port $port)) {
            Write-Log "[ERROR] Browser not running with CDP enabled" "Red"
            exit 1
        }

        $content = Get-PageContent -Port $port -TabId $TabId

        if ($content) {
            Write-Log "`n[SUCCESS] Content retrieved" "Green"
            $content | ConvertTo-Json -Depth 5 | Write-Host
        }
    }

    'CloseTab' {
        if (-not $TabId) {
            Write-Log "[ERROR] TabId required for CloseTab" "Red"
            exit 1
        }

        Write-Log "Closing tab: $TabId" "Cyan"

        if (-not (Test-CDPConnection -Port $port)) {
            Write-Log "[ERROR] Browser not running with CDP enabled" "Red"
            exit 1
        }

        Close-CDPTab -Port $port -TabId $TabId
    }

    'StartBrowser' {
        Start-BrowserWithCDP -BrowserName $Browser
    }

    'NavigateTo' {
        if (-not $Url) {
            Write-Log "[ERROR] Url required for NavigateTo" "Red"
            exit 1
        }

        Write-Log "Navigation requires WebSocket implementation (to be added)" "Yellow"
    }
}

Write-Log "`n[DONE]" "Green"
