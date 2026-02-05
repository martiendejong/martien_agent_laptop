# dependency-scanner.ps1
# Scans for vulnerable/outdated dependencies
param([string]$ProjectPath)

$vulnCount = 0
Get-ChildItem $ProjectPath -Filter "package.json" -Recurse | ForEach-Object {
    $pkg = Get-Content $_.FullName | ConvertFrom-Json
    $pkg.dependencies.PSObject.Properties | ForEach-Object {
        # Simplified check - in reality would query vulnerability database
        if ($_.Value -match '\^' -or $_.Value -match '~') {
            Write-Host "⚠️ Loose version: $($_.Name)@$($_.Value)" -ForegroundColor Yellow
            $vulnCount++
        }
    }
}
Write-Host "$vulnCount potential issues found" -ForegroundColor $(if($vulnCount -eq 0){"Green"}else{"Yellow"})
