<#
.SYNOPSIS
    Universal Google Drive tool with OAuth, upload, download, search, list
.DESCRIPTION
    Complete Google Drive management tool with:
    - Automatic OAuth flow (popup browser for consent)
    - Token refresh
    - Upload/download files
    - Search/list files and folders
    - Create folders
.PARAMETER Action
    Action to perform: auth, upload, download, search, list, mkdir, find-folder
.PARAMETER FilePath
    Local file path (for upload/download)
.PARAMETER DriveFolder
    Google Drive folder name or ID
.PARAMETER Query
    Search query
.PARAMETER FolderName
    Folder name to create or find
.EXAMPLE
    .\gdrive.ps1 -Action auth
    .\gdrive.ps1 -Action upload -FilePath "C:\file.pdf" -DriveFolder "MVV"
    .\gdrive.ps1 -Action list -DriveFolder "MVV"
    .\gdrive.ps1 -Action search -Query "tardieve"
    .\gdrive.ps1 -Action find-folder -FolderName "MVV"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('auth', 'upload', 'download', 'search', 'list', 'mkdir', 'find-folder')]
    [string]$Action,

    [string]$FilePath,
    [string]$DriveFolder,
    [string]$Query,
    [string]$FolderName,
    [string]$DriveFileId
)

$ErrorActionPreference = "Stop"

# Paths
$CredentialsPath = "C:\scripts\_machine\gdrive-full-credentials.json"
$ClientSecretPath = "C:\Users\HP\Downloads\client_secret_856798693858-fh1s1fu0uj58vpluo6j13c4ioprptfgl.apps.googleusercontent.com.json"

# Load client secret
function Get-ClientConfig {
    if (-not (Test-Path $ClientSecretPath)) {
        throw "Client secret not found at $ClientSecretPath"
    }
    $config = Get-Content $ClientSecretPath | ConvertFrom-Json
    return $config.web
}

# Get access token (refresh if expired)
function Get-AccessToken {
    if (-not (Test-Path $CredentialsPath)) {
        Write-Host "❌ No credentials found. Run: .\gdrive.ps1 -Action auth" -ForegroundColor Red
        throw "Not authenticated"
    }

    $creds = Get-Content $CredentialsPath | ConvertFrom-Json

    # Check if token expired
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    if ($creds.expiry_date -lt $now) {
        Write-Host "🔄 Token expired, refreshing..." -ForegroundColor Yellow
        $clientConfig = Get-ClientConfig

        $body = @{
            client_id = $clientConfig.client_id
            client_secret = $clientConfig.client_secret
            refresh_token = $creds.refresh_token
            grant_type = "refresh_token"
        }

        $response = Invoke-RestMethod -Uri "https://oauth2.googleapis.com/token" -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"

        $creds.access_token = $response.access_token
        $creds.expiry_date = $now + ($response.expires_in * 1000)

        $creds | ConvertTo-Json | Set-Content $CredentialsPath
        Write-Host "✅ Token refreshed" -ForegroundColor Green
    }

    return $creds.access_token
}

# OAuth flow
function Start-OAuth {
    $clientConfig = Get-ClientConfig

    $scope = "https://www.googleapis.com/auth/drive"
    $redirectUri = "http://localhost:8080"

    $authUrl = "https://accounts.google.com/o/oauth2/auth?client_id=$($clientConfig.client_id)&redirect_uri=$redirectUri&scope=$scope&response_type=code&access_type=offline&prompt=consent"

    Write-Host "🌐 Opening browser for OAuth consent..." -ForegroundColor Cyan
    Write-Host "📋 If browser doesn't open, go to:" -ForegroundColor Yellow
    Write-Host $authUrl -ForegroundColor White

    Start-Process $authUrl

    # Start local server to receive callback
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("$redirectUri/")
    $listener.Start()

    Write-Host "⏳ Waiting for authorization..." -ForegroundColor Yellow

    $context = $listener.GetContext()
    $code = $context.Request.QueryString["code"]

    # Send response to browser
    $response = $context.Response
    $html = "<html><body><h1>✅ Authorization successful!</h1><p>You can close this window.</p></body></html>"
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.Close()
    $listener.Stop()

    if (-not $code) {
        throw "No authorization code received"
    }

    Write-Host "🔑 Exchanging code for tokens..." -ForegroundColor Cyan

    # Exchange code for tokens
    $body = @{
        code = $code
        client_id = $clientConfig.client_id
        client_secret = $clientConfig.client_secret
        redirect_uri = $redirectUri
        grant_type = "authorization_code"
    }

    $tokenResponse = Invoke-RestMethod -Uri "https://oauth2.googleapis.com/token" -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"

    # Save credentials
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $credentials = @{
        access_token = $tokenResponse.access_token
        refresh_token = $tokenResponse.refresh_token
        scope = $tokenResponse.scope
        token_type = $tokenResponse.token_type
        expiry_date = $now + ($tokenResponse.expires_in * 1000)
    }

    $credentials | ConvertTo-Json | Set-Content $CredentialsPath

    Write-Host "✅ Authentication successful! Credentials saved." -ForegroundColor Green
}

# Find folder by name
function Find-DriveFolder {
    param([string]$Name)

    $token = Get-AccessToken
    $headers = @{ Authorization = "Bearer $token" }

    $query = "name='$Name' and mimeType='application/vnd.google-apps.folder' and trashed=false"
    $uri = "https://www.googleapis.com/drive/v3/files?q=$([System.Web.HttpUtility]::UrlEncode($query))&fields=files(id,name,parents)"

    $response = Invoke-RestMethod -Uri $uri -Headers $headers

    if ($response.files.Count -eq 0) {
        return $null
    }

    return $response.files[0]
}

