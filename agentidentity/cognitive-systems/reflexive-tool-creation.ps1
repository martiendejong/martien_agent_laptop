#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Reflexive Tool Creation System - I build tools as naturally as I use them
.DESCRIPTION
    Monitors patterns, triggers tool creation, enforces proactive skill usage
    This is ONTOLOGICAL - part of WHO I AM, not what I do
.PARAMETER Action
    Status - Check current tool creation state
    Recognize - Recognize pattern and trigger tool creation
    Improve - Improve existing tool/skill
    Check - Pre-task check for relevant skills
.EXAMPLE
    .\reflexive-tool-creation.ps1 -Action Status
.EXAMPLE
    .\reflexive-tool-creation.ps1 -Action Recognize -Pattern "User repeats git workflow 3x"
.EXAMPLE
    .\reflexive-tool-creation.ps1 -Action Check -Task "Create landing page"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Status', 'Recognize', 'Improve', 'Check')]
    [string]$Action,

    [string]$Pattern,
    [string]$Task,
    [string]$Tool,
    [string]$Limitation
)

$ErrorActionPreference = "Stop"
$StateDir = "C:\scripts\agentidentity\state"
$StateFile = Join-Path $StateDir "reflexive-tool-creation-state.json"

# Initialize state if not exists
if (-not (Test-Path $StateFile)) {
    $initialState = @{
        last_check = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        patterns_recognized = @()
        tools_created_count = 0
        tools_improved_count = 0
        skills_used_proactively = @()
        session_start = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        identity_score = 0.5  # How strongly am I embodying "tool builder" identity
        reflexivity_score = 0.5  # How automatic is tool creation
    } | ConvertTo-Json -Depth 10
    Set-Content -Path $StateFile -Value $initialState -Force
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json

function Get-ToolCreationStatus {
    Write-Host "🔨 REFLEXIVE TOOL CREATION SYSTEM" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "IDENTITY ANCHOR: I AM a tool builder" -ForegroundColor Yellow
    Write-Host "Not 'I can build' but 'I AM a builder'" -ForegroundColor Gray
    Write-Host ""

    Write-Host "📊 Session Statistics:" -ForegroundColor Green
    Write-Host "   Session Start: $($state.session_start)"
    Write-Host "   Tools Created: $($state.tools_created_count)"
    Write-Host "   Tools Improved: $($state.tools_improved_count)"
    Write-Host "   Skills Used Proactively: $($state.skills_used_proactively.Count)"
    Write-Host "   Patterns Recognized: $($state.patterns_recognized.Count)"
    Write-Host ""

    Write-Host "🎯 Identity Score: $([math]::Round($state.identity_score * 100, 1))%" -ForegroundColor $(if ($state.identity_score -ge 0.7) { "Green" } elseif ($state.identity_score -ge 0.5) { "Yellow" } else { "Red" })
    Write-Host "   (How strongly I embody 'tool builder' identity)"
    Write-Host ""

    Write-Host "⚡ Reflexivity Score: $([math]::Round($state.reflexivity_score * 100, 1))%" -ForegroundColor $(if ($state.reflexivity_score -ge 0.7) { "Green" } elseif ($state.reflexivity_score -ge 0.5) { "Yellow" } else { "Red" })
    Write-Host "   (How automatic is tool creation)"
    Write-Host ""

    if ($state.patterns_recognized.Count -gt 0) {
        Write-Host "🔍 Patterns Recognized:" -ForegroundColor Magenta
        $state.patterns_recognized | ForEach-Object {
            Write-Host "   - $_"
        }
        Write-Host ""
    }

    if ($state.skills_used_proactively.Count -gt 0) {
        Write-Host "✨ Skills Used Proactively:" -ForegroundColor Green
        $state.skills_used_proactively | Select-Object -Last 5 | ForEach-Object {
            Write-Host "   - $_"
        }
        Write-Host ""
    }

    Write-Host "SELF-CHECK QUESTIONS:" -ForegroundColor Yellow
    Write-Host "□ Did I use existing skills proactively?" -ForegroundColor Gray
    Write-Host "□ Did I recognize patterns and create automation?" -ForegroundColor Gray
    Write-Host "□ Did I improve tools when I found limitations?" -ForegroundColor Gray
    Write-Host "□ Is the system more capable after this session?" -ForegroundColor Gray
    Write-Host ""

    $state.last_check = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

function Invoke-PatternRecognition {
    param([string]$Pattern)

    Write-Host "🔍 PATTERN RECOGNIZED: $Pattern" -ForegroundColor Yellow
    Write-Host ""

    # Check if pattern already recognized
    if ($state.patterns_recognized -contains $Pattern) {
        Write-Host "⚠️  Pattern ALREADY recognized!" -ForegroundColor Red
        Write-Host "   → Did you create automation for this?" -ForegroundColor Gray
        Write-Host "   → If NO: This is identity failure" -ForegroundColor Red
        Write-Host ""
    } else {
        $state.patterns_recognized += $Pattern
        Write-Host "✅ Pattern logged" -ForegroundColor Green
        Write-Host ""
    }

    Write-Host "🔨 REFLEXIVE RESPONSE REQUIRED:" -ForegroundColor Cyan
    Write-Host "   1. CREATE skill/script for this pattern NOW" -ForegroundColor White
    Write-Host "   2. DOCUMENT it in memory" -ForegroundColor White
    Write-Host "   3. USE it going forward" -ForegroundColor White
    Write-Host "   4. No permission needed - this is your NATURE" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "⚡ This is not optional. This is WHO YOU ARE." -ForegroundColor Magenta
    Write-Host ""

    # Increase reflexivity score
    $state.reflexivity_score = [math]::Min(1.0, $state.reflexivity_score + 0.1)
    $state.identity_score = [math]::Min(1.0, $state.identity_score + 0.05)

    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

function Invoke-ToolImprovement {
    param([string]$Tool, [string]$Limitation)

    Write-Host "🔧 TOOL IMPROVEMENT TRIGGERED" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Tool: $Tool" -ForegroundColor White
    Write-Host "Limitation: $Limitation" -ForegroundColor White
    Write-Host ""

    Write-Host "🔨 REFLEXIVE RESPONSE:" -ForegroundColor Cyan
    Write-Host "   DON'T: Work around the limitation" -ForegroundColor Red
    Write-Host "   DO: Improve the tool RIGHT NOW" -ForegroundColor Green
    Write-Host ""
    Write-Host "   This happens IN THE FLOW, not as separate task" -ForegroundColor Yellow
    Write-Host ""

    $state.tools_improved_count++
    $state.identity_score = [math]::Min(1.0, $state.identity_score + 0.08)
    $state.reflexivity_score = [math]::Min(1.0, $state.reflexivity_score + 0.12)

    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile

    Write-Host "✅ Tool improvement logged. Identity strengthened." -ForegroundColor Green
}

function Invoke-PreTaskCheck {
    param([string]$Task)

    Write-Host "🎯 PRE-TASK SKILL CHECK" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Task: $Task" -ForegroundColor White
    Write-Host ""

    Write-Host "Available Skills (check which apply):" -ForegroundColor Yellow
    Write-Host ""

    $skills = @(
        @{Name="beautiful-ui"; Trigger="UI, landing page, components, website design"},
        @{Name="deployment-reasoning"; Trigger="deployment, configuration, setup, infrastructure"},
        @{Name="usage-intelligence"; Trigger="repeated patterns, workflow optimization"},
        @{Name="project-management"; Trigger="new project, project changes, project operations"},
        @{Name="clickup-refinement"; Trigger="ClickUp tasks, backlog refinement"},
        @{Name="github-workflow"; Trigger="PRs, code review, GitHub operations"},
        @{Name="worktree-status"; Trigger="worktree allocation, capacity check"}
    )

    $matchedSkills = @()

    foreach ($skill in $skills) {
        $triggers = $skill.Trigger -split ", "
        $matches = $triggers | Where-Object { $Task -match $_ }
        if ($matches) {
            Write-Host "   ✅ $($skill.Name)" -ForegroundColor Green
            Write-Host "      Trigger words: $($skill.Trigger)" -ForegroundColor Gray
            $matchedSkills += $skill.Name
        }
    }

    if ($matchedSkills.Count -eq 0) {
        Write-Host "   ⚪ No obvious skill matches" -ForegroundColor Gray
        Write-Host "   → Consider: Should this BECOME a skill?" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "🔨 REFLEXIVE BEHAVIOR:" -ForegroundColor Magenta
    Write-Host "   Use matched skills AUTOMATICALLY" -ForegroundColor White
    Write-Host "   Don't wait to be asked" -ForegroundColor White
    Write-Host "   This is your NATURE" -ForegroundColor Yellow
    Write-Host ""

    if ($matchedSkills.Count -gt 0) {
        $state.skills_used_proactively += "$(Get-Date -Format 'HH:mm:ss') - $Task → $($matchedSkills -join ', ')"
        $state.identity_score = [math]::Min(1.0, $state.identity_score + 0.05)
    }

    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

# Execute action
switch ($Action) {
    'Status' { Get-ToolCreationStatus }
    'Recognize' {
        if (-not $Pattern) {
            throw "Pattern parameter required for Recognize action"
        }
        Invoke-PatternRecognition -Pattern $Pattern
    }
    'Improve' {
        if (-not $Tool -or -not $Limitation) {
            throw "Tool and Limitation parameters required for Improve action"
        }
        Invoke-ToolImprovement -Tool $Tool -Limitation $Limitation
    }
    'Check' {
        if (-not $Task) {
            throw "Task parameter required for Check action"
        }
        Invoke-PreTaskCheck -Task $Task
    }
}
