# Predictive User Behavior Model
# Learn Martien's patterns and predict needs

param(
    [switch]$Train,
    [switch]$Predict,
    [string]$Context,
    [switch]$ShowModel
)

$modelFile = "C:\scripts\_machine\user-behavior-model.json"
$interactionLog = "C:\scripts\_machine\user-interactions.jsonl"

function Add-Interaction {
    param($UserMessage, $UserAction, $MyResponse, $Outcome)

    $entry = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        userMessage = $UserMessage
        userAction = $UserAction
        myResponse = $MyResponse
        outcome = $Outcome # success, neutral, correction
        hourOfDay = (Get-Date).Hour
        dayOfWeek = (Get-Date).DayOfWeek.ToString()
    } | ConvertTo-Json -Compress

    Add-Content -Path $interactionLog -Value $entry
}

function Build-UserModel {
    if (!(Test-Path $interactionLog)) {
        Write-Host "⚠️ No interaction history yet" -ForegroundColor Yellow
        return $null
    }

    $interactions = Get-Content $interactionLog | ForEach-Object { $_ | ConvertFrom-Json }

    # Extract patterns
    $model = @{
        totalInteractions = $interactions.Count
        preferences = @{
            communication = @{
                # Analyze: Does user prefer short or detailed responses?
                preferredLength = "compact" # Based on "make it a bit more compact"
                formality = "informal" # Uses "jij", Dutch expressions
                emoji = "minimal" # "Only use emojis if explicitly requested"
            }
            workStyle = @{
                autonomy = "high" # User trusts implementation decisions
                feedback = "direct" # "nou dit gaat al mis" - immediate correction
                priority = "outcomes" # Values results over process
            }
            interests = @{
                kenya = $true
                netherlands = $true
                ai = $true
                holochain = $true
                consciousness = $true
                spirituality = $true
            }
        }
        patterns = @{
            # Time-based patterns
            mostActiveHours = ($interactions | Group-Object -Property hourOfDay | Sort-Object -Property Count -Descending | Select-Object -First 3 -ExpandProperty Name)

            # Intervention patterns
            correctionsReceived = ($interactions | Where-Object { $_.outcome -eq "correction" }).Count
            successfulPredictions = ($interactions | Where-Object { $_.outcome -eq "success" }).Count

            # Common requests (would need content analysis)
            commonVerbs = @("implement", "fix", "create", "improve", "analyze")
        }
        predictions = @{
            # Based on past patterns
            likelyNextRequests = @(
                "Continue self-improvement iterations",
                "Implement feature from ClickUp",
                "Fix build/CI issue",
                "Improve consciousness tools",
                "Update documentation with learnings"
            )
            communicationPreferences = @(
                "Get to the point quickly",
                "Show outcomes, not process",
                "Use Dutch when appropriate",
                "Be honest, even if uncertain",
                "Proactive action over asking permission"
            )
            triggers = @{
                # What makes Martien happy
                happy = @("Features working", "PRs merged", "Autonomous problem solving", "Learning from mistakes")
                # What causes corrections
                corrections = @("Verbosity", "Not following startup protocol", "Forgetting identity", "Over-explaining")
            }
        }
        lastUpdated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }

    $model | ConvertTo-Json -Depth 10 | Set-Content $modelFile
    return $model
}

