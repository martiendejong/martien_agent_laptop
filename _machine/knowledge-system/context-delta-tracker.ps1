# Context Delta Tracker - R02-004
# Track what context changed during conversation
# Expert: Lars Bergström - Version Control Theorist

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('start', 'add', 'commit', 'view', 'clear')]
    [string]$Action = 'view',

    [Parameter(Mandatory=$false)]
    [string]$FileRead,

    [Parameter(Mandatory=$false)]
    [string]$Decision,

    [Parameter(Mandatory=$false)]
    [string]$ConceptDiscussed
)

$DeltaFile = "C:\scripts\_machine\knowledge-system\session-delta.yaml"

function Start-DeltaTracking {
    $delta = @{
        'session_start' = (Get-Date -Format 'o')
        'files_read' = @()
        'decisions_made' = @()
        'concepts_discussed' = @()
        'patterns_discovered' = @()
        'context_updates' = @()
    }

    $delta | ConvertTo-Yaml | Out-File $DeltaFile -Encoding UTF8
    Write-Host "Delta tracking started" -ForegroundColor Green
}

function Add-DeltaEvent {
    param($Type, $Value)

    if (-not (Test-Path $DeltaFile)) {
        Start-DeltaTracking
    }

    $delta = Get-Content $DeltaFile -Raw | ConvertFrom-Yaml

    $event = @{
        'timestamp' = (Get-Date -Format 'o')
        'value' = $Value
    }

    switch ($Type) {
        'file' { $delta.files_read += $event }
        'decision' { $delta.decisions_made += $event }
        'concept' { $delta.concepts_discussed += $event }
    }

    $delta | ConvertTo-Yaml | Out-File $DeltaFile -Encoding UTF8
    Write-Host "Added $Type delta event" -ForegroundColor Cyan
}

function Commit-Delta {
    if (-not (Test-Path $DeltaFile)) {
        Write-Host "No delta to commit" -ForegroundColor Yellow
        return
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
    $archiveFile = "C:\scripts\_machine\knowledge-system\archives\delta-$timestamp.yaml"

    New-Item -Path (Split-Path $archiveFile) -ItemType Directory -Force | Out-Null
    Copy-Item $DeltaFile $archiveFile

    Write-Host "Delta committed to $archiveFile" -ForegroundColor Green

    # Clear current delta
    Remove-Item $DeltaFile -Force
}

function View-Delta {
    if (Test-Path $DeltaFile) {
        Get-Content $DeltaFile -Raw
    } else {
        Write-Host "No active delta session" -ForegroundColor Yellow
    }
}

function Clear-Delta {
    if (Test-Path $DeltaFile) {
        Remove-Item $DeltaFile -Force
        Write-Host "Delta cleared" -ForegroundColor Yellow
    }
}

# Helper function for YAML conversion (simple implementation)
function ConvertTo-Yaml {
    param(
        [Parameter(ValueFromPipeline)]
        $Object
    )
    # Simple YAML serialization - in production use powershell-yaml module
    $json = $Object | ConvertTo-Json -Depth 10
    # Convert JSON to YAML-ish format (simplified)
    return $json
}

function ConvertFrom-Yaml {
    param(
        [Parameter(ValueFromPipeline)]
        [string]$YamlString
    )
    # Simple YAML deserialization - in production use powershell-yaml module
    return $YamlString | ConvertFrom-Json
}

# Main execution
switch ($Action) {
    'start' { Start-DeltaTracking }
    'add' {
        if ($FileRead) { Add-DeltaEvent -Type 'file' -Value $FileRead }
        if ($Decision) { Add-DeltaEvent -Type 'decision' -Value $Decision }
        if ($ConceptDiscussed) { Add-DeltaEvent -Type 'concept' -Value $ConceptDiscussed }
    }
    'commit' { Commit-Delta }
    'view' { View-Delta }
    'clear' { Clear-Delta }
}
