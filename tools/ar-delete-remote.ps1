param([string]$RemotePath)
$ftpHost = "artrevisionist.com"
$ftpUser = "u63291p434771"
$ftpPass = '?:jO8;TrSFQAtsD3c`IMt{'
try {
    $req = [System.Net.FtpWebRequest]::Create("ftp://$ftpHost$RemotePath")
    $req.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
    $req.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $resp = $req.GetResponse()
    Write-Host "Deleted: $RemotePath" -ForegroundColor Green
    $resp.Close()
} catch { Write-Host "Delete failed: $_" -ForegroundColor Red }
