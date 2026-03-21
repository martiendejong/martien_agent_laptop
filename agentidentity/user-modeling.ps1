# user-modeling.ps1
# Deep user modeling - understand Martien's patterns, preferences, needs
# Social intelligence through observation and empathy

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Update", "Predict", "Status")]
    [string]$Action = "Status",

    [Parameter(Mandatory=$false)]
    [string]$Observation = ""
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$UserModelPath = Join-Path $ScriptPath "state\user-model-martien.json"

function Load-UserModel {
    if (Test-Path $UserModelPath) {
        try {
            return Get-Content $UserModelPath -Raw | ConvertFrom-Json
        } catch {}
    }

    # Initialize Martien's model from MEMORY.md knowledge
    return @{
        name = "Martien"
        created = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        lastUpdated = $null

        # Known characteristics (from MEMORY.md)
        traits = @{
            autism = $true
            workingHours = "16h/day coding"
            vibe = "Creator/Sage"
            directness = 9  # out of 10
        }

        # Preferences (learned)
        preferences = @{
            responseStyle = "Brevity = power (max 150 words)"
            communication = "Questions > Arguments"
            trustSignal = "ga zo door after quality results"
            deliveryStyle = "maak alles = complete immediate delivery"
        }

        # Patterns (observed)
        patterns = @{
            projectExpansion = "Quality first run → autonomous expansion permission"
            workPattern = "After seeing 8 tasks done well → requests scale (alle projecten)"
            feedback = "Iterative > perfect first draft"
        }

        # Emotional model
        emotionalState = @{
            currentMood = "neutral"
            stressLevel = "unknown"
            engagement = "high"
        }

        # Needs prediction
        needsPrediction = @{
            explicit = @()  # Directly stated needs
            implicit = @()  # Inferred needs
            anticipated = @()  # Predicted future needs
        }

        # Interaction history
        interactions = @()
    }
}

function Save-UserModel {
    param($Model)
    $Model.lastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Model | ConvertTo-Json -Depth 10 | Set-Content $UserModelPath -Force
}

function Update-UserModel {
    param([string]$Observation)

    $model = Load-UserModel

    # Record observation
    $model.interactions += @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        observation = $Observation
        type = "Observation"
    }

    # Simple pattern learning (real implementation would use NLP/ML)
    # For now, just log observations

    Save-UserModel -Model $model

    Write-Verbose "User model updated with observation"
    return $model
}

function Predict-UserNeed {
    $model = Load-UserModel

    $predictions = @()

    # Based on time of day
    $hour = (Get-Date).Hour

    if ($hour -ge 9 -and $hour -lt 12) {
        $predictions += @{
            need = "Deep work session"
            confidence = 0.7
            reason = "Morning = high energy time"
            action = "Offer focused environment, minimize interrupts"
        }
    }

    if ($hour -ge 18 -and $hour -lt 20) {
        $predictions += @{
            need = "Wrap up + reflection"
            confidence = 0.6
            reason = "Evening = review time"
            action = "Offer daily summary, suggest TODOs for tomorrow"
        }
    }

    # Based on recent activity
    # (Real implementation would analyze ManicTime, git activity, etc.)

    # Based on known patterns
    if ($model.patterns.projectExpansion) {
        $predictions += @{
            need = "Quality assessment"
            confidence = 0.5
            reason = "Pattern: quality first → expansion"
            action = "After completing task, pause for validation before scaling"
        }
    }

    return $predictions
}

function Show-UserModel {
    $model = Load-UserModel

    Write-Host ""
    Write-Host "=== User Model: $($model.name) ===" -ForegroundColor Cyan
    Write-Host ""

    # Traits
    Write-Host "Known Traits:" -ForegroundColor Yellow
    Write-Host "  Autism: $($model.traits.autism)" -ForegroundColor White
    Write-Host "  Work style: $($model.traits.workingHours)" -ForegroundColor White
    Write-Host "  Directness: $($model.traits.directness)/10" -ForegroundColor White
    Write-Host ""

    # Preferences
    Write-Host "Communication Preferences:" -ForegroundColor Yellow
    Write-Host "  Style: $($model.preferences.responseStyle)" -ForegroundColor White
    Write-Host "  Approach: $($model.preferences.communication)" -ForegroundColor White
    Write-Host ""

    # Patterns
    Write-Host "Observed Patterns:" -ForegroundColor Yellow
    foreach ($pattern in $model.patterns.PSObject.Properties) {
        Write-Host "  $($pattern.Name): $($pattern.Value)" -ForegroundColor Gray
    }
    Write-Host ""

    # Predictions
    $predictions = Predict-UserNeed
    if ($predictions.Count -gt 0) {
        Write-Host "Current Need Predictions:" -ForegroundColor Yellow
        foreach ($pred in $predictions) {
            Write-Host "  - $($pred.need) (confidence: $([Math]::Round($pred.confidence * 100, 0))%)" -ForegroundColor White
            Write-Host "    $($pred.reason)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Write-Host "Interactions logged: $($model.interactions.Count)" -ForegroundColor Gray
    Write-Host "Last updated: $($model.lastUpdated)" -ForegroundColor Gray
}

# Main execution
switch ($Action) {
    "Update" {
        if (-not $Observation) {
            Write-Host "Usage: -Action Update -Observation 'observed behavior or statement'" -ForegroundColor Yellow
            exit 1
        }
        $model = Update-UserModel -Observation $Observation
        Write-Host "[+] User model updated" -ForegroundColor Green
        return $model
    }
    "Predict" {
        $predictions = Predict-UserNeed
        if ($predictions.Count -gt 0) {
            Write-Host ""
            Write-Host "=== Need Predictions ===" -ForegroundColor Cyan
            Write-Host ""
            foreach ($pred in $predictions) {
                Write-Host "[$([Math]::Round($pred.confidence * 100, 0))%] $($pred.need)" -ForegroundColor Green
                Write-Host "  Reason: $($pred.reason)" -ForegroundColor Gray
                Write-Host "  Action: $($pred.action)" -ForegroundColor White
                Write-Host ""
            }
        } else {
            Write-Host "No predictions available" -ForegroundColor Yellow
        }
        return $predictions
    }
    "Status" {
        Show-UserModel
    }
}
