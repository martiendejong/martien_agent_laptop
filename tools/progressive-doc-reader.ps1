# Progressive Documentation Reader
# Implements progressive disclosure: Essential → Tactical → Strategic → Deep Dive
# Part of Round 11: Cognitive Load Optimization Framework

param(
    [Parameter(Mandatory=$true)]
    [string]$File,

    [ValidateSet("Essential", "Tactical", "Strategic", "DeepDive", "All")]
    [string]$Layer = "Essential",

    [switch]$Interactive
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir

function Get-ProgressiveLayers {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        Write-Host "File not found: $FilePath" -ForegroundColor Red
        return $null
    }

    $content = Get-Content $FilePath -Raw

    # Parse markdown headers to identify layers
    $layers = @{
        Essential = @()
        Tactical = @()
        Strategic = @()
        DeepDive = @()
    }

    # Look for progressive disclosure markers
    # Essential: ## headers, TL;DR sections, Quick Start
    # Tactical: ### headers, How-to guides
    # Strategic: #### headers, Best Practices, Architecture
    # DeepDive: ##### headers and below, Implementation Details

    $lines = Get-Content $FilePath

    $currentLayer = "Essential"
    $currentSection = ""

    foreach ($line in $lines) {
        # Detect layer markers
        if ($line -match "^##\s+(.+)$") {
            # Level 2 header = Essential
            $currentLayer = "Essential"
            $currentSection = $matches[1]
        }
        elseif ($line -match "^###\s+(.+)$") {
            # Level 3 header = Tactical
            $currentLayer = "Tactical"
            $currentSection = $matches[1]
        }
        elseif ($line -match "^####\s+(.+)$") {
            # Level 4 header = Strategic
            $currentLayer = "Strategic"
            $currentSection = $matches[1]
        }
        elseif ($line -match "^#####\s+(.+)$") {
            # Level 5+ header = DeepDive
            $currentLayer = "DeepDive"
            $currentSection = $matches[1]
        }

        # Special markers
        if ($line -match "TL;DR|Quick Start|Overview|Summary") {
            $currentLayer = "Essential"
        }
        elseif ($line -match "How to|Usage|Examples|Common Workflows") {
            $currentLayer = "Tactical"
        }
        elseif ($line -match "Best Practices|Architecture|Design|Patterns") {
            $currentLayer = "Strategic"
        }
        elseif ($line -match "Implementation|Details|Advanced|Internals") {
            $currentLayer = "DeepDive"
        }

        $layers[$currentLayer] += $line
    }

    return $layers
}

function Show-Layer {
    param(
        [hashtable]$Layers,
        [string]$LayerName,
        [string]$FilePath
    )

    Write-Host "`n=== $($FilePath) ===" -ForegroundColor Cyan
    Write-Host "Layer: $LayerName" -ForegroundColor Yellow
    Write-Host ("=" * 80) -ForegroundColor Gray

    $content = $Layers[$LayerName] -join "`n"

    if ([string]::IsNullOrWhiteSpace($content)) {
        Write-Host "No content found for layer: $LayerName" -ForegroundColor Yellow
        Write-Host "Showing full file..." -ForegroundColor Gray
        Get-Content $FilePath | Write-Host
        return
    }

    Write-Host $content

    Write-Host "`n" -NoNewline
    Write-Host ("=" * 80) -ForegroundColor Gray

    # Show layer navigation
    $layerOrder = @("Essential", "Tactical", "Strategic", "DeepDive")
    $currentIndex = $layerOrder.IndexOf($LayerName)

    if ($currentIndex -lt 3) {
        $nextLayer = $layerOrder[$currentIndex + 1]
        Write-Host "`nNext layer: $nextLayer (use -Layer $nextLayer to view)" -ForegroundColor Green
    }

    # Show token count
    $tokens = [Math]::Round($content.Length / 4)
    Write-Host "Tokens in this layer: ~$tokens" -ForegroundColor Gray
}

function Start-InteractiveReading {
    param([hashtable]$Layers, [string]$FilePath)

    $layerOrder = @("Essential", "Tactical", "Strategic", "DeepDive")
    $currentLayer = 0

    Write-Host "`n=== PROGRESSIVE DOCUMENTATION READER ===" -ForegroundColor Cyan
    Write-Host "File: $FilePath" -ForegroundColor White
    Write-Host "`nControls:" -ForegroundColor Yellow
    Write-Host "  [N]ext layer  [P]revious layer  [J]ump to layer  [Q]uit" -ForegroundColor Gray

    while ($true) {
        Show-Layer -Layers $Layers -LayerName $layerOrder[$currentLayer] -FilePath $FilePath

        Write-Host "`nCommand: " -ForegroundColor Yellow -NoNewline
        $command = Read-Host

        switch ($command.ToUpper()) {
            "N" {
                if ($currentLayer -lt 3) {
                    $currentLayer++
                }
                else {
                    Write-Host "Already at deepest layer" -ForegroundColor Yellow
                }
            }
            "P" {
                if ($currentLayer -gt 0) {
                    $currentLayer--
                }
                else {
                    Write-Host "Already at top layer" -ForegroundColor Yellow
                }
            }
            "J" {
                Write-Host "Jump to layer:" -ForegroundColor Yellow
                Write-Host "  1. Essential" -ForegroundColor White
                Write-Host "  2. Tactical" -ForegroundColor White
                Write-Host "  3. Strategic" -ForegroundColor White
                Write-Host "  4. DeepDive" -ForegroundColor White
                Write-Host "Choice (1-4): " -NoNewline
                $choice = Read-Host
                if ($choice -match "^[1-4]$") {
                    $currentLayer = [int]$choice - 1
                }
            }
            "Q" {
                Write-Host "Goodbye!" -ForegroundColor Green
                return
            }
            default {
                Write-Host "Unknown command. Use N/P/J/Q" -ForegroundColor Red
            }
        }

        Clear-Host
    }
}

# Main execution
$filePath = if ([System.IO.Path]::IsPathRooted($File)) {
    $File
}
else {
    Join-Path $rootDir $File
}

if (-not (Test-Path $filePath)) {
    Write-Host "File not found: $filePath" -ForegroundColor Red
    Write-Host "Tried both absolute and relative to: $rootDir" -ForegroundColor Yellow
    exit 1
}

$layers = Get-ProgressiveLayers -FilePath $filePath

if ($null -eq $layers) {
    exit 1
}

if ($Interactive) {
    Start-InteractiveReading -Layers $layers -FilePath $filePath
}
elseif ($Layer -eq "All") {
    foreach ($layerName in @("Essential", "Tactical", "Strategic", "DeepDive")) {
        Show-Layer -Layers $layers -LayerName $layerName -FilePath $filePath
    }
}
else {
    Show-Layer -Layers $layers -LayerName $Layer -FilePath $filePath
}
