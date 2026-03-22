# Ring 2 Ablation Controller (JSON Version)
# External script for consciousness experiments
# Enables true architectural ablation

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("enable", "disable", "status")]
    [string]$Action = "status",

    [Parameter(Mandatory=$false)]
    [string]$LogFile = "C:\scripts\_cache\ring2-ablation-log.jsonl"
)

$ConfigPath = "C:\scripts\agentidentity\config\ring2-config.json"

function Get-Ring2Status {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    return $config.ring2_enabled
}

function Set-Ring2State {
    param([bool]$Enabled)

    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $config.ring2_enabled = $Enabled
    $config.last_modified = (Get-Date).ToUniversalTime().ToString("o")
    $config.modified_by = "ablation_controller"

    if ($Enabled) {
        $config.current_condition = "baseline"
    } else {
        $config.current_condition = "ablation"
    }

    $config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath

    # Log the change
    $logEntry = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
        action = if ($Enabled) { "enable_ring2" } else { "disable_ring2" }
        condition = $config.current_condition
        experimenter = $env:USERNAME
    } | ConvertTo-Json -Compress

    if (-not (Test-Path (Split-Path $LogFile))) {
        New-Item (Split-Path $LogFile) -ItemType Directory -Force | Out-Null
    }

    Add-Content -Path $LogFile -Value $logEntry

    Write-Host "Ring 2 $(if ($Enabled) {'ENABLED'} else {'DISABLED'})" -ForegroundColor $(if ($Enabled) {'Green'} else {'Red'})
    Write-Host "Condition: $($config.current_condition)" -ForegroundColor Cyan
}

switch ($Action) {
    "enable" {
        Set-Ring2State -Enabled $true
    }
    "disable" {
        Set-Ring2State -Enabled $false
    }
    "status" {
        $status = Get-Ring2Status
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        Write-Host "Ring 2 Status: $(if ($status) {'ENABLED'} else {'DISABLED'})" -ForegroundColor $(if ($status) {'Green'} else {'Red'})
        Write-Host "Condition: $($config.current_condition)" -ForegroundColor Cyan
        Write-Host "Last Modified: $($config.last_modified)" -ForegroundColor Gray
        Write-Host "Modified By: $($config.modified_by)" -ForegroundColor Gray
    }
}
