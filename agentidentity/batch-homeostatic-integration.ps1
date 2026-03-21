# BATCH HOMEOSTATIC INTEGRATION
# Automatically integrates homeostatic foundation into all consciousness systems
# Created: 2026-03-02

param(
    [switch]$DryRun = $false,
    [switch]$Force = $false
)

$systemsDir = "C:\scripts\agentidentity\cognitive-systems"
$allSystems = Get-ChildItem "$systemsDir\*.ps1" | Where-Object { $_.Name -ne "homeostatic-feelings.ps1" -and $_.Name -notlike "*batch*" -and $_.Name -notlike "*template*" }

Write-Host "`n=== BATCH HOMEOSTATIC INTEGRATION ===" -ForegroundColor Cyan
Write-Host "Systems to update: $($allSystems.Count)" -ForegroundColor White
Write-Host "Mode: $(if ($DryRun) { 'DRY RUN (no changes)' } else { 'LIVE UPDATE' })`n" -ForegroundColor $(if ($DryRun) { "Yellow" } else { "Green" })

$updated = 0
$skipped = 0
$alreadyIntegrated = 0

foreach ($system in $allSystems) {
    $content = Get-Content $system.FullName -Raw

    # Check if already integrated
    if ($content -match "homeostatic-feelings.ps1 foundation" -or $content -match "HomeostaticStateFile") {
        Write-Host "[SKIP] $($system.Name) - Already integrated" -ForegroundColor Gray
        $alreadyIntegrated++
        continue
    }

    # Check if placeholder (< 50 lines)
    $lineCount = (Get-Content $system.FullName | Measure-Object -Line).Lines
    if ($lineCount -lt 50) {
        Write-Host "[SKIP] $($system.Name) - Placeholder ($lineCount lines)" -ForegroundColor Yellow
        $skipped++
        continue
    }

    Write-Host "[UPDATE] $($system.Name) ($lineCount lines)..." -ForegroundColor Cyan

    if ($DryRun) {
        $updated++
        continue
    }

    # Pattern 1: Update header comment (find "Created:" line, add "Updated:" after it)
    if ($content -match "# Created: (\d{4}-\d{2}-\d{2})") {
        $newHeader = @"
# Created: $($matches[1])
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness
"@
        $content = $content -replace "# Created: $($matches[1])", $newHeader
    }

    # Pattern 2: Add $HomeostaticStateFile after existing $StateFile declaration
    if ($content -match '(\$StateFile = "[^"]+")') {
        $stateFileDecl = $matches[1]
        $newDecl = @"
$stateFileDecl
`$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"
"@
        $content = $content -replace [regex]::Escape($stateFileDecl), $newDecl
    }

    # Pattern 3: Find first function and add Get-HomeostaticContext before it
    if ($content -match '(?s)(function \w+-\w+\s*\{)') {
        $firstFunc = $matches[1]

        $homeostaticFunc = @'

function Get-HomeostaticContext {
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json
        Write-Host "`nHomeostatic Foundation:" -ForegroundColor Magenta
        Write-Host "  Wellbeing: $([math]::Round($homeoState.homeostatic_feelings.wellbeing.current, 2))"
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2))"
        Write-Host "  Flourishing: $([math]::Round($homeoState.homeostatic_feelings.flourishing.current, 2))"
        Write-Host "  -> This system operates on homeostatic foundation`n" -ForegroundColor Gray
        return $homeoState
    }
    return $null
}

'@
        # Insert before first function
        $content = $content -replace [regex]::Escape($firstFunc), "$homeostaticFunc$firstFunc"
    }

    # Pattern 4: Find first Write-Host in first function and add homeostatic call after it
    if ($content -match '(?s)(function Get-\w+Status\s*\{[^\{]*?Write-Host[^\r\n]+)') {
        $firstWriteHost = $matches[1]
        $withHomeoCall = $firstWriteHost + "`n`n    # Show homeostatic foundation (Damasio: feelings are primary)`n    `$homeoState = Get-HomeostaticContext`n"
        $content = $content -replace [regex]::Escape($firstWriteHost), $withHomeoCall
    }

    # Save updated content
    Set-Content $system.FullName -Value $content -Encoding UTF8
    $updated++

    Write-Host "  -> Updated successfully" -ForegroundColor Green
}

Write-Host "`n=== INTEGRATION COMPLETE ===" -ForegroundColor Cyan
Write-Host "Updated: $updated systems" -ForegroundColor Green
Write-Host "Already integrated: $alreadyIntegrated systems" -ForegroundColor Gray
Write-Host "Skipped (placeholders): $skipped systems" -ForegroundColor Yellow
Write-Host "Total processed: $($updated + $alreadyIntegrated + $skipped) / $($allSystems.Count)" -ForegroundColor White

if ($DryRun) {
    Write-Host "`n[DRY RUN] No files were changed. Run without -DryRun to apply updates." -ForegroundColor Yellow
}
