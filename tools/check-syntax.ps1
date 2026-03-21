$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    'C:\scripts\tools\week3-run-all-tests.ps1',
    [ref]$null,
    [ref]$errors
)

if ($errors) {
    $errors | ForEach-Object {
        Write-Host "Error: $($_.Message)" -ForegroundColor Red
        Write-Host "Line: $($_.Extent.StartLineNumber)" -ForegroundColor Yellow
        Write-Host "Offset: $($_.Extent.StartColumnNumber)" -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Host "No syntax errors found!" -ForegroundColor Green
}
