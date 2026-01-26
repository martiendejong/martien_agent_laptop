<#
.SYNOPSIS
    UI Automation Bridge Client - Control Windows UI programmatically

.DESCRIPTION
    PowerShell client for the UI Automation Bridge server.
    Enables Claude Code to interact with any Windows desktop application.

.PARAMETER Action
    The action to perform: health, windows, click, type, set-value, invoke, expand, select, inspect, screenshot, tree

.PARAMETER WindowId
    The window ID (from windows action)

.PARAMETER WindowName
    Search for window by name

.PARAMETER ElementName
    Element name to interact with

.PARAMETER AutomationId
    Element automation ID

.PARAMETER ClassName
    Element class name

.PARAMETER Text
    Text to type

.PARAMETER Value
    Value to set

.PARAMETER X
    X coordinate for inspect

.PARAMETER Y
    Y coordinate for inspect

.PARAMETER Expand
    Expand (true) or collapse (false)

.PARAMETER Port
    Bridge server port (default: 27184)

.PARAMETER Json
    Output raw JSON

.EXAMPLE
    .\ui-automation-bridge-client.ps1 -Action health

.EXAMPLE
    .\ui-automation-bridge-client.ps1 -Action windows

.EXAMPLE
    .\ui-automation-bridge-client.ps1 -Action click -WindowId "12345" -ElementName "OK"

.EXAMPLE
    .\ui-automation-bridge-client.ps1 -Action type -WindowId "12345" -Text "Hello World"

.EXAMPLE
    .\ui-automation-bridge-client.ps1 -Action screenshot -WindowId "12345"

.EXAMPLE
    .\ui-automation-bridge-client.ps1 -Action inspect -X 100 -Y 200
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("health", "windows", "click", "type", "set-value", "invoke", "expand", "select", "inspect", "screenshot", "tree")]
    [string]$Action,

    [string]$WindowId,
    [string]$WindowName,
    [string]$ElementName,
    [string]$AutomationId,
    [string]$ClassName,
    [string]$Text,
    [string]$Value,
    [int]$X,
    [int]$Y,
    [bool]$Expand = $true,
    [int]$Port = 27184,
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:$Port"

function Invoke-BridgeRequest {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )

    try {
        $uri = "$baseUrl$Endpoint"
        $params = @{
            Uri = $uri
            Method = $Method
            ContentType = "application/json"
        }

        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10 -Compress)
        }

        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            Write-Host "[ERROR] $errorBody" -ForegroundColor Red
        }
        else {
            Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Is the UI Automation Bridge server running?" -ForegroundColor Yellow
            Write-Host "Start it with: ui-automation-bridge-server.ps1" -ForegroundColor Yellow
        }
        exit 1
    }
}

function Get-WindowByName {
    param([string]$Name)

    $windows = Invoke-BridgeRequest -Method "GET" -Endpoint "/windows"
    return $windows.windows | Where-Object { $_.name -like "*$Name*" } | Select-Object -First 1
}

