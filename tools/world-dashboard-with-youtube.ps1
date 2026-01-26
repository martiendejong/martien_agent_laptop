<#
.SYNOPSIS
    Generate World Development Dashboard with REAL YouTube video links

.DESCRIPTION
    Uses YouTube Data API v3 to fetch actual video URLs for past 3 days.
    Fully integrated with youtube-video-finder.ps1 script.

.PARAMETER AutoOpen
    Automatically open dashboard in browser (default: true)

.PARAMETER OutputPath
    Path to save HTML dashboard (default: C:\projects\world_development\dashboard)

.EXAMPLE
    .\world-dashboard-with-youtube.ps1

.NOTES
    Created: 2026-01-26
    Requires: YouTube API key in appsettings.Secrets.json
    Setup: See YOUTUBE_API_SETUP.md
#>

param(
    [bool]$AutoOpen = $true,
    [string]$OutputPath = "C:\projects\world_development\dashboard"
)

$ErrorActionPreference = "Stop"

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$timestamp = Get-Date
$dateStr = $timestamp.ToString("yyyy-MM-dd")
$timeStr = $timestamp.ToString("HH:mm:ss")
$dashboardFile = Join-Path $OutputPath "world-dashboard-$dateStr.html"
$latestFile = Join-Path $OutputPath "latest.html"

Write-Host "World Development Dashboard with YouTube Videos - $dateStr $timeStr" -ForegroundColor Cyan
Write-Host ""

# Load YouTube API Key from secrets
Write-Host "[1/4] Loading YouTube API Key..." -ForegroundColor Yellow
$secretsPath = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
$youtubeApiKey = $null

if (Test-Path $secretsPath) {
    $secrets = Get-Content $secretsPath | ConvertFrom-Json
    $youtubeApiKey = $secrets.ApiSettings.YouTubeApiKey

    if ($youtubeApiKey) {
        Write-Host "      [OK] YouTube API Key loaded" -ForegroundColor Green
    }
    else {
        Write-Host "      [!] YouTube API Key not found in secrets" -ForegroundColor Yellow
        Write-Host "      See: C:\scripts\tools\YOUTUBE_API_SETUP.md for setup instructions" -ForegroundColor Gray
    }
}
else {
    Write-Host "      [!] Secrets file not found" -ForegroundColor Yellow
}

Write-Host ""

# Fetch YouTube videos if API key exists
$kenyaVideosHtml = ""
$netherlandsVideosHtml = ""
$aiVideosHtml = ""
$holochainVideosHtml = ""

if ($youtubeApiKey) {
    Write-Host "[2/4] Fetching YouTube videos (past 3 days)..." -ForegroundColor Yellow

    try {
        # Define queries for each category
        $queries = @{
            "Kenya" = @("Kenya tech startup 2026", "Kenya business investment diaspora")
            "Netherlands" = @("Netherlands crypto news", "Nederland cryptocurrency belasting")
            "AI" = @("AI tutorial 2026", "new AI tools", "ChatGPT Claude tutorial")
            "Holochain" = @("Holochain HOT analysis", "HOT crypto price prediction")
        }

        # Fetch Kenya videos
        Write-Host "      - Kenya videos..." -ForegroundColor Gray
        $kenyaResults = & "C:\scripts\tools\youtube-video-finder.ps1" `
            -ApiKey $youtubeApiKey `
            -Queries $queries["Kenya"] `
            -MaxResults 3 `
            -DaysBack 3 `
            -OutputFormat html

        if ($kenyaResults) {
            $kenyaVideosHtml = $kenyaResults
            Write-Host "        [OK] Found Kenya videos" -ForegroundColor Green
        }

        # Fetch Netherlands videos
        Write-Host "      - Netherlands videos..." -ForegroundColor Gray
        $netherlandsResults = & "C:\scripts\tools\youtube-video-finder.ps1" `
            -ApiKey $youtubeApiKey `
            -Queries $queries["Netherlands"] `
            -MaxResults 3 `
            -DaysBack 3 `
            -OutputFormat html

        if ($netherlandsResults) {
            $netherlandsVideosHtml = $netherlandsResults
            Write-Host "        [OK] Found Netherlands videos" -ForegroundColor Green
        }

        # Fetch AI videos
        Write-Host "      - AI videos..." -ForegroundColor Gray
        $aiResults = & "C:\scripts\tools\youtube-video-finder.ps1" `
            -ApiKey $youtubeApiKey `
            -Queries $queries["AI"] `
            -MaxResults 5 `
            -DaysBack 3 `
            -OutputFormat html

        if ($aiResults) {
            $aiVideosHtml = $aiResults
            Write-Host "        [OK] Found AI videos" -ForegroundColor Green
        }

        # Fetch Holochain videos
        Write-Host "      - Holochain HOT videos..." -ForegroundColor Gray
        $holochainResults = & "C:\scripts\tools\youtube-video-finder.ps1" `
            -ApiKey $youtubeApiKey `
            -Queries $queries["Holochain"] `
            -MaxResults 3 `
            -DaysBack 3 `
            -OutputFormat html

        if ($holochainResults) {
            $holochainVideosHtml = $holochainResults
            Write-Host "        [OK] Found Holochain videos" -ForegroundColor Green
        }

        Write-Host "      [OK] All YouTube videos fetched" -ForegroundColor Green
    }
    catch {
        Write-Host "      [ERROR] YouTube API call failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "      Dashboard will show placeholder text instead" -ForegroundColor Yellow
    }
}
else {
    Write-Host "[2/4] SKIPPED - No YouTube API Key configured" -ForegroundColor Yellow
    Write-Host "      Dashboard will show setup instructions" -ForegroundColor Gray
}

