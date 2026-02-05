# Session Context Preloader
# Preloads context at session start based on predicted needs
# Part of Round 11: Cognitive Load Optimization (#10)

param(
    [switch]$ShowPredictions,
    [switch]$Load
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$historyFile = "$rootDir\_machine\session-history.json"

function Get-SessionHistory {
    if (Test-Path $historyFile) {
        return Get-Content $historyFile -Raw | ConvertFrom-Json
    }
    return @{
        last_session = @{}
        sessions = @()
    }
}

function Predict-Context {
    $history = Get-SessionHistory
    $predictions = @{
        mode = "unknown"
        confidence = 0
        branch = $null
        tasks = @()
        files = @()
        preload_recommended = $false
    }

    # Get current git context
    try {
        $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
        $predictions.branch = $currentBranch
    }
    catch {
        # Not in git repo
    }

    # Predict mode from last session
    if ($history.last_session.mode) {
        $predictions.mode = $history.last_session.mode
        $predictions.confidence = 0.7  # 70% likely to continue same mode
    }

    # Higher confidence if branch suggests mode
    if ($currentBranch -match "^feature/") {
        $predictions.mode = "FeatureDev"
        $predictions.confidence = 0.9
    }
    elseif ($currentBranch -match "^fix/|^hotfix/") {
        $predictions.mode = "Debugging"
        $predictions.confidence = 0.85
    }

    # Predict recent files
    if ($history.last_session.files_edited) {
        $predictions.files = $history.last_session.files_edited[0..4]  # Last 5 files
    }

    # Recommend preload if confidence > 50%
    $predictions.preload_recommended = $predictions.confidence -gt 0.5

    return $predictions
}

function Preload-Context {
    param($Predictions)

    Write-Host "`n=== PRELOADING SESSION CONTEXT ===" -ForegroundColor Cyan

    # Preload git status
    Write-Host "`nGit Context:" -ForegroundColor Yellow
    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        $uncommitted = (git status --porcelain 2>$null | Measure-Object).Count

        Write-Host "  Branch: $branch" -ForegroundColor White
        Write-Host "  Uncommitted Changes: $uncommitted" -ForegroundColor White
    }
    catch {
        Write-Host "  Not in git repository" -ForegroundColor Gray
    }

    # Preload worktree status
    Write-Host "`nWorktree Status:" -ForegroundColor Yellow
    try {
        $worktrees = git worktree list 2>$null
        if ($worktrees) {
            $count = ($worktrees | Measure-Object).Count
            Write-Host "  Active Worktrees: $count" -ForegroundColor White
        }
        else {
            Write-Host "  No active worktrees" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  Worktree check failed" -ForegroundColor Gray
    }

    # Preload recent documentation
    if ($Predictions.files.Count -gt 0) {
        Write-Host "`nRecent Files:" -ForegroundColor Yellow
        foreach ($file in $Predictions.files) {
            if (Test-Path $file) {
                Write-Host "  - $file" -ForegroundColor White
            }
        }
    }

    # Preload build status (check if last build passed)
    Write-Host "`nBuild Status:" -ForegroundColor Yellow
    $clientManagerPath = "C:\Projects\client-manager"
    if (Test-Path "$clientManagerPath\client-manager.sln") {
        Write-Host "  Solution: client-manager.sln" -ForegroundColor White
        # Check for recent build artifacts
        if (Test-Path "$clientManagerPath\bin\Debug") {
            Write-Host "  Last build: Debug configuration" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  No solution found" -ForegroundColor Gray
    }

    Write-Host "`n" -NoNewline
}

function Show-Predictions {
    param($Predictions)

    Write-Host "`n=== SESSION CONTEXT PREDICTIONS ===" -ForegroundColor Cyan

    $confidenceColor = if ($Predictions.confidence -gt 0.8) { "Green" }
                       elseif ($Predictions.confidence -gt 0.5) { "Yellow" }
                       else { "Red" }

    Write-Host "`nPredicted Mode: $($Predictions.mode)" -ForegroundColor Yellow
    Write-Host "Confidence: $([Math]::Round($Predictions.confidence * 100))%" -ForegroundColor $confidenceColor

    if ($Predictions.branch) {
        Write-Host "`nCurrent Branch: $($Predictions.branch)" -ForegroundColor Yellow
    }

    if ($Predictions.files.Count -gt 0) {
        Write-Host "`nRecent Files (Last Session):" -ForegroundColor Yellow
        foreach ($file in $Predictions.files) {
            Write-Host "  - $file" -ForegroundColor White
        }
    }

    if ($Predictions.preload_recommended) {
        Write-Host "`nRecommendation: AUTO-LOAD context (confidence > 50%)" -ForegroundColor Green
        Write-Host "Run with -Load to preload context" -ForegroundColor Gray
    }
    else {
        Write-Host "`nRecommendation: SKIP preload (low confidence)" -ForegroundColor Yellow
    }
}

function Save-SessionContext {
    param(
        [string]$Mode,
        [string[]]$FilesEdited
    )

    $history = Get-SessionHistory

    $session = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        mode = $Mode
        files_edited = $FilesEdited
        branch = (git rev-parse --abbrev-ref HEAD 2>$null)
    }

    $history.last_session = $session
    $history.sessions += $session

    # Keep last 50 sessions
    if ($history.sessions.Count -gt 50) {
        $history.sessions = $history.sessions[-50..-1]
    }

    $history | ConvertTo-Json -Depth 10 | Set-Content $historyFile
}

# Main execution
$predictions = Predict-Context

if ($ShowPredictions) {
    Show-Predictions -Predictions $predictions
}
elseif ($Load) {
    Preload-Context -Predictions $predictions
}
else {
    # Auto mode: preload if recommended
    if ($predictions.preload_recommended) {
        Write-Host "Auto-loading context (confidence: $([Math]::Round($predictions.confidence * 100))%)..." -ForegroundColor Green
        Preload-Context -Predictions $predictions
    }
    else {
        Write-Host "Low confidence prediction - showing predictions instead" -ForegroundColor Yellow
        Show-Predictions -Predictions $predictions
    }
}
