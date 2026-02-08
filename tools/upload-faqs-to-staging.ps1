# Upload FAQ generation scripts to Art Revisionist staging and execute

$ftpHost = "ftp.artrevisionist.com"
$ftpUser = "info@artrevisionist.com"
$ftpPass = "u48zm5dRaDTxVc9wdSbW"
$stagingPath = "/public_html/staging"

Write-Host "=== Uploading FAQ Scripts to Staging ===" -ForegroundColor Cyan
Write-Host ""

# Files to upload
$filesToUpload = @(
    @{
        Local = "C:\xampp\htdocs\generate-faqs-staging-batch.php"
        Remote = "$stagingPath/generate-faqs-staging-batch.php"
    },
    @{
        Local = "C:\stores\artrevisionist\faq-generation.prompts.json"
        Remote = "$stagingPath/faq-generation.prompts.json"
    }
)

# Upload files via FTP
foreach ($file in $filesToUpload) {
    Write-Host "Uploading: $($file.Local)" -ForegroundColor Yellow

    $ftpUri = "ftp://$ftpHost$($file.Remote)"
    $webclient = New-Object System.Net.WebClient
    $webclient.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

    try {
        $webclient.UploadFile($ftpUri, $file.Local)
        Write-Host "  Success: Uploaded successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error: Upload failed - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Browse to: https://artrevisionist.com/staging/generate-faqs-staging.php"
Write-Host "2. Or run via SSH/CLI on server"
Write-Host ""
Write-Host "Note: Script has OpenAI API key embedded"
