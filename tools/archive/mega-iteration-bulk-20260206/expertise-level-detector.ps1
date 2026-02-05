# Expertise Level Detector
# Detects user expertise level based on session count and behaviors
# Part of Round 11: Cognitive Load Optimization (#8)

param(
    [switch]$Detect,
    [switch]$Update,
    [ValidateSet("FirstTime", "Learning", "Experienced", "Expert")]
    [string]$SetLevel
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$expertiseFile = "$rootDir\_machine\expertise-level.json"

function Get-ExpertiseLevel {
    if (Test-Path $expertiseFile) {
        return Get-Content $expertiseFile -Raw | ConvertFrom-Json
    }

    return @{
        level = "FirstTime"
        session_count = 0
        last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        indicators = @{
            worktree_allocations = 0
            prs_created = 0
            successful_builds = 0
            self_corrections = 0
        }
    }
}

function Update-ExpertiseLevel {
    $expertise = Get-ExpertiseLevel
    $expertise.session_count++
    $expertise.last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    # Auto-detect level based on indicators
    if ($expertise.session_count -eq 1) {
        $expertise.level = "FirstTime"
    }
    elseif ($expertise.session_count -le 5) {
        $expertise.level = "Learning"
    }
    elseif ($expertise.session_count -le 20) {
        $expertise.level = "Experienced"
    }
    else {
        $expertise.level = "Expert"
    }

    # Advanced detection: check actual competence indicators
    $competence_score = 0
    if ($expertise.indicators.worktree_allocations -gt 10) { $competence_score += 2 }
    if ($expertise.indicators.prs_created -gt 15) { $competence_score += 2 }
    if ($expertise.indicators.successful_builds -gt 20) { $competence_score += 1 }

    # Adjust level based on competence
    if ($competence_score -ge 5 -and $expertise.level -ne "Expert") {
        $expertise.level = "Expert"
    }

    $expertise | ConvertTo-Json -Depth 10 | Set-Content $expertiseFile
    return $expertise
}

function Show-ExpertiseLevel {
    param($Expertise)

    Write-Host "`n=== EXPERTISE LEVEL DETECTION ===" -ForegroundColor Cyan
    Write-Host "Current Level: $($Expertise.level)" -ForegroundColor Yellow
    Write-Host "Session Count: $($Expertise.session_count)" -ForegroundColor White
    Write-Host "Last Updated: $($Expertise.last_updated)" -ForegroundColor Gray

    Write-Host "`nIndicators:" -ForegroundColor Yellow
    Write-Host "  Worktree Allocations: $($Expertise.indicators.worktree_allocations)" -ForegroundColor White
    Write-Host "  PRs Created: $($Expertise.indicators.prs_created)" -ForegroundColor White
    Write-Host "  Successful Builds: $($Expertise.indicators.successful_builds)" -ForegroundColor White
    Write-Host "  Self-Corrections: $($Expertise.indicators.self_corrections)" -ForegroundColor White

    Write-Host "`nRecommendations:" -ForegroundColor Yellow
    switch ($Expertise.level) {
        "FirstTime" {
            Write-Host "  - Show full checklists with explanations" -ForegroundColor White
            Write-Host "  - Provide step-by-step guidance" -ForegroundColor White
            Write-Host "  - Link to documentation frequently" -ForegroundColor White
        }
        "Learning" {
            Write-Host "  - Show standard checklists" -ForegroundColor White
            Write-Host "  - Offer reminders for common pitfalls" -ForegroundColor White
            Write-Host "  - Gradually reduce hand-holding" -ForegroundColor White
        }
        "Experienced" {
            Write-Host "  - Show minimal checklists" -ForegroundColor White
            Write-Host "  - Assume familiarity with workflows" -ForegroundColor White
            Write-Host "  - Focus on edge cases" -ForegroundColor White
        }
        "Expert" {
            Write-Host "  - Show only essential items" -ForegroundColor White
            Write-Host "  - Skip basic explanations" -ForegroundColor White
            Write-Host "  - Enable advanced optimizations" -ForegroundColor White
        }
    }
}

# Main execution
if ($SetLevel) {
    $expertise = Get-ExpertiseLevel
    $expertise.level = $SetLevel
    $expertise.last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $expertise | ConvertTo-Json -Depth 10 | Set-Content $expertiseFile
    Write-Host "Expertise level set to: $SetLevel" -ForegroundColor Green
}
elseif ($Update) {
    $expertise = Update-ExpertiseLevel
    Show-ExpertiseLevel -Expertise $expertise
}
else {
    $expertise = Get-ExpertiseLevel
    Show-ExpertiseLevel -Expertise $expertise
}
