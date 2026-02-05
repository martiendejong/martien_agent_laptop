# Context Compression Pipeline - Round 12
# Compress old context files to save space

param(
    [Parameter(Mandatory=$false)]
    [int]$DaysOld = 30,

    [Parameter(Mandatory=$false)]
    [string]$ContextDir = "C:\scripts\_machine"
)

$archiveDir = Join-Path $ContextDir "archives"

if (-not (Test-Path $archiveDir)) {
    New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
}

# Find old files
$cutoffDate = (Get-Date).AddDays(-$DaysOld)
$oldFiles = Get-ChildItem $ContextDir -Recurse |
    Where-Object { $_.LastWriteTime -lt $cutoffDate -and $_.Extension -match '\.(md|yaml|json)$' -and $_.Directory.Name -ne 'archives' }

Write-Host "Found $($oldFiles.Count) files older than $DaysOld days" -ForegroundColor Cyan

$totalOriginalSize = 0
$totalCompressedSize = 0

foreach ($file in $oldFiles) {
    $relativePath = $file.FullName.Replace($ContextDir, "").TrimStart('\')
    $archivePath = Join-Path $archiveDir "$relativePath.gz"
    $archiveFolder = Split-Path $archivePath

    if (-not (Test-Path $archiveFolder)) {
        New-Item -ItemType Directory -Path $archiveFolder -Force | Out-Null
    }

    # Compress using gzip
    $content = [System.IO.File]::ReadAllBytes($file.FullName)
    $compressedStream = New-Object System.IO.MemoryStream

    $gzipStream = New-Object System.IO.Compression.GzipStream($compressedStream, [System.IO.Compression.CompressionMode]::Compress)
    $gzipStream.Write($content, 0, $content.Length)
    $gzipStream.Close()

    $compressed = $compressedStream.ToArray()
    [System.IO.File]::WriteAllBytes($archivePath, $compressed)

    $originalSize = $file.Length
    $compressedSize = $compressed.Length
    $ratio = [math]::Round((1 - ($compressedSize / $originalSize)) * 100, 2)

    Write-Host "  $($file.Name): $originalSize → $compressedSize bytes ($ratio% reduction)" -ForegroundColor Green

    $totalOriginalSize += $originalSize
    $totalCompressedSize += $compressedSize

    # Remove original
    Remove-Item $file.FullName -Force
}

Write-Host "`n=== Compression Summary ===" -ForegroundColor Cyan
Write-Host "Files compressed: $($oldFiles.Count)" -ForegroundColor White
Write-Host "Original size: $([math]::Round($totalOriginalSize / 1MB, 2)) MB" -ForegroundColor White
Write-Host "Compressed size: $([math]::Round($totalCompressedSize / 1MB, 2)) MB" -ForegroundColor White
Write-Host "Space saved: $([math]::Round(($totalOriginalSize - $totalCompressedSize) / 1MB, 2)) MB" -ForegroundColor Green
Write-Host "Compression ratio: $([math]::Round((1 - ($totalCompressedSize / $totalOriginalSize)) * 100, 2))%" -ForegroundColor Green
