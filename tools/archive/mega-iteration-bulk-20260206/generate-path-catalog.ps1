# Generate File Path Catalog
# Scans directories and generates up-to-date path catalog

param(
    [switch]$Verbose
)

$catalogFile = "C:\scripts\_machine\FILE_PATH_CATALOG.yaml"

Write-Host "Generating file path catalog..." -ForegroundColor Cyan

# Scan projects
$projects = @{}
Get-ChildItem "C:\Projects" -Directory | ForEach-Object {
    $readme = Join-Path $_.FullName "README.md"
    $projects[$_.Name] = @{
        path = $_.FullName
        has_readme = (Test-Path $readme)
        last_modified = $_.LastWriteTime.ToString("yyyy-MM-dd")
    }
}

# Scan stores
$stores = @{}
if (Test-Path "C:\stores") {
    Get-ChildItem "C:\stores" -Directory | ForEach-Object {
        $stores[$_.Name] = @{
            path = $_.FullName
            size_mb = [math]::Round((Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
        }
    }
}

# Scan tools
$tools = @()
Get-ChildItem "C:\scripts\tools" -Filter "*.ps1" | ForEach-Object {
    $tools += $_.FullName
}

# Scan skills
$skills = @()
if (Test-Path "C:\scripts\.claude\skills") {
    Get-ChildItem "C:\scripts\.claude\skills" -Directory | ForEach-Object {
        $skills += $_.Name
    }
}

# Build catalog structure
$catalog = @{
    schema_version = "1.0"
    last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    description = "Auto-generated file path catalog"
    statistics = @{
        total_projects = $projects.Count
        total_stores = $stores.Count
        total_tools = $tools.Count
        total_skills = $skills.Count
        scan_date = (Get-Date).ToString("yyyy-MM-dd")
    }
    projects = $projects
    stores = $stores
    tools = $tools
    skills = $skills
}

# Save catalog
$catalog | ConvertTo-Json -Depth 10 | Set-Content $catalogFile

Write-Host "[SUCCESS] Catalog generated: $catalogFile" -ForegroundColor Green
Write-Host "  Projects: $($projects.Count)" -ForegroundColor Cyan
Write-Host "  Stores: $($stores.Count)" -ForegroundColor Cyan
Write-Host "  Tools: $($tools.Count)" -ForegroundColor Cyan
Write-Host "  Skills: $($skills.Count)" -ForegroundColor Cyan

if ($Verbose) {
    Write-Host "`nProjects found:" -ForegroundColor Yellow
    $projects.Keys | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
}
