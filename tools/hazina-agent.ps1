<#
.SYNOPSIS
    Run a tool-calling agent using Hazina

.DESCRIPTION
    Execute complex tasks using an AI agent that can plan and execute steps.

.PARAMETER Task
    The task for the agent to complete

.PARAMETER MaxSteps
    Maximum number of agent steps (default 10)

.EXAMPLE
    hazina-agent.ps1 "Analyze this codebase and find security issues"

.EXAMPLE
    hazina-agent.ps1 "Create a summary of all TODO comments" -MaxSteps 20
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Task,

    [Parameter()]
    [int]$MaxSteps = 10
)

$ErrorActionPreference = "Stop"

# Find hazina CLI
$hazinaPath = "C:\Projects\hazina\apps\CLI\Hazina.CLI\bin\Debug\net9.0\hazina.exe"
if (!(Test-Path $hazinaPath)) {
    $hazinaPath = "C:\Projects\worker-agents\agent-002\hazina\apps\CLI\Hazina.CLI\bin\Debug\net9.0\hazina.exe"
}
if (!(Test-Path $hazinaPath)) {
    Write-Error "Hazina CLI not found. Build it first: cd C:\Projects\hazina\apps\CLI\Hazina.CLI && dotnet build"
    exit 1
}

& $hazinaPath agent $Task --max-steps $MaxSteps