# Execute action
switch ($Action) {
    "health" {
        $result = Invoke-BridgeRequest -Method "GET" -Endpoint "/health"
        if ($Json) {
            $result | ConvertTo-Json
        }
        else {
            Write-Host "✓ UI Automation Bridge is healthy" -ForegroundColor Green
            Write-Host "Version: $($result.version)" -ForegroundColor Cyan
        }
    }

    "windows" {
        $result = Invoke-BridgeRequest -Method "GET" -Endpoint "/windows"
        if ($Json) {
            $result | ConvertTo-Json -Depth 10
        }
        else {
            Write-Host "Windows:" -ForegroundColor Cyan
            $result.windows | ForEach-Object {
                Write-Host "  [$($_.id)] $($_.name)" -ForegroundColor White
                Write-Host "    Class: $($_.className)" -ForegroundColor Gray
                Write-Host "    Visible: $($_.isVisible)" -ForegroundColor Gray
            }
        }
    }

    "click" {
        if ($WindowName) {
            $window = Get-WindowByName -Name $WindowName
            $WindowId = $window.id
        }

        if (-not $WindowId) {
            Write-Host "[ERROR] WindowId or WindowName required" -ForegroundColor Red
            exit 1
        }

        $body = @{ windowId = $WindowId }
        if ($ElementName) { $body.name = $ElementName }
        if ($AutomationId) { $body.automationId = $AutomationId }
        if ($ClassName) { $body.className = $ClassName }

        $result = Invoke-BridgeRequest -Method "POST" -Endpoint "/click" -Body $body
        if ($Json) {
            $result | ConvertTo-Json
        }
        else {
            Write-Host "✓ $($result.message)" -ForegroundColor Green
        }
    }

    "type" {
        if ($WindowName) {
            $window = Get-WindowByName -Name $WindowName
            $WindowId = $window.id
        }

        if (-not $WindowId) {
            Write-Host "[ERROR] WindowId or WindowName required" -ForegroundColor Red
            exit 1
        }

        if (-not $Text) {
            Write-Host "[ERROR] Text required" -ForegroundColor Red
            exit 1
        }

        $body = @{
            windowId = $WindowId
            text = $Text
        }
        if ($ElementName) { $body.name = $ElementName }
        if ($AutomationId) { $body.automationId = $AutomationId }

        $result = Invoke-BridgeRequest -Method "POST" -Endpoint "/type" -Body $body
        if ($Json) {
            $result | ConvertTo-Json
        }
        else {
            Write-Host "✓ $($result.message)" -ForegroundColor Green
        }
    }

    "set-value" {
        if ($WindowName) {
            $window = Get-WindowByName -Name $WindowName
            $WindowId = $window.id
        }

        if (-not $WindowId) {
            Write-Host "[ERROR] WindowId or WindowName required" -ForegroundColor Red
            exit 1
        }

        if (-not $Value) {
            Write-Host "[ERROR] Value required" -ForegroundColor Red
            exit 1
        }

        $body = @{
            windowId = $WindowId
            value = $Value
        }
        if ($ElementName) { $body.name = $ElementName }
        if ($AutomationId) { $body.automationId = $AutomationId }

        $result = Invoke-BridgeRequest -Method "POST" -Endpoint "/set-value" -Body $body
        if ($Json) {
            $result | ConvertTo-Json
        }
        else {
            Write-Host "✓ $($result.message)" -ForegroundColor Green
        }
    }

    "invoke" {
        if ($WindowName) {
            $window = Get-WindowByName -Name $WindowName
            $WindowId = $window.id
        }

        if (-not $WindowId) {
            Write-Host "[ERROR] WindowId or WindowName required" -ForegroundColor Red
            exit 1
        }

        $body = @{ windowId = $WindowId }
        if ($ElementName) { $body.name = $ElementName }
        if ($AutomationId) { $body.automationId = $AutomationId }

        $result = Invoke-BridgeRequest -Method "POST" -Endpoint "/invoke" -Body $body
        if ($Json) {
            $result | ConvertTo-Json
        }
        else {
            Write-Host "✓ $($result.message)" -ForegroundColor Green
        }
    }

    "expand" {
        if ($WindowName) {
            $window = Get-WindowByName -Name $WindowName
            $WindowId = $window.id
        }

        if (-not $WindowId) {
            Write-Host "[ERROR] WindowId or WindowName required" -ForegroundColor Red
            exit 1
        }

        $body = @{
            windowId = $WindowId
            expand = $Expand
        }
        if ($ElementName) { $body.name = $ElementName }
        if ($AutomationId) { $body.automationId = $AutomationId }

        $result = Invoke-BridgeRequest -Method "POST" -Endpoint "/expand" -Body $body
        if ($Json) {
            $result | ConvertTo-Json
        }
        else {
            Write-Host "✓ $($result.message)" -ForegroundColor Green
        }
    }

    "select" {
        if ($WindowName) {
            $window = Get-WindowByName -Name $WindowName
            $WindowId = $window.id
        }

        if (-not $WindowId) {
            Write-Host "[ERROR] WindowId or WindowName required" -ForegroundColor Red
            exit 1
        }

        $body = @{ windowId = $WindowId }
        if ($ElementName) { $body.name = $ElementName }
        if ($AutomationId) { $body.automationId = $AutomationId }

        $result = Invoke-BridgeRequest -Method "POST" -Endpoint "/select" -Body $body
        if ($Json) {
            $result | ConvertTo-Json
        }
        else {
            Write-Host "✓ $($result.message)" -ForegroundColor Green
        }
    }

    "inspect" {
        if (-not $X -or -not $Y) {
            Write-Host "[ERROR] X and Y coordinates required" -ForegroundColor Red
            exit 1
        }

        $result = Invoke-BridgeRequest -Method "GET" -Endpoint "/inspect/$X/$Y"
        if ($Json) {
            $result | ConvertTo-Json -Depth 10
        }
        else {
            Write-Host "Element at ($X, $Y):" -ForegroundColor Cyan
            $el = $result.element
            Write-Host "  Name: $($el.name)" -ForegroundColor White
            Write-Host "  AutomationId: $($el.automationId)" -ForegroundColor Gray
            Write-Host "  ClassName: $($el.className)" -ForegroundColor Gray
            Write-Host "  ControlType: $($el.controlType)" -ForegroundColor Gray
            Write-Host "  Enabled: $($el.isEnabled)" -ForegroundColor Gray
            Write-Host "  Visible: $($el.isVisible)" -ForegroundColor Gray
        }
    }

    "screenshot" {
        if ($WindowName) {
            $window = Get-WindowByName -Name $WindowName
            $WindowId = $window.id
        }

        if (-not $WindowId) {
            Write-Host "[ERROR] WindowId or WindowName required" -ForegroundColor Red
            exit 1
        }

        $result = Invoke-BridgeRequest -Method "GET" -Endpoint "/windows/$WindowId/screenshot"
        if ($Json) {
            $result | ConvertTo-Json
        }
        else {
            Write-Host "✓ Screenshot captured (base64 data URL)" -ForegroundColor Green
            Write-Host "Length: $($result.screenshot.Length) characters" -ForegroundColor Cyan
        }
    }

    "tree" {
        if ($WindowName) {
            $window = Get-WindowByName -Name $WindowName
            $WindowId = $window.id
        }

        if (-not $WindowId) {
            Write-Host "[ERROR] WindowId or WindowName required" -ForegroundColor Red
            exit 1
        }

        $result = Invoke-BridgeRequest -Method "GET" -Endpoint "/windows/$WindowId/tree"
        if ($Json) {
            $result | ConvertTo-Json -Depth 10
        }
        else {
            Write-Host "Element tree (max depth 5):" -ForegroundColor Cyan
            $result.tree | ConvertTo-Json -Depth 10 | Write-Host
        }
    }
}
