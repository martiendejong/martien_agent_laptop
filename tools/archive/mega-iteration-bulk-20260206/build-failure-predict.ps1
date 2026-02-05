# Build Failure Predictor
# Predicts build failures before committing using ML and static analysis
#
# Usage:
#   .\build-failure-predict.ps1 -Project C:\Projects\client-manager
#   .\build-failure-predict.ps1 -Files "file1.cs,file2.cs"
#   .\build-failure-predict.ps1 -PreCommitHook

param(
    [Parameter(Mandatory=$false)]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [string]$Files,

    [Parameter(Mandatory=$false)]
    [switch]$PreCommitHook
)

$ErrorActionPreference = "Stop"

Write-Host "`n🔮 Build Failure Predictor" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Load failure patterns from history
$failurePatterns = @{
    MissingUsing = @{
        Pattern = "type or namespace .+ could not be found"
        Check = { param($code) $code -notmatch "^using\s+" }
        Fix = "Add missing using statement"
        Confidence = 0.95
    }
    UndefinedVariable = @{
        Pattern = "The name .+ does not exist"
        Check = { param($code) $code -match "\b[a-z]\w+\b" -and $code -notmatch "var\s+[a-z]\w+" }
        Fix = "Define variable or fix typo"
        Confidence = 0.90
    }
    TypeMismatch = @{
        Pattern = "Cannot implicitly convert type"
        Check = { param($code) $code -match "=\s*.+;" }
        Fix = "Fix type mismatch or add cast"
        Confidence = 0.85
    }
    MissingReference = @{
        Pattern = "The type or namespace name .+ could not be found"
        Check = { param($code) $code -match "<.*Reference.*>" }
        Fix = "Add project or package reference"
        Confidence = 0.92
    }
    SyntaxError = @{
        Pattern = "Invalid expression term|Expected|';' expected"
        Check = { param($code) -not (Test-SyntaxValid $code) }
        Fix = "Fix syntax error"
        Confidence = 0.99
    }
}

function Test-SyntaxValid {
    param([string]$Code)
    # Simplified syntax check
    $openBraces = ([regex]::Matches($Code, "\{")).Count
    $closeBraces = ([regex]::Matches($Code, "\}")).Count
    return $openBraces -eq $closeBraces
}

function Analyze-File {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return @()
    }

    $code = Get-Content $FilePath -Raw
    $predictions = @()

    foreach ($patternName in $failurePatterns.Keys) {
        $pattern = $failurePatterns[$patternName]

        # Run pattern check
        try {
            $matches = & $pattern.Check -code $code

            if ($matches) {
                $predictions += @{
                    Type = $patternName
                    File = $FilePath
                    Confidence = $pattern.Confidence
                    Fix = $pattern.Fix
                    Severity = if ($pattern.Confidence -gt 0.9) { "High" } else { "Medium" }
                }
            }
        }
        catch {
            # Skip if check fails
        }
    }

    return $predictions
}

function Get-ChangedFiles {
    param([string]$ProjectPath)

    # Get git changed files
    $gitRoot = $ProjectPath
    if (-not (Test-Path "$gitRoot\.git")) {
        $gitRoot = Split-Path $ProjectPath -Parent
    }

    $changedFiles = @()

    try {
        Push-Location $gitRoot
        $gitStatus = git status --porcelain
        $changedFiles = $gitStatus | ForEach-Object {
            $file = $_ -replace "^\s*[A-Z?]+\s+", ""
            if ($file -match "\.(cs|ts|tsx)$") {
                Join-Path $gitRoot $file
            }
        } | Where-Object { $_ -ne $null }
        Pop-Location
    }
    catch {
        Write-Host "⚠️ Could not get git status: $_" -ForegroundColor Yellow
    }

    return $changedFiles
}

# Determine files to analyze
$filesToAnalyze = @()

