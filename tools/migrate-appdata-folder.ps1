# Generic AppData Folder Migration Script
# Migrates AppData subdirectories to E: drive with symlinks + environment variables
#
# Usage:
#   migrate-appdata-folder.ps1 -FolderName "Yarn" -EnvVarName "YARN_CACHE_FOLDER" -EnvVarSubPath "\Cache"
#   migrate-appdata-folder.ps1 -FolderName "ms-playwright" -EnvVarName "PLAYWRIGHT_BROWSERS_PATH"

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderName,           # Name of folder in AppData\Local (e.g., "Yarn", "ms-playwright")

    [Parameter(Mandatory=$false)]
    [string]$EnvVarName,           # Environment variable name (e.g., "YARN_CACHE_FOLDER")

    [Parameter(Mandatory=$false)]
    [string]$EnvVarSubPath = "",   # Subpath to append to env var (e.g., "\Cache")

    [Parameter(Mandatory=$false)]
    [switch]$SkipBackup,           # Skip creating backup (for testing)

    [Parameter(Mandatory=$false)]
    [switch]$DryRun                # Show what would be done without doing it
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== APPDATA FOLDER MIGRATION ===" -ForegroundColor Cyan
Write-Host "Folder: $FolderName" -ForegroundColor White

# Paths
$sourcePath = "C:\Users\HP\AppData\Local\$FolderName"
$targetPath = "E:\appdata-cache\$FolderName"
$backupPath = "C:\Users\HP\AppData\Local\$FolderName.old"

# Validate source exists
if (-not (Test-Path $sourcePath)) {
    throw "Source folder not found: $sourcePath"
}

