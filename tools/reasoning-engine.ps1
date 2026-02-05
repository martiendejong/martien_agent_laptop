<#
.SYNOPSIS
    Logic Rule Engine (R16-001)

.DESCRIPTION
    Infer new facts from existing context using logical rules.
    Supports forward chaining, backward chaining, and rule-based inference.

.EXAMPLE
    .\reasoning-engine.ps1 -Query "next_file" -Context "code_edit"

.NOTES
    Part of Round 16: Reasoning & Logic
    Created: 2026-02-05
#>

param(
    [string]$Query = "infer",
    [string]$Context = ""
)

$KnowledgeStore = "C:\scripts\_machine\knowledge-store.yaml"
$RulesFile = "C:\scripts\_machine\reasoning-rules.yaml"

function Load-KnowledgeStore {
    if (Test-Path $KnowledgeStore) {
        return Get-Content $KnowledgeStore -Raw | ConvertFrom-Yaml
    }
    return @{}
}

function Load-Rules {
    if (Test-Path $RulesFile) {
        return Get-Content $RulesFile -Raw | ConvertFrom-Yaml
    }

    # Default rules
    return @{
        rules = @(
            @{
                name = "predict_test_after_code"
                if = @{
                    last_action = "code_edit"
                    file_type = ".cs"
                }
                then = @{
                    suggest = "run_tests"
                    confidence = 0.9
                }
            },
            @{
                name = "predict_controller_view"
                if = @{
                    opened_file = "*Controller.cs"
                }
                then = @{
                    suggest_file = "*View.tsx"
                    confidence = 0.85
                }
            },
            @{
                name = "morning_startup"
                if = @{
                    time_hour = @(7..12)
                    session_start = $true
                }
                then = @{
                    load_context = @("STARTUP_PROTOCOL.md", "MACHINE_CONFIG.md")
                    confidence = 0.95
                }
            },
            @{
                name = "end_of_day_commit"
                if = @{
                    time_hour = @(17..18)
                    uncommitted_changes = $true
                }
                then = @{
                    suggest = "commit_and_pr"
                    confidence = 0.75
                }
            }
        )
    }
}

function Test-Condition {
    param($Condition, $Facts)

    foreach ($key in $Condition.Keys) {
        $expectedValue = $Condition[$key]
        $actualValue = $Facts[$key]

        switch ($key) {
            "time_hour" {
                $currentHour = (Get-Date).Hour
                if ($expectedValue -is [array]) {
                    if ($currentHour -notin $expectedValue) { return $false }
                } else {
                    if ($currentHour -ne $expectedValue) { return $false }
                }
            }
            "last_action" {
                if ($Facts.last_action -ne $expectedValue) { return $false }
            }
            "file_type" {
                if ($Facts.file_type -notlike $expectedValue) { return $false }
            }
            "opened_file" {
                if ($Facts.opened_file -notlike $expectedValue) { return $false }
            }
            "session_start" {
                if ($Facts.session_start -ne $expectedValue) { return $false }
            }
            "uncommitted_changes" {
                if ($Facts.uncommitted_changes -ne $expectedValue) { return $false }
            }
            default {
                if ($actualValue -ne $expectedValue) { return $false }
            }
        }
    }

    return $true
}

function Invoke-ForwardChaining {
    param($Rules, $Facts)

    $inferences = @()

    foreach ($rule in $Rules.rules) {
        if (Test-Condition $rule.if $Facts) {
            $inference = @{
                rule = $rule.name
                conclusion = $rule.then
                confidence = $rule.then.confidence
                timestamp = Get-Date -Format "o"
            }
            $inferences += $inference

            Write-Host "✓ Rule matched: " -ForegroundColor Green -NoNewline
            Write-Host $rule.name
            Write-Host "  Conclusion: " -NoNewline
            Write-Host ($rule.then | ConvertTo-Json -Compress) -ForegroundColor Cyan
        }
    }

    return $inferences
}

