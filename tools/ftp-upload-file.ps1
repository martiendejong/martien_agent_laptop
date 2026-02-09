param(
    [Parameter(Mandatory=$true)]
    [string]$LocalFile,
    [Parameter(Mandatory=$true)]
    [string]$RemotePath
)

$ftpHost = "artrevisionist.com"
$ftpUser = "u63291p434771"
$ftpPass = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("PzpqTzg7VHJTRlFBdHNEM2NgSU10ew=="))

$ftpUri = "ftp://$ftpHost$RemotePath"
Write-Host "Uploading $LocalFile -> $ftpUri"

try {
    $webclient = New-Object System.Net.WebClient
    $webclient.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $webclient.UploadFile($ftpUri, $LocalFile)
    Write-Host "OK: Upload complete" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}
