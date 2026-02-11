Get-Service | Where-Object { $_.DisplayName -like '*apache*' -or $_.DisplayName -like '*mysql*' -or $_.DisplayName -like '*xampp*' } | Format-Table Name, DisplayName, Status, StartType -AutoSize
Write-Host "---"
# Check PATH for xampp references
$env:PATH -split ';' | Where-Object { $_ -like '*xampp*' } | ForEach-Object { Write-Host "PATH entry: $_" }
Write-Host "---"
# Check wp-config for DB path
if (Test-Path 'E:\xampp\htdocs\wp-config.php') {
    Write-Host "wp-config.php exists"
} else {
    Write-Host "No wp-config.php in htdocs root"
}
# Check for artrevisionist wp-config
Get-ChildItem 'E:\xampp\htdocs' -Filter 'wp-config.php' -Recurse -Depth 1 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "Found: $($_.FullName)" }
