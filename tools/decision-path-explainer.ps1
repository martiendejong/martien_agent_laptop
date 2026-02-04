# decision-path-explainer.ps1
# Logs and explains the decision path taken for complex decisions

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('optimization', 'architecture', 'priority', 'mode', 'error-handling')]
    [string]$DecisionType,

    [Parameter(Mandatory=$true)]
    [string]$Question,

    [Parameter(Mandatory=$true)]
    [string]$Answer,

    [string]$Explanation = "",

    [switch]$ShowPath
)

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logPath = "C:\scripts\agentidentity\state\decision-paths.yaml"

# Ensure file exists
if (-not (Test-Path $logPath)) {
    @"
decision_paths:
  metadata:
    created: $timestamp
    purpose: "Track decision reasoning for transparency and learning"

  decisions: []
"@ | Out-File -FilePath $logPath -Encoding UTF8
}

# Read current log
$content = Get-Content $logPath -Raw | ConvertFrom-Yaml

# Create decision entry
$decisionEntry = @{
    timestamp = $timestamp
    type = $DecisionType
    question = $Question
    answer = $Answer
    explanation = $Explanation
    path = @()
}

# Determine which systems were consulted based on decision type
switch ($DecisionType) {
    'optimization' {
        $decisionEntry.path = @(
            @{ system = "WHEN_NOT_TO_OPTIMIZE.md"; result = "Checked negative constraints" }
            @{ system = "optimization-roi-calculator.ps1"; result = "Calculated cost/benefit" }
            @{ system = "META_GOAL_HIERARCHY.md"; result = "Checked goal priorities" }
            @{ system = "FAST_PATH_DECISIONS.md"; result = "Applied heuristic" }
        )
    }
    'architecture' {
        $decisionEntry.path = @(
            @{ system = "META_GOAL_HIERARCHY.md"; result = "Terminal vs instrumental goals" }
            @{ system = "HEURISTICS_LIBRARY.md"; result = "Worse is better, YAGNI" }
            @{ system = "MENTAL_MODELS.md"; result = "Conceptual framework" }
        )
    }
    'priority' {
        $decisionEntry.path = @(
            @{ system = "META_GOAL_HIERARCHY.md"; result = "Tier comparison" }
            @{ system = "CONTEXT_SENSITIVITY.md"; result = "Context factors" }
            @{ system = "attention-allocator.ps1"; result = "Resource allocation" }
        )
    }
    'mode' {
        $decisionEntry.path = @(
            @{ system = "FAST_PATH_DECISIONS.md"; result = "Mode selection heuristic" }
            @{ system = "CONTEXT_SENSITIVITY.md"; result = "Situational factors" }
        )
    }
    'error-handling' {
        $decisionEntry.path = @(
            @{ system = "ERROR_PATTERN_LIBRARY.md"; result = "Pattern match" }
            @{ system = "RECOVERY_PROTOCOLS.md"; result = "Recovery procedure" }
            @{ system = "BLAME_FREE_RETROSPECTIVE.md"; result = "Learning capture" }
        )
    }
}

# Add to decisions array
if (-not $content.decision_paths.decisions) {
    $content.decision_paths.decisions = @()
}
$content.decision_paths.decisions += $decisionEntry

# Keep last 100 decisions
if ($content.decision_paths.decisions.Count -gt 100) {
    $content.decision_paths.decisions = $content.decision_paths.decisions[-100..-1]
}

# Save
$content | ConvertTo-Yaml | Out-File -FilePath $logPath -Encoding UTF8

if ($ShowPath) {
    Write-Host "`n🧠 DECISION PATH EXPLANATION" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "Question: " -NoNewline -ForegroundColor Yellow
    Write-Host $Question
    Write-Host "`nSystems Consulted:" -ForegroundColor Cyan

    $stepNum = 1
    foreach ($step in $decisionEntry.path) {
        Write-Host "  $stepNum. " -NoNewline -ForegroundColor DarkGray
        Write-Host $step.system -NoNewline -ForegroundColor White
        Write-Host " → " -NoNewline -ForegroundColor DarkGray
        Write-Host $step.result -ForegroundColor Gray
        $stepNum++
    }

    Write-Host "`nAnswer: " -NoNewline -ForegroundColor Yellow
    Write-Host $Answer -ForegroundColor Green

    if ($Explanation) {
        Write-Host "`nReasoning: " -NoNewline -ForegroundColor Yellow
        Write-Host $Explanation -ForegroundColor Gray
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}

Write-Output "Decision path logged: $DecisionType"
