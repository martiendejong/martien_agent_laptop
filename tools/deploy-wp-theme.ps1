param(
    [string]$SiteUrl = "https://artrevisionist.com",
    [string]$Username = "wreckingball",
    [string]$Password = "Th1s1sSp4rt4!",
    [string]$ThemeZip = "C:\Users\HP\Downloads\artrevisionist-wp-theme.zip"
)

Add-Type -AssemblyName System.Web
$ErrorActionPreference = "Stop"

# Step 1: Get login page first (to get cookies)
Write-Host "Getting login page..."
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    $loginPage = Invoke-WebRequest -Uri "$SiteUrl/wp-login.php" -WebSession $session -UseBasicParsing
    Write-Host "Login page loaded. Cookies: $($session.Cookies.Count)"
} catch {
    Write-Host "Warning getting login page: $_"
}

# Step 2: Login
Write-Host "Logging in as $Username..."
$loginBody = @{
    log = $Username
    pwd = $Password
    "wp-submit" = "Log In"
    redirect_to = "$SiteUrl/wp-admin/"
    testcookie = 1
}

try {
    $loginResponse = Invoke-WebRequest -Uri "$SiteUrl/wp-login.php" -Method POST -Body $loginBody -WebSession $session -UseBasicParsing
    Write-Host "Login response: $($loginResponse.StatusCode). Cookies: $($session.Cookies.Count)"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 302 -or $_.Exception.Message -match "redirect") {
        Write-Host "Login redirect (expected). Cookies: $($session.Cookies.Count)"
    } else {
        Write-Host "Login error: $_"
    }
}

# Show cookies for debug
$cookies = $session.Cookies.GetCookies("$SiteUrl")
Write-Host "Session cookies ($($cookies.Count)):"
foreach ($c in $cookies) {
    Write-Host "  - $($c.Name) = $($c.Value.Substring(0, [Math]::Min(20, $c.Value.Length)))..."
}

# Step 3: Try to access wp-admin dashboard first
Write-Host "`nTesting wp-admin access..."
try {
    $dashPage = Invoke-WebRequest -Uri "$SiteUrl/wp-admin/" -WebSession $session -UseBasicParsing -MaximumRedirection 5
    $titleMatch = [regex]::Match($dashPage.Content, '<title>([^<]+)</title>')
    Write-Host "Dashboard page title: $($titleMatch.Groups[1].Value)"

    if ($dashPage.Content -match "wp-login") {
        Write-Host "ERROR: Still on login page. Authentication failed."
        exit 1
    }
} catch {
    Write-Host "ERROR accessing dashboard: $_"
    exit 1
}

# Step 4: Get theme upload page
Write-Host "`nGetting theme upload page..."
$uploadPage = Invoke-WebRequest -Uri "$SiteUrl/wp-admin/theme-install.php?upload" -WebSession $session -UseBasicParsing -MaximumRedirection 5
$nonceMatch = [regex]::Match($uploadPage.Content, 'name="_wpnonce"\s+value="([^"]+)"')

if (-not $nonceMatch.Success) {
    # Try alternative nonce pattern
    $nonceMatch = [regex]::Match($uploadPage.Content, '_wpnonce=([a-f0-9]+)')
}

if (-not $nonceMatch.Success) {
    Write-Host "ERROR: Could not find upload nonce."
    $titleMatch = [regex]::Match($uploadPage.Content, '<title>([^<]+)</title>')
    Write-Host "Page title: $($titleMatch.Groups[1].Value)"
    exit 1
}

$nonce = $nonceMatch.Groups[1].Value
Write-Host "Got nonce: $nonce"

# Step 5: Upload theme
$fileSize = [Math]::Round((Get-Item $ThemeZip).Length / 1MB, 1)
Write-Host "`nUploading theme zip ($fileSize MB)..."

$boundary = [System.Guid]::NewGuid().ToString()
$CRLF = "`r`n"

