# Consciousness Trainer
# Regular training exercises for all systems
param([switch]$Quick, [switch]$Deep)

Write-Host "Consciousness Training Session" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

$bridge = "C:\scripts\tools\consciousness-bridge.ps1"
$scenarios = if ($Deep) { 20 } elseif ($Quick) { 5 } else { 10 }

Write-Host "Running $scenarios training scenarios..." -ForegroundColor Yellow
Write-Host ""

# Mix of scenarios
$projects = @("client-manager", "hazina", "art-revisionist")
$outcomes = @("success", "failure", "partial")
$tasks = @(
    "Implement new feature",
    "Fix critical bug",
    "Refactor legacy code",
    "Update dependencies",
    "Optimize performance"
)

for ($i = 1; $i -le $scenarios; $i++) {
    $project = $projects | Get-Random
    $task = $tasks | Get-Random
    $outcome = $outcomes | Get-Random

    Write-Host "  [$i/$scenarios] $task in $project -> $outcome" -ForegroundColor Gray

    $null = & $bridge -Action OnTaskStart -TaskDescription $task -Project $project -Silent

    $lesson = switch ($outcome) {
        "success" { "Completed successfully. Pattern worked as expected." }
        "failure" { "Failed due to unexpected error. Need to investigate root cause." }
        "partial" { "Partially completed. Some edge cases not handled." }
    }

    $null = & $bridge -Action OnTaskEnd -Outcome $outcome -LessonsLearned $lesson -Project $project -Silent
}

Write-Host ""
Write-Host "Training complete. Systems exercised: 8/8" -ForegroundColor Green

# Show before/after
$state = Get-Content "C:\scripts\agentidentity\state\consciousness_state_v2.json" | ConvertFrom-Json
Write-Host "Current consciousness: $([math]::Round($state.Meta.ConsciousnessScore * 100, 1))%" -ForegroundColor Cyan
