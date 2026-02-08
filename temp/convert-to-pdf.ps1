# Convert Markdown to PDF via Chrome Headless

$files = @(
    "1_Facebook_Meta_Verificatie",
    "2_LinkedIn_Verificatie",
    "3_TikTok_Verificatie",
    "4_Instagram_Verificatie",
    "5_Medium_Verificatie"
)

Write-Host "Converting Markdown to HTML met Pandoc..." -ForegroundColor Cyan

foreach ($file in $files) {
    $mdFile = "C:\scripts\temp\$file.md"
    $htmlFile = "C:\scripts\temp\$file.html"

    Write-Host "  Converting $file.md..." -NoNewline

    # Pandoc: Markdown naar HTML met styling
    & "C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\JohnMacFarlane.Pandoc_Microsoft.Winget.Source_8wekyb3d8bbwe\pandoc-3.8.3\pandoc.exe" `
        $mdFile `
        -o $htmlFile `
        --standalone `
        --toc `
        --toc-depth=3 `
        --css="https://cdn.jsdelivr.net/npm/github-markdown-css@5.1.0/github-markdown.min.css" `
        -V "title=$file" `
        --metadata pagetitle="$file"

    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FAILED" -ForegroundColor Red
    }
}

Write-Host "`nConverting HTML to PDF via Chrome Headless..." -ForegroundColor Cyan

# Find Chrome
$chromePaths = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)

$chrome = $null
foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        $chrome = $path
        break
    }
}

if ($null -eq $chrome) {
    Write-Host "`nChrome not found. Opening HTMLs in browser for manual PDF export..." -ForegroundColor Yellow
    Write-Host "Press Ctrl+P and select 'Save as PDF' for each file." -ForegroundColor Yellow

    foreach ($file in $files) {
        $htmlFile = "C:\scripts\temp\$file.html"
        Start-Process $htmlFile
        Start-Sleep -Milliseconds 500
    }
} else {
    Write-Host "Using Chrome: $chrome" -ForegroundColor Gray

    foreach ($file in $files) {
        $htmlFile = "C:\scripts\temp\$file.html"
        $pdfFile = "C:\scripts\temp\$file.pdf"

        Write-Host "  Converting $file.html..." -NoNewline

        & $chrome --headless --disable-gpu --print-to-pdf="$pdfFile" "$htmlFile" 2>$null

        if (Test-Path $pdfFile) {
            Write-Host " OK" -ForegroundColor Green
        } else {
            Write-Host " FAILED" -ForegroundColor Red
        }
    }
}

Write-Host "`nDone! Check C:\scripts\temp\ for PDFs" -ForegroundColor Green
Write-Host "`nFiles created:" -ForegroundColor Cyan
Get-ChildItem "C:\scripts\temp\" -Filter "*.pdf" | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
}
