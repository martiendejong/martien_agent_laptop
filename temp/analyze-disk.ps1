# Analyze C: drive space usage
Write-Host "=== C: Drive Analysis ===" -ForegroundColor Cyan

# Known large directories
$targets = @(
    "C:\Users\HP\.nuget"
    "C:\Users\HP\.claude"
    "C:\Users\HP\AppData\Local\Temp"
    "C:\Users\HP\AppData\Local\npm-cache"
    "C:\Projects"
    "C:\ProgramData\Package Cache"
    "C:\Windows\Temp"
)

$results = @()

foreach ($path in $targets) {
    if (Test-Path $path) {
        try {
            $size = (Get-ChildItem -Path $path -Recurse -File -Force -ErrorAction SilentlyContinue |
                     Measure-Object -Property Length -Sum).Sum
            $sizeGB = [math]::Round($size / 1GB, 2)
            if ($sizeGB -gt 0.1) {
                $results += [PSCustomObject]@{
                    Path = $path
                    SizeGB = $sizeGB
                    Movable = $true
                }
            }
        } catch {
            Write-Warning "Failed to scan: $path"
        }
    }
}

# C:\Projects subdirectories
if (Test-Path "C:\Projects") {
    Get-ChildItem "C:\Projects" -Directory -Force | ForEach-Object {
        try {
            $size = (Get-ChildItem -Path $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
                     Measure-Object -Property Length -Sum).Sum
            $sizeGB = [math]::Round($size / 1GB, 2)
            if ($sizeGB -gt 0.5) {
                $results += [PSCustomObject]@{
                    Path = $_.FullName
                    SizeGB = $sizeGB
                    Movable = ($_.Name -notin @('client-manager', 'hazina', 'artrevisionist', 'worker-agents'))
                }
            }
        } catch {}
    }
}

$results | Sort-Object SizeGB -Descending | Format-Table -AutoSize

Write-Host "`nTotal size: $([math]::Round(($results | Measure-Object -Property SizeGB -Sum).Sum, 2)) GB" -ForegroundColor Yellow
