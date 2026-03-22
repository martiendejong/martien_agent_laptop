# AppData Migration Guide

Veilige migratie van AppData subdirectories van C: naar E: drive met symlinks en environment variables.

## Quick Start

```powershell
# Run as Administrator (required for symlinks)
cd C:\scripts\tools

# Migrate with environment variable
.\migrate-appdata-folder.ps1 -FolderName "Yarn" -EnvVarName "YARN_CACHE_FOLDER" -EnvVarSubPath "\Cache"

# Migrate without environment variable (symlink only)
.\migrate-appdata-folder.ps1 -FolderName "ms-playwright"

# Dry run (see what would be done)
.\migrate-appdata-folder.ps1 -FolderName "CapCut" -DryRun
```

## Migration Pattern

**8-step veilig proces:**

1. **Measure** source size (GB)
2. **Create** target directory on E:
3. **Robocopy** files (preserves permissions, handles locked files)
4. **Verify** sizes match (fail if >0.5 GB difference)
5. **Set** environment variable (if specified)
6. **Backup** original folder (rename to .old)
7. **Create** symlink (C: → E:)
8. **Verify** symlink works

**Safety features:**
- Never deletes source until verified
- Creates backup (.old) before symlink
- Restores original if symlink fails
- Verifies sizes match before proceeding
- All steps logged with color-coded output

## Common Folders

### Already Migrated

| Folder | Size | Env Var | Date |
|--------|------|---------|------|
| Yarn | 5.8 GB | YARN_CACHE_FOLDER | 2026-02-21 |

### Ready to Migrate

| Folder | Size | Env Var | Notes |
|--------|------|---------|-------|
| ms-playwright | 2.78 GB | PLAYWRIGHT_BROWSERS_PATH | Browser binaries |
| wsl | 4.38 GB | - | WSL distributions/cache |
| Programs | 3.25 GB | - | Installed programs |
| Packages | 3.16 GB | - | Package cache |
| CapCut | 2.11 GB | - | Video editor cache |
| BraveSoftware | 1.37 GB | - | Browser cache |
| Temp | 1.51 GB | - | Can be cleaned instead |

**Total potential:** ~19 GB

## Environment Variables

Common environment variables supported by popular tools:

| Tool | Env Var | Default Path |
|------|---------|--------------|
| Yarn | YARN_CACHE_FOLDER | %LOCALAPPDATA%\Yarn\Cache |
| Playwright | PLAYWRIGHT_BROWSERS_PATH | %LOCALAPPDATA%\ms-playwright |
| npm | npm_config_cache | %LOCALAPPDATA%\npm-cache |
| pip | PIP_CACHE_DIR | %LOCALAPPDATA%\pip\Cache |
| HuggingFace | HF_HOME | %USERPROFILE%\.cache\huggingface |
| Ollama | OLLAMA_MODELS | %USERPROFILE%\.ollama\models |

## Examples

### Yarn Cache (with env var + subpath)

```powershell
.\migrate-appdata-folder.ps1 `
  -FolderName "Yarn" `
  -EnvVarName "YARN_CACHE_FOLDER" `
  -EnvVarSubPath "\Cache"
```

**Result:**
- Symlink: `C:\Users\HP\AppData\Local\Yarn` → `E:\appdata-cache\Yarn`
- Env var: `YARN_CACHE_FOLDER=E:\appdata-cache\Yarn\Cache`

### Playwright Browsers (with env var, no subpath)

```powershell
.\migrate-appdata-folder.ps1 `
  -FolderName "ms-playwright" `
  -EnvVarName "PLAYWRIGHT_BROWSERS_PATH"
```

**Result:**
- Symlink: `C:\Users\HP\AppData\Local\ms-playwright` → `E:\appdata-cache\ms-playwright`
- Env var: `PLAYWRIGHT_BROWSERS_PATH=E:\appdata-cache\ms-playwright`

### Generic Folder (symlink only)

```powershell
.\migrate-appdata-folder.ps1 -FolderName "CapCut"
```

**Result:**
- Symlink: `C:\Users\HP\AppData\Local\CapCut` → `E:\appdata-cache\CapCut`
- No env var

## Verification

After migration, verify with:

```powershell
# Check symlink
Get-Item "C:\Users\HP\AppData\Local\FolderName" | Select-Object Attributes, Target

