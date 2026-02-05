# Auto-Update Learned Patterns - R02-003
# When Claude discovers a pattern, automatically append to relevant pattern file
# Expert: Dr. Amara Okonkwo - Memory Systems Neuroscientist

param(
    [Parameter(Mandatory=$true)]
    [string]$Pattern,

    [Parameter(Mandatory=$false)]
    [string]$Category = 'general',

    [Parameter(Mandatory=$false)]
    [string]$Context = '',

    [Parameter(Mandatory=$false)]
    [ValidateSet('frontend', 'backend', 'ci-cd', 'debugging', 'architecture', 'git', 'general')]
    [string]$Domain = 'general'
)

$PatternsDir = "C:\scripts\_machine\best-practices"

# Determine target file based on domain
$targetFile = switch ($Domain) {
    'frontend' { "$PatternsDir\frontend-patterns.md" }
    'backend' { "$PatternsDir\backend-patterns.md" }
    'ci-cd' { "$PatternsDir\cicd-patterns.md" }
    'debugging' { "$PatternsDir\debugging-patterns.md" }
    'architecture' { "$PatternsDir\architecture-patterns.md" }
    'git' { "$PatternsDir\git-patterns.md" }
    default { "$PatternsDir\general-patterns.md" }
}

# Ensure file exists
if (-not (Test-Path $targetFile)) {
    New-Item -Path $targetFile -ItemType File -Force | Out-Null
    @"
# $Domain Patterns

Auto-discovered patterns from Claude conversations.

"@ | Out-File $targetFile -Encoding UTF8
}

# Format pattern entry
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$patternEntry = @"

## $Category - $timestamp

**Pattern:** $Pattern

$(if ($Context) { "**Context:** $Context" })

**Auto-learned:** Yes
**Confidence:** High

---

"@

# Append to file
Add-Content -Path $targetFile -Value $patternEntry -Encoding UTF8

Write-Host "Pattern added to $targetFile" -ForegroundColor Green

# Log to conversation events
$eventLog = "C:\scripts\_machine\conversation-events.log.jsonl"
$event = @{
    'timestamp' = Get-Date -Format 'o'
    'event' = 'pattern_learned'
    'pattern' = $Pattern
    'category' = $Category
    'domain' = $Domain
    'target_file' = $targetFile
} | ConvertTo-Json -Compress

Add-Content -Path $eventLog -Value $event -Encoding UTF8

Write-Host "Logged to conversation events" -ForegroundColor Cyan
