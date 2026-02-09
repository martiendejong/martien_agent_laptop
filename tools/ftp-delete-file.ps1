param(
    [Parameter(Mandatory=$true)]
    [string]$RemotePath
)

$ftpHost = "artrevisionist.com"
$ftpUser = "u63291p434771"
$ftpPass = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("PzpqTzg7VHJTRlFBdHNEM2NgSU10ew=="))

$ftpUri = "ftp://$ftpHost$RemotePath"
Write-Host "Deleting $ftpUri..."

try {
    $request = [System.Net.FtpWebRequest]::Create($ftpUri)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $response = $request.GetResponse()
    Write-Host "OK: File deleted" -ForegroundColor Green
    $response.Close()
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