# Step 1: Measure source size
Write-Host "`n[1/8] Measuring source size..." -ForegroundColor Yellow
$sourceSize = (Get-ChildItem $sourcePath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$sourceGB = [math]::Round($sourceSize/1GB, 2)
Write-Host "Source: $sourceGB GB ($([math]::Round($sourceSize/1MB, 0)) MB)" -ForegroundColor Green

if ($DryRun) {
    Write-Host "`n[DRY RUN] Would migrate $sourceGB GB from C: to E:" -ForegroundColor Yellow
    Write-Host "Source: $sourcePath" -ForegroundColor Gray
    Write-Host "Target: $targetPath" -ForegroundColor Gray
    if ($EnvVarName) {
        Write-Host "Env var: $EnvVarName=$targetPath$EnvVarSubPath" -ForegroundColor Gray
    }
    exit 0
}

# Step 2: Create target directory
Write-Host "`n[2/8] Creating target directory..." -ForegroundColor Yellow
if (-not (Test-Path "E:\appdata-cache")) {
    New-Item -Path "E:\appdata-cache" -ItemType Directory | Out-Null
}
Write-Host "Target: $targetPath" -ForegroundColor Green

# Step 3: Robocopy (preserves permissions, handles locked files)
Write-Host "`n[3/8] Copying files with robocopy..." -ForegroundColor Yellow
Write-Host "This may take a few minutes for large folders..." -ForegroundColor Gray

$robocopyArgs = @(
    $sourcePath,
    $targetPath,
    "/E",           # Copy subdirectories including empty
    "/COPY:DAT",    # Copy data, attributes, timestamps
    "/R:3",         # Retry 3 times on failure
    "/W:5"          # Wait 5 seconds between retries
)

$robocopyOutput = robocopy @robocopyArgs 2>&1
$exitCode = $LASTEXITCODE

# Robocopy exit codes 0-7 are success/warnings, 8+ are errors
if ($exitCode -gt 7) {
    Write-Host "Robocopy output:" -ForegroundColor Red
    Write-Host $robocopyOutput -ForegroundColor Gray
    throw "Robocopy failed with exit code $exitCode"
}
Write-Host "Robocopy completed (exit code: $exitCode)" -ForegroundColor Green

# Step 4: Verify target size
Write-Host "`n[4/8] Verifying target size..." -ForegroundColor Yellow
$targetSize = (Get-ChildItem $targetPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$targetGB = [math]::Round($targetSize/1GB, 2)
$diffGB = [math]::Abs($sourceGB - $targetGB)

Write-Host "Source: $sourceGB GB" -ForegroundColor Cyan
Write-Host "Target: $targetGB GB" -ForegroundColor Cyan
Write-Host "Diff:   $diffGB GB" -ForegroundColor $(if ($diffGB -lt 0.1) { "Green" } else { "Yellow" })

if ($diffGB -gt 0.5) {
    throw "Size mismatch too large! Source: $sourceGB GB, Target: $targetGB GB, Diff: $diffGB GB"
}

# Step 5: Set environment variable (if specified)
if ($EnvVarName) {
    Write-Host "`n[5/8] Setting environment variable..." -ForegroundColor Yellow
    $envVarValue = "$targetPath$EnvVarSubPath"
    [Environment]::SetEnvironmentVariable($EnvVarName, $envVarValue, [EnvironmentVariableTarget]::User)
    Write-Host "Set $EnvVarName=$envVarValue" -ForegroundColor Green
    Write-Host "NOTE: Restart terminals for env var to take effect" -ForegroundColor Yellow
} else {
    Write-Host "`n[5/8] Skipping environment variable (not specified)" -ForegroundColor Gray
}

# Step 6: Rename original (create backup)
Write-Host "`n[6/8] Creating backup..." -ForegroundColor Yellow
if (Test-Path $backupPath) {
    Write-Host "Removing old backup..." -ForegroundColor Gray
    Remove-Item $backupPath -Recurse -Force
}

if (-not $SkipBackup) {
    Rename-Item $sourcePath $backupPath
    Write-Host "Backup created: $backupPath" -ForegroundColor Green
} else {
    Remove-Item $sourcePath -Recurse -Force
    Write-Host "Backup skipped (source removed)" -ForegroundColor Yellow
}

# Step 7: Create symlink (requires Administrator)
Write-Host "`n[7/8] Creating symlink..." -ForegroundColor Yellow
$mklinkOutput = cmd /c mklink /D "$sourcePath" "$targetPath" 2>&1
if ($LASTEXITCODE -ne 0) {
    # Restore original if symlink fails
    if (Test-Path $backupPath) {
        Rename-Item $backupPath $sourcePath
    }
    throw "Symlink creation failed: $mklinkOutput"
}
Write-Host "Symlink created: $sourcePath -> $targetPath" -ForegroundColor Green

# Step 8: Verify symlink
Write-Host "`n[8/8] Verifying symlink..." -ForegroundColor Yellow
$item = Get-Item $sourcePath
if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
    Write-Host "[PASS] Symlink verified" -ForegroundColor Green
    Write-Host "Target: $($item.Target)" -ForegroundColor Cyan
} else {
    throw "Symlink verification failed"
}

# Final summary
Write-Host "`n=== MIGRATION COMPLETE ===" -ForegroundColor Green
Write-Host "`nSpace freed on C: drive: ~$sourceGB GB" -ForegroundColor Cyan

if ($EnvVarName) {
    Write-Host "`nConfiguration:" -ForegroundColor Yellow
    Write-Host "- Environment variable: $EnvVarName=$targetPath$EnvVarSubPath" -ForegroundColor White
    Write-Host "- Symlink: $sourcePath -> $targetPath" -ForegroundColor White
} else {
    Write-Host "`nSymlink: $sourcePath -> $targetPath" -ForegroundColor Yellow
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Test that applications using this folder still work" -ForegroundColor White
if ($EnvVarName) {
    Write-Host "2. Restart terminals (for environment variable)" -ForegroundColor White
}
if (-not $SkipBackup) {
    Write-Host "3. After testing, remove backup:" -ForegroundColor White
    Write-Host "   Remove-Item '$backupPath' -Recurse -Force" -ForegroundColor Gray
}

# Check C: drive space
$drive = Get-PSDrive C
$freeGB = [math]::Round($drive.Free/1GB, 2)
Write-Host "`nC: drive free space: $freeGB GB" -ForegroundColor Cyan
