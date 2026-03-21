$projects = @()

# C:\Projects
Get-ChildItem 'C:\Projects' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $gitRepo = Test-Path (Join-Path $_.FullName ".git")
    $projects += [PSCustomObject]@{
        Name = $_.Name
        Path = $_.FullName
        Drive = 'C:'
        IsGitRepo = $gitRepo
        LastModified = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
    }
}

# E:\Projects
if (Test-Path 'E:\Projects') {
    Get-ChildItem 'E:\Projects' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $gitRepo = Test-Path (Join-Path $_.FullName ".git")
        $projects += [PSCustomObject]@{
            Name = $_.Name
            Path = $_.FullName
            Drive = 'E:'
            IsGitRepo = $gitRepo
            LastModified = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        }
    }
}

$output = @{
    GeneratedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    TotalProjects = $projects.Count
    Projects = $projects | Sort-Object Drive, Name
}

$output | ConvertTo-Json -Depth 3 | Out-File 'C:\scripts\_machine\all-projects-index.json' -Encoding UTF8
Write-Host "[OK] Index created: $($projects.Count) projects indexed"