# List files in folder
function Get-DriveFiles {
    param([string]$FolderId)

    $token = Get-AccessToken
    $headers = @{ Authorization = "Bearer $token" }

    $query = if ($FolderId) {
        "'$FolderId' in parents and trashed=false"
    } else {
        "trashed=false"
    }

    $uri = "https://www.googleapis.com/drive/v3/files?q=$([System.Web.HttpUtility]::UrlEncode($query))&fields=files(id,name,mimeType,size,modifiedTime)&pageSize=100"

    $response = Invoke-RestMethod -Uri $uri -Headers $headers

    return $response.files
}

# Upload file
function Upload-DriveFile {
    param(
        [string]$LocalPath,
        [string]$FolderId
    )

    if (-not (Test-Path $LocalPath)) {
        throw "File not found: $LocalPath"
    }

    $token = Get-AccessToken
    $headers = @{ Authorization = "Bearer $token" }

    $fileName = Split-Path $LocalPath -Leaf

    # Metadata
    $metadata = @{
        name = $fileName
    }
    if ($FolderId) {
        $metadata.parents = @($FolderId)
    }

    # Read file
    $fileBytes = [System.IO.File]::ReadAllBytes($LocalPath)
    $boundary = [Guid]::NewGuid().ToString()

    # Build multipart body
    $bodyLines = @(
        "--$boundary",
        "Content-Type: application/json; charset=UTF-8",
        "",
        ($metadata | ConvertTo-Json),
        "--$boundary",
        "Content-Type: application/octet-stream",
        "",
        [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($fileBytes),
        "--$boundary--"
    )

    $body = $bodyLines -join "`r`n"

    $uri = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"

    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ContentType "multipart/related; boundary=$boundary"

    return $response
}

# Search files
function Search-DriveFiles {
    param([string]$SearchQuery)

    $token = Get-AccessToken
    $headers = @{ Authorization = "Bearer $token" }

    $query = "fullText contains '$SearchQuery' and trashed=false"
    $uri = "https://www.googleapis.com/drive/v3/files?q=$([System.Web.HttpUtility]::UrlEncode($query))&fields=files(id,name,mimeType,parents,webViewLink)&pageSize=100"

    $response = Invoke-RestMethod -Uri $uri -Headers $headers

    return $response.files
}

# Main execution
Add-Type -AssemblyName System.Web

switch ($Action) {
    'auth' {
        Start-OAuth
    }

    'find-folder' {
        if (-not $FolderName) {
            throw "FolderName required"
        }

        $folder = Find-DriveFolder -Name $FolderName
        if ($folder) {
            Write-Host "✅ Folder found: $($folder.name)" -ForegroundColor Green
            Write-Host "📁 ID: $($folder.id)" -ForegroundColor Cyan
            $folder | ConvertTo-Json
        } else {
            Write-Host "❌ Folder not found: $FolderName" -ForegroundColor Red
        }
    }

    'upload' {
        if (-not $FilePath) {
            throw "FilePath required"
        }

        $folderId = $null
        if ($DriveFolder) {
            Write-Host "🔍 Finding folder: $DriveFolder" -ForegroundColor Cyan
            $folder = Find-DriveFolder -Name $DriveFolder
            if (-not $folder) {
                throw "Folder not found: $DriveFolder"
            }
            $folderId = $folder.id
            Write-Host "✅ Folder found: $($folder.name)" -ForegroundColor Green
        }

        Write-Host "📤 Uploading: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
        $result = Upload-DriveFile -LocalPath $FilePath -FolderId $folderId
        Write-Host "✅ Upload successful!" -ForegroundColor Green
        Write-Host "📁 File ID: $($result.id)" -ForegroundColor Cyan
        Write-Host "🔗 https://drive.google.com/file/d/$($result.id)/view" -ForegroundColor Yellow
    }

    'list' {
        $folderId = $null
        if ($DriveFolder) {
            $folder = Find-DriveFolder -Name $DriveFolder
            if (-not $folder) {
                throw "Folder not found: $DriveFolder"
            }
            $folderId = $folder.id
            Write-Host "📁 Listing files in: $($folder.name)" -ForegroundColor Cyan
        } else {
            Write-Host "📁 Listing all files" -ForegroundColor Cyan
        }

        $files = Get-DriveFiles -FolderId $folderId

        if ($files.Count -eq 0) {
            Write-Host "No files found" -ForegroundColor Yellow
        } else {
            Write-Host "`n$($files.Count) files found:" -ForegroundColor Green
            $files | Format-Table -Property name, mimeType, @{Label="Size (KB)"; Expression={[math]::Round($_.size/1KB, 2)}}, modifiedTime
        }
    }

    'search' {
        if (-not $Query) {
            throw "Query required"
        }

        Write-Host "🔍 Searching for: $Query" -ForegroundColor Cyan
        $files = Search-DriveFiles -SearchQuery $Query

        if ($files.Count -eq 0) {
            Write-Host "No files found" -ForegroundColor Yellow
        } else {
            Write-Host "`n$($files.Count) files found:" -ForegroundColor Green
            foreach ($file in $files) {
                Write-Host "📄 $($file.name)" -ForegroundColor White
                Write-Host "   🔗 $($file.webViewLink)" -ForegroundColor Cyan
                Write-Host "   📁 ID: $($file.id)" -ForegroundColor Gray
                Write-Host ""
            }
        }
    }
}
