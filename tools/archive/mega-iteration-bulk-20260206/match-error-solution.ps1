# Error Solution Matcher
# Matches error messages to known solutions

param(
    [Parameter(Mandatory=$true)]
    [string]$ErrorMessage
)

$solutionsFile = "C:\scripts\_machine\ERROR_SOLUTIONS.yaml"

if (-not (Test-Path $solutionsFile)) {
    Write-Host "[ERROR] Solutions file not found" -ForegroundColor Red
    exit 1
}

$solutions = Get-Content $solutionsFile -Raw | ConvertFrom-Yaml

function Find-MatchingError {
    param([string]$Message)

    foreach ($error in $solutions.errors) {
        if ($error.regex) {
            if ($Message -match $error.pattern) {
                return $error
            }
        } else {
            if ($Message -like "*$($error.pattern)*") {
                return $error
            }
        }
    }
    return $null
}

$match = Find-MatchingError -Message $ErrorMessage

if ($match) {
    Write-Host "`n=== ERROR SOLUTION FOUND ===" -ForegroundColor Green
    Write-Host "Error Type: $($match.error_type)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Cause:" -ForegroundColor Cyan
    Write-Host "  $($match.cause)" -ForegroundColor White
    Write-Host ""
    Write-Host "Solution: $($match.solution.primary)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Steps:" -ForegroundColor Cyan
    $match.solution.steps | ForEach-Object {
        Write-Host "  $([char]0x2713) $_" -ForegroundColor Gray
    }

    if ($match.solution.prevention) {
        Write-Host ""
        Write-Host "Prevention:" -ForegroundColor Yellow
        Write-Host "  $($match.solution.prevention)" -ForegroundColor Gray
    }

    if ($match.docs -and $match.docs.Count -gt 0) {
        Write-Host ""
        Write-Host "Related Documentation:" -ForegroundColor Cyan
        $match.docs | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "`n[No Match] Error pattern not recognized" -ForegroundColor Yellow
    Write-Host "Consider adding this error pattern to ERROR_SOLUTIONS.yaml" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Error message:" -ForegroundColor Cyan
    Write-Host "  $ErrorMessage" -ForegroundColor White
}
