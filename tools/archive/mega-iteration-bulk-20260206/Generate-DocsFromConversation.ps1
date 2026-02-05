# Auto-Documentation Generator - Round 6
# Extracts key learnings from conversations into documentation

param(
    [Parameter(Mandatory=$false)]
    [string]$ConversationLog = "C:\scripts\_machine\conversation-events.log.jsonl",

    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "C:\scripts\_machine\auto-generated-docs"
)

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Load conversation events
$events = Get-Content $ConversationLog | ForEach-Object {
    $_ | ConvertFrom-Json
}

# Extract patterns discovered
$patterns = $events | Where-Object { $_.event -eq "pattern_learned" }

if ($patterns.Count -gt 0) {
    $patternDoc = @"
# Auto-Discovered Patterns
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm")

This documentation was automatically generated from conversation analysis.

"@

    foreach ($pattern in $patterns) {
        $data = $pattern.data | ConvertFrom-Json
        $patternDoc += @"

## $($data.pattern)

**Category:** $($data.category)
**Discovered:** $($pattern.timestamp)
**Source File:** $($data.file)

---

"@
    }

    $patternDoc | Set-Content (Join-Path $OutputDir "auto-discovered-patterns.md")
    Write-Host "Generated: auto-discovered-patterns.md" -ForegroundColor Green
}

# Extract architecture decisions
$decisions = $events | Where-Object { $_.event -eq "decision_made" }

if ($decisions.Count -gt 0) {
    $adrDoc = @"
# Architecture Decision Records (Auto-Generated)
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm")

"@

    $adrIndex = 1
    foreach ($decision in $decisions) {
        $data = $decision.data | ConvertFrom-Json
        $adrDoc += @"

## ADR-$('{0:D3}' -f $adrIndex): $($data.title)

**Status:** Accepted
**Date:** $($decision.timestamp)
**Context:** $($data.context)
**Decision:** $($data.decision)
**Consequences:** $($data.consequences)

---

"@
        $adrIndex++
    }

    $adrDoc | Set-Content (Join-Path $OutputDir "architecture-decisions.md")
    Write-Host "Generated: architecture-decisions.md" -ForegroundColor Green
}

# Extract key learnings
$learnings = $events | Where-Object { $_.event -match "learning|insight" }

if ($learnings.Count -gt 0) {
    $learningDoc = @"
# Session Learnings
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm")

Key insights discovered during conversations.

"@

    foreach ($learning in $learnings) {
        $learningDoc += @"

- **$($learning.timestamp)**: $($learning.data.insight)

"@
    }

    $learningDoc | Set-Content (Join-Path $OutputDir "session-learnings.md")
    Write-Host "Generated: session-learnings.md" -ForegroundColor Green
}

Write-Host "`nAuto-documentation complete! Output: $OutputDir" -ForegroundColor Cyan
