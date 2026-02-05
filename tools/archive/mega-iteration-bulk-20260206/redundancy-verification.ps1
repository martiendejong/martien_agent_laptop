# Redundancy Verification Dashboard
# Verifies every capability has 3-4 fallback methods (each failing differently)
# Part of Round 12: Resilience & Antifragility Framework (#12)

param(
    [string]$Capability,
    [switch]$All
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir

function Test-Capability {
    param(
        [string]$Name,
        [string[]]$Methods,
        [scriptblock[]]$Tests
    )

    Write-Host "`n=== $Name ===" -ForegroundColor Cyan

    $available = @()
    $diversity_score = 0

    for ($i = 0; $i -lt $Methods.Count; $i++) {
        $method = $Methods[$i]
        $test = $Tests[$i]

        Write-Host "  Testing: $method..." -NoNewline

        try {
            $result = & $test
            if ($result) {
                $available += $method
                $diversity_score++
                Write-Host " ✓" -ForegroundColor Green
            }
            else {
                Write-Host " ✗" -ForegroundColor Red
            }
        }
        catch {
            Write-Host " ✗ (Error)" -ForegroundColor Red
        }
    }

    $color = if ($diversity_score -ge 3) { "Green" }
             elseif ($diversity_score -ge 2) { "Yellow" }
             else { "Red" }

    Write-Host "  Diversity Score: $diversity_score/$($Methods.Count)" -ForegroundColor $color

    return @{
        name = $Name
        methods_available = $available
        diversity_score = $diversity_score
        total_methods = $Methods.Count
        status = if ($diversity_score -ge 3) { "RESILIENT" }
                 elseif ($diversity_score -ge 2) { "MINIMAL" }
                 else { "VULNERABLE" }
    }
}

# Define capabilities and their fallback methods
$capabilities = @{
    "Documentation Lookup" = @{
        methods = @(
            "suggest-related tool",
            "Ripgrep search",
            "Quick reference",
            "File system scan"
        )
        tests = @(
            { Test-Path "$scriptDir\suggest-related.ps1" },
            { Get-Command rg -ErrorAction SilentlyContinue },
            { Test-Path "$rootDir\QUICK_REFERENCE.md" },
            { Test-Path $rootDir }
        )
    }

    "Code Editing" = @{
        methods = @(
            "Direct file I/O",
            "Git worktree",
            "VSCode API"
        )
        tests = @(
            { Test-Path "$rootDir\CLAUDE.md" },
            { git worktree list 2>$null; $LASTEXITCODE -eq 0 },
            { Get-Command code -ErrorAction SilentlyContinue }
        )
    }

    "Testing" = @{
        methods = @(
            "dotnet test CLI",
            "Manual script execution"
        )
        tests = @(
            { Get-Command dotnet -ErrorAction SilentlyContinue },
            { $true }  # Always available
        )
    }

    "Environment State Detection" = @{
        methods = @(
            "Git status",
            "Process check",
            "File system scan"
        )
        tests = @(
            { git status 2>$null; $LASTEXITCODE -eq 0 },
            { Get-Process devenv -ErrorAction SilentlyContinue },
            { Test-Path $env:USERPROFILE }
        )
    }

    "Worktree Allocation" = @{
        methods = @(
            "allocate-worktree.ps1",
            "Manual git worktree",
            "Direct clone"
        )
        tests = @(
            { Test-Path "$scriptDir\allocate-worktree.ps1" },
            { git worktree 2>$null; $LASTEXITCODE -eq 0 },
            { Get-Command git -ErrorAction SilentlyContinue }
        )
    }

    "Build Validation" = @{
        methods = @(
            "dotnet build",
            "MSBuild"
        )
        tests = @(
            { Get-Command dotnet -ErrorAction SilentlyContinue },
            { Get-Command msbuild -ErrorAction SilentlyContinue }
        )
    }

    "Dependency Resolution" = @{
        methods = @(
            "dotnet restore",
            "npm install",
            "NuGet CLI"
        )
        tests = @(
            { Get-Command dotnet -ErrorAction SilentlyContinue },
            { Get-Command npm -ErrorAction SilentlyContinue },
            { Get-Command nuget -ErrorAction SilentlyContinue }
        )
    }

    "PR Creation" = @{
        methods = @(
            "gh CLI",
            "Manual git push + web UI"
        )
        tests = @(
            { Get-Command gh -ErrorAction SilentlyContinue },
            { Get-Command git -ErrorAction SilentlyContinue }
        )
    }
}

# Main execution
if ($Capability -and $capabilities.ContainsKey($Capability)) {
    $cap = $capabilities[$Capability]
    Test-Capability -Name $Capability -Methods $cap.methods -Tests $cap.tests
}
else {
    Write-Host "`n=== REDUNDANCY VERIFICATION DASHBOARD ===" -ForegroundColor Cyan

    $results = @()

    foreach ($capName in $capabilities.Keys) {
        $cap = $capabilities[$capName]
        $result = Test-Capability -Name $capName -Methods $cap.methods -Tests $cap.tests
        $results += $result
    }

    # Summary
    Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan

    $resilient = ($results | Where-Object { $_.status -eq "RESILIENT" }).Count
    $minimal = ($results | Where-Object { $_.status -eq "MINIMAL" }).Count
    $vulnerable = ($results | Where-Object { $_.status -eq "VULNERABLE" }).Count

    Write-Host "Resilient (3+ methods): $resilient" -ForegroundColor Green
    Write-Host "Minimal (2 methods): $minimal" -ForegroundColor Yellow
    Write-Host "Vulnerable (0-1 methods): $vulnerable" -ForegroundColor Red

    if ($vulnerable -gt 0) {
        Write-Host "`nWARNING: $vulnerable capabilities have single points of failure" -ForegroundColor Red
    }
    else {
        Write-Host "`nAll capabilities have redundancy ✓" -ForegroundColor Green
    }
}
