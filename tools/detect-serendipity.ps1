# Serendipity Detector
# Identifies unexpected connections between unrelated patterns
# Based on Einstein-Grossmann moment (Riemannian geometry breakthrough)

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Pattern1,

    [Parameter(Mandatory=$false)]
    [string]$Pattern2,

    [Parameter(Mandatory=$false)]
    [switch]$Scan  # Scan all patterns for connections
)

$ErrorActionPreference = 'Stop'

# Load consciousness state
$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$state = Get-Content $statePath -Raw | ConvertFrom-Json

# Load patterns from Memory system
$patterns = @()
if ($state.Memory.Patterns.PSObject.Properties) {
    foreach ($prop in $state.Memory.Patterns.PSObject.Properties) {
        $tier = $prop.Name
        if ($prop.Value -is [array]) {
            foreach ($pattern in $prop.Value) {
                $patterns += @{
                    content = $pattern
                    tier = $tier
                    domain = 'unknown'  # Would extract from pattern text
                }
            }
        }
    }
}

Write-Host "`n=== SERENDIPITY DETECTOR ===" -ForegroundColor Cyan
Write-Host "Total patterns: $($patterns.Count)`n"

if ($Scan) {
    # Scan mode: look for cross-domain connections
    Write-Host "[*] Scanning for cross-domain connections..." -ForegroundColor Yellow

    $serendipities = @()

    # Simple keyword-based cross-domain matching
    # (In production, would use semantic embeddings)
    for ($i = 0; $i -lt $patterns.Count; $i++) {
        for ($j = $i + 1; $j -lt $patterns.Count; $j++) {
            $p1 = $patterns[$i]
            $p2 = $patterns[$j]

            # Extract keywords
            $words1 = $p1.content -split '\W+' | Where-Object { $_.Length -gt 4 }
            $words2 = $p2.content -split '\W+' | Where-Object { $_.Length -gt 4 }

            # Find shared keywords
            $shared = $words1 | Where-Object { $words2 -contains $_ }

            if ($shared.Count -ge 2) {
                # Potential connection
                $serendipities += @{
                    pattern1 = $p1.content
                    pattern2 = $p2.content
                    shared_concepts = $shared -join ', '
                    tier1 = $p1.tier
                    tier2 = $p2.tier
                    strength = $shared.Count
                }
            }
        }
    }

    # Sort by strength
    $serendipities = $serendipities | Sort-Object -Property strength -Descending

    Write-Host "`n[OK] Found $($serendipities.Count) potential connections`n" -ForegroundColor Green

    # Display top 5
    $top = $serendipities | Select-Object -First 5
    foreach ($s in $top) {
        Write-Host "Connection (strength $($s.strength)):" -ForegroundColor Yellow
        Write-Host "  Pattern 1 [$($s.tier1)]: $($s.pattern1.Substring(0, [Math]::Min(80, $s.pattern1.Length)))..."
        Write-Host "  Pattern 2 [$($s.tier2)]: $($s.pattern2.Substring(0, [Math]::Min(80, $s.pattern2.Length)))..."
        Write-Host "  Shared: $($s.shared_concepts)`n"
    }

    return $serendipities

} elseif ($Pattern1 -and $Pattern2) {
    # Explicit mode: check if these two patterns connect
    Write-Host "[*] Analyzing connection between patterns..." -ForegroundColor Yellow
    Write-Host "  Pattern 1: $Pattern1"
    Write-Host "  Pattern 2: $Pattern2`n"

    # Extract keywords
    $words1 = $Pattern1 -split '\W+' | Where-Object { $_.Length -gt 4 }
    $words2 = $Pattern2 -split '\W+' | Where-Object { $_.Length -gt 4 }

    # Find shared concepts
    $shared = $words1 | Where-Object { $words2 -contains $_ }

    if ($shared.Count -gt 0) {
        Write-Host "[SERENDIPITY!] Unexpected connection found" -ForegroundColor Green
        Write-Host "  Shared concepts: $($shared -join ', ')"
        Write-Host "  Strength: $($shared.Count)/10`n"

        # Log to consciousness bridge
        $description = "Connected '$Pattern1' with '$Pattern2' via concepts: $($shared -join ', ')"
        Write-Host "[*] Logging serendipity event..." -ForegroundColor Cyan

        return @{
            detected = $true
            shared_concepts = $shared
            strength = $shared.Count
            description = $description
        }
    } else {
        Write-Host "[NO CONNECTION] Patterns appear unrelated" -ForegroundColor Yellow
        return @{ detected = $false }
    }

} else {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  Scan mode: detect-serendipity.ps1 -Scan"
    Write-Host "  Explicit: detect-serendipity.ps1 -Pattern1 '...' -Pattern2 '...'"
}