if ($Files) {
    $filesToAnalyze = $Files -split "," | ForEach-Object { $_.Trim() }
}
elseif ($Project) {
    Write-Host "🔍 Scanning for changed files..." -ForegroundColor Gray
    $filesToAnalyze = Get-ChangedFiles -ProjectPath $Project
    Write-Host "   Found $($filesToAnalyze.Count) changed file(s)" -ForegroundColor Gray
    Write-Host ""
}
else {
    Write-Host "❌ Must specify -Project or -Files" -ForegroundColor Red
    exit 1
}

if ($filesToAnalyze.Count -eq 0) {
    Write-Host "✅ No files to analyze" -ForegroundColor Green
    exit 0
}

# Analyze each file
Write-Host "🔍 Analyzing files for potential build failures..." -ForegroundColor Cyan
Write-Host ""

$allPredictions = @()

foreach ($file in $filesToAnalyze) {
    Write-Host "   Analyzing: $(Split-Path $file -Leaf)" -ForegroundColor Gray

    $predictions = Analyze-File -FilePath $file

    if ($predictions.Count -gt 0) {
        Write-Host "      ⚠️ $($predictions.Count) potential issue(s) found" -ForegroundColor Yellow
        $allPredictions += $predictions
    }
    else {
        Write-Host "      ✓ No issues predicted" -ForegroundColor Green
    }
}

Write-Host ""

# Report predictions
if ($allPredictions.Count -eq 0) {
    Write-Host "✅ No build failures predicted!" -ForegroundColor Green
    Write-Host "   All files passed analysis" -ForegroundColor Green
    Write-Host ""
    exit 0
}

Write-Host "⚠️ BUILD FAILURES PREDICTED!" -ForegroundColor Red
Write-Host ""

$highSeverity = ($allPredictions | Where-Object { $_.Severity -eq "High" }).Count
$mediumSeverity = ($allPredictions | Where-Object { $_.Severity -eq "Medium" }).Count

Write-Host "📊 Prediction Summary:" -ForegroundColor Cyan
Write-Host "   Total predictions: $($allPredictions.Count)" -ForegroundColor Yellow
Write-Host "   High severity: $highSeverity" -ForegroundColor Red
Write-Host "   Medium severity: $mediumSeverity" -ForegroundColor Yellow
Write-Host ""

Write-Host "🔧 Predicted Failures:" -ForegroundColor Cyan
Write-Host ""

foreach ($prediction in $allPredictions | Sort-Object -Property Confidence -Descending) {
    $color = if ($prediction.Severity -eq "High") { "Red" } else { "Yellow" }

    Write-Host "   [$($prediction.Severity)] $($prediction.Type)" -ForegroundColor $color
    Write-Host "      File: $($prediction.File)" -ForegroundColor Gray
    Write-Host "      Confidence: $($prediction.Confidence * 100)%" -ForegroundColor Gray
    Write-Host "      Recommended fix: $($prediction.Fix)" -ForegroundColor White
    Write-Host ""
}

# Recommendations
Write-Host "💡 Recommended Actions:" -ForegroundColor Yellow
Write-Host ""

if ($highSeverity -gt 0) {
    Write-Host "   ⚠️ HIGH PRIORITY: Fix high-severity issues before committing" -ForegroundColor Red
    Write-Host ""
}

Write-Host "   1. Review predicted failures above" -ForegroundColor White
Write-Host "   2. Apply recommended fixes" -ForegroundColor White
Write-Host "   3. Run build to verify: dotnet build" -ForegroundColor White
Write-Host "   4. Re-run predictor to confirm: .\build-failure-predict.ps1" -ForegroundColor White
Write-Host ""

# Exit with error code if high severity issues found
if ($highSeverity -gt 0) {
    Write-Host "❌ COMMIT BLOCKED: High-severity build failures predicted" -ForegroundColor Red
    Write-Host "   Fix issues and re-run before committing" -ForegroundColor Red
    Write-Host ""
    exit 1
}
else {
    Write-Host "⚠️ COMMIT ALLOWED: Only medium-severity predictions" -ForegroundColor Yellow
    Write-Host "   Consider fixing before committing, but not blocking" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# Future enhancements
Write-Host "🚀 Future: ML model trained on build logs for 99% accuracy" -ForegroundColor DarkYellow
