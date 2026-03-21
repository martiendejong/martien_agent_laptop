# Universal Tool API - Multi-Agent Tool Invocation Wrapper
# Version: 1.0.0
# Created: 2026-02-25
# Purpose: Universal interface for invoking any Jengo tool from any AI agent

param(
    [Parameter(Mandatory=$true)]
    [string]$Tool,              # Tool name (without .ps1 extension)

    [Parameter(Mandatory=$false)]
    [string]$Args = "{}",       # JSON string of arguments

    [Parameter(Mandatory=$false)]
    [switch]$Silent,            # Suppress output (return JSON only)

    [Parameter(Mandatory=$false)]
    [string]$AgentId = "unknown" # Agent identifier (for logging)
)

$ErrorActionPreference = "Stop"

# Script root
$ScriptRoot = Split-Path -Parent $PSScriptRoot
$ToolsDir = Join-Path $ScriptRoot "tools"

# Parse arguments
try {
    $ArgsObj = $Args | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse Args JSON: $_"
    exit 1
}

# Resolve tool path
$ToolPath = Join-Path $ToolsDir "$Tool.ps1"
if (-not (Test-Path $ToolPath)) {
    Write-Error "Tool not found: $Tool (expected at $ToolPath)"
    exit 1
}

# Log invocation (for multi-agent tracking)
$InvocationLog = Join-Path $ScriptRoot "_machine" "tool-invocations.jsonl"
$InvocationEntry = @{
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
    agent_id = $AgentId
    tool = $Tool
    args = $ArgsObj
} | ConvertTo-Json -Compress

try {
    Add-Content -Path $InvocationLog -Value $InvocationEntry -ErrorAction SilentlyContinue
} catch {
    # Non-critical - continue even if logging fails
}

# Build parameter hash for splatting
$Params = @{}
foreach ($prop in $ArgsObj.PSObject.Properties) {
    $paramName = $prop.Name
    $paramValue = $prop.Value

    # Convert boolean strings
    if ($paramValue -is [string]) {
        if ($paramValue -eq "true") { $paramValue = $true }
        elseif ($paramValue -eq "false") { $paramValue = $false }
    }

    $Params[$paramName] = $paramValue
}

# Execute tool
if (-not $Silent) {
    Write-Host "[unified-tool-api] Invoking $Tool with args: $Args" -ForegroundColor Cyan
}

try {
    # Invoke tool with splatted parameters
    $Result = & $ToolPath @Params

    # If result is object, convert to JSON
    if ($Result -is [PSCustomObject] -or $Result -is [Hashtable]) {
        $ResultJson = $Result | ConvertTo-Json -Depth 10 -Compress
        if ($Silent) {
            Write-Output $ResultJson
        } else {
            Write-Host "[unified-tool-api] Result: $ResultJson" -ForegroundColor Green
        }
    } else {
        # Plain text result
        if ($Silent) {
            Write-Output $Result
        } else {
            Write-Host "[unified-tool-api] Result: $Result" -ForegroundColor Green
        }
    }

    exit 0
} catch {
    $ErrorMsg = "Tool execution failed: $_"
    if ($Silent) {
        $ErrorJson = @{
            success = $false
            error = $ErrorMsg
            tool = $Tool
            args = $ArgsObj
        } | ConvertTo-Json -Compress
        Write-Output $ErrorJson
    } else {
        Write-Host "[unified-tool-api] ERROR: $ErrorMsg" -ForegroundColor Red
    }
    exit 1
}
