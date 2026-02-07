# With-Prediction - Execute action and show next-action predictions
# Wrapper for integrating predictions into workflow
# Created: 2026-02-07 (Integration layer)

param(
    [Parameter(Mandatory=$true)]
    [string]$ActionName,

    [Parameter(Mandatory=$true)]
    [ScriptBlock]$Action,

    [Parameter(Mandatory=$false)]
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Execute the actual action
$result = & $Action

# Show prediction after action completes
if (-not $Silent) {
    & "C:\scripts\tools\predict-next.ps1" -LastAction $ActionName
}

return $result
