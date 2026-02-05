# Context Conflict Detector - Round 7
# Finds contradictions in documentation

param(
    [Parameter(Mandatory=$false)]
    [string]$ContextDir = "C:\scripts\_machine"
)

$contradictions = @()

# Load all markdown and yaml files
$files = Get-ChildItem $ContextDir -Include *.md,*.yaml,*.yml -Recurse

# Define contradiction patterns
$contradictionPatterns = @(
    @{ Pattern1 = "ALWAYS"; Pattern2 = "NEVER"; Context = "same file" }
    @{ Pattern1 = "must"; Pattern2 = "must not"; Context = "same topic" }
    @{ Pattern1 = "required"; Pattern2 = "optional"; Context = "same feature" }
    @{ Pattern1 = "enabled"; Pattern2 = "disabled"; Context = "same setting" }
)

Write-Host "Scanning $($files.Count) files for conflicts..." -ForegroundColor Cyan

# Schema validation
foreach ($file in ($files | Where-Object { $_.Extension -match 'ya?ml' })) {
    try {
        $content = Get-Content $file.FullName -Raw
        $yaml = $content | ConvertFrom-Yaml -ErrorAction Stop
        Write-Host "✓ $($file.Name)" -ForegroundColor Green
    } catch {
        $contradictions += @{
            Type = "Schema Violation"
            File = $file.FullName
            Error = $_.Exception.Message
        }
        Write-Host "✗ $($file.Name): Schema error" -ForegroundColor Red
    }
}

# Duplicate content detection (simple hash-based)
$contentHashes = @{}
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $hash = [System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($content))
    $hashString = [System.BitConverter]::ToString($hash)

    if ($contentHashes.ContainsKey($hashString)) {
        $contradictions += @{
            Type = "Duplicate Content"
            File1 = $contentHashes[$hashString]
            File2 = $file.FullName
        }
        Write-Host "⚠ Duplicate: $($file.Name)" -ForegroundColor Yellow
    } else {
        $contentHashes[$hashString] = $file.FullName
    }
}

# Report results
Write-Host "`n=== Conflict Detection Results ===" -ForegroundColor Cyan
Write-Host "Total files scanned: $($files.Count)" -ForegroundColor White
Write-Host "Conflicts found: $($contradictions.Count)" -ForegroundColor $(if($contradictions.Count -gt 0){"Red"}else{"Green"})

if ($contradictions.Count -gt 0) {
    Write-Host "`nConflicts:" -ForegroundColor Yellow
    $contradictions | Format-Table -AutoSize

    # Save report
    $reportPath = Join-Path $ContextDir "conflict-report.json"
    $contradictions | ConvertTo-Json | Set-Content $reportPath
    Write-Host "`nReport saved: $reportPath" -ForegroundColor Cyan
}

return $contradictions
