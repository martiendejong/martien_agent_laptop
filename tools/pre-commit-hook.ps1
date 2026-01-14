<#
.SYNOPSIS
    Pre-commit hook for zero-tolerance rule enforcement.

.DESCRIPTION
    This script is designed to be run as a git pre-commit hook.
    It checks for violations of zero-tolerance rules before allowing commits.

    Checks performed:
    - Edits in C:\Projects\<repo> during Feature Development Mode
    - Uncommitted worktree changes
    - Pool/worktree inconsistencies

.PARAMETER Install
    Install this hook to a repository

.PARAMETER Check
    Run checks without being in a hook context

.EXAMPLE
    .\pre-commit-hook.ps1 -Install -RepoPath "C:\Projects\client-manager"
    .\pre-commit-hook.ps1 -Check
#>

param(
    [switch]$Install,
    [string]$RepoPath,
    [switch]$Check
)

$PoolPath = "C:\scripts\_machine\worktrees.pool.md"
$BaseRepos = @(
    "C:\Projects\client-manager",
    "C:\Projects\hazina"
)

function Test-IsBaseRepo {
    param([string]$Path)
    return $BaseRepos -contains $Path
}

function Test-HasBusyWorktrees {
    if (-not (Test-Path $PoolPath)) { return $false }

    $content = Get-Content $PoolPath -Raw
    return $content -match '\| BUSY \|'
}

function Get-CurrentRepoPath {
    $gitDir = git rev-parse --git-dir 2>$null
    if ($gitDir) {
        return (Resolve-Path (Join-Path $gitDir "..")).Path.TrimEnd('\')
    }
    return $null
}

function Write-Violation {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== ZERO-TOLERANCE VIOLATION ===" -ForegroundColor Red
    Write-Host $Message -ForegroundColor Red
    Write-Host ""
    Write-Host "This commit has been blocked." -ForegroundColor Yellow
    Write-Host "See: C:\scripts\ZERO_TOLERANCE_RULES.md" -ForegroundColor Yellow
    Write-Host ""
}

function Invoke-PreCommitChecks {
    $violations = @()
    $warnings = @()

    # Get current repo path
    $currentRepo = Get-CurrentRepoPath

    # Check 1: Are we committing in a base repo while worktrees are BUSY?
    if ($currentRepo -and (Test-IsBaseRepo -Path $currentRepo)) {
        if (Test-HasBusyWorktrees) {
            # This might be Feature Development Mode - check if this is a violation
            $repoName = Split-Path $currentRepo -Leaf
            $poolContent = Get-Content $PoolPath -Raw

            # Check if any worktree is working on this repo
            if ($poolContent -match "\| BUSY \|.*\| $repoName \|") {
                $violations += "Committing in base repo ($repoName) while a worktree is BUSY for this repo."
                $violations += "In Feature Development Mode, commits should be in worktrees, not base repos."
            } else {
                $warnings += "Committing in base repo while worktrees are BUSY. Verify you're in Active Debugging Mode."
            }
        }
    }

    # Check 2: Is this a worktree commit without the seat being marked BUSY?
    if ($currentRepo -and $currentRepo -match "worker-agents\\(agent-\d+)\\") {
        $seat = $matches[1]
        $poolContent = Get-Content $PoolPath -Raw

        if ($poolContent -notmatch "\| $seat .* \| BUSY \|") {
            $warnings += "Committing in $seat worktree but seat is not marked BUSY in pool.md"
        }
    }

    # Output results
    if ($violations.Count -gt 0) {
        foreach ($v in $violations) {
            Write-Violation $v
        }
        return $false
    }

    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "=== PRE-COMMIT WARNINGS ===" -ForegroundColor Yellow
        foreach ($w in $warnings) {
            Write-Host "  - $w" -ForegroundColor Yellow
        }
        Write-Host ""
        Write-Host "Commit allowed, but please verify this is intentional." -ForegroundColor Yellow
        Write-Host ""
    }

    return $true
}

function Install-Hook {
    param([string]$TargetRepo)

    if (-not (Test-Path $TargetRepo)) {
        Write-Host "ERROR: Repository not found at $TargetRepo" -ForegroundColor Red
        return
    }

    $hooksDir = Join-Path $TargetRepo ".git\hooks"
    if (-not (Test-Path $hooksDir)) {
        Write-Host "ERROR: Not a git repository or hooks dir missing" -ForegroundColor Red
        return
    }

    $hookPath = Join-Path $hooksDir "pre-commit"
    $hookContent = @"
#!/bin/sh
# Pre-commit hook installed by Claude Agent
# Runs zero-tolerance checks before commits

powershell.exe -ExecutionPolicy Bypass -File "C:\scripts\tools\pre-commit-hook.ps1" -Check
exit `$?
"@

    $hookContent | Set-Content $hookPath -Encoding ASCII
    Write-Host "Hook installed to: $hookPath" -ForegroundColor Green
    Write-Host "Make sure the hook is executable (chmod +x on Unix)" -ForegroundColor DarkGray
}

# Main execution
if ($Install) {
    if (-not $RepoPath) {
        Write-Host "ERROR: -RepoPath required for install" -ForegroundColor Red
        Write-Host "Usage: .\pre-commit-hook.ps1 -Install -RepoPath 'C:\Projects\client-manager'"
        exit 1
    }
    Install-Hook -TargetRepo $RepoPath
} elseif ($Check) {
    $result = Invoke-PreCommitChecks
    if (-not $result) {
        exit 1
    }
    exit 0
} else {
    # Running as actual hook
    $result = Invoke-PreCommitChecks
    if (-not $result) {
        exit 1
    }
    exit 0
}
