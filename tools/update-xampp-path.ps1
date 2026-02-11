# Update system PATH: replace C:\xampp\php with E:\xampp\php
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$newPath = $currentPath -replace [regex]::Escape("C:\xampp\php"), "E:\xampp\php"

if ($currentPath -ne $newPath) {
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
    Write-Host "System PATH updated: C:\xampp\php -> E:\xampp\php"
} else {
    # Check if E:\xampp\php is already there
    if ($currentPath -like "*E:\xampp\php*") {
        Write-Host "E:\xampp\php already in PATH"
    } else {
        # C:\xampp\php not found, add E:\xampp\php
        $newPath = $currentPath + ";E:\xampp\php"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        Write-Host "Added E:\xampp\php to PATH (C:\xampp\php was not found)"
    }
}

# Also update user PATH if it references C:\xampp
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -and $userPath -like "*C:\xampp*") {
    $newUserPath = $userPath -replace [regex]::Escape("C:\xampp"), "E:\xampp"
    [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
    Write-Host "User PATH updated: C:\xampp -> E:\xampp"
} else {
    Write-Host "User PATH: no C:\xampp references found"
}

# Show current relevant PATH entries
Write-Host "`nCurrent PATH entries with 'xampp':"
$finalPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$finalPath -split ';' | Where-Object { $_ -like '*xampp*' } | ForEach-Object { Write-Host "  $_" }