# Check environment variable
[Environment]::GetEnvironmentVariable("VAR_NAME", [EnvironmentVariableTarget]::User)

# Test symlink redirect
echo "test" > "C:\Users\HP\AppData\Local\FolderName\test.txt"
Test-Path "E:\appdata-cache\FolderName\test.txt"  # Should be True
```

## Cleanup After Migration

**After testing (1-2 days):**

```powershell
# Remove backup to free space
Remove-Item "C:\Users\HP\AppData\Local\FolderName.old" -Recurse -Force

# Check freed space
Get-PSDrive C | Select-Object @{Name='Free_GB';Expression={[math]::Round($_.Free/1GB,2)}}
```

## Troubleshooting

### Symlink Creation Failed

**Error:** "You do not have sufficient privilege to perform this operation"

**Solution:** Run PowerShell as Administrator

```powershell
# Right-click PowerShell → Run as Administrator
Start-Process powershell -Verb RunAs
cd C:\scripts\tools
.\migrate-appdata-folder.ps1 -FolderName "..."
```

### Size Mismatch

**Error:** "Size mismatch too large! Source: X GB, Target: Y GB"

**Cause:** Files being written during migration, or robocopy incomplete

**Solution:** Re-run migration (robocopy will sync differences)

### Application Can't Find Files

**Cause:** Application doesn't follow symlinks OR environment variable not loaded

**Solution:**
1. Restart application (reload environment variables)
2. Restart terminal (for command-line tools)
3. Check application settings for custom cache path configuration

### Rollback Migration

If something goes wrong:

```powershell
# 1. Remove symlink
Remove-Item "C:\Users\HP\AppData\Local\FolderName"

# 2. Restore original
Rename-Item "C:\Users\HP\AppData\Local\FolderName.old" "C:\Users\HP\AppData\Local\FolderName"

# 3. Remove environment variable (if set)
[Environment]::SetEnvironmentVariable("VAR_NAME", $null, [EnvironmentVariableTarget]::User)
```

## Best Practices

1. **Test with non-critical folders first** (e.g., CapCut before Yarn)
2. **Keep backups for 1-2 days** before deleting
3. **Close applications** using the folder before migration
4. **Migrate during low-activity times** (fewer locked files)
5. **Check environment variable support** before using -EnvVarName
6. **Use -DryRun** to preview changes

## Technical Details

### Why Robocopy?

- Handles locked files gracefully (retries)
- Preserves NTFS permissions and attributes
- Faster than PowerShell `Copy-Item` for large folders
- Industry-standard for Windows file copying

### Why Symlinks?

- **100% transparent** - applications see original path
- **No configuration needed** - works with all apps
- **Windows-native** - no third-party tools
- **Persistent** - survives reboots

### Why Environment Variables?

- **Future-proof** - survives Windows updates
- **Preferred method** - many tools check env vars first
- **Explicit control** - clear where files go
- **User-level** - doesn't require admin for changes

### Symlink vs Junction

We use **Directory Symlinks** (`mklink /D`), not Junctions:
- Symlinks work across drives (C: → E:)
- Symlinks more flexible (can point to network paths)
- Junctions limited to local NTFS volumes

## Migration History

Track completed migrations:

| Date | Folder | Size | Method | Status |
|------|--------|------|--------|--------|
| 2026-02-21 | Yarn | 5.8 GB | Symlink + YARN_CACHE_FOLDER | ✅ Complete |
| 2026-02-21 | ms-playwright | 2.78 GB | Symlink + PLAYWRIGHT_BROWSERS_PATH | ✅ Complete |

**Total freed:** ~8.6 GB

**C: drive free space:** Before: ~14 GB → After: ~23 GB

---

**Last updated:** 2026-02-21
**Script location:** `C:\scripts\tools\migrate-appdata-folder.ps1`
**Verification script:** `C:\scripts\temp\verify-yarn-migration-complete.ps1` (adapt per folder)