Write-Host ""

# Generate HTML Dashboard
Write-Host "[3/4] Generating HTML dashboard..." -ForegroundColor Yellow

# YouTube section fallback
if (-not $youtubeApiKey) {
    $kenyaVideosHtml = @"
<div class="item critical">
    <strong>YouTube API Not Configured</strong>
    Om directe video links te zien, volg deze stappen:<br>
    1. Open: <code>C:\scripts\tools\YOUTUBE_API_SETUP.md</code><br>
    2. Maak een gratis Google Cloud API key (5 minuten)<br>
    3. Add key to: <code>appsettings.Secrets.json</code><br>
    4. Run dit script opnieuw<br><br>
    <strong>Quota:</strong> 10,000 gratis queries per dag (ruim genoeg!)
</div>
"@
    $netherlandsVideosHtml = $kenyaVideosHtml
    $aiVideosHtml = $kenyaVideosHtml
    $holochainVideosHtml = $kenyaVideosHtml
}
elseif (-not $kenyaVideosHtml -and -not $aiVideosHtml) {
    # API key exists but no videos found
    $fallbackHtml = @"
<div class="item">
    <strong>Geen videos gevonden afgelopen 3 dagen</strong>
    Dit kan betekenen:<br>
    - Geen nieuwe uploads in deze categorie<br>
    - YouTube API quota limiet bereikt (reset morgen)<br>
    - Probeer DaysBack parameter te verhogen (van 3 naar 7 dagen)
</div>
"@
    if (-not $kenyaVideosHtml) { $kenyaVideosHtml = $fallbackHtml }
    if (-not $netherlandsVideosHtml) { $netherlandsVideosHtml = $fallbackHtml }
    if (-not $aiVideosHtml) { $aiVideosHtml = $fallbackHtml }
    if (-not $holochainVideosHtml) { $holochainVideosHtml = $fallbackHtml }
}

