<#
.SYNOPSIS
    Evolve optimal prompts using hybrid genetic algorithms

.DESCRIPTION
    Uses a two-phase approach to evolve effective prompts:
    - Phase 1: Fast component-based genetic evolution
    - Phase 2: LLM-assisted refinement of top candidates

    Requires test cases in JSON format to evaluate prompt quality.

.PARAMETER TestCasesPath
    Path to JSON file containing test cases
    Format: [{"input": "...", "expected_output": "...", "weight": 1.0}, ...]

.PARAMETER PopulationSize
    Number of prompts in each generation (default: 20)

.PARAMETER Generations
    Number of generations for Phase 1 evolution (default: 20)

.PARAMETER TopK
    Number of top prompts to refine in Phase 2 (default: 5)

.PARAMETER OutputPath
    Where to save evolution results (default: prompt_evolution_result.json)

.EXAMPLE
    prompt-evolver.ps1 -TestCasesPath "test_cases.json"

.EXAMPLE
    prompt-evolver.ps1 -TestCasesPath "test_cases.json" -Generations 30 -TopK 3

.EXAMPLE
    # Create test cases file first
    @(
        @{input="Text to summarize"; expected_output="Expected summary"; weight=1.0}
    ) | ConvertTo-Json | Out-File "test_cases.json"

    prompt-evolver.ps1 -TestCasesPath "test_cases.json"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TestCasesPath,

    [Parameter()]
    [int]$PopulationSize = 20,

    [Parameter()]
    [int]$Generations = 20,

    [Parameter()]
    [int]$TopK = 5,

    [Parameter()]
    [string]$OutputPath = "prompt_evolution_result.json"
)

$ErrorActionPreference = "Stop"

# Validate test cases file
if (!(Test-Path $TestCasesPath)) {
    Write-Error "Test cases file not found: $TestCasesPath"
    exit 1
}

# Check for Python
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (!$pythonCmd) {
    Write-Error "Python not found. Please install Python 3.8+"
    exit 1
}

# Path to evolution script
$evolverScript = Join-Path $PSScriptRoot "prompt-evolution\evolver.py"
if (!(Test-Path $evolverScript)) {
    Write-Error "Evolution script not found: $evolverScript"
    exit 1
}

# Create temporary runner script
$runnerScript = @"
import asyncio
import json
import sys
from pathlib import Path

# Add evolver to path
sys.path.insert(0, r'$($PSScriptRoot)\prompt-evolution')

from evolver import PromptEvolver, TestCase

async def main():
    # Load test cases
    with open(r'$TestCasesPath', 'r') as f:
        test_data = json.load(f)

    test_cases = [
        TestCase(
            input=tc['input'],
            expected_output=tc['expected_output'],
            weight=tc.get('weight', 1.0)
        )
        for tc in test_data
    ]

    # Run evolution
    evolver = PromptEvolver(test_cases)
    result = await evolver.evolve(
        population_size=$PopulationSize,
        phase1_generations=$Generations,
        top_k=$TopK
    )

    # Save results
    with open(r'$OutputPath', 'w') as f:
        json.dump(result, f, indent=2)

    print(f'\n💾 Results saved to: $OutputPath')

if __name__ == '__main__':
    asyncio.run(main())
"@

$tempRunner = Join-Path $env:TEMP "prompt_evolver_runner.py"
$runnerScript | Out-File -FilePath $tempRunner -Encoding UTF8

try {
    # Run evolution
    Write-Host "🚀 Starting Prompt Evolution" -ForegroundColor Cyan
    Write-Host "   Test Cases: $TestCasesPath" -ForegroundColor Gray
    Write-Host "   Population: $PopulationSize" -ForegroundColor Gray
    Write-Host "   Generations: $Generations" -ForegroundColor Gray
    Write-Host "   Top-K: $TopK" -ForegroundColor Gray
    Write-Host ""

    & python $tempRunner

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Evolution failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }

    # Display results
    if (Test-Path $OutputPath) {
        Write-Host "`n📊 Evolution Results:" -ForegroundColor Green
        $results = Get-Content $OutputPath | ConvertFrom-Json

        Write-Host "`n🏆 Best Prompt (Score: $($results.best_score)):" -ForegroundColor Yellow
        Write-Host $results.best_prompt -ForegroundColor White

        Write-Host "`n🥈 Other Top Candidates:" -ForegroundColor Yellow
        for ($i = 1; $i -lt [Math]::Min(3, $results.all_candidates.Count); $i++) {
            $candidate = $results.all_candidates[$i]
            Write-Host "  #$($i + 1) (Score: $($candidate.score)):" -ForegroundColor Gray
            Write-Host "  $($candidate.prompt)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
finally {
    # Cleanup
    if (Test-Path $tempRunner) {
        Remove-Item $tempRunner -Force
    }
}
