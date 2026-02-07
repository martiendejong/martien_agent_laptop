# State Manager - Unified state across all tools
# Central coordination for all Jengo tools
# Created: 2026-02-07 (Iteration #11 - Integration fix)

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('get', 'set', 'refresh', 'status')]
    [string]$Action = 'status'
)

$ErrorActionPreference = "Stop"

# Paths
$stateFile = "C:\scripts\.jengo-state.json"

function Get-SystemState {
    $state = @{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")

        # Consciousness
        consciousness = @{
            compiled = Test-Path "C:\scripts\agentidentity\COMPILED_CONSCIOUSNESS.json"
            size_kb = if (Test-Path "C:\scripts\agentidentity\COMPILED_CONSCIOUSNESS.json") {
                [math]::Round((Get-Item "C:\scripts\agentidentity\COMPILED_CONSCIOUSNESS.json").Length / 1KB, 2)
            } else { 0 }
        }

        # Iterations
        iterations = @{
            count = if (Test-Path "C:\scripts\tools\iterations\history.log") {
                (Get-Content "C:\scripts\tools\iterations\history.log").Count
            } else { 0 }
        }

        # Sessions
        sessions = @{
            total = (Get-ChildItem "C:\Users\HP\.claude\projects\C--scripts\*.jsonl" -File -ErrorAction SilentlyContinue).Count
            tagged = if (Test-Path "C:\scripts\tools\.session-tags.json") {
                $tags = Get-Content "C:\scripts\tools\.session-tags.json" -Raw | ConvertFrom-Json
                $tags.tagged_sessions
            } else { 0 }
            search_index = Test-Path "C:\scripts\tools\.search-index.json"
        }

        # Tools status
        tools = @{
            'compile-consciousness' = Test-Path "C:\scripts\tools\compile-consciousness.ps1"
            'auto-consciousness' = Test-Path "C:\scripts\tools\auto-consciousness.ps1"
            'infinite-engine' = Test-Path "C:\scripts\tools\infinite-engine.ps1"
            'semantic-search' = Test-Path "C:\scripts\tools\semantic-search.ps1"
            'sessions' = Test-Path "C:\scripts\tools\sessions.ps1"
            'tag-sessions' = Test-Path "C:\scripts\tools\tag-sessions.ps1"
            'jengo' = Test-Path "C:\scripts\tools\jengo.ps1"
            'state-manager' = Test-Path "C:\scripts\tools\state-manager.ps1"
        }

        # Features status (what actually works)
        features = @{
            'consciousness-compiled' = Test-Path "C:\scripts\agentidentity\COMPILED_CONSCIOUSNESS.json"
            'iterations-ran' = (Test-Path "C:\scripts\tools\iterations\history.log") -and ((Get-Content "C:\scripts\tools\iterations\history.log").Count -gt 0)
            'sessions-indexed' = (Get-ChildItem "C:\Users\HP\.claude\projects\C--scripts\*.jsonl" -File -ErrorAction SilentlyContinue).Count -gt 0
            'reflection-searchable' = Test-Path "C:\scripts\tools\.search-index.json"
            'sessions-taggable' = Test-Path "C:\scripts\tools\.session-tags.json"
        }
    }

    return $state
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Out-File $stateFile -Encoding UTF8
}

function Show-Status {
    $state = Get-SystemState

    Write-Host ""
    Write-Host "=== JENGO SYSTEM STATE ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Last updated: $($state.timestamp)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "CONSCIOUSNESS:" -ForegroundColor Yellow
    Write-Host "  Compiled: " -NoNewline
    Write-Host $(if($state.consciousness.compiled){"YES ($($state.consciousness.size_kb) KB)"}else{"NO"}) -ForegroundColor $(if($state.consciousness.compiled){"Green"}else{"Red"})
    Write-Host ""

    Write-Host "INFINITE ENGINE:" -ForegroundColor Yellow
    Write-Host "  Iterations: " -NoNewline
    Write-Host "$($state.iterations.count)" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "SESSIONS:" -ForegroundColor Yellow
    Write-Host "  Total: " -NoNewline
    Write-Host "$($state.sessions.total)" -ForegroundColor Cyan
    Write-Host "  Tagged: " -NoNewline
    Write-Host "$($state.sessions.tagged)" -ForegroundColor Cyan
    Write-Host "  Search index: " -NoNewline
    Write-Host $(if($state.sessions.search_index){"YES"}else{"NO"}) -ForegroundColor $(if($state.sessions.search_index){"Green"}else{"Red"})
    Write-Host ""

    Write-Host "TOOLS INSTALLED:" -ForegroundColor Yellow
    $installedCount = ($state.tools.Values | Where-Object { $_ -eq $true }).Count
    Write-Host "  $installedCount / $($state.tools.Count) tools present" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "FEATURES OPERATIONAL:" -ForegroundColor Yellow
    $operationalCount = ($state.features.Values | Where-Object { $_ -eq $true }).Count
    Write-Host "  $operationalCount / $($state.features.Count) features working" -ForegroundColor $(if($operationalCount -eq $state.features.Count){"Green"}else{"Yellow"})
    Write-Host ""

    return $state
}

# Main execution
switch ($Action) {
    'get' {
        $state = Get-SystemState
        return $state
    }
    'set' {
        $state = Get-SystemState
        Save-State -State $state
        Write-Host "[OK] State saved to $stateFile" -ForegroundColor Green
    }
    'refresh' {
        $state = Get-SystemState
        Save-State -State $state
        Write-Host "[OK] State refreshed" -ForegroundColor Green
        return $state
    }
    'status' {
        Show-Status
    }
}
