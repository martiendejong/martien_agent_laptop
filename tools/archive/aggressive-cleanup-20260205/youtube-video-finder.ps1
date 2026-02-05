<#
.SYNOPSIS
    Find recent YouTube videos using YouTube Data API v3

.DESCRIPTION
    Searches YouTube for videos matching specific queries, filtered to past 3 days.
    Returns video URLs, titles, thumbnails, and metadata for dashboard injection.

.PARAMETER ApiKey
    YouTube Data API v3 key (get from Google Cloud Console)

.PARAMETER Queries
    Array of search queries to execute

.PARAMETER MaxResults
    Maximum results per query (default: 5)

.PARAMETER DaysBack
    Number of days to search back (default: 3)

.PARAMETER OutputFormat
    Output format: json, html, object (default: object)

.EXAMPLE
    .\youtube-video-finder.ps1 -ApiKey "YOUR_API_KEY" -Queries @("AI tutorial", "Holochain HOT")

.EXAMPLE
    # For dashboard integration
    $videos = .\youtube-video-finder.ps1 -ApiKey $env:YOUTUBE_API_KEY -Queries @("Kenya tech") -OutputFormat html

.NOTES
    Created: 2026-01-26
    Part of World Development Dashboard automation
    Requires: YouTube Data API v3 enabled in Google Cloud Console
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ApiKey,

    [Parameter(Mandatory=$true)]
    [string[]]$Queries,

    [int]$MaxResults = 5,

    [int]$DaysBack = 3,

    [ValidateSet('json', 'html', 'object')]
    [string]$OutputFormat = 'object'
)

$ErrorActionPreference = "Stop"

# Calculate publishedAfter date (3 days ago)
$publishedAfter = (Get-Date).AddDays(-$DaysBack).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "YouTube Video Finder - Searching videos from past $DaysBack days" -ForegroundColor Cyan
Write-Host "Published After: $publishedAfter" -ForegroundColor Gray
Write-Host ""

$allResults = @()

foreach ($query in $Queries) {
    Write-Host "[*] Searching: $query" -ForegroundColor Yellow

    # YouTube Data API v3 - Search endpoint
    $apiUrl = "https://www.googleapis.com/youtube/v3/search"
    $params = @{
        part = "snippet"
        q = $query
        type = "video"
        order = "date"
        publishedAfter = $publishedAfter
        maxResults = $MaxResults
        key = $ApiKey
        relevanceLanguage = "en" # Can be changed to "nl" for Dutch content
    }

    # Build query string
    $queryString = ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join "&"
    $fullUrl = "$apiUrl`?$queryString"

    try {
        $response = Invoke-RestMethod -Uri $fullUrl -Method Get -ErrorAction Stop

        if ($response.items -and $response.items.Count -gt 0) {
            Write-Host "   Found: $($response.items.Count) videos" -ForegroundColor Green

            foreach ($item in $response.items) {
                $videoId = $item.id.videoId
                $videoUrl = "https://www.youtube.com/watch?v=$videoId"
                $title = $item.snippet.title
                $channelTitle = $item.snippet.channelTitle
                $publishedAt = $item.snippet.publishedAt
                $thumbnail = $item.snippet.thumbnails.medium.url
                $description = $item.snippet.description

                $videoData = [PSCustomObject]@{
                    Query = $query
                    VideoId = $videoId
                    VideoUrl = $videoUrl
                    Title = $title
                    ChannelTitle = $channelTitle
                    PublishedAt = $publishedAt
                    Thumbnail = $thumbnail
                    Description = $description
                }

                $allResults += $videoData

                Write-Host "      - $title" -ForegroundColor Gray
                Write-Host "        Channel: $channelTitle | Published: $publishedAt" -ForegroundColor DarkGray
                Write-Host "        URL: $videoUrl" -ForegroundColor DarkGray
            }
        }
        else {
            Write-Host "   No videos found" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red

        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            Write-Host "   API Response: $errorBody" -ForegroundColor Red
        }
    }

    Write-Host ""
}

# Output results based on format
switch ($OutputFormat) {
    'json' {
        $allResults | ConvertTo-Json -Depth 10
    }
    'html' {
        $html = ""
        $groupedResults = $allResults | Group-Object Query

        foreach ($group in $groupedResults) {
            $html += "<div class='query-group'>`n"
            $html += "  <h3>$($group.Name)</h3>`n"

            foreach ($video in $group.Group) {
                $html += "  <div class='item video-item'>`n"
                $html += "    <a href='$($video.VideoUrl)' target='_blank'>`n"
                $html += "      <img src='$($video.Thumbnail)' alt='$($video.Title)' style='width:120px;height:90px;float:left;margin-right:12px;border-radius:5px;'>`n"
                $html += "      <strong>▶️ $($video.Title)</strong><br>`n"
                $html += "      <span style='color:#718096;font-size:0.9em;'>$($video.ChannelTitle)</span><br>`n"
                $html += "      <span style='color:#a0aec0;font-size:0.85em;'>$($video.PublishedAt)</span>`n"
                $html += "    </a>`n"
                $html += "  </div>`n"
            }

            $html += "</div>`n"
        }

        return $html
    }
    'object' {
        return $allResults
    }
}

Write-Host "[OK] Search complete. Found $($allResults.Count) total videos" -ForegroundColor Green
