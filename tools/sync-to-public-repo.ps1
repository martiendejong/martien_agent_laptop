# Sync C:\scripts to C:\Projects\claudescripts (public distribution repo)
# Excludes machine-specific files and secrets

param(
    [switch]$DryRun,
    [switch]$NoPush,
    [string]$CommitMessage = "sync: Update from C:\scripts production system"
)

$ErrorActionPreference = "Stop"

$sourceDir = "C:\scripts"
$targetDir = "C:\Projects\claudescripts"

# Excluded patterns (machine-specific, secrets, temp files)
$excludePatterns = @(
    "_machine",
    "*.log",
    "*.tmp",
    "tmpclaude-*",
    "temp_clickup.json",
    "temp_clickup_comment.txt",
    "tools/gdrive-upload/credentials.json",
    "tools/gdrive-upload/oauth-keys.json",
    "tools/create-hazinastore-config.py",
    "MACHINE_CONFIG.md",
    "ZERO_TOLERANCE_RULES.md",
    "dual-mode-workflow.md",
    "worktree-workflow.md",
    "claude_info.txt",
    "claude_agent.bat",
    "node_modules",
    ".git",
    "*.secret",
    "*.key",
    "secrets/",
    "C:*"
)

Write-Host "🔄 Syncing C:\scripts → C:\Projects\claudescripts" -ForegroundColor Cyan
Write-Host ""

# Verify source exists
if (-not (Test-Path $sourceDir)) {
    Write-Host "❌ Source directory not found: $sourceDir" -ForegroundColor Red
    exit 1
}

# Verify target exists
if (-not (Test-Path $targetDir)) {
    Write-Host "❌ Target directory not found: $targetDir" -ForegroundColor Red
    Write-Host "Run: git clone https://github.com/martiendejong/autonomous-dev-system.git $targetDir" -ForegroundColor Yellow
    exit 1
}

# Verify target is a git repo
if (-not (Test-Path "$targetDir\.git")) {
    Write-Host "❌ Target is not a git repository: $targetDir" -ForegroundColor Red
    exit 1
}

# Sync files using robocopy
Write-Host "📁 Syncing files (excluding secrets and machine-specific files)..." -ForegroundColor Yellow

$robocopyCmd = "robocopy `"$sourceDir`" `"$targetDir`" /MIR /XD .git _machine node_modules /XF *.log *.tmp *.secret *.key tmpclaude-* temp_clickup.json /NFL /NDL /NJH /NJS"

if ($DryRun) {
    $robocopyCmd += " /L"
    Write-Host "🔍 DRY RUN MODE - No files will be modified" -ForegroundColor Magenta
}

$result = Invoke-Expression $robocopyCmd 2>&1
$exitCode = $LASTEXITCODE

# Robocopy exit codes: 0-7 are success/partial, 8+ are errors
if ($exitCode -ge 8) {
    Write-Host "❌ Robocopy failed with exit code: $exitCode" -ForegroundColor Red
    Write-Host $result
    exit 1
}

Write-Host "✅ Files synced successfully" -ForegroundColor Green
Write-Host ""

# Count changed files
Push-Location $targetDir
try {
    $gitStatus = git status --short
    $changedFiles = ($gitStatus | Measure-Object).Count

    if ($changedFiles -eq 0) {
        Write-Host "✨ No changes detected - repository is up to date" -ForegroundColor Green
        exit 0
    }

    Write-Host "📊 Changed files: $changedFiles" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-Host "Changes that would be committed:" -ForegroundColor Yellow
        git status --short
        exit 0
    }

    # Stage all changes
    Write-Host "📦 Staging changes..." -ForegroundColor Yellow
    git add -A

    # Get summary of changes
    $added = (git diff --cached --numstat | Where-Object { $_ -match '^\d+\s+0\s+' } | Measure-Object).Count
    $modified = (git diff --cached --numstat | Where-Object { $_ -match '^\d+\s+\d+\s+' -and $_ -notmatch '^\d+\s+0\s+' } | Measure-Object).Count
    $deleted = (git diff --cached --diff-filter=D --name-only | Measure-Object).Count

    Write-Host "  Added: $added files" -ForegroundColor Green
    Write-Host "  Modified: $modified files" -ForegroundColor Yellow
    Write-Host "  Deleted: $deleted files" -ForegroundColor Red
    Write-Host ""

    # Commit
    Write-Host "💾 Committing changes..." -ForegroundColor Yellow
    git commit -m $CommitMessage

    Write-Host "✅ Changes committed" -ForegroundColor Green
    Write-Host ""

    # Push (unless -NoPush)
    if (-not $NoPush) {
        Write-Host "🚀 Pushing to remote (autonomous-dev-system)..." -ForegroundColor Yellow

        $remote = git remote get-url origin
        if ($remote -notlike "*autonomous-dev-system*") {
            Write-Host "⚠️  Warning: Remote is $remote" -ForegroundColor Yellow
            Write-Host "Expected: https://github.com/martiendejong/autonomous-dev-system.git" -ForegroundColor Yellow
            $confirm = Read-Host "Continue pushing? (y/N)"
            if ($confirm -ne 'y') {
                Write-Host "❌ Push cancelled" -ForegroundColor Red
                exit 1
            }
        }

        git push origin master

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
        } else {
            Write-Host "❌ Push failed - check for secret scanning or other errors" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "⏭️  Skipping push (use without -NoPush to push)" -ForegroundColor Yellow
    }

} finally {
    Pop-Location
}

Write-Host ""
Write-Host "🎉 Sync complete!" -ForegroundColor Green
Write-Host "   Source: C:\scripts (machine_agents repo)"
Write-Host "   Target: C:\Projects\claudescripts (autonomous-dev-system repo)"
