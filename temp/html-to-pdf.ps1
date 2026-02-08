# HTML to PDF Converter using Chrome Headless

$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"

$files = @(
    "1_Facebook_Meta_API_Verification",
    "2_LinkedIn_API_Verification",
    "3_TikTok_API_Verification",
    "4_Instagram_API_Verification",
    "5_Medium_API_Verification"
)

if (-not (Test-Path $chrome)) {
    Write-Host "Chrome not found at: $chrome" -ForegroundColor Red
    exit 1
}

Write-Host "Converting HTML to PDF with Chrome Headless..." -ForegroundColor Cyan
Write-Host ""

foreach ($file in $files) {
    $htmlPath = "C:\scripts\temp\$file.html"
    $pdfPath = "C:\scripts\temp\$file.pdf"

    if (-not (Test-Path $htmlPath)) {
        Write-Host "  SKIP: $file.html not found" -ForegroundColor Yellow
        continue
    }

    Write-Host "  Converting: $file.html..." -NoNewline

    # Use Start-Process to better handle Chrome headless
    $proc = Start-Process -FilePath $chrome `
        -ArgumentList "--headless", "--disable-gpu", "--no-sandbox", "--disable-dev-shm-usage", "--print-to-pdf=`"$pdfPath`"", "file:///$($htmlPath.Replace('\','/'))" `
        -WindowStyle Hidden `
        -Wait `
        -PassThru

    Start-Sleep -Milliseconds 1000

    if (Test-Path $pdfPath) {
        $size = [math]::Round((Get-Item $pdfPath).Length / 1KB, 1)
        Write-Host " OK ($size KB)" -ForegroundColor Green
    } else {
        Write-Host " FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! Check C:\scripts\temp\ for PDFs" -ForegroundColor Green
