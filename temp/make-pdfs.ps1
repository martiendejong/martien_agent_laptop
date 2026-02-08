$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"

$files = @(
    "1_Facebook_Meta_API_Verification",
    "2_LinkedIn_API_Verification",
    "3_TikTok_API_Verification",
    "4_Instagram_API_Verification",
    "5_Medium_API_Verification"
)

Write-Host "Creating PDFs with Chrome..." -ForegroundColor Cyan

foreach ($file in $files) {
    $html = "C:\scripts\temp\$file.html"
    $pdf = "C:\scripts\temp\$file.pdf"

    Write-Host "  $file..." -NoNewline

    & $chrome --headless --disable-gpu --print-to-pdf="$pdf" "$html" 2>$null
    Start-Sleep -Milliseconds 500

    if (Test-Path $pdf) {
        $size = (Get-Item $pdf).Length / 1KB
        Write-Host " OK ($([math]::Round($size, 1)) KB)" -ForegroundColor Green
    } else {
        Write-Host " FAILED" -ForegroundColor Red
    }
}

Write-Host "`nDone! PDFs in C:\scripts\temp\" -ForegroundColor Green
