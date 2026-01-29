<#
.SYNOPSIS
    Deep extraction of patterns from conversation history
.DESCRIPTION
    More sophisticated analysis to find:
    - Repeated task sequences (potential workflows)
    - Error-correction pairs (rules to encode)
    - Communication patterns (style preferences)
    - Meta-learnings (process insights)
.EXAMPLE
    .\extract-conversation-patterns.ps1 -Days 30
.NOTES
    Created: 2026-01-29
    Author: Jengo (self-improvement)
#>

param(
    [int]$Days = 30,
    [switch]$Verbose
)

$historyPath = "C:\Users\HP\.claude\projects\C--scripts"
$reflectionLog = "C:\scripts\_machine\reflection.log.md"

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Magenta
Write-Host "  DEEP CONVERSATION PATTERN EXTRACTION" -ForegroundColor Magenta
Write-Host "==============================================================" -ForegroundColor Magenta
Write-Host ""

# Categories to extract
$patterns = @{
    task_sequences = @()      # Repeated multi-step tasks
    error_corrections = @()   # What I did wrong and learned
    user_feedback = @()       # Direct feedback about behavior
    workflow_hints = @()      # Process improvements mentioned
    communication_style = @() # How Martien likes communication
}

# Keywords for detection
$errorKeywords = @("fout", "wrong", "niet", "nee", "don't", "shouldn't", "verkeerd", "stop", "niet doen")
$feedbackKeywords = @("liever", "prefer", "beter", "better", "always", "altijd", "never", "nooit")
$workflowKeywords = @("workflow", "process", "stap", "step", "eerst", "first", "then", "dan")

# Also scan reflection log for encoded learnings
Write-Host "Scanning reflection log..." -ForegroundColor Yellow

if (Test-Path $reflectionLog) {
    $reflectionContent = Get-Content $reflectionLog -Raw

    # Extract date-headed sections
    $sections = [regex]::Matches($reflectionContent, '## (\d{4}-\d{2}-\d{2}[^\n]*)\n([\s\S]*?)(?=\n## |\z)')

    Write-Host "Found $($sections.Count) reflection entries" -ForegroundColor Gray

    foreach ($section in $sections) {
        $date = $section.Groups[1].Value
        $content = $section.Groups[2].Value

        # Extract key learnings
        if ($content -match "What I [Ll]earned|Lesson|Learning|Key [Ii]nsight") {
            $patterns.error_corrections += @{
                date = $date
                type = "reflection_learning"
                snippet = $content.Substring(0, [Math]::Min(200, $content.Length))
            }
        }

        # Extract patterns mentioned
        if ($content -match "pattern|Pattern|always|Always|never|Never|rule|Rule") {
            $patterns.workflow_hints += @{
                date = $date
                type = "pattern_mention"
                snippet = $content.Substring(0, [Math]::Min(200, $content.Length))
            }
        }
    }
}

# Scan recent sessions for patterns
$cutoffDate = (Get-Date).AddDays(-$Days)
$sessions = Get-ChildItem -Path $historyPath -Filter "*.jsonl" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $cutoffDate }

Write-Host "Scanning $($sessions.Count) conversation sessions..." -ForegroundColor Yellow

$humanMessages = @()
$assistantActions = @()

foreach ($session in $sessions) {
    try {
        $lines = Get-Content $session.FullName -ErrorAction SilentlyContinue | Select-Object -First 500

        foreach ($line in $lines) {
            try {
                $json = $line | ConvertFrom-Json -ErrorAction SilentlyContinue

                if ($json.type -eq "human" -and $json.message.content) {
                    $msg = $json.message.content
                    if ($msg -is [string] -and $msg.Length -gt 10) {
                        $humanMessages += @{
                            session = $session.Name
                            content = $msg
                        }

                        # Check for error keywords
                        foreach ($keyword in $errorKeywords) {
                            if ($msg -match $keyword) {
                                $patterns.error_corrections += @{
                                    session = $session.Name
                                    keyword = $keyword
                                    context = $msg.Substring(0, [Math]::Min(150, $msg.Length))
                                }
                                break
                            }
                        }

                        # Check for feedback keywords
                        foreach ($keyword in $feedbackKeywords) {
                            if ($msg -match $keyword) {
                                $patterns.user_feedback += @{
                                    session = $session.Name
                                    keyword = $keyword
                                    context = $msg.Substring(0, [Math]::Min(150, $msg.Length))
                                }
                                break
                            }
                        }
                    }
                }
            } catch { }
        }
    } catch { }
}

# Report findings
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Magenta
Write-Host "  EXTRACTED PATTERNS" -ForegroundColor Magenta
Write-Host "==============================================================" -ForegroundColor Magenta

Write-Host ""
Write-Host "ERROR CORRECTIONS: $($patterns.error_corrections.Count)" -ForegroundColor Red
$patterns.error_corrections | Select-Object -First 5 | ForEach-Object {
    if ($_.context) {
        Write-Host "  - $($_.context.Substring(0, [Math]::Min(80, $_.context.Length)))..." -ForegroundColor Gray
    } elseif ($_.snippet) {
        Write-Host "  - [$($_.date)] $($_.snippet.Substring(0, [Math]::Min(60, $_.snippet.Length)))..." -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "USER FEEDBACK: $($patterns.user_feedback.Count)" -ForegroundColor Yellow
$patterns.user_feedback | Select-Object -First 5 | ForEach-Object {
    Write-Host "  - [$($_.keyword)] $($_.context.Substring(0, [Math]::Min(70, $_.context.Length)))..." -ForegroundColor Gray
}

Write-Host ""
Write-Host "WORKFLOW HINTS: $($patterns.workflow_hints.Count)" -ForegroundColor Green
$patterns.workflow_hints | Select-Object -First 5 | ForEach-Object {
    Write-Host "  - [$($_.date)] Pattern/rule mentioned" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Magenta
Write-Host "  RECOMMENDATIONS" -ForegroundColor Magenta
Write-Host "==============================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "  1. Review error corrections - encode as rules" -ForegroundColor White
Write-Host "  2. Add user feedback to PERSONAL_INSIGHTS.md" -ForegroundColor White
Write-Host "  3. Create skills from repeated workflows" -ForegroundColor White
Write-Host "  4. Update error_patterns.yaml with new patterns" -ForegroundColor White
Write-Host ""

# Save to file for further analysis
$outputPath = "C:\scripts\agentidentity\state\extracted_patterns.json"
$patterns | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8
Write-Host "Full patterns saved to: $outputPath" -ForegroundColor Green
Write-Host ""
