param([string]$LocalFile, [string]$RemotePath)

$ftpHost = "artrevisionist.com"
$ftpUser = "u63291p434771"
$ftpPass = '?:jO8;TrSFQAtsD3c`IMt{'

$ftpUri = "ftp://$ftpHost$RemotePath"
Write-Host "Uploading: $LocalFile" -ForegroundColor Yellow
Write-Host "       To: $ftpUri" -ForegroundColor Yellow

$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

try {
    $webclient.UploadFile($ftpUri, $LocalFile)
    Write-Host "Success!" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
