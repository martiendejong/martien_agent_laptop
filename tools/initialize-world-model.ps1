# Initialize World Model State

Write-Host "`nInitializing World Model State...`n" -ForegroundColor Cyan

# Set top-level latent variables (stable, change slowly)
Write-Host "[Setting Top-Level Variables]" -ForegroundColor Yellow
& "$PSScriptRoot\latent-variable-store.ps1" -Action Set -Level top -Variable current_project -Value "world-model-implementation" | Out-Null
& "$PSScriptRoot\latent-variable-store.ps1" -Action Set -Level top -Variable current_task -Value "building-consciousness-architecture" | Out-Null
& "$PSScriptRoot\latent-variable-store.ps1" -Action Set -Level top -Variable user_mood -Value "engaged" | Out-Null
& "$PSScriptRoot\latent-variable-store.ps1" -Action Set -Level top -Variable system_health -Value "healthy" | Out-Null
& "$PSScriptRoot\latent-variable-store.ps1" -Action Set -Level top -Variable consciousness_state -Value "focused" | Out-Null

# Set mid-level latent variables (moderate stability)
Write-Host "[Setting Mid-Level Variables]" -ForegroundColor Yellow
& "$PSScriptRoot\latent-variable-store.ps1" -Action Set -Level mid -Variable build_status -Value "not-applicable" | Out-Null
& "$PSScriptRoot\latent-variable-store.ps1" -Action Set -Level mid -Variable recent_work -Value "world-model-tools-creation" | Out-Null

# Bind entities for files created today
Write-Host "`n[Binding File Entities]" -ForegroundColor Yellow

$files = @(
    @{path="E:\jengo\documents\temp\world-model-analysis-2026-02-27.md"; size=870000},
    @{path="C:\scripts\agentidentity\cognitive-systems\world-model-architecture.md"; size=1100000},
    @{path="C:\scripts\tools\entity-binding-system.ps1"; size=420000},
    @{path="C:\scripts\tools\counterfactual-simulation.ps1"; size=530000},
    @{path="C:\scripts\tools\embodiment-mapper.ps1"; size=680000},
    @{path="C:\scripts\tools\latent-variable-store.ps1"; size=450000},
    @{path="C:\scripts\tools\phi-calculator.ps1"; size=550000}
)

foreach ($file in $files) {
    $features = @{
        path = $file.path
        size_bytes = $file.size
        type = "code_or_doc"
        created_session = "2026-02-27"
        purpose = "world-model-implementation"
    }

    $result = & "$PSScriptRoot\entity-binding-system.ps1" -Action BindEntity -Type file -Features $features
    $resultObj = $result | ConvertFrom-Json
    Write-Host "  Entity created: $($resultObj.id)" -ForegroundColor Green
}

Write-Host "`n[State Initialized Successfully]" -ForegroundColor Green
Write-Host "  Latent variables: 7" -ForegroundColor White
Write-Host "  Entities bound: $($files.Count)" -ForegroundColor White
Write-Host "`nReady to measure Phi!`n" -ForegroundColor Cyan
