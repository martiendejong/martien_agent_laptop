param(
    [Parameter(Mandatory=$true)]
    [string]$RootPath,

    [switch]$DryRun
)

function Get-EmailDate {
    param([string]$EmlPath)

    try {
        # Read first 150 lines to find Date header (use -LiteralPath for special chars)
        # Some emails have long DKIM/ARC headers before Date
        $lines = Get-Content -LiteralPath $EmlPath -Encoding UTF8 -TotalCount 150

        foreach ($line in $lines) {
            if ($line -match '^Date:\s*(.+)$') {
                $dateStr = $matches[1]

                # Try parsing the date
                try {
                    $date = [DateTime]::Parse($dateStr)
                    return $date
                }
                catch {
                    # Try parsing as RFC2822 format
                    try {
                        $date = [DateTime]::ParseExact($dateStr, 'ddd, dd MMM yyyy HH:mm:ss zzz', [System.Globalization.CultureInfo]::InvariantCulture)
                        return $date
                    }
                    catch {
                        Write-Warning "Could not parse date: $dateStr in file: $EmlPath"
                        return $null
                    }
                }
            }
        }

        Write-Warning "No Date header found in: $EmlPath"
        return $null
    }
    catch {
        Write-Error "Error reading file ${EmlPath}: $_"
        return $null
    }
}

# Get all .eml files recursively
$emlFiles = Get-ChildItem -Path $RootPath -Filter "*.eml" -Recurse -File

Write-Host "Found $($emlFiles.Count) EML files"
Write-Host ""

$renamed = 0
$failed = 0
$skipped = 0

foreach ($file in $emlFiles) {
    # Check if already has date prefix (yy_mm_dd pattern)
    if ($file.Name -match '^\d{2}_\d{2}_\d{2}_\d{2}_\d{2}_') {
        Write-Host "[SKIP] Already has date prefix: $($file.Name)" -ForegroundColor Yellow
        $skipped++
        continue
    }

    # Extract date from email
    $emailDate = Get-EmailDate -EmlPath $file.FullName

    if ($null -eq $emailDate) {
        Write-Host "[FAIL] No date found: $($file.Name)" -ForegroundColor Red
        $failed++
        continue
    }

    # Format: yy_mm_dd_hh_mm_
    $prefix = $emailDate.ToString("yy_MM_dd_HH_mm_")

    # New filename
    $newName = "$prefix$($file.Name)"
    $newPath = Join-Path $file.DirectoryName $newName

    # Check if target already exists
    if (Test-Path $newPath) {
        Write-Host "[FAIL] Target already exists: $newName" -ForegroundColor Red
        $failed++
        continue
    }

    if ($DryRun) {
        Write-Host "[DRY-RUN] $($file.Name) -> $newName" -ForegroundColor Cyan
    }
    else {
        try {
            Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
            Write-Host "[OK] $($file.Name) -> $newName" -ForegroundColor Green
            $renamed++
        }
        catch {
            Write-Host "[FAIL] Error renaming $($file.Name): $_" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host ""
Write-Host "Summary:"
Write-Host "  Renamed: $renamed" -ForegroundColor Green
Write-Host "  Skipped: $skipped" -ForegroundColor Yellow
Write-Host "  Failed: $failed" -ForegroundColor Red
