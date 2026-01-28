<#
.SYNOPSIS
    Ask a question to an LLM using Hazina

.DESCRIPTION
    Simple LLM query tool using Hazina's multi-provider abstraction.
    Supports streaming responses and custom system prompts.

.PARAMETER Question
    The question to ask the LLM

.PARAMETER System
    Optional system prompt to set context

.PARAMETER NoStream
    Disable streaming (show response all at once)

.EXAMPLE
    hazina-ask.ps1 "What is the capital of France?"

.EXAMPLE
    hazina-ask.ps1 "Explain this code" -System "You are a senior developer"

.EXAMPLE
    hazina-ask.ps1 "Summarize this" -NoStream
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Question,

    [Parameter()]
    [string]$System = $null,

    [Parameter()]
    [switch]$NoStream
)

$ErrorActionPreference = "Stop"

# Find hazina CLI - prefer stable bin location
$hazinaPath = "C:\scripts\bin\hazina.exe"
if (!(Test-Path $hazinaPath)) {
    # Fallback to worktree build
    $hazinaPath = "C:\Projects\worker-agents\agent-002\hazina\apps\CLI\Hazina.CLI\bin\Release\net9.0\hazina.exe"
}
if (!(Test-Path $hazinaPath)) {
    Write-Error "Hazina CLI not found at C:\scripts\bin\hazina.exe. Run: Copy-Item 'C:\Projects\hazina\apps\CLI\Hazina.CLI\bin\Release\net9.0\*' 'C:\scripts\bin\' -Recurse"
    exit 1
}

$args = @("ask", $Question)

if ($System) {
    $args += "--system"
    $args += $System
}

if ($NoStream) {
    $args += "--stream"
    $args += "false"
}

& $hazinaPath @args
