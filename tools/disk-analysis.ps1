# Disk Analysis Script - Find biggest items to move from C: to E:
$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== DRIVE OVERVIEW ===" -ForegroundColor Cyan
Get-PSDrive C,E -ErrorAction SilentlyContinue | ForEach-Object {
    $used = [math]::Round($_.Used/1GB,1)
    $free = [math]::Round($_.Free/1GB,1)
    $total = [math]::Round(($_.Used+$_.Free)/1GB,1)
    Write-Host "$($_.Name): Used=$used GB, Free=$free GB, Total=$total GB"
}

Write-Host "`n=== TOP-LEVEL C:\ FOLDERS (sorted by size) ===" -ForegroundColor Cyan
Get-ChildItem 'C:\' -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin @('$Recycle.Bin','System Volume Information','PerfLogs') } |
    ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($size/1GB,2); SizeMB=[math]::Round($size/1MB,0)}
    } | Sort-Object SizeGB -Descending | Format-Table -AutoSize

Write-Host "`n=== C:\Projects BREAKDOWN ===" -ForegroundColor Cyan
Get-ChildItem 'C:\Projects' -Directory -ErrorAction SilentlyContinue |
    ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($size/1GB,2); SizeMB=[math]::Round($size/1MB,0)}
    } | Sort-Object SizeGB -Descending | Format-Table -AutoSize

Write-Host "`n=== C:\Users\HP BREAKDOWN ===" -ForegroundColor Cyan
Get-ChildItem 'C:\Users\HP' -Directory -ErrorAction SilentlyContinue |
    ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($size/1GB,2); SizeMB=[math]::Round($size/1MB,0)}
    } | Sort-Object SizeGB -Descending | Select-Object -First 15 | Format-Table -AutoSize

Write-Host "`n=== C:\Projects\worker-agents BREAKDOWN ===" -ForegroundColor Cyan
if (Test-Path 'C:\Projects\worker-agents') {
    Get-ChildItem 'C:\Projects\worker-agents' -Directory -ErrorAction SilentlyContinue |
        ForEach-Object {
            $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($size/1GB,2); SizeMB=[math]::Round($size/1MB,0)}
        } | Sort-Object SizeGB -Descending | Format-Table -AutoSize
}

Write-Host "`n=== XAMPP ===" -ForegroundColor Cyan
if (Test-Path 'C:\xampp') {
    $size = (Get-ChildItem 'C:\xampp' -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Write-Host "C:\xampp: $([math]::Round($size/1GB,2)) GB"
}

Write-Host "`n=== NUGET CACHE ===" -ForegroundColor Cyan
$nuget = "$env:USERPROFILE\.nuget"
if (Test-Path $nuget) {
    $size = (Get-ChildItem $nuget -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Write-Host ".nuget cache: $([math]::Round($size/1GB,2)) GB"
}

Write-Host "`n=== NPM/NODE CACHES ===" -ForegroundColor Cyan
$npmCache = "$env:APPDATA\npm-cache"
if (Test-Path $npmCache) {
    $size = (Get-ChildItem $npmCache -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Write-Host "npm-cache: $([math]::Round($size/1GB,2)) GB"
}
$nodeModulesLocations = @(
    'C:\Projects\client-manager\client-manager.client\node_modules',
    'C:\Projects\artrevisionist\artrevisionist\node_modules',
    'C:\Projects\hazina'
)
foreach ($loc in $nodeModulesLocations) {
    if (Test-Path $loc) {
        $size = (Get-ChildItem $loc -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Write-Host "$loc : $([math]::Round($size/1GB,2)) GB"
    }
}

Write-Host "`n=== E: DRIVE STATUS ===" -ForegroundColor Cyan
if (Test-Path 'E:\') {
    Get-ChildItem 'E:\' -ErrorAction SilentlyContinue | Format-Table Name, Length, LastWriteTime -AutoSize
    $edrive = Get-PSDrive E
    Write-Host "E: Free=$([math]::Round($edrive.Free/1GB,1)) GB, Used=$([math]::Round($edrive.Used/1GB,1)) GB"
} else {
    Write-Host "E: drive not accessible"
}

Write-Host "`n=== LARGE FILES (>500MB) on C: ===" -ForegroundColor Cyan
Get-ChildItem 'C:\' -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 500MB } |
    Sort-Object Length -Descending |
    Select-Object -First 20 |
    ForEach-Object {
        [PSCustomObject]@{Path=$_.FullName; SizeMB=[math]::Round($_.Length/1MB,0)}
    } | Format-Table -AutoSize

Write-Host "`n=== STORES ===" -ForegroundColor Cyan
if (Test-Path 'C:\stores') {
    Get-ChildItem 'C:\stores' -Directory -ErrorAction SilentlyContinue |
        ForEach-Object {
            $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            [PSCustomObject]@{Folder=$_.Name; SizeMB=[math]::Round($size/1MB,0)}
        } | Sort-Object SizeMB -Descending | Format-Table -AutoSize
}
