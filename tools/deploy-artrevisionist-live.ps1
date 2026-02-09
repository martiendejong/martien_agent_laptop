param(
    [switch]$ThemeOnly,
    [switch]$PluginOnly,
    [switch]$DryRun
)

$ftpHost = "artrevisionist.com"
$ftpUser = "u63291p434771"
$ftpPass = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("PzpqTzg7VHJTRlFBdHNEM2NgSU10ew=="))
$liveWpContent = "/public_html/wp-content"

Write-Host "=== Deploying to Art Revisionist LIVE ===" -ForegroundColor Cyan
Write-Host "Host: $ftpHost"
Write-Host "Path: $liveWpContent"
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
        [string]$RemotePath
    )

    $ftpUri = "ftp://$ftpHost$RemotePath"

    if ($DryRun) {
        Write-Host "  [DRY] Would upload: $RemotePath" -ForegroundColor DarkGray
        return $true
    }

    try {
        $webclient = New-Object System.Net.WebClient
        $webclient.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $webclient.UploadFile($ftpUri, $LocalFile)
        return $true
    } catch {
        Write-Host "    ERROR uploading $($RemotePath): $_" -ForegroundColor Red
        return $false
    }
}

function Upload-Directory {
    param(
        [string]$LocalPath,
        [string]$RemotePath,
        [string]$Label
    )

    Write-Host "Uploading $Label..." -ForegroundColor Yellow

    $files = Get-ChildItem -Path $LocalPath -Recurse -File
    # Exclude git and dev files
    $files = $files | Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.Name -ne '.gitignore' -and
        $_.Name -ne '.gitattributes'
    }

    $total = $files.Count
    $success = 0
    $failed = 0
    $i = 0

    # Collect unique directories
    $dirs = @{}
    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($LocalPath.Length).Replace('\', '/')
        $dirPart = $relativePath.Substring(0, $relativePath.LastIndexOf('/'))
        if ($dirPart -and -not $dirs.ContainsKey($dirPart)) {
            $dirs[$dirPart] = $true
        }
    }

    # Create directories first
    foreach ($dir in ($dirs.Keys | Sort-Object)) {
        Ensure-FtpDirectory "$RemotePath$dir"
    }

    # Upload files
    foreach ($file in $files) {
        $i++
        $relativePath = $file.FullName.Substring($LocalPath.Length).Replace('\', '/')
        $remoteFilePath = "$RemotePath$relativePath"

        $pct = [Math]::Round(($i / $total) * 100)
        Write-Host "`r  [$pct%] $i/$total - $($file.Name)" -NoNewline

        if (Upload-File -LocalFile $file.FullName -RemotePath $remoteFilePath) {
            $success++
        } else {
            $failed++
        }
    }

    Write-Host ""
    if ($failed -eq 0) {
        Write-Host "  OK: $success files uploaded" -ForegroundColor Green
    } else {
        Write-Host "  WARN: $success uploaded, $failed failed" -ForegroundColor Yellow
    }
}

# Upload Theme
if (-not $PluginOnly) {
    Upload-Directory `
        -LocalPath "C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme" `
        -RemotePath "$liveWpContent/themes/artrevisionist-wp-theme" `
        -Label "Theme (artrevisionist-wp-theme)"
}

# Upload Plugin
if (-not $ThemeOnly) {
    $pluginPath = "C:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress"
    if (Test-Path $pluginPath) {
        Upload-Directory `
            -LocalPath $pluginPath `
            -RemotePath "$liveWpContent/plugins/artrevisionist-wordpress" `
            -Label "Plugin (artrevisionist-wordpress)"
    } else {
        Write-Host "Plugin directory not found, skipping." -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host "Live URL: https://artrevisionist.com" -ForegroundColor Cyan
Write-Host ""
