$themePath = "C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme"
$zipPath = "C:\Users\HP\Downloads\artrevisionist-wp-theme.zip"

if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path $themePath -DestinationPath $zipPath -Force

$size = (Get-Item $zipPath).Length / 1MB
Write-Host "Theme zipped: $zipPath"
Write-Host "Size: $([Math]::Round($size, 1)) MB"
