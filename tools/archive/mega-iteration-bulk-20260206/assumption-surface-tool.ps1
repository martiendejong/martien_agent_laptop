# assumption-surface-tool.ps1
# Make hidden assumptions visible before acting on them

param(
    [Parameter(Mandatory=$true)]
    [string]$ProposedAction,

    [string[]]$Assumptions = @(),

    [switch]$Challenge
)

# Common assumption patterns to detect
$assumptionPatterns = @{
    'branch' = @{
        pattern = 'branch|checkout|merge|rebase'
        common_assumptions = @(
            'Assuming current branch is correct'
            'Assuming no uncommitted changes'
            'Assuming branch exists'
        )
        checks = @{
            'Current branch' = 'git branch --show-current'
            'Uncommitted changes' = 'git status --short'
            'Branch exists' = 'git branch --list TARGET'
        }
    }
    'build' = @{
        pattern = 'build|compile|npm|dotnet'
        common_assumptions = @(
            'Assuming dependencies installed'
            'Assuming correct Node version'
            'Assuming environment configured'
        )
        checks = @{
            'Node modules' = 'Test-Path node_modules'
            'NuGet packages' = 'Test-Path packages'
            'Env variables' = '$env:NODE_ENV'
        }
    }
    'file' = @{
        pattern = 'read|write|edit|delete|move'
        common_assumptions = @(
            'Assuming file exists'
            'Assuming file is not locked'
            'Assuming path is correct'
        )
        checks = @{
            'File exists' = 'Test-Path TARGET'
            'File writable' = 'Test file not locked'
        }
    }
    'worktree' = @{
        pattern = 'worktree|allocate|agent-\d+'
        common_assumptions = @(
            'Assuming seat is FREE'
            'Assuming no conflicts'
            'Assuming repo exists'
        )
        checks = @{
            'Pool status' = 'Get-Content worktrees.pool.md'
            'Conflicts' = 'Check MULTI_AGENT_CONFLICT_DETECTION'
        }
    }
}

# Detect which category
$detectedCategory = $null
foreach ($category in $assumptionPatterns.Keys) {
    if ($ProposedAction -match $assumptionPatterns[$category].pattern) {
        $detectedCategory = $category
        break
    }
}

Write-Host "`n🔍 ASSUMPTION SURFACE ANALYSIS" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "Proposed Action: " -NoNewline -ForegroundColor Gray
Write-Host $ProposedAction -ForegroundColor White

if ($detectedCategory) {
    Write-Host "Category: " -NoNewline -ForegroundColor Gray
    Write-Host $detectedCategory -ForegroundColor Yellow

    $categoryInfo = $assumptionPatterns[$detectedCategory]

    Write-Host "`nCommon Assumptions for '$detectedCategory' operations:" -ForegroundColor Cyan
    foreach ($assumption in $categoryInfo.common_assumptions) {
        $isExplicit = $false
        foreach ($userAssumption in $Assumptions) {
            if ($userAssumption -match [regex]::Escape($assumption.Split('Assuming ')[1])) {
                $isExplicit = $true
                break
            }
        }

        if ($isExplicit) {
            Write-Host "  ✅ " -NoNewline -ForegroundColor Green
            Write-Host $assumption -ForegroundColor Gray
            Write-Host "     (Explicitly stated)" -ForegroundColor DarkGray
        } else {
            Write-Host "  ⚠️  " -NoNewline -ForegroundColor Yellow
            Write-Host $assumption -ForegroundColor Yellow
            Write-Host "     (IMPLICIT - not verified)" -ForegroundColor Red
        }
    }

    if ($Challenge) {
        Write-Host "`n🧪 VERIFICATION CHECKS:" -ForegroundColor Cyan
        foreach ($checkName in $categoryInfo.checks.Keys) {
            $checkCommand = $categoryInfo.checks[$checkName]
            Write-Host "  • $checkName" -NoNewline -ForegroundColor White
            Write-Host " → " -NoNewline -ForegroundColor DarkGray
            Write-Host $checkCommand -ForegroundColor Gray
        }
    }
} else {
    Write-Host "Category: " -NoNewline -ForegroundColor Gray
    Write-Host "Generic" -ForegroundColor DarkGray
}

if ($Assumptions.Count -gt 0) {
    Write-Host "`nExplicit Assumptions Provided:" -ForegroundColor Cyan
    foreach ($assumption in $Assumptions) {
        Write-Host "  • " -NoNewline -ForegroundColor DarkGray
        Write-Host $assumption -ForegroundColor Green
    }
} else {
    Write-Host "`n⚠️  No explicit assumptions provided" -ForegroundColor Yellow
    Write-Host "   Consider what you're assuming about:" -ForegroundColor Gray
    Write-Host "   - Current state (branch, directory, mode)" -ForegroundColor DarkGray
    Write-Host "   - Preconditions (files exist, deps installed)" -ForegroundColor DarkGray
    Write-Host "   - Environment (permissions, config)" -ForegroundColor DarkGray
}

Write-Host "`n💡 RECOMMENDATION:" -ForegroundColor Cyan
if ($detectedCategory -and $Assumptions.Count -eq 0) {
    Write-Host "  Before executing, verify common assumptions for '$detectedCategory' operations" -ForegroundColor Yellow
} elseif ($Assumptions.Count -gt 0) {
    Write-Host "  Verify each assumption before proceeding" -ForegroundColor Green
} else {
    Write-Host "  List your assumptions explicitly, then verify them" -ForegroundColor Yellow
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

# Log for learning
$logEntry = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    proposed_action = $ProposedAction
    category = $detectedCategory
    explicit_assumptions = $Assumptions
    implicit_assumptions = if ($detectedCategory) { $assumptionPatterns[$detectedCategory].common_assumptions } else { @() }
}

$logPath = "C:\scripts\agentidentity\state\assumption-log.yaml"
if (Test-Path $logPath) {
    $log = Get-Content $logPath -Raw | ConvertFrom-Yaml
    $log.entries += $logEntry
    # Keep last 50
    if ($log.entries.Count -gt 50) {
        $log.entries = $log.entries[-50..-1]
    }
} else {
    $log = @{
        metadata = @{
            created = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            purpose = "Track assumptions to learn patterns"
        }
        entries = @($logEntry)
    }
}

$log | ConvertTo-Yaml | Out-File -FilePath $logPath -Encoding UTF8

Write-Output "`nLogged to: $logPath"
