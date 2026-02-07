# Workflow Optimizer - Analyzes patterns and suggests automations
# Created: 2026-02-07

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('analyze', 'suggest')]
    [string]$Action = 'analyze'
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== WORKFLOW OPTIMIZER ===" -ForegroundColor Cyan
Write-Host ""

function Analyze-WorkflowPatterns {
    $markovFile = "C:\scripts\.machine\markov-chain.json"

    if (-not (Test-Path $markovFile)) {
        Write-Host "[ERROR] No prediction data" -ForegroundColor Red
        return
    }

    $markov = Get-Content $markovFile -Raw | ConvertFrom-Json

    Write-Host "Transitions analyzed: $($markov.metadata.transitions_extracted)" -ForegroundColor White
    Write-Host ""

    # Find high-frequency transitions
    Write-Host "High-frequency patterns:" -ForegroundColor Yellow
    Write-Host ""

    $allTransitions = @()
    foreach ($from in $markov.transitions.PSObject.Properties) {
        foreach ($to in $from.Value.PSObject.Properties) {
            if ($to.Value.count -gt 10) {
                $allTransitions += @{
                    from = $from.Name
                    to = $to.Name
                    count = $to.Value.count
                    probability = $to.Value.probability
                }
            }
        }
    }

    $topTransitions = $allTransitions | Sort-Object -Property count -Descending | Select-Object -First 10

    foreach ($t in $topTransitions) {
        $pct = [math]::Round($t.probability * 100, 1)
        Write-Host "  $($t.from) -> $($t.to): $pct% ($($t.count) times)" -ForegroundColor White
    }

    Write-Host ""
}

function Suggest-Automations {
    Write-Host "=== AUTOMATION OPPORTUNITIES ===" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "1. Batch Write Tool" -ForegroundColor Yellow
    Write-Host "   Create multiple files from template in one command" -ForegroundColor Gray
    Write-Host ""

    Write-Host "2. Test After Edit Hook" -ForegroundColor Yellow
    Write-Host "   Automatically run tests after code edits" -ForegroundColor Gray
    Write-Host ""

    Write-Host "3. Find and Fix Tool" -ForegroundColor Yellow
    Write-Host "   Find files by pattern, edit all at once" -ForegroundColor Gray
    Write-Host ""
}

# Main execution
switch ($Action) {
    'analyze' { Analyze-WorkflowPatterns }
    'suggest' { Suggest-Automations }
}

