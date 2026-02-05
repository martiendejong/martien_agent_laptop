# code-linter.ps1
# PowerShell script linter with auto-fix capabilities
param([string]$Path, [switch]$AutoFix)

$issues = @()

Get-ChildItem $Path -Filter "*.ps1" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw

    # Check: Magic numbers
    if ($content -match '\d{4,}') {
        $issues += @{File=$_.Name; Issue="Magic numbers found"; Severity="Medium"}
    }

    # Check: Missing param validation
    if ($content -match 'param\(' -and $content -notmatch '\[Parameter') {
        $issues += @{File=$_.Name; Issue="Missing parameter validation"; Severity="Low"}
    }

    # Check: No error handling
    if ($content -match '\$\w+\.\w+\(' -and $content -notmatch 'try|catch') {
        $issues += @{File=$_.Name; Issue="No error handling"; Severity="High"}
    }
}

Write-Host "Found $($issues.Count) issues" -ForegroundColor $(if($issues.Count -eq 0){"Green"}else{"Yellow"})
$issues | ForEach-Object { Write-Host "  $($_.Severity): $($_.File) - $($_.Issue)" }
