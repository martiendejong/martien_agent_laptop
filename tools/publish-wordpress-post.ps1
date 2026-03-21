param(
    [Parameter(Mandatory=$true)]
    [string]$MarkdownFile,

    [Parameter(Mandatory=$true)]
    [string]$WordPressUrl,

    [Parameter(Mandatory=$true)]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [string]$AppPassword,

    [Parameter(Mandatory=$false)]
    [string]$Status = "publish",  # publish or draft

    [Parameter(Mandatory=$false)]
    [string]$Slug
)

# Read markdown file
$markdown = Get-Content -Path $MarkdownFile -Raw

# Extract title (first # heading)
if ($markdown -match "^#\s+(.+)$") {
    $title = $Matches[1]
} else {
    Write-Error "No title found in markdown (expected # heading)"
    exit 1
}

# Remove YAML frontmatter if exists
$markdown = $markdown -replace "^---[\r\n]+.*?[\r\n]+---[\r\n]+", ""

# Convert markdown to HTML (basic conversion)
# For production, consider using pandoc or a proper markdown library
$html = $markdown

# Replace markdown headers
$html = $html -replace "^###\s+(.+)$", "<h3>`$1</h3>" -replace "`r`n", "`n"
$html = $html -replace "^##\s+(.+)$", "<h2>`$1</h2>" -replace "`r`n", "`n"
$html = $html -replace "^#\s+(.+)$", "<h1>`$1</h1>" -replace "`r`n", "`n"

# Replace bold
$html = $html -replace "\*\*(.+?)\*\*", "<strong>`$1</strong>"

# Replace emphasis
$html = $html -replace "\*(.+?)\*", "<em>`$1</em>"

# Replace links
$html = $html -replace "\[([^\]]+)\]\(([^\)]+)\)", '<a href="`$2">`$1</a>'

# Replace line breaks
$html = $html -replace "`n`n", "</p><p>"
$html = "<p>" + $html + "</p>"

# Replace horizontal rules
$html = $html -replace "<p>---+</p>", "<hr />"

# Replace lists (basic)
$html = $html -replace "<p>-\s+(.+?)</p>", "<ul><li>`$1</li></ul>"
$html = $html -replace "<p>(\d+)\.\s+(.+?)</p>", "<ol><li>`$2</li></ol>"

# Prepare post data
$postData = @{
    title = $title
    content = $html
    status = $Status
} | ConvertTo-Json -Depth 10

if ($Slug) {
    $postData = $postData | ConvertFrom-Json
    $postData.slug = $Slug
    $postData = $postData | ConvertTo-Json -Depth 10
}

# Create auth header
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${AppPassword}"))
$headers = @{
    "Authorization" = "Basic $base64Auth"
    "Content-Type" = "application/json"
}

# API endpoint
$apiUrl = "$WordPressUrl/wp-json/wp/v2/posts"

Write-Host "Publishing to: $apiUrl" -ForegroundColor Cyan
Write-Host "Title: $title" -ForegroundColor Cyan
Write-Host "Status: $Status" -ForegroundColor Cyan

try {
    # Make API request
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $postData

    Write-Host "`n✓ Post published successfully!" -ForegroundColor Green
    Write-Host "Post ID: $($response.id)" -ForegroundColor Green
    Write-Host "URL: $($response.link)" -ForegroundColor Green

    return $response
} catch {
    Write-Error "Failed to publish post: $($_.Exception.Message)"
    exit 1
}
