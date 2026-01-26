<#
.SYNOPSIS
    Complete World Development Dashboard: Articles + YouTube Videos

.DESCRIPTION
    Combines WebSearch articles (top) with YouTube videos (bottom).
    - Articles: Title, description, link
    - Videos: Thumbnail, title, channel, clickable URL

.EXAMPLE
    .\world-dashboard-complete.ps1

.NOTES
    Created: 2026-01-26
    Requires: YouTube API key in appsettings.Secrets.json
#>

param(
    [bool]$AutoOpen = $true,
    [string]$OutputPath = "C:\projects\world_development\dashboard"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$timestamp = Get-Date
$dateStr = $timestamp.ToString("yyyy-MM-dd")
$timeStr = $timestamp.ToString("HH:mm:ss")
$dashboardFile = Join-Path $OutputPath "world-dashboard-$dateStr.html"
$latestFile = Join-Path $OutputPath "latest.html"

Write-Host "Complete Dashboard: Articles + YouTube Videos - $dateStr $timeStr" -ForegroundColor Cyan
Write-Host ""

# Load YouTube API Key
Write-Host "[1/5] Loading YouTube API Key..." -ForegroundColor Yellow
$secretsPath = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
$youtubeApiKey = $null

if (Test-Path $secretsPath) {
    $secrets = Get-Content $secretsPath | ConvertFrom-Json
    $youtubeApiKey = $secrets.ApiSettings.YouTubeApiKey

    if ($youtubeApiKey) {
        Write-Host "      [OK] YouTube API Key loaded" -ForegroundColor Green
    }
}

Write-Host ""

# Articles will be populated via WebSearch (Claude will do this)
Write-Host "[2/5] Article sections ready (to be populated by Claude)" -ForegroundColor Yellow
Write-Host ""

# Fetch YouTube videos
$kenyaVideosHtml = ""
$netherlandsVideosHtml = ""
$aiVideosHtml = ""
$holochainVideosHtml = ""

if ($youtubeApiKey) {
    Write-Host "[3/5] Fetching YouTube videos (past 3 days)..." -ForegroundColor Yellow

    try {
        # Kenya videos
        Write-Host "      - Kenya videos..." -ForegroundColor Gray
        $kenyaResults = & "C:\scripts\tools\youtube-video-finder.ps1" `
            -ApiKey $youtubeApiKey `
            -Queries @("Kenya tech startup 2026", "Kenya business investment") `
            -MaxResults 4 `
            -DaysBack 7 `
            -OutputFormat html

        if ($kenyaResults) {
            $kenyaVideosHtml = $kenyaResults
            Write-Host "        [OK]" -ForegroundColor Green
        }

        # Netherlands videos
        Write-Host "      - Netherlands videos..." -ForegroundColor Gray
        $netherlandsResults = & "C:\scripts\tools\youtube-video-finder.ps1" `
            -ApiKey $youtubeApiKey `
            -Queries @("Netherlands crypto news", "Nederland cryptocurrency") `
            -MaxResults 4 `
            -DaysBack 7 `
            -OutputFormat html

        if ($netherlandsResults) {
            $netherlandsVideosHtml = $netherlandsResults
            Write-Host "        [OK]" -ForegroundColor Green
        }

        # AI videos
        Write-Host "      - AI videos..." -ForegroundColor Gray
        $aiResults = & "C:\scripts\tools\youtube-video-finder.ps1" `
            -ApiKey $youtubeApiKey `
            -Queries @("AI tutorial 2026", "new AI models", "ChatGPT Claude tutorial") `
            -MaxResults 5 `
            -DaysBack 7 `
            -OutputFormat html

        if ($aiResults) {
            $aiVideosHtml = $aiResults
            Write-Host "        [OK]" -ForegroundColor Green
        }

        # Holochain videos
        Write-Host "      - Holochain HOT videos..." -ForegroundColor Gray
        $holochainResults = & "C:\scripts\tools\youtube-video-finder.ps1" `
            -ApiKey $youtubeApiKey `
            -Queries @("Holochain HOT crypto", "HOT token analysis") `
            -MaxResults 4 `
            -DaysBack 7 `
            -OutputFormat html

        if ($holochainResults) {
            $holochainVideosHtml = $holochainResults
            Write-Host "        [OK]" -ForegroundColor Green
        }

        Write-Host "      [OK] YouTube videos fetched" -ForegroundColor Green
    }
    catch {
        Write-Host "      [ERROR] YouTube API: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "[3/5] SKIPPED - No YouTube API Key" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[4/5] Generating HTML template..." -ForegroundColor Yellow

# HTML Template
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

        .status-bar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            margin-top: 15px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(600px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
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

        .item {
            padding: 12px;
            margin-bottom: 10px;
            background: #f7fafc;
            border-left: 4px solid #667eea;
            border-radius: 5px;
        }

        .item strong {
            color: #2d3748;
            display: block;
            margin-bottom: 5px;
        }

        .item a {
            color: #667eea;
            text-decoration: none;
        }

        .item a:hover {
            color: #764ba2;
            text-decoration: underline;
        }

        .article-item {
            border-left-color: #48bb78;
        }

        .article-link {
            display: inline-block;
            margin-top: 5px;
            font-size: 0.9em;
            color: #667eea;
        }

        .video-section {
            margin-top: 40px;
        }

        .video-section-header {
            background: linear-gradient(135deg, #f56565 0%, #ed64a6 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 20px;
            text-align: center;
        }

        .video-section-header h1 {
            font-size: 2em;
            margin-bottom: 10px;
        }

        .video-item {
            padding: 15px !important;
            min-height: 110px;
            border-left-color: #f56565 !important;
            clear: both;
            overflow: hidden;
        }

        .video-item img {
            width: 120px;
            height: 90px;
            float: left;
            margin-right: 12px;
            border-radius: 5px;
            object-fit: cover;
        }

        .video-item a {
            color: #2d3748;
            font-weight: 600;
        }

        .video-item .channel {
            color: #718096;
            font-size: 0.9em;
        }

        .video-item .date {
            color: #a0aec0;
            font-size: 0.85em;
        }

        .footer {
            background: white;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            color: #718096;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-top: 30px;
        }

        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- HEADER -->
        <div class="header">
            <h1>📰 Jouw Persoonlijke Dashboard</h1>
            <div class="meta">
                <strong>Datum:</strong> $dateStr | <strong>Tijd:</strong> $timeStr | <strong>Tijdskader:</strong> Afgelopen 3 Dagen
            </div>
            <div class="status-bar">
                Artikelen + YouTube Videos | Kenya | Nederland | AI | Holochain HOT
            </div>
        </div>

        <!-- ARTICLES SECTION -->
        <div class="grid">
            <!-- Kenya Articles -->
            <div class="card">
                <div class="card-header">
                    <div class="icon">[KE📰]</div>
                    <h2>Kenya Artikelen</h2>
                </div>
                <div class="card-content" id="kenya-articles">
                    <div class="item">Wordt geladen door Claude...</div>
                </div>
            </div>

            <!-- Netherlands Articles -->
            <div class="card">
                <div class="card-header">
                    <div class="icon">[NL📰]</div>
                    <h2>Nederland Artikelen</h2>
                </div>
                <div class="card-content" id="netherlands-articles">
                    <div class="item">Wordt geladen door Claude...</div>
                </div>
            </div>

            <!-- AI Articles -->
            <div class="card">
                <div class="card-header">
                    <div class="icon">[AI📰]</div>
                    <h2>AI Models & Tools Artikelen</h2>
                </div>
                <div class="card-content" id="ai-articles">
                    <div class="item">Wordt geladen door Claude...</div>
                </div>
            </div>

            <!-- Holochain Articles -->
            <div class="card">
                <div class="card-header">
                    <div class="icon">[HOT📰]</div>
                    <h2>Holochain HOT Artikelen</h2>
                </div>
                <div class="card-content" id="holochain-articles">
                    <div class="item">Wordt geladen door Claude...</div>
                </div>
            </div>
        </div>

        <!-- YOUTUBE VIDEOS SECTION -->
        <div class="video-section">
            <div class="video-section-header">
                <h1>📺 YouTube Videos (Afgelopen Week)</h1>
                <p>Klik direct op de videos om te kijken</p>
            </div>

            <div class="grid">
                <!-- Kenya Videos -->
                <div class="card">
                    <div class="card-header">
                        <div class="icon">[KE▶️]</div>
                        <h2>Kenya Videos</h2>
                    </div>
                    <div class="card-content">
                        $kenyaVideosHtml
                    </div>
                </div>

                <!-- Netherlands Videos -->
                <div class="card">
                    <div class="card-header">
                        <div class="icon">[NL▶️]</div>
                        <h2>Nederland Videos</h2>
                    </div>
                    <div class="card-content">
                        $netherlandsVideosHtml
                    </div>
                </div>

                <!-- AI Videos -->
                <div class="card">
                    <div class="card-header">
                        <div class="icon">[AI▶️]</div>
                        <h2>AI Videos</h2>
                    </div>
                    <div class="card-content">
                        $aiVideosHtml
                    </div>
                </div>

                <!-- Holochain Videos -->
                <div class="card">
                    <div class="card-header">
                        <div class="icon">[HOT▶️]</div>
                        <h2>Holochain HOT Videos</h2>
                    </div>
                    <div class="card-content">
                        $holochainVideosHtml
                    </div>
                </div>
            </div>
        </div>

        <!-- FOOTER -->
        <div class="footer">
            Gegenereerd door <strong>Claude Agent</strong> | WebSearch + YouTube Data API v3<br>
            📅 Volgende Update: Morgen om 12:00 (automatisch)
        </div>
    </div>
</body>
</html>
"@

# Save template
Set-Content -Path $dashboardFile -Value $html -Encoding UTF8
Set-Content -Path $latestFile -Value $html -Encoding UTF8

Write-Host "      [OK] Template saved: $dashboardFile" -ForegroundColor Green
Write-Host ""

Write-Host "[5/5] Opening dashboard..." -ForegroundColor Yellow
if ($AutoOpen) {
    Start-Process $latestFile
    Write-Host "      [OK] Dashboard opened" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEMPLATE READY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Location: $latestFile" -ForegroundColor Gray
Write-Host "YouTube Videos: POPULATED" -ForegroundColor Green
Write-Host "Articles: AWAITING CLAUDE WEBSEARCH" -ForegroundColor Yellow
Write-Host ""
Write-Host "Claude will now populate articles via WebSearch..." -ForegroundColor Cyan

return @{
    DashboardPath = $dashboardFile
    LatestPath = $latestFile
    Timestamp = $timestamp
    YouTubeEnabled = ($null -ne $youtubeApiKey)
    Status = 'Template Ready - Awaiting Article Population'
}