# Build multipart body manually
$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("--$boundary$CRLF")
[void]$sb.Append("Content-Disposition: form-data; name=`"_wpnonce`"$CRLF$CRLF")
[void]$sb.Append("$nonce$CRLF")
[void]$sb.Append("--$boundary$CRLF")
[void]$sb.Append("Content-Disposition: form-data; name=`"_wp_http_referer`"$CRLF$CRLF")
[void]$sb.Append("/wp-admin/theme-install.php?upload$CRLF")
[void]$sb.Append("--$boundary$CRLF")
[void]$sb.Append("Content-Disposition: form-data; name=`"themezip`"; filename=`"artrevisionist-wp-theme.zip`"$CRLF")
[void]$sb.Append("Content-Type: application/zip$CRLF$CRLF")

$headerBytes = [System.Text.Encoding]::UTF8.GetBytes($sb.ToString())
$fileBytes = [System.IO.File]::ReadAllBytes($ThemeZip)
$footerBytes = [System.Text.Encoding]::UTF8.GetBytes("$CRLF--$boundary--$CRLF")

$bodyStream = New-Object System.IO.MemoryStream
$bodyStream.Write($headerBytes, 0, $headerBytes.Length)
$bodyStream.Write($fileBytes, 0, $fileBytes.Length)
$bodyStream.Write($footerBytes, 0, $footerBytes.Length)
$bodyBytes = $bodyStream.ToArray()
$bodyStream.Dispose()

Write-Host "Uploading ($([Math]::Round($bodyBytes.Length / 1MB, 1)) MB total payload)..."

$uploadResponse = Invoke-WebRequest -Uri "$SiteUrl/wp-admin/update.php?action=upload-theme" `
    -Method POST `
    -Body $bodyBytes `
    -ContentType "multipart/form-data; boundary=$boundary" `
    -WebSession $session `
    -UseBasicParsing `
    -MaximumRedirection 5

Write-Host "Upload response status: $($uploadResponse.StatusCode)"

# Check result
$content = $uploadResponse.Content

if ($content -match "already exists") {
    Write-Host "Theme already exists on server. Looking for replace/overwrite option..."

    $overwriteMatch = [regex]::Match($content, 'href="([^"]*overwrite=update-theme[^"]*)"')
    if ($overwriteMatch.Success) {
        $overwriteUrl = [System.Web.HttpUtility]::HtmlDecode($overwriteMatch.Groups[1].Value)
        if (-not $overwriteUrl.StartsWith("http")) {
            $overwriteUrl = "$SiteUrl$overwriteUrl"
        }
        Write-Host "Replacing existing theme at: $overwriteUrl"
        $replaceResponse = Invoke-WebRequest -Uri $overwriteUrl -WebSession $session -UseBasicParsing -MaximumRedirection 5

        if ($replaceResponse.Content -match "successfully") {
            Write-Host "SUCCESS: Theme replaced!"
        } else {
            # Extract any status text
            $msgs = [regex]::Matches($replaceResponse.Content, '<p[^>]*>([^<]+)</p>')
            foreach ($m in $msgs) {
                $txt = $m.Groups[1].Value.Trim()
                if ($txt.Length -gt 5 -and $txt -notmatch "^\s*$") {
                    Write-Host "  > $txt"
                }
            }
        }
    } else {
        Write-Host "Could not find overwrite link automatically."
        Write-Host "You may need to delete the theme first via WP admin, then re-upload."
    }
} elseif ($content -match "successfully") {
    Write-Host "SUCCESS: Theme uploaded and installed!"
} else {
    Write-Host "Upload completed. Extracting status..."
    $msgs = [regex]::Matches($content, '<p[^>]*>([^<]+)</p>')
    foreach ($m in $msgs) {
        $txt = $m.Groups[1].Value.Trim()
        if ($txt.Length -gt 5) {
            Write-Host "  > $txt"
        }
    }
}