function Invoke-BackwardChaining {
    param($Rules, $Goal, $Facts)

    # Find rules that conclude the goal
    foreach ($rule in $Rules.rules) {
        if ($rule.then.suggest -eq $Goal -or $rule.then.suggest_file -like $Goal) {
            Write-Host "🎯 Goal: $Goal can be achieved by:" -ForegroundColor Yellow
            Write-Host "  Rule: $($rule.name)" -ForegroundColor Cyan
            Write-Host "  Required conditions:" -ForegroundColor DarkGray

            foreach ($key in $rule.if.Keys) {
                $value = $rule.if[$key]
                Write-Host "    - $key = $value" -ForegroundColor DarkGray
            }

            # Check if conditions are met
            if (Test-Condition $rule.if $Facts) {
                Write-Host "  ✅ All conditions met!" -ForegroundColor Green
                return $rule
            } else {
                Write-Host "  ⚠️  Some conditions not met" -ForegroundColor Yellow
            }
        }
    }

    return $null
}

# Main execution
Write-Host ""
Write-Host "🧠 Reasoning Engine" -ForegroundColor Cyan
Write-Host "   Query: $Query" -ForegroundColor DarkGray
Write-Host ""

# Load knowledge and rules
$store = Load-KnowledgeStore
$rules = Load-Rules

# Build current facts from context
$facts = @{
    time_hour = (Get-Date).Hour
    time_day = (Get-Date).DayOfWeek.ToString()
    session_start = ($Context -eq "session_start")
    last_action = $Context
    file_type = ""
    opened_file = ""
    uncommitted_changes = $false
}

# Try to get more facts from git
try {
    $gitStatus = git status --porcelain 2>$null
    if ($gitStatus) {
        $facts.uncommitted_changes = $true
    }
} catch {}

switch ($Query) {
    "infer" {
        Write-Host "🔍 Forward chaining inference..." -ForegroundColor Yellow
        Write-Host ""
        $inferences = Invoke-ForwardChaining $rules $facts

        if ($inferences.Count -eq 0) {
            Write-Host "  ℹ️  No rules matched current context" -ForegroundColor DarkGray
        } else {
            Write-Host ""
            Write-Host "📊 Summary:" -ForegroundColor Cyan
            Write-Host "  Rules matched: $($inferences.Count)" -ForegroundColor White
            $avgConfidence = ($inferences | Measure-Object -Property confidence -Average).Average
            Write-Host "  Average confidence: $([math]::Round($avgConfidence * 100))%" -ForegroundColor White
        }
    }

    "goal" {
        if (-not $Context) {
            Write-Host "❌ Error: Goal required for backward chaining" -ForegroundColor Red
            Write-Host "   Usage: -Query goal -Context <goal>" -ForegroundColor DarkGray
        } else {
            Write-Host "🔍 Backward chaining for goal: $Context" -ForegroundColor Yellow
            Write-Host ""
            $result = Invoke-BackwardChaining $rules $Context $facts
        }
    }

    "consistency" {
        Write-Host "🔍 Checking logical consistency..." -ForegroundColor Yellow
        Write-Host ""

        # Check for contradictory rules
        $suggestions = @{}
        foreach ($rule in $rules.rules) {
            $suggest = $rule.then.suggest
            if ($suggest) {
                if (-not $suggestions.ContainsKey($suggest)) {
                    $suggestions[$suggest] = @()
                }
                $suggestions[$suggest] += $rule
            }
        }

        $contradictions = 0
        foreach ($suggest in $suggestions.Keys) {
            $rulesForSuggestion = $suggestions[$suggest]
            if ($rulesForSuggestion.Count -gt 1) {
                Write-Host "  ⚠️  Multiple rules suggest: $suggest" -ForegroundColor Yellow
                foreach ($r in $rulesForSuggestion) {
                    Write-Host "     - $($r.name) (confidence: $($r.then.confidence))" -ForegroundColor DarkGray
                }
                $contradictions++
            }
        }

        if ($contradictions -eq 0) {
            Write-Host "  ✅ No contradictions found" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "  ℹ️  Note: Multiple rules for same suggestion may indicate redundancy or priority needs" -ForegroundColor Cyan
        }
    }

    default {
        Write-Host "❌ Unknown query: $Query" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available queries:" -ForegroundColor Cyan
        Write-Host "  infer       - Forward chaining inference" -ForegroundColor White
        Write-Host "  goal        - Backward chaining (requires -Context <goal>)" -ForegroundColor White
        Write-Host "  consistency - Check for logical contradictions" -ForegroundColor White
    }
}

Write-Host ""
