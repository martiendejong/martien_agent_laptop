<#
.SYNOPSIS
    Export a Claude Code session to readable markdown.

.DESCRIPTION
    Converts a session JSONL file to a clean markdown document
    for reading, archiving, or sharing.

.PARAMETER SessionId
    The session UUID to export (or partial match)

.PARAMETER Project
    Project folder to search in

.PARAMETER Output
    Output file path (default: session-<id>.md)

.PARAMETER IncludeThinking
    Include Claude's thinking blocks

.PARAMETER IncludeToolCalls
    Include tool calls and results

.EXAMPLE
    .\session-export.ps1 -SessionId "abc123"
    .\session-export.ps1 -SessionId "abc123" -Output "my-session.md" -IncludeThinking
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$SessionId,

    [string]$Project = "",

    [string]$Output = "",

    [switch]$IncludeThinking,

    [switch]$IncludeToolCalls
)

$ErrorActionPreference = "Stop"

$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"

# Find session file
$searchPath = if ($Project) {
    Join-Path $ClaudeProjectsPath $Project
} else {
    $ClaudeProjectsPath
}

Write-Host "`n=== Session Exporter ===" -ForegroundColor Cyan

$sessionFiles = Get-ChildItem -Path $searchPath -Filter "*.jsonl" -Recurse -File |
    Where-Object { $_.Name -like "*$SessionId*" }

if ($sessionFiles.Count -eq 0) {
    Write-Host "No session found matching '$SessionId'" -ForegroundColor Red
    exit 1
}

if ($sessionFiles.Count -gt 1) {
    Write-Host "Multiple sessions found. Please be more specific:" -ForegroundColor Yellow
    $sessionFiles | ForEach-Object { Write-Host "  $($_.Name)" }
    exit 1
}

$sessionFile = $sessionFiles[0]
$fullSessionId = [System.IO.Path]::GetFileNameWithoutExtension($sessionFile.Name)

if (-not $Output) {
    $Output = "session-$($fullSessionId.Substring(0,8)).md"
}

Write-Host "Exporting: $($sessionFile.Name)"
Write-Host "Output: $Output`n"

# Parse session
$lines = Get-Content $sessionFile.FullName
$markdown = @()

# Header
$projectName = Split-Path (Split-Path $sessionFile.FullName -Parent) -Leaf
$markdown += "# Session Export"
$markdown += ""
$markdown += "- **Session ID:** $fullSessionId"
$markdown += "- **Project:** $projectName"
$markdown += "- **Exported:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$markdown += ""
$markdown += "---"
$markdown += ""

$messageCount = 0
$toolCallCount = 0

foreach ($line in $lines) {
    try {
        $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
        if (-not $entry) { continue }

        # User messages
        if ($entry.type -eq "user" -and $entry.message.content) {
            $content = $entry.message.content
            if ($content -is [string] -and -not $content.StartsWith("<")) {
                $messageCount++
                $time = if ($entry.timestamp) { [DateTime]::Parse($entry.timestamp).ToString('HH:mm:ss') } else { "" }
                $markdown += "## User [$time]"
                $markdown += ""
                $markdown += $content
                $markdown += ""
            }
        }

        # Assistant messages
        if ($entry.type -eq "assistant" -and $entry.message.content) {
            $hasContent = $false

            foreach ($block in $entry.message.content) {
                if ($block.type -eq "thinking" -and $IncludeThinking) {
                    $markdown += "<details>"
                    $markdown += "<summary>Thinking...</summary>"
                    $markdown += ""
                    $markdown += $block.thinking
                    $markdown += ""
                    $markdown += "</details>"
                    $markdown += ""
                }

                if ($block.type -eq "text" -and $block.text) {
                    if (-not $hasContent) {
                        $messageCount++
                        $time = if ($entry.timestamp) { [DateTime]::Parse($entry.timestamp).ToString('HH:mm:ss') } else { "" }
                        $markdown += "## Claude [$time]"
                        $markdown += ""
                        $hasContent = $true
                    }
                    $markdown += $block.text
                    $markdown += ""
                }

                if ($block.type -eq "tool_use" -and $IncludeToolCalls) {
                    $toolCallCount++
                    $markdown += "``````"
                    $markdown += "Tool: $($block.name)"
                    $markdown += "Input: $($block.input | ConvertTo-Json -Compress)"
                    $markdown += "``````"
                    $markdown += ""
                }
            }
        }
    }
    catch {
        # Skip malformed lines
    }
}

# Footer
$markdown += "---"
$markdown += ""
$markdown += "*Exported $messageCount messages"
if ($IncludeToolCalls) {
    $markdown += ", $toolCallCount tool calls"
}
$markdown += "*"

# Write output
$markdown -join "`n" | Out-File -FilePath $Output -Encoding UTF8

Write-Host "Export complete!" -ForegroundColor Green
Write-Host "  Messages: $messageCount"
Write-Host "  Tool calls: $toolCallCount"
Write-Host "  Output: $Output"