# HTML Template with YouTube video sections
$html = @"
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jouw Persoonlijke Dashboard - $dateStr</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .header {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .header h1 {
            color: #2d3748;
            font-size: 2.5em;
            margin-bottom: 10px;
        }

        .header .meta {
            color: #718096;
            font-size: 1.1em;
        }

        .header .meta strong {
            color: #4a5568;
        }

        .status-bar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            margin-top: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .status-bar .status {
            font-size: 1.1em;
            font-weight: 600;
        }

        .status-bar .badge {
            background: rgba(255,255,255,0.2);
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(600px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        }

        .card-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 3px solid #e2e8f0;
        }

        .card-header .icon {
            font-size: 2em;
            margin-right: 15px;
        }

        .card-header h2 {
            color: #2d3748;
            font-size: 1.8em;
        }

        .card-content {
            color: #4a5568;
            line-height: 1.8;
        }

        .card-content .item {
            padding: 12px;
            margin-bottom: 10px;
            background: #f7fafc;
            border-left: 4px solid #667eea;
            border-radius: 5px;
            transition: background 0.2s ease;
            overflow: hidden;
        }

        .card-content .item:hover {
            background: #edf2f7;
        }

        .card-content .item strong {
            color: #2d3748;
            display: block;
            margin-bottom: 5px;
        }

        .card-content .item a {
            color: #667eea;
            text-decoration: none;
            display: block;
            transition: color 0.2s ease;
        }

        .card-content .item a:hover {
            color: #764ba2;
        }

        .video-item {
            padding: 15px !important;
            min-height: 110px;
            border-left-color: #f56565 !important;
        }

        .video-item img {
            width: 120px;
            height: 90px;
            float: left;
            margin-right: 12px;
            border-radius: 5px;
            object-fit: cover;
        }

        .critical {
            background: #fff5f5;
            border-left-color: #fc8181;
        }

        .positive {
            background: #f0fff4;
            border-left-color: #48bb78;
        }

        .actionable {
            background: #fffbeb;
            border-left-color: #f59e0b;
        }

        .footer {
            background: white;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            color: #718096;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .footer .next-update {
            margin-top: 10px;
            font-weight: 600;
            color: #4a5568;
        }

        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
            }

            .header h1 {
                font-size: 1.8em;
            }

            .status-bar {
                flex-direction: column;
                gap: 10px;
            }

            .video-item img {
                width: 100px;
                height: 75px;
            }
        }

        code {
            background: #edf2f7;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📺 Jouw Persoonlijke Dashboard met YouTube</h1>
            <div class="meta">
                <strong>Datum:</strong> $dateStr | <strong>Gegenereerd:</strong> $timeStr | <strong>Tijdskader:</strong> Afgelopen 3 Dagen
            </div>
            <div class="status-bar">
                <div class="status">
                    📡 Live YouTube videos: Kenya | Nederland | AI Tools | Holochain HOT
                </div>
                <div class="badge">
                    DIRECTE VIDEO LINKS
                </div>
            </div>
        </div>

        <div class="grid">
            <!-- Kenya YouTube Videos -->
            <div class="card">
                <div class="card-header">
                    <div class="icon">[KE▶️]</div>
                    <h2>Kenya YouTube Videos</h2>
                </div>
                <div class="card-content">
                    $kenyaVideosHtml
                </div>
            </div>

            <!-- Netherlands YouTube Videos -->
            <div class="card">
                <div class="card-header">
                    <div class="icon">[NL▶️]</div>
                    <h2>Nederland YouTube Videos</h2>
                </div>
                <div class="card-content">
                    $netherlandsVideosHtml
                </div>
            </div>

            <!-- AI YouTube Videos -->
            <div class="card">
                <div class="card-header">
                    <div class="icon">[AI▶️]</div>
                    <h2>AI Tools & Tutorials YouTube</h2>
                </div>
                <div class="card-content">
                    $aiVideosHtml
                </div>
            </div>

            <!-- Holochain HOT YouTube Videos -->
            <div class="card">
                <div class="card-header">
                    <div class="icon">[HOT▶️]</div>
                    <h2>Holochain HOT YouTube</h2>
                </div>
                <div class="card-content">
                    $holochainVideosHtml
                </div>
            </div>
        </div>

        <div class="footer">
            <div>
                Gegenereerd door <strong>Claude Agent</strong> met <strong>YouTube Data API v3</strong>
            </div>
            <div class="next-update">
                📅 Volgende Update: Morgen om 12:00 (automatisch met nieuwe videos)
            </div>
        </div>
    </div>
</body>
</html>
"@

# Save dashboard
Set-Content -Path $dashboardFile -Value $html -Encoding UTF8
Set-Content -Path $latestFile -Value $html -Encoding UTF8

Write-Host "      [OK] Dashboard saved: $dashboardFile" -ForegroundColor Green
Write-Host ""

# Open in browser
if ($AutoOpen) {
    Write-Host "[4/4] Opening dashboard in browser..." -ForegroundColor Yellow
    Start-Process $latestFile
    Write-Host "      [OK] Dashboard opened" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DASHBOARD READY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Location: $latestFile" -ForegroundColor Gray
Write-Host "YouTube Videos: $(if ($youtubeApiKey) { 'ENABLED' } else { 'NOT CONFIGURED' })" -ForegroundColor Gray
Write-Host ""

if (-not $youtubeApiKey) {
    Write-Host "SETUP YOUTUBE API (5 minuten):" -ForegroundColor Yellow
    Write-Host "1. Open: C:\scripts\tools\YOUTUBE_API_SETUP.md" -ForegroundColor Gray
    Write-Host "2. Volg de instructies" -ForegroundColor Gray
    Write-Host "3. Run dit script opnieuw" -ForegroundColor Gray
}

return @{
    DashboardPath = $dashboardFile
    LatestPath = $latestFile
    Timestamp = $timestamp
    YouTubeEnabled = ($null -ne $youtubeApiKey)
    Status = 'Complete'
}
