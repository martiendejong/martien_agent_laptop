# Auto-Update Learned Patterns
# Automatically appends newly discovered patterns to relevant documentation

param(
    [Parameter(Mandatory=$true)]
    [string]$Pattern,

    [Parameter(Mandatory=$true)]
    [string]$Category,

    [Parameter(Mandatory=$false)]
    [string]$Context = ""
)

$categoryMap = @{
    "git" = "C:\scripts\_machine\best-practices\git-patterns.md"
    "workflow" = "C:\scripts\_machine\best-practices\workflow-patterns.md"
    "debugging" = "C:\scripts\_machine\best-practices\debugging-patterns.md"
    "performance" = "C:\scripts\_machine\best-practices\performance-patterns.md"
    "architecture" = "C:\scripts\_machine\best-practices\architecture-patterns.md"
    "communication" = "C:\scripts\_machine\best-practices\communication-patterns.md"
}

$targetFile = $categoryMap[$Category]

if (-not $targetFile) {
    Write-Error "Unknown category: $Category. Valid: $($categoryMap.Keys -join ', ')"
    exit 1
}

# Ensure file exists
if (-not (Test-Path $targetFile)) {
    "# $Category Patterns`n`nAuto-discovered patterns during conversations.`n" | Set-Content $targetFile
}

# Append pattern
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$entry = @"

## Pattern Discovered: $timestamp

**Pattern:** $Pattern

**Context:** $Context

**Source:** Auto-discovered during conversation

---

"@

Add-Content -Path $targetFile -Value $entry

Write-Host "Pattern added to $targetFile" -ForegroundColor Green

# Log to conversation events
$eventData = @{
    pattern = $Pattern
    category = $Category
    file = $targetFile
} | ConvertTo-Json -Compress

Add-Content -Path "C:\scripts\_machine\conversation-events.log.jsonl" -Value "{`"timestamp`":`"$timestamp`",`"event`":`"pattern_learned`",`"data`":$eventData}"
