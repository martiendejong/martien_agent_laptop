# Upload Art Revisionist Theme and Plugin to Staging

$ftpHost = "ftp.artrevisionist.com"
$ftpUser = "info@artrevisionist.com"
$ftpPass = "u48zm5dRaDTxVc9wdSbW"
$stagingWpContent = "/public_html/staging/wp-content"

Write-Host "=== Uploading to Art Revisionist Staging ===" -ForegroundColor Cyan
Write-Host ""

function Upload-Directory {
    param (
        [string]$LocalPath,
        [string]$RemotePath,
        [string]$Label
    )

    Write-Host "Uploading $Label..." -ForegroundColor Yellow

    # Use WinSCP for reliable recursive upload
    $winscp = "C:\Program Files (x86)\WinSCP\WinSCP.com"

    if (Test-Path $winscp) {
        $scriptContent = @"
open ftp://$ftpUser`:$ftpPass@$ftpHost
synchronize remote -delete `"$LocalPath`" `"$RemotePath`"
exit
"@

        $scriptContent | & $winscp /command /log="C:\temp\winscp-staging.log"

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $Label uploaded successfully" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $Label upload failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ! WinSCP not found, using basic FTP (slower)..." -ForegroundColor Yellow

        # Fallback to basic FTP for single files
        Get-ChildItem -Path $LocalPath -Recurse -File | ForEach-Object {
            $relativePath = $_.FullName.Substring($LocalPath.Length).Replace('\', '/')
            $ftpUri = "ftp://$ftpHost$RemotePath$relativePath"

            try {
                $webclient = New-Object System.Net.WebClient
                $webclient.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
                $webclient.UploadFile($ftpUri, $_.FullName)
            } catch {
                Write-Host "    Error uploading $($_.Name): $_" -ForegroundColor Red
            }
        }
    }
}

# Upload Theme
Upload-Directory `
    -LocalPath "C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme" `
    -RemotePath "$stagingWpContent/themes/artrevisionist-wp-theme/" `
    -Label "Theme (artrevisionist-wp-theme)"

# Upload Plugin
Upload-Directory `
    -LocalPath "C:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress" `
    -RemotePath "$stagingWpContent/plugins/artrevisionist-wordpress/" `
    -Label "Plugin (artrevisionist-wordpress)"

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host "Staging URL: https://artrevisionist.com/staging" -ForegroundColor Cyan
Write-Host ""