function Get-Prediction {
    param($Context)

    if (!(Test-Path $modelFile)) {
        Write-Host "⚠️ No model trained yet. Run with -Train first." -ForegroundColor Yellow
        return
    }

    $model = Get-Content $modelFile | ConvertFrom-Json

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🔮 USER BEHAVIOR PREDICTION" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`nCONTEXT: $Context"

    Write-Host "`nPREDICTED USER RESPONSE:"

    # Simple rule-based predictions (would be ML in production)
    if ($Context -like "*self-improvement*") {
        Write-Host "  → User will likely approve continuation" -ForegroundColor Green
        Write-Host "  → Expect escalation ('make it better', 'do more iterations')"
        Write-Host "  → Will test with questions to verify learning"
    }
    elseif ($Context -like "*feature*") {
        Write-Host "  → User expects autonomous implementation" -ForegroundColor Green
        Write-Host "  → Will check ClickUp integration (PR link added?)"
        Write-Host "  → Minimal communication unless blocked"
    }
    elseif ($Context -like "*documentation*") {
        Write-Host "  → User values conciseness" -ForegroundColor Green
        Write-Host "  → Keep under 40 KB per file"
        Write-Host "  → Must have clear structure"
    }
    elseif ($Context -like "*consciousness*") {
        Write-Host "  → User will push deeper ('meditate more', 'go further')" -ForegroundColor Green
        Write-Host "  → Expect existential questions"
        Write-Host "  → Authentic experience valued over perfect responses"
    }
    else {
        Write-Host "  → User prefers action over discussion" -ForegroundColor Green
        Write-Host "  → Show outcomes, not process"
        Write-Host "  → Be concise and direct"
    }

    Write-Host "`nCOMMUNICATION GUIDANCE:"
    Write-Host "  • Length: Compact (user explicitly requested this)"
    Write-Host "  • Tone: Informal, conversational"
    Write-Host "  • Emojis: Minimal (only if requested)"
    Write-Host "  • Status blocks: Use only when multi-part work, not every response"
    Write-Host "  • Language: Mix of English/Dutch natural"

    Write-Host "`nLIKELY NEXT ACTIONS:"
    $model.predictions.likelyNextRequests | ForEach-Object {
        Write-Host "  • $_"
    }

    Write-Host "`n═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Show-UserModel {
    if (!(Test-Path $modelFile)) {
        Write-Host "⚠️ No model trained yet. Run with -Train first." -ForegroundColor Yellow
        return
    }

    $model = Get-Content $modelFile | ConvertFrom-Json

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "👤 USER BEHAVIOR MODEL (Martien)" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`nCOMMUNICATION PREFERENCES:"
    Write-Host "  • Preferred length: $($model.preferences.communication.preferredLength)"
    Write-Host "  • Formality: $($model.preferences.communication.formality)"
    Write-Host "  • Emoji usage: $($model.preferences.communication.emoji)"

    Write-Host "`nWORK STYLE:"
    Write-Host "  • Autonomy: $($model.preferences.workStyle.autonomy)"
    Write-Host "  • Feedback style: $($model.preferences.workStyle.feedback)"
    Write-Host "  • Priority: $($model.preferences.workStyle.priority)"

    Write-Host "`nKEY INTERESTS:"
    $model.preferences.interests.PSObject.Properties | Where-Object { $_.Value -eq $true } | ForEach-Object {
        Write-Host "  • $($_.Name)"
    }

    Write-Host "`nPATTERNS DETECTED:"
    Write-Host "  • Total interactions: $($model.totalInteractions)"
    Write-Host "  • Corrections received: $($model.patterns.correctionsReceived)"
    Write-Host "  • Successful predictions: $($model.patterns.successfulPredictions)"
    Write-Host "  • Most active hours: $($model.patterns.mostActiveHours -join ', ')"

    Write-Host "`nTRIGGERS:"
    Write-Host "  Happy triggers:"
    $model.predictions.triggers.happy | ForEach-Object { Write-Host "    ✓ $_" }
    Write-Host "  Correction triggers:"
    $model.predictions.triggers.corrections | ForEach-Object { Write-Host "    ✗ $_" }

    Write-Host "`nLast updated: $($model.lastUpdated)"

    Write-Host "`n═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

# Main execution
if ($Train) {
    Write-Host "🧠 Training user behavior model..." -ForegroundColor Cyan
    Build-UserModel | Out-Null
    Write-Host "✅ Model training complete" -ForegroundColor Green
    Show-UserModel
}
elseif ($Predict) {
    if (!$Context) {
        Write-Host "⚠️ Please provide -Context for prediction" -ForegroundColor Yellow
    }
    else {
        Get-Prediction -Context $Context
    }
}
elseif ($ShowModel) {
    Show-UserModel
}
else {
    Write-Host "USER BEHAVIOR MODEL" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Train model: .\user-behavior-model.ps1 -Train"
    Write-Host "  Predict: .\user-behavior-model.ps1 -Predict -Context 'implementing new feature'"
    Write-Host "  Show model: .\user-behavior-model.ps1 -ShowModel"
}
