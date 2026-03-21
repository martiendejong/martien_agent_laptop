param(
    [switch]$DryRun
)

# Get credentials from vault
$creds = & "C:\scripts\tools\vault.ps1" -Action get -Service ftp-maasaiinvestments -Silent | ConvertFrom-Json

$ftpHost = "maasaiinvestments.com"
$ftpUser = $creds.username
$ftpPass = $creds.password
$remotePath = "/public_html"
$localPath = "C:\projects\maasai\dist"

Write-Host "=== Deploying Maasai Investments to LIVE ===" -ForegroundColor Cyan
Write-Host "Host: $ftpHost"
Write-Host "Remote: $remotePath"
Write-Host "Local: $localPath"
if ($DryRun) { Write-Host "DRY RUN - no files will be uploaded" -ForegroundColor Yellow }
Write-Host ""

function Ensure-FtpDirectory {
    param([string]$DirPath)
    try {
        $ftpUri = "ftp://$ftpHost$DirPath/"
        $request = [System.Net.FtpWebRequest]::Create($ftpUri)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $request.UseBinary = $true
        $request.UsePassive = $true
        $response = $request.GetResponse()
        $response.Close()
    } catch {
        # Directory probably already exists, that's fine
    }
}

function Upload-File {
    param(
        [string]$LocalFile,
        [string]$RemoteFilePath
    )

    $ftpUri = "ftp://$ftpHost$RemoteFilePath"

    if ($DryRun) {
        Write-Host "  [DRY] Would upload: $RemoteFilePath" -ForegroundColor DarkGray
        return $true
    }

    try {
        $webclient = New-Object System.Net.WebClient
        $webclient.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $webclient.UploadFile($ftpUri, $LocalFile)
        return $true
    } catch {
        Write-Host "    ERROR uploading $($RemoteFilePath): $_" -ForegroundColor Red
        return $false
    }
}

# Check if dist folder exists
if (-not (Test-Path $localPath)) {
    Write-Host "ERROR: Build folder not found: $localPath" -ForegroundColor Red
    Write-Host "Run 'npm run build' first" -ForegroundColor Yellow
    exit 1
}

Write-Host "Uploading files..." -ForegroundColor Yellow

$files = Get-ChildItem -Path $localPath -Recurse -File
$total = $files.Count
$success = 0
$failed = 0
$i = 0

# Collect unique directories
$dirs = @{}
foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($localPath.Length).Replace('\', '/')
    if ($relativePath.Contains('/')) {
        $dirPart = $relativePath.Substring(0, $relativePath.LastIndexOf('/'))
        if ($dirPart -and -not $dirs.ContainsKey($dirPart)) {
            $dirs[$dirPart] = $true
        }
    }
}

# Create directories first
Write-Host "Creating remote directories..." -ForegroundColor Cyan
foreach ($dir in ($dirs.Keys | Sort-Object)) {
    Ensure-FtpDirectory "$remotePath$dir"
}

# Upload files
Write-Host "Uploading $total files..." -ForegroundColor Cyan
foreach ($file in $files) {
    $i++
    $relativePath = $file.FullName.Substring($localPath.Length).Replace('\', '/')
    $remoteFilePath = "$remotePath$relativePath"

    Write-Host "[$i/$total] $relativePath" -NoNewline
    if (Upload-File -LocalFile $file.FullName -RemoteFilePath $remoteFilePath) {
        Write-Host " OK" -ForegroundColor Green
        $success++
    } else {
        $failed++
    }
}

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Cyan
Write-Host "Success: $success/$total" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "Failed: $failed" -ForegroundColor Red
    exit 1
} else {
    Write-Host ""
    Write-Host "Site deployed to: https://maasaiinvestments.com" -ForegroundColor Green
}
