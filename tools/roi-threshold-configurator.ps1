# roi-threshold-configurator.ps1
# Configure acceptable ROI thresholds for different optimization scenarios

param(
    [ValidateSet('view', 'set', 'reset')]
    [string]$Action = 'view',

    [ValidateSet('critical-path', 'user-facing', 'background', 'admin', 'hot-path')]
    [string]$Scenario,

    [double]$MinimumROI,

    [int]$MaxResponseTimeMs
)

$configPath = "C:\scripts\agentidentity\state\roi-thresholds.yaml"

# Default thresholds
$defaults = @{
    thresholds = @{
        'critical-path' = @{
            minimum_roi = 10.0
            max_response_ms = 1000
            description = "User-facing critical operations (login, checkout, etc.)"
        }
        'user-facing' = @{
            minimum_roi = 5.0
            max_response_ms = 500
            description = "Regular user-facing operations"
        }
        'background' = @{
            minimum_roi = 3.0
            max_response_ms = 10000
            description = "Background processing, batch jobs"
        }
        'admin' = @{
            minimum_roi = 2.0
            max_response_ms = 5000
            description = "Admin-only operations"
        }
        'hot-path' = @{
            minimum_roi = 3.0
            max_response_ms = 50
            description = "Operations called 1000+ times/day"
        }
    }
    metadata = @{
        last_updated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        user_customized = $false
    }
}

# Ensure file exists
if (-not (Test-Path $configPath)) {
    $defaults | ConvertTo-Yaml | Out-File -FilePath $configPath -Encoding UTF8
}

# Read current config
$config = Get-Content $configPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'view' {
        Write-Host "`n⚙️  ROI THRESHOLD CONFIGURATION" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        foreach ($scenario in $config.thresholds.Keys | Sort-Object) {
            $threshold = $config.thresholds[$scenario]
            Write-Host "`n$scenario" -ForegroundColor Yellow
            Write-Host "  Description: " -NoNewline -ForegroundColor Gray
            Write-Host $threshold.description -ForegroundColor White
            Write-Host "  Minimum ROI: " -NoNewline -ForegroundColor Gray
            Write-Host "${($threshold.minimum_roi)}x" -ForegroundColor Green
            Write-Host "  Max Response: " -NoNewline -ForegroundColor Gray
            Write-Host "$($threshold.max_response_ms)ms" -ForegroundColor Green
        }

        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "User Customized: " -NoNewline -ForegroundColor Gray
        Write-Host $config.metadata.user_customized -ForegroundColor $(if ($config.metadata.user_customized) { "Yellow" } else { "DarkGray" })
        Write-Host "Last Updated: " -NoNewline -ForegroundColor Gray
        Write-Host $config.metadata.last_updated -ForegroundColor DarkGray
        Write-Host ""
    }

    'set' {
        if (-not $Scenario) {
            Write-Host "❌ Error: -Scenario required for 'set' action" -ForegroundColor Red
            return
        }

        if (-not $config.thresholds.ContainsKey($Scenario)) {
            Write-Host "❌ Error: Unknown scenario '$Scenario'" -ForegroundColor Red
            Write-Host "Valid scenarios: critical-path, user-facing, background, admin, hot-path" -ForegroundColor Yellow
            return
        }

        $updated = $false

        if ($MinimumROI -gt 0) {
            $config.thresholds[$Scenario].minimum_roi = $MinimumROI
            $updated = $true
            Write-Host "✅ Set $Scenario minimum ROI to ${MinimumROI}x" -ForegroundColor Green
        }

        if ($MaxResponseTimeMs -gt 0) {
            $config.thresholds[$Scenario].max_response_ms = $MaxResponseTimeMs
            $updated = $true
            Write-Host "✅ Set $Scenario max response time to ${MaxResponseTimeMs}ms" -ForegroundColor Green
        }

        if ($updated) {
            $config.metadata.last_updated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $config.metadata.user_customized = $true
            $config | ConvertTo-Yaml | Out-File -FilePath $configPath -Encoding UTF8
            Write-Host "`n💾 Configuration saved" -ForegroundColor Cyan
        } else {
            Write-Host "❌ No changes specified. Use -MinimumROI or -MaxResponseTimeMs" -ForegroundColor Yellow
        }
    }

    'reset' {
        $defaults | ConvertTo-Yaml | Out-File -FilePath $configPath -Encoding UTF8
        Write-Host "✅ ROI thresholds reset to defaults" -ForegroundColor Green
    }
}
