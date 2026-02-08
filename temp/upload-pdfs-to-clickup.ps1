# Upload PDFs to ClickUp Tasks

$API_KEY = "pk_74525428_TXT8V1QUA13N7SCRM0UUM6WNQO2I2NML"
$API_BASE = "https://api.clickup.com/api/v2"

$tasks = @(
    @{id="869c2e17j"; file="1_Facebook_Meta_API_Verification.pdf"; name="Facebook/Meta"},
    @{id="869c2e17m"; file="2_LinkedIn_API_Verification.pdf"; name="LinkedIn"},
    @{id="869c2e17p"; file="3_TikTok_API_Verification.pdf"; name="TikTok"},
    @{id="869c2e17t"; file="4_Instagram_API_Verification.pdf"; name="Instagram"},
    @{id="869c2e17v"; file="5_Medium_API_Verification.pdf"; name="Medium"}
)

Write-Host "Uploading PDFs to ClickUp..." -ForegroundColor Cyan
Write-Host ""

foreach ($task in $tasks) {
    $pdfPath = "C:\scripts\temp\$($task.file)"

    if (-not (Test-Path $pdfPath)) {
        Write-Host "  SKIP: $($task.file) not found" -ForegroundColor Yellow
        continue
    }

    Write-Host "  Uploading: $($task.name)..." -NoNewline

    try {
        # Read file
        $fileBytes = [System.IO.File]::ReadAllBytes($pdfPath)
        $fileBase64 = [Convert]::ToBase64String($fileBytes)

        # Create multipart form data
        $boundary = [System.Guid]::NewGuid().ToString()

        $LF = "`r`n"
        $bodyLines = (
            "--$boundary",
            "Content-Disposition: form-data; name=`"attachment`"; filename=`"$($task.file)`"",
            "Content-Type: application/pdf$LF",
            [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes),
            "--$boundary--$LF"
        ) -join $LF

        $headers = @{
            "Authorization" = $API_KEY
            "Content-Type" = "multipart/form-data; boundary=$boundary"
        }

        $response = Invoke-RestMethod -Uri "$API_BASE/task/$($task.id)/attachment" `
            -Headers $headers `
            -Method Post `
            -Body $bodyLines

        Write-Host " OK" -ForegroundColor Green

    } catch {
        Write-Host " FAILED: $_" -ForegroundColor Red

        # Try alternative method: add comment with file location
        try {
            $commentHeaders = @{
                "Authorization" = $API_KEY
                "Content-Type" = "application/json"
            }

            $commentBody = @{
                comment_text = "PDF Guide: $pdfPath (manual upload needed)"
            } | ConvertTo-Json

            Invoke-RestMethod -Uri "$API_BASE/task/$($task.id)/comment" `
                -Headers $commentHeaders `
                -Method Post `
                -Body $commentBody | Out-Null

            Write-Host "     Added comment with file path" -ForegroundColor Gray
        } catch {
            Write-Host "     Could not add comment either" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Write-Host ""
Write-Host "View tasks: https://app.clickup.com/9012956001/v/li/901214097647" -ForegroundColor Cyan
